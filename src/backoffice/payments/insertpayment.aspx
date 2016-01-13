<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertpayment.aspx.cs" Inherits="_Payment" Debug="false" ValidateRequest="false"%>
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
<script language="JavaScript">
function insertPayment(){
	
	if(document.form_inserisci.description.value == ""){
		alert("<%=lang.getTranslated("backend.payment.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.description.focus();
		return;
	}
	
	/*
	if(document.form_inserisci.paymentData.value == ""){
		alert("<%=lang.getTranslated("backend.payment.detail.js.alert.insert_dati_pagamento_value")%>");
		document.form_inserisci.paymentData.focus();
		return;
	}
	*/
	
	var commission = document.form_inserisci.commission.value;
	if(commission == ""){
		alert("<%=lang.getTranslated("backend.currency.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.commission.focus();
		return;
	}else if(commission.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.commission.focus();
		return;		
	}

	if(document.form_inserisci.hasExternalUrl.options[document.form_inserisci.hasExternalUrl.selectedIndex].value == 1 && (document.form_inserisci.idModule.options[document.form_inserisci.idModule.selectedIndex].value == "" || document.form_inserisci.idModule.options[document.form_inserisci.idModule.selectedIndex].value == "-1")){
		alert("<%=lang.getTranslated("backend.payment.detail.js.alert.choose_module_payment_value")%>");
		return;
	}
	
	document.form_inserisci.submit()
}

function showHide(){
	if(document.form_inserisci.hasExternalUrl.options[document.form_inserisci.hasExternalUrl.selectedIndex].value == 0){
		var element = document.getElementById("div_payment_field");
		element.style.visibility = 'hidden';
		element.style.display = "none";
		$('#idModule').val(-1);
		$('#div_payment_field_container').hide();
	}else if(document.form_inserisci.hasExternalUrl.options[document.form_inserisci.hasExternalUrl.selectedIndex].value == 1){
		var element = document.getElementById("div_payment_field");
		element.style.visibility = 'visible';	
		element.style.display = "block";
	}
}

function changePaymentModule(fieldForm, id_payment){
	getModulefields(fieldForm.value, id_payment);
}

function getModulefields(id_module, id_payment){
	if(id_module != -1){		
		var query_string = "idModule="+id_module+"&idPayment="+id_payment;	
		//alert(query_string);
		$.ajax({
			async: true,
			type: "GET",
			cache: false,
			url: "/backoffice/payments/ajaxviewfields.aspx",
			data: query_string,
			success: function(response) {
				//alert(response);
				$('#div_payment_field_container').empty();
				$('#div_payment_field_container').append(response);
				$('#div_payment_field_container').show();
			},
			error: function(response) {
				//alert(response.responseText);	
			}
		});		
	}else{
		alert("<%=lang.getTranslated("backend.payment.detail.js.alert.no_id_payment")%>");
	}	
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.description.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr><td>
		<form action="/backoffice/payments/insertpayment.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=payment.id%>" name="id">
		  <input type="hidden" value="<%=cssClass%>" name="cssClass">	
		  <input type="hidden" value="insert" name="operation">
		  <span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.descrizione")%></span><br>
		  <input type="text" name="description" value="<%=payment.description%>" class="formFieldTXT">
		  <a href="javascript:showHideDiv('description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>
			<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="description_ml">
			<%
			foreach (Language x in languages){%>
			<input type="text" hspace="2" vspace="2" name="description_<%=x.label%>" id="description_<%=x.label%>" value="<%=mlangrep.translate("backend.payment.description.label."+payment.description, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>				
			</div>
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.dati_pagamento")%></span><br>
		  <textarea name="paymentData" class="formFieldTXTAREAAbstract"><%=payment.paymentData%></textarea><br><br>
		  </div>	
		  <div align="left" style="float:left;padding-right:8px;"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.commission")%></span><br>
		  <input type="text" name="commission" value="<%=payment.commission.ToString("#0.00#")%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.commission_type")%></span><br>
			<select name="commissionType" class="formFieldTXTMedium">
			<option value="0"<%if (payment.commissionType==0) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.tipologia_fisso")%></option>	
			<option value="1"<%if (payment.commissionType==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.tipologia_percentuale")%></option>	
			</SELECT>	
		  </div><br><br>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.attivo")%></span><br>
			<select name="isActive" class="formFieldTXTShort">
			<option value="0"<%if (!payment.isActive) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if (payment.isActive) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
			</SELECT>&nbsp;&nbsp;	
		  </div>
		  <div align="left" style="float:top;"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.applyto")%></span><br>
			<select name="applyTo" class="formFieldTXT">
			<option value="0"<%if (payment.applyTo==0) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_front")%></option>	
			<option value="1"<%if (payment.applyTo==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_back")%></option>	
			<option value="2"<%if (payment.applyTo==2) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.lista.table.applyto_both")%></option>	
			</SELECT>&nbsp;&nbsp;	
		  </div><br/><br/>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.payment_type")%></span><br>
		  <select name="paymentType" class="formFieldTXT">
		  <option value="0"<%if (payment.paymentType==0) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.no_charge")%></option>
		  <option value="1"<%if (payment.paymentType==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.direct_payment")%></option>
		  </select>&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.url")%></span><br>
		  <select name="hasExternalUrl" class="formFieldTXTShort" onChange="javascript:showHide();">
		  <option value="0"<%if (!payment.hasExternalUrl) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
		  <option value="1"<%if (payment.hasExternalUrl) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
		  </select>
		  </div><br/>
		  <div id="div_payment_field" style="<%if(payment.hasExternalUrl) { Response.Write("visibility:visibledisplay:block;");}else{ Response.Write("visibility:hidden;display:none;");}%>;">

			<br><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.module.label.name")%></span><br>
			<select name="idModule" id="idModule" class="formFieldTXT" onChange="javascript:return changePaymentModule(this, <%=payment.id%>);">		
			<option value="-1"></option>	
			<%
			foreach(PaymentModule value in paymentModule){%>
				<option value="<%=value.id%>"<%if (payment.idModule==value.id) { Response.Write(" selected");}%>><%=value.name%></option>
			<%}%>	
			</select>
			
			<div id="div_payment_field_container">
			
			</div>
		  </div><br/>
		  <script>
			jQuery(document).ready(function(){
			<%if(payment.hasExternalUrl && payment.idModule != -1){%>
			getModulefields(<%=payment.idModule%>,<%=payment.id%>);	
			<%}%>
			});		  
		  </script>
		</form><br>
		</td></tr>
		</table>	<br> 
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.payment.detail.button.inserisci.label")%>" onclick="javascript:insertPayment();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/payments/paymentlist.aspx?cssClass=<%=cssClass%>';" />
		<br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>