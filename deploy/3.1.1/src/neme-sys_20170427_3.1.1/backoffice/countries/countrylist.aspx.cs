using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _CountryList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass, search_key;	
	protected IList<Country> countries;
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
		cssClass="LCT";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ICountryRepository countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["countryItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["countryItems"];
		}else{
			if (Session["countryItems"] != null) {
				itemsXpage = (int)Session["countryItems"];
			}else{
				Session["countryItems"] = 20;
				itemsXpage = (int)Session["countryItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["countryPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["countryPage"];
		}else{
			if (Session["countryPage"] != null) {
				numPage = (int)Session["countryPage"];
			}else{
				Session["countryPage"]= 1;
				numPage = (int)Session["countryPage"];
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
			Session["countryPage"] = 1;
			numPage = (int)Session["countryPage"];
			Session["search_key"] = null;
			search_key = (string)Session["search_key"];
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{			
			countries = countryrep.find(null, null, search_key, numPage, itemsXpage, out totalcount);
			if(countries != null){				
				bolFoundLista = true;						
			}	    	
		}
		catch (Exception ex)
		{
			countries = new List<Country>();
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