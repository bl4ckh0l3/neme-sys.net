using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _CurrencyList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass;	
	protected IList<Currency> currencies;
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
		cssClass="LCY";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		ICurrencyRepository currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["currencyItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["currencyItems"];
		}else{
			if (Session["currencyItems"] != null) {
				itemsXpage = (int)Session["currencyItems"];
			}else{
				Session["currencyItems"] = 20;
				itemsXpage = (int)Session["currencyItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["currencyPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["currencyPage"];
		}else{
			if (Session["currencyPage"] != null) {
				numPage = (int)Session["currencyPage"];
			}else{
				Session["currencyPage"]= 1;
				numPage = (int)Session["currencyPage"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			currencies = currrep.find(null, null, numPage, itemsXpage, out totalcount);
			if(currencies != null){				
				bolFoundLista = true;			
			}	    	
		}
		catch (Exception ex)
		{
			currencies = new List<Currency>();
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