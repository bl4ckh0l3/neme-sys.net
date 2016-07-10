<%@ Page Language="C#" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="ErrorBody" TagName="insert" Src="~/public/layout/include/error.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	lang.set();
	login.acceptedRoles = "1,2";	
	bool logged = login.checkedUser();

	if(logged) {
		string redirectErrCode = Request["error_code"];
		string redirectField = "";
		string redirectValue = "";
		
		if(redirectErrCode=="001"){
			redirectField = "id_usr";
			redirectValue = "-1";
			if (!String.IsNullOrEmpty(Request["id_usr"])) {
				redirectValue = Request["id_usr"];
			}
		}else if(redirectErrCode=="018"){
			redirectField = "id_category";
			redirectValue = "-1";
			if (!String.IsNullOrEmpty(Request["id_category"])) {
				redirectValue = Request["id_category"];
			}
		}else if(redirectErrCode=="041"){
			redirectField = "id_mail";
			redirectValue = "-1";
			if (!String.IsNullOrEmpty(Request["id_mail"])) {
				redirectValue = Request["id_mail"];
			}
		}
					
		Response.Redirect("/backoffice/include/error.aspx?error_code="+HttpUtility.UrlEncode(redirectErrCode)+"&"+redirectField+"="+HttpUtility.UrlEncode(redirectValue));
	}
}
</script>
<ErrorBody:insert runat="server" />