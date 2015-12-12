<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<script language="JavaScript">
var billsMapM, billsMapR;
billsMapM = new Hashtable();
billsMapR = new Hashtable();

var billsStrategyMap;
billsStrategyMap = new Hashtable();
var billsStrategyCounter = 0;

var selectedType = <%=iType%>;


<%
On Error Resume Next
Set objListaSpese = objSpesa.getListaSpese(null,null, null,null)
oldgroupname = ""
groupname = ""
for each q in objListaSpese
	Set objspesatmp = objListaSpese(q)
	groupname = objspesatmp.getGroup()
	if(objspesatmp.getAutoactive() = 0 AND (groupname <> oldgroupname))then
		response.write("billsMapM.put('"&groupname&"','"&objspesatmp.getMultiply()&"');")
		response.write("billsMapR.put('"&groupname&"','"&objspesatmp.getRequired()&"');")
		oldgroupname = groupname
	end if
	Set objspesatmp = nothing
next
Set objListaSpese = nothing
if Err.number <> 0 then
end if

On Error Resume Next
Set objListFieldProd = objField.getListProductField(1)
if Err.number <> 0 then
	Set objListFieldProd = Server.CreateObject("Scripting.Dictionary")
end if
%>


function insertSpesa(){
	
	if(document.form_inserisci.descrizione.value == ""){
		alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.descrizione.focus();
		return;
	}
	
	if((document.form_inserisci.tipo_valore.value==1 || document.form_inserisci.tipo_valore.value==2) && document.form_inserisci.valore.value == ""){
		alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.valore.focus();
		return;
	}else if(document.form_inserisci.tipo_valore.value!=1 && document.form_inserisci.tipo_valore.value!=2){
		document.form_inserisci.valore.value = 0;
	}

	if(document.form_inserisci.autoactive.value == 0 && (document.form_inserisci.group.value == "" || !checkGroupFormat(document.form_inserisci.group.value))){
		alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_correct_group")%>");		
		document.form_inserisci.group.focus();
		return;
	}

	var arrKeys = billsMapM.keys();	
	var sel_value = "";
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = billsMapM.get(tmpKey);
		if(tmpKey == document.form_inserisci.group.value && !(document.form_inserisci.multiply.value == tmpValue)){
			if(tmpValue==0){sel_value = "<%=langEditor.getTranslated("backend.commons.no")%>";}else{sel_value = "<%=langEditor.getTranslated("backend.commons.yes")%>";}
			alert(tmpKey+" <%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_correct_multiply")%> "+sel_value+"!");
			return;
		}
	}

	var arrKeysR = billsMapR.keys();	
	var sel_valueR = "";
	for(var z=0; z<arrKeysR.length; z++){
		tmpKeyR = arrKeysR[z];
		tmpValueR = billsMapR.get(tmpKeyR);
		if(tmpKeyR == document.form_inserisci.group.value && !(document.form_inserisci.required.value == tmpValueR)){
			if(tmpValueR==0){sel_valueR = "<%=langEditor.getTranslated("backend.commons.no")%>";}else{sel_valueR = "<%=langEditor.getTranslated("backend.commons.yes")%>";}
			alert(tmpKeyR+" <%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_correct_required")%> "+sel_valueR+"!");
			return;
		}
	}

	if(document.form_inserisci.tipo_valore.value!=1 && document.form_inserisci.tipo_valore.value!=2){	
		var arrKeysS = billsStrategyMap.keys();	
		var keys="";	
		for(var z=0; z<arrKeysS.length; z++){
			tmpKeyS = arrKeysS[z];
			
			if((document.form_inserisci.tipo_valore.value==7 || document.form_inserisci.tipo_valore.value==8) && $('#id_prod_field'+tmpKeyS).val() == ""){
				alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_id_prod_field_value")%>");
				$('#id_prod_field'+tmpKeyS).focus();
				return;
			}else if($('#rate_from'+tmpKeyS).val() == ""){
				alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_rate_from_value")%>");
				$('#rate_from'+tmpKeyS).focus();
				return;
			}else if($('#rate_to'+tmpKeyS).val() == ""){
				alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_rate_to_value")%>");
				$('#rate_to'+tmpKeyS).focus();
				return;				
			}else if($('#valore'+tmpKeyS).val() == ""){
				alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.insert_rate_valore_value")%>");
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

function checkGroupFormat(field){
	var fieldVal = field;	
	
	/*
	var expr1 = /^\d+,\d+$/;
	var expr2 = /^\d+$/;			
	var expr3 = /(^\d$)|(^\d,\d$)|(^10$)|(^10,0$)/;
	var expr4 = /(^\d{4}\/([1-9]|10|11|12)$)/;
	var expr5 = /^[0-9]$/
	var expr = /(^\d+$)|(^\d+\.\d+$)|(\.\d+$)/
	*/
	
	var expr = /^\w+$/
	var ok = expr.test(fieldVal);
	
	return ok;
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
	<%for each f in objListFieldProd
		if((Cint(objListFieldProd(f).getTypeContent())=2 OR Cint(objListFieldProd(f).getTypeContent())=3))then%>
			$("#id_prod_field"+counter).append('<option value="<%=f%>"><%=objListFieldProd(f).getDescription()%></option>');
		<%end if
	next%>	
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
	render+='"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a></td>';
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
			url: "<%=Application("baseroot") & "/editor/spese/deletestrategyvalue.asp"%>",
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
		alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.wrong_rateto")%>");
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
			alert("<%=langEditor.getTranslated("backend.spese.detail.js.alert.wrong_ratefrom")%>");
			$('#rate_from'+counter).val("");
			$('#rate_from'+counter).focus();
			return;			
		}	
	}		
}*/ 
</script>
</head>
<body onLoad="javascript:document.form_inserisci.descrizione.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr>
		<td>
		<form action="<%=Application("baseroot") & "/editor/spese/ProcessspesaAccessoria.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_spesa%>" name="id_spesa">		  
		  <input type="hidden" value="" name="bills_strategy_counter">
		  
		  <span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.descrizione_spesa")%></span><br>
		  <input type="text" name="descrizione" value="<%=strDescrizione%>" class="formFieldTXTLong">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc');" class="labelForm" onmouseout="javascript:hideDiv('help_desc');">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc">
		  <%=langEditor.getTranslated("backend.spese.detail.table.label.field_help_desc")%>
		  </div>
		  <br/><br/>
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.tipo_valore")%></span><br>
			<select name="tipo_valore" id="tipo_valore" class="formFieldTXTLong">
			<option value="1"<%if ("1"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso")%></option>	
			<option value="2"<%if ("2"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_percentuale")%></option>	
			<option value="3"<%if ("3"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso_range_imp")%></option>	
			<option value="4"<%if ("4"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_percentuale_range_imp")%></option>	
			<option value="5"<%if ("5"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta")%></option>	
			<option value="6"<%if ("6"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso_qta_incr")%></option>	
			<option value="7"<%if ("7"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso_field")%></option>	
			<option value="8"<%if ("8"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.label.tipologia_fisso_field_incr")%></option>	
			</SELECT>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_type_value');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_type_value');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:550px;" id="help_desc_type_value">
			  <%=langEditor.getTranslated("backend.prodotti.detail.table.label.field_help_desc_type_value")%>
			  </div>	
		  </div><br>	
		  <div align="left" id="simple_value">
		  <span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.valore")%></span><br>
		  <input type="text" name="valore" value="<%=iValore%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">&nbsp;&nbsp;
		  </div>	
		  <div align="left" id="complex_value">
			  <span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.alt.strategy_value")%></span>&nbsp;<a href="javascript:addStrategyValues(billsStrategyCounter,selectedType);"><img src="<%=Application("baseroot")&"/editor/img/add.png"%>" title="<%=langEditor.getTranslated("backend.spese.detail.table.alt.add_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.spese.detail.table.alt.add_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
			  <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table-nowitdh" id="add_field_values_div">
			  <tr>
			  <th class="id_prod_field_elem"><%=langEditor.getTranslated("backend.spese.detail.table.label.id_field_prod")%></th>
			  <th><%=langEditor.getTranslated("backend.spese.detail.table.label.rate_from")%></th>
			  <th><%=langEditor.getTranslated("backend.spese.detail.table.label.rate_to")%></th>
			  <th class="operation_elem"><%=langEditor.getTranslated("backend.spese.detail.table.label.operation")%></th>
			  <th><%=langEditor.getTranslated("backend.spese.detail.table.label.valore")%></th>
			  <th>&nbsp;</th>
			  </tr>
			  <%On Error Resume Next
				Dim valuesCounter, totalCounter
				valuesCounter = 0
				totalCounter = 0
				Set objListBillsConf = objSpesa.getListaSpeseConfig(id_spesa, null)
				if(objListBillsConf.Count > 0)then
					totalCounter = objListBillsConf.Count
				end if
				
				if(totalCounter > 0) then
					arrKey = objListBillsConf.Keys
					
					for each j in arrKey%>
						<tr id="field_values_container<%=valuesCounter%>">
						<td class="id_prod_field_elem">
						<input type="hidden" name="id<%=valuesCounter%>" value="<%=j%>">
						<%'if(iType=7 OR iType=8)then%>
						<select name="id_prod_field<%=valuesCounter%>" id="id_prod_field<%=valuesCounter%>" class="formFieldSelect">
							<option value=""></option>
							<%for each f in objListFieldProd
								if((objListFieldProd(f).getTypeContent()=2 OR objListFieldProd(f).getTypeContent()=3))then%>
									<option value="<%=f%>" <%if (Cint(f)=Cint(objListBillsConf(j).getProdFieldConfID())) then response.Write(" selected")%>><%=objListFieldProd(f).getDescription()%></option>
								<%end if
							next%>
						</select>
						<%'end if%></td>						
						<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="<%=objListBillsConf(j).getRateFromConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="<%=objListBillsConf(j).getRateToConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>);"></td>
						<td class="operation_elem" align="center"><%'if(iType=6 OR iType=8)then%>
						<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
							<option value="1"<%if ("1"=objListBillsConf(j).getOperationConf()) then response.Write(" selected")%>>+</option>	
							<option value="2"<%if ("2"=objListBillsConf(j).getOperationConf()) then response.Write(" selected")%>>-</option>
						</select>
						<%'end if%></td>
						<td><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="<%=objListBillsConf(j).getValoreConf()%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
						<td>&nbsp;<a href="javascript:delStrategyValues(<%=valuesCounter%>,'<%=j%>','field_values_container<%=valuesCounter%>',1);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
						<script>
						// aggiorno la mappa dei field
						billsStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
						</script></td>
						</tr>
					<%valuesCounter = valuesCounter+1
					next
				end if
				Set objListBillsConf = nothing
			
				if(Err.number <> 0)then
					'response.write(Err.description)
				end if%>
			  
			  <%if(valuesCounter = 0) then%>
				<tr id="field_values_container<%=valuesCounter%>">
			  	<td class="id_prod_field_elem">
				<input type="hidden" name="id<%=valuesCounter%>" value="-1">
				<%'if(iType=7 OR iType=8)then%>				
				<select name="id_prod_field<%=valuesCounter%>" id="id_prod_field<%=valuesCounter%>" class="formFieldSelect">
					<option value=""></option>
					<%for each f in objListFieldProd
						if((objListFieldProd(f).getTypeContent()=2 OR objListFieldProd(f).getTypeContent()=3))then%>
						<option value="<%=f%>"><%=objListFieldProd(f).getDescription()%></option>
						<%end if
					next%>
				</select>
				<%'end if%></td>				
				<td><input type="text" name="rate_from<%=valuesCounter%>" id="rate_from<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td><input type="text" name="rate_to<%=valuesCounter%>" id="rate_to<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" onblur="javascript:return checkFrom(<%=valuesCounter%>);"></td>
				<td class="operation_elem" align="center"><%'if(iType=6 OR iType=8)then%>
				<select name="operation<%=valuesCounter%>" id="operation<%=valuesCounter%>" class="formFieldSelect">
					<option value="1">+</option>	
					<option value="2">-</option>
				</select>
				<%'end if%></td>
				<td><input type="text" name="valore<%=valuesCounter%>" id="valore<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);"></td>
				<td>&nbsp;<a href="javascript:delStrategyValues(<%=valuesCounter%>,' ','field_values_container<%=valuesCounter%>',0);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" alt="<%=langEditor.getTranslated("backend.spese.detail.table.alt.del_strategy_value")%>" hspace="5" vspace="0" border="0"></a>
				<script>
				// aggiorno la mappa dei field
				billsStrategyMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
				</script></td>
				</tr>
			  <%valuesCounter=valuesCounter+1
			  end if%>
			  </table>
			  <script>
			  billsStrategyCounter = <%=valuesCounter%>;
			  </script>
			  <!--<div id="add_field_values_div">
			  </div>-->
			  <%Set objListFieldProd = nothing%>

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

		  
		  <span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.tassa_applicata")%></span><br>
		  <select name="id_tassa_applicata" class="formFieldTXT">
		  <option value=""></option>
			<%
			Dim objTasse, objListaTasse, objTassa
			Set objTasse = new TaxsClass
			On Error Resume Next
			Set objListaTasse = objTasse.getListaTasse(null,null)
			if not (isNull(objListaTasse)) then
				for each y in objListaTasse.Keys
					Set objTassa = objListaTasse(y)%>
					<option value="<%=y%>" <%if (tassa_applicata = y) then response.write("selected") end if%>><%=objTassa.getDescrizioneTassa()%></option>	
				<%	Set objTassa = nothing
				next
			end if		
			Set objListaTasse = nothing
			if(Err.number<>0)then
			end if
			Set objTasse = nothing
			%>	  
		  </select>		
		  <br/><br/>
		  
		  <span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.taxs_group")%></span><br>
		  <select name="taxs_group" class="formFieldTXT">
		  <option value=""></option>
			<%
			Dim objTaxGroup, objListaTaxGroup, objGroupT
			Set objTaxGroup = new TaxsGroupClass
			On Error Resume Next
			Set objListaTaxGroup = objTaxGroup.getListaTaxsGroup(null)
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
			Set objTaxGroup = nothing
			%>	  
		  </select>		
		  <br/><br/>		
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.applica_frontend")%>&nbsp;&nbsp;&nbsp;</span><br>
			<select name="applica_frontend" class="formFieldTXTShort">
			<option value="0"<%if ("0"=applica_frontend) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=applica_frontend) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>	
		  </div>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.applica_backend")%>&nbsp;&nbsp;&nbsp;</span><br>
			<select name="applica_backend" class="formFieldTXTShort">
			<option value="0"<%if ("0"=applica_backend) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=applica_backend) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>	
			</div>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.type_view")%></span><br>
			<select name="type_view" class="formFieldTXT">
			<option value="0"<%if ("0"=type_view) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.detail.option.label.bigzeroamount")%></option>	
			<option value="1"<%if ("1"=type_view) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.spese.detail.option.label.always")%></option>	
			</SELECT>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_type_view');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_type_view');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:550px;" id="help_desc_type_view">
			  <%=langEditor.getTranslated("backend.spese.detail.table.label.type_view_help_desc")%>
			  </div>	
			</div>		
		  <br/><br/>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.autoactive")%>&nbsp;&nbsp;&nbsp;</span><br>
			<select name="autoactive" id="autoactive" class="formFieldTXTShort">
			<option value="0"<%if ("0"=autoactive) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=autoactive) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>	
		  </div>	
		  <div align="left" style="float:left;" id="multiply"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.multiply")%>&nbsp;&nbsp;&nbsp;</span><br>
			<select name="multiply" class="formFieldTXTShort">
			<option value="0"<%if ("0"=multiply) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=multiply) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>	
		  </div>	
		  <div align="left" id="required"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.required")%></span><br>
			<select name="required" class="formFieldTXTShort">
			<option value="0"<%if ("0"=required) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=required) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>	
		  </div>
		  <br/><br/>
		  <div align="left" id="group"><span class="labelForm"><%=langEditor.getTranslated("backend.spese.detail.table.label.group")%></span><br>
		  <input type="text" name="group" value="<%=group%>" class="formFieldTXTLong">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_group');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_group');">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc_group">
		  <%=langEditor.getTranslated("backend.spese.detail.table.label.group_help_desc")%>
		  </div>
		  </div>


		<script>
		$('#autoactive').change(function() {
			var autoactive_val_ch = $('#autoactive').val();
			if(autoactive_val_ch==1){
				$("#multiply").hide();
				$("#required").hide();
				$("#group").hide();
			}else{
				$("#multiply").show();
				$("#required").show();
				$("#group").show();
			}
		});

		var autoactive_val = $('#autoactive').val();
		if(autoactive_val==1){
			$("#multiply").hide();
			$("#required").hide();
			$("#group").hide();
		}else{
			$("#multiply").show();
			$("#required").show();
			$("#group").show();
		}
		</script> 
		</form>
		</td></tr>
		</table><br/>    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.spese.detail.button.inserisci.label")%>" onclick="javascript:insertSpesa();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/spese/ListaSpeseAccessorie.asp?cssClass=LSP"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%
Set objField = nothing
Set objSpesa = nothing%>