<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
protected string checkoutForm;
public ASP.MultiLanguageControl lang;
				
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
protected void Page_Load(object sender, EventArgs e)
{
	lang.set();
		
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	
	Response.Redirect(Utils.getBaseUrl(Request.Url.ToString(),1).ToString()+"error.aspx?error_code=043");	
}
</script>