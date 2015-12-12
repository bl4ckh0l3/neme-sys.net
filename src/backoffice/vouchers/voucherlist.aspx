<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deleteVoucherCampaign(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.voucher.lista.js.alert.delete_campaign")%>?")){
		ajaxDeleteItem(id_objref,"voucher",row,refreshrows);
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
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LVC"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		      <tr> 
			<th colspan="3">&nbsp;</th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.label"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.voucher_type"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.value"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.operation"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.activate"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.max_generation"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.max_usage"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.enable_date"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.expire_date"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.lista.table.header.exclude_prod_rule"))%></th>
		      </tr> 
				<%
				Dim hasVoucher
				hasVoucher = false
				on error Resume Next
				Set objListaVoucher = objVoucher.getCampaignList(null,null)
				
				if(objListaVoucher.Count > 0) then
					hasVoucher = true
				end if
					
				if Err.number <> 0 then
					hasVoucher = false
				end if	
				
				if(hasVoucher) then				
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpVoucher, objTmpVoucherKey, FromVoucher, ToVoucher, Diff
					iIndex = objListaVoucher.Count
					FromVoucher = ((numPage * itemsXpage) - itemsXpage)
					Diff = (iIndex - ((numPage * itemsXpage)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToVoucher = iIndex - Diff
					
					totPages = iIndex\itemsXpage
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
						totPages = totPages +1	
					end if		
					
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"
											
					objTmpVoucher = objListaVoucher.Items
					objTmpVoucherKey=objListaVoucher.Keys		
					for newsCounter = FromVoucher to ToVoucher
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
					<form action="<%=Application("baseroot") & "/editor/voucher/InserisciVoucher.asp"%>" method="post" name="form_lista_<%=intCount%>">
					<input type="hidden" value="<%=objTmpVoucherKey(newsCounter)%>" name="id_voucher">
					<input type="hidden" value="LVC" name="cssClass">
					</form>	
					<tr class="<%=styleRow%>" id="tr_delete_list_<%=intCount%>">
						<%
						Set objTmpVoucher0 = objTmpVoucher(newsCounter)
						%>
						<td align="center" width="25"><a href="<%=Application("baseroot") & "/editor/voucher/VisualizzaVoucher.asp?cssClass=LVC&id_voucher=" & objTmpVoucherKey(newsCounter)%>"><img src="<%=Application("baseroot")&"/editor/img/zoom.png"%>" alt="<%=langEditor.getTranslated("backend.voucher.lista.table.alt.view_voucher")%>" hspace="2" vspace="0" border="0"></a></td>						
						<td align="center" width="25"><a href="javascript:document.form_lista_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.voucher.lista.table.alt.modify_voucher")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteVoucherCampaign(<%=objTmpVoucherKey(newsCounter)%>, 'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.voucher.lista.table.alt.delete_voucher")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="13%">				
						<div class="ajax" id="view_label_<%=intCount%>" onmouseover="javascript:showHide('view_label_<%=intCount%>','edit_label_<%=intCount%>','label_<%=intCount%>',500, false);"><%=objTmpVoucher0.getLabel()%></div>
						<div class="ajax" id="edit_label_<%=intCount%>"><input type="text" class="formfieldAjax" id="label_<%=intCount%>" name="label" onmouseout="javascript:restoreField('edit_label_<%=intCount%>','view_label_<%=intCount%>','label_<%=intCount%>','voucher',<%=objTmpVoucher0.getID()%>,1,<%=intCount%>);" value="<%=objTmpVoucher0.getLabel()%>"></div>
						<script>
						$("#edit_label_<%=intCount%>").hide();
						</script>
						</td>
						<td width="13%">
						<%
						Select Case objTmpVoucher0.getVoucherType()
						Case 0
							response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot"))
						Case 1
							response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use"))
						Case 2
							response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_time"))
						Case 3
							response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use_by_time"))
						Case 4
							response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_user"))
						Case Else
						End Select%>
						</td>
						<td width="80">				
						<div class="ajax" id="view_valore_<%=intCount%>" onmouseover="javascript:showHide('view_valore_<%=intCount%>','edit_valore_<%=intCount%>','valore_<%=intCount%>',500, false);"><%=objTmpVoucher0.getValore()%></div>
						<div class="ajax" id="edit_valore_<%=intCount%>"><input type="text" class="formfieldAjaxMedium" id="valore_<%=intCount%>" name="valore" onmouseout="javascript:restoreField('edit_valore_<%=intCount%>','view_valore_<%=intCount%>','valore_<%=intCount%>','voucher',<%=objTmpVoucher0.getID()%>,1,<%=intCount%>);" value="<%=objTmpVoucher0.getValore()%>" onkeypress="javascript:return isDouble(event);"></div>
						<script>
						$("#edit_valore_<%=intCount%>").hide();
						</script>
						</td>
						<td width="125">
						<div class="ajax" id="view_operation_<%=intCount%>" onmouseover="javascript:showHide('view_operation_<%=intCount%>','edit_operation_<%=intCount%>','operation_<%=intCount%>',500, true);">
						<%
						Select Case objTmpVoucher0.getOperation()
						Case 0
							response.write(langEditor.getTranslated("backend.voucher.lista.operation.label.percentage"))
						Case 1
							response.write(langEditor.getTranslated("backend.voucher.lista.operation.label.fixed"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_operation_<%=intCount%>">
							<select name="operation" class="formfieldAjaxSelect" id="operation_<%=intCount%>" onblur="javascript:updateField('edit_operation_<%=intCount%>','view_operation_<%=intCount%>','operation_<%=intCount%>','voucher',<%=objTmpVoucher0.getID()%>,2,<%=intCount%>);">
							<option value="0"<%if ("0"=objTmpVoucher0.getOperation()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.operation.label.percentage")%></option>	
							<option value="1"<%if ("1"=objTmpVoucher0.getOperation()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.operation.label.fixed")%></option>
							</SELECT>						
						</div>
						<script>
						$("#edit_operation_<%=intCount%>").hide();
						</script>
						</td>
						<td width="50">
						<div class="ajax" id="view_activate_<%=intCount%>" onmouseover="javascript:showHide('view_activate_<%=intCount%>','edit_activate_<%=intCount%>','activate_<%=intCount%>',500, true);">
						<%
						Select Case objTmpVoucher0.getActivate()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_activate_<%=intCount%>">
							<select name="activate" class="formFieldTXTShort" id="activate_<%=intCount%>" onblur="javascript:updateField('edit_activate_<%=intCount%>','view_activate_<%=intCount%>','activate_<%=intCount%>','voucher',<%=objTmpVoucher0.getID()%>,2,<%=intCount%>);">
							<option value="0"<%if ("0"=objTmpVoucher0.getActivate()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
							<option value="1"<%if ("1"=objTmpVoucher0.getActivate()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
							</SELECT>						
						</div>
						<script>
						$("#edit_activate_<%=intCount%>").hide();
						</script>
						</td>
						<td width="150"><%
						if(objTmpVoucher0.getMaxGeneration()="-1")then
							response.write(langEditor.getTranslated("backend.voucher.label.unlimited"))
						else
							response.write(objTmpVoucher0.getMaxGeneration())
						end if
						%></td>
						<td width="120"><%
						if(objTmpVoucher0.getMaxUsage()="-1")then
							response.write(langEditor.getTranslated("backend.voucher.label.unlimited"))
						else
							response.write(objTmpVoucher0.getMaxUsage())
						end if
						%></td>
						<td width="130"><%
						if(objTmpVoucher0.getEnableDate()<>"")then
							response.write(FormatDateTime(objTmpVoucher0.getEnableDate(),2)&" "&FormatDateTime(objTmpVoucher0.getEnableDate(),vbshorttime))
						end if
						%></td>
						<td width="120"><%
						if(objTmpVoucher0.getExpireDate()<>"")then
							response.write(FormatDateTime(objTmpVoucher0.getExpireDate(),2)&" "&FormatDateTime(objTmpVoucher0.getExpireDate(),vbshorttime))
						end if
						%></td>
						<td>
						<div class="ajax" id="view_exlude_prod_rule_<%=intCount%>" onmouseover="javascript:showHide('view_exlude_prod_rule_<%=intCount%>','edit_exlude_prod_rule_<%=intCount%>','exlude_prod_rule_<%=intCount%>',500, true);">
						<%
						Select Case objTmpVoucher0.getExcludeProdRule()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_exlude_prod_rule_<%=intCount%>">
							<select name="exlude_prod_rule" class="formFieldTXTShort" id="exlude_prod_rule_<%=intCount%>" onblur="javascript:updateField('edit_exlude_prod_rule_<%=intCount%>','view_exlude_prod_rule_<%=intCount%>','exlude_prod_rule_<%=intCount%>','voucher',<%=objTmpVoucher0.getID()%>,2,<%=intCount%>);">
							<option value="0"<%if ("0"=objTmpVoucher0.getExcludeProdRule()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
							<option value="1"<%if ("1"=objTmpVoucher0.getExcludeProdRule()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
							</SELECT>						
						</div>
						<script>
						$("#edit_exlude_prod_rule_<%=intCount%>").hide();
						</script>
						</td>						
					</tr>		
					<%intCount = intCount +1
					next
					Set objListaVoucher = nothing
					Set objVoucher = Nothing
					%>
				<tr> 
				<form action="<%=Application("baseroot") & "/editor/voucher/ListaVoucher.asp"%>" method="post" name="item_x_page">
				<th colspan="13">
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				<%		
				'**************** richiamo paginazione
				call PaginazioneFrontend(totPages, numPage, strGerarchia, "/editor/voucher/ListaVoucher.asp", "&items="&itemsXpage)
				%>
				</th>
				</form>
				</tr>
			<%end if%>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/voucher/InserisciVoucher.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LVC" name="cssClass">	
		<input type="hidden" value="-1" name="id_voucher">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.voucher.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>		
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>