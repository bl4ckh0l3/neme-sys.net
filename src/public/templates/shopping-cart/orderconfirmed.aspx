<%@ Page Language="C#" AutoEventWireup="true" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;

protected int orderid;
protected string paymentType;
protected bool paymentDone;
protected decimal billsAmount;
protected decimal paymentCommissions;
protected decimal orderAmount;
protected bool hasOrderRule;
protected IList<OrderBusinessRule> orderRules;
protected string pdone;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	lang.set();

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	

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
<title><%=lang.getTranslated("frontend.page.title")%></title>
<META name="description" CONTENT="">
<META name="keywords" CONTENT="">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<div id="content-center">
			<div id="carrello-lista">   
				<div id="prodotto-conto">
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
					
					<h2><%=lang.getTranslated("frontend.carrello.table.label.ordine_complete")%></h2>
					<%if(paymentDone){%>					
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_complete")%></p>
					<%}else{%>
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_2")%></p>
					<%}%>
				</div>
			</div>	
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
