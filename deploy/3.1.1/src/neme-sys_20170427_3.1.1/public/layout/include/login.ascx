<%@control Language="c#" description="login-control"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
protected string secureURL;
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	IMultiLanguageRepository langRepository = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
	
	if (!String.IsNullOrEmpty(Request["error_code"]) && !String.IsNullOrEmpty(langRepository.convertErrorCode(Request["error_code"])))
	{
		message.Text = "<p><span class=error>"+lang.getTranslated(langRepository.convertErrorCode(Request["error_code"]))+"</span></p>";
	}
	
	if (!String.IsNullOrEmpty(Request["messages"]) && !String.IsNullOrEmpty(langRepository.convertMessageCode(Request["messages"])))
	{
		message.Text = "<p><span class=error>"+lang.getTranslated(langRepository.convertMessageCode(Request["messages"]))+"</span></p>";
	}
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	
	secureURL = Utils.getBaseUrl(Request.Url.ToString(),1).ToString();
}
</script>
<div id="warp">
	<CommonHeader:insert runat="server" />
	<div id="container">    	
		<div id="menu-left"></div>
		<div id="content-center">
			<h1><%=lang.getTranslated("frontend.login.label.login_needed")%></h1>
			
			<asp:Literal id="message" runat="server" />
			
			<div id="login" style="visibility:visible;display:block;">
			<form name="login" method="post" action="<%=secureURL%>login.aspx" onSubmit="return sendForm();">
			<input name="from" type="hidden" value="<%=Request["from"]%>" />			
			<h3>Username</h3>
			<input name="j_username" type="text" class="larghezza100" />
			<h3>Password</h3>
			<input name="j_password" type="password" class="larghezza100"  onkeypress="javascript:return notSpecialCharAndSpaceButReturn(event);"/>
			
			<p><input type="checkbox" value="1" name="keep_logged">&nbsp;<%=lang.getTranslated("frontend.login.label.keep_logged")%>			
			<span id="allinea-destra"><input name="login" type="submit" value="<%=lang.getTranslated("frontend.login.label.login_button")%>" /></span></p>
			</form>
			</div>
			
			<div id="lost-pwd" style="visibility:hidden;display:none;">
			<form name="lost_pwd" method="post" action="<%=secureURL%>login.aspx" onSubmit="return sendFormLostPwd();">
			<input name="from" type="hidden" value="lost_pwd" />	
			<h3>Username</h3>
			<input name="j_username" type="text" class="larghezza100" />			
			<h3 class="lost-pwd-mail">Email</h3>
			<input name="j_mail" type="text" class="larghezza100" />
			
			<p><input type="checkbox" value="1" name="keep_logged">&nbsp;<%=lang.getTranslated("frontend.login.label.keep_logged")%>			
			<span id="allinea-destra"><input name="retrieve" type="submit" value="<%=lang.getTranslated("frontend.login.label.retrieve_button")%>" /></span></p>
			</form>
			</div>
			
			<p><a id="login-lostpwd" href="javascript:fadeDiv('login');fadeDiv('lost-pwd');"><%=lang.getTranslated("frontend.login.label.lost_pwd")%></a></p>

			<h2 style="padding-bottom:3px;"padding-top:20px;"><%=lang.getTranslated("frontend.login.label.no_yet_reg")%></h2>
			<%=lang.getTranslated("frontend.login.label.compile_module")%>&nbsp;<a href="<%=secureURL%>area_user/account.aspx"><%=lang.getTranslated("frontend.login.label.registration")%></a>
			<div class="spese-div"></div>
		</div>
		<div id="menu-right"></div>
	</div>
	<CommonFooter:insert runat="server" />
</div>