<%@control Language="c#" description="backend-common-meta-control"%>
<%@ import Namespace="com.nemesys.model" %>
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
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>
<title><%=lang.getTranslated("backend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">-->
<%//Response.Charset="ISO-8859-1"%>
<!--<meta name=viewport content="width=device-width, initial-scale=1">-->
<link rel="stylesheet" href="/backoffice/css/style.css" type="text/css">
