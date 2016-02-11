<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
		
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	
	if(!String.IsNullOrEmpty(Request["orderid"])){
		FOrder order = orderep.getById(Convert.ToInt32(Request["orderid"]));
		
		if(order != null){
			string modulePage = PaymentService.getCheckoutModulePage(order.paymentId);
			if(!String.IsNullOrEmpty(modulePage)){
				Server.Transfer("/checkout/checkout_"+modulePage+".aspx?orderid="+order.id+"&useLang="+Request["useLang"],true);
			}
		}
	}
}
</script>