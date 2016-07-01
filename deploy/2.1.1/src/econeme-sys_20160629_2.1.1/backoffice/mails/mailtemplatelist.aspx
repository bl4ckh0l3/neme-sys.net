<%@ Page Language="C#" AutoEventWireup="true" CodeFile="mailtemplatelist.aspx.cs" Inherits="_MailList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
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
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/backoffice/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function editMail(idMail){
	location.href='/backoffice/mails/inserttemplatemail.aspx?cssClass=LMT&id='+idMail;
}

function deleteMail(id_objref, row, refreshrows){
	if(confirm("<%=lang.getTranslated("backend.mail.lista.js.alert.delete_category")%>?")){		
		ajaxDeleteItem(id_objref,"MailMsg|IMailRepository",row, refreshrows);
	}
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<div style="padding-bottom:5px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" accept-charset="UTF-8">
			<input type="hidden" value="1" name="page">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			<input type="submit" value="<%=lang.getTranslated("backend.mail.lista.label.search")%>" class="buttonForm" hspace="4">
			<select name="search_key" class="formfieldSelect">
			<option value=""></option>
			<%
			foreach(MailCategory mc in mcl){%>
				<OPTION VALUE="<%=mc.name%>" <%if (mc.name==search_key) { Response.Write("selected");}%>><%=mc.name%></OPTION>
			<%}%>
			</SELECT>	
			</form>
			</div>
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
				<th colspan="9" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
				</div>
				</th>
		      	</tr>
			    <tr> 
				<th colspan="2">&nbsp;</td>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.name" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.category" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.lang_code" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.active" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.body_html" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.base" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.mails.lista.table.header.last_modify" runat="server" /></th>
			    </tr>
				<%
				int counter = 0;				
				if(bolFoundLista){
					foreach (MailMsg k in mails){%>	
							<tr id="tr_delete_list_<%=counter%>" class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:editMail(<%=k.id%>);"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.mails.lista.table.alt.modify_mail")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:<%if(k.isBase){%>alert('<%=lang.getTranslated("backend.mails.lista.table.alt.cannot_delete")%>');<%}else{%>deleteMail(<%=k.id%>,'tr_delete_list_<%=counter%>','tr_delete_list_');<%}%>"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.mails.lista.table.alt.delete_mail")%>" hspace="2" vspace="0" border="0"></a></td>
							<td><%=k.name%></td>
							<td width="17%"><%if(k.mailCategory!=null){Response.Write(k.mailCategory.name);}%></td>
							<td><%=k.langCode%></td>
							<td>
							<div class="ajax" id="view_active_<%=counter%>" onmouseover="javascript:showHide('view_active_<%=counter%>','edit_active_<%=counter%>','active_<%=counter%>',500, true);">
							<%
							if (k.isActive) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{ 
								Response.Write(lang.getTranslated("backend.commons.no"));
							}
							%>
							</div>
							<div class="ajax" id="edit_active_<%=counter%>">
							<select name="isActive" class="formfieldAjaxSelect" id="active_<%=counter%>" onblur="javascript:updateField('edit_active_<%=counter%>','view_active_<%=counter%>','active_<%=counter%>','MailMsg|IMailRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_active_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<div class="ajax" id="view_body_html_<%=counter%>" onmouseover="javascript:showHide('view_body_html_<%=counter%>','edit_body_html_<%=counter%>','body_html_<%=counter%>',500, true);">
							<%if(k.isBodyHTML) {
								 Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.no"));
							}
							%>
							</div>
							<div class="ajax" id="edit_body_html_<%=counter%>">
							<select name="isBodyHTML" class="formfieldAjaxSelect" id="body_html_<%=counter%>" onblur="javascript:updateField('edit_body_html_<%=counter%>','view_body_html_<%=counter%>','body_html_<%=counter%>','MailMsg|IMailRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.isBodyHTML) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.isBodyHTML) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_body_html_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<%if(k.isBase) {
								 Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.no"));
							}
							%>
							</td>	
							<td>
							<%=k.modifyDate.ToString("dd/MM/yyyy HH:mm")%>
							</td>								
							</tr>			
						<%
						counter++;
					}
				}%>	  

				<tr> 
				<th colspan="9" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
				</div>
				</th>
		      	</tr>
			</table>
			<br/>
			
			<form action="/backoffice/mails/inserttemplatemail.aspx" method="post" name="form_crea">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			<input type="hidden" value="-1" name="id">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.mails.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
			</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>