<%@control Language="c#" description="common-header" Debug="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="SearchWidget" TagName="insert" Src="~/public/layout/addson/search/search-widget.ascx" %>
<%@ Register TagPrefix="LangsWidget" TagName="insert" Src="~/public/layout/addson/langs/langs-widget.ascx" %>
<%@ Register TagPrefix="CookiesPolicy" TagName="insert" Src="~/common/include/cookies-policy.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
protected string url;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	
	url = Utils.getBaseUrl(Request.Url.ToString(),0).ToString();
}
</script>

	<CookiesPolicy:insert runat="server" />
	<div id="header">
		<div id="top-bar">
			<div id="top-bar-logo"><!--nsys-head1--><a href="<%=url%>"><img src="/common/img/logo.png" hspace="2" vspace="0" border="0" align="left" alt="<%=lang.getTranslated("portal.commons.label.home_page")%>"></a><!---nsys-head1--></div>
			<div id="top-bar-search"><SearchWidget:insert runat="server" /></div>
			<div id="top-bar-lenguage"><LangsWidget:insert runat="server" /></div>
		</div>
		<div id="image-container">
			<div>
			</div>		
		</div>
	</div>