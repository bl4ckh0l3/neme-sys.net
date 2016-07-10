using System;
using System.Data;
using System.Web.UI;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;

public partial class _OrderList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundUser = false;
	protected bool bolFoundFees = false;
	protected bool showChart = false;
	protected int itemsXpage, numPage;
	protected int fromOrder, toOrder;
	protected string cssClass;
	protected string search_guid, search_datefrom, search_dateto, search_status, search_paydone, chart_filter;	
	protected int search_user, search_orderby, search_paytype;
	protected IList<FOrder> orders;
	protected IOrderRepository orderrep;
	protected IUserRepository usrrep;
	protected IPaymentRepository payrep;
	protected IPaymentTransactionRepository paytransrep;
	protected IList<User> users;
	protected IList<Payment> payments;
	protected IDictionary<int,string> orderStatus;
	// charts variables
	protected long totalOrderc;
	protected string chartReference;
	protected IDictionary<int, int> dictChart;
	protected IDictionary<int, string> dictMonths;
	protected StringBuilder urlParamOrderFilter;
	
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
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");

		users = new List<User>();
		payments = new List<Payment>();
		totalOrderc = 0;
		chartReference = "";
		dictChart = new Dictionary<int, int>();
		dictMonths = new Dictionary<int, string>();
		orderStatus = OrderService.getOrderStatus();
		
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
				Session["payment_done"] = null;
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

		if (!String.IsNullOrEmpty(Request["chart_filter"])) {
			Session["chart_filter"] = Request["chart_filter"];
			chart_filter = (string)Session["chart_filter"];
		}else{
			if (Session["chart_filter"] != null) {
				chart_filter = (string)Session["chart_filter"];
			}else{
				Session["chart_filter"] = "";
				chart_filter = (string)Session["chart_filter"];
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
			Session["chart_filter"] = null;
			chart_filter = (string)Session["chart_filter"];
		}
		
		try
		{
			users = usrrep.find(null, "3", true, null, false, 1, false, false, false, false, false, false);
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

		
		//****************************** creo il grafico vendite su base annua/mensile
		dictMonths.Add(1, lang.getTranslated("backend.ordini.lista.table.chart.gen"));
		dictMonths.Add(2, lang.getTranslated("backend.ordini.lista.table.chart.feb"));
		dictMonths.Add(3, lang.getTranslated("backend.ordini.lista.table.chart.mar"));
		dictMonths.Add(4, lang.getTranslated("backend.ordini.lista.table.chart.apr"));
		dictMonths.Add(5, lang.getTranslated("backend.ordini.lista.table.chart.mag"));
		dictMonths.Add(6, lang.getTranslated("backend.ordini.lista.table.chart.giu"));
		dictMonths.Add(7, lang.getTranslated("backend.ordini.lista.table.chart.lug"));
		dictMonths.Add(8, lang.getTranslated("backend.ordini.lista.table.chart.ago"));
		dictMonths.Add(9, lang.getTranslated("backend.ordini.lista.table.chart.set"));
		dictMonths.Add(10, lang.getTranslated("backend.ordini.lista.table.chart.ott"));
		dictMonths.Add(11, lang.getTranslated("backend.ordini.lista.table.chart.nov"));
		dictMonths.Add(12, lang.getTranslated("backend.ordini.lista.table.chart.dic"));	
		
		string dtaChartFrom = "";
		string dtaChartTo = "";
                        	
		if("m".Equals(chart_filter)){
			int currentDay = DateTime.Now.Day;
			chartReference = dictMonths[DateTime.Now.Month];
			
			for(int counter = 1; counter<=currentDay; counter++){
				dictChart.Add(counter, 0);
			}
			
			dtaChartFrom = "01/"+DateTime.Now.Month.ToString()+"/"+DateTime.Now.Year.ToString();
			dtaChartTo = DateTime.Now.ToString("dd/MM/yyyy");
		}else{
			int currMonth = DateTime.Now.Month;
			chartReference = DateTime.Now.Year.ToString();
			
			for(int counter = 1; counter<=currMonth; counter++){
				dictChart.Add(counter, 0);
			}
			
			dtaChartFrom = "01/01/"+DateTime.Now.Year.ToString();
			dtaChartTo = DateTime.Now.Day.ToString()+"/"+DateTime.Now.Month.ToString()+"/"+DateTime.Now.Year.ToString();		
		}

		try
		{		
			IList<FOrder> ordersC = orderrep.find(null, -1, dtaChartFrom, dtaChartTo, "3", -1, true, -1, true);
	
			if(ordersC != null && ordersC.Count>0){	
				showChart = true;
				totalOrderc = ordersC.Count;
				foreach(FOrder x in ordersC){
					int baseC = 0;
					if("m".Equals(chart_filter)){
						baseC = x.insertDate.Day;
					}else{
						baseC = x.insertDate.Month;
					}
					int val = 0;

					if(dictChart.TryGetValue(baseC, out val)){
						dictChart[baseC] = val+1;
					}
				}
			}	
		}
		catch (Exception ex)
		{
			Response.Write("An error occured: " + ex.Message);
			totalOrderc = 0;
			showChart = false;
			chartReference = "";
		}
		
		
		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		try
		{
			Nullable<bool> spaydone = null;
			if (!String.IsNullOrEmpty(search_paydone)) {
				spaydone = Convert.ToBoolean(search_paydone);
			}
			
			orders = orderrep.find(search_guid, search_user, search_datefrom, search_dateto, search_status, search_paytype, spaydone, search_orderby, true);
			if(orders != null && orders.Count>0){				
				bolFoundLista = true;
			}	    	
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			orders = new List<FOrder>();
			bolFoundLista = false;
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
		
		urlParamOrderFilter= new StringBuilder()
		.Append("payment_done=").Append(search_paydone)
		.Append("&order_status=").Append(search_status)
		.Append("&order_date_from=").Append(search_datefrom)
		.Append("&order_date_to=").Append(search_dateto)
		.Append("&order_payment=").Append(search_paytype)
		.Append("&order_user=").Append(search_user)
		.Append("&order_guid=").Append(search_guid)
		.Append("&order_by=").Append(search_orderby);
		
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