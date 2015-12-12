<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include file="include/init4.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<script language="JavaScript">
var fieldValuesMap;
fieldValuesMap = new Hashtable();

var fieldValuesCounter = 0;

function insertField(){
	if(document.form_inserisci.description.value == "") {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_description")%>");
		document.form_inserisci.description.focus();
		return false;		
	}else if(isSpecialChar(document.form_inserisci.description.value)) {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.not_use_special_char")%>");
		document.form_inserisci.description.focus();
		return false;		
	}
	
	/*if(document.form_inserisci.id_group.value == "") {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_group")%>");
		document.form_inserisci.id_group.focus();
		return false;		
	}*/

	var arrKeys = fieldValuesMap.keys();	
	var keys="";
	
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		keys+=tmpKey+",";
	}
	keys = keys.substring(0, keys.lastIndexOf(','));
	document.form_inserisci.field_values_counter.value=keys;
	
	document.form_inserisci.submit();
}

function deleteGroup(field){
	var id_group = field.options[field.selectedIndex].value;
	document.form_delete_group.id_del_group.value = id_group;
	if(confirm("<%=langEditor.getTranslated("backend.prodotti.lista.js.alert.delete_group")%>?")){
		document.form_delete_group.submit();
	}
}

function insertGroup(){
	var group_description = document.getElementById("group_value");
	var group_order = document.getElementById("group_order");

	document.form_inserisci_group.desc_new_group.value = group_description.value;
	document.form_inserisci_group.order_new_group.value = group_order.value;
	
	if(group_description.value == "") {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_description")%>");
		document.form_inserisci.group_value.focus();
		return false;		
	}else if(isSpecialChar(group_description.value)) {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.not_use_special_char")%>");
		document.form_inserisci.group_description.focus();
		return false;		
	}
	
	if(group_order.value == "") {
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.insert_order")%>");
		document.form_inserisci.group_order.focus();
		return false;		
	}
	
	document.form_inserisci_group.submit();
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



function sortDropDownListByText(elem) {  
	$("select#"+elem).each(function() {  
		var selectedValue = $(this).val();  
		$(this).html($("option", $(this)).sort(function(a, b) {  
		return a.text == b.text ? 0 : a.text < b.text ? -1 : 1  
		}));  
		$(this).val(selectedValue);  
	});  
}

function addFieldValues(fieldValCounter){
	var counter = fieldValCounter;

	$("#add_field_values_div").append('<span id="field_values_container'+counter+'"></span>');
	$("#field_values_container"+counter).append($('<input type="text"/>').attr('name', "field_values"+counter).attr('class', "formFieldTXTMedium").attr('value', "").keypress(function(event) {return notSpecialCharButUnderscore(event); }));
	var render='&nbsp;<a href="';
	render+="javascript:delFieldValues("+counter+",' ',' ','field_values_container"+counter+"',0);";
	render+='"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a><br/>';
	$("#field_values_container"+counter).append(render);

	// aggiorno la mappa dei field
	fieldValuesMap.put(counter,counter);

	fieldValuesCounter = counter+1;
} 

function delFieldValues(counter,id_element, value, field, remove){
	
	if(remove==1){
		var query_string = "id_field="+id_element+"&value="+value;
		
		$.ajax({
			type: "POST",
			url: "<%=Application("baseroot") & "/editor/prodotti/deletefieldvalue.asp"%>",
			data: query_string,
			success: function() {
			$("#"+field).remove();
			}
		});
	
		// aggiorno la mappa dei field
		fieldValuesMap.remove(counter);
	}else{
		$("#"+field).remove();
	
		// aggiorno la mappa dei field
		fieldValuesMap.remove(counter);
	}
} 
</script>
</head>
<body onLoad="javascript:document.form_inserisci.description.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<form action="<%=Application("baseroot") & "/editor/prodotti/ProcessField.asp"%>" method="post" name="form_inserisci" id="form_inserisci">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		  <input type="hidden" value="<%=id_field%>" name="id_field">
		  <input type="hidden" value="" name="field_values_counter">
		<tr>
		<td>	
		  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.description")%></span><br>
		  <input type="text" name="description" value="<%=description%>" class="formFieldTXTMedium" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc');" class="labelForm" onmouseout="javascript:hideDiv('help_desc');">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc">
		  <%=langEditor.getTranslated("backend.prodotti.detail.table.label.field_help_desc")%>
		  </div>
		  <br/><br/>	
		  
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.group")%></span><br>
			<select name="id_group" class="formFieldSelectSimple">
			<option value=""></option>
			<%if (Instr(1, typename(objDispGroup), "dictionary", 1) > 0) then
			for each x in objDispGroup%>
			<option value="<%=x%>" <%if (idGroup = x) then response.Write("selected")%>><%if not(langEditor.getTranslated("backend.prodotti.detail.table.label.group."&objDispGroup(x).getDescription()) = "") then response.write(langEditor.getTranslated("backend.prodotti.detail.table.label.group."&objDispGroup(x).getDescription())) else response.write(objDispGroup(x).getDescription()) end if%></option>
			<%next
			end if%>
			</select>
		  </div>
		  <div align="left" style="float:left;text-align:left;padding-top:20px;padding-right:20px;">
		  <a href="javascript:deleteGroup(document.form_inserisci.id_group);"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.delete_group")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.delete_group")%>" hspace="5" vspace="0" border="0"></a>
		  </div>
		  <div align="left" style="text-align:left;display:block;">
			<span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.insert_group")%></span><br>
			<table>
			<tr><td>
			<%=langEditor.getTranslated("backend.prodotti.detail.table.label.group")%>&nbsp;<input type="text" name="group_value" id="group_value"  value="" class="formFieldTXTMedium" onkeypress="javascript:return notSpecialChar(event);">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_group');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_group');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc_group">
			  <%=langEditor.getTranslated("backend.prodotti.detail.table.label.group_help_desc")%>
			  </div>
			</td></tr>
			<tr><td>
			<%=langEditor.getTranslated("backend.prodotti.detail.table.label.order")%>&nbsp;<input type="text" name="group_order" id="group_order" value="" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
			&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" onclick="javascript:insertGroup();" />
		  </td></tr>
		  </table>
		  </div>
		  <br><br>
		  
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.type")%></span><br>
			<select name="id_type" id="id_type" class="formFieldSelectSimple">
			<%for each x in typeList
				if(x<>4 AND x<>5 AND x<>6)then%>
			<option VALUE="<%=x%>" <%if not(typeField = "") AND (strComp(x, typeField, 1) = 0) then response.Write("selected")%>><%if not(langEditor.getTranslated("portal.commons.product_field.type.label."&typeList(x)) = "") then response.write(langEditor.getTranslated("portal.commons.product_field.type.label."&typeList(x))) else response.write typeList(x) end if%></option>
			<%	end if
			next%>
			</select>
		  </div>

			<script>
			$('#id_type').change(function() {
				var type_val_ch = $('#id_type').val();

				if(type_val_ch==1 || type_val_ch==2 || type_val_ch==7 || type_val_ch==8 || type_val_ch==9){
					$("#field_values_div").hide();
					if(type_val_ch==7 || type_val_ch==8){
						$("#max_lenght_div").hide();
					}else{
						$("#max_lenght_div").show();
					}
					
					$("#required_field").val($("#required_field_old").val());
					$("#required_text").empty();
					$("#required").show();
					
					$("#editable_field").val($("#editable_field_old").val());
					$("#editable_text").empty();
					$("#editable").show();
				}else{
					$("#field_values_div").show();
					$("#max_lenght_div").hide();
					
					//$("#required_field_old").val($("#required").val());
					$("#required_field").val(1)
					$("#required").hide();
					$("#required_text").empty();
					$("#required_text").append('<%=langEditor.getTranslated("backend.commons.yes")%>');
					
					//$("#editable_field_old").val($("#editable").val());
					$("#editable_field").val(0)
					$("#editable").hide();
					$("#editable_text").empty();
					$("#editable_text").append('<%=langEditor.getTranslated("backend.commons.no")%>');
				}

				sortDropDownListByText("id_type_content");
			});
			</script> 
 
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.type_content")%></span><br>
			<select name="id_type_content" id="id_type_content" class="formFieldSelectSimple">
			<%for each x in typeContentList%>
			<option VALUE="<%=x%>" <%if not(typeContent = "") AND (strComp(x, typeContent, 1) = 0) then response.Write("selected")%>><%if not(langEditor.getTranslated("portal.commons.product_field.type_content.label."&typeContentList(x)) = "") then response.write(langEditor.getTranslated("portal.commons.product_field.type_content.label."&typeContentList(x))) else response.write typeContentList(x) end if%></option>
			<%next%>
			</select>
		  </div><br>
		  <div align="left" id="field_values_div">
			  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.values")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc_values');" class="labelForm" onmouseout="javascript:hideDiv('help_desc_values');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc_values">
			  <%=langEditor.getTranslated("backend.prodotti.detail.table.label.field_help_desc_values")%>
			  </div>
			  &nbsp;<a href="javascript:addFieldValues(fieldValuesCounter);"><img src="<%=Application("baseroot")&"/editor/img/add.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.add_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.add_field_value")%>" hspace="5" vspace="0" border="0"></a>
			  
			  <%On Error Resume Next
				Dim valuesCounter, totalCounter
				valuesCounter = 0
				totalCounter = 0
				Set objListValues = objField.getListProductFieldValues(id_field)
				if(objListValues.Count > 0)then
					totalCounter = objListValues.Count
				end if
				
				if(totalCounter > 0) then
					arrKey = objListValues.Keys
					
					for each j in arrKey%>
						<span id="field_values_container<%=valuesCounter%>">
						<br/><input type="text" name="field_values<%=valuesCounter%>" value="<%=j%>" class="formFieldTXTMedium" onkeypress="javascript:return notSpecialCharButUnderscore(event);">&nbsp;<a href="javascript:delFieldValues(<%=valuesCounter%>,'<%=id_field%>','<%=j%>','field_values_container<%=valuesCounter%>',1);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
						<script>
						// aggiorno la mappa dei field
						fieldValuesMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
						</script>
						</span>
					<%valuesCounter = valuesCounter+1
					next
				end if
				Set objListValues = nothing
			
				if(Err.number <> 0)then
					'response.write(Err.description)
				end if%>
			  
			  <%if(valuesCounter = 0) then%>
				<span id="field_values_container<%=valuesCounter%>">
			  	<br/><input type="text" name="field_values<%=valuesCounter%>" value="" class="formFieldTXTMedium" onkeypress="javascript:return notSpecialCharButUnderscore(event);">&nbsp;<a href="javascript:delFieldValues(<%=valuesCounter%>,' ',' ','field_values_container<%=valuesCounter%>',0);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" alt="<%=langEditor.getTranslated("backend.prodotti.detail.table.alt.del_field_value")%>" hspace="5" vspace="0" border="0"></a>
				<script>
				// aggiorno la mappa dei field
				fieldValuesMap.put(<%=valuesCounter%>,<%=valuesCounter%>);
				</script>
				</span>
			  <%valuesCounter=valuesCounter+1
			  end if%>
			  <script>
			  fieldValuesCounter = <%=valuesCounter%>;
			  </script>
			  <div id="add_field_values_div">
			  </div>
			  
			  <br/><br/>
		  </div>
		  <div align="left" id="max_lenght_div">
			  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.max_lenght")%></span><br>
			  <input type="text" name="max_lenght" value="<%=maxLenght%>" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">
			  <br/><br/>
		  </div>			
		  <span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.order")%></span><br>
		  <input type="text" name="order" value="<%=order%>" class="formFieldTXTShort" maxlength="3" onkeypress="javascript:return isInteger(event);">
		  <br/><br/>	 	
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.enabled")%></span><br>
			<select name="enabled" class="formFieldTXTShort">
			<option value="0"<%if ("0"=enabled) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=enabled) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>
		  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.required")%></span><br>
			<div id="required" style="float:left;">
			<select name="required" id="required_field" class="formFieldTXTShort">
			<option value="0"<%if ("0"=required) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=required) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
			</div><span id="required_text"></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_required');" class="labelForm" onmouseout="javascript:hideDiv('help_required');">?</a>
			  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_required">
			  <%=langEditor.getTranslated("backend.prodotti.detail.table.label.field_help_required")%>
			  </div>
			<input type="hidden" value="" name="required_field_old" id="required_field_old">
		  </div>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.prodotti.detail.table.label.editable")%></span><br>
			<div id="editable">
			<select name="editable" id="editable_field" class="formFieldTXTShort">
			<option value="0"<%if ("0"=editable) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=editable) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
			</div><span id="editable_text"></span>
			<input type="hidden" value="" name="editable_field_old" id="editable_field_old">
		  </div>

		<script>
		$("#required_field_old").val($("#required_field").val());
		$("#editable_field_old").val($("#editable_field").val());
		
		var type_val = $('#id_type').val();
		if(type_val==1 || type_val==2 || type_val==7 || type_val==8 || type_val==9){
			$("#field_values_div").hide();
			if(type_val==7 || type_val==8){
				$("#max_lenght_div").hide();
			}else{
				$("#max_lenght_div").show();
			}
			$("#required_text").empty();
			$("#required").show();
			
			$("#editable_text").empty();
			$("#editable").show();
		}else{
			$("#field_values_div").show();
			$("#max_lenght_div").hide();
			
			$("#required_field").val(1)
			$("#required").hide();
			$("#required_text").empty();
			$("#required_text").append('<%=langEditor.getTranslated("backend.commons.yes")%>');
			
			$("#editable_field").val(0)
			$("#editable").hide();
			$("#editable_text").empty();
			$("#editable_text").append('<%=langEditor.getTranslated("backend.commons.no")%>');
		}

		sortDropDownListByText("id_type_content");
		</script> 
		</td></tr>
		</table>
		</form>
		<br/>
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" onclick="javascript:insertField();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/prodotti/Listaprodotti.asp?cssClass=LP&showtab=prodfield"%>';" />
		<br/><br/>
		<form action="<%=Application("baseroot") & "/editor/prodotti/ProcessField.asp"%>" method="post" name="form_inserisci_group">
			<input type="hidden" value="ins_group" name="action">
			<input type="hidden" value="" name="desc_new_group">
			<input type="hidden" value="" name="order_new_group">
			<input type="hidden" value="<%=id_field%>" name="id_field">
		</form>	

		<form action="<%=Application("baseroot") & "/editor/prodotti/ProcessField.asp"%>" method="post" name="form_delete_group">
			<input type="hidden" value="del_group" name="action">
			<input type="hidden" value="" name="id_del_group">
			<input type="hidden" value="<%=id_field%>" name="id_field">
		</form>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%
Set objField = nothing
Set typeList = nothing
%>