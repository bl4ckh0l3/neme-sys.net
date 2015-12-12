<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init4.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<script language="JavaScript">
var rulesStrategyMap;
rulesStrategyMap = new Hashtable();
var rulesStrategyCounter = 0;
var selectedType = <%=rule_type%>;

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
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_label_rule")%>");
		document.form_inserisci.label.focus();
		return false;		
	}

	if(document.form_inserisci.descrizione.value == "") {
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_desc_rule")%>");
		document.form_inserisci.descrizione.focus();
		return false;		
	}

	var arrKeysS = rulesStrategyMap.keys();	
	var keys="";	
	for(var z=0; z<arrKeysS.length; z++){
		tmpKeyS = arrKeysS[z];
		
		if((document.form_inserisci.rule_type.value==6 || document.form_inserisci.rule_type.value==7 || document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9 || document.form_inserisci.rule_type.value==10) && $('#id_prod_orig'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_id_prod_orig_value")%>");
			$('#id_prod_orig'+tmpKeyS).focus();
			return;
		}
		if($('#rate_from'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_rate_from_value")%>");
			$('#rate_from'+tmpKeyS).focus();
			return;
		}
		if($('#rate_to'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_rate_to_value")%>");
			$('#rate_to'+tmpKeyS).focus();
			return;				
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#id_prod_ref'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_id_prod_ref_value")%>");
			$('#id_prod_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#rate_from_ref'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_rate_from_value")%>");
			$('#rate_from_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#rate_to_ref'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_rate_to_value")%>");
			$('#rate_to_ref'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==6 || document.form_inserisci.rule_type.value==7 || document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#apply_4_qta'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_apply_4_qta_value")%>");
			$('#apply_4_qta'+tmpKeyS).focus();
			return;
		}
		if((document.form_inserisci.rule_type.value==8 || document.form_inserisci.rule_type.value==9) && $('#applyto'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_applyto_value")%>");
			$('#applyto'+tmpKeyS).focus();
			return;
		}
		if(document.form_inserisci.rule_type.value!=3 && document.form_inserisci.rule_type.value!=10 && $('#valore'+tmpKeyS).val() == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_rate_valore_value")%>");
			$('#valore'+tmpKeyS).focus();
			return;				
		}
		if(document.form_inserisci.rule_type.value==3 && document.form_inserisci.voucher_id.value == ""){
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_voucher_id")%>");
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
	if (bolHasListProd) then
		counter = 0
		desc_cat = ""
		bolStart = true

		for each k in objListRefProd					
			Set objTmp = objListRefProd(k)
			bolIncrCount = false%>
			<%if(desc_cat <>objTmp.getDescCatRelProd())then%>
				$("#id_prod_orig"+counter).append('<optgroup label="<%=objTmp.getDescCatRelProd()%>" id="optgroup_prod_orig'+counter+'<%="_"&counter%>">');
				<%if not(bolStart)then bolIncrCount=true end if
				bolStart=false
			end if%>
			$("#optgroup_prod_orig"+counter+"<%="_"&counter%>").append('<option value="<%=objTmp.getIDProdotto()%>"><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>');
			<%
			desc_cat = objTmp.getDescCatRelProd()
			Set objTmp = nothing
			if(bolIncrCount)then
				counter = counter +1
			end if
		next
	end if%>	
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
	if (bolHasListProd) then
		counter = 0
		desc_cat = ""
		bolStart = true

		for each k in objListRefProd					
			Set objTmp = objListRefProd(k)%>
			<%if(desc_cat <>objTmp.getDescCatRelProd())then%>
				$("#id_prod_ref"+counter).append('<optgroup label="<%=objTmp.getDescCatRelProd()%>" id="optgroup_prod_ref'+counter+'<%="_"&counter%>">');
				<%if not(bolStart)then bolIncrCount=true end if
				bolStart=false
			end if%>
			$("#optgroup_prod_ref"+counter+"<%="_"&counter%>").append('<option value="<%=objTmp.getIDProdotto()%>"><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>');
			<%
			desc_cat = objTmp.getDescCatRelProd()
			Set objTmp = nothing
			if(bolIncrCount)then
				counter = counter +1
			end if
		next
	end if%>	
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
	$("#applyto"+counter).append('<option value="1"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>');
	$("#applyto"+counter).append('<option value="2"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>');
	$("#applyto"+counter).append('<option value="3"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>');
	$("#applyto"+counter).append('<option value="4"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>');
	$("#applyto"+counter).append('<option value="5"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>');
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
	render+='"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a></td>';
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
			url: "<%=Application("baseroot") & "/editor/margini/deletestrategyvalue.asp"%>",
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
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.wrong_rateto")%>");
		$('#'+to_field+counter).val("");
		$('#'+to_field+counter).focus();
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
			alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.wrong_ratefrom")%>");
			$('#rate_from'+counter).val("");
			$('#rate_from'+counter).focus();
			return;			
		}	
	}		
}*/ 
</script>
</head>
<body onLoad="javascript:document.form_inserisci.label.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
	<table class="principal" cellpadding="0" cellspacing="0">
	<tr> 
	<td>
		<form action="<%=Application("baseroot") & "/editor/margini/ProcessRule.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="businessrules" name="showtab">
		  <input type="hidden" value="<%=id_rule%>" name="id_rule">		  
		  <input type="hidden" value="" name="rules_strategy_counter">
		  
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.label_rule")%></span><br>
		  <input type="text" name="label" value="<%=label%>" class="formFieldTXT">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc');" class="labelForm" onmouseout="javascript:hideDiv('help_desc');">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc">
		  <%=langEditor.getTranslated("backend.margini.detail.table.label.field_help_desc")%>
		  </div>
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.desc_rule")%></span><br>
		  <textarea name="descrizione" class="formFieldTXTAREAAbstract"><%=description%></textarea>
		  </div>	
		  <br/>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.activate_rule")%></span><br>
			<select name="activate" class="formFieldTXTShort">
			<option value="0"<%if ("0"=activate) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=activate) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>
		  <br/><br/>
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.tipo_rule")%></span><br>
			<select name="rule_type" id="rule_type" class="formFieldTXTLong">
			<%showOneTwo=false
			if(not(objDict.Exists(1)) AND not(objDict.Exists(2))) then
				showOneTwo=true
			end if
			if(objDict.Exists(1)) then
				if(objDict(1)=id_rule) then
					showOneTwo=true
				end if
			end if
			if(objDict.Exists(2)) then
				if(objDict(2)=id_rule) then
					showOneTwo=true
				end if
			end if
			if(showOneTwo) then%>
			<option value="1"<%if ("1"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.amount_order_rule")%></option>	
			<option value="2"<%if ("2"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.percentage_order_rule")%></option>
			<%end if%>
<!--nsys-voucher2--> 
			<option value="3"<%if ("3"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.voucher_order_rule")%></option>
<!---nsys-voucher2-->
			<%showFourFive=false
			if(not(objDict.Exists(4)) AND not(objDict.Exists(5))) then
				showFourFive=true
			end if
			if(objDict.Exists(4)) then
				if(objDict(4)=id_rule) then
					showFourFive=true
				end if
			end if
			if(objDict.Exists(5)) then
				if(objDict(5)=id_rule) then
					showFourFive=true
				end if
			end if
			if(showFourFive) then%>
			<option value="4"<%if ("4"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.first_amount_order_rule")%></option>	
			<option value="5"<%if ("5"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.first_percentage_order_rule")%></option>
			<%end if%>
			<option value="6"<%if ("6"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.amount_qta_product_rule")%></option>	
			<option value="7"<%if ("7"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.percentage_qta_product_rule")%></option>	
			<option value="8"<%if ("8"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.amount_related_product_rule")%></option>
			<option value="9"<%if ("9"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.percentage_related_product_rule")%></option>
			<option value="10"<%if ("10"=rule_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.label.exclude_bills_product_rule")%></option>	
			</SELECT>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_rule_type_value');" class="labelForm" onmouseout="javascript:hideDiv('help_rule_type_value');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:780px;" id="help_rule_type_value">
			  <%=langEditor.getTranslated("backend.margini.detail.table.label.help_rule_type_value")%>
			  </div>	
		  </div><br>	

		  <div align="left" id="complex_value" style="float:left;margin-right:5px;">
			  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.alt.strategy_value")%></span>&nbsp;<a id="addStrategyButton" href="javascript:addStrategyValues(rulesStrategyCounter,selectedType);"><img src="<%=Application("baseroot")&"/editor/img/add.png"%>" title="<%=langEditor.getTranslated("backend.margini.detail.table.alt.add_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.margini.detail.table.alt.add_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
			  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-nowitdh" id="add_field_values_div">
			  <tr>
			  <th class="id_prod_orig_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.id_prod_orig")%></th>
			  <th><%=langEditor.getTranslated("backend.margini.detail.table.label.rate_from")%></th>
			  <th><%=langEditor.getTranslated("backend.margini.detail.table.label.rate_to")%></th>
			  <th class="id_prod_ref_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.id_prod_ref")%></th>
			  <th class="rate_from_ref_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.rate_from_ref")%></th>
			  <th class="rate_to_ref_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.rate_to_ref")%></th>
			  <th class="operation_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.operation")%></th>
			  <th class="applyto_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto")%></th>
			  <th class="apply_4_qta_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.apply_4_qta")%></th>
			  <th class="valore_elem"><%=langEditor.getTranslated("backend.margini.detail.table.label.valore")%></th>
			  <th>&nbsp;</th>
			  </tr>
			  <%On Error Resume Next
				Dim valuesCounter, totalCounter
				valuesCounter = 0
				totalCounter = 0
				Set objSelRuleConf = objRule.getListaRulesConfig(id_rule, null)
				if(objSelRuleConf.Count > 0)then
					totalCounter = objSelRuleConf.Count
				end if
				
				if(totalCounter > 0) then
					arrKey = objSelRuleConf.Keys
					
					for each j in arrKey%>
						<tr id="field_values_container<%=valuesCounter%>" class="field_values_container">
						<td class="id_prod_orig_elem">
						<select name="id_prod_orig<%=valuesCounter%>" id="id_prod_orig<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>
							<%
							if (bolHasListProd) then
								counter = 0
								desc_cat = ""

								for each k in objListRefProd					
									Set objTmp = objListRefProd(k)%>
									<%if(desc_cat <>objTmp.getDescCatRelProd())then
										if(counter>0) then response.write("</optgroup>") end if%>
										<optgroup label="<%=objTmp.getDescCatRelProd()%>">
									<%end if%>
									<option value="<%=objTmp.getIDProdotto()%>" <%if (Cint(objTmp.getIDProdotto())=Cint(objSelRuleConf(j).getProdOrigConfID())) then response.Write(" selected")%>><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>	
									<%
									desc_cat = objTmp.getDescCatRelProd()
									Set objTmp = nothing
									counter = counter +1
								next
							end if%>
						</select>
						</td>						
						<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="<%=objSelRuleConf(j).getRateFromConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="<%=objSelRuleConf(j).getRateToConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,false);"></td>
						<td class="id_prod_ref_elem">
						<select name="id_prod_ref<%=valuesCounter%>" id="id_prod_ref<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>
							<%
							if (bolHasListProd) then
								counter = 0
								desc_cat = ""

								for each k in objListRefProd					
									Set objTmp = objListRefProd(k)%>
									<%if(desc_cat <>objTmp.getDescCatRelProd())then
										if(counter>0) then response.write("</optgroup>") end if%>
										<optgroup label="<%=objTmp.getDescCatRelProd()%>">
									<%end if%>
									<option value="<%=objTmp.getIDProdotto()%>" <%if (Cint(objTmp.getIDProdotto())=Cint(objSelRuleConf(j).getProdRefConfID())) then response.Write(" selected")%>><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>	
									<%
									desc_cat = objTmp.getDescCatRelProd()
									Set objTmp = nothing
									counter = counter +1
								next
							end if%>
						</select>
						</td>						
						<td class="rate_from_ref_elem"><input type="text" name="rate_from_ref<%=valuesCounter%>" id="rate_from_ref<%=valuesCounter%>" value="<%=objSelRuleConf(j).getRateFromRefConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td class="rate_to_ref_elem"><input type="text" name="rate_to_ref<%=valuesCounter%>" id="rate_to_ref<%=valuesCounter%>" value="<%=objSelRuleConf(j).getRateToRefConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,true);"></td>
						<td class="operation_elem" align="center">
						<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
							<option value="0"></option>
							<option value="1"<%if ("1"=objSelRuleConf(j).getOperationConf()) then response.Write(" selected")%>>+</option>	
							<option value="2"<%if ("2"=objSelRuleConf(j).getOperationConf()) then response.Write(" selected")%>>-</option>
						</select>
						</td>
						<td class="applyto_elem">
						<select name="applyto<%=valuesCounter%>" id="applyto<%=valuesCounter%>" class="formFieldSelect">
							<option value="0"></option>
							<option value="1"<%if ("1"=objSelRuleConf(j).getApplyToConf()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>	
							<option value="2"<%if ("2"=objSelRuleConf(j).getApplyToConf()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>	
							<option value="3"<%if ("3"=objSelRuleConf(j).getApplyToConf()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>	
							<option value="4"<%if ("4"=objSelRuleConf(j).getApplyToConf()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>	
							<option value="5"<%if ("5"=objSelRuleConf(j).getApplyToConf()) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>
						</select>
						</td>
						<td class="apply_4_qta_elem"><input type="text" name="apply_4_qta<%=valuesCounter%>" id="apply_4_qta<%=valuesCounter%>" value="<%=objSelRuleConf(j).getApply4QtaConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isInteger(event);"></td>
						<td class="valore_elem"><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="<%=objSelRuleConf(j).getValoreConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td>&nbsp;<a class="delStrategy" href="javascript:delStrategyValues(<%=valuesCounter%>,'<%=j%>','field_values_container<%=valuesCounter%>',1);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
						<script>
						// aggiorno la mappa dei field
						rulesStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
						</script></td>
						</tr>
					<%valuesCounter = valuesCounter+1
					next
				end if
				Set objSelRuleConf = nothing
			
				if(Err.number <> 0)then
					'response.write(Err.description)
				end if%>
			  
			  <%if(valuesCounter = 0) then%>
				<tr id="field_values_container<%=valuesCounter%>" class="field_values_container">
			  	<td class="id_prod_orig_elem">		
				<select name="id_prod_orig<%=valuesCounter%>" id="id_prod_orig<%=valuesCounter%>" class="formFieldSelect">
					<option value=""></option>
					<%
					if (bolHasListProd) then
						counter = 0
						desc_cat = ""

						for each k in objListRefProd					
							Set objTmp = objListRefProd(k)%>
							<%if(desc_cat <>objTmp.getDescCatRelProd())then
								if(counter>0) then response.write("</optgroup>") end if%>
								<optgroup label="<%=objTmp.getDescCatRelProd()%>">
							<%end if%>
							<option value="<%=objTmp.getIDProdotto()%>"><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>	
							<%
							desc_cat = objTmp.getDescCatRelProd()
							Set objTmp = nothing
							counter = counter +1
						next
					end if%>
				</select>
				</td>				
				<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>,false);"></td>	
				<td class="id_prod_ref_elem">
				<select name="id_prod_ref<%=valuesCounter%>" id="id_prod_ref<%=valuesCounter%>" class="formFieldSelect">
					<option value=""></option>
					<%
					if (bolHasListProd) then
						counter = 0
						desc_cat = ""

						for each k in objListRefProd					
							Set objTmp = objListRefProd(k)%>
							<%if(desc_cat <>objTmp.getDescCatRelProd())then
								if(counter>0) then response.write("</optgroup>") end if%>
								<optgroup label="<%=objTmp.getDescCatRelProd()%>">
							<%end if%>
							<option value="<%=objTmp.getIDProdotto()%>"><%=objTmp.getNomeProdotto()%>&nbsp;(<%=objTmp.getCodiceProd()%>)</option>	
							<%
							desc_cat = objTmp.getDescCatRelProd()
							Set objTmp = nothing
							counter = counter +1
						next
					end if%>
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
					<option value="1"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_orig")%></option>	
					<option value="2"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_ref")%></option>	
					<option value="3"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_chip")%></option>	
					<option value="4"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_expe")%></option>	
					<option value="5"><%=langEditor.getTranslated("backend.margini.detail.table.label.applyto_both")%></option>
				</select>
				</td>
				<td class="apply_4_qta_elem"><input type="text" name="apply_4_qta<%=valuesCounter%>" id="apply_4_qta<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isInteger(event);"></td>
				<td class="valore_elem"><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td>&nbsp;<a class="delStrategy" href="javascript:delStrategyValues(<%=valuesCounter%>,' ','field_values_container<%=valuesCounter%>',0);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.margini.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
				<script>
				// aggiorno la mappa dei field
				rulesStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
				</script></td>
				</tr>
			  <%valuesCounter=valuesCounter+1
			  end if%>
			  </table>
			  <script>
			  rulesStrategyCounter = <%=valuesCounter%>;
			  </script>
			  <%Set objListFieldProd = nothing%>

		  </div>	
		  <div align="left" id="voucher_id">
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.voucher_id")%></span><br>
		  <select name="voucher_id" id="voucher_id">
		  <option value=""></option>
		  <%
		  if(hasVoucherCampaign)then
			for each g in objListVoucherCampaign%>
			<option value="<%=g%>" <%if(g=voucher_id)then response.write(" selected") end if%>><%=objListVoucherCampaign(g).getLabel()%></option>
			<%next
		  end if
		  %>
		  </select>&nbsp;&nbsp;
		  </div>
		  <br>

			<script>
			$('#rule_type').change(function() {
				var rule_type_val_ch = $('#rule_type').val();
				selectedType = rule_type_val_ch;
				//alert("rule_type_val_ch: "+rule_type_val_ch);
				if(rule_type_val_ch==3){
					$(".field_values_container").remove();
					rulesStrategyMap.clear();
					addStrategyValues(rulesStrategyCounter,selectedType);
				
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
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.lista.button.label.inserisci_rule")%>" onclick="javascript:insertRule();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/margini/ListaMargini.asp?cssClass=LM&showtab=businessrules"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%
Set objListRefProd = nothing
Set objVoucherClass =  nothing
Set objRule = nothing%>