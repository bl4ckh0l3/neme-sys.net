<%@ Page Language="C#" AutoEventWireup="true" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;

protected int orderid;
protected string paymentType;
protected bool paymentDone;
protected decimal billsAmount;
protected decimal paymentCommissions;
protected decimal orderAmount;
protected bool hasOrderRule;
protected IList<OrderBusinessRule> orderRules;
protected string pdone;
protected string cssClass;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	cssClass="LO";	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}	


	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	
	orderid = -1;
	paymentType = "";
	paymentDone = false;
	billsAmount = 0.00M;
	paymentCommissions = 0.00M;
	orderAmount = 0.00M;
	hasOrderRule = false;
	pdone = "";
	orderRules = null;
	
	if(!String.IsNullOrEmpty(Request["orderid"])){
		try{
			orderid = Convert.ToInt32(Request["orderid"]);
			FOrder order = orderep.getByIdExtended(orderid, true);
			
			paymentDone = order.paymentDone;
			paymentCommissions = order.paymentCommission;
			orderAmount = order.amount;

			pdone = lang.getTranslated("portal.commons.no");
			if(paymentDone){
				pdone = lang.getTranslated("portal.commons.yes");
			}			
			
			int paymentId = order.paymentId;
			Payment payment = payrep.getByIdCached(paymentId, true);
			if(payment != null){
				paymentType = payment.description;
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+payment.description))){
					paymentType = lang.getTranslated("backend.payment.description.label."+payment.description);
				}
				if(!String.IsNullOrEmpty(payment.paymentData)){
				paymentType+="<br/>"+payment.paymentData+"<br/>";
				}
			}
			
			IList<OrderFee> fees = orderep.findFeesByOrderId(orderid);
			if(fees != null && fees.Count>0){
				foreach(OrderFee f in fees){
					billsAmount+=f.amount;
				}
			}
			
			orderRules = orderep.findOrderBusinessRule(orderid, false);
			if(orderRules != null && orderRules.Count>0){
				hasOrderRule = true;
			}		
		}catch(Exception ex){
			StringBuilder builder = new StringBuilder("Exception: ")
			.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
			Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
			lrep.write(log);			
		}
	}
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<table border="0" cellpadding="0" cellspacing="0" align="center">
			<tr>
			<td>
				<span class="labelForm"><%=lang.getTranslated("backend.ordini.include.table.label.ordine_complete")%></span><br><br>
			
				<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_id_ordine")%>: <strong><%=orderid%></strong></div>
				<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_1")%>: <strong><%=paymentType%></strong></div>
				<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_pagam_done")%>: <strong><%=pdone%></strong></div>
				<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_spese_sped")%>: <strong>&euro; <%=billsAmount.ToString("#,###0.00")%></strong></div>
				<%if(hasOrderRule){
					foreach(OrderBusinessRule x in orderRules){
						string orLabel = x.label;
						if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+orLabel))){ 
							orLabel = lang.getTranslated("backend.businessrule.label.label."+orLabel);
						}%>
						<div class="spese-div"><%=orLabel%>:&nbsp;<strong>&euro;&nbsp;<%=x.value.ToString("#,###0.00")%></strong></div>
					<%}
				}%>
				<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_payment_commission")%>: <strong>&euro;  <%=paymentCommissions.ToString("#,###0.00")%></strong></div>
				<div id="spese-totale"><%=lang.getTranslated("frontend.carrello.table.label.confirm_tot_ord")%>: <strong>&euro;  <%=orderAmount.ToString("#,###0.00")%></strong></div>
				
				<%if(paymentDone){%>					
					<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_complete")%></p>
				<%}else{%>
					<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_2")%></p>
				<%}%>
			</td>
			</tr>
			</table>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
