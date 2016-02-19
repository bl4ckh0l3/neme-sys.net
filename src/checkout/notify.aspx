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
	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");

	if(!String.IsNullOrEmpty(Request["custom"])){
		Server.Transfer("/checkout/notify_paypal.aspx?custom="+Request["custom"],true);
	}else if(!String.IsNullOrEmpty(Request["b"])){
		Server.Transfer("/checkout/notify_sella.aspx?b="+Request["b"]+"&a="+Request["a"],true);
	}else{
		Logger log = new Logger();
		log.usr= "system";
		log.msg = "order notify failed";
		log.type = "error";
		log.date = DateTime.Now;
		lrep.write(log);
	}	
}
</script>
