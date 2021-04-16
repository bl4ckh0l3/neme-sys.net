<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" Debug="false" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<title></title>
	<meta name="robots" content="noindex">
	<meta name="googlebot" content="noindex">
</head>
<%if(!String.IsNullOrEmpty(resolved)) {%>
	<body onload="document.controller_redirect.submit();"><!--  -->
	<form method="post" name="controller_redirect" action="<%=resolved%>">
	<input type="hidden" name="categoryid" value="<%=categoryid%>">
	<input type="hidden" name="hierarchy" value="<%=hierarchy%>">
	<input type="hidden" name="lang_code" value="<%=forcedLangCode%>">
	</form>
	</body>
<%}else{%>
	<body>
		<br>
		<div align="center">
		<font face="Verdana" size="6" color="#003399">Under Construction</font></b>
		</div>
	</body>
<%}%>
</html>
