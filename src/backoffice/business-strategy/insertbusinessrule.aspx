<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertbusinessrule.aspx.cs" Inherits="_BusinessRule" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<SCRIPT SRC="/common/js/hashtable.js"></SCRIPT>
<script language="JavaScript">
var billsMapM, billsMapR;
billsMapM = new Hashtable();
billsMapR = new Hashtable();

var billsStrategyMap;
billsStrategyMap = new Hashtable();
var billsStrategyCounter = 0;

var selectedType = <%=brule.ruleType%>;

<%
/*if(bolFoundLista){
	string oldgroupname = "";
	
	foreach (Fee f in fees){
		if(!f.autoactive && !oldgroupname.Equals(f.feeGroup)){
			Response.Write("billsMapM.put('"+f.feeGroup+"','"+Convert.ToInt32(f.multiply)+"');");
			Response.Write("billsMapR.put('"+f.feeGroup+"','"+Convert.ToInt32(f.required)+"');");
			oldgroupname = f.feeGroup;
		}
	}
}*/
%>


function insertRule(){
	
	if(document.form_inserisci.descrizione.value == ""){
		alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.descrizione.focus();
		return;
	}
	
	if((document.form_inserisci.tipo_valore.value==1 || document.form_inserisci.tipo_valore.value==2) && document.form_inserisci.valore.value == ""){
		alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.valore.focus();
		return;
	}else if(document.form_inserisci.tipo_valore.value!=1 && document.form_inserisci.tipo_valore.value!=2){
		document.form_inserisci.valore.value = 0;
	}

	if(document.form_inserisci.autoactive.value == 0 && (document.form_inserisci.group.value == "" || !checkGroupFormat(document.form_inserisci.group.value))){
		alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_correct_group")%>");		
		document.form_inserisci.group.focus();
		return;
	}

	var arrKeys = billsMapM.keys();	
	var sel_value = "";
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = billsMapM.get(tmpKey);
		if(tmpKey == document.form_inserisci.group.value && !(document.form_inserisci.multiply.value == tmpValue)){
			if(tmpValue==0){sel_value = "<%=lang.getTranslated("backend.commons.no")%>";}else{sel_value = "<%=lang.getTranslated("backend.commons.yes")%>";}
			alert(tmpKey+" <%=lang.getTranslated("backend.spese.detail.js.alert.insert_correct_multiply")%> "+sel_value+"!");
			return;
		}
	}

	var arrKeysR = billsMapR.keys();	
	var sel_valueR = "";
	for(var z=0; z<arrKeysR.length; z++){
		tmpKeyR = arrKeysR[z];
		tmpValueR = billsMapR.get(tmpKeyR);
		if(tmpKeyR == document.form_inserisci.group.value && !(document.form_inserisci.required.value == tmpValueR)){
			if(tmpValueR==0){sel_valueR = "<%=lang.getTranslated("backend.commons.no")%>";}else{sel_valueR = "<%=lang.getTranslated("backend.commons.yes")%>";}
			alert(tmpKeyR+" <%=lang.getTranslated("backend.spese.detail.js.alert.insert_correct_required")%> "+sel_valueR+"!");
			return;
		}
	}

	if(document.form_inserisci.tipo_valore.value!=1 && document.form_inserisci.tipo_valore.value!=2){	
		var arrKeysS = billsStrategyMap.keys();	
		var keys="";	
		for(var z=0; z<arrKeysS.length; z++){
			tmpKeyS = arrKeysS[z];
			
			if((document.form_inserisci.tipo_valore.value==7 || document.form_inserisci.tipo_valore.value==8) && $('#id_prod_field'+tmpKeyS).val() == ""){
				alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_id_prod_field_value")%>");
				$('#id_prod_field'+tmpKeyS).focus();
				return;
			}else if($('#rate_from'+tmpKeyS).val() == ""){
				alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_rate_from_value")%>");
				$('#rate_from'+tmpKeyS).focus();
				return;
			}else if($('#rate_to'+tmpKeyS).val() == ""){
				alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_rate_to_value")%>");
				$('#rate_to'+tmpKeyS).focus();
				return;				
			}else if($('#valore'+tmpKeyS).val() == ""){
				alert("<%=lang.getTranslated("backend.spese.detail.js.alert.insert_rate_valore_value")%>");
				$('#valore'+tmpKeyS).focus();
				return;				
			}

			keys+=tmpKeyS+",";
		}
		keys = keys.substring(0, keys.lastIndexOf(','));
		document.form_inserisci.bills_strategy_counter.value=keys;
	}
	//alert("bills_strategy_counter: "+document.form_inserisci.bills_strategy_counter.value);
	//alert("valore: "+document.form_inserisci.valore.value);	
	
	document.form_inserisci.submit();
}

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
})

function showDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;

	element.style.left=tempX+10;
	element.style.top=tempY+10;
	$(jquery_id).show(500);
	element.style.visibility = 'visible';		
	element.style.display = "block";
}

function hideDiv(elemID){
	var element = document.getElementById(elemID);

	element.style.visibility = 'hidden';
	element.style.display = "none";
}

function addStrategyValues(billsStratCounter, type){
	var counter = billsStratCounter;

	$("#add_field_values_div").append('<tr id="field_values_container'+counter+'"></tr>');
	$("#field_values_container"+counter).append('<td id="td_prod_field'+counter+'"  class="id_prod_field_elem">');
	$("#td_prod_field"+counter).append($('<input type="hidden"/>').attr('name', "id"+counter).attr('value', ""));		
	$("#td_prod_field"+counter).append($('<select>').attr('name', "id_prod_field"+counter).attr('class', "formFieldSelect").attr('id', "id_prod_field"+counter));
	$("#id_prod_field"+counter).append('<option value=""></option>');	
	<%/*foreach(ProductField f in productFields){%>
		$("#id_prod_field"+counter).append('<option value="<%//=f.description%>"><%//=f.description%></option>');
	<%}*/%>	
	if(type!=7 && type!=8){
		$(".id_prod_field_elem").hide();
	}else{
		$(".id_prod_field_elem").show();
	}
					
	$("#field_values_container"+counter).append('<td id="td_rate_from'+counter+'">');
	$("#td_rate_from"+counter).append($('<input type="text"/>').attr('name', "rate_from"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_from"+counter).keypress(function(event) {return isDouble(event); }));//.blur(function(event) {return checkLastTo(counter); })	
	$("#field_values_container"+counter).append('<td id="td_rate_to'+counter+'">');
	$("#td_rate_to"+counter).append($('<input type="text"/>').attr('name', "rate_to"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_to"+counter).keypress(function(event) {return isDouble(event); }).blur(function(event) {return checkFrom(counter); }));
	$("#field_values_container"+counter).append('<td id="td_operation'+counter+'" class="operation_elem" align="center">');
	$("#td_operation"+counter).append($('<select>').attr('name', "operation"+counter).attr('class', "formFieldSelect").attr('id', "operation"+counter));	
	$("#operation"+counter).append('<option value="1">+</option>');
	$("#operation"+counter).append('<option value="2">-</option>');
	if(type!=6 && type!=8){
		$(".operation_elem").hide();
	}else{
		$(".operation_elem").show();
	}
	
	$("#field_values_container"+counter).append('<td id="td_valore'+counter+'">');
	$("#td_valore"+counter).append($('<input type="text"/>').attr('name', "valore"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "valore"+counter).keypress(function(event) {return isDouble(event); }));
	
	var render='<td>&nbsp;<a href="';
	render+="javascript:delStrategyValues("+counter+",' ','field_values_container"+counter+"',0);";
	render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a></td>';
	$("#field_values_container"+counter).append(render);

	// aggiorno la mappa dei field
	billsStrategyMap.put(counter,counter);
	billsStrategyCounter = counter+1;
} 

function delStrategyValues(counter,id_element, field, remove){
	//alert("counter: "+counter+" - id_element: "+id_element+" - field: "+field+" - remove: "+remove);
	
	if(remove==1){
		var query_string = "id_strategy="+id_element;
		
		$.ajax({
			type: "POST",
			url: "/backoffice/fees/ajaxdelstrategyvalue.aspx",
			data: query_string,
			success: function() {
			$("#"+field).remove();
			}
		});
	
		// aggiorno la mappa dei field
		billsStrategyMap.remove(counter);
	}else{
		$("#"+field).remove();
	
		// aggiorno la mappa dei field
		billsStrategyMap.remove(counter);
	}
}

function checkFrom(counter){
	//alert("rate_from: "+$('#rate_from'+counter).val());
	//alert("rate_to: "+$('#rate_to'+counter).val());
	//alert("check: "+(Number($('#rate_to'+counter).val())<Number($('#rate_from'+counter).val())));
	if(Number($('#rate_to'+counter).val())<Number($('#rate_from'+counter).val())){
		alert("<%=lang.getTranslated("backend.spese.detail.js.alert.wrong_rateto")%>");
		$('#rate_to'+counter).val("");
		$('#rate_to'+counter).focus();
		return;
	}		
}
/*function checkLastTo(counter){
	if(counter>0){
		//alert("counter: "+counter);
		var last_to = $('#rate_to'+counter).val();
		$('#add_field_values_div').find("select[name*='id_prod_field']").each( function(){
			//alert("name: "+$(this).attr("name"));
			if($(this).attr("name")!="id_prod_field"+counter){
				var this_name = $(this).attr("name");
				//alert("this_name: "+this_name);
				var suffix_counter = this_name.substring(this_name.lastIndexOf("id_prod_field")+13,this_name.length);
				//alert("suffix_counter: "+suffix_counter);
				//alert("last_to: "+$('#rate_to'+suffix_counter).val());
				last_to = $('#rate_to'+suffix_counter).val();
			}else{return false;}
		});
		alert("last_to: "+last_to);
		alert("rate_from: "+$('#rate_from'+counter).val());
		alert("check: "+(Number(last_to)<Number($('#rate_from'+counter).val())));
		if(Number(last_to)<Number($('#rate_from'+counter).val())){
			alert("<%=lang.getTranslated("backend.spese.detail.js.alert.wrong_ratefrom")%>");
			$('#rate_from'+counter).val("");
			$('#rate_from'+counter).focus();
			return;			
		}	
	}		
}*/ 
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr>
		<td>
		<form action="/backoffice/business-strategy/insertbusinessrule.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=brule.id%>" name="id">		  
		  <input type="hidden" value="" name="bills_strategy_counter">	  
		  <input type="hidden" value="insert" name="operation">
		  
		  
		  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.label_rule")%></span><br>
		  <input type="text" name="label" value="<%=brule.label%>" class="formFieldTXTLong">
		  <a href="javascript:showHideDiv('label_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>
			<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="label_ml">
			<%
			foreach (Language x in languages){%>
			<input type="text" hspace="2" vspace="2" name="label_<%=x.label%>" id="label_<%=x.label%>" value="<%=mlangrep.translate("backend.businessrule.label.label."+brule.label, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>				
			</div>
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.desc_rule")%></span><br>
		  <textarea name="description" class="formFieldTXTAREAAbstract"><%=brule.description%></textarea>
		  </div>	
		  <br/>		 	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.activate_rule")%></span><br>
			<select name="active" class="formFieldTXTShort">
			<option value="0"<%if (!brule.active) {Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if (brule.active) {Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>
		  <br/><br/>
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.tipo_rule")%></span><br>
			<select name="rule_type" id="rule_type" class="formFieldTXTLong">
			<%if(showOneTwo){%>
			<option value="1" <%if (1==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.amount_order_rule")%></option>	
			<option value="2" <%if (2==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.percentage_order_rule")%></option>
			<%}%>
<!--nsys-voucher2--> 
			<option value="3" <%if (3==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.voucher_order_rule")%></option>
<!---nsys-voucher2-->
			<%if(showFourFive){%>
			<option value="4" <%if (4==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.first_amount_order_rule")%></option>	
			<option value="5" <%if (5==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.first_percentage_order_rule")%></option>
			<%}%>
			<option value="6" <%if (6==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.amount_qta_product_rule")%></option>	
			<option value="7" <%if (7==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.percentage_qta_product_rule")%></option>	
			<option value="8" <%if (8==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.amount_related_product_rule")%></option>
			<option value="9" <%if (9==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.percentage_related_product_rule")%></option>
			<option value="10" <%if (10==brule.ruleType){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.label.exclude_bills_product_rule")%></option>				
			</SELECT>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_type_value');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_type_value');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:550px;" id="help_desc_type_value">
			  <%=lang.getTranslated("backend.margini.detail.table.label.help_rule_type_value")%>
			  </div>	
		  </div>
		  <br><br>
		  <div align="left" id="complex_value">
			  <span class="labelForm"><%=lang.getTranslated("backend.spese.detail.table.alt.strategy_value")%></span>&nbsp;<a href="javascript:addStrategyValues(billsStrategyCounter,selectedType);"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.spese.detail.table.alt.add_strategy_value")%>" alt="<%=lang.getTranslated("backend.spese.detail.table.alt.add_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
			  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-nowitdh" id="add_field_values_div">
			  <tr>
			  <th class="id_prod_field_elem"><%=lang.getTranslated("backend.spese.detail.table.label.id_field_prod")%></th>
			  <th><%=lang.getTranslated("backend.spese.detail.table.label.rate_from")%></th>
			  <th><%=lang.getTranslated("backend.spese.detail.table.label.rate_to")%></th>
			  <th class="operation_elem"><%=lang.getTranslated("backend.spese.detail.table.label.operation")%></th>
			  <th><%=lang.getTranslated("backend.spese.detail.table.label.valore")%></th>
			  <th>&nbsp;</th>
			  </tr>
			  <%
				int valuesCounter = 0;
				int totalCounter = 0;
				
				//if(fee.configs != null && fee.configs.Count>0){
				//	totalCounter = fee.configs.Count;
				//}
				
				if(totalCounter > 0) {					
					//foreach(FeeConfig j in fee.configs){%>
						<tr id="field_values_container<%=valuesCounter%>">
						<td class="id_prod_field_elem">
						<input type="hidden" name="id<%=valuesCounter%>" value="<%//=j.id%>">
						<select name="id_prod_field<%=valuesCounter%>" id="id_prod_field<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>
							<%//if(bolFoundProdF){
								//foreach(ProductField pf in productFields){%>
									<option value="<%//=pf.description%>" <%//if (j.descProdField != null && pf.description==j.descProdField) { Response.Write("selected");}%>><%//=pf.description%></option>
								<%//}
							//}%> 
						</select>
						</td>						
						<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="<%//=j.rateFrom.ToString("#0.##")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="<%//=j.rateTo.ToString("#0.##")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>);"></td>
						<td class="operation_elem" align="center">
						<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
							<option value="1"<%//if (1==j.operation) {Response.Write(" selected");}%>>+</option>	
							<option value="2"<%//if (2==j.operation) {Response.Write(" selected");}%>>-</option>
						</select>
						</td>
						<td><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="<%//=j.value.ToString("#0.00")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td>&nbsp;<a href="javascript:delStrategyValues(<%=valuesCounter%>,'<%//=j.id%>','field_values_container<%=valuesCounter%>',1);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" alt="<%=lang.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
						<script>
							// aggiorno la mappa dei field
							billsStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
						</script>
						</td>
						</tr>
						<%valuesCounter++;
					//}
				}
			  
				if(valuesCounter == 0) {%>
					<tr id="field_values_container<%=valuesCounter%>">
					<td class="id_prod_field_elem">
					<input type="hidden" name="id<%=valuesCounter%>" value="-1">			
					<select name="id_prod_field<%=valuesCounter%>" id="id_prod_field<%=valuesCounter%>" class="formFieldSelect">
						<option value=""></option>
						<%//if(bolFoundProdF){
							//foreach(ProductField pf in productFields){%>
								<option value="<%//=pf.description%>"><%//=pf.description%></option>
							<%//}
						//}%> 
					</select>
					</td>				
					<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
					<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>);"></td>
					<td class="operation_elem" align="center">
					<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
						<option value="1">+</option>	
						<option value="2">-</option>
					</select></td>
					<td><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
					<td>&nbsp;<a href="javascript:delStrategyValues(<%=valuesCounter%>,' ','field_values_container<%=valuesCounter%>',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" alt="<%=lang.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
					<script>
						// aggiorno la mappa dei field
						billsStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
					</script>
					</td>
					</tr>
					<%valuesCounter++;
				}%>
				</table>
				<script>
					billsStrategyCounter = <%=valuesCounter%>;
				</script>
			</div>
			<br>

			<script>
			$('#tipo_valore').change(function() {
				var tipo_valore_val_ch = $('#tipo_valore').val();
				selectedType = tipo_valore_val_ch;
				//alert("tipo_valore_val_ch: "+tipo_valore_val_ch);
				if(tipo_valore_val_ch==1 || tipo_valore_val_ch==2){
					$("#simple_value").show();
					$("#complex_value").hide();
				}else{
					$("#simple_value").hide();
					if(tipo_valore_val_ch!=7 && tipo_valore_val_ch!=8){
						$(".id_prod_field_elem").hide();
					}else{
						$(".id_prod_field_elem").show();
						//alert("mostro id_prod_field td");
					}
					if(tipo_valore_val_ch!=6 && tipo_valore_val_ch!=8){
						$(".operation_elem").hide();
					}else{
						$(".operation_elem").show();
						//alert("mostro operation td");
					}
					$("#complex_value").show();
				}
			});
	
			var tipo_valore_val = $('#tipo_valore').val();
			if(tipo_valore_val==1 || tipo_valore_val==2){
				$("#simple_value").show();
				$("#complex_value").hide();
			}else{
				$("#simple_value").hide();
				if(tipo_valore_val!=7 && tipo_valore_val!=8){
					$(".id_prod_field_elem").hide();
				}else{
					$(".id_prod_field_elem").show();
				}
				if(tipo_valore_val!=6 && tipo_valore_val!=8){
					$(".operation_elem").hide();
				}else{
					$(".operation_elem").show();
				}
				$("#complex_value").show();
			}
			</script>
		</form>
		
		</td></tr>
		</table>	<br> 
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.margini.lista.button.label.inserisci_rule")%>" onclick="javascript:insertRule();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/business-strategy/strategylist.aspx?cssClass=<%=cssClass%>&showtab=businessrulelist';" />
		<br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>