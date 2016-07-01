using System;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Web.Caching;

public partial class _ShoppingcartList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected int fromShop, toShop;
	protected string cssClass;
	
	protected IList<ShoppingCart> shoppingcarts;
	protected IDictionary<int,string> users;
	
	
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
		cssClass="LCI";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		IShoppingCartRepository shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");
		IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		
		Logger log = new Logger();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");
		users = new Dictionary<int,string>();
		shoppingcarts = new List<ShoppingCart>();
		
		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["shopItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["shopItems"];
		}else{
			if (Session["shopItems"] != null) {
				itemsXpage = (int)Session["shopItems"];
			}else{
				Session["shopItems"] = 20;
				itemsXpage = (int)Session["shopItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["shopPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["shopPage"];
		}else{
			if (Session["shopPage"] != null) {
				numPage = (int)Session["shopPage"];
			}else{
				Session["shopPage"]= 1;
				numPage = (int)Session["shopPage"];
			}
		}

		try
		{
			shoppingcarts = shoprep.find(false);
			
			if(shoppingcarts != null && shoppingcarts.Count>0){				
				bolFoundLista = true;
			}			    	
		}
		catch (Exception ex)
		{
			shoppingcarts = new List<ShoppingCart>();
			bolFoundLista = false;
		}	
		
		if(bolFoundLista){		
			foreach(ShoppingCart sc in shoppingcarts){
				User us = userrep.findById(sc.idUser, false, false, false, false, false, false);
				if(us != null){
					users.Add(sc.id, us.username);
				}else{
					users.Add(sc.id, lang.getTranslated("backend.commons.sessione")+": "+sc.idUser);
				}
			}				
		}
	
		int iIndex = shoppingcarts.Count;
		fromShop = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toShop = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(shoppingcarts.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
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