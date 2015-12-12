<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	string cssClass="LCY";
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	
	UriBuilder builder0 = new UriBuilder(Request.Url);
	builder0.Scheme = "http";
	builder0.Port = -1;
	builder0.Path = "backoffice/currency/currencypoller.aspx";		
	string url = builder0.ToString();
	
	try
	{			
		HttpWebRequest myHttpWebRequest = (HttpWebRequest)WebRequest.Create(url);	
		WebResponse response = myHttpWebRequest.GetResponse();
		response.Close();
	}
	catch(Exception ex){
		StringBuilder builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);	
		Logger log = new Logger(builder.ToString(), "system", "error", DateTime.Now);	
		lrep.write(log);	
	}
	finally
	{
		Response.Redirect("/backoffice/currency/currencylist.aspx?cssClass="+cssClass);		
	}
}
</script>