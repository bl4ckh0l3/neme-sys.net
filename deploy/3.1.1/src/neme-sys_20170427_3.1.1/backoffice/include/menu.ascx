<%@control Language="c#" description="backend-menu"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
private ASP.BoMultiLanguageControl lang;
private ASP.UserLoginControl login;
private string cssClass;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	cssClass = Request["cssClass"];
}
</script>
<div id="backend-menu-left-container">
  <div id="backend-menu-left" style="<%if(Session["menu_closed"]!=null&&Convert.ToBoolean(Session["menu_closed"])){Response.Write("display:none;");}%>">
    <%if(login.userLogged.role.isAdmin() || login.userLogged.role.isEditor()) {%>		
    <ul>
      <li><a href="/backoffice/contents/insertcontent.aspx?id=-1&cssClass=LN"><img src="/backoffice/img/page_white_edit.png" border="0" title="<%=lang.getTranslated("backend.menu.item.contenuti.inserisci")%>"/></a></li>
      <li><a href="/backoffice/contents/contentlist.aspx?cssClass=LN&resetMenu=1" class="<%if(String.Compare(cssClass, "LN") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.contenuti.lista")%>"><%=lang.getTranslated("backend.menu.item.contenuti")%></a></li>
    </ul>		
    <ul>
      <li><a href="/backoffice/newsletter/insertnewsletter.aspx?cssClass=LNL&id=-1"><img src="/backoffice/img/newsletter_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.newsletter.inserisci")%>"/></a></li>
      <li><a href="/backoffice/newsletter/newsletterlist.aspx?cssClass=LNL" class="<%if(String.Compare(cssClass, "LNL") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.newsletter.lista")%>"><%=lang.getTranslated("backend.menu.item.newsletter")%></a></li>
    </ul>			
    <%}
    if(login.userLogged.role.isAdmin()) {%>
    <ul>		
      <li><a href="/backoffice/users/insertuser.aspx?cssClass=LU&id=-1"><img src="/backoffice/img/user_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.utenti.inserisci")%>"/></a></li>
      <li><a href="/backoffice/users/userlist.aspx?cssClass=LU&resetMenu=1" class="<%if(String.Compare(cssClass, "LU") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.utenti.lista")%>"><%=lang.getTranslated("backend.menu.item.utenti")%></a></li>
    </ul>		
    <!--<ul>		
      <li><a href="/backoffice/targets/InserisciTarget.aspx?cssClass=LT&id_target=-1"><img src="/backoffice/img/link_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.target.inserisci")%>"/></a></li>
      <li><a href="/backoffice/targets/ListaTarget.aspx?cssClass=LT" class="<%if(String.Compare(cssClass, "LT") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.target.lista")%>"><%=lang.getTranslated("backend.menu.item.target")%></a></li>
    </ul>-->		
    <ul>		
      <li><a href="/backoffice/categories/insertcategory.aspx?cssClass=LCE&id=-1"><img src="/backoffice/img/folder_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.categorie.inserisci")%>"/></a></li>
      <li><a href="/backoffice/categories/categorylist.aspx?cssClass=LCE&resetMenu=1" class="<%if(String.Compare(cssClass, "LCE") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.categorie.lista")%>"><%=lang.getTranslated("backend.menu.item.categorie")%></a></li>
    </ul>		
    <ul>		
      <li><a href="/backoffice/templates/templatelist.aspx?cssClass=LTP"><img src="/backoffice/img/layout_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.templates.inserisci")%>"/></a></li>
      <li><a href="/backoffice/templates/templatelist.aspx?cssClass=LTP" class="<%if(String.Compare(cssClass, "LTP") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.templates.lista")%>"><%=lang.getTranslated("backend.menu.item.templates")%></a></li>
    </ul>		
    <ul>		
      <li><a href="/backoffice/mails/inserttemplatemail.aspx?cssClass=LMT&id=-1"><img src="/backoffice/img/script_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.mails.inserisci")%>"/></a></li>
      <li><a href="/backoffice/mails/mailtemplatelist.aspx?cssClass=LMT&resetMenu=1" class="<%if(String.Compare(cssClass, "LMT") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.mails.lista")%>"><%=lang.getTranslated("backend.menu.item.mails")%></a></li>
    </ul>	
    <ul>		
      <li><a href="/backoffice/countries/insertcountry.aspx?id=-1&cssClass=LCT"><img src="/backoffice/img/world_add.png" border="0" title="<%=lang.getTranslated("backend.menu.item.country.inserisci")%>"/></a></li>
      <li><a href="/backoffice/countries/countrylist.aspx?cssClass=LCT&resetMenu=1" class="<%if(String.Compare(cssClass, "LCT") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.country.lista")%>"><%=lang.getTranslated("backend.menu.item.country")%></a></li>
    </ul>		
    <ul>		
      <li><img src="/backoffice/img/spacer.png" border="0"/></li>
      <li><a href="/backoffice/languages/languagelist.aspx?cssClass=IL" class="<%if(String.Compare(cssClass, "IL") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.language.lista")%>"><%=lang.getTranslated("backend.menu.item.language")%></a></li>
    </ul>			
    <%}
    if(login.userLogged.role.isAdmin()) {%>
    <ul>		
      <li><img src="/backoffice/img/spacer.png" border="0"/></li>
      <li><a href="/backoffice/multilanguages/multilanguagelist.aspx?cssClass=IML&resetMenu=1" class="<%if(String.Compare(cssClass, "IML") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.multi_language.lista")%>"><%=lang.getTranslated("backend.menu.item.multi_language")%></a></li>
    </ul>			
    <%}
    if(login.userLogged.role.isAdmin()) {%>
    <ul>				
      <li><img src="/backoffice/img/spacer.png" border="0"/></li>
      <li><a href="/backoffice/configuration/configuration.aspx?cssClass=CP" class="<%if(String.Compare(cssClass, "CP") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.config_portal.lista")%>"><%=lang.getTranslated("backend.menu.item.config_portal")%></a></li>
    </ul>		
    <ul>		
      <li><img src="/backoffice/img/spacer.png" border="0"/></li>
      <li><a href="/backoffice/logs/loglist.aspx?cssClass=LL&resetMenu=1" class="<%if(String.Compare(cssClass, "LL") == 0) { Response.Write("active");}%>" title="<%=lang.getTranslated("backend.menu.item.logs_portal.lista")%>"><%=lang.getTranslated("backend.menu.item.logs_portal")%></a></li>
    </ul>		
    <%}%>
    <br/>	
<!--nsys-editinc1--><!---nsys-editinc1-->
  </div>
  <div id="backend-menu-left-hide">
  <img src="/backoffice/img/close_corner.png" border="0" id="close_corner" align="absmiddle"/>
  </div>
</div>
<script>
function setCloseMenu(closed){
	var query_string = "menu_closed="+closed;

	$.ajax({
	   type: "POST",
	   url: "/backoffice/include/menu_closed.aspx",
	   data: query_string,
		success: function(response) {
		//alert(response);
		},
		error: function() {
			//alert("error");
		}
	 });
}

$('#close_corner').click(function() {
	var element = document.getElementById("backend-menu-left");
	var closed; 
	if(element.style.display == 'none'){
		$('#backend-menu-left').show('slow');
		closed = 0;
	}else{
		$('#backend-menu-left').hide('slow');
		closed = 1;
	}
    //alert(closed);
	setCloseMenu(closed);
});
</script>
