<%@ Page Language="C#" AutoEventWireup="true" CodeFile="currencylist.aspx.cs" Inherits="_CurrencyList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="System.Globalization" %>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function deleteCurrency(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.currency.lista.js.alert.delete_currency")%>?")){
		ajaxDeleteItem(id_objref,"Currency|ICurrencyRepository",row,refreshrows);
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
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
				<th colspan="8" align="left">
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
				  <th colspan="2">&nbsp;</th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.descrizione").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.valore").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.abilitato").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.default").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.dta_riferimento").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.currency.lista.table.header.dta_inserimento").ToUpper()%></th>
              </tr> 
				<%						
					int counter = 0;				
					if(bolFoundLista){
						foreach (Currency k in currencies){%>
						<form action="/backoffice/currency/insertcurrency.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">		
						</form> 
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=counter%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_<%=counter%>.submit();"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.currency.lista.table.alt.modify_currency")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25">
								<%if(!k.isDefault) {%>
								<a href="javascript:deleteCurrency(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.currency.lista.table.alt.delete_currency")%>" hspace="2" vspace="0" border="0"></a>
								<%}%>
							</td>						
							<td><b><%=k.currency%></b>&nbsp;<%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.keyword.label."+k.currency))) { Response.Write("("+lang.getTranslated("backend.currency.keyword.label."+k.currency)+")");}%></td>
							<td><%=k.rate.ToString()%></td><%//=k.rate.ToString("0.0000", CultureInfo.InvariantCulture)%>
							<td width="8%">
							<div class="ajax" id="view_active_<%=counter%>" onmouseover="javascript:showHide('view_active_<%=counter%>','edit_active_<%=counter%>','active_<%=counter%>',500, true);">
							<%
							if(k.active){
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_active_<%=counter%>">
							<select name="active" class="formfieldAjaxSelect" id="active_<%=counter%>" onblur="javascript:updateField('edit_active_<%=counter%>','view_active_<%=counter%>','active_<%=counter%>','Currency|ICurrencyRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_active_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<%
							if(!k.isDefault){
								Response.Write(lang.getTranslated("backend.commons.no"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}%>
							</td>
							<td><%=k.referDate.ToString("dd/MM/yyyy")%></td>
							<td><%=k.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
						</tr>		
							<%
							counter++;
						}
					}%>	
				<tr> 
				<th colspan="8" align="left">
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
		<form action="/backoffice/currency/insertcurrency.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.currency.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />	

		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.currency.lista.button.label.aggiorna")%>" onclick="javascript:location.href='/backoffice/currency/refreshcurrency.aspx';" />
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>