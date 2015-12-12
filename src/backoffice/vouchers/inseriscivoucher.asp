<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function insertVoucher(){
	
	if(document.form_inserisci.label.value == ""){
		alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_label")%>");
		document.form_inserisci.label.focus();
		return;
	}

	if(document.form_inserisci.descrizione.value == ""){
		alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_description")%>");
		document.form_inserisci.descrizione.focus();
		return;
	}

	if(document.form_inserisci.valore.value == ""){
		alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_valore")%>");
		document.form_inserisci.valore.focus();
		return;
	}

	if(document.form_inserisci.max_generation_selector.value != "-1"){
		if(document.form_inserisci.max_generation.value == "") {
			alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_max_generation")%>");
			document.form_inserisci.max_generation.focus();
			return;
		}
	}

	if(document.form_inserisci.max_usage_selector.value != "-1"){
		if(document.form_inserisci.max_usage.value == "") {
			alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_max_usage")%>");
			document.form_inserisci.max_usage.focus();
			return;
		}
	}

	if(document.form_inserisci.voucher_type.value == "2" || document.form_inserisci.voucher_type.value == "3"){
		if(document.form_inserisci.enable_date.value == "") {
			alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_enable_date")%>");
			document.form_inserisci.enable_date.focus();
			return;
		}
	}

	if(document.form_inserisci.voucher_type.value == "2" || document.form_inserisci.voucher_type.value == "3"){
		if(document.form_inserisci.expire_date.value == "") {
			alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_expire_date")%>");
			document.form_inserisci.expire_date.focus();
			return;
		}
	}
	
	document.form_inserisci.submit()
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		<form action="<%=Application("baseroot") & "/editor/voucher/ProcessVoucher.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_voucher%>" name="id_voucher">
			<tr><td>

		  <span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.label")%></span><br>
		  <input type="text" name="label" value="<%=label%>" class="formFieldTXT">
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.detail.table.label.desc")%></span><br>
		  <textarea name="descrizione" class="formFieldTXTAREAAbstract"><%=description%></textarea>
		  </div>	
		  <br/>	 	
		  <div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.value")%></span><br>
			<input type="text" name="valore" id="valore" value="<%=valore%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);">
		  </div>	 	
		  <div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.operation")%></span><br>
			<select name="operation" class="formFieldSelect">
			<option value="0"<%if ("0"=operation) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.operation.label.percentage")%></option>	
			<option value="1"<%if ("1"=operation) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.operation.label.fixed")%></option>	
			</select>
		  </div>	 	
		  <div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.activate")%></span><br>
			<select name="activate" class="formFieldTXTShort">
			<option value="0"<%if ("0"=activate) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=activate) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</select>
		  </div>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.exclude_prod_rule")%></span><br>
			<select name="exclude_prod_rule" class="formFieldTXTShort">
			<option value="0"<%if ("0"=exclude_prod_rule) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=exclude_prod_rule) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</select>
		  </div>
		  <br/>	 	
		  <div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.voucher_type")%></span><br>
			<select name="voucher_type" id="voucher_type" class="formFieldSelect">
			<option value="0"<%if ("0"=voucher_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot")%></option>	
			<option value="1"<%if ("1"=voucher_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use")%></option>	
			<option value="2"<%if ("2"=voucher_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_time")%></option>	
			<option value="3"<%if ("3"=voucher_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use_by_time")%></option>	
			<option value="4"<%if ("4"=voucher_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_user")%></option>		
			</select>
		  </div>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.max_generation")%></span><br>
			<select name="max_generation_selector" id="max_generation_selector" class="formFieldSelect" style="margin-right:10px;">
			<option value="-1"<%if ("-1"=max_generation) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.label.unlimited")%></option>	
			<option value=""<%if ("-1"<>max_generation) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.label.max_generation_not_unlimited")%></option>			
			</select>
			<input type="text" name="max_generation" id="max_generation" value="<%=max_generation%>" class="formFieldTXTMediumThin" onkeypress="javascript:return isInteger(event);">
		  </div>
		  <br/>	 	
		  <div align="left" id="max_usage_view"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.max_usage")%></span><br>
			<select name="max_usage_selector" id="max_usage_selector" class="formFieldSelect" style="margin-right:10px;">
			<option value="-1"<%if ("-1"=max_usage) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.label.unlimited")%></option>	
			<option value="0"<%if ("-1"<>max_usage) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.voucher.label.max_usage_not_unlimited")%></option>			
			</select>
			<input type="text" name="max_usage" id="max_usage" value="<%=max_usage%>" class="formFieldTXTMediumThin" onkeypress="javascript:return isInteger(event);">
		  </div>
		  <br/>	 	
		  <span id="date_view"><div align="left" style="float:left;padding-right:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.enable_date")%></span><br>
			<input type="text" name="enable_date" id="enable_date" value="<%=enable_date%>" class="formFieldTXT">
		  </div>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.voucher.lista.table.header.expire_date")%></span><br>
			<input type="text" name="expire_date" id="expire_date" value="<%=expire_date%>" class="formFieldTXT">
		  </div>
		  <br/></span>


			<script>			
			$('#enable_date').datetimepicker({
				showButtonPanel: false,
				dateFormat: 'dd/mm/yy',
				timeFormat: 'hh.mm'
			});			
			$('#expire_date').datetimepicker({
				showButtonPanel: false,
				dateFormat: 'dd/mm/yy',
				timeFormat: 'hh.mm'
			});
							
			$('#max_generation_selector').change(function() {
				var max_generation_selector_val_ch = $('#max_generation_selector').val();
				if(max_generation_selector_val_ch==-1){
					$("#max_generation").hide();
					$("#max_generation").val("-1");
				}else{
					$("#max_generation").show();
					$("#max_generation").val("");
				}
			});			
			var max_generation_selector_val = $('#max_generation_selector').val();
			if(max_generation_selector_val==-1){
				$("#max_generation").hide();
				$("#max_generation").val("-1");
			}else{
				$("#max_generation").show();
			}
			
			$('#max_usage_selector').change(function() {
				var max_usage_selector_val_ch = $('#max_usage_selector').val();
				if(max_usage_selector_val_ch==-1){
					$("#max_usage").hide();
					$("#max_usage").val("-1");
				}else{
					$("#max_usage").show();
					$("#max_usage").val("");
				}
			});			
			var max_usage_selector_val = $('#max_usage_selector').val();
			if(max_usage_selector_val==-1){
				$("#max_usage").hide();
				$("#max_usage").val("-1");
			}else{
				$("#max_usage").show();
			}
			
			
			$('#voucher_type').change(function() {
				var voucher_type_val_ch = $('#voucher_type').val();
				if(voucher_type_val_ch==0){				
					$("#max_usage_view").hide();
					$("#max_usage_selector").val("0");				
					$("#max_usage").val("1");						
					$("#date_view").hide();						
					$("#enable_date").val("");						
					$("#expire_date").val("");			
				}else if(voucher_type_val_ch==1){						
					$('#max_usage_selector').val("-1");
					$("#max_usage").hide();
					$("#max_usage").val("-1");
					$("#max_usage_view").show();					
					$("#date_view").hide();						
					$("#enable_date").val("");							
					$("#expire_date").val("");
				}else if(voucher_type_val_ch==2){				
					$("#max_usage_view").hide();
					$("#max_usage_selector").val("0");				
					$("#max_usage").val("1");						
					$("#date_view").show();	
				}else if(voucher_type_val_ch==3){					
					$('#max_usage_selector').val("-1");	
					$("#max_usage").hide();
					$("#max_usage").val("-1");
					$("#max_usage_view").show();						
					$("#date_view").show();	
				}else if(voucher_type_val_ch==4){		
					$("#max_usage_view").hide();
					$("#max_usage_selector").val("0");				
					$("#max_usage").val("1");						
					$("#date_view").hide();						
					$("#enable_date").val("");						
					$("#expire_date").val("");			
				}
			});
	
			var voucher_type_val = $('#voucher_type').val();
			if(voucher_type_val==0){				
				$("#max_usage_view").hide();
				$("#max_usage_selector").val("0");				
				$("#max_usage").val("1");						
				$("#date_view").hide();						
				$("#enable_date").val("");						
				$("#expire_date").val("");			
			}else if(voucher_type_val==1){					
				var max_usage_selector_val_tmp = $('#max_usage_selector').val();
				if(max_usage_selector_val_tmp==-1){
					$("#max_usage").hide();
					$("#max_usage").val("-1");
					$("#max_usage_selector").show();	
				}else{
					$("#max_usage_selector").show();	
					$("#max_usage_value").show();
				}					
				$("#date_view").hide();						
				$("#enable_date").val("");							
				$("#expire_date").val("");
			}else if(voucher_type_val==2){				
				$("#max_usage_view").hide();
				$("#max_usage_selector").val("0");				
				$("#max_usage").val("1");						
				$("#date_view").show();	
			}else if(voucher_type_val==3){					
				var max_usage_selector_val_tmp = $('#max_usage_selector').val();
				if(max_usage_selector_val_tmp==-1){
					$("#max_usage").hide();
					$("#max_usage").val("-1");
					$("#max_usage_selector").show();	
				}else{
					$("#max_usage_selector").show();	
					$("#max_usage").show();
				}						
				$("#date_view").show();	
			}else if(voucher_type_val==4){		
				$("#max_usage_view").hide();
				$("#max_usage_selector").val("0");				
				$("#max_usage").val("1");						
				$("#date_view").hide();						
				$("#enable_date").val("");						
				$("#expire_date").val("");			
			}
			</script>
		</td></tr>
		</form>
		</table><br/>		    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.voucher.detail.button.inserisci.label")%>" onclick="javascript:insertVoucher();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/voucher/ListaVoucher.asp?cssClass=LVC"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%Set objVoucher = nothing%>