<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/csv";
	Response.AddHeader("content-disposition", "attachment;  filename=csv_logs.csv");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	StringBuilder result = new StringBuilder();
	IList<Logger> logs;
	
	try
	{	    
		logs = lrep.getAll();
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message);
		logs = new List<Logger>();
	}
		
	try
	{	
		//CREATE CSV HEADER
		result
		.Append(lang.getTranslated("backend.logs.include.table.header.msg").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.logs.include.table.header.usr").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.logs.include.table.header.type").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.logs.include.table.header.date").ToUpper())
		.Append(System.Environment.NewLine);
		
		//APPEND CSV ROWS
		if(logs != null && logs.Count>0){
			foreach(Logger p in logs){
				result.Append("\"").Append(p.msg).Append("\",")
				.Append("\"").Append(p.usr).Append("\",")
				.Append("\"").Append(p.type).Append("\",")
				.Append("\"").Append(p.date.ToString("dd/MM/yyyy HH:mm:ss")).Append("\"")
				.Append(System.Environment.NewLine);
			}
		}
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
		
	Response.Write(result.ToString());
	Response.End();
}
</script>