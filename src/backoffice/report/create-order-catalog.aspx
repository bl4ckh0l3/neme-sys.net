<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
protected IList<FOrder> orders;
protected IOrderRepository orderrep;
protected IUserRepository usrrep;
protected IPaymentRepository payrep;
protected IPaymentTransactionRepository paytransrep;
protected string search_guid, search_datefrom, search_dateto, search_status, search_paydone;	
protected int search_user, search_orderby, search_paytype;
protected IDictionary<int,string> orderStatus;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/csv";
	Response.AddHeader("content-disposition", "attachment;  filename=csv_order.csv");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	orderrep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
	
	StringBuilder result = new StringBuilder();
	
	search_orderby = -1;
	search_guid = "";
	search_user = -1;
	search_paytype = -1;
	search_paydone = "";
	search_datefrom = "";
	search_dateto = "";
	search_status = "";
	orderStatus = OrderService.getOrderStatus();
	
	bool bolFoundLista = false;	
	
	if (!String.IsNullOrEmpty(Request["order_by"])) {
		search_orderby = Convert.ToInt32(Request["order_by"]);
	}
	if (!String.IsNullOrEmpty(Request["order_guid"])) {
		search_guid = Request["order_guid"];
	}
	if (!String.IsNullOrEmpty(Request["order_user"])) {
		search_user = Convert.ToInt32(Request["order_user"]);
	}
	if (!String.IsNullOrEmpty(Request["order_payment"])) {
		search_paytype = Convert.ToInt32(Request["order_payment"]);
	}
	if (!String.IsNullOrEmpty(Request["payment_done"])) {
		search_paydone = Request["payment_done"];
	}
	if (!String.IsNullOrEmpty(Request["order_date_from"])) {
		search_datefrom = Request["order_date_from"];
	}
	if (!String.IsNullOrEmpty(Request["order_date_to"])) {
		search_dateto = Request["order_date_to"];
	}
	if (!String.IsNullOrEmpty(Request["order_status"])) {
		search_status = Request["order_status"];
	}	
		
	try
	{
		try
		{
			orders = orderrep.find(search_guid, search_user, search_datefrom, search_dateto, search_status, search_paytype, search_paydone, search_orderby, false);
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
		
	
		//CREATE CSV HEADER
		result.Append(lang.getTranslated("backend.ordini.lista.table.header.id_ordine").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.header.cliente").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.header.data_insert").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.search.header.type_pagam").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.search.header.pagam_done").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.header.totale_order").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.ordini.lista.table.search.header.stato_ord").ToUpper());		
		result.Append(System.Environment.NewLine);
		
		//APPEND CSV ROWS
		if(bolFoundLista){
			foreach(FOrder order in orders){
				bool hasExtURL = false;
				string paydesc = "";
				string labelStatus = "";
				string paymentDone = "";
				
				Payment p = payrep.getByIdCached(order.paymentId, true);
				if(p != null){
					hasExtURL = p.hasExternalUrl;
					paydesc = p.description;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+paydesc))){
						paydesc = lang.getTranslated("backend.payment.description.label."+paydesc);
					}						
				}	
				
				if (order.status==1) {
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
				}else if(order.status==2){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
				}else if(order.status==3){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
				}else if(order.status==4){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
				}			

				if(order.paymentDone){
					bool payNotified = false;
					
					if(paytransrep.hasPaymentTransactionNotified(order.id)){
						payNotified = true;
					}
					
					if(payNotified || !hasExtURL){
						paymentDone = lang.getTranslated("backend.ordini.lista.table.alt.order_paied_notified");
					}else{
						paymentDone = lang.getTranslated("backend.ordini.lista.table.alt.order_paied_no_notified");
					}														
				}else{
					paymentDone = lang.getTranslated("backend.ordini.lista.table.alt.order_to_pay");
				}				
				
				result.Append("\"").Append(order.id).Append("\",")
				.Append("\"").Append(usrrep.getById(order.userId).username).Append("\",")
				.Append("\"").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("\",")
				.Append("\"").Append(paydesc).Append("\",")
				.Append("\"").Append(paymentDone).Append("\",")
				.Append("\"").Append("EUR ").Append(order.amount.ToString("#,###0.00")).Append("\",")
				.Append("\"").Append(labelStatus).Append("\"");						
				result.Append(System.Environment.NewLine);
			}	
		}
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
		
	Response.Write(result.ToString());
	Response.End();
}
</script>