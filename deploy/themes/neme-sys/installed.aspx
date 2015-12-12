<%@ Page Language="C#" %>
<%@ import Namespace="com.nemesys.model" %>
<script runat="server">
string copyright = "";
protected void Page_Load(Object sender, EventArgs e)
{
	copyr.Text = Utils.getCurrentCopyrightYearRange();

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
<div id="container">
	<div id="header" class="bg_nemesys">		
		<div class="header_navbar">
			<h1 class="nemesys_h1" title="nemesys cms">ne<span>me-sys</span></h1>			
			<div class="div_login">
				<a href="/login.aspx">Accedi!</a> Oppure <a href="/area_user/account.aspx">Registrati</a>
			</div>
		</div>
	</div>
	<div id="main"> 	
		<div class="content">		
			<form name="install_login" method="post" action ="/login.aspx">
			<p align="center">Il database e' stato correttamente istallato!<br/><br/>
			All query have been executed!<br/><br/>
			
			<input type="hidden" name="j_username" value="administrator">
			<input type="hidden" name="j_password" value="admin">
			<input type="submit" value="LOGIN BACK OFFICE" align="center">
			</p>
			</form>
		
		</div>
	</div>
</div>
<div id="footer"><span>Powered by BHNet Online Technology Merchant Copyright &copy; <asp:Literal id="copyr" runat="server" /></span></div>
</body>
</html>