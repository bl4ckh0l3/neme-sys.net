<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deleteSpesa(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.spese.lista.js.alert.delete_spesa")%>?")){
		ajaxDeleteItem(id_objref,"bill",row,refreshrows);
	}
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LSP"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.descrizione_spesa")%></th>
				  <!--<th><%'=langEditor.getTranslated("backend.spese.lista.table.header.valore")%></th>-->
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.tipologia_valore")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.tassa_applicata")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.taxs_group")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.applica_frontend")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.applica_backend")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.automatic")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.multiple")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.required")%></th>
				  <th><%=langEditor.getTranslated("backend.spese.lista.table.header.group")%></th>
			</tr> 
				<%
				On Error Resume Next
				Set objListaSpese = objSpesa.getListaSpese(null,null, null,null)
				
				if Err.number <> 0 then
					Set objListaSpese = null
				end if		
				
				if not(isNull(objListaSpese)) AND not isEmpty(objListaSpese) AND isObject(objListaSpese) then	
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpSpese, objTmpSpeseKey, FromSpese, ToSpese, Diff
					iIndex = objListaSpese.Count
					FromSpese = ((numPage * itemsXpage) - itemsXpage)
					Diff = (iIndex - ((numPage * itemsXpage)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToSpese = iIndex - Diff
					
					totPages = iIndex\itemsXpage
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"							
					
					objTmpSpese = objListaSpese.Items
					objTmpSpeseKey=objListaSpese.Keys	
					for newsCounter = FromSpese to ToSpese
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/spese/InserisciSpesaaccessoria.asp"%>" method="post" name="form_lista_<%=intCount%>">
						<input type="hidden" value="<%=objTmpSpeseKey(newsCounter)%>" name="id_spesa">
						<input type="hidden" value="" name="delete_spesa">
						<input type="hidden" value="LSP" name="cssClass">	
						</form> 
						<tr class="<%=styleRow%>" id="tr_delete_list_<%=intCount%>">
						<%Set objTmpSpese0 = objTmpSpese(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_lista_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.spese.lista.table.alt.modify_spesa")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteSpesa(<%=objTmpSpeseKey(newsCounter)%>, 'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.spese.lista.table.alt.delete_spesa")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="17%">
						<div class="ajax" id="view_descrizione_<%=intCount%>" onmouseover="javascript:showHide('view_descrizione_<%=intCount%>','edit_descrizione_<%=intCount%>','descrizione_<%=intCount%>',500, false);"><%=objTmpSpese0.getDescrizioneSpesa()%></div>
						<div class="ajax" id="edit_descrizione_<%=intCount%>"><input type="text" class="formfieldAjax" id="descrizione_<%=intCount%>" name="descrizione" onmouseout="javascript:restoreField('edit_descrizione_<%=intCount%>','view_descrizione_<%=intCount%>','descrizione_<%=intCount%>','bill',<%=objTmpSpese0.getSpeseID()%>,1,<%=intCount%>);" value="<%=objTmpSpese0.getDescrizioneSpesa()%>"></div>
						<script>
						$("#edit_descrizione_<%=intCount%>").hide();
						</script>
						</td>
						<!--<td>
						<div class="ajax" id="view_valore_<%'=intCount%>" onmouseover="javascript:showHide('view_valore_<%'=intCount%>','edit_valore_<%'=intCount%>','valore_<%'=intCount%>',500, false);"><%'=objTmpSpese0.getValore()%></div>
						<div class="ajax" id="edit_valore_<%'=intCount%>"><input type="text" class="formfieldAjaxShort" id="valore_<%'=intCount%>" name="valore" onmouseout="javascript:restoreField('edit_valore_<%'=intCount%>','view_valore_<%'=intCount%>','valore_<%'=intCount%>','bill',<%'=objTmpSpese0.getSpeseID()%>,1,<%'=intCount%>);" value="<%'=objTmpSpese0.getValore()%>" onkeypress="javascript:return isDouble(event);"></div>
						<script>
						//$("#edit_valore_<%'=intCount%>").hide();
						</script>
						</td>-->
						<td width="20%">
						<!--<div class="ajax" id="view_tipo_valore_<%'=intCount%>" onmouseover="javascript:showHide('view_tipo_valore_<%'=intCount%>','edit_tipo_valore_<%'=intCount%>','tipo_valore_<%'=intCount%>',500, true);">-->
						<%
						Select Case objTmpSpese0.getTipoValore()
						Case 1
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso"))
						Case 2
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_percentuale"))
						Case 3
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso_range_imp"))
						Case 4
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_percentuale_range_imp"))
						Case 5
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta"))
						Case 6
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta_incr"))
						Case 7
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso_field"))
						Case 8
							response.write(langEditor.getTranslated("backend.spese.label.tipologia_fisso_field_incr"))
						Case Else
						End Select%>
						<!--</div>
						<div class="ajax" id="edit_tipo_valore_<%'=intCount%>">
						<select name="tipo_valore" class="formfieldAjaxSelect" id="tipo_valore_<%'=intCount%>" onblur="javascript:updateField('edit_tipo_valore_<%'=intCount%>','view_tipo_valore_<%'=intCount%>','tipo_valore_<%'=intCount%>','bill',<%'=objTmpSpese0.getSpeseID()%>,2,<%'=intCount%>);">
							<option value="1"<%'if ("1"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso")%></option>	
							<option value="2"<%'if ("2"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_percentuale")%></option>	
							<option value="3"<%'if ("3"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso_range_imp")%></option>	
							<option value="4"<%'if ("4"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_percentuale_range_imp")%></option>	
							<option value="5"<%'if ("5"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta")%></option>	
							<option value="6"<%'if ("6"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta_incr")%></option>	
							<option value="7"<%'if ("7"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso_field")%></option>	
							<option value="8"<%'if ("8"=objTmpSpese0.getTipoValore()) then response.Write(" selected")%>><%'=langEditor.getTranslated("backend.spese.label.tipologia_fisso_field_incr")%></option>	
						</SELECT>	
						</div>
						<script>
						//$("#edit_tipo_valore_<%'=intCount%>").hide();
						</script>-->
						</td>
						<td width="13%">
						<div class="ajax" id="view_id_tassa_applicata_<%=intCount%>" onmouseover="javascript:showHide('view_id_tassa_applicata_<%=intCount%>','edit_id_tassa_applicata_<%=intCount%>','id_tassa_applicata_<%=intCount%>',500, true);">
						<%
						Dim tassa, objTassa
						Set objTassa = new TaxsClass
						On Error resume Next
						Set tassa = objTassa.findTassaByID(objTmpSpese0.getIDTassaApplicata())
						response.Write(tassa.getDescrizioneTassa())
						Set tassa = nothing
						if(Err.number <> 0)then
						end if
						%>
						</div>
						<div class="ajax" id="edit_id_tassa_applicata_<%=intCount%>">
						<select name="id_tassa_applicata" class="formfieldAjaxSelect" id="id_tassa_applicata_<%=intCount%>" onblur="javascript:updateField('edit_id_tassa_applicata_<%=intCount%>','view_id_tassa_applicata_<%=intCount%>','id_tassa_applicata_<%=intCount%>','bill',<%=objTmpSpese0.getSpeseID()%>,2,<%=intCount%>);">
						  <option value=""></option>
							<%
							Dim objListaTasse, objTmpTassa
							Set objListaTasse = objTassa.getListaTasse(null,null)
							if not (isNull(objListaTasse)) then
								for each y in objListaTasse.Keys
									Set objTmpTassa = objListaTasse(y)%>
									<option value="<%=y%>" <%if (objTmpSpese0.getIDTassaApplicata() = y) then response.write("selected") end if%>><%=objTmpTassa.getDescrizioneTassa()%></option>	
								<%	Set objTmpTassa = nothing
								next
							end if		
							Set objListaTasse = nothing
							%>	  
						</select>
						</div>
						<script>
						$("#edit_id_tassa_applicata_<%=intCount%>").hide();
						</script>
						<%Set objTassa = nothing%>
						</td>						
						<td width="13%">
						<div class="ajax" id="view_taxs_group_<%=intCount%>" onmouseover="javascript:showHide('view_taxs_group_<%=intCount%>','edit_taxs_group_<%=intCount%>','taxs_group_<%=intCount%>',500, true);">
						<%
						Dim taxsG, objTaxGroup
						Set objTaxGroup = new TaxsGroupClass
						On Error resume Next
						Set taxsG = objTaxGroup.getGroupByID(objTmpSpese0.getTaxGroup())
						response.Write(taxsG.getGroupDescription())
						Set taxsG = nothing
						if(Err.number <> 0)then
						end if
						%>
						</div>
						<div class="ajax" id="edit_taxs_group_<%=intCount%>">
						<select name="taxs_group" class="formfieldAjaxSelect" id="taxs_group_<%=intCount%>" onblur="javascript:updateField('edit_taxs_group_<%=intCount%>','view_taxs_group_<%=intCount%>','taxs_group_<%=intCount%>','bill',<%=objTmpSpese0.getSpeseID()%>,2,<%=intCount%>);">
						  <option value=""></option>
							<%							
							Dim objListaTaxGroup, objGroupT
							On Error Resume Next
							Set objListaTaxGroup = objTaxGroup.getListaTaxsGroup(null)
							if not (isNull(objListaTaxGroup)) then
								for each y in objListaTaxGroup.Keys
									Set objGroupT = objListaTaxGroup(y)%>
									<option value="<%=y%>" <%if (objTmpSpese0.getTaxGroup() = y) then response.write("selected") end if%>><%=objGroupT.getGroupDescription()%></option>	
								<%	Set objGroupT = nothing
								next
							end if		
							Set objListaTaxGroup = nothing
							if(Err.number<>0)then
							end if					
							%>	  
						</select>
						</div>
						<script>
						$("#edit_taxs_group_<%=intCount%>").hide();
						</script>
						<%Set objTaxGroup = nothing%>
						</td>					
						<td width="7%">
						<div class="ajax" id="view_applica_frontend_<%=intCount%>" onmouseover="javascript:showHide('view_applica_frontend_<%=intCount%>','edit_applica_frontend_<%=intCount%>','applica_frontend_<%=intCount%>',500, true);">
						<%
						Select Case objTmpSpese0.getApplicaFrontend()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_applica_frontend_<%=intCount%>">
						<select name="applica_frontend" class="formfieldAjaxSelect" id="applica_frontend_<%=intCount%>" onblur="javascript:updateField('edit_applica_frontend_<%=intCount%>','view_applica_frontend_<%=intCount%>','applica_frontend_<%=intCount%>','bill',<%=objTmpSpese0.getSpeseID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpSpese0.getApplicaFrontend(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpSpese0.getApplicaFrontend(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_applica_frontend_<%=intCount%>").hide();
						</script>
						</td>
						<td width="7%">
						<div class="ajax" id="view_applica_backend_<%=intCount%>" onmouseover="javascript:showHide('view_applica_backend_<%=intCount%>','edit_applica_backend_<%=intCount%>','applica_backend_<%=intCount%>',500, true);">
						<%
						Select Case objTmpSpese0.getApplicaBackend()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select						
						%>
						</div>
						<div class="ajax" id="edit_applica_backend_<%=intCount%>">
						<select name="applica_backend" class="formfieldAjaxSelect" id="applica_backend_<%=intCount%>" onblur="javascript:updateField('edit_applica_backend_<%=intCount%>','view_applica_backend_<%=intCount%>','applica_backend_<%=intCount%>','bill',<%=objTmpSpese0.getSpeseID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpSpese0.getApplicaBackend(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpSpese0.getApplicaBackend(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_applica_backend_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<%
						Select Case objTmpSpese0.getAutoactive()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select						
						%>
						</td>
						<td>
						<%
						Select Case objTmpSpese0.getMultiply()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select						
						%>
						</td>
						<td>
						<%
						Select Case objTmpSpese0.getRequired()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select						
						%>
						</td>
						<td>
						<%=objTmpSpese0.getGroup()%>
						</td>               
					</tr>			
					<%Set objTmpSpese0 = nothing
					intCount = intCount +1
					next
					Set objListaSpese = nothing
				end if
				Set objSpesa = Nothing
				%>
			<tr> 
			<form action="<%=Application("baseroot") & "/editor/spese/ListaSpeseaccessorie.asp"%>" method="post" name="item_x_page">
			<th colspan="13">
			<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPage, strGerarchia, "/editor/spese/ListaSpeseaccessorie.asp", "&items="&itemsXpage)
			%>
			</th>
			</form>
			</tr>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/spese/InserisciSpesaaccessoria.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LSP" name="cssClass">	
		<input type="hidden" value="-1" name="id_spesa">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.spese.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>		
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>