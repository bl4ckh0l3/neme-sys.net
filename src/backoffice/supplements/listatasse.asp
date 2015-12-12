<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deleteTassa(theForm){
	if(confirm("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.delete_tassa")%>")){
		theForm.delete_tassa.value = "del";
		theForm.action = "<%=Application("baseroot") & "/editor/tax/ProcessTassa.asp"%>";
		theForm.submit();
	}
}

function deleteTaxsGroup(theForm){
	if(confirm("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.delete_taxs_group")%>")){
		theForm.action = "<%=Application("baseroot") & "/editor/tax/processtassagroup.asp"%>";
		theForm.submit();
	}
}

function deleteTaxsGroupValue(theForm, countryCode, stateRegCode,gaDiv){
	if(confirm("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.delete_taxs_group_value")%>")){
		theForm.operation.value = "delete_group_value";
		theForm.group_ass_match_div.value = gaDiv;
		theForm.country_code.value = countryCode;
		theForm.state_region_code.value =stateRegCode;
		theForm.action = "<%=Application("baseroot") & "/editor/tax/processtassagroup.asp"%>";
		theForm.submit();
	}
}

function insertTaxsGroup(theForm){
	if(theForm.description.value == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_desc")%>");
		theForm.description.focus();
		return;
	}

	if(confirm("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_taxs_group")%>")){
		theForm.submit();
	}
}

function insertTaxsGroupValue(theForm){
	if(theForm.id_group.value == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_group")%>");
		return;
	}
	if(theForm.id_tassa_applicata.value == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_tax")%>");
		return;
	}
	if(theForm.country_code.value == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_country")%>");
		return;
	}
	
	if(confirm("<%=langEditor.getTranslated("backend.tasse.lista.js.alert.insert_taxs_group_value")%>")){
		theForm.submit();
	}
}

function showHideDivTaxsGroup(element){
	var elementTl = document.getElementById("taxslist");
	var elementaTl = document.getElementById("ataxslist");
	var elementTg = document.getElementById("taxsgroup");
	var elementaTg = document.getElementById("ataxsgroup");

	if(element == 'taxslist'){
		elementTg.style.visibility = 'hidden';		
		elementTg.style.display = "none";
		elementaTg.className= "";
		elementTl.style.visibility = 'visible';
		elementTl.style.display = "block";
		elementaTl.className= "active";
	}else if(element == 'taxsgroup'){
		elementTl.style.visibility = 'hidden';
		elementTl.style.display = "none";
		elementaTl.className= "";
		elementTg.style.visibility = 'visible';		
		elementTg.style.display = "block";
		elementaTg.className= "active";
	}
}

function openTaxsGroup(element){
	if($("#"+element).is(":visible")){
		$("#"+element).hide();
	}else{
		$("#"+element).show();
	}
}

var group_ass_match_div = "";	

<%
if(request("group_ass_match_div")<>"")then
	response.write("group_ass_match_div ='"&request("group_ass_match_div")&"';")
end if%>

function changeRowListData(listCounter, objtype, field){
	if(objtype=="taxs_group"){
		group_ass_match_div = "group_association_"+listCounter.substring(0,listCounter.indexOf("_"));
	}
}
</script>
</head>
<body onLoad="showHideDivTaxsGroup('<%=showTab%>');">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LTX"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<div id="tab-taxs-group"><a id="ataxslist" <%if(showtab="taxslist")then response.write("class=active") end if%> href="javascript:showHideDivTaxsGroup('taxslist');"><%=langEditor.getTranslated("backend.tasse.lista.table.header.label_taxs_list")%></a><a id="ataxsgroup" <%if(showtab="taxsgroup")then response.write("class=active") end if%> href="javascript:showHideDivTaxsGroup('taxsgroup');"><%=langEditor.getTranslated("backend.tasse.lista.table.header.label_taxs_group")%></a></div>
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<div id="taxslist" style="visibility:visible;display:block;margin:0px;padding:0px;">
		<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=langEditor.getTranslated("backend.tasse.lista.table.header.descrizione_tassa")%></th>
				  <th><%=langEditor.getTranslated("backend.tasse.lista.table.header.valore")%></th>
				  <th><%=langEditor.getTranslated("backend.tasse.lista.table.header.tipologia_valore")%></th>
			</tr> 
				<%
				On Error Resume Next
				Dim hasTasse
				hasTasse = false
				Set objListaTasse = objTassa.getListaTasse(null,null)
				hasTasse = true				
				
				if Err.number <> 0 then
					hasTasse = false
				end if
				
				if(hasTasse) then			
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpTasse, objTmpTasseKey, FromTasse, ToTasse, Diff
					iIndex = objListaTasse.Count
					FromTasse = ((numPageTax * itemsXpageTax) - itemsXpageTax)
					Diff = (iIndex - ((numPageTax * itemsXpageTax)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToTasse = iIndex - Diff
					
					totPages = iIndex\itemsXpageTax
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageTax <> 0) AND not ((totPages * itemsXpageTax) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"							
							
					objTmpTasse = objListaTasse.Items
					objTmpTasseKey=objListaTasse.Keys	
					for newsCounter = FromTasse to ToTasse
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/tax/InserisciTassa.asp"%>" method="post" name="form_lista_<%=intCount%>">
						<input type="hidden" value="<%=objTmpTasseKey(newsCounter)%>" name="id_tassa">
						<input type="hidden" value="" name="delete_tassa">
						<input type="hidden" value="LTX" name="cssClass">
						</form> 
					<tr class="<%=styleRow%>">
						<%Set objTmpTasse0 = objTmpTasse(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_lista_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.tasse.lista.table.alt.modify_tassa")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteTassa(document.form_lista_<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.tasse.lista.table.alt.delete_tassa")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="25%">						
						<div class="ajax" id="view_descrizione_<%=intCount%>" onmouseover="javascript:showHide('view_descrizione_<%=intCount%>','edit_descrizione_<%=intCount%>','descrizione_<%=intCount%>',500, false);"><%=objTmpTasse0.getDescrizioneTassa()%></div>
						<div class="ajax" id="edit_descrizione_<%=intCount%>"><input type="text" class="formfieldAjax" id="descrizione_<%=intCount%>" name="descrizione" onmouseout="javascript:restoreField('edit_descrizione_<%=intCount%>','view_descrizione_<%=intCount%>','descrizione_<%=intCount%>','tax',<%=objTmpTasse0.getTasseID()%>,1,<%=intCount%>);" value="<%=objTmpTasse0.getDescrizioneTassa()%>"></div>
						<script>
						$("#edit_descrizione_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_valore_<%=intCount%>" onmouseover="javascript:showHide('view_valore_<%=intCount%>','edit_valore_<%=intCount%>','valore_<%=intCount%>',500, false);"><%=objTmpTasse0.getValore()%></div>
						<div class="ajax" id="edit_valore_<%=intCount%>"><input type="text" class="formfieldAjaxShort" id="valore_<%=intCount%>" name="valore" onmouseout="javascript:restoreField('edit_valore_<%=intCount%>','view_valore_<%=intCount%>','valore_<%=intCount%>','tax',<%=objTmpTasse0.getTasseID()%>,1,<%=intCount%>);" value="<%=objTmpTasse0.getValore()%>" onkeypress="javascript:return isDouble(event);"></div>
						<script>
						$("#edit_valore_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_tipo_valore_<%=intCount%>" onmouseover="javascript:showHide('view_tipo_valore_<%=intCount%>','edit_tipo_valore_<%=intCount%>','tipo_valore_<%=intCount%>',500, true);">
						<%
						Select Case objTmpTasse0.getTipoValore()
						Case 1
							response.write(langEditor.getTranslated("backend.tasse.label.tipologia_fisso"))
						Case 2
							response.write(langEditor.getTranslated("backend.tasse.label.tipologia_percentuale"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_tipo_valore_<%=intCount%>">
						<select name="tipo_valore" class="formfieldAjaxSelect" id="tipo_valore_<%=intCount%>" onblur="javascript:updateField('edit_tipo_valore_<%=intCount%>','view_tipo_valore_<%=intCount%>','tipo_valore_<%=intCount%>','tax',<%=objTmpTasse0.getTasseID()%>,2,<%=intCount%>);">
							<option value="1"<%if ("1"=objTmpTasse0.getTipoValore()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.tasse.label.tipologia_fisso")%></option>	
							<option value="2"<%if ("2"=objTmpTasse0.getTipoValore()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.tasse.label.tipologia_percentuale")%></option>
						</SELECT>	
						</div>
						<script>
						$("#edit_tipo_valore_<%=intCount%>").hide();
						</script>
						</td>               
						</tr>				
						<%intCount = intCount +1
						
						Set objTmpTasse0 = nothing
					next
					Set objListaTasse = nothing		
				end if
				%>
		<tr> 
			<form action="<%=Application("baseroot") & "/editor/tax/ListaTasse.asp"%>" method="post" name="item_x_page">
			<th colspan="5">
			<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpageTax%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPageTax, strGerarchia, "/editor/tax/ListaTasse.asp", "&items="&itemsXpageTax)
			%>
			</th>
			</form>
              </tr>
		</table>
		<br/>
		<form action="<%=Application("baseroot") & "/editor/tax/InserisciTassa.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LTX" name="cssClass">	
		<input type="hidden" value="-1" name="id_tassa">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.tasse.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>
		</div>

		<div id="taxsgroup" style="visibility:hidden;margin:0px;padding:0px;">	
		<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<form action="<%=Application("baseroot") & "/editor/tax/processtassagroup.asp"%>" method="post" name="form_crea_group">
			<input type="hidden" value="LTX" name="cssClass">	
			<input type="hidden" value="-1" name="id_group">	
			<input type="hidden" value="group" name="operation">
			<tr class="table-list-on"> 
				  <td>&nbsp;</td>
				  <td>		
				 <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.tasse.lista.button.label.inserisci_group")%>" onclick="javascript:insertTaxsGroup(document.form_crea_group);" /></td>
				  <td><input type="text" value="" name="description" class="formFieldTXT"></td>
			</tr>
			</form>
			
			<%
			dim objCountry, objListaTasse4Select, objListaCountry4Select, objListaStateRegion4Select
			Set objCountry = New CountryClass			

			'*************** INIZIALIZZO LE LISTE DI OGGETTI NECESSARI: countries e tasse da usare nei cicli for successivi;					
			On Error Resume Next
			Set objListaTasse4Select = objTassa.getListaTasse(null,null)			
			if(Err.number<>0)then
			end if				
			
			On Error Resume Next
			Set objListaCountry4Select = objCountry.findCountryListCodeDesc("2,3")
			Set objListaStateRegion4Select = objCountry.findStateRegionListCodeDesc("2,3")
			if(Err.number<>0)then
				'response.write("Err: "&Err.description&"<br>")
			end if
			%>

			<form action="<%=Application("baseroot") & "/editor/tax/processtassagroup.asp"%>" method="post" name="form_crea_group_value">
			<input type="hidden" value="LTX" name="cssClass">	
			<input type="hidden" value="group_value" name="operation">
			<tr class="table-list-off"> 
				  <td>&nbsp;</td>
				  <td>		
				 <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.tasse.lista.button.label.inserisci_group_association")%>" onclick="javascript:insertTaxsGroupValue(document.form_crea_group_value);" /></td>
				  <td>

				<div style="float:left;padding-right:10px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.lista.group.label.taxs_group")%></span><br>
				  <select name="id_group" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					Dim objListaTaxGroup, objGroupT					
					On Error Resume Next
					Set objListaTaxGroup = objTaxsGroup.getListaTaxsGroup(null)
					if not (isNull(objListaTaxGroup)) then
						for each y in objListaTaxGroup.Keys
							Set objGroupT = objListaTaxGroup(y)%>
							<option value="<%=y%>" <%if (taxs_group = y) then response.write("selected") end if%>><%=objGroupT.getGroupDescription()%></option>	
						<%	Set objGroupT = nothing
						next
					end if		
					Set objListaTaxGroup = nothing
					if(Err.number<>0)then
					end if
					%>	  
				  </select>
				  </div>
				  <div style="float:left;padding-right:10px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.lista.group.label.group_tax_id")%></span><br>	
				  <select name="id_tassa_applicata" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					On Error Resume Next
					if (Instr(1, typename(objListaTasse4Select), "Dictionary", 1) > 0) then
						for each y in objListaTasse4Select.Keys
							Set objTassaTmp = objListaTasse4Select(y)%>
							<option value="<%=y%>"><%=objTassaTmp.getDescrizioneTassa()%></option>	
						<%	Set objTassaTmp = nothing
						next
					end if		
					
					if(Err.number <> 0) then
					end if
					%>	  
				  </select>					
				  </div>
				  <div style="padding-bottom:10px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.lista.group.label.exclude_calculation")%></span><br>	
				  <select name="exclude_calculation">
				  <option value="0"><%=langEditor.getTranslated("backend.commons.no")%></option>
				  <option value="1"><%=langEditor.getTranslated("backend.commons.yes")%></option>
				  </select>					
				  </div>
				  <div style="float:left;padding-right:10px;padding-top:10px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.lista.group.label.country")%></span><br>
				  <select id="country_code" name="country_code" class="formFieldSelectSimple">
				  <option value=""></option>
					<%Set specialFieldValue = objCountry.findCountryListOnly("2,3")			    
					for each x in specialFieldValue
						key =  specialFieldValue(x).getCountryCode()%>
						<option value="<%=key%>"><%=langEditor.getTranslated("portal.commons.select.option.country."&key)%></option>     
					<%next
					Set specialFieldValue = nothing%>
				  </select>  
				  </div>  
				  <div style="padding-top:10px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.lista.group.label.state_region")%></span><br>	 
				  <select id="state_region_code" name="state_region_code" class="formFieldSelectSimple">
				  <option value=""></option>
				  </select>	  
				  </div>
					<script>
					$('#country_code').change(function() {
						var type_val_ch = $('#country_code').val();
						var query_string = "field_val="+encodeURIComponent(type_val_ch);
	
						$.ajax({
							async: true,
							type: "GET",
							cache: false,
							url: "<%=Application("baseroot") & "/editor/include/ajaxstateregionlistupdate.asp"%>",
							data: query_string,
							success: function(response) {
								//alert("response: "+response);
								$("select#state_region_code").empty();
								$("select#state_region_code").append($("<option></option>").attr("value","").text(""));
								$("select#state_region_code").append(response);
							},
							error: function() {
								$("select#state_region_code").empty();
								$("select#state_region_code").append($("<option></option>").attr("value","").text(""));
							}
						});
					});
					</script> 
				  </td>
				</tr>
				</form>
				<tr> 
				  <th>&nbsp;</th>
				  <th><%=langEditor.getTranslated("backend.tasse.lista.table.header.descrizione_group")%></th>
				  <th><%=langEditor.getTranslated("backend.tasse.lista.table.header.associazioni_tasse")%></th>
			</tr> 
				<%
				On Error Resume Next
				Dim hasGroup
				hasGroup = false
				Set objListaGroup = objTaxsGroup.findWrapTaxsGroup(null)
				hasGroup = true				
				
				if Err.number <> 0 then
					hasGroup = false
				end if
				
				if(hasGroup) then	
					intCount = 0
					
					Dim groupCounter, iIndexGroup, objTmpGroup, objTmpGroupKey, FromTaxsGroup, ToTaxsGroup, DiffGroup
					iIndexGroup = objListaGroup.Count
					FromTaxsGroup = ((numPageGroup * itemsXpageGroup) - itemsXpageGroup)
					DiffGroup = (iIndexGroup - ((numPageGroup * itemsXpageGroup)-1))
					if(DiffGroup < 1) then
						DiffGroup = 1
					end if
					
					ToTaxsGroup = iIndexGroup - DiffGroup
					
					totPages = iIndexGroup\itemsXpageGroup
					if(totPages < 1) then
						totPages = 1
					elseif((iIndexGroup MOD itemsXpageGroup <> 0) AND not ((totPages * itemsXpageGroup) >= iIndexGroup)) then
						totPages = totPages +1	
					end if		
				
					styleRow  = "table-list-off"
					styleRow2 = "table-list-on"
	
					objTmpGroup = objListaGroup.Items
					objTmpGroupKey=objListaGroup.Keys	
					for groupCounter = FromTaxsGroup to ToTaxsGroup
						styleRow = "table-list-off"
						if(groupCounter MOD 2 = 0) then styleRow = styleRow2 end if

						splitIdG = Left(objTmpGroupKey(groupCounter),Instr(1,objTmpGroupKey(groupCounter),"|",1 )-1) 
						splitDescG = Mid(objTmpGroupKey(groupCounter),Instr(1,objTmpGroupKey(groupCounter),"|",1 )+1,Len(objTmpGroupKey(groupCounter)))
						%>
						<form action="<%=Application("baseroot") & "/editor/tax/processtassagroup.asp"%>" method="post" name="form_lista_tgroup_<%=intCount%>">
						<input type="hidden" value="<%=splitIdG%>" name="id_group">
						<input type="hidden" value="delete_group" name="operation">
						<input type="hidden" value="" name="country_code">
						<input type="hidden" value="" name="state_region_code">
						<input type="hidden" value="" name="exclude_calculation">
						<input type="hidden" value="" name="group_ass_match_div">
						<input type="hidden" value="LTX" name="cssClass">
						</form> 
						<tr class="<%=styleRow%>">
						<td style="text-align:center;vertical-align:top;width:25px;"><a href="javascript:deleteTaxsGroup(document.form_lista_tgroup_<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.tasse.lista.table.alt.delete_taxs_group")%>" hspace="2" vspace="0" border="0"></a></td>
						<td style="text-align:left;vertical-align:top;width:25%;"><input type="button" value="<%=splitDescG%>" style="background-color:#FFFFFF; padding-left:10px; vertical-align:top; text-align:left; color:#000000; border:1px solid #000000; width:100%; " onclick="javascript:openTaxsGroup('group_association_<%=intCount%>');" /></td>
						<td>
						<%
						Set objTmpGroup0 = objTmpGroup(groupCounter)
						if (Instr(1, typename(objTmpGroup0), "Dictionary", 1) > 0) then
							if(objTmpGroup0.Count > 0)then
							%>
						<div id="group_association_<%=intCount%>" style="margin:0px;padding:0px;">	
						<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
							<tr>
							<th>&nbsp;</th>
							<th><%=langEditor.getTranslated("backend.tasse.lista.table.header.group_country")%></th>
							<th><%=langEditor.getTranslated("backend.tasse.lista.table.header.group_state_region")%></th>
							<th><%=langEditor.getTranslated("backend.tasse.lista.table.header.group_tax")%></th>
							<th><%=langEditor.getTranslated("backend.tasse.lista.table.header.exclude_calculation")%></th>		
							</tr>

							<%
							innerCounter = 0
							for each q in objTmpGroup0
								ajaxupdatefield = ""
								styleRowInner = "table-list-off"
								if(innerCounter MOD 2 = 0) then styleRowInner = "table-list-on" end if
								
								ajaxupdatefield = splitIdG&"|"&q.getCountryCode()&"|"&q.getStateRegionCode()
								%>
								<tr class="<%=styleRowInner%>">
									<td align="center" width="25"><a href="javascript:deleteTaxsGroupValue(document.form_lista_tgroup_<%=intCount%>,'<%=q.getCountryCode()%>','<%=q.getStateRegionCode()%>','group_association_<%=intCount%>');"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" alt="<%=langEditor.getTranslated("backend.tasse.lista.table.alt.delete_taxs_group_value")%>" hspace="2" vspace="0" border="0"></a></td>
									<td width="30%"><%if(Trim(objListaCountry4Select(q.getCountryCode()))<>"")then response.write(objListaCountry4Select(q.getCountryCode())) else response.write(q.getCountryCode()) end if%></td>
									<td width="40%"><%if(Trim(objListaStateRegion4Select(q.getStateRegionCode()))<>"")then response.write(objListaStateRegion4Select(q.getStateRegionCode())) else response.write(q.getStateRegionCode()) end if%></td>
									<td>
									<div class="ajax" id="view_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>" onmouseover="javascript:showHide('view_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>','edit_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>','id_tassa_applicata_<%=intCount%>_<%=innerCounter%>',500, true);">
									<%
									Dim tassaGA
									On Error resume Next
									Set tassaGA = objTassa.findTassaByID(q.getTaxID())
									response.Write(tassaGA.getDescrizioneTassa())
									Set tassaGA = nothing
									if(Err.number <> 0)then
									end if
									%>
									</div>
									<div class="ajax" id="edit_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>">
									<select name="id_tassa_applicata" class="formfieldAjaxSelect" id="id_tassa_applicata_<%=intCount%>_<%=innerCounter%>" onblur="javascript:updateField('edit_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>','view_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>','id_tassa_applicata_<%=intCount%>_<%=innerCounter%>','taxs_group','<%=ajaxupdatefield%>',2,'<%=intCount%>_<%=innerCounter%>');">
									  <option value=""></option>
										<%
										Set objListaTasse = objTassa.getListaTasse(null,null)
										if not (isNull(objListaTasse)) then
											for each y in objListaTasse.Keys
												Set objTmpTassa = objListaTasse(y)%>
												<option value="<%=y%>" <%if (q.getTaxID() = y) then response.write("selected") end if%>><%=objTmpTassa.getDescrizioneTassa()%></option>	
											<%	Set objTmpTassa = nothing
											next
										end if		
										Set objListaTasse = nothing
										%>	  
									</select>
									</div>
									<script>
									$("#edit_id_tassa_applicata_<%=intCount%>_<%=innerCounter%>").hide();
									</script>
								</td>
								<td width="30">
									<div class="ajax" id="view_exclude_calculation_<%=intCount%>_<%=innerCounter%>" onmouseover="javascript:showHide('view_exclude_calculation_<%=intCount%>_<%=innerCounter%>','edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>','exclude_calculation_<%=intCount%>_<%=innerCounter%>',500, true);">
									<%if(Cint(q.isExcludeCalculation())=0) then response.write(langEditor.getTranslated("backend.commons.no")) else response.write(langEditor.getTranslated("backend.commons.yes")) end if%>
									</div>
									<div class="ajax" id="edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>">
									<select name="exclude_calculation" class="formfieldAjaxSelect" id="exclude_calculation_<%=intCount%>_<%=innerCounter%>" onblur="javascript:updateField('edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>','view_exclude_calculation_<%=intCount%>_<%=innerCounter%>','exclude_calculation_<%=intCount%>_<%=innerCounter%>','taxs_group','<%=ajaxupdatefield%>',2,'<%=intCount%>_<%=innerCounter%>');">
									  <option value="0" <%if (Cint(q.isExcludeCalculation()) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
									  <option value="1" <%if (Cint(q.isExcludeCalculation()) = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	  
									</select>
									</div>
									<script>
									$("#edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>").hide();
									</script>								
								</td>
								</tr>
								<%innerCounter = innerCounter+1
							next
							%>
			
						</table>
						</div>
						<script>					
						if(group_ass_match_div!="group_association_<%=intCount%>"){
							$('#group_association_<%=intCount%>').hide();
						}
						</script>

						<%end if
						end if						
						Set objTmpGroup0 = nothing%>
						</td>             
						</tr>			
						<%
						intCount = intCount +1
					next
					Set objListaGroup = nothing		
				end if
				%>
			<tr> 
			<form action="<%=Application("baseroot") & "/editor/tax/ListaTasse.asp"%>" method="post" name="item_x_page">
			<input type="hidden" value="taxsgroup" name="showtab">
			<th colspan="4">
			<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpageGroup%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPageGroup, strGerarchia, "/editor/tax/ListaTasse.asp", "&items="&itemsXpageGroup&"&showtab=taxsgroup")
			%>
			</th>
			</form>
              </tr>
		</table>
		</div>	

		<%
		Set objCountry = nothing
		Set objTassa = Nothing	
		%>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>