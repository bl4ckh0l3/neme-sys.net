<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">

function insertPayment(){
	
	if(document.form_inserisci.descrizione.value == ""){
		alert("<%=langEditor.getTranslated("backend.payment.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.descrizione.focus();
		return;
	}
	
	if(document.form_inserisci.dati_pagamento.value == ""){
		alert("<%=langEditor.getTranslated("backend.payment.detail.js.alert.insert_dati_pagamento_value")%>");
		document.form_inserisci.dati_pagamento.focus();
		return;
	}
	
	if(document.form_inserisci.url.options[document.form_inserisci.url.selectedIndex].value == 1 && (document.form_inserisci.payment_module.options[document.form_inserisci.payment_module.selectedIndex].value == "" || document.form_inserisci.payment_module.options[document.form_inserisci.payment_module.selectedIndex].value == "-1")){
		alert("<%=langEditor.getTranslated("backend.payment.detail.js.alert.choose_module_payment_value")%>");
		//document.form_inserisci.dati_pagamento.focus();
		return;
	}
	
	document.form_inserisci.submit()
}

function showHide(){
	if(document.form_inserisci.url.options[document.form_inserisci.url.selectedIndex].value == 0){
		var element = document.getElementById("div_payment_field");
		element.style.visibility = 'hidden';
		element.style.display = "none";
	}else if(document.form_inserisci.url.options[document.form_inserisci.url.selectedIndex].value == 1){
		var element = document.getElementById("div_payment_field");
		element.style.visibility = 'visible';	
		element.style.display = "block";
	}
}

function changeExternalURL(){	
	location.href = "<%=Application("baseroot") & "/editor/payments/InserisciPayment.asp?id_payment="&id_payment&"&id_modulo="&modulo&"&ext_url="%>"+document.form_inserisci.url.options[document.form_inserisci.url.selectedIndex].value;
}

function changePaymentModule(fieldForm){
	if(document.form_inserisci.id_payment.value == "-1"){
		alert("<%=langEditor.getTranslated("backend.payment.detail.js.alert.no_id_payment")%>");
		document.form_inserisci.payment_module.value = "";
		return;		
	}else{
		if(document.form_inserisci.payment_module.options[document.form_inserisci.payment_module.selectedIndex].value == "" || document.form_inserisci.payment_module.options[document.form_inserisci.payment_module.selectedIndex].value == "-1"){
			alert("<%=langEditor.getTranslated("backend.payment.detail.js.alert.choose_module_payment_value")%>");
			document.form_inserisci.payment_module.value = fieldForm;
			return;
			//location.href = "<%=Application("baseroot") & "/editor/payments/InserisciPayment.asp?id_payment="&id_payment&"&id_modulo=-1"%>";
		}else{		
			location.href = "<%=Application("baseroot") & "/editor/payments/InserisciPayment.asp?id_payment="&id_payment&"&ext_url="&url&"&id_modulo="%>"+document.form_inserisci.payment_module.options[document.form_inserisci.payment_module.selectedIndex].value;
		}
	}
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.descrizione.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table class="principal" cellpadding="0" cellspacing="0">
		<form action="<%=Application("baseroot") & "/editor/payments/ProcessPayment.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_payment%>" name="id_payment">
		<tr><td>
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.descrizione")%></span><br/>
		  <input type="text" name="descrizione" value="<%=strDescrizione%>" class="formFieldTXT">&nbsp;&nbsp;</div>
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.keyword_multilingua")%></span><br/>
		  <input type="text" name="keyword_multilingua" value="<%=strKeywordMultilingua%>" class="formFieldTXTLong">
		  </div><br>	
		  <span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.dati_pagamento")%></span><br>
		  <textarea name="dati_pagamento" class="formFieldTXTAREAAbstract"><%=datiPagamento%></textarea>
		  <br/><br/>	
		  <div align="left" style="float:left;padding-right:8px;"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.commission")%></span><br>
		  <input type="text" name="commission" value="<%=commission%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.commission_type")%></span><br>
			<select name="commission_type" class="formFieldTXTMedium">
			<option value="1"<%if ("1"=commission_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.payment.label.tipologia_fisso")%></option>	
			<option value="2"<%if ("2"=commission_type) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.payment.label.tipologia_percentuale")%></option>	
			</SELECT>	
		  </div>
		  <br/><br/>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.attivo")%></span><br>
		  <select name="active" class="formFieldTXTShort">
		  <option value="0" <%if (active = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
		  <option value="1" <%if (active = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
		  </select>&nbsp;&nbsp;
		  </div>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.payment_type")%></span><br>
		  <select name="payment_type" class="formFieldTXT">
		  <option value="0" <%if (payment_type = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.payment.label.no_charge")%></option>
		  <option value="1" <%if (payment_type = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.payment.label.direct_payment")%></option>
		  </select>&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.label.url")%></span><br>
		  <select name="url" class="formFieldTXTShort" onChange="javascript:showHide(); return changeExternalURL();">
		  <option value="0" <%if (url = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
		  <%if (Cint(id_payment) <> -1) then%><option value="1" <%if (url = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option><%end if%>
		  </select>
		  </div><br/>
		  
		  <div id="div_payment_field" style="<%if(url = 1) then response.Write("visibility:visibledisplay:block;") else response.Write("visibility:hidden;display:none;") end if%>;">
			<%
			if(url = 1) then
				On Error Resume Next
				Dim objPaymentModule
				Dim externalPaymentModuleList
				
				Set objPaymentModule = new PaymentModuleClass
				Set externalPaymentModuleList = objPaymentModule.getListaPaymentModuli()%>
				<br><span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.module.label.name")%></span><br>
				<select name="payment_module" class="formFieldTXT" onChange="javascript:return changePaymentModule('<%=modulo%>');">		
				<option value="-1"></option>	
				<%for each j in externalPaymentModuleList%>			
				<option value="<%=j%>" <%if (CInt(modulo) = j) then response.Write("selected")%>><%=externalPaymentModuleList(j).getNameModulo()%></option>		
				<%next%>	
				</select>		
					
				<%		
				if not (modulo = "") AND not(CInt(modulo) = -1) then
					Dim moduleInsertPage
					moduleInsertPage = Application("baseroot") & "/editor/payments/moduli/"
					moduleInsertPage = moduleInsertPage & objPaymentModule.findPaymentModuloByID(modulo).getDirectory() & "/"
					moduleInsertPage = moduleInsertPage & objPaymentModule.findPaymentModuloByID(modulo).getInsertPage()
					Session("id_modulo") = modulo 
					Session("id_payment") = id_payment
					Server.Execute(moduleInsertPage)
					Set Session("id_modulo") = nothing 
					Set Session("id_payment") = nothing
				end if
				
				Set objPaymentModule = nothing
									
				if Err.number <> 0 then
					'response.write("error="&Err.description)
				end if	
			end if		
			%>
		  </div>		  
		  <br>
		</td></tr>
		</form>		
		</table><br>
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.payment.detail.button.inserisci.label")%>" onclick="javascript:insertPayment();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/payments/ListaPayment.asp?cssClass=LPT"%>';" />
		  <br><br>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>