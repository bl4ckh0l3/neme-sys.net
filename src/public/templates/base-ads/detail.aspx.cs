using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _Detail : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected FContent content;
	protected Ads ads;
	protected IList<Geolocalization> points;
	protected int numPage, modelPageNum;
	protected IList<int> matchCategories = null;
	protected IDictionary<string, IList<ContentAttachment>> attachmentsDictionary = null;
	protected IList<ContentAttachmentLabel> attachmentsLabel = null;
	protected IList<ContentField> contentFields = null;
	protected string hierarchy;
	protected string categoryid;
	protected string detailURL = "#";
	protected string currentUrl;
	protected IDictionary<int, IList<object>> adsData; 
	
	private string _pageTitle;	
	public string pageTitle {
		get { return _pageTitle; }
	}
	
	private string _metaDescription;	
	public string metaDescription {
		get { return _metaDescription; }
	}
	
	private string _metaKeyword;	
	public string metaKeyword {
		get { return _metaKeyword; }
	}
			
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}
		
	protected void Page_Load(object sender, EventArgs e) 
	{	
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;
		login.acceptedRoles = "";
		bool logged = login.checkedUser();
		IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		IGeolocalizationRepository georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		IAdsRepository adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		IMultiLanguageRepository multilangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");	
		confservice = new ConfigurationService();
		currentUrl = Request.Url.ToString();

		//se il sito � offline rimando a pagina default
		if ("1".Equals(confservice.get("go_offline").value)) 
		{
			UriBuilder defRedirect = new UriBuilder(Request.Url);
			defRedirect.Port = -1;	
			defRedirect.Path = "";			
			defRedirect.Query = "";
			Response.Redirect(defRedirect.ToString());
		}
		
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");
		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
		numPage = 1;
		string status = "1";
		int orderBy = 1;
		modelPageNum = 1;
		hierarchy = (string)HttpContext.Current.Items["hierarchy"];
		categoryid = (string)HttpContext.Current.Items["categoryid"];
		attachmentsDictionary = new Dictionary<string, IList<ContentAttachment>>();
		attachmentsLabel = contentrep.getContentAttachmentLabelCached(true);
		contentFields = new List<ContentField>();
		points = new List<Geolocalization>();
		ads = null;
		adsData = new Dictionary<int, IList<object>>();
		
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}
		
		try
		{
			if(!String.IsNullOrEmpty(Request["hierarchy"]))
			{
				hierarchy = Request["hierarchy"];
			}
			if(!String.IsNullOrEmpty(Request["categoryid"]))
			{
				categoryid = Request["categoryid"];
			}
					
			// tento di risolvere la categoria e il template in base ai parametri della request
			if(!String.IsNullOrEmpty(categoryid))
			{
				category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
				hierarchy = category.hierarchy;				
			}
			if(CategoryService.isCategoryNull(category))
			{	
				if(!String.IsNullOrEmpty(hierarchy))
				{
					category = catrep.getByHierarchyCached(hierarchy, true);	
				}			
			}	
			
			if(!CategoryService.isCategoryNull(category)){				
				setMetaCategory(category);
				if(category.idTemplate>0){
					template = templrep.getByIdCached(templateId,true);
				}
			}
										
			if(template == null)
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
				if(CategoryService.isCategoryNull(category))
				{
					category = catrep.getByTemplateCached(template.id, true);
					if(!CategoryService.isCategoryNull(category))
					{
						if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
							HttpContext.Current.Items["lang-code"] = newLangCode;
							lang.set();
						}	
						hierarchy = category.hierarchy;					
						setMetaCategory(category); 					
					}
				}
			}
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
							
			// tento il recupero del contenuto tramite id
			if(!String.IsNullOrEmpty(Request["contentid"]))
			{
				content = contentrep.getByIdCached(Convert.ToInt32(Request["contentid"]), true);	
			}			

			// se non trovo nulla tento il recupero dalla categoria
			if(ContentService.isContentNull(content))
			{	
				if (!String.IsNullOrEmpty(lang.currentLangCode)) {
					matchLanguages = new List<int>();
					matchLanguages.Add(langrep.getByLabel(lang.currentLangCode).id);
				}
		
				if (!String.IsNullOrEmpty(Request["content_preview"])) {
					status = null;
				}
					
				if(!String.IsNullOrEmpty(Request["order_by"]))
				{
					orderBy = Convert.ToInt32(Request["order_by"]);	
				}
								
				try
				{			
					IList<FContent> contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);
					
					//Response.Write("contents != null:"+ contents!=null +"<br>");
					
					if(contents != null){								
						foreach(FContent c in contents){
							content = c;
							break;      
						}					
					}	
				}
				catch (Exception ex){
					//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					throw;
				}
				
			}
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			content = null;
		}
		
		//gestisco attachment
		if(content != null)
		{
			if (!String.IsNullOrEmpty(lang.getTranslated(content.pageTitle))) {
				_pageTitle+= " " + lang.getTranslated(content.pageTitle);
			}else{
				if (!String.IsNullOrEmpty(content.pageTitle)) {
					_pageTitle+= " " + content.pageTitle;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(content.metaDescription))) {
				_metaDescription+= " " + lang.getTranslated(content.metaDescription);
			}else{
				if (!String.IsNullOrEmpty(content.metaDescription)) {
					_metaDescription+= " " + content.metaDescription;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(content.metaKeyword))) {
				_metaKeyword+= " " + lang.getTranslated(content.metaKeyword);
			}else{
				if (!String.IsNullOrEmpty(content.metaKeyword)) {
					_metaKeyword+= " " + content.metaKeyword;
				}
			}
					
			bool langHasSubDomainActive = false;
			string langUrlSubdomain = "";
			Language language = langrep.getByLabel(lang.currentLangCode, true);
			if(!LanguageService.isLanguageNull(language))
			{	
				langHasSubDomainActive = language.subdomainActive;
				langUrlSubdomain = language.urlSubdomain;
			}
												
			cwwc1.elemId = content.id.ToString();
			string cwwc1Link = MenuService.resolvePageHrefUrl(Request.Url.Scheme+"://", modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
			if(cwwc1Link==null){
				cwwc1Link = "#";
			}
			cwwc1.from = cwwc1Link;
			cwwc1.hierarchy = hierarchy;
			cwwc1.categoryId = categoryid;	
			// set comment type
			cwwc1.elemType="1";
			
			ctitle.Text = content.title;
			csummary.Text = content.summary;
			cdescription.Text = content.description;
			
			if(content.attachments != null)
			{
				foreach(ContentAttachment ca in content.attachments)
				{				
					int label = ca.fileLabel;
					string alabel = "";
					foreach(ContentAttachmentLabel cal in attachmentsLabel)
					{
						if(cal.id==label)
						{
							alabel = cal.description;
							break;
						}
					}
					
					if(attachmentsDictionary.ContainsKey(alabel))
					{
						IList<ContentAttachment> items = null;
						if(attachmentsDictionary.TryGetValue(alabel, out items)){
							items.Add(ca);
							attachmentsDictionary[alabel] = items;
						}
					}
					else
					{
						IList<ContentAttachment> items = new List<ContentAttachment>();
						items.Add(ca);
						attachmentsDictionary[alabel] = items;
					}
				}
			}
			
			// gestisco i field per contenuto
			if(content.fields != null && content.fields.Count>0){
				contentFields = content.fields;
			}

			//*************** verifico se esiste la geolocalizzazione per questo elemento
			IList<Geolocalization> tmpPoints = georep.findByElement(content.id, 1);
			if(tmpPoints != null && tmpPoints.Count>0){
				points = tmpPoints;
			}
			
			try
			{			
				ads = adsrep.getByIdElement(content.id, -1);
				
				if(ads != null){			
					IList<object> adsElements = new List<object>();
					
					User u = usrrep.getById(ads.userId);
					bool hasUrgent = false;
					bool hasHighlight = false;
						
					if(ads.promotions != null && ads.promotions.Count>0){
						foreach(AdsPromotion ap in ads.promotions){
							if(ap.active){
								string expire = ap.elementCode.Substring(ap.elementCode.LastIndexOf('#')+1);
								if(ap.elementCode.StartsWith("ad-1")){
									if (DateTime.Compare(ap.insertDate.AddDays(Convert.ToInt32(expire)), DateTime.Now)>=0) {
										hasHighlight = true;
									}
								}else if(ap.elementCode.StartsWith("ad-2")){
									if (DateTime.Compare(ap.insertDate.AddDays(Convert.ToInt32(expire)), DateTime.Now)>=0) {
										hasUrgent = true;
									}
								}
							}
						}
					}					
					
					adsElements.Add(ads);
					adsElements.Add(u);
					adsElements.Add(hasUrgent);
					adsElements.Add(hasHighlight);
					
					adsData.Add(ads.elementId, adsElements);					
				}	
			}
			catch (Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				ads = null;
			}	

			if (!String.IsNullOrEmpty(Request["error"]) && !String.IsNullOrEmpty(multilangrep.convertErrorCode(Request["error"])))
			{
				mailRespMsg.Text = "<p><span class=error>"+lang.getTranslated(multilangrep.convertErrorCode(Request["error"]))+"</span></p>";
			}	
			
			// gestisco invio mail da form contatti
			if("sendmail"==Request["operation"])
			{
				bool carryOn = true;
				UriBuilder ubuilder = new UriBuilder(Request.Url);
				ubuilder.Scheme = "http";
				ubuilder.Port = -1;
				ubuilder.Path="";
				ubuilder.Query = "";
				try
				{
					// resolve captcha code
					UriBuilder errCaptcha = new UriBuilder(Request.Url);
					errCaptcha.Port = -1;
					errCaptcha.Query = "captcha_err=1";	
					if(confservice.get("use_recaptcha").value == "1"){
						string captchacode = Request["captchacode"];
						if(captchacode.ToLower() != Session["CaptchaImageText"].ToString().ToLower())
						{	
							url = new StringBuilder(errCaptcha.ToString());
							carryOn = false;					
						}
					}else if(confservice.get("use_recaptcha").value == "2"){
						if(CaptchaService.verifyRecaptcha(Request.ServerVariables["REMOTE_ADDR"], Request["recaptcha_challenge_field"], Request["recaptcha_response_field"]))
						{
							carryOn = true;
						}else{
							url = new StringBuilder(errCaptcha.ToString());
							carryOn = false;	
						}
					}					
					
					if(carryOn){
						ListDictionary replacements = new ListDictionary();
						replacements.Add("mail_receiver",usrrep.getById(Convert.ToInt32(Request["adsuser"])).email);	
						
						StringBuilder adsContent = new StringBuilder();					

						string reqadstitle = Request["adstitle"];	
						string reqadsemail = Request["email"];		
						string reqadsphone = Request["phone"];			
						string reqadsmessage = Request["message"];	
						
						adsContent.Append("<b>").Append(lang.getTranslated("frontend.template_ads.label.content_title")).Append("</b>:&nbsp;").Append(reqadstitle).Append("<br/>");
						if(!String.IsNullOrEmpty(reqadsphone)){adsContent.Append("<b>").Append(lang.getTranslated("frontend.template_ads.label.phone_requestor")).Append("</b>:&nbsp;").Append(reqadsphone).Append("<br/>");}
						adsContent.Append("<b>").Append(lang.getTranslated("frontend.template_ads.label.email")).Append("</b>:&nbsp;").Append(reqadsemail).Append("<br/><br/>");
						adsContent.Append("<b>").Append(lang.getTranslated("frontend.template_ads.label.testo_mail")).Append("</b>:&nbsp;").Append(reqadsmessage).Append("<br/>");
						
						replacements.Add("<%content%>",adsContent.ToString());						
						MailService.prepareAndSend("ads-contact-mail", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, ubuilder.ToString());				
					}
				}catch(Exception ex){
					//Response.Write("Generic error: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					carryOn = false;
				}
				if(carryOn){
					string confirmURL = MenuService.resolvePageHrefUrl(Request.Url.Scheme+"://", 0, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
					if(confirmURL==null){
						confirmURL = "#";
					}
					Response.Redirect(confirmURL);
				}else{
					Response.Redirect(Request.Url.ToString());
				}
			}			
		}
			
		
		// init menu frontend
		this.mf1.modelPageNum = this.modelPageNum;
		this.mf1.categoryid = categoryid;	
		this.mf1.hierarchy = hierarchy;	
		this.mf2.modelPageNum = this.modelPageNum;
		this.mf2.categoryid = categoryid;	
		this.mf2.hierarchy = hierarchy;	
		this.mf3.modelPageNum = this.modelPageNum;
		this.mf3.categoryid = categoryid;	
		this.mf3.hierarchy = hierarchy;
		//this.mf4.modelPageNum = this.modelPageNum;
		//this.mf4.categoryid = categoryid;	
		//this.mf4.hierarchy = hierarchy;
		this.mf5.modelPageNum = this.modelPageNum;
		this.mf5.categoryid = categoryid;	
		this.mf5.hierarchy = hierarchy;
	}
	
	private void setMetaCategory(Category category)
	{
		_pageTitle = lang.getTranslated("frontend.page.title");
		_metaDescription = "";
		_metaKeyword = "";
		matchCategories = new List<int>();
		matchCategories.Add(category.id);	
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.pageTitle))) {
			_pageTitle= " " + lang.getTranslated(category.pageTitle);
		}else{
			if (!String.IsNullOrEmpty(category.pageTitle)) {
				_pageTitle= " " + category.pageTitle;
			}
		} 
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaDescription))) {
			_metaDescription+= " " + lang.getTranslated(category.metaDescription);
		}else{
			if (!String.IsNullOrEmpty(category.metaDescription)) {
				_metaDescription+= " " + category.metaDescription;
			}
		}
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaKeyword))) {
			_metaKeyword+= " " + lang.getTranslated(category.metaKeyword);
		}else{
			if (!String.IsNullOrEmpty(category.metaKeyword)) {
				_metaKeyword+= " " + category.metaKeyword;
			}
		} 			
	}
}
