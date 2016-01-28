<%@ Page Language="C#" AutoEventWireup="true" CodeFile="voucherlist.aspx.cs" Inherits="_VoucherList" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function deleteVoucher(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.voucher.lista.js.alert.delete_campaign")%>?")){
		ajaxDeleteItem(id_objref,"VoucherCampaign|IVoucherRepository",row,refreshrows);
	}
}  

function isNumerico(inputStr) {	
	for (var i = 0; i < inputStr.length; i++) {
		var oneChar = inputStr.substring(i, i + 1)
		if (oneChar < "0" || oneChar > "9") {
			return false;
		}
	}
	return true;
}

function isCharacterLowerCase(inputStr) {
	var oneChar = inputStr;
	if (oneChar < 97 || oneChar > 122) {
		return false;
	}
	return true;
}

//consente di digitare numeri e il punto
function isCorrectChar(e){
	var key = window.event ? e.keyCode : e.which;
	var keychar = String.fromCharCode(key);		
	if (isNumerico(keychar) || isCharacterLowerCase(key) || key==95 || keychar=="-"){					
		return true;
	}
	return false;
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
				<th colspan="13" align="left">
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
				  <th colspan="3">&nbsp;</th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.label")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.voucher_type")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.value")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.operation")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.activate")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.max_generation")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.max_usage")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.enable_date")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.expire_date")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.lista.table.header.exclude_prod_rule")%></th>
				</tr> 
					<%int counter = 0;				
					if(bolFoundLista){
						for(counter = fromVoucher; counter<= toVoucher;counter++){
						VoucherCampaign k = campaigns[counter];%>
						<form action="/backoffice/vouchers/insertvoucher.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">		
						</form> 
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=counter%>">        
							<td align="center" width="25"><a href="/backoffice/vouchers/viewvoucher.aspx?cssClass=<%=cssClass%>&id=<%=k.id%>"><img src="/backoffice/img/zoom.png" title="<%=lang.getTranslated("backend.voucher.lista.table.alt.view_voucher")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:document.form_lista_<%=counter%>.submit();"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.voucher.lista.table.alt.modify_voucher")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteVoucher(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.voucher.lista.table.alt.delete_voucher")%>" hspace="2" vspace="0" border="0"></a></td>						
							<td width="200">						
							<div class="ajax" id="view_label_<%=counter%>" onmouseover="javascript:showHide('view_label_<%=counter%>','edit_label_<%=counter%>','label_<%=counter%>',500, false);"><%=k.label%></div>
							<div class="ajax" id="edit_label_<%=counter%>"><input type="text" class="formfieldAjax" id="label_<%=counter%>" name="label" onmouseout="javascript:restoreField('edit_label_<%=counter%>','view_label_<%=counter%>','label_<%=counter%>','VoucherCampaign|IVoucherRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.label%>"></div>
							<script>                     
							$("#edit_label_<%=counter%>").hide();
							</script>
							</td>
							<td width="250">
							<%
							int caseSwitch = k.type;
							switch (caseSwitch)
							{							
								// valore fisso
								case 0:
									Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot"));
									break;
								case 1:
									Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_multiple_use"));
									break;
								case 2:
									Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_time"));
								break;
								case 3:
									Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_multiple_use_by_time"));
								break;
								case 4:
									Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_user"));
								break;
								default:
								break;
							}%>
							</td>
							<td width="100">
							<div class="ajax" id="view_voucherAmount_<%=counter%>" onmouseover="javascript:showHide('view_voucherAmount_<%=counter%>','edit_voucherAmount_<%=counter%>','voucherAmount_<%=counter%>',500, false);"><%=k.voucherAmount.ToString("#,###0.00")%></div>
							<div class="ajax" id="edit_voucherAmount_<%=counter%>"><input type="text" class="formfieldAjaxMedium3" id="voucherAmount_<%=counter%>" name="voucherAmount" onmouseout="javascript:restoreField('edit_voucherAmount_<%=counter%>','view_voucherAmount_<%=counter%>','voucherAmount_<%=counter%>','VoucherCampaign|IVoucherRepository|decimal',<%=k.id%>,1,<%=counter%>);" value="<%=k.voucherAmount.ToString("#,###0.00")%>" onkeypress="javascript:return isDouble(event);"></div>
							<script>
							$("#edit_voucherAmount_<%=counter%>").hide();
							</script>
							</td>
							<td width="135">
							<div class="ajax" id="view_operation_<%=counter%>" onmouseover="javascript:showHide('view_operation_<%=counter%>','edit_operation_<%=counter%>','operation_<%=counter%>',500, true);">
							<%
							if(k.operation==0){
								Response.Write(lang.getTranslated("backend.voucher.lista.operation.label.percentage"));
							}else if(k.operation==1){
								Response.Write(lang.getTranslated("backend.voucher.lista.operation.label.fixed"));
							}%>
							</div>
							<div class="ajax" id="edit_operation_<%=counter%>">
							<select name="operation" class="formfieldAjaxSelect" id="operation_<%=counter%>" onblur="javascript:updateField('edit_operation_<%=counter%>','view_operation_<%=counter%>','operation_<%=counter%>','VoucherCampaign|IVoucherRepository|int',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (k.operation==0) { Response.Write("selected");}%>><%=lang.getTranslated("backend.voucher.lista.operation.label.percentage")%></OPTION>
							<OPTION VALUE="1" <%if (k.operation==1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.voucher.lista.operation.label.fixed")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_operation_<%=counter%>").hide();
							</script>
							</td>
							<td width="50">
							<div class="ajax" id="view_active_<%=counter%>" onmouseover="javascript:showHide('view_active_<%=counter%>','edit_active_<%=counter%>','active_<%=counter%>',500, true);">
							<%
							if(!k.active){
								Response.Write(lang.getTranslated("backend.commons.no"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}%>
							</div>
							<div class="ajax" id="edit_active_<%=counter%>">
							<select name="active" class="formfieldAjaxSelect" id="active_<%=counter%>" onblur="javascript:updateField('edit_active_<%=counter%>','view_active_<%=counter%>','active_<%=counter%>','VoucherCampaign|IVoucherRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_active_<%=counter%>").hide();
							</script>
							</td>
							<td width="80">
							<%if(k.maxGeneration==-1){
								Response.Write(lang.getTranslated("backend.voucher.label.unlimited"));
							}else{
								Response.Write(k.maxGeneration);
							}%></td>
							<td width="80">
							<%if(k.maxUsage==-1){
								Response.Write(lang.getTranslated("backend.voucher.label.unlimited"));
							}else{
								Response.Write(k.maxUsage);
							}%></td>
							<td width="120">
							<%string aDate = k.enableDate.ToString("dd/MM/yyyy HH:mm");
							if("31/12/9999 23:59".Equals(aDate)){
								aDate = "";
							}
							Response.Write(aDate);%></td>
							<td width="120">
							<%string eDate = k.expireDate.ToString("dd/MM/yyyy HH:mm");
							if("31/12/9999 23:59".Equals(eDate)){
								eDate = "";
							}
							Response.Write(eDate);%></td>
							<td width="80">
							<div class="ajax" id="view_excludeProdRule_<%=counter%>" onmouseover="javascript:showHide('view_excludeProdRule_<%=counter%>','edit_excludeProdRule_<%=counter%>','excludeProdRule_<%=counter%>',500, true);">
							<%
							if(!k.excludeProdRule){
								Response.Write(lang.getTranslated("backend.commons.no"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}%>
							</div>
							<div class="ajax" id="edit_excludeProdRule_<%=counter%>">
							<select name="excludeProdRule" class="formfieldAjaxSelect" id="excludeProdRule_<%=counter%>" onblur="javascript:updateField('edit_excludeProdRule_<%=counter%>','view_excludeProdRule_<%=counter%>','excludeProdRule_<%=counter%>','VoucherCampaign|IVoucherRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (!k.excludeProdRule) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.excludeProdRule) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_excludeProdRule_<%=counter%>").hide();
							</script>
							</td>							
						</tr>		
						<%}
					}%>	
				<tr> 
				<th colspan="13" align="left">
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
		<form action="/backoffice/vouchers/insertvoucher.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.voucher.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />	
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>