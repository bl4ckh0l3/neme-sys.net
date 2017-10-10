using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using System.Runtime.Remoting;
using System.Reflection;
using System.Net.Mail;
using System.Net.Mime;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using NHibernate;
using NHibernate.Criterion;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using com.nemesys.services;

public partial class _FeContent : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected IList<Category> categories;
	protected IList<Language> contentlanguages;	
	protected IList<IElementCategory> contentcategories;	
	protected IList<Language> languages;
	protected IList<User> users;
	protected IList<Newsletter> newsletters;
	protected IList<ContentAttachmentLabel> contentAttachmentLabel;
	protected IList<Comment> comments;
	//protected IList<ContentField> contentFields;
	protected IList<SystemFieldsType> systemFieldsType;
	protected IList<SystemFieldsTypeContent> systemFieldsTypeContent;
	protected IList<string> fieldNames;
	protected IList<string> fieldGroupNames;
	protected IDictionary<string, IList<string>> previewUrls;
	protected FContent content;
	protected IMultiLanguageRepository mlangrep;
	protected IGeolocalizationRepository georep;
	protected IContentRepository contrep;
	protected ICountryRepository countryrep;
	protected string pre_el_id;
	protected int numMaxAttachs = 2;
	protected bool hasContentFields,hasFieldsList,hasComments,hasCommonContentFields;
	protected string country_opt_text;
	protected string state_region_opt_text;
	protected IList<Country> countries;
	protected IList<Country> stateRegions;
	protected IList<ContentField> commonfields;
	protected string secureURL, baseURL;
			
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="LN";	
		
		secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
		baseURL = CommonService.getBaseUrl(Request.Url.ToString(),2).ToString();
		
		login.acceptedRoles = "3";
		if(!login.checkedUser()){
			Response.Redirect(secureURL+"login.aspx?error_code=002");
		}
		contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
		ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		INewsletterRepository newsrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
		IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IUserRepository urep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		ConfigurationService configService = new ConfigurationService();
		contentlanguages = new List<Language>();
		contentcategories = null;
		//contentFields = new List<ContentField>();
		hasContentFields = false;	
		hasCommonContentFields = false;	
		commonfields =  new List<ContentField>();
		hasFieldsList = false;	
		hasComments = false;
		comments = new List<Comment>();
		systemFieldsType = new List<SystemFieldsType>();
		systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		fieldNames = new List<string>();
		fieldGroupNames = new List<string>();
		
		content = new FContent();		
		content.id = -1;
		content.publishDate = DateTime.Now;		
		content.deleteDate = DateTime.Parse("9999-12-31 23:59:59");
		content.languages = new List<ContentLanguage>();
		content.categories = new List<ContentCategory>();
		content.attachments = new List<ContentAttachment>();
		content.fields = new List<ContentField>();
		pre_el_id="";
		if(!String.IsNullOrEmpty(configService.get("num_max_attachments").value))
		{
			numMaxAttachs = Convert.ToInt32(configService.get("num_max_attachments").value);
		}
		StringBuilder url = new StringBuilder(baseURL+"error.aspx?error_code=");		
		Logger log = new Logger();
		
		// recupero elementi della pagina necessari
		country_opt_text = "country";
		state_region_opt_text = "state/region";		
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.country"))){
			country_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.country");
		}
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.state_region"))){
			state_region_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.state_region");
		}
		
		try{				
			categories = catrep.findActive();
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
			users = usrrep.find(null, "3", true, null, false, 1, false, false, false, false, true, false);		
			if(users == null){				
				users = new List<User>();						
			}
		}catch (Exception ex){
			users = new List<User>();
		}
		try{				
			contentAttachmentLabel = contrep.getContentAttachmentLabel();		
			if(contentAttachmentLabel == null){				
				contentAttachmentLabel = new List<ContentAttachmentLabel>();						
			}
		}catch (Exception ex){
			contentAttachmentLabel = new List<ContentAttachmentLabel>();
		}
		try{				
			newsletters = newsrep.findActive();		
			if(newsletters == null){				
				newsletters = new List<Newsletter>();						
			}
		}catch (Exception ex){
			newsletters = new List<Newsletter>();
		}
		try{				
			systemFieldsType = commonrep.getSystemFieldsType();		
			if(systemFieldsType == null){				
				systemFieldsType = new List<SystemFieldsType>();						
			}
		}catch (Exception ex){
			systemFieldsType = new List<SystemFieldsType>();
		}
		try{				
			systemFieldsTypeContent = commonrep.getSystemFieldsTypeContent();		
			if(systemFieldsTypeContent == null){				
				systemFieldsTypeContent = new List<SystemFieldsTypeContent>();						
			}
		}catch (Exception ex){
			systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		}
		try{				
			fieldNames = contrep.findFieldNames(false);		
			if(fieldNames == null){				
				fieldNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldNames = new List<string>();
		}
		try{				
			fieldGroupNames = contrep.findFieldGroupNames(false);		
			if(fieldGroupNames == null){				
				fieldGroupNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldGroupNames = new List<string>();
		}
		try{				
			countries = countryrep.findAllCountries("1");		
			if(countries == null){				
				countries = new List<Country>();						
			}
		}catch (Exception ex){
			countries = new List<Country>();
		}
		try{				
			stateRegions = countryrep.findStateRegionByCountry(null,"1,3");	
			if(stateRegions == null){				
				stateRegions = new List<Country>();						
			}
		}catch (Exception ex){
			stateRegions = new List<Country>();
		}
		try{				
			commonfields = contrep.getContentFields(-1, true, true, true);
			hasCommonContentFields = true;				
			if(commonfields == null){				
				commonfields = new List<ContentField>();	
				hasCommonContentFields = false;						
			}
		}catch (Exception ex){
			commonfields = new List<ContentField>();
		}

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				content = contrep.getById(Convert.ToInt32(Request["id"]));
				summary.Value = content.summary;
				description.Value = content.description;
				
				if(content.languages != null)
				{
					foreach(ContentLanguage cl in content.languages)
					{
						foreach(Language l in languages)
						{						
							if(l.id==cl.idLanguage){
								contentlanguages.Add(l);
								break;
							}
						}
					}
				}
				
				if(content.categories != null)
				{
					contentcategories = new List<IElementCategory>();
					foreach(ContentCategory cc in content.categories)
					{
						contentcategories.Add(cc);
					}
				}
				//Response.Write("content.fields check<br>");
				if(content.fields != null && content.fields.Count>0){
					//Response.Write("content.fields.Count:"+content.fields.Count+"<br>");
					hasContentFields = true;
				}
				
				//check for comments
				comments = commentrep.find(0,content.id,1,null);
				if(comments != null && comments.Count>0){
					hasComments = true;
				}
			}catch (Exception ex){
				content = new FContent();		
				content.id = -1;
				contentcategories = new List<IElementCategory>();
			}	
		}else{
			// Gestione caso inserimento field su nuovo contenuto
			contentcategories = new List<IElementCategory>();
			if(!String.IsNullOrEmpty(Request["pre_el_id"]))
			{
				pre_el_id = Request["pre_el_id"];	
				//Response.Write("pre_el_id:"+pre_el_id+"<br>");	
				try{				
					IList<ContentField> tmpContentFields = contrep.getContentFields(Convert.ToInt32(pre_el_id), null, null, false);			
					if(tmpContentFields != null){	
						//Response.Write("before starting save - content.fields.Count:"+content.fields.Count+"<br>");
						//Response.Write("before starting save - tmpContentFields.Count:"+tmpContentFields.Count+"<br>");		
						content.fields.Clear();
						foreach(ContentField cf in tmpContentFields){						
							//content.fields = tmpContentFields;
							content.fields.Add(cf);
						}
						hasContentFields = true;			
	
						//Response.Write("before starting save - content.fields.Count:"+content.fields.Count+"<br>");							
					}
				}catch (Exception ex){}			
			}
			else
			{
				pre_el_id=Convert.ToString(Guids.createGuidMax18Len(7)*(-1));
			}
		}
		if(!String.IsNullOrEmpty(pre_el_id))
		{
			this.gl1.idElem=Convert.ToInt32(pre_el_id);		
		}


		// CLEAR PHANTOMS FIELDS AND GEOLOCALIZATIONS (based on insert date)
		

		
		
		// TODO gestione preview contenuti
		previewUrls = new Dictionary<string, IList<string>>();
		string hrefGer = "";
		string newCatId = "";
		foreach(Category ct in categories)
		{
			//Response.Write("category:"+ct.ToString()+"<br>");	
			if(CategoryService.checkUserCategory(login.userLogged, ct)){
				string strHref = MenuService.resolveMenuItemUrl(ct, lang.currentLangCode, Request.Url.Scheme+"://", 1, out hrefGer, out newCatId);
				string catdesc = "-&nbsp;"+ct.description;
				string[] level = ct.hierarchy.Split('.');
				if(level != null){
					for(int l=1;l<level.Length;l++){
						catdesc = "&nbsp;&nbsp;&nbsp;"+catdesc;
					}
				}						
				IList<string> elems = new List<string>();
				elems.Add(hrefGer);
				elems.Add(newCatId);
				elems.Add(strHref);
				elems.Add(catdesc);
				//Response.Write("ct.description:"+ct.description+" -ct.hierarchy:"+ct.hierarchy+" -hrefGer:"+hrefGer+" -newCatId:"+newCatId+" -strHref:"+strHref+"<br>");
				previewUrls[ct.hierarchy]=elems;		
				//Response.Write("previewUrls["+hrefGer+"]:"+previewUrls[hrefGer]+"<br>");	
			}
		}
		
		bool carryOn;							
		//******** INSERISCO NUOVO CONTENUTO / MODIFICO ESISTENTE	
		int savesc = Convert.ToInt32(Request["savesc"]);				
		if("insert".Equals(Request["operation"]))
		{	
			carryOn = true;	
			try
			{	
				IList<Geolocalization> listOfPoints = new List<Geolocalization>();	
				string title = Request["title"];
				
				string summary = Request["summary"];					
				summary = summary.Replace("<br type=&quot;_moz&quot; />","")
				.Replace("<br type=\"_moz\" />","")
				.Replace("&lt;br type=&quot;_moz&quot; /&gt;","")
				.Replace("&lt;br /&gt;","<br />");
				if(summary=="<br />"){summary="";}	
				summary = HttpUtility.HtmlDecode(summary);
					
				string description = Request["description"];					
				description = description.Replace("<br type=&quot;_moz&quot; />","")
				.Replace("<br type=\"_moz\" />","")
				.Replace("&lt;br type=&quot;_moz&quot; /&gt;","")
				.Replace("&lt;br /&gt;","<br />");	
				if(description=="<br />"){description="";}	
				description = HttpUtility.HtmlDecode(description);				
				
				string keyword = Request["keyword"];	
				string pageTitle = Request["page_title"];	
				string metaDescription = Request["meta_description"];	
				string metaKeyword = Request["meta_keyword"];				
				string publishDate = Request["publish_date"];				
				string deleteDate = Request["delete_date"];
				int status = Convert.ToInt32(Request["status"]);
				
				content.title = title;
				content.summary = summary;
				content.description = description;
				content.keyword = keyword;
				content.metaDescription = metaDescription;	
				content.metaKeyword = metaKeyword;	
				content.pageTitle = pageTitle;		
				content.publishDate = DateTime.ParseExact(publishDate, "dd/MM/yyyy HH.mm", null);		
				content.deleteDate = DateTime.ParseExact(deleteDate, "dd/MM/yyyy HH.mm", null);
				content.status = status;
				if(content.id == -1) {
					content.userId = login.userLogged.id;
				}

				// update content languages
				content.languages.Clear();
				if(!String.IsNullOrEmpty(Request["content_languages"])){
					string[] contentLanguages = Request["content_languages"].Split('|');
					if(contentLanguages!=null){
						foreach(string x in contentLanguages){
							ContentLanguage cl = new ContentLanguage();
							cl.idParentContent = content.id;
							cl.idLanguage = Convert.ToInt32(x);
							content.languages.Add(cl);
						}
					}
				}

				// update content categories
				content.categories.Clear();
				if(!String.IsNullOrEmpty(Request["content_categories"])){
					string[] contentCategories = Request["content_categories"].Split(',');
					if(contentCategories!=null){
						foreach(string x in contentCategories){
							ContentCategory cc = new ContentCategory();
							cc.idParent = content.id;
							cc.idCategory = Convert.ToInt32(x);
							content.categories.Add(cc);
						}
					}
				}

				// update content attachments
				for(int ac=1; ac<=Convert.ToInt32(Request["attach_counter"]);ac++)
				{				
					string fattachId = Request["filemodify_id"+ac];
					if(!String.IsNullOrEmpty(fattachId)){
						int aid = Convert.ToInt32(Request["filemodify_id"+ac]);
						int label = Convert.ToInt32(Request["filemodify_label"+ac]);
						string dida = Request["filemodify_dida"+ac];
						
						foreach(ContentAttachment ca in content.attachments)
						{
							if(ca.id==aid)
							{
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentContent = content.id;
								break;
							}
						}
					}
				}

				HttpFileCollection MyFileCollection;			
				MyFileCollection = Request.Files;									
								
				for(int ac=1; ac<=Convert.ToInt32(Request["numMaxImgs"]);ac++)
				{					
					string fileName = Path.GetFileName(Request["fileupload_name"+ac]);
					int label = Convert.ToInt32(Request["fileupload_label"+ac]);
					string dida = Request["fileupload_dida"+ac];
					//Response.Write("first: fileName:"+fileName+" - label:"+label+" - dida:"+dida+"<br>");
					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{	
						HttpPostedFile tmp = MyFileCollection[k];
						string name = Path.GetFileName(tmp.FileName);
						if(!String.IsNullOrEmpty(name) && name==fileName)
						{							
							if(CommonService.isValidExtension(Path.GetExtension(name))){
								//Response.Write("found: fileName: "+name+" - contentType: "+tmp.ContentType+" - label: "+label+" - dida: "+dida+"<br>");
								ContentAttachment ca = new ContentAttachment();
								ca.fileName=name;
								ca.contentType=tmp.ContentType;
								ca.fileLabel=label;
								ca.fileDida=dida;
								ca.idParentContent=content.id;
								ca.filePath=content.id+"/";
								content.attachments.Add(ca);							
								break;		
							}else{
								throw new Exception("022");
							}							
						}
					}
				}
			
				if(!String.IsNullOrEmpty(Request["pre_el_id"]) && Convert.ToInt32(Request["pre_el_id"])!=content.id)
				{
					listOfPoints = georep.findByElement(Convert.ToInt32(Request["pre_el_id"]), 1);
				}

				try
				{
					contrep.saveCompleteContent(content, listOfPoints);

					pre_el_id=content.id.ToString();
					this.gl1.idElem=Convert.ToInt32(pre_el_id);				
					string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/contents/"+content.id); 
					if (!Directory.Exists(dirName))
					{
						Directory.CreateDirectory(dirName);
					}
	
					for(int k = 0; k<MyFileCollection.Keys.Count;k++)
					{
						HttpPostedFile tmp = MyFileCollection[k];	
						string fileName = Path.GetFileName(tmp.FileName);
						if(!String.IsNullOrEmpty(fileName))
						{
							if(CommonService.isValidExtension(Path.GetExtension(fileName)))
							{
								CommonService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/contents/"+content.id+"/"+tmp.FileName));								
							}else{
								throw new Exception("022");
							}
						}						
					}
					
					log.usr= login.userLogged.username;
					log.msg = "save content: "+content.ToString();
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);	
				}
				catch(Exception ex)
				{
					throw;	
				}

				// manage send newsletter
				if(Convert.ToInt32(Request["send_newsletter"])== 1){
					try
					{
						int newsletterId = Convert.ToInt32(Request["choose_newsletter"]);
						string mailAddressBCC = "";
						foreach(User u in users)
						{
							if(u.newsletters != null && u.newsletters.Count>0)
							{
								foreach(UserNewsletter un in u.newsletters){
									if(un.newsletterId==newsletterId)
									{
										mailAddressBCC+=","+u.email;
									}
								}
							}
						}
						if(mailAddressBCC.StartsWith(","))
						{
							mailAddressBCC = mailAddressBCC.Substring(1);
						}
						
						Newsletter newsletter = newsrep.getById(newsletterId);
						MailMsg template = mailrep.getById(newsletter.templateId);
						ListDictionary replacements = new ListDictionary();
						
						StringBuilder newsContent = new StringBuilder()
						.Append("<b>").Append(content.title).Append("</b><br/><br/>")
						.Append(content.summary).Append("<br/><br/>")
						.Append(content.description).Append("<br/><br/>");
						
						IList<ContentField> cfnewsletter = contrep.getContentFields(content.id, true, false, false);
						if(cfnewsletter != null && cfnewsletter.Count>0) {
							foreach(ContentField cf in cfnewsletter){			
								string labelForm = cf.description;								
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm))){
									 labelForm = lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm);
								}
								
								string currvalue = cf.value;
								if(!String.IsNullOrEmpty(currvalue)){
									newsContent.Append("<b class=labelForm>").Append(labelForm).Append("</b>:&nbsp;").Append(currvalue).Append("<br/>");
								}
							}
						}						
						replacements.Add("<%content%>",newsContent.ToString());
						replacements.Add("mail_bcc",mailAddressBCC);								
						MailService.prepareAndSend(template.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, secureURL);																		
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
				if(savesc==0){
					Response.Redirect(secureURL+"area_user/ads/insertcontent.aspx?cssClass="+Request["cssClass"]+"&id="+content.id);
				}else{
					Response.Redirect(secureURL+"area_user/ads/contentlist.aspx?cssClass="+Request["cssClass"]);
				}
			}else{
				Response.Redirect(url.ToString());
			}								
		}
		
		if("delete".Equals(Request["operation"]))
		{
			carryOn = true;
			try
			{
				contrep.delete(content);
				
				log.usr= login.userLogged.username;
				log.msg = "delete content: "+content.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);	
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
				
			if(carryOn){
				Response.Redirect(secureURL+"area_user/ads/contentlist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}			
		}
		
		// init menu frontend
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";				
	}
}