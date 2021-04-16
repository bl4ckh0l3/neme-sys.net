<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService confservice;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	confservice = new ConfigurationService();	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
	Logger log;

	try
	{
		string fileName = Request["filename"];
		string filePath = Request["attach_path"];
		string fileid = Request["attach_id"];
		string referurl = Request["page_url"];
		string contentType = Request["contenttype"];
							
		string userdown = "";
		if(logged){
			userdown = login.userLogged.username;
		}
		
		UserDownload download = new UserDownload();
		download.idFile = -1;
		if(!String.IsNullOrEmpty(fileid)){download.idFile = Convert.ToInt32(fileid);}
		download.user = userdown;
		download.fileName = fileName;
		download.contentType = contentType;
		download.filePath = filePath;
		download.userHost = referurl;
		download.userInfo = Request.ServerVariables["HTTP_USER_AGENT"];

		userrep.insertDownload(download);
		
		/*
		StringBuilder downbuilder = new StringBuilder("Attachment Download: ")
		.Append(" <br>-User: ").Append(userdown)
		.Append(" <br>-Attach id: ").Append(fileid)
		.Append(" <br>-Attach path: ").Append(filePath)
		.Append(" <br>-Attach type: ").Append(label)
		.Append(" <br>-Referer URL: ").Append(referurl);
		log = new Logger(downbuilder.ToString(),"system","info",DateTime.Now);		
		lrep.write(log);
		*/
	}
	catch(Exception ex)
	{
		StringBuilder errbuilder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(errbuilder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>