<%@control Language="c#" description="common-footer"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	copyr.Text = Utils.getCurrentCopyrightYearRange();

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>
<div id="footer"><span><lang:getTranslated keyword="frontend.bottom.label.copyright" runat="server" /> <asp:Literal id="copyr" runat="server" /></span></div>
