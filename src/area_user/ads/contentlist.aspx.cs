using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Web.Caching;

public partial class _FeContentList : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpageNews, numPageNews;
	protected string cssClass;
	protected ConfigurationService configService;
	protected string secureURL, currentURL;
	
	protected int order_by;
	protected string titlef;
	protected string keywordf;
	protected string statusf;
	protected int languagef;
	protected int categoryf;
	protected int userf;
	
	protected IList<FContent> contents;	
	protected IList<Language> languages;	
	protected IList<Category> categories;
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}
	
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
		
		UriBuilder baseBuilder = Utils.getBaseUrl(Request.Url.ToString(),1);
		secureURL = baseBuilder.ToString();
		baseBuilder.Path=Request.Url.AbsolutePath;
		currentURL=baseBuilder.ToString();
		
		login.acceptedRoles = "3";
		if(!login.checkedUser()){
			Response.Redirect(secureURL+"login.aspx?error_code=002");
		}
		IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		configService = new ConfigurationService();
		
		IList<int> matchCategories = null;
		IList<int> matchLanguages = null;	
		order_by = -1;
		titlef = "";
		keywordf = "";
		statusf = "";
		languagef = 0;
		categoryf = 0;
		userf = -1;
		
		if (!String.IsNullOrEmpty(Request["itemsNews"])) {
			Session["listItems"] = Convert.ToInt32(Request["itemsNews"]);
			itemsXpageNews = (int)Session["listItems"];
		}else{
			if (Session["listItems"] != null) {
				itemsXpageNews = (int)Session["listItems"];
			}else{
				Session["listItems"] = 20;
				itemsXpageNews = (int)Session["listItems"];
			}
		}

		//************* START: CONTENT FILTERS SETUP
		if("1" == Request["resetMenu"]) 
		{
			Session["contenutiPage"] = 1;
			numPageNews = (int)Session["contenutiPage"];
			Session["order_by"] = -1;
			order_by = (int)Session["order_by"];
			Session["titlef"] = "";
			titlef = (string)Session["titlef"];
			Session["keywordf"] = "";
			keywordf = (string)Session["keywordf"];
			Session["statusf"] = "";
			statusf = (string)Session["statusf"];
			Session["categoryf"] = null;
			categoryf = 0;
			Session["languagef"] = null;
			languagef = 0;
		}
		else
		{		
			if (!String.IsNullOrEmpty(Request["page"])) {
				Session["contenutiPage"] = Convert.ToInt32(Request["page"]);
				numPageNews = (int)Session["contenutiPage"];
			}else{
				if (Session["contenutiPage"] != null) {
					numPageNews = (int)Session["contenutiPage"];
				}else{
					Session["contenutiPage"]= 1;
					numPageNews = (int)Session["contenutiPage"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["order_by"]) && Request["order_by"]!="-1") {
				Session["order_by"] = Convert.ToInt32(Request["order_by"]);
				order_by = (int)Session["order_by"];
			}else{
				if (Session["order_by"] != null) {
					order_by = (int)Session["order_by"];
				}else{
					Session["order_by"]= -1;
					order_by = (int)Session["order_by"];
				}
			}

			if (!String.IsNullOrEmpty(Request["titlef"])) {
				Session["titlef"] = Request["titlef"];
				titlef = (string)Session["titlef"];
			}else{
				if (Session["titlef"] != null) {
					titlef = (string)Session["titlef"];
				}else{
					Session["titlef"] = "";
					titlef = (string)Session["titlef"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["keywordf"])) {
				Session["keywordf"] = Request["keywordf"];
				keywordf = (string)Session["keywordf"];
			}else{
				if (Session["keywordf"] != null) {
					keywordf = (string)Session["keywordf"];
				}else{
					Session["keywordf"] = "";
					keywordf = (string)Session["keywordf"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["statusf"])) {
				Session["statusf"] = Request["statusf"];
				statusf = (string)Session["statusf"];
			}else{
				if (Session["statusf"] != null) {
					statusf = (string)Session["statusf"];
				}else{
					Session["statusf"] = "";
					statusf = (string)Session["statusf"];
				}
			}
			
			if (!String.IsNullOrEmpty(Request["categoryf"]) && Request["categoryf"]!="0") {
				Session["categoryf"] = Convert.ToInt32(Request["categoryf"]);
				categoryf = (int)Session["categoryf"];
				//Response.Write("categoryf:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
				matchCategories = new List<int>();
				matchCategories.Add(categoryf);
			}else{
				if (Session["categoryf"] != null) {
					categoryf = (int)Session["categoryf"];
					//Response.Write("categoryf by session:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
					matchCategories = new List<int>();
					matchCategories.Add(categoryf);
				}else{
					Session["categoryf"] = null;
					categoryf = 0;
					//Response.Write("categoryf empty:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
				}
			}
			
			if (!String.IsNullOrEmpty(Request["languagef"]) && Request["languagef"]!="0") {
				Session["languagef"] = Convert.ToInt32(Request["languagef"]);
				languagef = (int)Session["languagef"];
				//Response.Write("languagef:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
				matchLanguages = new List<int>();
				matchLanguages.Add(languagef);
			}else{
				if (Session["languagef"] != null) {
					languagef = (int)Session["languagef"];
					//Response.Write("languagef by session:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
					matchLanguages = new List<int>();
					matchLanguages.Add(languagef);
				}else{
					Session["languagef"] = null;
					languagef = 0;
				}
			}
		}
		//************* END: CONTENT FILTERS SETUP

		//Response.Write("titlef:"+titlef+" -Session[titlef]:"+Session["titlef"]+"<br>");
		//Response.Write("keywordf:"+keywordf+" -Session[keywordf]:"+Session["keywordf"]+"<br>");
		//Response.Write("statusf:"+statusf+" -Session[statusf]:"+Session["statusf"]+"<br>");
		//Response.Write("categoryf:"+categoryf+" -Session[categoryf]:"+Session["categoryf"]+"<br>");
		//Response.Write("languagef:"+languagef+" -Session[languagef]:"+Session["languagef"]+"<br>");
		//Response.Write("resetMenu:"+Request["resetMenu"]+" -Request[resetMenu] == 1:"+(Request["resetMenu"] == "1")+"<br>");

		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{			
			categories = catrep.getCategoryList();	
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			//check su userid: se administrator mostro tutti i contenuti
			if(!login.userLogged.role.isAdmin()){userf=login.userLogged.id;}
			contents = contentrep.find(titlef,keywordf,statusf,userf,null,null,order_by,matchCategories,matchLanguages,false,true,true,false,numPageNews,itemsXpageNews,out totalcount);
			
			if(contents != null && contents.Count>0){				
				bolFoundLista = true;		
				
				//if(contents[0].attachments!=null){Response.Write("contents attachments != null "+contents[0].attachments.GetType());}	
			}			    	
		}
		catch (Exception ex)
		{
			contents = new List<FContent>();
			Response.Write(ex.Message);
			bolFoundLista = false;
		}
	
		if(itemsXpageNews>0){_totalPages = (int)totalcount/itemsXpageNews;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(totalcount % itemsXpageNews != 0 &&  (_totalPages * itemsXpageNews) < totalcount) {
			_totalPages = _totalPages +1;	
		}
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPageNews;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "itemsNews="+itemsXpageNews+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPageNews;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "itemsNews="+itemsXpageNews+"&cssClass="+cssClass+"&order_by="+order_by+"&titlef="+titlef+"&keywordf="+keywordf+"&categoryf="+categoryf+"&statusf="+statusf+"&languagef="+languagef;	

		// init menu frontend
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";			
	}
}