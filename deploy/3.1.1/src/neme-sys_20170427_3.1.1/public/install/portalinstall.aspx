<%@ Page Language="C#" Debug="true" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="MySql.Data.MySqlClient" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database" %> 
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 

<script runat="server">	
protected void Page_Load(Object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;

	ConfigurationService confservice = new ConfigurationService();
	
	StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
	
	copyr.Text = Utils.getCurrentCopyrightYearRange();
	
	bool carryOn = false;
	string pathInstall = HttpContext.Current.Server.MapPath("~/public/install/portalinstall.aspx");
	
	try
	{
		if("true"==Request["apply"]){
			string connectionString = "server="+Request["servername"]+";database="+Request["dbname"]+";user="+Request["dbuser"]+";port="+Request["serverport"]+";password="+Request["dbpassword"]+";pooling=true;charset=utf8;";
			Config config = confservice.get("dbconn");
			if(config != null)
			{	
				config.value = connectionString;
				confservice.update(config);
				
				Config configsn = confservice.get("server_name");
				configsn.value = Request.Url.Host;
				confservice.update(configsn);
				
				DBConnectionManager.setConnectionString(connectionString);
				MySqlConnection conn = DBConnectionManager.getDBConnection();
				
				string pathSql = HttpContext.Current.Server.MapPath("~/public/install/global_install_query.sql");
				//FileInfo file = new FileInfo(pathSql);
				//string script = file.OpenText().ReadToEnd(); 				

				StreamReader reader = File.OpenText(pathSql);
				string script = reader.ReadToEnd();
				reader.Close();

				MySqlCommand cmd = new MySqlCommand();
				cmd.Connection = conn;
				cmd.CommandText = script;
				cmd.Prepare();
				cmd.ExecuteNonQuery();				
				
				if(File.Exists(pathSql)) {
					File.Delete(pathSql);
				}				
				
				carryOn = true;
			}			
		}
	}
	catch(Exception ex)
	{
		Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		carryOn = false;
	}
	
	if(carryOn){			
		if(File.Exists(pathInstall)) {
			File.Delete(pathInstall);
		}
				
		Response.Redirect("~/installed.aspx");
	}
}
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>install page</title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
<script language="JavaScript">
function sendForm(){
	if(document.form_install.dbuser.value == ""){
		alert("valorizzare il nome utente!");
		return;
	}
	if(document.form_install.dbpassword.value == ""){
		alert("valorizzare la password!");
		return;
	}
	if(document.form_install.dbname.value == ""){
		alert("valorizzare il nome del database!");
		return;
	}
	if(document.form_install.servername.value == ""){
		alert("valorizzare il nome del server!");
		return;
	}
	if(document.form_install.serverport.value == ""){
		alert("valorizzare la porta del database(se nn si conosce lasciare la 3306 di default)!");
		return;
	}
	
	if(confirm("Verranno lanciate tutte le query per la creazione e la prima inizializzazione del nuovo database;\nconfermi avvio procedura?")){
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_install.submit();
	}else{
		return;
	}
}
</script>
</head>
<body>
<div id="warp">

	<div id="header">
		<div id="top-bar">
			<div id="top-bar-logo"><a href="/default.aspx" style="color:#FFFFFF;text-decoration:none;">Home</a></div>
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
		<div id="content-center">
	  
		<form action="/public/install/portalinstall.aspx" method="post" name="form_install">
		<input type="hidden" name="apply" value="true">

		<h1>DB connection variables:</h1>
		
		<h3>DB user:</h3>
		<input name="dbuser" type="text" class="larghezza100" />
		
		<h3>DB password:</h3>
		<input name="dbpassword" type="text" class="larghezza100" />
		
		<h3>DB name:</h3>
		<input name="dbname" type="text" class="larghezza100" />
		
		<h3>DB Server name/IP:</h3>
		<input name="servername" type="text" value="localhost" class="larghezza100" />
		
		<h3>Server port:</h3>
		<input name="serverport" type="text" class="larghezza100" value="3306" />

		<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="/backoffice/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>

		<p align="center"><input type="button" value="INSERT" onclick="javascript:sendForm();"></p>	
		</form>	

		</div>
		<div id="menu-right"></div>
	</div>
	<div id="footer"><span>Powered by BHN Online Technology Merchant Copyright &copy; <asp:Literal id="copyr" runat="server" /></span></div>
</div>
</body>
</html>
