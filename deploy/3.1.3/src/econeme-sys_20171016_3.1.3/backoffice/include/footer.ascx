<%@control Language="c#" description="backend-footer"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
private ASP.BoMultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	copyr.Text = CommonService.getCurrentCopyrightYearRange();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>
<div id="backend-footer">
	<div>
	<h2><lang:getTranslated keyword="backend.bottom.label.product_version" runat="server" /></h2>
	<span class="poweredby"><lang:getTranslated keyword="backend.bottom.label.powered_by" runat="server" /></span>
	</div>
	<div style="float:right;">
	<span class="copyright"><lang:getTranslated keyword="backend.bottom.label.copyright" runat="server" /> <asp:Literal id="copyr" runat="server" /></span>
	</div>
</div>