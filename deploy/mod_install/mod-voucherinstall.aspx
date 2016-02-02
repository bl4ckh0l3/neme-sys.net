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
protected IDictionary<string,IDictionary<string,string>> modules;
protected IDictionary<string,IDictionary<string,string>> modulesKV;	

protected void Page_Load(Object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;

	ConfigurationService confservice = new ConfigurationService();
	
	StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
	
	copyr.Text = Utils.getCurrentCopyrightYearRange();
	
	bool carryOn = false;
	string pathInstall = HttpContext.Current.Server.MapPath("~/public/install/moduleinstall.aspx");
		
	try
	{
		if("true"==Request["apply"]){
			Config config = confservice.get("dbconn");
			if(config != null)
			{					
				DBConnectionManager.setConnectionString(config.value);
				MySqlConnection conn = DBConnectionManager.getDBConnection();
				string pathSql = HttpContext.Current.Server.MapPath("~/public/install/module_install_query.sql");			
		
				string script = "";
				using (StreamReader sr = new StreamReader(pathSql)) 
				{						
					script = sr.ReadToEnd();
				}
		
				MySqlCommand cmd = new MySqlCommand();
				cmd.Connection = conn;
				cmd.CommandText = script;
				cmd.Prepare();
				cmd.ExecuteNonQuery();				
				
				if(File.Exists(pathSql)) {
					File.Delete(pathSql);
				}				

				// aggiorno tutti i file di progetto legati ai moduli
				modules = new  Dictionary<string,IDictionary<string,string>>();
				modulesKV = new  Dictionary<string,IDictionary<string,string>>();					
				
				cmd = new MySqlCommand("SELECT * FROM MODULES ORDER BY insert_date ASC", conn);
				MySqlDataReader reader = cmd.ExecuteReader(CommandBehavior.CloseConnection);	
				
				if (reader.HasRows)
				{
					while (reader.Read())
					{
						IDictionary<string,string> moduleValues = new  Dictionary<string,string>();
						string keyword = reader["keyword"].ToString();
						string description = reader["description"].ToString();
						string version = reader["version"].ToString();
						string active = reader["active"].ToString();
						string insert_date = reader["insert_date"].ToString();

						moduleValues.Add("description", description);
						moduleValues.Add("version", version);
						moduleValues.Add("active", active);
						moduleValues.Add("insert_date", insert_date);
						
						modules.Add(keyword, moduleValues);
					}
				}
				reader.Close(); 	

				foreach(string x in modules.Keys){
					string path = HttpContext.Current.Server.MapPath("~/public/install/"+x+"_replace.properties");
					if(File.Exists(path)) {
						IDictionary<string,string> moduleKVValues = new  Dictionary<string,string>();
						string line;

						// Read the file and display it line by line.
						StreamReader file = new StreamReader(path);
						while((line = file.ReadLine()) != null) {
							//Response.Write ("Line: "+line+"<br>");
							
							if(!String.IsNullOrEmpty(line.Trim())){
								string keyword = line.Substring(0,line.IndexOf("="));
								string value = line.Substring(line.IndexOf("=")+1);
								
								//Response.Write ("keyword: "+keyword+" - value: "+value+"<br>");
								
								moduleKVValues.Add(keyword, value);
							}
						}
						file.Close();	

						modulesKV.Add(x,moduleKVValues);
					}
				}				
				
				processDirectory(HttpContext.Current.Server.MapPath("~/public/layout"));
				
				processDirectory(HttpContext.Current.Server.MapPath("~/public/modules"));

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

protected void processDirectory(string targetDirectory) 
{
	// Process the list of files found in the directory. 
	string [] fileEntries = Directory.GetFiles(targetDirectory);
	foreach(string fileName in fileEntries)
		processFile(fileName);

	// Recurse into subdirectories of this directory. 
	string [] subdirectoryEntries = Directory.GetDirectories(targetDirectory);
	foreach(string subdirectory in subdirectoryEntries)
		processDirectory(subdirectory);
}

// Insert logic for processing found files here. 
protected void processFile(string path) 
{		
	string extension = Path.GetExtension(path);
	

	if(".cs"==extension || ".aspx"==extension || ".ascx"==extension || ".css"==extension || ".js"==extension || ".xml"==extension){
		//Response.Write("path: "+ path + " -extension: "+extension+"<br /><br />");
		checkModuleTag(path);
	}
}

protected void checkModuleTag(string path){
	bool saveFile = false;

	try
	{
		string content = "";
		using (StreamReader sr = new StreamReader(path)) 
		{						
			content = sr.ReadToEnd();
		}	
		
		//*** faccio il parsing del file per ogni modulo istallato
		foreach(string x in modulesKV.Keys){
			//Response.Write("module name: "+x+ "<br />");
			
			IDictionary<string,string> values = modulesKV[x];
			
			foreach(string key in values.Keys){
				//Response.Write("key: "+key+" - value: "+values[key]+"<br />");
				// fare il parsing dei tag in base al modulo e al tipo di tag
				
				if (content.IndexOf("/*<!--"+key) >= 0) {  
					// Response.Write("found tag /*&lt;!--"+key+"<br />");	
					//Response.Write(" - content before: "+content+"<br /><br /><br />");	
					string startRepl = content.Substring(0,content.IndexOf("/*<!--"+key+"-->*/")+11+key.Length);
					string endRepl = content.Substring(content.IndexOf("/*<!---"+key+"-->*/"));
					content = startRepl+values[key]+endRepl;
					//Response.Write(" - content after: "+content+"<br /><br /><br />");	
					saveFile = true;			
				}else if (content.IndexOf("<!--"+key) >= 0) {  
					// Response.Write("found tag &lt;!--"+key+"<br />");
					//Response.Write(" - content before: "+content+"<br /><br /><br />");	
					string startRepl = content.Substring(0,content.IndexOf("<!--"+key+"-->")+7+key.Length);
					string endRepl = content.Substring(content.IndexOf("<!---"+key+"-->"));
					content = startRepl+values[key]+endRepl;	
					//Response.Write(" - content after: "+content+"<br /><br /><br />");
					saveFile = true;			
				}
			}
						
		}

		if(saveFile){
			using (StreamWriter sw = new StreamWriter(path)) 
			{						
				sw.Write(content);
			}
		}

	}
	catch(Exception ex)
	{
		throw;
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
	if(confirm("Verranno eseguite tutte le query per l'inserimento dei nuovi dati su database;\nconfermi avvio procedura? \n\n All query will execute on database; confirm procedure?")){
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
	  
		<form action="/public/install/moduleinstall.aspx" method="post" name="form_install">
		<input type="hidden" name="apply" value="true">
		<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="/backoffice/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
		<p align="center"><input type="button" value="ACTIVATE MODULE" onclick="javascript:sendForm();"></p>
		</form>	

		</div>
		<div id="menu-right"></div>
	</div>
	<div id="footer"><span>Powered by BHN Online Technology Merchant Copyright &copy; <asp:Literal id="copyr" runat="server" /></span></div>
</div>
</body>
</html>