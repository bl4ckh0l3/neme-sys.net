using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _OrderList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundUser = false;
	protected bool bolFoundFees = false;
	protected int itemsXpage, numPage;
	protected string cssClass;
	protected string search_guid, search_datefrom, search_dateto, search_status, search_paydone;	
	protected int search_user, search_orderby, search_paytype;
	protected IList<FOrder> orders;
	protected IOrderRepository orderrep;
	protected IList<User> users;
	protected IList<Payment> payments;
	
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
		cssClass="LO";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		
		orderrep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");

		users = new List<User>();
		payments = new List<Payment>();
		
		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["orderItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["orderItems"];
		}else{
			if (Session["orderItems"] != null) {
				itemsXpage = (int)Session["orderItems"];
			}else{
				Session["orderItems"] = 20;
				itemsXpage = (int)Session["orderItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["orderPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["orderPage"];
		}else{
			if (Session["orderPage"] != null) {
				numPage = (int)Session["orderPage"];
			}else{
				Session["orderPage"]= 1;
				numPage = (int)Session["orderPage"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_by"])) {
			Session["order_by"] = Convert.ToInt32(Request["order_by"]);
			search_orderby = (int)Session["order_by"];
		}else{
			if (Session["order_by"] != null) {
				search_orderby = (int)Session["order_by"];
			}else{
				Session["order_by"]= -1;
				search_orderby = (int)Session["order_by"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_guid"])) {
			Session["order_guid"] = Request["order_guid"];
			search_guid = (string)Session["order_guid"];
		}else{
			if (Session["order_guid"] != null) {
				search_guid = (string)Session["order_guid"];
			}else{
				Session["order_guid"] = "";
				search_guid = (string)Session["order_guid"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_user"])) {
			Session["order_user"] = Convert.ToInt32(Request["order_user"]);
			search_user = (int)Session["order_user"];
		}else{
			if (Session["order_user"] != null) {
				search_user = (int)Session["order_user"];
			}else{
				Session["order_user"]= -1;
				search_user = (int)Session["order_user"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_payment"])) {
			Session["order_payment"] = Convert.ToInt32(Request["order_payment"]);
			search_paytype = (int)Session["order_payment"];
		}else{
			if (Session["order_payment"] != null) {
				search_paytype = (int)Session["order_payment"];
			}else{
				Session["order_payment"]= -1;
				search_paytype = (int)Session["order_payment"];
			}
		}

		if (!String.IsNullOrEmpty(Request["payment_done"])) {
			Session["payment_done"] = Request["payment_done"];
			search_paydone = (string)Session["payment_done"];
		}else{
			if (Session["payment_done"] != null) {
				search_paydone = (string)Session["payment_done"];
			}else{
				Session["payment_done"] = "";
				search_paydone = (string)Session["payment_done"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_date_from"])) {
			Session["order_date_from"] = Request["order_date_from"];
			search_datefrom = (string)Session["order_date_from"];
		}else{
			if (Session["order_date_from"] != null) {
				search_datefrom = (string)Session["order_date_from"];
			}else{
				Session["order_date_from"] = "";
				search_datefrom = (string)Session["order_date_from"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_date_to"])) {
			Session["order_date_to"] = Request["order_date_to"];
			search_dateto = (string)Session["order_date_to"];
		}else{
			if (Session["order_date_to"] != null) {
				search_dateto = (string)Session["order_date_to"];
			}else{
				Session["order_date_to"] = "";
				search_dateto = (string)Session["order_date_to"];
			}
		}

		if (!String.IsNullOrEmpty(Request["order_status"])) {
			Session["order_status"] = Request["order_status"];
			search_status = (string)Session["order_status"];
		}else{
			if (Session["order_status"] != null) {
				search_status = (string)Session["order_status"];
			}else{
				Session["order_status"] = "";
				search_status = (string)Session["order_status"];
			}
		}

		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["orderPage"] = 1;
			numPage = (int)Session["orderPage"];
			Session["order_by"] = -1;
			search_orderby = (int)Session["order_by"];
			Session["order_guid"] = null;
			search_guid = (string)Session["order_guid"];
			Session["order_user"] = -1;
			search_user = (int)Session["order_user"];
			Session["order_payment"] = -1;
			search_paytype = (int)Session["order_payment"];
			Session["order_date_from"] = null;
			search_datefrom = (string)Session["order_date_from"];
			Session["order_date_to"] = null;
			search_dateto = (string)Session["order_date_to"];
			Session["order_status"] = null;
			search_status = (string)Session["order_status"];
			Session["payment_done"] = null;
			search_paydone = (string)Session["payment_done"];
		}
		
		try
		{
			users = usrrep.find(null, "3", "true", null, "false", 1, false, false, false, false, false, false);
			if(users != null && users.Count>0){				
				bolFoundUser = true;
			}	    	
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			bolFoundUser = false;
			users = new List<User>();
		}

		try{
			payments = payrep.find(-1, -1, null, null, true, false);
			if(payments != null && payments.Count>0){				
				bolFoundFees = true;			
			}	    	
		}catch (Exception ex){
			//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			payments = new List<Payment>();
			bolFoundFees = false;
		}		
		
		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		long totalcount=0L;
		try
		{
			orders = orderrep.find(search_guid, search_user, search_datefrom, search_dateto, search_status, search_paytype, search_paydone, search_orderby, true);
			if(orders != null && orders.Count>0){				
				bolFoundLista = true;
				totalcount = orders.Count;
			}	    	
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			orders = new List<FOrder>();
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