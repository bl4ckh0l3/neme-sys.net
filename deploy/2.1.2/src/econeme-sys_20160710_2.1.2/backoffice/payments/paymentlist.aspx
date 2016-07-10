<%@ Page Language="C#" AutoEventWireup="true" CodeFile="paymentlist.aspx.cs" Inherits="_PaymentList" Debug="false" ValidateRequest="false"%>
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
function deletePayment(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.payment.lista.js.alert.delete_payment")%>?")){
		ajaxDeleteItem(id_objref,"Payment|IPaymentRepository",row,refreshrows);
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
				  <th><%=lang.getTranslated("backend.payment.lista.table.header.descrizione_payment").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.payment.lista.table.header.active").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.payment.lista.table.header.payment_type").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.payment.lista.table.header.url").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.payment.lista.table.header.apply_to").ToUpper()%></th>
              </tr> 
				<%						
					int counter = 0;				
					if(bolFoundLista){
						for(counter = fromPayment; counter<= toPayment;counter++){
						Payment k = payments[counter];%>
						<form action="/backoffice/payments/insertpayment.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">		
						</form> 
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=counter%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_<%=counter%>.submit();"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.payment.lista.table.alt.modify_payment")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deletePayment(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.payment.lista.table.alt.delete_payment")%>" hspace="2" vspace="0" border="0"></a></td>						
							<td width="250">						
							<div class="ajax" id="view_description_<%=counter%>" onmouseover="javascript:showHide('view_description_<%=counter%>','edit_description_<%=counter%>','description_<%=counter%>',500, false);"><%=k.description%></div>
							<div class="ajax" id="edit_description_<%=counter%>"><input type="text" class="formfieldAjax" id="description_<%=counter%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=counter%>','view_description_<%=counter%>','description_<%=counter%>','Payment|IPaymentRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.description%>"></div>
							<script>
							$("#edit_description_<%=counter%>").hide();
							</script>
							</td>
							<td width="8%">
							<div class="ajax" id="view_active_<%=counter%>" onmouseover="javascript:showHide('view_active_<%=counter%>','edit_active_<%=counter%>','active_<%=counter%>',500, true);">
							<%
							if(k.isActive){
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_active_<%=counter%>">
							<select name="isActive" class="formfieldAjaxSelect" id="active_<%=counter%>" onblur="javascript:updateField('edit_active_<%=counter%>','view_active_<%=counter%>','active_<%=counter%>','Payment|IPaymentRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_active_<%=counter%>").hide();
							</script>
							</td>
							<td width="200"><%
							if(k.paymentType==0){
								Response.Write(lang.getTranslated("backend.payment.label.no_charge"));
							}else if(k.paymentType==1){
								Response.Write(lang.getTranslated("backend.payment.label.direct_payment"));
							}%></td>
							<td><%if(k.hasExternalUrl){Response.Write(lang.getTranslated("backend.commons.yes"));}else{Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
							<td style="min-width:250px;">
							<div class="ajax" id="view_applyto_<%=counter%>" onmouseover="javascript:showHide('view_applyto_<%=counter%>','edit_applyto_<%=counter%>','applyto_<%=counter%>',500, true);">
							<%
							if(k.applyTo==0){
								Response.Write(lang.getTranslated("backend.payment.lista.table.applyto_front"));
							}else if(k.applyTo==1){
								Response.Write(lang.getTranslated("backend.payment.lista.table.applyto_back"));
							}else if(k.applyTo==2){
								Response.Write(lang.getTranslated("backend.payment.lista.table.applyto_both"));
							}%>
							</div>
							<div class="ajax" id="edit_applyto_<%=counter%>">
							<select name="applyTo" class="formfieldAjaxSelect" id="applyto_<%=counter%>" onblur="javascript:updateField('edit_applyto_<%=counter%>','view_applyto_<%=counter%>','applyto_<%=counter%>','Payment|IPaymentRepository|int',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (k.applyTo==0) { Response.Write("selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_front")%></OPTION>
							<OPTION VALUE="1" <%if (k.applyTo==1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_back")%></OPTION>
							<OPTION VALUE="2" <%if (k.applyTo==2) { Response.Write("selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_both")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_applyto_<%=counter%>").hide();
							</script>
							</td>
						</tr>		
						<%}
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
		<form action="/backoffice/payments/insertpayment.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.payment.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />	
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>