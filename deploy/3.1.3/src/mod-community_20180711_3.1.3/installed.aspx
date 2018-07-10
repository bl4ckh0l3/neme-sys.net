<%@ Page Language="C#" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
string copyright = "";
protected void Page_Load(Object sender, EventArgs e)
{
	copyr.Text = CommonService.getCurrentCopyrightYearRange();

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>installed page</title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
</head>
<body>
<div id="warp">

	<div id="header">
		<div id="top-bar">
			<div id="top-bar-logo"><asp:HyperLink  style="color:#FFFFFF;text-decoration:none;" NavigateUrl="~/default.aspx" Text="Home Page"  runat="server" /></div>
			<div id="top-bar-search"></div>
			<div id="top-bar-lenguage">
				<ul>
				<li></li>
				</ul>
			</div>
		</div>
		<div id="image-container"></div>
	</div>
	<div id="container">    	
		<div id="menu-left"></div>
		<div id="content-center" style="width:100%;">
		
		<form name="install_login" method="post" action ="/login.aspx">
		<p align="center">Il database e' stato correttamente istallato!<br/><br/>
		
		<input type="hidden" name="j_username" value="administrator">
<!--nsys-demoinst1-->
		<input type="hidden" name="j_password" value="admin">
<!---nsys-demoinst1-->
		<input type="submit" value="LOGIN" align="center">
		</p>
		</form>
		
		</div>
		<div id="menu-right"></div>
	</div>
	<div id="footer"><span>Powered by BHNet Online Technology Merchant Copyright &copy; <asp:Literal id="copyr" runat="server" /></span></div>
</div>
</body>
</html>