<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.model" %>

<script runat="server">

public IList<Category> menu;
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		
		menu = MenuService.getMenu(1, "04", "15", 1, "false");
		
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
    <h2>Template Report </h2>
    
    <%	
	foreach(Category cat in menu){
		Response.Write(cat.ToString()+"<br><br>");
	}
	%>
</body>
</html>