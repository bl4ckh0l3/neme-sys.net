using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Web.Caching;

public partial class _FeOrderList : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected int fromOrder, toOrder;
	protected string cssClass;
	protected ConfigurationService configService;
	
	protected IList<FOrder> orders;	
	protected IDictionary<int,string> paymentTypes;
	protected IDictionary<int,string> statusOrder;
	
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
		login.acceptedRoles = "3";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		configService = new ConfigurationService();
		orders = new List<FOrder>();
		paymentTypes = new Dictionary<int,string>();
		fromOrder = 0;
		toOrder = 0;
		statusOrder = OrderService.getOrderStatus();
		
		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["listUOrder"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["listUOrder"];
		}else{
			if (Session["listUOrder"] != null) {
				itemsXpage = (int)Session["listUOrder"];
			}else{
				Session["listUOrder"] = 20;
				itemsXpage = (int)Session["listUOrder"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["uorderPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["uorderPage"];
		}else{
			if (Session["uorderPage"] != null) {
				numPage = (int)Session["uorderPage"];
			}else{
				Session["uorderPage"]= 1;
				numPage = (int)Session["uorderPage"];
			}
		}
		
		try
		{
			orders = orderep.getByIdUser(login.userLogged.id, false);
			
			if(orders != null && orders.Count>0){				
				bolFoundLista = true;				
			}			    	
		}
		catch (Exception ex)
		{
			//Response.Write(ex.Message+"<br><br><br>"+ex.StackTrace+"<br>");
			orders = new List<FOrder>();
			bolFoundLista = false;
		}
		
		if(bolFoundLista){
			foreach(FOrder o in orders){
				int paymentId = o.paymentId;
				if(paymentId != null && paymentId>0){
					Payment payment = payrep.getByIdCached(paymentId, true);
					if(payment != null){
						string paymentType = payment.description;
						if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+payment.description))){
							paymentType = lang.getTranslated("backend.payment.description.label."+payment.description);
						}
						paymentTypes.Add(o.id, paymentType);
					}	
				}
			}
			
			
			int iIndex = orders.Count;
			fromOrder = ((this.numPage * itemsXpage) - itemsXpage);
			int diff = (iIndex - ((this.numPage * itemsXpage)-1));
			if(diff < 1) {
				diff = 1;
			}
			
			toOrder = iIndex - diff;
				
			if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
			if(_totalPages < 1) {
				_totalPages = 1;
			}else if(orders.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
				_totalPages = _totalPages +1;	
			}
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

		// init menu frontend
		this.mf1.modelPageNum = 1;
		this.mf1.categoryid = "";	
		this.mf1.hierarchy = "";	
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";			
	}
}