<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include file="include/init5.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">

var isSentCard = false;

function sendForm(applyBills){
	if(!isSentCard && controllaCampiInput(applyBills)){
		isSentCard = true;
		document.form_inserisci.submit();
	}else{
		return;
	}
}


function insertVoucher(doDelete){
	if(doDelete==1){
		//document.form_inserisci_voucher.voucher_delete.value="1";
		document.form_inserisci_voucher.voucher_code.value="";
	}else{
		var voucher_code = document.form_inserisci_voucher.voucher_code.value;
		if(voucher_code == ""){
			alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.insert_voucher_code")%>");
			return;
		}
		document.form_inserisci_voucher.submit();
	}  
}

function controllaCampiInput(applyBills){	
	
	// CONTROLLO SCELTA TIPO PAGAMENTO PRIMA DI INIVIARE FORM
	var paymentSelected = false;
	if(document.form_inserisci.tipo_pagam){
		if(!document.form_inserisci.tipo_pagam.length || document.form_inserisci.tipo_pagam.length<=1){
			if(document.form_inserisci.tipo_pagam.checked == true){		
				paymentSelected = true;
			}	      
		}else{
			for(var i=0; i<document.form_inserisci.tipo_pagam.length; i++){		
				if(document.form_inserisci.tipo_pagam[i].checked == true){		
					paymentSelected = true;
					break;
				}		
			}      
		}
	}

	if(!paymentSelected){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.select_payment_mode")%>");
		return false;		
	}


	// CONTROLLO SCELTA SPESE ACCESSORIE PRIMA DI INIVIARE FORM
	if(applyBills==1){
		var group_name = "";
		var arrKeys = listBills4Order.keys();	
		
		for(var k=0; k<arrKeys.length; k++){
			tmpKey = arrKeys[k];
			gn = tmpKey.substring(0, tmpKey.indexOf("-"));
			rq = tmpKey.substring(tmpKey.lastIndexOf("-")+1, tmpKey.length);
			
			if(group_name != gn){
				if(rq==1){
					var billSelected = false;
					var elem = eval("document.form_inserisci."+gn);
					if(elem){
						if(!elem.length || elem.length<=1){
							if(elem.checked == true){		
								billSelected = true;
							}	      
						}else{
							for(var i=0; i<elem.length; i++){		
								if(elem[i].checked == true){		
									billSelected = true;
									break;
								}		
							}      
						}
					}

					if(!billSelected){
						alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.select_bills")%> "+gn);
						return false;		
					}
				}
				
				group_name = gn;
			}
		}		
	}
	
	<%if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then%>
	if(applyBills==1 <%if(Application("enable_international_tax_option") = 1)then response.write(" || true") end if%>){
		// CONTROLLO CHE SIA STATO IMPOSTATO UNO SHIPPING ADDRESS
		document.form_inserisci.ship_name.value = document.getElementById("name").value;
		document.form_inserisci.ship_surname.value = document.getElementById("surname").value;
		document.form_inserisci.ship_cfiscvat.value = document.getElementById("cfiscvat").value;
		document.form_inserisci.ship_address.value = document.getElementById("address").value;
		document.form_inserisci.ship_zip_code.value = document.getElementById("zipCode").value;
		document.form_inserisci.ship_city.value = document.getElementById("city").value;
		document.form_inserisci.ship_country.value = document.getElementById("country_code").value;
		document.form_inserisci.ship_state_region.value = document.getElementById("state_region_code").value;
		document.form_inserisci.ship_is_company_client.value = document.getElementById("is_company_client_flag").value;
		
		if(document.form_inserisci.ship_name.value=="" || document.form_inserisci.ship_surname.value=="" || document.form_inserisci.ship_cfiscvat.value=="" || document.form_inserisci.ship_address.value=="" || document.form_inserisci.ship_zip_code.value=="" || document.form_inserisci.ship_city.value=="" || document.form_inserisci.ship_country.value==""){
			alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.insert_shipping_address")%>");
			return false;		
		}	
	}else{
		document.form_inserisci.ship_name.value = "";
		document.form_inserisci.ship_surname.value = "";
		document.form_inserisci.ship_cfiscvat.value = "";
		document.form_inserisci.ship_address.value = "";
		document.form_inserisci.ship_zip_code.value = "";
		document.form_inserisci.ship_city.value = "";
		document.form_inserisci.ship_country.value = "";	
		document.form_inserisci.ship_state_region.value = "";
		document.form_inserisci.ship_is_company_client.value = "0";
	}
	<%end if	

	if(Application("show_bills_box") = 1) then%>	
	// CONTROLLO CHE SIA STATO IMPOSTATO UN BILLS ADDRESS
	document.form_inserisci.bills_name.value = document.getElementById("bname").value;
	document.form_inserisci.bills_surname.value = document.getElementById("bsurname").value;
	document.form_inserisci.bills_cfiscvat.value = document.getElementById("bcfiscvat").value;
	document.form_inserisci.bills_address.value = document.getElementById("baddress").value;
	document.form_inserisci.bills_zip_code.value = document.getElementById("bzipCode").value;
	document.form_inserisci.bills_city.value = document.getElementById("bcity").value;
	document.form_inserisci.bills_country.value = document.getElementById("bcountry_code").value;
	document.form_inserisci.bills_state_region.value = document.getElementById("bstate_region_code").value;
	
	if(document.form_inserisci.bills_name.value=="" || document.form_inserisci.bills_surname.value=="" || document.form_inserisci.bills_cfiscvat.value=="" || document.form_inserisci.bills_address.value=="" || document.form_inserisci.bills_zip_code.value=="" || document.form_inserisci.bills_city.value=="" || document.form_inserisci.bills_country.value==""){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.insert_bills_address")%>");
		return false;		
	}	
	<%end if%>
	
	return true;
}

/**************
 metodo per il calcolo delle commissioni sul metodo di pagamento selezionato
***************/
var listPaymentMethods;
listPaymentMethods = new Hashtable();

function calculatePaymentCommission(imp,tax,rule,payment_method){
	var payment,commission,type, amount;
	total_imp_amount = Number(imp.replace(',','.'));
	total_tax_amount = Number(tax.replace(',','.'));
	total_rule_amount = Number(rule.replace(',','.'));
	
	/****** ricalcolo le spese accessorie *******/
	
	var arrKeys = listBills4Order.keys();		
	var arrKeysOld = listBills4OrderOld.keys();	
	
	for(var k=0; k<arrKeysOld.length; k++){
		tmpKeyOld = arrKeysOld[k];
		tmpValueOld = listBills4OrderOld.get(tmpKeyOld);
		bill_imp_amount_old = tmpValueOld.substring(0, tmpValueOld.indexOf("|")).replace(',','.');
		bill_tax_amount_old = tmpValueOld.substring(tmpValueOld.indexOf("|")+1, tmpValueOld.length).replace(',','.');
		total_imp_amount = Number(total_imp_amount)-Number(bill_imp_amount_old);
		total_tax_amount = Number(total_tax_amount)-Number(bill_tax_amount_old);		
	}
			
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	
		bill_imp_amount = tmpValue.substring(0, tmpValue.indexOf("|")).replace(',','.');
		bill_tax_amount = tmpValue.substring(tmpValue.indexOf("|")+1, tmpValue.length).replace(',','.');	
		elem = document.getElementById(tmpKey);		
		if(elem.checked==true){
			total_imp_amount = Number(total_imp_amount)+Number(bill_imp_amount);
			total_tax_amount = Number(total_tax_amount)+Number(bill_tax_amount);	
		}
	}	
	total_order = (Number(total_imp_amount)+Number(total_tax_amount)+Number(total_rule_amount)).toFixed(2);
	
	/****** fine ricalcolo spese accessorie *******/
	
	payment = listPaymentMethods.get(payment_method);
	commission = payment.substring(0, payment.indexOf("|"));
	type = payment.substring(payment.indexOf("|")+1, payment.length);
	commission_amount = 0;
	commission = Number(commission.replace(',','.'));

	if(type == 2){
		commission_amount = (total_order * (commission / 100)).toFixed(2);
		total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
	}else{
		commission_amount = Number(commission).toFixed(2);
		total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
	}
	
	$("#payment_commission").empty();
	$("#ord_total").empty();
	$("#payment_commission").append(addSeparatorsNF(commission_amount,'.',',','.'));
	$("#ord_total").append(addSeparatorsNF(total_order,'.',',','.'));
}

/**************
 metodo per il calcolo delle spese per ordine selezionate dall'utente
***************/
var listBills4Order,listBills4OrderOld;
listBills4Order = new Hashtable();
listBills4OrderOld = new Hashtable();

function calculateBills4Order(imp,tax,rule){

	var bill_imp_amount,bill_tax_amount,total_imp_amount,total_tax_amount,elem;
	total_imp_amount = Number(imp.replace(',','.'));
	total_tax_amount = Number(tax.replace(',','.'));
	total_rule_amount = Number(rule.replace(',','.'));
	
	var arrKeys = listBills4Order.keys();	
	var arrKeysOld = listBills4OrderOld.keys();	
	
	for(var k=0; k<arrKeysOld.length; k++){
		tmpKeyOld = arrKeysOld[k];
		tmpValueOld = listBills4OrderOld.get(tmpKeyOld);
		bill_imp_amount_old = tmpValueOld.substring(0, tmpValueOld.indexOf("|")).replace(',','.');
		bill_tax_amount_old = tmpValueOld.substring(tmpValueOld.indexOf("|")+1, tmpValueOld.length).replace(',','.');
		total_imp_amount = Number(total_imp_amount)-Number(bill_imp_amount_old);
		total_tax_amount = Number(total_tax_amount)-Number(bill_tax_amount_old);		
	}
		
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	

		bill_imp_amount = tmpValue.substring(0, tmpValue.indexOf("|")).replace(',','.');
		bill_tax_amount = tmpValue.substring(tmpValue.indexOf("|")+1, tmpValue.length).replace(',','.');
		
		//alert("tmpKey: "+tmpKey+"; bill_imp_amount: "+bill_imp_amount+"; bill_tax_amount: "+bill_tax_amount);
	
		elem = document.getElementById(tmpKey);
		
		if(elem.checked==true){
			total_imp_amount = Number(total_imp_amount)+Number(bill_imp_amount);
			total_tax_amount = Number(total_tax_amount)+Number(bill_tax_amount);	
		
			//alert("total_imp_amount: "+total_imp_amount+"; total_tax_amount: "+total_tax_amount);	
		}
	}
	
	total_order = (Number(total_imp_amount)+Number(total_tax_amount)+Number(total_rule_amount)).toFixed(2);

	/****** ricarico la lista dei metodi di pagamento disponibili *******/
	var tipo_pagam_tmp;
	if(document.form_inserisci.tipo_pagam){
		if(!document.form_inserisci.tipo_pagam.length || document.form_inserisci.tipo_pagam.length<=1){
			if(document.form_inserisci.tipo_pagam.checked == true){
				tipo_pagam_tmp = document.form_inserisci.tipo_pagam.value;
			}	      
		}else{
			for(var i=0; i<document.form_inserisci.tipo_pagam.length; i++){		
				if(document.form_inserisci.tipo_pagam[i].checked == true){		
					tipo_pagam_tmp = document.form_inserisci.tipo_pagam[i].value;
					break;
				}		
			}      
		}
	}
	ajaxReloadPaymentList(total_order, Number(imp.replace(',','.')), Number(tax.replace(',','.')), Number(rule.replace(',','.')),tipo_pagam_tmp);

	/****** ricalcolo le commissioni pagamento *******/

	paymentSelected = false;
	if(document.form_inserisci.tipo_pagam){
		if(!document.form_inserisci.tipo_pagam.length || document.form_inserisci.tipo_pagam.length<=1){
			if(document.form_inserisci.tipo_pagam.checked == true){		
				paymentSelected = true;
				payment_method = document.form_inserisci.tipo_pagam.value;
			}	      
		}else{
			for(var i=0; i<document.form_inserisci.tipo_pagam.length; i++){		
				if(document.form_inserisci.tipo_pagam[i].checked == true){		
					paymentSelected = true;
					payment_method = document.form_inserisci.tipo_pagam[i].value;
					break;
				}		
			}      
		}
	}
	
	if(paymentSelected){
		payment = listPaymentMethods.get(payment_method);
		commission = payment.substring(0, payment.indexOf("|"));
		type = payment.substring(payment.indexOf("|")+1, payment.length);
		commission_amount = 0;
		commission = Number(commission.replace(',','.'));
	
		if(type == 2){
			commission_amount = (total_order * (commission / 100)).toFixed(2);
			total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
		}else{
			commission_amount = Number(commission).toFixed(2);
			total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
		}	
	
		$("#payment_commission").empty();
		$("#payment_commission").append(addSeparatorsNF(commission_amount,'.',',','.'));
	}
	
	/****** fine ricalcolo commissioni pagamento *******/
	
	total_imp_amount = Number(total_imp_amount).toFixed(2);
	total_tax_amount = Number(total_tax_amount).toFixed(2);

	
	$("#imp_total").empty();
	$("#tax_total").empty();
	$("#ord_total").empty();
	$("#imp_total").append(addSeparatorsNF(total_imp_amount,'.',',','.'));
	$("#tax_total").append(addSeparatorsNF(total_tax_amount,'.',',','.'));
	$("#ord_total").append(addSeparatorsNF(total_order,'.',',','.'));
}



function addSeparatorsNF(nStr, inD, outD, sep){
	nStr += '';
	var dpos = nStr.indexOf(inD);
	var nStrEnd = '';
	if (dpos != -1) {
		nStrEnd = outD + nStr.substring(dpos + 1, nStr.length);
		nStr = nStr.substring(0, dpos);
	}
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(nStr)) {
		nStr = nStr.replace(rgx, '$1' + sep + '$2');
	}
	return nStr + nStrEnd;
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

function ajaxReloadPaymentList(totale_ord, totale_imp_ord, totale_tasse_ord, totale_rule_ord, payment_method){
	var query_string = "totale_ord="+totale_ord+"&totale_imp_ord="+totale_imp_ord+"&totale_tasse_ord="+totale_tasse_ord+"&totale_rule_ord="+totale_rule_ord+"&tipo_pagam="+payment_method;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "GET",
		cache: false,
		url: "<%=Application("baseroot") & "/editor/ordini/ajaxreloadpaymentlist.asp"%>",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			$("#payment_list").empty();
			$("#payment_list").append(response);
		},
		error: function() {
			//alert("errorrrrrrrrrr!");
			$("#payment_list").empty();
			$("#payment_list").append("<%=langEditor.getTranslated("backend.commons.fail_updated_field")%>");
		}
	});
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LO"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
		<td><a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine1.asp?id_ordine="&id_order&"&order_modified="&order_modified%>"><img src="<%=Application("baseroot")&"/editor/img/utenti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.order_client")%>"></a></td>
		<td width="100" align="center"><img src="<%=Application("baseroot")&"/editor/img/freccia_order.jpg"%>" hspace="0" vspace="0" border="0"></td>
		<td>
		<%if(CInt(id_order) <> -1 AND CInt(order_modified) <> 1) then%>
			<a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_order&"&resetMenu=1"%>"><img src="<%=Application("baseroot")&"/editor/img/prodotti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%>"></a>
		<%else%>
			<img src="<%=Application("baseroot")&"/editor/img/prodotti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%>">
		<%end if%>
		</td>
		<td width="100" align="center"><img src="<%=Application("baseroot")&"/editor/img/freccia_order.jpg"%>" hspace="0" vspace="0" border="0"></td>
		<td>
		<%if(CInt(id_order) <> -1 AND CInt(order_modified) <> 1) then%>
			<a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine3.asp?id_ordine="&id_order%>"><img src="<%=Application("baseroot")&"/editor/img/pagamento.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.tipo_pagam_order")%>"></a>
		<%else%>
			<img src="<%=Application("baseroot")&"/editor/img/pagamento.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.tipo_pagam_order")%>">
		<%end if%>
		</td>
		</tr>
		</table>
		<br/><br/>

		<table border="0" cellpadding="0" cellspacing="0" class="principal">
		<tr>
		<td>		
		  <span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.order_client")%></span>:&nbsp;
		  <%			
			if(not(id_utente = "")) then	  
		  		response.write(objClientTmpUsr)

				if(not(scontoCliente= "")) then
					scontoCliente = Cdbl(scontoCliente)
					if(scontoCliente > 0) then
						hasSconto = true%>
						&nbsp;(<%=langEditor.getTranslated("backend.ordini.detail.table.label.sconto_cliente")%>:&nbsp;<%=scontoCliente%>%)
					<%end if
				end if

				if(hasGroup) then
					response.write("<br/>"&langEditor.getTranslated("backend.ordini.detail.table.label.if_client_has_group")&groupDesc)
				else
					if(hasSconto AND Application("manage_sconti") = 0) then
						response.write("<br/>"&langEditor.getTranslated("backend.ordini.detail.table.label.if_client_has_sconto"))
					end if
				end if
			else
				response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
			end if
		  %>
		<br><br>
		<%
		Dim objListProd4Rule
		applyBills = false
		totImpTmp4bills = 0
		totale_qta_order = 0
		bolHasProdRule = false		

		if(hasSelProdPerOrder) then
			On Error Resume Next
			Set objListProd4Rule = objRule.findRuleOrderAssociationsByOrder(id_order, true)
			if (objListProd4Rule.count>0) then
				bolHasProdRule = true
			end if
			If Err.Number<>0 then
				bolHasProdRule = false
			end if

			On Error Resume Next								
			for each z in objSelProdPerOrder.Keys
				prod_type = objSelProdPerOrder(z).getProdType()
				bolExcludeBills = false
				
				if (bolHasProdRule) then
					for each w in objListProd4Rule
						tmpIdProd = objListProd4Rule(w).getProdID() 
						tmpCounterProd = objListProd4Rule(w).getCounterProd() 
						if(tmpIdProd=objSelProdPerOrder(z).getIDProdotto() AND tmpCounterProd=objSelProdPerOrder(z).getCounterProd())then
							tmpType = objListProd4Rule(w).getRuleType()
							if(Cint(tmpType)=10)then
								bolExcludeBills = true
							end if
						end if
					next
				end if

				if (prod_type=0 AND not(bolExcludeBills)) then
					applyBills = true
					totImpTmp4bills = totImpTmp4bills + objSelProdPerOrder(z).getTotale()					
					totale_qta_order=totale_qta_order+Cint(objSelProdPerOrder(z).getQtaProdotto())
				end if
			next

			If Err.Number<>0 then
			applyBills = false
			end if
		end if


		  ' *****************************************************		
		  ' INIZIO: CODICE GESTIONE SHIPPING ADDRESS	
		  
		  Dim objCountry 
		  Set objCountry = New CountryClass		  
	
		  if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then 
			  if(applyBills) OR (Application("enable_international_tax_option") = 1) then%>
				  <div align="left" <%if(Cint(order_modified)=1) then%>onClick="javascript:showHideDiv('divShipCost')"<%end if%>><span class="labelForm">
				  <%if(Application("enable_international_tax_option") = 1 AND not(applyBills))then%>
				  <%=langEditor.getTranslated("backend.ordini.detail.table.label.shipping_address_international_tax")%>
				  <%else%>
				  <%=langEditor.getTranslated("backend.ordini.detail.table.label.shipping_address")%>
				  <%end if%>
				</span>:<img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=langEditor.getTranslated("backend.ordini.detail.table.label.change_ship_address")%>"><br/>
				  <%if(hasShipAddress)then
					if(Cint(userIsCompanyClient)=0) then
						userLabelIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_private")
					else
						userLabelIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_company")
					end if
					response.write(userName & " " & userSurname & " ("&userLabelIsCompanyClient&") - " & userCfiscVat & " - " & userAddress &" - "&userCity&" ("&userZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegionLabel)
				  end if%>
				  </div>
				  <div id="divShipCost"  <%if not(hasShipAddress)then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
					  <form name="shipping_address_form" id="shipping_address_form" method="post" action="<%=Application("baseroot") &"/editor/ordini/processordine2.asp"%>" enctype="multipart/form-data">
					  <input type="hidden" name="complete_selected_prod_list" value="<%=request("complete_selected_prod_list")%>" />
					  <input type="hidden" name="order_modified" value="<%=order_modified%>" />
					  <input type="hidden" name="id_ordine" value="<%=id_order%>" />
					  
					  <input type="hidden" value="" name="bills_name">
					  <input type="hidden" value="" name="bills_surname">
					  <input type="hidden" value="" name="bills_cfiscvat">
					  <input type="hidden" value="" name="bills_address">
					  <input type="hidden" value="" name="bills_zip_code">
					  <input type="hidden" value="" name="bills_city">
					  <input type="hidden" value="" name="bills_country">
					  <input type="hidden" value="" name="bills_state_region"> 
					  
					  <br/><div style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.name")%></span><br>
					  <input type="text" name="ship_name" id="name" value="<%=userName%>" class="formFieldTXT"></div>
					  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.surname")%></span><br>
					  <input type="text" name="ship_surname" id="surname" value="<%=userSurname%>" class="formFieldTXT"></div>
					  <div style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.cod_fisc_piva")%></span><br>
					  <input type="text" name="ship_cfiscvat" id="cfiscvat" value="<%=userCfiscVat%>" class="formFieldTXT"></div>
					  <div style="padding-bottom:10px;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.is_company_client")%></span><br>
					  <select name="ship_is_company_client" id="is_company_client_flag">
					  <option value="0" <%if (Cint(userIsCompanyClient) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.utenti.detail.table.label.is_private")%></option>
					  <option value="1" <%if (Cint(userIsCompanyClient) = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.utenti.detail.table.label.is_company")%></option>
					  </select></div>
					  <div style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.address")%></span><br>
					  <input type="text" name="ship_address" id="address" value="<%=userAddress%>" class="formFieldTXT"></div>
					  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.zip_code")%></span><br>
					  <input type="text" name="ship_zip_code" id="zipCode" value="<%=userZipCode%>" class="formFieldTXT"></div>
					  <div style="float:left;">
					  <span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.city")%><br>
					  <input type="text" name="ship_city" id="city" value="<%=userCity%>" class="formFieldTXT">
					  </span></div>
					  <div style="float:left;padding-right:3px;">
					  <span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.country")%></span><br>
					  <select name="ship_country" id="country_code" class="formFieldSelectSimple">
					  <option value=""></option>
						<%On Error Resume next
						Set specialFieldValue = objCountry.findCountryListOnly("2,3")
						if (Instr(1, typename(specialFieldValue), "Dictionary", 1) > 0) then				    
						for each x in specialFieldValue
							key =  specialFieldValue(x).getCountryCode()
							selected = ""
							if (strComp(key, userCountry, 1) = 0) then selected=" selected" end if%>
							<option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(langEditor.getTranslated("portal.commons.select.option.country."&key))%></option>     
						<%next
						end if
						Set specialFieldValue = nothing
						if(Err.number<>0) then
						end if%>
					  </select> 
					  </div>
					  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.state_region")%></span><br>	 
					  <select name="ship_state_region" id="state_region_code" class="formFieldSelectSimple">
					  <option value=""></option>
						<%
						if(userCountry<>"")then
							On Error Resume next
							Set specialFieldValue = objCountry.findStateRegionListByCountry(userCountry,"2,3")
							if (Instr(1, typename(specialFieldValue), "Dictionary", 1) > 0) then				    
							for each x in specialFieldValue
								key =  specialFieldValue(x).getStateRegionCode()
								selected = ""
								if (strComp(key, userStateRegion, 1) = 0) then selected=" selected" end if%>
								<option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(langEditor.getTranslated("portal.commons.select.option.country."&key))%></option>     
							<%next
							end if
							Set specialFieldValue = nothing
							if(Err.number<>0) then
							end if
						end if%>
					  </select>	
					  </div>
						<script>
						<%if(Application("enable_international_tax_option") = 1) then%>
						$('#country_code').change(function() {
							$('#prodotto-totale').hide();

							var query_string = "?ship_country="+encodeURIComponent($('#country_code').val())
							query_string+="&ship_state_region="

							query_string+="&id_ordine=<%=id_order%>";
							query_string+="&order_modified=<%=order_modified%>";
							query_string+="&complete_selected_prod_list=<%=Server.URLEncode(request("complete_selected_prod_list"))%>";
		
							query_string+="&ship_name="+encodeURIComponent($('#name').val());
							query_string+="&ship_surname="+encodeURIComponent($('#surname').val());
							query_string+="&ship_cfiscvat="+encodeURIComponent($('#cfiscvat').val());
							query_string+="&ship_address="+encodeURIComponent($('#address').val());
							query_string+="&ship_zip_code="+encodeURIComponent($('#zipCode').val());
							query_string+="&ship_city="+encodeURIComponent($('#city').val());
							query_string+="&ship_is_company_client="+encodeURIComponent($('#is_company_client_flag').val());
							
							<%if(Application("show_bills_box") = 1)then%>
							query_string+="&bills_name="+encodeURIComponent($('#bname').val());
							query_string+="&bills_surname="+encodeURIComponent($('#bsurname').val());
							query_string+="&bills_cfiscvat="+encodeURIComponent($('#bcfiscvat').val());
							query_string+="&bills_address="+encodeURIComponent($('#baddress').val());
							query_string+="&bills_zip_code="+encodeURIComponent($('#bzipCode').val());
							query_string+="&bills_city="+encodeURIComponent($('#bcity').val());
							query_string+="&bills_country="+encodeURIComponent($('#bcountry_code').val());
							query_string+="&bills_state_region="+encodeURIComponent($('#bstate_region_code').val());
							<%end if%>

							//var url = '<%=Application("baseroot") &"/editor/ordini/processordine2.asp"%>'+query_string;
							//window.location.href = url;
							
							<%if(Application("show_bills_box") = 1)then%>
							document.shipping_address_form.bills_name.value=encodeURIComponent($('#bname').val());
							document.shipping_address_form.bills_surname.value=encodeURIComponent($('#bsurname').val());
							document.shipping_address_form.bills_cfiscvat.value=encodeURIComponent($('#bcfiscvat').val());
							document.shipping_address_form.bills_address.value=encodeURIComponent($('#baddress').val());
							document.shipping_address_form.bills_zip_code.value=encodeURIComponent($('#bzipCode').val());
							document.shipping_address_form.bills_city.value=encodeURIComponent($('#bcity').val());
							document.shipping_address_form.bills_country.value=encodeURIComponent($('#bcountry_code').val());
							document.shipping_address_form.bills_state_region.value=encodeURIComponent($('#bstate_region_code').val());
							<%end if%>							
							$('#shipping_address_form').submit();
						});


						$('#state_region_code').change(function() {
							$('#prodotto-totale').hide();

							var query_string = "?ship_country="+encodeURIComponent($('#country_code').val())
							query_string+="&ship_state_region="+encodeURIComponent($('#state_region_code').val())

							query_string+="&id_ordine=<%=id_order%>";
							query_string+="&order_modified=<%=order_modified%>";
							query_string+="&complete_selected_prod_list=<%=Server.URLEncode(request("complete_selected_prod_list"))%>";
		
							query_string+="&ship_name="+encodeURIComponent($('#name').val());
							query_string+="&ship_surname="+encodeURIComponent($('#surname').val());
							query_string+="&ship_cfiscvat="+encodeURIComponent($('#cfiscvat').val());
							query_string+="&ship_address="+encodeURIComponent($('#address').val());
							query_string+="&ship_zip_code="+encodeURIComponent($('#zipCode').val());
							query_string+="&ship_city="+encodeURIComponent($('#city').val());
							query_string+="&ship_is_company_client="+encodeURIComponent($('#is_company_client_flag').val());
		
							<%if(Application("show_bills_box") = 1)then%>
							query_string+="&bills_name="+encodeURIComponent($('#bname').val());
							query_string+="&bills_surname="+encodeURIComponent($('#bsurname').val());
							query_string+="&bills_cfiscvat="+encodeURIComponent($('#bcfiscvat').val());
							query_string+="&bills_address="+encodeURIComponent($('#baddress').val());
							query_string+="&bills_zip_code="+encodeURIComponent($('#bzipCode').val());
							query_string+="&bills_city="+encodeURIComponent($('#bcity').val());
							query_string+="&bills_country="+encodeURIComponent($('#bcountry_code').val());
							query_string+="&bills_state_region="+encodeURIComponent($('#bstate_region_code').val());
							<%end if%>
		
							//var url = '<%=Application("baseroot") &"/editor/ordini/processordine2.asp"%>'+query_string;
							//window.location.href = url;
							<%if(Application("show_bills_box") = 1)then%>
							document.shipping_address_form.bills_name.value=encodeURIComponent($('#bname').val());
							document.shipping_address_form.bills_surname.value=encodeURIComponent($('#bsurname').val());
							document.shipping_address_form.bills_cfiscvat.value=encodeURIComponent($('#bcfiscvat').val());
							document.shipping_address_form.bills_address.value=encodeURIComponent($('#baddress').val());
							document.shipping_address_form.bills_zip_code.value=encodeURIComponent($('#bzipCode').val());
							document.shipping_address_form.bills_city.value=encodeURIComponent($('#bcity').val());
							document.shipping_address_form.bills_country.value=encodeURIComponent($('#bcountry_code').val());
							document.shipping_address_form.bills_state_region.value=encodeURIComponent($('#bstate_region_code').val());
							<%end if%>	
							$('#shipping_address_form').submit();
						});


						$('#is_company_client_flag').change(function() {
							$('#prodotto-totale').hide();

							var query_string = "?ship_country="+encodeURIComponent($('#country_code').val())
							query_string+="&ship_state_region="+encodeURIComponent($('#state_region_code').val())

							query_string+="&id_ordine=<%=id_order%>";
							query_string+="&order_modified=<%=order_modified%>";
							query_string+="&complete_selected_prod_list=<%=Server.URLEncode(request("complete_selected_prod_list"))%>";
		
							query_string+="&ship_name="+encodeURIComponent($('#name').val());
							query_string+="&ship_surname="+encodeURIComponent($('#surname').val());
							query_string+="&ship_cfiscvat="+encodeURIComponent($('#cfiscvat').val());
							query_string+="&ship_address="+encodeURIComponent($('#address').val());
							query_string+="&ship_zip_code="+encodeURIComponent($('#zipCode').val());
							query_string+="&ship_city="+encodeURIComponent($('#city').val());
							query_string+="&ship_is_company_client="+encodeURIComponent($('#is_company_client_flag').val());
		
							<%if(Application("show_bills_box") = 1)then%>
							query_string+="&bills_name="+encodeURIComponent($('#bname').val());
							query_string+="&bills_surname="+encodeURIComponent($('#bsurname').val());
							query_string+="&bills_cfiscvat="+encodeURIComponent($('#bcfiscvat').val());
							query_string+="&bills_address="+encodeURIComponent($('#baddress').val());
							query_string+="&bills_zip_code="+encodeURIComponent($('#bzipCode').val());
							query_string+="&bills_city="+encodeURIComponent($('#bcity').val());
							query_string+="&bills_country="+encodeURIComponent($('#bcountry_code').val());
							query_string+="&bills_state_region="+encodeURIComponent($('#bstate_region_code').val());
							<%end if%>
		
							//var url = '<%=Application("baseroot") &"/editor/ordini/processordine2.asp"%>'+query_string;
							//window.location.href = url;
							<%if(Application("show_bills_box") = 1)then%>
							document.shipping_address_form.bills_name.value=encodeURIComponent($('#bname').val());
							document.shipping_address_form.bills_surname.value=encodeURIComponent($('#bsurname').val());
							document.shipping_address_form.bills_cfiscvat.value=encodeURIComponent($('#bcfiscvat').val());
							document.shipping_address_form.bills_address.value=encodeURIComponent($('#baddress').val());
							document.shipping_address_form.bills_zip_code.value=encodeURIComponent($('#bzipCode').val());
							document.shipping_address_form.bills_city.value=encodeURIComponent($('#bcity').val());
							document.shipping_address_form.bills_country.value=encodeURIComponent($('#bcountry_code').val());
							document.shipping_address_form.bills_state_region.value=encodeURIComponent($('#bstate_region_code').val());
							<%end if%>	
							$('#shipping_address_form').submit();
						});

						<%else%>
		
						$('#country_code').change(function() {
							var type_val_ch = $('#country_code').val();
							var query_string = "field_val="+encodeURIComponent(type_val_ch);
		
							$.ajax({
								async: true,
								type: "GET",
								cache: false,
								url: "<%=Application("baseroot") & "/editor/include/ajaxstateregionlistupdate.asp"%>",
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
						<%end if%>
						</script>
					</form>  
				  </div>
				  <%Set objShip = nothing%>
				<br><br>		
			<%end if
		  end if
		
		' *****************************************************		
		  ' INIZIO: CODICE GESTIONE BILLS ADDRESS
		  if(Application("show_bills_box") = 1) then%>
			  <div align="left" <%if(order_modified=1) then%>onClick="javascript:showHideDiv('divBillsCost')"<%end if%>><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.bills_address")%></span>:<img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=langEditor.getTranslated("backend.ordini.detail.table.label.change_bills_address")%>"><br/>
			  <%if(hasBillsAddress)then
				response.write(buserName & " " & buserSurname & " - " & buserCfiscVat & " - " & buserAddress &" - "&buserCity&" ("&buserZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&buserCountry)&buserStateRegionLabel)
			  end if%>
			  </div>
			  <div id="divBillsCost"  <%if not(hasBillsAddress)then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
				  <br/><div style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.name")%></span><br>
				  <input type="text" id="bname" value="<%=buserName%>" class="formFieldTXT"></div>
				  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.surname")%></span><br>
				  <input type="text" id="bsurname" value="<%=buserSurname%>" class="formFieldTXT"></div>
				  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.cod_fisc_piva")%></span><br>
				  <input type="text" id="bcfiscvat" value="<%=buserCfiscVat%>" class="formFieldTXT"></div>
				  <div style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.address")%></span><br>
				  <input type="text" id="baddress" value="<%=buserAddress%>" class="formFieldTXT"></div>
				  <div><span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.zip_code")%></span><br>
				  <input type="text" id="bzipCode" value="<%=buserZipCode%>" class="formFieldTXT"></div>
				  <div style="float:left;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.city")%><br>
				  <input type="text" id="bcity" value="<%=buserCity%>" class="formFieldTXT">
				  </span></div>
				  <div style="float:left;padding-right:3px;">
				  <span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.country")%></span><br>
				  <select id="bcountry_code" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					On Error Resume next
					Set specialFieldValue = objCountry.findCountryListOnly("2,3")	
					if (Instr(1, typename(specialFieldValue), "Dictionary", 1) > 0) then			    
					for each x in specialFieldValue
						key =  specialFieldValue(x).getCountryCode()
						selected = ""
						if (strComp(key, buserCountry, 1) = 0) then selected=" selected" end if%>
						<option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(langEditor.getTranslated("portal.commons.select.option.country."&key))%></option>     
					<%next
					end if
					Set specialFieldValue = nothing
					if(Err.number<>0) then
					end if%>
				  </select>  
				  </div>  
				  <div>
				  <span class="labelForm"><%=langEditor.getTranslated("backend.utenti.detail.table.label.state_region")%></span><br>	 
				  <select id="bstate_region_code" class="formFieldSelectSimple">
				  <option value=""></option>
					<%
					if(buserCountry<>"")then
						On Error Resume next
						Set specialFieldValue = objCountry.findStateRegionListByCountry(buserCountry,"2,3")	
						if (Instr(1, typename(specialFieldValue), "Dictionary", 1) > 0) then		    
						for each x in specialFieldValue
							key =  specialFieldValue(x).getStateRegionCode()
							selected = ""
							if (strComp(key, buserStateRegion, 1) = 0) then selected=" selected" end if%>
							<option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(langEditor.getTranslated("portal.commons.select.option.country."&key))%></option>     
						<%next
						end if
						Set specialFieldValue = nothing
						if(Err.number<>0) then
						end if
					end if%>
				  </select>	  
				  </div>
					<script>
					$('#bcountry_code').change(function() {
						var type_val_ch = $('#bcountry_code').val();
						var query_string = "field_val="+encodeURIComponent(type_val_ch);
	
						$.ajax({
							async: true,
							type: "GET",
							cache: false,
							url: "<%=Application("baseroot") & "/editor/include/ajaxstateregionlistupdate.asp"%>",
							data: query_string,
							success: function(response) {
								//alert("response: "+response);
								$("select#bstate_region_code").empty();
								$("select#bstate_region_code").append($("<option></option>").attr("value","").text(""));
								$("select#bstate_region_code").append(response);
							},
							error: function() {
								$("select#bstate_region_code").empty();
								$("select#bstate_region_code").append($("<option></option>").attr("value","").text(""));
							}
						});
					});
					</script> 
			  </div>
			  <%		  
			  Set objBills = nothing
		  end if
		  Set objCountry = nothing%>		
		<br>
		
		
		<%if(hasActiveVoucherCampaign AND Cint(order_modified)=1)then%>        
			<div>
			<form name="form_inserisci_voucher" id="form_inserisci_voucher" method="post" action="<%=Application("baseroot") &"/editor/ordini/processordine2.asp"%>" enctype="multipart/form-data">
			<input type="hidden" name="complete_selected_prod_list" value="<%=request("complete_selected_prod_list")%>" />
			<input type="hidden" name="order_modified" value="<%=order_modified%>" />
			<input type="hidden" name="id_ordine" value="<%=id_order%>" />
			<input type="hidden" value="0" name="voucher_delete">
			<%if(voucher_message<>"")then
			response.write("<span class=error>"&voucher_message&"</span><br/>")
			end if%>
			<strong><%=langEditor.getTranslated("backend.ordini.detail.table.label.voucher_code")%></strong>&nbsp;<input type="text" id="voucher_code" name="voucher_code" value="">
			<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(0);" value="<%=langEditor.getTranslated("backend.ordini.detail.table.label.insert_voucher")%>">&nbsp;<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(1);" value="<%=langEditor.getTranslated("backend.ordini.detail.table.label.delete_voucher")%>">   
			</form>
			</div><br>
		<%end if%>		
		
		
		<%' *****************************************************		
		  ' INIZIO: CODICE RECUPERO/GESTIONE LISTA PRODOTTI
		%>
		<br><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%></span><br>
		<table class="inner-table" border="0" cellpadding="0" cellspacing="0">
			  <tr> 
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.nome_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.prezzo_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.tax_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.qta_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>
			  </tr>				  
			<%
			if(hasSelProdPerOrder) then											
				Dim intCount, descTassa, totale_qta_order
				intCount = 0
				
				Dim styleRow, styleRow2, imponibile, tasse, objListAllFieldxProd
				styleRow2 = "table-list-on"	
				
				On Error Resume Next
				'** inizializzo mappa dei field per prodotto selezionati				 
				Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")				
				If Err.Number<>0 then
				end if

				for each z in objSelProdPerOrder.Keys
					imponibile = 0
					tasse = 0
					descTassa = ""
					Set objFilteredProd = objSelProdPerOrder(z)
					prod_type = objFilteredProd.getProdType()
					imponibile = objFilteredProd.getTotale()

					if(objFilteredProd.getTax() <> "") then 
					  tasse = objFilteredProd.getTax()

					  if not(langEditor.getTranslated("portal.commons.order_taxs.label."&objFilteredProd.getDescTax())="") then
						  descTassa = "&nbsp;&nbsp;("&langEditor.getTranslated("portal.commons.order_taxs.label."&objFilteredProd.getDescTax())&")" 
					  else 
						  descTassa = "&nbsp;&nbsp;("&objFilteredProd.getDescTax()&")"
					  end if
					end if

					styleRow = "table-list-off"
					if(intCount MOD 2 = 0) then styleRow = styleRow2 end if%>
					<tr class="<%=styleRow%>">
					<td nowrap><strong><%=Server.HTMLEncode(objFilteredProd.getNomeProdotto())%></strong></td>
					<td>&euro;&nbsp;<%=FormatNumber(imponibile,2,-1)%>
					<%					
					On Error Resume Next
					if (bolHasProdRule) then
						for each w in objListProd4Rule
							tmpIdProd = objListProd4Rule(w).getProdID() 
							tmpCounterProd = objListProd4Rule(w).getCounterProd() 
							if(tmpIdProd=objFilteredProd.getIDProdotto() AND tmpCounterProd=objFilteredProd.getCounterProd())then
								tmpLabel = objListProd4Rule(w).getLabel()                 
								tmp_amount_rule = objListProd4Rule(w).getValoreConf()%>
								<li style="list-style-type:none;"><%if(langEditor.getTranslated("portal.commons.business_rule.label."&tmpLabel) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&tmpLabel)) else response.write(tmpLabel) end if%>:&nbsp;&euro;&nbsp;<%=FormatNumber(tmp_amount_rule, 2,-1)%><br/>
						<%	end if
						next%>
					<%end if
					If Err.Number<>0 then
					end if
					%>
					</td>
					<td>&euro;&nbsp;<%=FormatNumber(tasse,2,-1)&descTassa%></td>
					<td><%=objFilteredProd.getQtaProdotto()%></td>
					<td>
					<%
					On Error Resume Next
					Set objListProdField = objProdField.getListProductField4ProdActive(objFilteredProd.getIDProdotto())
					
					if (Instr(1, typename(objListProdField), "Dictionary", 1) > 0) then
						if(objListProdField.count > 0)then
							
							if (Instr(1, typename(objProdField.findListFieldXOrderByProd(objFilteredProd.getCounterProd(), id_order, objFilteredProd.getIDProdotto())), "Dictionary", 1) > 0) then
								Set fieldList4Order = objProdField.findListFieldXOrderByProd(objFilteredProd.getCounterProd(), id_order, objFilteredProd.getIDProdotto())			

								if(fieldList4Order.count > 0)then
									if (prod_type=0) then
										'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
										Set objDict = Server.CreateObject("Scripting.Dictionary")
										objListAllFieldxProd.add objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto(), objDict
									end if
									for each w in fieldList4Order
										Set objTmpField4Order = fieldList4Order(w)
										keys = objTmpField4Order.Keys
																	
										labelTmpForm = ""
										'hasQtaViewed = false
										for each r in keys
											Set tmpF4O = r
											
											'if not(hasQtaViewed) then
												'response.write(langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")&":&nbsp;"&r.getQtaProd()&"<br/>")
												'hasQtaViewed = true
											'end if
											if (prod_type=0) then
												Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
												objDictFieldxProd.add "id", tmpF4O.getID()
												objDictFieldxProd.add "value", tmpF4O.getSelValue()
												objDictFieldxProd.add "qta", objFilteredProd.getQtaProdotto()
												objListAllFieldxProd(objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto()).add objDictFieldxProd, ""
												Set objDictFieldxProd = nothing
											end if

											labelTmpForm = tmpF4O.getDescription()
											if(Cint(tmpF4O.getTypeField())<>9)then
												valueTmp = Server.HTMLEncode(tmpF4O.getSelValue())
											else
												valueTmp = tmpF4O.getSelValue()
											end if
											if(Cint(tmpF4O.getTypeField())=8)then
												valueTmp = "<a href=""" & valueTmp & """ target=_blank>click</a>"
											end if
											if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())="") then labelTmpForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())
											response.write("<b>"&labelTmpForm & ":</b>&nbsp;" & valueTmp & "<br/>")
										
											Set tmpF4O = nothing
										next
										Set objTmpField4Order = nothing
									next	
									Set objDict = nothing			
									Set fieldList4Order = nothing
								end if
							end if


							'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
							if (prod_type=0) then
								'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
								Set objDict = Server.CreateObject("Scripting.Dictionary")
								if not(objListAllFieldxProd.Exists(objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto()))then
									objListAllFieldxProd.add objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto(), objDict
								end if

								'response.write("<b>recupero e aggiunta field prodotto:</b><br>")

								for each d in objListProdField
									if((objListProdField(d).getTypeContent()=2 OR objListProdField(d).getTypeContent()=3) AND (objListProdField(d).getEditable()=0))then
										Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
										objDictFieldxProd.add "id", objListProdField(d).getID()
										objDictFieldxProd.add "value", objListProdField(d).getSelValue()
										objDictFieldxProd.add "qta", objFilteredProd.getQtaProdotto()

										'response.write("objDictFieldxProd(id): "&objDictFieldxProd("id")&"<br>")
										'response.write("objDictFieldxProd(value): "&objDictFieldxProd("value")&"<br>")
										'response.write("objDictFieldxProd(qta): "&objDictFieldxProd("qta")&"<br>")
										'response.write("objListAllFieldxProd.count: "&objListAllFieldxProd.count&"<br>")
										'response.write("Exists: "& objListAllFieldxProd.Exists(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()) &"<br>")
										'response.write("count: "& objListAllFieldxProd(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()).count &"<br>")
										bolCanAdd = true
										On Error Resume Next
										for each i in objListAllFieldxProd(objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto())
											'response.write(" - i(id): "&i("id")&" - list(id): "&objDictFieldxProd("id")&" - diversi: "& (Cint(i("id"))<>Cint(objDictFieldxProd("id"))) &"<br>")
											if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
												'response.write("esiste già il field associato a objListAllFieldxProd - id: "&objDictFieldxProd("id")&"<br>")
												bolCanAdd = false
												Exit for
											end if
										next

										if(bolCanAdd)then
											objListAllFieldxProd(objFilteredProd.getCounterProd()&"-"&objFilteredProd.getIDProdotto()).add objDictFieldxProd, ""
										end if
										if(Err.number<>0)then
										'response.write("Error: "&Err.description)
										end if
										Set objDictFieldxProd = nothing		
									end if
								next
								Set objDict = nothing								
							end if							
						end if
					end if
					if(Err.number <> 0) then
					end if
					%>					
					</td>				
					</tr>				
					<%intCount = intCount +1
					Set objFilteredProd = nothing
				next
				
				if(bolHasProdRule)then
					Set objListProd4Rule = nothing
				end if%>
			<%else%>
			<tr class="table-list-off">
			<td colspan="5" align="center"><strong><%=langEditor.getTranslated("backend.ordini.detail.table.label.no_product_disp")%></strong></td>
			</tr>
			<%end if
			Set objSelProdPerOrder = nothing%>
		</table><br>

		<%'FINE: *******************************************************%>			  
		  
		<form action="<%=Application("baseroot") & "/editor/ordini/ProcessOrdine3.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_order%>" name="id_ordine">
		  <input type="hidden" value="<%=applyBills%>" name="apply_bills">
		  <input type="hidden" value="<%=totImpTmp4bills%>" name="tot_imp_tmp4bills">	
		  <input type="hidden" value="<%=totale_qta_order%>" name="totale_qta_order">	  
			  
		  <input type="hidden" value="" name="ship_name">
		  <input type="hidden" value="" name="ship_surname">
		  <input type="hidden" value="" name="ship_cfiscvat">
		  <input type="hidden" value="" name="ship_address">
		  <input type="hidden" value="" name="ship_zip_code">
		  <input type="hidden" value="" name="ship_city">
		  <input type="hidden" value="" name="ship_country">
		  <input type="hidden" value="" name="ship_state_region">
		  <input type="hidden" value="" name="ship_is_company_client">
		  
		  <input type="hidden" value="" name="bills_name">
		  <input type="hidden" value="" name="bills_surname">
		  <input type="hidden" value="" name="bills_cfiscvat">
		  <input type="hidden" value="" name="bills_address">
		  <input type="hidden" value="" name="bills_zip_code">
		  <input type="hidden" value="" name="bills_city">
		  <input type="hidden" value="" name="bills_country">
		  <input type="hidden" value="" name="bills_state_region">

		<!-- ************************************************************ GESTIONE SPESE ACCESSORIE ************************************************************ -->
		<%
		if(applyBills)then%>
			<div align="left" style="float:top;"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.spese_accessorie_order")%>&nbsp;&nbsp;&nbsp;</span><br>			
			<%Dim objBillsClass, objBills4OrderClass, objTasse
			Dim objListaSpeseXOrdine, objTmpSpesa, objTmpSpesaXOrdine, oldGroupDesc
			Set objBillsClass = new BillsClass
			Set objBills4OrderClass = new Bills4OrderClass	
			Set objTasse = new TaxsClass

			On Error Resume Next
			Set objListaSpeseXOrdine = objBills4OrderClass.getSpeseXOrdine(id_order)			
			If Err.Number<>0 then
			Set objListaSpeseXOrdine = Server.CreateObject("Scripting.Dictionary") 
			end if
			
			On Error Resume Next			
			Set objListaSpese = objBillsClass.getListaSpese(null, null, null, 1)
			oldGroupDesc = ""
			
			for each j in objListaSpese.Keys
				Set objTmpSpesa = objListaSpese(j)
				totSpeseImp = 0
				totSpeseTax = 0
				
				if(oldGroupDesc<>objTmpSpesa.getGroup())then 
					if not(langEditor.getTranslated("portal.commons.order_bills.label.group."&objTmpSpesa.getGroup())="") then response.write("<b>"&langEditor.getTranslated("portal.commons.order_bills.label.group."&objTmpSpesa.getGroup())&"</b><br/>") else response.write("<b>"&objTmpSpesa.getGroup()&"</b><br/>") end if	
				end if
				
				if(objTmpSpesa.getAutoactive()=1)then
					Set objTmpSpesaXOrdine = objListaSpeseXOrdine(j)
					response.write("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"&objTmpSpesaXOrdine.getDescSpesa()&"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"&FormatNumber(objTmpSpesaXOrdine.getTotale(),2,-1)&"&nbsp;&nbsp;<br/>")
					Set objTmpSpesaXOrdine = nothing
				else
					'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
					totSpeseImp = objTmpSpesa.getImpByStrategy(totImpTmp4bills, totale_qta_order, objListAllFieldxProd)
	
					' verifico se si tratta di valore fisso o percentuale
					'if(CInt(objTmpSpesa.getTipoValore()) = 2) then
						'totSpeseImp = CDbl(totImpTmp4bills) / 100 * CDbl(objTmpSpesa.getValore())					
					'else
						'totSpeseImp = CDbl(objTmpSpesa.getValore())
					'end if
					
					
					'***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
					applyOrigTax = true
					if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
						if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
							On Error Resume Next
							objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
							if(not(isNull(objRelatedTax))) then
								Set objTaxG = objTasse.findTassaByID(objRelatedTax)
								totSpeseTax = groupClienteTax.getImportoTassa(totSpeseImp, objTaxG)
								Set objTaxG = nothing
								applyOrigTax = false
							else
								applyOrigTax = true		
							end if	
							if(Err.number<>0)then
							  applyOrigTax = true
							end if			
						else
							On Error Resume Next
							Set groupBillsTax = objTmpSpesa.getTaxGroupObj(objTmpSpesa.getTaxGroup())
							if(Instr(1, typename(groupBillsTax), "TaxsGroupClass", 1) > 0) then
								objRelatedTax = groupBillsTax.findRelatedTax(groupBillsTax.getID(), international_country_code,international_state_region_code)
			
								if(not(isNull(objRelatedTax))) then
									Set objTaxG = objTasse.findTassaByID(objRelatedTax)
									totSpeseTax = groupBillsTax.getImportoTassa(totSpeseImp, objTaxG)
									Set objTaxG = nothing
									applyOrigTax = false		
								end if								
								Set groupBillsTax = nothing
							else
								applyOrigTax = true
							end if
							Set groupBillsTax = nothing	
							if(Err.number<>0)then
							  applyOrigTax = true
							end if	
						end if
					end if
					if(applyOrigTax)then
						totSpeseTax = 0
						if not(isNull(objTmpSpesa.getIDTassaApplicata())) AND not(objTmpSpesa.getIDTassaApplicata() = "") then
							Set objBillTaxTmp = objTasse.findTassaByID(objTmpSpesa.getIDTassaApplicata())
							if(objBillTaxTmp.getTipoValore() = 2) then
								totSpeseTax = CDbl(totSpeseImp) * (CDbl(objBillTaxTmp.getValore()) / 100)
							else
								totSpeseTax = CDbl(objBillTaxTmp.getValore())
							end if	
							Set objBillTaxTmp = nothing
						end if
					end if				
					%>	
					
					<script language="Javascript">
					listBills4Order.put("<%=objTmpSpesa.getGroup()&"-"&j&"-"&objTmpSpesa.getRequired()%>","<%=totSpeseImp&"|"&totSpeseTax%>");
					<%if(objListaSpeseXOrdine.Exists(j))then%>
					listBills4OrderOld.put("<%=objTmpSpesa.getGroup()&"-"&j&"-"&objTmpSpesa.getRequired()%>","<%=totSpeseImp&"|"&totSpeseTax%>");
					<%end if%>
					</script>
					<%if(objTmpSpesa.getMultiply()=1)then%>
						<input type="checkbox" onclick="javascript:calculateBills4Order('<%=totale_imp_ord%>','<%=totale_tasse_ord%>','<%=tot_rule_amount%>');" name="<%=objTmpSpesa.getGroup()%>" id="<%=objTmpSpesa.getGroup()&"-"&j&"-"&objTmpSpesa.getRequired()%>" value="<%=j%>" <%if(objListaSpeseXOrdine.Exists(j))then response.write("checked='checked'") end if%>/> <%if not(langEditor.getTranslated("portal.commons.order_bills.label."&objTmpSpesa.getDescrizioneSpesa())="") then response.write(langEditor.getTranslated("portal.commons.order_bills.label."&objTmpSpesa.getDescrizioneSpesa())) else response.write(objTmpSpesa.getDescrizioneSpesa()) end if%>&nbsp;&nbsp;&nbsp;&euro;&nbsp;<%=FormatNumber(totSpeseImp+totSpeseTax,2,-1)%>&nbsp;&nbsp;<BR>
					<%else%>
						<input type="radio"  onclick="javascript:calculateBills4Order('<%=totale_imp_ord%>','<%=totale_tasse_ord%>','<%=tot_rule_amount%>');" name="<%=objTmpSpesa.getGroup()%>" id="<%=objTmpSpesa.getGroup()&"-"&j&"-"&objTmpSpesa.getRequired()%>" value="<%=j%>" <%if(objListaSpeseXOrdine.Exists(j))then response.write("checked='checked'") end if%>/> <%if not(langEditor.getTranslated("portal.commons.order_bills.label."&objTmpSpesa.getDescrizioneSpesa())="") then response.write(langEditor.getTranslated("portal.commons.order_bills.label."&objTmpSpesa.getDescrizioneSpesa())) else response.write(objTmpSpesa.getDescrizioneSpesa()) end if%>&nbsp;&nbsp;&nbsp;&euro;&nbsp;<%=FormatNumber(totSpeseImp+totSpeseTax,2,-1)%>&nbsp;&nbsp;<BR>					
					<%end if
				end if
				
				oldGroupDesc = objTmpSpesa.getGroup()
				Set objTmpSpesa = nothing
			next

			Set objListAllFieldxProd = nothing				
			Set objListaSpeseXOrdine = nothing
			Set objListaSpese = nothing
			Set objTasse = nothing
			Set objBills4OrderClass = nothing	
			Set objBillsClass = nothing		
			
			If Err.Number<>0 then
			end if%>
			&nbsp;&nbsp;</div>
		<%end if%>	


		<!-- ************************************************************ GESTIONE SISTEMI DI PAGAMENTO ************************************************************ -->
		  <span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.tipo_pagam_order")%></span><br>		  
		  <div id="payment_list">
		  <%
		  On Error Resume Next
		   Dim objPayment, objTmpPayment, objListaPayment, loadDirectPayment
		   loadDirectPayment = null
		   Set objPayment = New PaymentClass
		   if(totale_ord<=0) then
			loadDirectPayment = 0
		   end if
		   Set objListaPayment = objPayment.getListaPayment(1,loadDirectPayment)	
		   

		  if not(isEmpty(objListaPayment)) AND (Instr(1, typename(objListaPayment), "Dictionary", 1) > 0) then%>
		  <script language="Javascript">
		  <%for each k in objListaPayment.Keys%>
		  listPaymentMethods.put("<%=k%>","<%=objListaPayment(k).getCommission()&"|"&objListaPayment(k).getCommissionType()%>");	
		  <%next%>
		  </script>
			  <%for each k in objListaPayment.Keys%>
				<INPUT type="radio" name="tipo_pagam" value="<%=k%>" <%if (tipo_pagam = CStr(k)) then response.Write("checked='checked'") end if%> onclick="javascript:calculatePaymentCommission('<%=totale_imp_ord%>','<%=totale_tasse_ord%>','<%=tot_rule_amount%>',<%=k%>);"> <%if not(langEditor.getTranslated(objListaPayment(k).getKeywordMultilingua())="") then response.write(langEditor.getTranslated(objListaPayment(k).getKeywordMultilingua())) else response.write(objListaPayment(k).getKeywordMultilingua()) end if%><BR>
			  <%next%>
		  <%
		  end if
		   Set objListaPayment = nothing
		   Set objPayment = nothing
		   
		If Err.Number<>0 then'
		end if
		  %>
		 </div>
		  <br/>
  

		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.totale_imp_order")%>&nbsp;&nbsp;&nbsp;</span><br>
		  &euro;&nbsp;<span id="imp_total"><%=FormatNumber(totale_imp_ord,2,-1)%></span>&nbsp;&nbsp;</div>
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.totale_tax_order")%>&nbsp;&nbsp;&nbsp;</span><br>
		  &euro;&nbsp;<span id="tax_total"><%=FormatNumber(totale_tasse_ord,2,-1)%></span>&nbsp;&nbsp;</div><br/>
		
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.payment_commission")%>&nbsp;&nbsp;</span><br> 
		&euro;&nbsp;<span id="payment_commission"><%=FormatNumber(payment_commission,2,-1)%></span>&nbsp;&nbsp;<br><br>

		<%if(bolHasCalculatedRules) then
			for each x in objRule4Order%>
				<span class="labelFormFule"><%if(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>&nbsp;&nbsp;</span><br>&euro;&nbsp;<%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1)%></span>&nbsp;&nbsp;<br><br>
		<%	next					
			Set objRule4Order = nothing
		end if%>

		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.totale_order")%>&nbsp;&nbsp;</span><br>
		  &euro;&nbsp;<span id="ord_total"><%=FormatNumber(totale_ord,2,-1)%></span>&nbsp;&nbsp;<br><br>

		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.stato_order")%>&nbsp;&nbsp;&nbsp;</span><br>
		  <%
		  Dim objListaStatiOrdine, statiOrderCount, iIndexStatiOrder, objTmpStatiOrder, objTmpStatiOrderKey
		  Set objListaStatiOrdine = objOrder.getListaStatiOrder()		  
		  %>
		  <select name="stato_order" class="formFieldChangeStato">
		  <%for each w in objListaStatiOrdine.Keys%>
		  	<option value="<%=w%>" <%if (stato_order = w) then response.Write("selected")%>><%=langEditor.getTranslated(objListaStatiOrdine(w))%></option>
		  <%next%>
		  </select>
		  <%	
		   Set objUserLogged = nothing	
		   Set objGroup = nothing
		   Set objProdField = nothing
		   Set objListaStatiOrdine = nothing
		   Set objRule = nothing
		   Set objOrder = nothing
		  %>&nbsp;&nbsp;</div>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.pagam_order_done")%></span><br>		  
		  <select name="pagam_done" class="formFieldChangeStato">
		  <option value="0" <%if (pagam_done = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>
		  <option value="1" <%if (pagam_done = 1) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
		  </select>
		  </div><br>	
		  
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.order_notes")%></span><br>		  
		  <textarea name="order_notes" class="formFieldTXTAREAAbstract"><%=order_notes%></textarea>
		  </div>
		</form>
		</td>
		</tr>	
		</table><br/>
		<div id="prodotto-totale">  			
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.detail.button.inserisci.label")%>" onclick="javascript:sendForm(<%if(applyBills) then response.write("1") else response.write("0") end if%>);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/ordini/ListaOrdini.asp?cssClass=LO"%>';" />
		</div><br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>