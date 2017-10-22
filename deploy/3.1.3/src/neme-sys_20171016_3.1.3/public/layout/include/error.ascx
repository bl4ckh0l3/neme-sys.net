<%@ control Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/common/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	lang.set();	
	
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
	
					msg+="&nbsp;&nbsp;<a href="+CommonService.getBaseUrl(Request.Url.ToString(),1).ToString()+"area_user/account.aspx?id="+id_user+">"+lang.getTranslated("portal.commons.errors.label.repeat_insert")+"</a>";
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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />
	<div id="container">	
		<div id="content-center" style="width:100%;">
			<div align="center">
			<h2><span id="error"><%=lang.getTranslated("portal.commons.errors.label.error")%></span></h2>
			<asp:Literal id="message" runat="server" />
			</div>
		</div>
		<div id="menu-right"></div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
