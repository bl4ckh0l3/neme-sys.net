using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _CategoryList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass, search_key;	
	protected IList<Category> categories;
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
		cssClass="LCE";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["categorieItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["categorieItems"];
		}else{
			if (Session["categorieItems"] != null) {
				itemsXpage = (int)Session["categorieItems"];
			}else{
				Session["categorieItems"] = 20;
				itemsXpage = (int)Session["categorieItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["categoriePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["categoriePage"];
		}else{
			if (Session["categoriePage"] != null) {
				numPage = (int)Session["categoriePage"];
			}else{
				Session["categoriePage"]= 1;
				numPage = (int)Session["categoriePage"];
			}
		}

		if (!String.IsNullOrEmpty(Request["search_key"])) {
			Session["search_key"] = Request["search_key"];
			search_key = (string)Session["search_key"];
		}else{
			if (Session["search_key"] != null) {
				search_key = (string)Session["search_key"];
			}else{
				Session["search_key"]= null;
				search_key = (string)Session["search_key"];
			}
		}

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["categoriePage"] = 1;
			numPage = (int)Session["categoriePage"];
			Session["search_key"] = null;
			search_key = (string)Session["search_key"];
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			categories = catrep.find(search_key, numPage, itemsXpage, out totalcount);
			if(categories != null){				
				bolFoundLista = true;					
			}	    	
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			categories = new List<Category>();
			bolFoundLista = false;
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