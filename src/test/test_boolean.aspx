<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<html>
<head>
</head>

<body>
<%
try	{
	Nullable<bool> test = true;
	
	Response.Write("test value: "+test);
}catch(Exception ex){
	Response.Write(ex.Message);
}%>
</body>
</html>