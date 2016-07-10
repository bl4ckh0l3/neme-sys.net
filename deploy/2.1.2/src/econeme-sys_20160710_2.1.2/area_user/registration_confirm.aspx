<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="UserConfirmRegistrationBody" TagName="insert" Src="~/public/layout/area_user/confirmregistration.ascx" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	ConfigurationService confservice = new ConfigurationService();
	//se il sito è offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		UriBuilder defRedirect = new UriBuilder(Request.Url);
		defRedirect.Port = -1;	
		defRedirect.Path = "";			
		defRedirect.Query = "";
		Response.Redirect(defRedirect.ToString());
	}	
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>
<UserConfirmRegistrationBody:insert runat="server" />