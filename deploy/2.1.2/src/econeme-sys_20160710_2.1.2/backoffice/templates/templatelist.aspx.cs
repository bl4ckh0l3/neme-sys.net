using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.IO.Compression;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;

public partial class _TemplateList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass;	
	protected IList<Template> templates;
	protected IList<Language> languages;
	protected ConfigurationService confservice;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="LTP";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		confservice = new ConfigurationService();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		bool addFileExtToUrlRewrite = false;
		if(Convert.ToBoolean(Convert.ToInt32(confservice.get("url_rewrite_file_ext").value))){
			addFileExtToUrlRewrite = true;
		}

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["templateItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["templateItems"];
		}else{
			if (Session["templateItems"] != null) {
				itemsXpage = (int)Session["templateItems"];
			}else{
				Session["templateItems"] = 20;
				itemsXpage = (int)Session["templateItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["templatePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["templatePage"];
		}else{
			if (Session["templatePage"] != null) {
				numPage = (int)Session["templatePage"];
			}else{
				Session["templatePage"]= 1;
				numPage = (int)Session["templatePage"];
			}
		}

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["templatePage"] = 1;
			numPage = (int)Session["templatePage"];
		}

		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}

		long totalcount=0L;
		try
		{
			templates = temprep.find(numPage, itemsXpage, out totalcount);
			if(templates != null){				
				bolFoundLista = true;					
			}
		}
		catch (Exception ex)
		{
			templates = new List<Template>();
			bolFoundLista = false;
		}
		
		//******** INSERISCO NUOVO TEMPLATE / MODIFICO ESISTENTE	
		bool carryOn;	
		if("insert".Equals(Request["operation"]))
		{
			carryOn = true;				
			try
			{
				string tdirectory = Request["directory"];
				
				Template testExist = temprep.getByDirectory(tdirectory);
				if(testExist!=null)
				{
					url.Append(Regex.Replace(lang.getTranslated("backend.templates.lista.button.label.directory_already_exists"), @"\t|\n|\r", " "));					
					carryOn = false;					
				}

				if(carryOn){				
					string tdescription = Request["description"];
					string tlangCode = Request["tlang_code"];
					
					HttpFileCollection MyFileCollection;
					HttpPostedFile MyFile;				
					MyFileCollection = Request.Files;
					MyFile = MyFileCollection[0];
					string zipName = MyFile.FileName;
					
					if(!zipName.EndsWith(".zip"))
					{					
						url.Append(Regex.Replace(lang.getTranslated("backend.templates.lista.button.label.only_zip_file"), @"\t|\n|\r", " "));					
						carryOn = false;
					}
					
					if(carryOn){
						Template newtemplate = new Template();
						newtemplate.directory = tdirectory;
						newtemplate.description = tdescription;
						newtemplate.langCode = tlangCode;
						newtemplate.elemXpage = 10;
						newtemplate.pages = new List<TemplatePage>();
						
						using (Stream MyStream = MyFile.InputStream) 
						{						
							// Open an existing zip file for reading
							using (ZipStorer zip = ZipStorer.Open(MyStream, FileAccess.Read))
							{
								// Read the central directory collection
								List<ZipStorer.ZipFileEntry> dir = zip.ReadCentralDir();
		
								// Look for the desired file
								foreach (ZipStorer.ZipFileEntry entry in dir)
								{
									//Response.Write(entry.FilenameInZip+"<br>");
									string fileName = Path.GetFileName(entry.FilenameInZip);
									string filext = "";
									if(fileName.IndexOf('.')>0)
									{
										//filext = fileName.Substring(fileName.LastIndexOf('.')+1);
										filext = Path.GetExtension(fileName);
									}
		
									if(".bat".Equals(filext) || ".exe".Equals(filext) || ".dll".Equals(filext))
									{					
										url.Append(Regex.Replace(lang.getTranslated("backend.templates.lista.button.label.invalid_file"), @"\t|\n|\r", " "));					
										carryOn = false;
										break;
									}
									
									if(carryOn){
										TemplatePage tp = new TemplatePage();	
										tp.fileName=fileName;						
										bool addPage = false;
										
										switch (filext)
										{
											case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":
												zip.ExtractFile(entry, HttpContext.Current.Server.MapPath("~/public/templates/"+tdirectory+"/"+entry.FilenameInZip));
												tp.filePath=tdirectory+"/"+Path.GetDirectoryName(entry.FilenameInZip);
												tp.priority=-1;									
												addPage = true;
												break;
											case ".cs": case ".aspx": case ".ascx": case ".js": case ".css":
												zip.ExtractFile(entry, HttpContext.Current.Server.MapPath("~/public/templates/"+tdirectory+"/"+entry.FilenameInZip));
												tp.filePath=tdirectory+"/"+Path.GetDirectoryName(entry.FilenameInZip);
												string endUrl = Path.GetFileNameWithoutExtension(entry.FilenameInZip);
												if(addFileExtToUrlRewrite){endUrl = tp.fileName;}
												tp.urlRewrite = tdirectory+"/"+endUrl;
												
												if(filext==".cs" || filext==".js" || filext==".css" || filext==".ascx")
												{
													tp.priority=-1;
													tp.urlRewrite = "";
												}
												addPage = true;
												break;
											default:	
												break;
										}
										
										if(addPage){
											newtemplate.pages.Add(tp);
										}
									}
								}
							}	
						}
						
						if(carryOn){
							try
							{
								temprep.insert(newtemplate);
							}
							catch(Exception ex)
							{		
								throw;					
							}							
						}
					}
				}
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/templates/templatelist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}					
		}
					
		if("addfile".Equals(Request["operation"]))
		{
			carryOn = true;
			try
			{
				string ptemplateid = Request["templateid"];
				Template t = temprep.getById(Convert.ToInt32(ptemplateid));
				if(t!=null)
				{
					HttpFileCollection MyFileCollection;			
					MyFileCollection = Request.Files;				

					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{
						HttpPostedFile tmp = MyFileCollection[k];	
						//Response.Write(tmp.FileName+"<br>");
						string fileName = Path.GetFileName(tmp.FileName);
						string filext = "";
						if(fileName.IndexOf('.')>0)
						{
							filext = Path.GetExtension(fileName);
						}

						if(".bat".Equals(filext) || ".exe".Equals(filext) || ".dll".Equals(filext))
						{					
							url.Append(Regex.Replace(lang.getTranslated("backend.templates.lista.button.label.invalid_file"), @"\t|\n|\r", " "));					
							carryOn = false;
							break;
						}
						
						if(carryOn){
							TemplatePage tp = new TemplatePage();	
							tp.fileName=fileName;						
							bool addPage = false;
							
							switch (filext)
							{
								case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":
									string iprefix = "";
									if(Directory.Exists(HttpContext.Current.Server.MapPath("~/public/templates/"+t.directory+"/img/"))){
										iprefix = "img/";
									}
									TemplateService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/templates/"+t.directory+"/"+iprefix+tmp.FileName));								
									tp.filePath=t.directory+"/"+iprefix+Path.GetDirectoryName(tmp.FileName);
									tp.priority=-1;									
									addPage = true;
									break;
								case ".cs": case ".aspx": case ".ascx": case ".js": case ".css":
									TemplateService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/templates/"+t.directory+"/"+tmp.FileName));								
									tp.filePath=t.directory+"/"+Path.GetDirectoryName(tmp.FileName);
									string endUrl = Path.GetFileNameWithoutExtension(tmp.FileName);
									if(addFileExtToUrlRewrite){endUrl = tp.fileName;}
									tp.urlRewrite = t.directory+"/"+endUrl;
									
									if(filext==".cs" || filext==".js" || filext==".css" || filext==".ascx")
									{
										tp.priority=-1;
										tp.urlRewrite = "";
									}
									addPage = true;
									break;
								default:	
									break;
							}

							foreach(TemplatePage tlp in t.pages)
							{
								if(tlp.fileName==tp.fileName)
								{
									addPage = false;
								}
							}
							
							if(addPage){
								t.pages.Add(tp);
							}
						}						
					}
					
					if(carryOn){
						try
						{
							temprep.update(t);
						}
						catch(Exception ex)
						{		
							throw;					
						}							
					}								
				}
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/templates/templatelist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}
		}						

	
		if(itemsXpage>0){_totalPages = (int)totalcount/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(totalcount % itemsXpage != 0 &&  (_totalPages * itemsXpage) < totalcount) {
			_totalPages = _totalPages +1;	
		}
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass;			
	}
}