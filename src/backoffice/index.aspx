<%@ Page Language="C#" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
private ASP.BoMultiLanguageControl lang;
private ASP.UserLoginControl login;
protected string secureURL;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	
	secureURL = Utils.getBaseUrl(Request.Url.ToString(),1).ToString();
	
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		Response.Redirect(secureURL+"login.aspx?error_code=002");
	}
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<SCRIPT type=text/javascript>
$(function() {
     $('img[data-hover]').hover(function() {
         $(this).attr('tmp', $(this).attr('src')).attr('src', $(this).attr('data-hover')).attr('data-hover', $(this).attr('tmp')).removeAttr('tmp');
     }).each(function() {
         $('<img />').attr('src', $(this).attr('data-hover'));
     });
}); 
</SCRIPT>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />	
		<div id="backend-content-home" align="center">
			<div align="center">
				<strong id="init"><br><br><lang:getTranslated keyword="backend.index.detail.table.label.editor_contents" runat="server" /><br><br></strong>
				<%if(login.userLogged.role.isAdmin() || login.userLogged.role.isEditor()) {%>
				<a href="<%=secureURL%>backoffice/contents/contentlist.aspx?cssClass=LN&resetMenu=1" title="<%=lang.getTranslated("backend.menu.item.contenuti.lista")%>"><IMG height="120" alt="<%=lang.getTranslated("backend.menu.item.contenuti")%>" src="/backoffice/img/home/ico-contenuti.jpg" data-hover="/backoffice/img/home/ico-active-contenuti.jpg" width="100" border="0" vspace="3" hspace="2"></a>
				<%}
    			if(login.userLogged.role.isAdmin()) {%>
				<a href="<%=secureURL%>backoffice/users/userlist.aspx?cssClass=LU" title="<%=lang.getTranslated("backend.menu.item.utenti.lista")%>"><IMG height="120" alt="<%=lang.getTranslated("backend.menu.item.utenti")%>" src="/backoffice/img/home/ico-utenti.jpg" data-hover="/backoffice/img/home/ico-active-utenti.jpg" width="100" border="0" vspace="3"></a>
				<a href="<%=secureURL%>backoffice/categories/categorylist.aspx?cssClass=LCE" title="<%=lang.getTranslated("backend.menu.item.categorie.lista")%>"><IMG height="120" alt="<%=lang.getTranslated("backend.menu.item.categorie")%>" src="/backoffice/img/home/ico-struttura.jpg" data-hover="/backoffice/img/home/ico-active-struttura.jpg" width="100" border="0" vspace="3" hspace="2"></a><br/>
				<a href="<%=secureURL%>backoffice/templates/templatelist.aspx?cssClass=LTP" title="<%=lang.getTranslated("backend.menu.item.templates.lista")%>"><IMG height="120" alt="<%=lang.getTranslated("backend.menu.item.templates")%>" src="/backoffice/img/home/ico-grafica.jpg" data-hover="/backoffice/img/home/ico-active-grafica.jpg" width="100" border="0" hspace="2"></a>
				<%}
    			if(login.userLogged.role.isAdmin()) {%>
				<a href="<%=secureURL%>backoffice/multilanguages/multilanguagelist.aspx?cssClass=IML&resetMenu=1" title="<%=lang.getTranslated("backend.menu.item.multi_language.lista")%>"><IMG height="120" alt="<%=lang.getTranslated("backend.menu.item.multi_language")%>" src="/backoffice/img/home/ico-multilingua.jpg" data-hover="/backoffice/img/home/ico-active-multilingua.jpg" width="100" border="0"></a><br/><br/>
				<%}%>
				<div><strong><lang:getTranslated keyword="backend.index.detail.table.label.download_guide" runat="server" /></strong>&nbsp;<!--nsys-bohome1--><a class="link-down-guide" target="_blank" href="http://www.neme-sys.it/public/utils/econeme-sys_guide.pdf"><!---nsys-bohome1--><lang:getTranslated keyword="backend.index.detail.table.label.download_guide_click" runat="server" /></a></div>
			</div>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>