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
<%@ Register TagPrefix="CommentsWidget" TagName="render" Src="~/public/layout/addson/comments/comments-widget.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
protected ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected string style, cssClass;
	
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
	login.acceptedRoles = "3";
	bool logged = login.checkedUser();
	confservice = new ConfigurationService();	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	//cw1.style = Request["style"];
	//cw1.cssClass = Request["cssClass"];	
	cw1.elemId = Request["elemid"]; 	
	cw1.elemType = Request["elemtype"]; 
}
</script>
<CommentsWidget:render runat="server" ID="cw1" index="1"/>