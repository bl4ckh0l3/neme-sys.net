<%@ Page Language="C#" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<%	
int id = Convert.ToInt32(Request["id"]);
bool isactive = Convert.ToBoolean(Convert.ToInt32(Request["isactive"]));
try
{
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");	
	Language mylang = langrep.getById(id);
	mylang.langActive = isactive;
	langrep.update(mylang);
}
catch(Exception ex)
{
	//do nothing
}
%>