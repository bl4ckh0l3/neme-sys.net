<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
private ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	lang.set();	
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	IMultiLanguageRepository langRepository = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
	
	if (!String.IsNullOrEmpty(Request["error_code"]))
	{
		string msg = Request["error_code"];
		try
		{
			if(!String.IsNullOrEmpty(langRepository.convertErrorCode(Request["error_code"])))
			{
				msg = lang.getTranslated(langRepository.convertErrorCode(Request["error_code"]));
				if(Request["error_code"]=="001")
				{
					string id_user = "-1";
					if (!String.IsNullOrEmpty(Request["id_usr"])) {
						id_user = Request["id_usr"];
					}
	
					msg+="&nbsp;&nbsp;<a href=/backoffice/users/insertuser.aspx?id="+id_user+">"+lang.getTranslated("portal.commons.errors.label.repeat_insert")+"</a>";
				}else if(Request["error_code"]=="018")
				{
					string id_category = "-1";
					if (!String.IsNullOrEmpty(Request["id_category"])) {
						id_category = Request["id_category"];
					}
	
					msg+="&nbsp;&nbsp;<a href=/backoffice/categories/insertcategory.aspx?id="+id_category+">"+lang.getTranslated("portal.commons.errors.label.repeat_insert")+"</a>";					
				}else if(Request["error_code"]=="041")
				{
					string id_mail = "-1";
					if (!String.IsNullOrEmpty(Request["id_mail"])) {
						id_mail = Request["id_mail"];
					}
	
					msg+="&nbsp;&nbsp;<a href=/backoffice/mails/inserttemplatemail.aspx?id="+id_mail+">"+lang.getTranslated("portal.commons.errors.label.repeat_insert")+"</a>";					
				}
			}
		}
		catch(Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		}
		message.Text = "<p><span class=error>"+msg+"</span></p>";
	}
}
</script>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<div id="backend-content">
			<div align="center" style="height:300px;padding-top:30px;">
			<span class="error-text">
			<h2><span id="error"><%=lang.getTranslated("portal.commons.errors.label.error")%></span></h2>
			<asp:Literal id="message" runat="server" /></span>
			</div>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
