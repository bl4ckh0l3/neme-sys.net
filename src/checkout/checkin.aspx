<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
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

	if(!String.IsNullOrEmpty(Request["token"])){
		Server.Transfer("/checkout/checkin_paypal.aspx?token="+Request["token"],true);
	}else if(!String.IsNullOrEmpty(Request["b"])){
		Server.Transfer("/checkout/checkin_sella.aspx?b="+Request["b"],true);
	}else{
		Response.Redirect("/error.aspx?error_code=043");
	}	
}
</script>
