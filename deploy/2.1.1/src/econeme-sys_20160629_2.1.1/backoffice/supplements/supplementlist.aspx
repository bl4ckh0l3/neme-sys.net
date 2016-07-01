<%@ Page Language="C#" AutoEventWireup="true" CodeFile="supplementlist.aspx.cs" Inherits="_SupplementList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
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
<script>
function deleteSupplement(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_news")%>?")){	
		ajaxDeleteItem(id_objref,"Supplement|ISupplementRepository",row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
	}
}

function editSupplement(id){
	location.href='/backoffice/supplements/insertsupplement.aspx?cssClass=LN&id='+id;
}

function deleteTaxsGroup(theForm){
	if(confirm("<%=lang.getTranslated("backend.tasse.lista.js.alert.delete_taxs_group")%>?")){
		theForm.operation.value = "deleteGroup";
		theForm.action = "/backoffice/supplements/supplementlist.aspx";
		theForm.submit();
	}
}

function deleteTaxsGroupValue(theForm, countryCode, stateRegCode,gaDiv,vId){
	if(confirm("<%=lang.getTranslated("backend.tasse.lista.js.alert.delete_taxs_group_value")%>")){
		theForm.operation.value = "deleteGroupValue";
		theForm.group_ass_match_div.value = gaDiv;
		theForm.value_id.value = vId;
		theForm.action = "/backoffice/supplements/supplementlist.aspx";
		theForm.submit();
	}
}

function insertTaxsGroup(theForm){
	if(theForm.description.value == ""){
		alert("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_desc")%>");
		theForm.description.focus();
		return;
	}

	if(confirm("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_taxs_group")%>")){
		theForm.submit();
	}
}

function insertTaxsGroupValue(theForm){
	if(theForm.id_group.value == ""){
		alert("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_group")%>");
		return;
	}
	if(theForm.id_fee.value == ""){
		alert("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_tax")%>");
		return;
	}
	if(theForm.country_code.value == ""){
		alert("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_country")%>");
		return;
	}
	
	if(confirm("<%=lang.getTranslated("backend.tasse.lista.js.alert.insert_taxs_group_value")%>")){
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
<%if(!String.IsNullOrEmpty(Request["group_ass_match_div"])){
	Response.Write("group_ass_match_div ='"+Request["group_ass_match_div"]+"';");
}%>

function changeRowListData(listCounter, objtype, field){
	if(objtype=="taxs_group"){
		group_ass_match_div = "group_association_"+listCounter.substring(0,listCounter.indexOf("_"));
	}
}

jQuery(document).ready(function(){
	showHideDivTaxsGroup('<%=showTab%>'); 
})
</SCRIPT>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		

			<div id="tab-taxs-group"><a id="ataxslist" <%if(showTab=="taxslist"){ Response.Write("class=active");}%> href="javascript:showHideDivTaxsGroup('taxslist');"><%=lang.getTranslated("backend.tasse.lista.table.header.label_taxs_list")%></a><a id="ataxsgroup" <%if(showTab=="taxsgroup"){Response.Write("class=active");}%> href="javascript:showHideDivTaxsGroup('taxsgroup');"><%=lang.getTranslated("backend.tasse.lista.table.header.label_taxs_group")%></a></div>

			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<div id="taxslist" style="visibility:visible;display:block;margin:0px;padding:0px;">
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
					<tr> 
						<th colspan="5" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">	
						<input type="hidden" value="taxslist" name="showtab">
						<input type="text" name="itemsSup" class="formFieldTXTNumXPage" value="<%=itemsXpageSup%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
						</div>
						</th>
					</tr>

				      <tr> 
					<th colspan="2">&nbsp;</td>
					<th><lang:getTranslated keyword="backend.tasse.lista.table.header.descrizione_tassa" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.tasse.lista.table.header.valore" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.tasse.lista.table.header.tipologia_valore" runat="server" /></th>
				      </tr>
					  
						<%
						int intCount = 0;				
						if(bolFoundLista){
							for(intCount = fromSup; intCount<= toSup;intCount++)
							{
								Supplement k = supplements[intCount];%>		
								<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
								<td align="center" width="25"><a href="javascript:editSupplement('<%=k.id%>');"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" hspace="2" vspace="0" border="0"></a></td>
								<td align="center" width="25"><a href="javascript:deleteSupplement(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>
								<td nowrap width="280">						
								<div class="ajax" id="view_description_<%=intCount%>" onmouseover="javascript:showHide('view_description_<%=intCount%>','edit_description_<%=intCount%>','description_<%=intCount%>',500, false);"><%=k.description%></div>
								<div class="ajax" id="edit_description_<%=intCount%>"><input type="text" class="formfieldAjax" id="description_<%=intCount%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=intCount%>','view_description_<%=intCount%>','description_<%=intCount%>','Supplement|ISupplementRepository|string',<%=k.id%>,1,<%=intCount%>);" value="<%=k.description%>"></div>
								<script>
								$("#edit_description_<%=intCount%>").hide();
								</script>
								</td>

								<td>
								<div class="ajax" id="view_value_<%=intCount%>" onmouseover="javascript:showHide('view_value_<%=intCount%>','edit_value_<%=intCount%>','value_<%=intCount%>',500, false);"><%=k.value.ToString("#0.00#")%></div>
								<div class="ajax" id="edit_value_<%=intCount%>"><input type="text" class="formfieldAjaxShort" id="value_<%=intCount%>" name="value" onmouseout="javascript:restoreField('edit_value_<%=intCount%>','view_value_<%=intCount%>','value_<%=intCount%>','Supplement|ISupplementRepository|decimal',<%=k.id%>,1,<%=intCount%>);" value="<%=k.value.ToString("#0.00#")%>" onkeypress="javascript:return isDouble(event);"></div>
								<script>
								$("#edit_value_<%=intCount%>").hide();
								</script>
								</td>
								<td>
								<div class="ajax" id="view_type_<%=intCount%>" onmouseover="javascript:showHide('view_type_<%=intCount%>','edit_type_<%=intCount%>','type_<%=intCount%>',500, true);">
								<%
								if(k.type==1){
									Response.Write(lang.getTranslated("backend.tasse.label.tipologia_fisso"));
								}else if(k.type==2){
									Response.Write(lang.getTranslated("backend.tasse.label.tipologia_percentuale"));
								}%>
								</div>
								<div class="ajax" id="edit_type_<%=intCount%>">
								<select name="type" class="formfieldAjaxSelect" id="type_<%=intCount%>" onblur="javascript:updateField('edit_type_<%=intCount%>','view_type_<%=intCount%>','type_<%=intCount%>','Supplement|ISupplementRepository|int',<%=k.id%>,2,<%=intCount%>);">
									<option value="1" <%if (k.type==1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.tasse.label.tipologia_fisso")%></option>	
									<option value="2"<%if (k.type==2) { Response.Write("selected");}%>><%=lang.getTranslated("backend.tasse.label.tipologia_percentuale")%></option>
								</SELECT>	
								</div>
								<script>
								$("#edit_type_<%=intCount%>").hide();
								</script>
								</td>  

								</tr>
								<%
							}
						}
						%>
					
					<tr> 
						<th colspan="5" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">
						<input type="hidden" value="taxslist" name="showtab">	
						<input type="text" name="itemsSup" class="formFieldTXTNumXPage" value="<%=itemsXpageSup%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
						</div>
						</th>
					</tr>			
				</table>
				<br/>
				<form action="/backoffice/supplements/insertsupplement.aspx" method="post" name="form_crea">
					<input type="hidden" value="-1" name="id">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.tasse.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
				</form>
			</div>
			
			<!-- **************** SUPPLEMENT LOCALIZATON ************ -->
			
			<div id="taxsgroup" style="visibility:hidden;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<form action="/backoffice/supplements/supplementlist.aspx" method="post" name="form_crea_group">
			<input type="hidden" value="LTX" name="cssClass">	
			<input type="hidden" value="-1" name="id_group">	
			<input type="hidden" value="insGroup" name="operation">
			<tr class="table-list-on"> 
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.tasse.lista.button.label.inserisci_group")%>" onclick="javascript:insertTaxsGroup(document.form_crea_group);" /></td>
				  <td><input type="text" value="" name="description" class="formFieldTXT"></td>
			</tr>
			</form>

			<form action="/backoffice/supplements/supplementlist.aspx" method="post" name="form_crea_group_value">
			<input type="hidden" value="LTX" name="cssClass">	
			<input type="hidden" value="insGroupValue" name="operation">
			<tr class="table-list-off"> 
				  <td>&nbsp;</td>
				  <td>&nbsp;</td>
				  <td><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.tasse.lista.button.label.inserisci_group_association")%>" onclick="javascript:insertTaxsGroupValue(document.form_crea_group_value);" /></td>
				  <td>

				<div style="float:left;padding-right:10px;">
				  <span class="labelForm"><%=lang.getTranslated("backend.tasse.lista.group.label.taxs_group")%></span><br>
				  <select name="id_group" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					if(bolFoundGroup){
						foreach(SupplementGroup sg in supplementGroups){%>
							<option value="<%=sg.id%>"><%=sg.description%></option>
						<%}
					}
					%>	  
				  </select>
				  </div>
				  <div style="float:left;padding-right:10px;">
				  <span class="labelForm"><%=lang.getTranslated("backend.tasse.lista.group.label.group_tax_id")%></span><br>	
				  <select name="id_fee" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					if(bolFoundLista){
						foreach(Supplement s in supplements){%>
							<option value="<%=s.id%>"><%=s.description%></option>
						<%}
					}
					%>	  
				  </select>					
				  </div>
				  <div style="padding-bottom:10px;">
				  <span class="labelForm"><%=lang.getTranslated("backend.tasse.lista.group.label.exclude_calculation")%></span><br>	
				  <select name="exclude_calculation">
				  <option value="0"><%=lang.getTranslated("backend.commons.no")%></option>
				  <option value="1"><%=lang.getTranslated("backend.commons.yes")%></option>
				  </select>					
				  </div>
				  <div style="float:left;padding-right:10px;padding-top:10px;">
				  <span class="labelForm"><%=lang.getTranslated("backend.tasse.lista.group.label.country")%></span><br>
				  <select id="country_code" name="country_code" class="formFieldSelectSimple">
				  <option value=""></option>
					<%					
					if(countries != null){
						foreach(Country c in countries){%>
							<option value="<%=c.countryCode%>"><%=c.countryDescription%></option>
						<%}
					}%>
				  </select>  
				  </div>  
				  <div style="padding-top:10px;">
				  <span class="labelForm"><%=lang.getTranslated("backend.tasse.lista.group.label.state_region")%></span><br>	 
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
							url: "/backoffice/include/ajaxstateregionupdate.aspx",
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
					<th colspan="4" align="left">
					<div style="float:left;padding-right:3px;height:15px;">
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					<input type="hidden" value="1" name="page">	
					<input type="hidden" value="taxsgroup" name="showtab">
					<input type="text" name="itemsSupg" class="formFieldTXTNumXPage" value="<%=itemsXpageSupG%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
					</form>
					</div>
					<div style="height:15px;">
					<CommonPagination:paginate ID="pg3" runat="server" index="3" maxVisiblePages="10" />
					</div>
					</th>
				</tr>
				<tr> 
				  <th>&nbsp;</th>
				  <th>&nbsp;</th>
				  <th><%=lang.getTranslated("backend.tasse.lista.table.header.descrizione_group")%></th>
				  <th><%=lang.getTranslated("backend.tasse.lista.table.header.associazioni_tasse")%></th>
			</tr> 
				<%if(bolFoundGroup) {	
					intCount = 0;
					
					for(intCount = fromGroup; intCount<= toGroup;intCount++)
					{
						SupplementGroup k = supplementGroups[intCount];%>		
						<form action="/backoffice/supplements/supplementlist.aspx" method="post" name="form_lista_tgroup_<%=intCount%>">
						<input type="hidden" value="<%=k.id%>" name="id_group">
						<input type="hidden" value="deleteGroup" name="operation">
						<input type="hidden" value="" name="value_id">
						<input type="hidden" value="" name="group_ass_match_div">
						<input type="hidden" value="LTX" name="cssClass">
						<input type="hidden" value="taxsgroup" name="showtab">
						</form> 
						<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
						<td style="text-align:center;vertical-align:top;width:25px;"><a href="javascript:openTaxsGroup('group_association_<%=intCount%>');"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.tasse.lista.table.alt.edit_taxs_group")%>" hspace="2" vspace="0" border="0"></a></td>
						<td style="text-align:center;vertical-align:top;width:25px;"><a href="javascript:deleteTaxsGroup(document.form_lista_tgroup_<%=intCount%>);"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.tasse.lista.table.alt.delete_taxs_group")%>" hspace="2" vspace="0" border="0"></a></td>
						<td style="text-align:left;vertical-align:top;width:200px;"><%=k.description%></td>
						<td>

						<%if(k.values != null && k.values.Count>0){%>
						<div id="group_association_<%=intCount%>" style="margin:0px;padding:0px;">	
						<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
							<tr>
							<th>&nbsp;</th>
							<th><%=lang.getTranslated("backend.tasse.lista.table.header.group_country")%></th>
							<th><%=lang.getTranslated("backend.tasse.lista.table.header.group_state_region")%></th>
							<th><%=lang.getTranslated("backend.tasse.lista.table.header.group_tax")%></th>
							<th><%=lang.getTranslated("backend.tasse.lista.table.header.exclude_calculation")%></th>		
							</tr>

							<%
							int innerCounter = 0;
							foreach(SupplementGroupValue q in k.values){
								//ajaxupdatefield = ""								
								//ajaxupdatefield = splitIdG&"|"&q.getCountryCode()&"|"&q.getStateRegionCode()
								%>
								<tr class="<%if(innerCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_vlist_<%=intCount%>_<%=innerCounter%>">
									<td align="center" width="25"><a href="javascript:deleteTaxsGroupValue(document.form_lista_tgroup_<%=intCount%>,'<%=q.countryCode%>','<%=q.stateRegionCode%>','group_association_<%=intCount%>','<%=q.id%>');"><img src="/backoffice/img/delete.png" alt="<%=lang.getTranslated("backend.tasse.lista.table.alt.delete_taxs_group_value")%>" hspace="2" vspace="0" border="0"></a></td>
									<td width="30%"><%if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.select.option.country."+q.countryCode))){Response.Write(lang.getTranslated("portal.commons.select.option.country."+q.countryCode));}else{Response.Write(q.countryCode);}%></td>
									<td width="40%"><%if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.select.option.country."+q.stateRegionCode))){Response.Write(lang.getTranslated("portal.commons.select.option.country."+q.stateRegionCode));}else{Response.Write(q.stateRegionCode);}%></td></td>
									<td>
									<div class="ajax" id="view_id_fee_<%=intCount%>_<%=innerCounter%>" onmouseover="javascript:showHide('view_id_fee_<%=intCount%>_<%=innerCounter%>','edit_id_fee_<%=intCount%>_<%=innerCounter%>','id_fee_<%=intCount%>_<%=innerCounter%>',500, true);">
									<%if(bolFoundLista){
										foreach(Supplement s in supplements){
											if(q.idFee==s.id){
												Response.Write(s.description);
												break;
											}
										}
									}%>
									</div>
									<div class="ajax" id="edit_id_fee_<%=intCount%>_<%=innerCounter%>">
									<select name="idFee" class="formfieldAjaxSelect" id="id_fee_<%=intCount%>_<%=innerCounter%>" onblur="javascript:updateField('edit_id_fee_<%=intCount%>_<%=innerCounter%>','view_id_fee_<%=intCount%>_<%=innerCounter%>','id_fee_<%=intCount%>_<%=innerCounter%>','SupplementGroupValue|ISupplementGroupRepository|int|getGroupValueById|updateGroupValue','<%=q.id%>',2,'<%=intCount%>_<%=innerCounter%>');">
									  <option value=""></option>
										<%
										if(bolFoundLista){
											foreach(Supplement s in supplements){%>
												<option value="<%=s.id%>" <%if(s.id==q.idFee){Response.Write("selected");}%>><%=s.description%></option>
											<%}
										}
										%>  
									</select>
									</div>
									<script>
									$("#edit_id_fee_<%=intCount%>_<%=innerCounter%>").hide();
									</script>
								</td>
								<td width="50">
									<div class="ajax" id="view_exclude_calculation_<%=intCount%>_<%=innerCounter%>" onmouseover="javascript:showHide('view_exclude_calculation_<%=intCount%>_<%=innerCounter%>','edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>','exclude_calculation_<%=intCount%>_<%=innerCounter%>',500, true);">
									<%if(!q.excludeCalculation){Response.Write(lang.getTranslated("backend.commons.no"));}else{Response.Write(lang.getTranslated("backend.commons.yes"));}%>
									</div>
									<div class="ajax" id="edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>">
									<select name="excludeCalculation" class="formfieldAjaxSelect" id="exclude_calculation_<%=intCount%>_<%=innerCounter%>" onblur="javascript:updateField('edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>','view_exclude_calculation_<%=intCount%>_<%=innerCounter%>','exclude_calculation_<%=intCount%>_<%=innerCounter%>','SupplementGroupValue|ISupplementGroupRepository|bool|getGroupValueById|updateGroupValue','<%=q.id%>',2,'<%=intCount%>_<%=innerCounter%>');">
									  <option value="0" <%if(!q.excludeCalculation){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
									  <option value="1" <%if(q.excludeCalculation){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	  
									</select>
									</div>
									<script>
									$("#edit_exclude_calculation_<%=intCount%>_<%=innerCounter%>").hide();
									</script>								
								</td>
								</tr>
								<%innerCounter++;
							}%>
			
						</table>
						</div>
						<script>					
						if(group_ass_match_div!="group_association_<%=intCount%>"){
							$('#group_association_<%=intCount%>').hide();
						}
						</script>
						<%}%>
						</td>             
						</tr>							
					<%
					}	
				}%>

				<tr> 
					<th colspan="4" align="left">
					<div style="float:left;padding-right:3px;height:15px;">
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					<input type="hidden" value="1" name="page">	
					<input type="hidden" value="taxsgroup" name="showtab">
					<input type="text" name="itemsSupg" class="formFieldTXTNumXPage" value="<%=itemsXpageSupG%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
					</form>
					</div>
					<div style="height:15px;">
					<CommonPagination:paginate ID="pg4" runat="server" index="4" maxVisiblePages="10" />
					</div>
					</th>
				</tr>	  
			</table>
			</div>		
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>