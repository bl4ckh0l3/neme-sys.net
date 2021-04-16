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
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
protected ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected int posted;
	
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
	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	Logger log;		
	
	int id_comment = Convert.ToInt32(Request["id_comment"]);

	try
	{
		Comment comment = commentrep.getById(id_comment);
		comment.active = true;
		commentrep.update(comment);
		msg.Text = lang.getTranslated("frontend.popup.label.comment_posted");
	}catch(Exception ex){
		msg.Text = ex.Message;
	}	
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<div id="content-center" style="min-height:300px;">
			<div align="center">
				<asp:Literal id="msg" runat="server" />	
			</div>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>