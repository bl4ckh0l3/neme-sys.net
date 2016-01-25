<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertnewsletter.aspx.cs" Inherits="_Newsletter" Debug="false" ValidateRequest="false"%>
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
<%@ Reference Control="~/backoffice/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertNewsletter(){
	
	if(document.form_inserisci.description.value == ""){
		alert("<%=lang.getTranslated("backend.newsletters.detail.js.alert.insert_newsletter_value")%>");
		document.form_inserisci.reset();
		document.form_inserisci.description.focus();
		return;
	}
		
	document.form_inserisci.submit()
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.description.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<form action="/backoffice/newsletter/insertnewsletter.aspx" method="post" name="form_inserisci">
		<input type="hidden" value="<%=newsletter.id%>" name="id">
		<input type="hidden" value="insert" name="operation">
<!--nsys-nwsletins2-->
<!---nsys-nwsletins2-->
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
			<tr>
			<td>
			<div style="float:left;padding-right:20px;">
			<span class="labelForm"><%=lang.getTranslated("backend.newsletters.detail.table.label.descrizione")%></span><br>
			  <input type="text" name="description" value="<%=newsletter.description%>" class="formFieldTXT">
			</div>
			<div style="display:block;">		
			  <span class="labelForm"><%=lang.getTranslated("backend.newsletter.detail.table.header.newsletter_stato")%></span><br>
				<select name="active" class="formFieldTXT">
				<option value="0"<%if (!newsletter.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.newsletter.lista.table.label.inactive")%></option>	
				<option value="1"<%if (newsletter.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.newsletter.lista.table.label.active")%></option>	
				</SELECT>		  
			</div>
			<div style="display:block; text-align:left;margin-top:20px;margin-bottom:20px;"> 
			  <span class="labelForm"><%=lang.getTranslated("backend.newsletter.detail.table.header.newsletter_template")%></span><br>
				<select name="templateid" class="formFieldTXT">		  
				<%foreach(MailMsg msg in templates){%>					
				<option value="<%=msg.id%>"<%if (msg.id==newsletter.templateId) { Response.Write(" selected");}%>><%=msg.name%></option>	
				<%}%>
				</SELECT>		  
			 </div>
<!--nsys-nwsletins3-->
			<div style="display:block; text-align:left;margin-top:20px;margin-bottom:20px;"> 
			  <span class="labelForm"><%=lang.getTranslated("backend.newsletter.detail.table.header.voucher_campaign")%></span><br>
				<select name="voucherid" class="formFieldTXT">		  
				  <option value=""></option>
				  <%if(hasVoucherCampaign){
					foreach(VoucherCampaign g in voucherCampaigns){%>
					<option value="<%=g.id%>" <%if(g.id==newsletter.idVoucherCampaign){Response.Write(" selected");}%>><%=g.label%></option>
					<%}
				  }%>
				</SELECT>	  
			 </div>
<!---nsys-nwsletins3-->
			</td>
			</tr>
		</table>		
			<br/>				
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.newsletter.detail.button.inserisci.label")%>" onclick="javascript:insertNewsletter();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/newsletter/newsletterlist.aspx?cssClass=<%=cssClass%>';" />
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>