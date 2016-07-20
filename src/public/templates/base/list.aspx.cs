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

public partial class _List : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected bool bolFoundLista = false;
	protected bool bolHasDetailLink = false;
	protected IList<FContent> contents;
	protected int numPage, itemsXpage, orderBy, modelPageNum;
	protected int fromContent, toContent;
	protected IList<int> matchCategories = null;
	protected string status;
	protected string hierarchy;
	protected string categoryid;
	public string detailURL = "#";
	
	private int _totalCPages;	
	public int totalCPages {
		get { return _totalCPages; }
	}
	
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
		confservice = new ConfigurationService();

		//se il sito � offline rimando a pagina default
		if ("1".Equals(confservice.get("go_offline").value)) 
		{
			UriBuilder defRedirect = new UriBuilder(Request.Url);
			defRedirect.Port = -1;	
			defRedirect.Path = "";			
			defRedirect.Query = "";
			Response.Redirect(defRedirect.ToString());
		}
				
		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
		numPage = 1;
		status = "1";
		itemsXpage = 20;
		orderBy = 1;
		modelPageNum = 1;
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}
		if (!String.IsNullOrEmpty(Request["content_preview"])) {
			status = null;
		}
		
		try
		{
			// tento di risolvere la categoria e il template in base ai parametri della request
			if(!String.IsNullOrEmpty(Request["categoryid"]))
			{
				category = catrep.getByIdCached(Convert.ToInt32(Request["categoryid"]), true);
				hierarchy = category.hierarchy;				
			}
			if(CategoryService.isCategoryNull(category))
			{	
				if(!String.IsNullOrEmpty(Request["hierarchy"]))
				{
					hierarchy = Request["hierarchy"];
					category = catrep.getByHierarchyCached(hierarchy, true);	
				}			
			}

			//Response.Write("category:"+category.ToString()+"<br>");			
			if(!CategoryService.isCategoryNull(category)){				
				setMetaCategory(category);
				if(category.idTemplate>0){
					template = templrep.getByIdCached(templateId,true);
				}
			}	

			if(template == null)
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
				if(CategoryService.isCategoryNull(category) && template != null)
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
			
			if(template != null){
				itemsXpage = template.elemXpage;
				orderBy = template.orderBy;
				bool langHasSubDomainActive = false;
				string langUrlSubdomain = "";
				Language language = langrep.getByLabel(lang.currentLangCode, true);
				if(!LanguageService.isLanguageNull(language))
				{	
					langHasSubDomainActive = language.subdomainActive;
					langUrlSubdomain = language.urlSubdomain;
				}								
				
				detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum+1, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
				//Response.Write("2 detailURL:"+detailURL+"<br>");	
				if(detailURL==null){
					detailURL = "#";
				}
				bolHasDetailLink = true;				
			}
			
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
		}catch (Exception ex){
			Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolHasDetailLink = false;
		}
	
		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
		}
	
		if(!String.IsNullOrEmpty(Request["order_by"]))
		{
			orderBy = Convert.ToInt32(Request["order_by"]);	
		}
						
		try
		{			
			contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);
			
			//Response.Write("contents != null:"+ contents!=null +"<br>");
			
			if(contents != null && contents.Count>0){				
				bolFoundLista = true;	
				
				foreach(FContent c in contents){
					if (!String.IsNullOrEmpty(lang.getTranslated(c.metaDescription))) {
						_metaDescription+= " " + lang.getTranslated(c.metaDescription);
					}else{
						if (!String.IsNullOrEmpty(c.metaDescription)) {
							_metaDescription+= " " + c.metaDescription;
						}
					}
					
					if (!String.IsNullOrEmpty(lang.getTranslated(c.metaKeyword))) {
						_metaKeyword+= " " + lang.getTranslated(c.metaKeyword);
					}else{
						if (!String.IsNullOrEmpty(c.metaKeyword)) {
							_metaKeyword+= " " + c.metaKeyword;
						}
					}      
				}					
			}	
		}
		catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			contents = new List<FContent>();
		}

		int iIndex = contents.Count;
		fromContent = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toContent = iIndex - diff;
		
		//Response.Write("<br>iIndex:"+ iIndex +"<br>");
		//Response.Write("diff:"+ diff +"<br>");
		//Response.Write("this.numPage:"+ this.numPage  +"<br>");
		//Response.Write("itemsXpage:"+ itemsXpage +"<br>");
			
		if(itemsXpage>0){_totalCPages = iIndex/itemsXpage;}
		if(_totalCPages < 1) {
			_totalCPages = 1;
		}else if(iIndex % itemsXpage != 0 &&  (_totalCPages * itemsXpage) < iIndex) {
			_totalCPages = _totalCPages +1;	
		}
			
		this.pg1.totalPages = this._totalCPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage;	
		
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
