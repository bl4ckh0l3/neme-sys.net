using System;
using System.Data;
using System.Web.UI;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _PaymentList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected int fromPayment, toPayment;
	protected string cssClass;	
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
		cssClass="LPT";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
	
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["paymentItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["paymentItems"];
		}else{
			if (Session["paymentItems"] != null) {
				itemsXpage = (int)Session["paymentItems"];
			}else{
				Session["paymentItems"] = 20;
				itemsXpage = (int)Session["paymentItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["paymentPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["paymentPage"];
		}else{
			if (Session["paymentPage"] != null) {
				numPage = (int)Session["paymentPage"];
			}else{
				Session["paymentPage"]= 1;
				numPage = (int)Session["paymentPage"];
			}
		}

		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		try
		{
			payments = payrep.find(-1, -1, null, null, true, false);
			if(payments != null){				
				bolFoundLista = true;			
			}	    	
		}
		catch (Exception ex)
		{
			payments = new List<Payment>();
			bolFoundLista = false;
		}
	
		int iIndex = payments.Count;
		fromPayment = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toPayment = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(payments.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
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