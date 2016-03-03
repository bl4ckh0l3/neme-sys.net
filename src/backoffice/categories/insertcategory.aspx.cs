using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using NHibernate;
using NHibernate.Criterion;

public partial class _Category : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected IList<Category> categories;
	protected IList<Language> languages;
	protected IList<Template> templates;
	protected Category category;
	protected IMultiLanguageRepository mlangrep;
	
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
		cssClass="LCE";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IUserRepository urep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		category = new Category();		
		category.id = -1;
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				category = catrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				category = new Category();		
				category.id = -1;
			}	
		}
		
		// recupero elementi della pagina necessari
		try{				
			categories = catrep.getCategoryList();
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{				
			templates = templrep.getTemplateList(null);		
			if(templates == null){				
				templates = new List<Template>();						
			}
		}catch (Exception ex){
			templates = new List<Template>();
		}
						
		//******** INSERISCO NUOVA CATEGORIA / MODIFICO ESISTENTE				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;			
			try
			{	
				string hierarchy = Request["hierarchy"];
				string description = Request["description"];		
				// verify category non already exists
				if(catrep.categoryAlreadyExists(hierarchy, description, category.id))
				{				
					//Response.Redirect("/error.aspx?error_code=018&id_category="+category.id, false);
					//HttpContext.Current.ApplicationInstance.CompleteRequest();
					url.Append("018&id_category=").Append(category.id);
					carryOn = false;	
				}
											
				if(carryOn)
				{
					int numMenu = Convert.ToInt32(Request["num_menu"]);
					bool setToUsers = Convert.ToBoolean(Convert.ToInt32(Request["set_to_users"]));		
					bool visible = Convert.ToBoolean(Convert.ToInt32(Request["visible"]));	
					bool hasElements = Convert.ToBoolean(Convert.ToInt32(Request["has_elements"]));
					
					int idTemplate = -1;
					if(!String.IsNullOrEmpty(Request["id_template"])){
						idTemplate = Convert.ToInt32(Request["id_template"]);	
					}
					string metaDescription = Request["meta_description"];
					string metaKeyword = Request["meta_keyword"];
					string pageTitle = Request["page_title"];
					string urlSubdomain = Request["url_subdomain"];
					bool automatic = Convert.ToBoolean(Convert.ToInt32(Request["automatic"]));
					bool bolDelImg = false;
					if(!String.IsNullOrEmpty(Request["del_catimage"])){
						bolDelImg = Convert.ToBoolean(Convert.ToInt32(Request["del_catimage"]));	
					}					
					
					category.numMenu = numMenu;
					category.hierarchy = hierarchy;
					category.description = description;
					category.visible = visible;
					category.hasElements = hasElements;
					category.idTemplate = idTemplate;
					category.metaDescription = metaDescription;	
					category.metaKeyword = metaKeyword;	
					category.pageTitle = pageTitle;	
					category.subDomainUrl = urlSubdomain;	
					category.automatic = automatic;
	
					// PREPARO LE LISTE DI TEMPLATES DA INSERIRE/AGGIORNARE IN TRANSAZIONE
					category.templates = new List<CategoryTemplate>();
					CategoryTemplate ctempl;
					if(languages!=null){
						foreach (Language x in languages){
							if(!String.IsNullOrEmpty(Request["id_template_"+x.label]) && -1 != Convert.ToInt32(Request["id_template_"+x.label])){
								ctempl = new CategoryTemplate(category.id, Convert.ToInt32(Request["id_template_"+x.label]), x.label);		
								category.templates.Add(ctempl);
							}
						}
					}
					
					//Response.Write("category:"+category.ToString()+"<br>");
	
		
					// GESTISCO IL CASO DI ASSEGNAZIONE CATEGORIE AUTOMATICHE ANCHE PER GLI UTENTI GUEST			
					// E/O IL CASO DI ASSEGNAZIONE PER GLI UTENTI EDITOR O ADMIN				
					IList<User> users = urep.find(false,false,false,true,false,false);
					IList<User> usersToUpdate = new List<User>(); 
					if(users!= null)
					{
						foreach(User usr in users)
						{
							if((!usr.role.isGuest() && setToUsers))
							{
								UserCategory uc = new UserCategory();
								uc.idCategory = category.id;
								uc.idParentUser = usr.id;										
								usr.categories.Add(uc);	
								usersToUpdate.Add(usr);						
							}	
		
							if(usr.role.isGuest() && category.automatic)
							{
								UserCategory uc = new UserCategory(); 
								uc.idCategory = category.id;
								uc.idParentUser = usr.id;													
								if(!usr.categories.Contains(uc)){
									usr.categories.Add(uc);							
								}								
								usersToUpdate.Add(usr);	
							}
							else if(usr.role.isGuest() && !category.automatic)
							{
								foreach(UserCategory usrcat in usr.categories)
								{
									if(usrcat.idParentUser==usr.id && usrcat.idCategory==category.id)
									{
										usr.categories.Remove(usrcat);
										break;
									}
								}	
								usersToUpdate.Add(usr);							
							}						
						}
					}
	
					// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
					IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
					MultiLanguage ml;
					if(languages!=null){
						foreach (Language x in languages){
							//*** insert description
							ml = mlangrep.find("backend.categorie.detail.table.label.description_"+category.hierarchy, x.label);
							if(ml != null){
								ml.value = Request["description_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.categorie.detail.table.label.description_"+category.hierarchy;
								ml.langCode = x.label;
								ml.value = Request["description_"+x.label];
								if(!String.IsNullOrEmpty(ml.value)){					
									newtranslactions.Add(ml);
								}
							}
							//*** insert summary
							ml = mlangrep.find("backend.categorie.detail.table.label.summary_"+category.hierarchy, x.label);
							if(ml != null){
								ml.value = Request["summary_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.categorie.detail.table.label.summary_"+category.hierarchy;
								ml.langCode = x.label;
								ml.value = Request["summary_"+x.label];
								if(!String.IsNullOrEmpty(ml.value)){					
									newtranslactions.Add(ml);
								}
							}
							//*** insert page_title
							ml = mlangrep.find("backend.categorie.detail.table.label.page_title_"+category.hierarchy, x.label);
							if(ml != null){
								ml.value = Request["page_title_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.categorie.detail.table.label.page_title_"+category.hierarchy;
								ml.langCode = x.label;
								ml.value = Request["page_title_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){				
									newtranslactions.Add(ml);
								}
							}
							//*** insert meta description
							ml = mlangrep.find("backend.categorie.detail.table.label.meta_description_"+category.hierarchy, x.label);
							if(ml != null){
								ml.value = Request["meta_description_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.categorie.detail.table.label.meta_description_"+category.hierarchy;
								ml.langCode = x.label;
								ml.value = Request["meta_description_"+x.label];
								if(!String.IsNullOrEmpty(ml.value)){					
									newtranslactions.Add(ml);
								}
							}
							//*** insert meta keyword
							ml = mlangrep.find("backend.categorie.detail.table.label.meta_keyword_"+category.hierarchy, x.label);
							if(ml != null){
								ml.value = Request["meta_keyword_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.categorie.detail.table.label.meta_keyword_"+category.hierarchy;
								ml.langCode = x.label;
								ml.value = Request["meta_keyword_"+x.label];		
								if(!String.IsNullOrEmpty(ml.value)){			
									newtranslactions.Add(ml);
								}
							}
						}
					}
								
					// recupero l'immagine allegata alla categoria se presente
					string delFilePath = "";
					if(bolDelImg && !String.IsNullOrEmpty(category.filePath)){
						delFilePath = category.id+"/"+category.filePath;
						category.filePath = "";					
					}					
					
					
					HttpFileCollection MyFileCollection = Request.Files;
					HttpPostedFile MyFile = null;
					string fileName = "";
					if(MyFileCollection != null && MyFileCollection.Count>0){
						MyFile = MyFileCollection[0];						
						fileName = Path.GetFileName(MyFile.FileName);
						if(!String.IsNullOrEmpty(fileName)){	
							switch (Path.GetExtension(fileName))
							{
								case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":						
									category.filePath = fileName;
									break;
								default:
									throw new Exception("022");										
									break;
							}						
						}
					}
					
					try
					{
						catrep.saveCompleteCategory(category, usersToUpdate, newtranslactions, updtranslactions, deltranslactions);
	
						foreach(MultiLanguage value in updtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in deltranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in newtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}

						// cancello l'immagine di categoria						
						if(bolDelImg)
						{
							CategoryService.deleteCategoryImage(delFilePath);								
						}
					
						string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/categories/"+category.id); 
						if (!Directory.Exists(dirName))
						{
							Directory.CreateDirectory(dirName);
						}					
						if(!String.IsNullOrEmpty(fileName))
						{
							CategoryService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/categories/"+category.id+"/"+fileName));								
						}						
												
						log.usr= login.userLogged.username;
						log.msg = "save category: "+category.ToString();
						log.type = "info";
						log.date = DateTime.Now;
						lrep.write(log);	
					}
					catch(Exception ex)
					{
						throw;	
					}
				}			
			}
			catch (Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);		
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				//Response.Redirect(url.ToString(),false);	
				//HttpContext.Current.ApplicationInstance.CompleteRequest();
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/categories/categorylist.aspx?cssClass="+Request["cssClass"]);
			}else{
				//Response.Write("An error occured: " + url.ToString());
				Response.Redirect(url.ToString());
			}								
		}
	}
}