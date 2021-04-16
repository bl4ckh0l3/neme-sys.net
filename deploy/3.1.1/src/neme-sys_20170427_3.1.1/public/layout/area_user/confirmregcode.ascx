<%@control Language="c#" description="user-account-control"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<script runat="server">
	protected ASP.MultiLanguageControl lang;
	protected ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected string username;
	protected bool confirmed;
		
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
		bool loggedin = login.checkedUser();
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect(Utils.getBaseUrl(Request.Url.ToString(),1).ToString()+"backoffice/index.aspx");
		}
		
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");			
		confservice = new ConfigurationService();
		
		confirmed = false;
		username = "";
		int id = -1;
		if(!String.IsNullOrEmpty(Request["id"])){
			id = Convert.ToInt32(Request["id"]);
		}
		User user = usrrep.getById(id);
		if(user != null){
			username = user.username;
			string confirmationCodeCheck = Request["confirm_reg_code"];
			UserConfirmation uconf = new UserConfirmation();
			uconf.idUser = user.id;
			uconf.confirmationCode = "";
			if(usrrep.matchConfirmationCode(user, confirmationCodeCheck, out uconf)){
				try{
					user.isActive = true;
					usrrep.update(user);				
					confirmed = true;
					usrrep.deleteConfirmationCode(uconf);
					//login.updateUserLogged(user);
				}catch(Exception ex){
					confirmed = false;
				}
			}
		}
		
		// init menu frontend
		this.mf1.modelPageNum = 1;
		this.mf1.categoryid = "";	
		this.mf1.hierarchy = "";	
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";		
	}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">
			<h1><%=lang.getTranslated("frontend.header.label.utente_modify")%>&nbsp;<em><%=username%></em></h1>				
			<%if(confirmed){%>
				<h1><%=lang.getTranslated("frontend.registration.manage.label.confirm_registration_success")%></h1>
			<%}else{%>
				<h1><%=lang.getTranslated("frontend.registration.manage.label.confirm_registration_fail")%></h1>
			<%}%>						
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>