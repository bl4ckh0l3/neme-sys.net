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
var rulesStrategyMap;
rulesStrategyMap = new Hashtable();
var rulesStrategyCounter = 0;
var selectedType = <%=brule.ruleType%>;

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
})

function insertRule(){
	if(document.form_inserisci.label.value == "") {
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_label_rule")%>");
		document.form_inserisci.label.focus();
		return false;		
	}

	if(document.form_inserisci.description.value == "") {
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_desc_rule")%>");
		document.form_inserisci.description.focus();
		return false;		
	}

	var arrKeysS = rulesStrategyMap.keys();	
	var keys="";	
	for(var z=0; z<arrKeysS.length; z++){
		tmpKeyS = arrKeysS[z];
		
		if((document.form_inserisci.rule_type.value==6 || document.form_inserisci.rule_type.value==7 || document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9 || document.form_inserisci.rule_type.value==10) && $('#id_prod_orig'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_id_prod_orig_value")%>");
			$('#id_prod_orig'+tmpKeyS).focus();
			return;
		}
		if($('#rate_from'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_rate_from_value")%>");
			$('#rate_from'+tmpKeyS).focus();
			return;
		}
		if($('#rate_to'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_rate_to_value")%>");
			$('#rate_to'+tmpKeyS).focus();
			return;				
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#id_prod_ref'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_id_prod_ref_value")%>");
			$('#id_prod_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#rate_from_ref'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_rate_from_value")%>");
			$('#rate_from_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#rate_to_ref'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_rate_to_value")%>");
			$('#rate_to_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==6 || document.form_inserisci.rule_type.value==7 || document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#apply_4_qta'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_apply_4_qta_value")%>");
			$('#apply_4_qta'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#applyto'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_applyto_value")%>");
			$('#applyto'+tmpKeyS).focus();
			return;
		}
		if(document.form_inserisci.rule_type.value!=3 && document.form_inserisci.rule_type.value!=10 && $('#valore'+tmpKeyS).val() == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_rate_valore_value")%>");
			$('#valore'+tmpKeyS).focus();
			return;				
		}
		if(document.form_inserisci.rule_type.value==3 && document.form_inserisci.voucher_id.value == ""){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_voucher_id")%>");
			document.form_inserisci.voucher_id.focus();
			return;				
		}

		keys+=tmpKeyS+",";
	}
	keys = keys.substring(0, keys.lastIndexOf(','));
	document.form_inserisci.rules_strategy_counter.value=keys;
	//alert("rules_strategy_counter: "+document.form_inserisci.rules_strategy_counter.value);

	document.form_inserisci.submit();
}

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

function addStrategyValues(rulesStratCounter, type){
	var counter = rulesStratCounter;

	$("#add_field_values_div").append('<tr id="field_values_container'+counter+'" class="field_values_container"></tr>');
	$("#field_values_container"+counter).append('<td id="td_prod_orig'+counter+'"  class="id_prod_orig_elem">');
	//$("#td_prod_orig"+counter).append($('<input type="hidden"/>').attr('name', "id"+counter).attr('value', ""));		
	$("#td_prod_orig"+counter).append($('<select>').attr('name', "id_prod_orig"+counter).attr('class', "formFieldSelect").attr('id', "id_prod_orig"+counter));
	$("#id_prod_orig"+counter).append('<option value=""></option>');	
	<%
	if(hasProducts) {
		foreach(Product p in products){	
			if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
				$("#id_prod_orig"+counter).append('<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>');
			<%}
		}
	
		int catDescCounter = 0;
		string desc_cat = "";
		IList<int> excludedProd = new List<int>();
		if(categories != null && categories.Count>0){
			foreach(Category c in categories){
				bool categorySeen = false;
				foreach(Product p in products){	
					if(p.categories != null && p.categories.Count>0){
						bool catMatch = false;
						foreach(ProductCategory pc in p.categories){
							if(c.id==pc.idCategory){
								catMatch = true;
								break;
							}
						}
						
						if(catMatch && !excludedProd.Contains(p.id)){%>
							<%if(!categorySeen){%>
								$("#id_prod_orig"+counter).append('<optgroup label="<%=c.description%>" id="optgroup_prod_orig'+counter+'<%="_"+catDescCounter%>">');
								<%categorySeen=true;
							}%>
							$("#optgroup_prod_orig"+counter+"<%="_"+catDescCounter%>").append('<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>');
							<%excludedProd.Add(p.id);
						}
					}
				}
				catDescCounter++;
			}%>
		<%}
	}%>		
	
	if(type!=6 && type!=7 && type!=8 && type!=9 && type!=10){
		$(".id_prod_orig_elem").hide();
	}else{
		$(".id_prod_orig_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_rate_from'+counter+'">');
	$("#td_rate_from"+counter).append($('<input type="text"/>').attr('name', "rate_from"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_from"+counter).keypress(function(event) {return isDouble(event); }));//.blur(function(event) {return checkLastTo(counter); })	
	$("#field_values_container"+counter).append('<td id="td_rate_to'+counter+'">');
	$("#td_rate_to"+counter).append($('<input type="text"/>').attr('name', "rate_to"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_to"+counter).keypress(function(event) {return isDouble(event); }).blur(function(event) {return checkFrom(counter,false); }));
	$("#field_values_container"+counter).append('<td id="td_prod_ref'+counter+'" class="id_prod_ref_elem">');		
	$("#td_prod_ref"+counter).append($('<select>').attr('name', "id_prod_ref"+counter).attr('class', "formFieldSelect").attr('id', "id_prod_ref"+counter));
	$("#id_prod_ref"+counter).append('<option value=""></option>');	
	<%
	if(hasProducts) {
		foreach(Product p in products){	
			if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
				$("#id_prod_ref"+counter).append('<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>');
			<%}
		}
		int catDescCounter = 0;
		string desc_cat = "";
		IList<int> excludedProd = new List<int>();
		if(categories != null && categories.Count>0){%>
			<%foreach(Category c in categories){
				bool categorySeen = false;	
				foreach(Product p in products){	
					if(p.categories != null && p.categories.Count>0){
						bool catMatch = false;
						foreach(ProductCategory pc in p.categories){
							if(c.id==pc.idCategory){
								catMatch = true;
								break;
							}
						}
						
						if(catMatch && !excludedProd.Contains(p.id)){%>
							<%if(!categorySeen){%>
								$("#id_prod_ref"+counter).append('<optgroup label="<%=c.description%>" id="optgroup_prod_ref'+counter+'<%="_"+catDescCounter%>">');
								<%categorySeen=true;
							}%>
							$("#optgroup_prod_ref"+counter+"<%="_"+catDescCounter%>").append('<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>');
							<%excludedProd.Add(p.id);
						}
					}
				}
				catDescCounter++;
			}%>
		<%}
	}%>
	if(type!=8 && type!=9){
		$(".id_prod_ref_elem").hide();
	}else{
		$(".id_prod_ref_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_rate_from_ref'+counter+'" class="rate_from_ref_elem">');
	$("#td_rate_from_ref"+counter).append($('<input type="text"/>').attr('name', "rate_from_ref"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_from_ref"+counter).keypress(function(event) {return isDouble(event); }));//.blur(function(event) {return checkLastTo(counter); })	
	$("#field_values_container"+counter).append('<td id="td_rate_to_ref'+counter+'" class="rate_to_ref_elem">');
	$("#td_rate_to_ref"+counter).append($('<input type="text"/>').attr('name', "rate_to_ref"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "rate_to_ref"+counter).keypress(function(event) {return isDouble(event); }).blur(function(event) {return checkFrom(counter,true); }));
	if(type!=8 && type!=9){
		$(".rate_from_ref_elem").hide();
		$(".rate_to_ref_elem").hide();
	}else{
		$(".rate_from_ref_elem").show();
		$(".rate_to_ref_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_operation'+counter+'" class="operation_elem" align="center">');
	$("#td_operation"+counter).append($('<select>').attr('name', "operation"+counter).attr('class', "formFieldSelect").attr('id', "operation"+counter));
	$("#operation"+counter).append('<option value="0"></option>');	
	$("#operation"+counter).append('<option value="1">+</option>');
	$("#operation"+counter).append('<option value="2">-</option>');
	if(type==3 || type==10){
		$(".operation_elem").hide();
	}else{
		$(".operation_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_applyto'+counter+'" class="applyto_elem" align="center">');
	$("#td_applyto"+counter).append($('<select>').attr('name', "applyto"+counter).attr('class', "formFieldSelect").attr('id', "applyto"+counter));
	$("#applyto"+counter).append('<option value="0"></option>');	
	$("#applyto"+counter).append('<option value="1"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>');
	$("#applyto"+counter).append('<option value="2"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>');
	$("#applyto"+counter).append('<option value="3"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>');
	$("#applyto"+counter).append('<option value="4"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>');
	$("#applyto"+counter).append('<option value="5"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>');
	if(type!=8 && type!=9){
		$(".applyto_elem").hide();
	}else{
		$(".applyto_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_apply_4_qta'+counter+'" class="apply_4_qta_elem">');
	$("#td_apply_4_qta"+counter).append($('<input type="text"/>').attr('name', "apply_4_qta"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "apply_4_qta"+counter).keypress(function(event) {return isInteger(event); }));
	if(type!=6 && type!=7 && type!=8 && type!=9){
		$(".apply_4_qta_elem").hide();
	}else{
		$(".apply_4_qta_elem").show();
	}
	$("#field_values_container"+counter).append('<td id="td_valore'+counter+'" class="valore_elem">');
	$("#td_valore"+counter).append($('<input type="text"/>').attr('name', "valore"+counter).attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "valore"+counter).keypress(function(event) {return isDouble(event); }));
	if(type==3 || type==10){
		$(".valore_elem").hide();
	}else{
		$(".valore_elem").show();
	}
	
	var render='<td>&nbsp;<a class="delStrategy" href="';
	render+="javascript:delStrategyValues("+counter+",' ','field_values_container"+counter+"',0);";
	render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=lang.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a></td>';
	$("#field_values_container"+counter).append(render);

	if(type==3 || type==10){
		$(".delStrategy").hide();
	}else{
		$(".delStrategy").show();
	}

	// aggiorno la mappa dei field
	rulesStrategyMap.put(counter,counter);
	rulesStrategyCounter = counter+1;
}

function delStrategyValues(counter,id_element, field, remove){
	//alert("counter: "+counter+" - id_element: "+id_element+" - field: "+field+" - remove: "+remove);
	
	if(remove==1){
		var query_string = "id_strategy="+id_element;
		
		$.ajax({
			type: "POST",
			url: "/backoffice/business-strategy/ajaxdelstrategyvalue.aspx",
			data: query_string,
			success: function() {
			$("#"+field).remove();
			}
		});
	
		// aggiorno la mappa dei field
		rulesStrategyMap.remove(counter);
	}else{
		$("#"+field).remove();
	
		// aggiorno la mappa dei field
		rulesStrategyMap.remove(counter);
	}
}

function checkFrom(counter, ref){
	//alert("rate_from: "+$('#rate_from'+counter).val());
	//alert("rate_to: "+$('#rate_to'+counter).val());
	//alert("check: "+(Number($('#rate_to'+counter).val())<Number($('#rate_from'+counter).val())));
	var from_field = "rate_from";
	var to_field = "rate_to";
	if(ref){
		from_field+="_ref";
		to_field+="_ref";
	}	
	
	if(Number($('#'+to_field+counter).val())<Number($('#'+from_field+counter).val())){
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.wrong_rateto")%>");
		$('#'+to_field+counter).val("");
		$('#'+to_field+counter).focus();
		return;
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
		
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr>
		<td>
		<form action="/backoffice/business-strategy/insertbusinessrule.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=brule.id%>" name="id">		  
		  <input type="hidden" value="" name="rules_strategy_counter">	  
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
			<select name="rule_type" id="rule_type" class="formFieldSelect">
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
		  <div id="complex_value" <%if(brule.ruleType==3){Response.Write(" style=\"float:left;margin-right:5px;\"");}%>>
			  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.alt.strategy_value")%></span>&nbsp;<a id="addStrategyButton" href="javascript:addStrategyValues(rulesStrategyCounter,selectedType);"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.margini.detail.table.alt.add_strategy_value")%>" alt="<%=lang.getTranslated("backend.margini.detail.table.alt.add_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
			  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-nowitdh" id="add_field_values_div">
			  <tr>
			  <th class="id_prod_orig_elem"><%=lang.getTranslated("backend.margini.detail.table.label.id_prod_orig")%></th>
			  <th><%=lang.getTranslated("backend.margini.detail.table.label.rate_from")%></th>
			  <th><%=lang.getTranslated("backend.margini.detail.table.label.rate_to")%></th>
			  <th class="id_prod_ref_elem"><%=lang.getTranslated("backend.margini.detail.table.label.id_prod_ref")%></th>
			  <th class="rate_from_ref_elem"><%=lang.getTranslated("backend.margini.detail.table.label.rate_from_ref")%></th>
			  <th class="rate_to_ref_elem"><%=lang.getTranslated("backend.margini.detail.table.label.rate_to_ref")%></th>
			  <th class="operation_elem"><%=lang.getTranslated("backend.margini.detail.table.label.operation")%></th>
			  <th class="applyto_elem"><%=lang.getTranslated("backend.margini.detail.table.label.applyto")%></th>
			  <th class="apply_4_qta_elem"><%=lang.getTranslated("backend.margini.detail.table.label.apply_4_qta")%></th>
			  <th class="valore_elem"><%=lang.getTranslated("backend.margini.detail.table.label.valore")%></th>
			  <th>&nbsp;</th>
			  </tr>
			  <%
				int valuesCounter = 0;
				int totalCounter = 0;
				if(bruleconfigs != null && bruleconfigs.Count>0){
					totalCounter = bruleconfigs.Count;
				}
				
				if(totalCounter > 0){
					foreach(BusinessRuleConfig j in bruleconfigs){%>
						<tr id="field_values_container<%=valuesCounter%>" class="field_values_container">
						<td class="id_prod_orig_elem">
						<select name="id_prod_orig<%=valuesCounter%>" id="id_prod_orig<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>			
							<%
							if(hasProducts) {
								foreach(Product p in products){	
									if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
										<option value="<%=p.id%>" <%if(p.id==j.productId){Response.Write(" selected");}%>><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
									<%}
								}
								int catDescCounter = 0;
								string desc_cat = "";
								IList<int> excludedProd = new List<int>();
								if(categories != null && categories.Count>0){%>
									<%foreach(Category c in categories){
										bool categorySeen = false;	
										foreach(Product p in products){	
											if(p.categories != null && p.categories.Count>0){
												bool catMatch = false;
												foreach(ProductCategory pc in p.categories){
													if(c.id==pc.idCategory){
														catMatch = true;
														break;
													}
												}
												
												if(catMatch && !excludedProd.Contains(p.id)){%>
													<%if(!categorySeen){Response.Write("<optgroup label='"+c.description+"'>");categorySeen=true;}%>
													<option value="<%=p.id%>" <%if(p.id==j.productId){Response.Write(" selected");}%>><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
													<%excludedProd.Add(p.id);
												}
												if(!catMatch && catDescCounter>0){%>
													</optgroup>
												<%}
											}
										}
										catDescCounter++;
									}%>
								<%}
							}%>	
						</select>
						</td>						
						<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="<%=j.rateFrom.ToString("#,###0.####")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="<%=j.rateTo.ToString("#,###0.####")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,false);"></td>
						<td class="id_prod_ref_elem">
						<select name="id_prod_ref<%=valuesCounter%>" id="id_prod_ref<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>
							<%
							if(hasProducts) {
								foreach(Product p in products){	
									if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
										<option value="<%=p.id%>" <%if(p.id==j.productRefId){Response.Write(" selected");}%>><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
									<%}
								}
								int catDescCounter = 0;
								string desc_cat = "";
								IList<int> excludedProd = new List<int>();
								if(categories != null && categories.Count>0){%>
									<%foreach(Category c in categories){
										bool categorySeen = false;	
										foreach(Product p in products){	
											if(p.categories != null && p.categories.Count>0){
												bool catMatch = false;
												foreach(ProductCategory pc in p.categories){
													if(c.id==pc.idCategory){
														catMatch = true;
														break;
													}
												}
												
												if(catMatch && !excludedProd.Contains(p.id)){%>
													<%if(!categorySeen){Response.Write("<optgroup label='"+c.description+"'>");categorySeen=true;}%>
													<option value="<%=p.id%>" <%if(p.id==j.productRefId){Response.Write(" selected");}%>><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
													<%excludedProd.Add(p.id);
												}
												if(!catMatch && catDescCounter>0){%>
													</optgroup>
												<%}
											}
										}
										catDescCounter++;
									}%>
								<%}
							}%>	
						</select>
						</td>						
						<td class="rate_from_ref_elem"><input type="text" name="rate_from_ref<%=valuesCounter%>" id="rate_from_ref<%=valuesCounter%>" value="<%=j.rateRefFrom.ToString("#,###0.####")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td class="rate_to_ref_elem"><input type="text" name="rate_to_ref<%=valuesCounter%>" id="rate_to_ref<%=valuesCounter%>" value="<%=j.rateRefTo.ToString("#,###0.####")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,true);"></td>
						<td class="operation_elem" align="center">
						<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
							<option value="0"></option>
							<option value="1"<%if (1==j.operation){Response.Write(" selected");}%>>+</option>	
							<option value="2"<%if (2==j.operation){Response.Write(" selected");}%>>-</option>
						</select>
						</td>
						<td class="applyto_elem">
						<select name="applyto<%=valuesCounter%>" id="applyto<%=valuesCounter%>" class="formFieldSelect">
							<option value="0"></option>
							<option value="1"<%if (1==j.applyTo){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>	
							<option value="2"<%if (2==j.applyTo){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>	
							<option value="3"<%if (3==j.applyTo){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>	
							<option value="4"<%if (4==j.applyTo){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>	
							<option value="5"<%if (5==j.applyTo){Response.Write(" selected");}%>><%=lang.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>
						</select>
						</td>
						<td class="apply_4_qta_elem"><input type="text" name="apply_4_qta<%=valuesCounter%>" id="apply_4_qta<%=valuesCounter%>" value="<%=j.applyToQuantity%>" class="formFieldTXTMedium" onkeypress="javascript:return isInteger(event);"></td>
						<td class="valore_elem"><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="<%=j.value.ToString("#,###0.####")%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td>&nbsp;<a class="delStrategy" href="javascript:delStrategyValues(<%=valuesCounter%>,'<%=j.id%>','field_values_container<%=valuesCounter%>',1);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" alt="<%=lang.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
						<script>
						// aggiorno la mappa dei field
						rulesStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
						</script></td>
						</tr>
					<%valuesCounter++;
					}
				}
			  
			  if(valuesCounter == 0) {%>
				<tr id="field_values_container<%=valuesCounter%>" class="field_values_container">
			  	<td class="id_prod_orig_elem">		
				<select name="id_prod_orig<%=valuesCounter%>" id="id_prod_orig<%=valuesCounter%>" class="formFieldSelect">
					<option value=""></option>
					<%
					if(hasProducts) {
						foreach(Product p in products){	
							if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
								<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
							<%}
						}
						int catDescCounter = 0;
						string desc_cat = "";
						IList<int> excludedProd = new List<int>();
						if(categories != null && categories.Count>0){%>
							<%foreach(Category c in categories){
								bool categorySeen = false;	
								foreach(Product p in products){	
									if(p.categories != null && p.categories.Count>0){
										bool catMatch = false;
										foreach(ProductCategory pc in p.categories){
											if(c.id==pc.idCategory){
												catMatch = true;
												break;
											}
										}
										
										if(catMatch && !excludedProd.Contains(p.id)){%>
											<%if(!categorySeen){Response.Write("<optgroup label='"+c.description+"'>");categorySeen=true;}%>
											<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
											<%excludedProd.Add(p.id);
										}
										if(!catMatch && catDescCounter>0){%>
											</optgroup>
										<%}
									}
								}
								catDescCounter++;
							}%>
						<%}
					}%>
				</select>
				</td>				
				<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,false);"></td>	
				<td class="id_prod_ref_elem">
				<select name="id_prod_ref<%=valuesCounter%>" id="id_prod_ref<%=valuesCounter%>" class="formFieldSelect">
					<option value=""></option>
					<%
					if(hasProducts) {
						foreach(Product p in products){	
							if(p.categories == null || (p.categories != null && p.categories.Count==0)){%>
								<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
							<%}
						}
						int catDescCounter = 0;
						string desc_cat = "";
						IList<int> excludedProd = new List<int>();
						if(categories != null && categories.Count>0){%>
							<%foreach(Category c in categories){
								bool categorySeen = false;	
								foreach(Product p in products){	
									if(p.categories != null && p.categories.Count>0){
										bool catMatch = false;
										foreach(ProductCategory pc in p.categories){
											if(c.id==pc.idCategory){
												catMatch = true;
												break;
											}
										}
										
										if(catMatch && !excludedProd.Contains(p.id)){%>
											<%if(!categorySeen){Response.Write("<optgroup label='"+c.description+"'>");categorySeen=true;}%>
											<option value="<%=p.id%>"><%=p.name%>&nbsp;(<%=p.keyword%>)</option>
											<%excludedProd.Add(p.id);
										}
										if(!catMatch && catDescCounter>0){%>
											</optgroup>
										<%}
									}
								}
								catDescCounter++;
							}%>
						<%}
					}%>	
				</select>
				</td>						
				<td class="rate_from_ref_elem"><input type="text" name="rate_from_ref<%=valuesCounter%>" id="rate_from_ref<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td class="rate_to_ref_elem"><input type="text" name="rate_to_ref<%=valuesCounter%>" id="rate_to_ref<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,true);"></td>			
				<td class="operation_elem" align="center">
				<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
					<option value="0"></option>
					<option value="1">+</option>	
					<option value="2">-</option>
				</select>
				</td>
				<td class="applyto_elem">
				<select name="applyto<%=valuesCounter%>" id="applyto<%=valuesCounter%>" class="formFieldSelect">
					<option value="0"></option>
					<option value="1"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>	
					<option value="2"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>	
					<option value="3"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>	
					<option value="4"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>	
					<option value="5"><%=lang.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>
				</select>
				</td>
				<td class="apply_4_qta_elem"><input type="text" name="apply_4_qta<%=valuesCounter%>" id="apply_4_qta<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isInteger(event);"></td>
				<td class="valore_elem"><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td>&nbsp;<a class="delStrategy" href="javascript:delStrategyValues(<%=valuesCounter%>,' ','field_values_container<%=valuesCounter%>',0);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" alt="<%=lang.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
				<script>
				// aggiorno la mappa dei field
				rulesStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
				</script></td>
				</tr>
				<%valuesCounter++;
			  }%>
			  </table>
			  <script>
			  rulesStrategyCounter = <%=valuesCounter%>;
			  </script>

		  </div>	
		  <div align="left" id="voucher_id">
		  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.voucher_id")%></span><br>
		  <select name="voucher_id" id="voucher_id">
		  <option value=""></option>
		  <%
		  if(hasVoucherCampaign){
			//foreach(VoucherCampaign vc in voucherCampaign){%>
				<option value="<%//=vc.id%>" <%//if(vc.id=brule.voucherId){Response.Write(" selected");}%>><%//=vc.label%></option>
			<%//}
		  }%>
		  </select>&nbsp;&nbsp;
		  </div>

			<script>
			$('#rule_type').change(function() {
				var rule_type_val_ch = $('#rule_type').val();
				selectedType = rule_type_val_ch;
				//alert("rule_type_val_ch: "+rule_type_val_ch);
				if(rule_type_val_ch==3){
					$(".field_values_container").remove();
					rulesStrategyMap.clear();
					addStrategyValues(rulesStrategyCounter,selectedType);
					$('#complex_value').attr('style', "float:left;margin-right:5px;");
					
					$("#voucher_id").show();
					$(".id_prod_orig_elem").hide();
					$(".id_prod_ref_elem").hide();
					$(".rate_from_ref_elem").hide();
					$(".rate_to_ref_elem").hide();
					$(".operation_elem").hide();
					$(".applyto_elem").hide();
					$(".apply_4_qta_elem").hide();
					$(".valore_elem").hide();
					$(".delStrategy").hide();
					$("#addStrategyButton").hide();					
				}else if(rule_type_val_ch==1 || rule_type_val_ch==2 || rule_type_val_ch==4 || rule_type_val_ch==5){
					$('#complex_value').attr('style', "float:top;margin-right:0px;");
					$("#voucher_id").hide();
					$(".id_prod_orig_elem").hide();
					$(".id_prod_ref_elem").hide();
					$(".rate_from_ref_elem").hide();
					$(".rate_to_ref_elem").hide();
					$(".applyto_elem").hide();
					$(".apply_4_qta_elem").hide();
					$(".operation_elem").show();
					$(".valore_elem").show();
					$(".delStrategy").show();
					$("#addStrategyButton").show();
				}else if(rule_type_val_ch==6 || rule_type_val_ch==7){
					$('#complex_value').attr('style', "float:top;margin-right:0px;");
					$("#voucher_id").hide();
					$(".id_prod_orig_elem").show();
					$(".id_prod_ref_elem").hide();
					$(".rate_from_ref_elem").hide();
					$(".rate_to_ref_elem").hide();
					$(".operation_elem").show();
					$(".applyto_elem").hide();
					$(".apply_4_qta_elem").show();
					$(".valore_elem").show();
					$(".delStrategy").show();
					$("#addStrategyButton").show();
				}else if(rule_type_val_ch==10){
					$(".field_values_container").remove();
					rulesStrategyMap.clear();
					addStrategyValues(rulesStrategyCounter,selectedType);
					$('#complex_value').attr('style', "float:top;margin-right:0px;");
				
					$("#voucher_id").hide();
					$(".id_prod_orig_elem").show();
					$(".id_prod_ref_elem").hide();
					$(".rate_from_ref_elem").hide();
					$(".rate_to_ref_elem").hide();
					$(".operation_elem").hide();
					$(".applyto_elem").hide();
					$(".apply_4_qta_elem").hide();
					$(".valore_elem").hide();
					$(".delStrategy").hide();
					$("#addStrategyButton").hide();					
				}else{
					$('#complex_value').attr('style', "float:top;margin-right:0px;");
					$("#voucher_id").hide();
					$(".id_prod_orig_elem").show();
					$(".id_prod_ref_elem").show();
					$(".rate_from_ref_elem").show();
					$(".rate_to_ref_elem").show();
					$(".operation_elem").show();
					$(".applyto_elem").show();
					$(".apply_4_qta_elem").show();
					$(".valore_elem").show();
					$(".delStrategy").show();
					$("#addStrategyButton").show();				
				}
			});
	
			var rule_type_val = $('#rule_type').val();
			if(rule_type_val==3){
				$('#complex_value').attr('style', "float:left;margin-right:5px;");
				$("#voucher_id").show();
				$(".id_prod_orig_elem").hide();
				$(".id_prod_ref_elem").hide();
				$(".rate_from_ref_elem").hide();
				$(".rate_to_ref_elem").hide();
				$(".operation_elem").hide();
				$(".applyto_elem").hide();
				$(".apply_4_qta_elem").hide();
				$(".valore_elem").hide();
				$(".delStrategy").hide();
				$("#addStrategyButton").hide();
			}else if(rule_type_val==1 || rule_type_val==2 || rule_type_val==4 || rule_type_val==5){
				$('#complex_value').attr('style', "float:top;margin-right:0px;");
				$("#voucher_id").hide();
				$(".id_prod_orig_elem").hide();
				$(".id_prod_ref_elem").hide();
				$(".rate_from_ref_elem").hide();
				$(".rate_to_ref_elem").hide();
				$(".applyto_elem").hide();
				$(".apply_4_qta_elem").hide();
				$(".operation_elem").show();
				$(".valore_elem").show();
				$(".delStrategy").show();
				$("#addStrategyButton").show();
			}else if(rule_type_val==6 || rule_type_val==7){
				$('#complex_value').attr('style', "float:top;margin-right:0px;");
				$("#voucher_id").hide();
				$(".id_prod_orig_elem").show();
				$(".id_prod_ref_elem").hide();
				$(".rate_from_ref_elem").hide();
				$(".rate_to_ref_elem").hide();
				$(".operation_elem").show();
				$(".applyto_elem").hide();
				$(".apply_4_qta_elem").show();
				$(".valore_elem").show();
				$(".delStrategy").show();
				$("#addStrategyButton").show();
			}else if(rule_type_val==10){		
				$('#complex_value').attr('style', "float:top;margin-right:0px;");		
				$("#voucher_id").hide();
				$(".id_prod_orig_elem").show();
				$(".id_prod_ref_elem").hide();
				$(".rate_from_ref_elem").hide();
				$(".rate_to_ref_elem").hide();
				$(".operation_elem").hide();
				$(".applyto_elem").hide();
				$(".apply_4_qta_elem").hide();
				$(".valore_elem").hide();
				$(".delStrategy").hide();
				$("#addStrategyButton").hide();					
			}else{
				$('#complex_value').attr('style', "float:top;margin-right:0px;");
				$("#voucher_id").hide();
				$(".id_prod_orig_elem").show();
				$(".id_prod_ref_elem").show();
				$(".rate_from_ref_elem").show();
				$(".rate_to_ref_elem").show();
				$(".operation_elem").show();
				$(".applyto_elem").show();
				$(".apply_4_qta_elem").show();
				$(".valore_elem").show();
				$(".delStrategy").show();
				$("#addStrategyButton").show();				
			}
			</script>
		</form>
		</td></tr>
		</table><br/> 
		
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.margini.lista.button.label.inserisci_rule")%>" onclick="javascript:insertRule();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/business-strategy/strategylist.aspx?cssClass=<%=cssClass%>&showtab=businessrulelist';" />
		<br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>