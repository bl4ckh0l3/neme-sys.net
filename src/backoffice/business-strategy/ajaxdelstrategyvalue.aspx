<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		

	IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	int idStrategy = Convert.ToInt32(Request["id_strategy"]);

	try
	{	
		BusinessRuleConfig toDel = brulerep.getBusinessRuleConfigById(idStrategy);
		brulerep.deleteBusinessRuleConfig(toDel);
	}
	catch(Exception ex)
	{
		//Response.Write(ex.Message);
		Response.StatusCode = 400;
	}	
}
</script>