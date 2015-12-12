<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>

<%@ import Namespace="NHibernate" %>
<%@ import Namespace="NHibernate.Cfg" %>

<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		ShoppingCartService.delCartByIdUser(((User)Session["user-online"]).id);			
		
	}
	    catch (Exception ex)
	{
	     Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>
<html>
<head>
</head>
<body>
    <h2>User Report </h2>
    
    <%
		Response.Write("user.id: "+((User)Session["user-online"]).id);
	%>
</body>
</html>