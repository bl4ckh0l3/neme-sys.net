<%@ Page Language="C#" AutoEventWireup="true" CodeFile="checkout.aspx.cs" Inherits="_Checkout" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<script src="/common/js/hashtable.js"></script>
<script>  
var listPaymentMethods;
listPaymentMethods = new Hashtable();

var listBills4Order;
listBills4Order = new Hashtable();  


var isSentCard = false;
function sendCarrello(applyBills){
	var id_carrello = document.form_insert_carrello.cartid.value;
	if(id_carrello == ""){
		alert("<%=lang.getTranslated("frontend.carrello.js.alert.no_carrello_found")%>");
		return;
	}
	
	// CONTROLLO SCELTA TIPO PAGAMENTO PRIMA DI INIVIARE FORM
	var paymentSelected = false;
	$('[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			paymentSelected = true;
			return;
		}
	});	
	
	if(!paymentSelected){
		alert("<%=lang.getTranslated("frontend.carrello.js.alert.select_payment_mode")%>");
		return;	
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
					var elem = eval("document.form_insert_carrello."+gn);
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
						alert("<%=lang.getTranslated("frontend.carrello.js.alert.select_bills")%> "+gn);
						return;		
					}
				}
				
				group_name = gn;
			}
		}		
	}

    <%if("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value)) {%>  
	if(applyBills==1 <%if("1".Equals(confservice.get("enable_international_tax_option").value)){Response.Write(" || true");}%>){
		var check_ship = false;
		<%if(!logged) {%>
			if($("#buy_noreg").val()== "1"){
				check_ship = true;
			}
		<%}else{%>
			check_ship = true;
		<%}%>

		// CONTROLLO CHE SIA STATO IMPOSTATO UNO SHIPPING ADDRESS
		if(check_ship){	
			if(
				document.getElementById("ship_name") && 
				document.getElementById("ship_surname") && 
				document.getElementById("ship_cfiscvat") && 
				document.getElementById("ship_address") && 
				document.getElementById("ship_zip_code") && 
				document.getElementById("ship_city") && 
				document.getElementById("ship_country")
			){
				if(
					$("#ship_name").val()=="" || 
					$("#ship_surname").val()=="" || 
					$("#ship_cfiscvat").val()=="" || 
					$("#ship_address").val()=="" || 
					$("#ship_zip_code").val()=="" || 
					$("#ship_city").val()=="" || 
					$("#ship_country").val()==""
				){
					alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_shipping_address")%>");
					return;		
				}
			}
		}
	}
	<%}	

	if("1".Equals(confservice.get("show_bills_box").value)	) {%>
		var check_bills = false;
		<%if(!logged) {%>
			if($("#buy_noreg").val()== "1"){
				check_bills = true;
			}
		<%}else{%>
			check_bills = true;
		<%}%>
	
		// CONTROLLO CHE SIA STATO IMPOSTATO UN BILLS ADDRESS	
		if(check_bills){
			if(
				document.getElementById("bills_name") && 
				document.getElementById("bills_surname") && 
				document.getElementById("bills_cfiscvat") && 
				document.getElementById("bills_address") && 
				document.getElementById("bills_zip_code") && 
				document.getElementById("bills_city") && 
				document.getElementById("bills_country")
			){
				if(
					$("#bills_name").val()=="" || 
					$("#bills_surname").val()=="" || 
					$("#bills_cfiscvat").val()=="" || 
					$("#bills_address").val()=="" || 
					$("#bills_zip_code").val()=="" || 
					$("#bills_city").val()=="" || 
					$("#bills_country").val()==""
				){
					alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_bills_address")%>");
					return;		
				}
			}
		}
	<%}%>

	// CONTROLLO SE E' STATA SELEZIONATA L'OPZIONE ACQUISTA SENZA REGISTRAZIONE
	if($("#buy_noreg").val()== "1"){
		var strMail = document.form_insert_carrello.noreg_email.value;
		if(strMail != ""){
			if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
				alert("<%=lang.getTranslated("frontend.area_user.js.alert.wrong_mail")%>");
				document.form_insert_carrello.email.focus();
				return;
			}
		}else if(strMail == ""){
			alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_mail")%>");
			document.form_insert_carrello.email.focus();
			return;
		}		

		<%
		if(bolFoundFields && "1".Equals(confservice.get("show_user_field_on_direct_buy").value)){
			Response.Write(UserService.renderFieldJsFormValidation(usrfields, login.userLogged, lang.currentLangCode, lang.defaultLangCode));
		}%>	
	}

	// CONTROLLO CHE SIA CHECKED LA VISIONE DELLE CONDIZIONI CONTRATTUALI
	if(!document.form_insert_carrello.terms_condition_purchase.checked == true){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.check_conditions")%>");
		return;
	}
      
	if(!isSentCard && confirm("******  <%=lang.getTranslated("frontend.carrello.js.alert.confirm_ordina_prod")%>  ******")){
		isSentCard = true;
		$("#sendtocardloading").hide();
		$("#sendtocardloadingimg").show();
		document.form_insert_carrello.submit();
	}
}


var formSent = false;
function addToCarrello(oldQta, theFrom, counter, applyBills, checkqtafields){
	var formname = theFrom.name;
	var sel_qta = theFrom.quantity.value;
	if(sel_qta == "" || Number(sel_qta) == 0){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.select_qta_prod")%>");
		theFrom.quantity.value = oldQta;
		return;
	}else if(isNaN(sel_qta)){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.quantity.value = oldQta;
		return;
	}else if(sel_qta.indexOf('.') != -1){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.quantity.value = oldQta;
		return;
	}else if(sel_qta==oldQta){
    	return;  
    }	
	
	var hasfield4prod = false;
	var query_string = "id_prod="+theFrom.productid.value;
	query_string+="&prod_fields="
	
	var jsonfields = "";

	var fieldscounter = 0;	
	$("#"+formname+" input:hidden[name*='product_field_']").each(function(){
		var key = $(this).attr('name');
		key = key.substring(key.lastIndexOf('_')+1); 
		var myRegExp = new RegExp(/"/g);
		var thisval = $(this).val();			
		thisval = thisval.replace(myRegExp, '\&quot;');				
		jsonfields += "\""+fieldscounter+"-"+key+"\":\""+encodeURIComponent(thisval)+"\",";	
		hasfield4prod = true;
		fieldscounter++;
	});
	
	jsonfields = jsonfields.substring(0,jsonfields.lastIndexOf(","));
	jsonfields = "{"+jsonfields;
	jsonfields += "}";	
	
	query_string+=jsonfields;
	
	//alert(query_string);
	
	//integro chiamata ajax per verificare disponibilita combinazione field prodotto
	if(checkqtafields==1){
		var final_qta;
		var max_prod_qty = theFrom.max_prod_qta.value;
		
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
		
		final_qta = ajaxCheckQta4Prod(theFrom.productid.value, Number(sel_qta)-Number(oldQta));
		if(final_qta>max_prod_qty){
			$("#addtocardloadingimg"+counter).hide();
			$("#addtocardloading"+counter).show();
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%> ");
			theFrom.quantity.value = oldQta;
			return;			
		}
	
		if(hasfield4prod){
			final_qta = ajaxCheckQta4X(theFrom.name, theFrom.productid.value, Number(sel_qta)-Number(oldQta), counter, 0, 0, jsonfields);
			query_string+="&quantity="+final_qta;
			//alert("query_string 2: "+query_string);
	
			result = ajaxCheckFieldAvailability(query_string);
			//alert("result: "+result);
	
			var obj = jQuery.parseJSON(result);
			var ischecked = obj.checked;
			var message_error_qta = obj.message_error;
	
			if (ischecked!="1"){
				$("#addtocardloadingimg"+counter).hide();
				$("#addtocardloading"+counter).show();
				alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
				theFrom.quantity.value = oldQta;
				return;
			}
		}
	}
	
	if(formSent == false){
		formSent = true;
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
		theFrom.action+="?"+selectPayAndBills4Form(applyBills)
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function checkMaxQtaProd(maxQtaProd, field){
	if(Number(field.value) > maxQtaProd){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%>");
		field.value="";
	}
}
  
function checkQta6Multiple(field){
    if(Number(field.value) > 1 && Number(field.value) % 6 != 0){
      alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.no_multilpe_6_qta_prod")%>");
      field.value="";      
    }
}

function ajaxCheckQta4Prod(id_prod, qta_prod){
	var query_string = "id_prod="+id_prod+"&qta_prod="+qta_prod;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=currentBaseURL+"ajaxcheckprodqta.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("response: "+response);
			return;
		},
		error: function(response) {
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = response;
		}
	});
  
  	var final_qta = Number(qta_prod)
  	if(!isNaN(resp)){
  		final_qta+=Number(resp);
	}
	return final_qta;
}

function ajaxCheckQta4X(theForm, id_prod, qta_prod, counter, x, method, jsonfields){
	var query_string = "id_prod="+id_prod+"&prod_counter="+counter+"&qta_prod="+qta_prod+"&prod_fields="+jsonfields;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=currentBaseURL+"ajaxcheckprodfieldsqta.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("response: "+response);
			return;
		},
		error: function(response) {
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = response;
		}
	});
  
  	var final_qta = Number(qta_prod)
  	if(!isNaN(resp)){
  		final_qta+=Number(resp);
	}
  	//alert("resp: "+resp+" - final_qta: "+final_qta);
	var lock = false;
	if(method==0){
		return final_qta;
	}else if(method==1){
		if(Number(final_qta) > 1 && Number(final_qta) % x != 0){
			lock = true;
		}
	}else if(method==2){
		if(Number(final_qta) > x){
			lock = true;
		}	
	}
	if(lock){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.no_multilpe_6_qta_prod")%>");
		var objForm = $('#'+theForm);
		objForm.quantity.value="";  
		return;	
	}
}

function ajaxCheckFieldAvailability(query_string){
	//alert("query_string: "+query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		//dataType: "xml",
		url: "<%=currentBaseURL+"ajaxcheckprodavailability.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("resp: "+resp);
			//alert("ischecked: "+ischecked+" - message_error_qta: "+message_error_qta);
		},
		error: function(response) {
			resp = response;
			//alert("resp error: "+response);
		}
	});

	return resp;
}

function changeCurrency(){
	document.change_currency.submit();
}

function changeOrder(){
	document.change_order.submit();
}

function openRelatedProdPage(strAction, hierarchy, numIdProd, numPageNum){
    document.form_cart_rel_prod.action=strAction;
    document.form_cart_rel_prod.hierarchy.value=hierarchy;
    document.form_cart_rel_prod.productid.value=numIdProd;
    document.form_cart_rel_prod.modelPageNum.value=numPageNum;
    document.form_cart_rel_prod.submit();
}
  
function continueShopping(strAction, hierarchy){
    document.form_cart_continue_shop.action=strAction;
    document.form_cart_continue_shop.hierarchy.value=hierarchy;
    document.form_cart_continue_shop.submit();
}


function delFromCarrello(strAction, cartid, numIdProd, counterProd, hierarchy, applyBills){
	if(confirm("<%=lang.getTranslated("frontend.carrello.js.alert.confirm_del_prod")%>")){
		strAction+="?"+selectPayAndBills4Form(applyBills);
		document.form_cart_del_item.action=strAction;
		document.form_cart_del_item.cartid.value=cartid;
		document.form_cart_del_item.productid.value=numIdProd;
		document.form_cart_del_item.counter_prod.value=counterProd;
		document.form_cart_del_item.hierarchy.value=hierarchy;
		document.form_cart_del_item.submit();		
	}
}

function insertVoucher(doDelete){
	if(doDelete==1){
		document.form_carrello_voucher.voucher_delete.value="1";
		document.form_carrello_voucher.voucher_code.value="";
	}else{
		if(document.form_carrello_voucher.voucher_code.value==""){
			alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_code")%>");
			return;
		}
	}
	
	document.form_carrello_voucher.submit();
}

function calculatePaymentCommission(amount,payment_method, currFrom, currTo){
	var payment,commission,type;
	var total_amount = Number(amount.replace(',','.'));
  
	/****** ricalcolo le spese accessorie *******/  
	var arrKeys = listBills4Order.keys();		
			
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	
		var bill_amount = tmpValue.replace(',','.');
		elem = document.getElementById(tmpKey);		
		if(elem.checked==true){
			total_amount = Number(total_amount)+Number(bill_amount);
		}
	}	
	total_order = Number(total_amount).toFixed(2);	
	/****** fine ricalcolo spese accessorie *******/

	payment = listPaymentMethods.get(payment_method);
	commission = payment.substring(0, payment.indexOf("|"));
	type = payment.substring(payment.indexOf("|")+1, payment.length);
	commission_amount = 0;
	commission = Number(commission.replace(',','.'));
	currFrom = Number(currFrom.replace(',','.'));
	currTo = Number(currTo.replace(',','.'));

	if(type == 1){
		commission_amount = (total_order * (commission / 100)).toFixed(2);
		total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
	}else{
		commission_amount = Number(commission).toFixed(2);
		total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
	}

	// imposto il totale di carrello in euro
	$(".ord_total_def_curr").empty();
	$(".ord_total_def_curr").append(addSeparatorsNF(total_order,'.',',','.'));
  
	// converto in base alla currency selezionata dall'utente
	commission_amount = (commission_amount * (Number(currTo)/Number(currFrom))).toFixed(2);
	total_order = (total_order * (Number(currTo)/Number(currFrom))).toFixed(2);
  
	$(".payment_commission").empty();
	$(".ord_total").empty();
	$(".payment_commission").append(addSeparatorsNF(commission_amount,'.',',','.'));
	$(".ord_total").append(addSeparatorsNF(total_order,'.',',','.'));
}

function calculateBills4Order(amount, currFrom, currTo){
	var bill_amount,total_amount,elem, total_amount_4_payment;
	total_amount = amount;
  	total_amount_4_payment = total_amount;
	total_amount = Number(total_amount.replace(',','.'));
	
	var arrKeys = listBills4Order.keys();	
		
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	
		var bill_amount = tmpValue.replace(',','.');
		elem = document.getElementById(tmpKey);
		
		if(elem.checked==true){
			total_amount = Number(total_amount)+Number(bill_amount);
		}
	}

	total_order = Number(total_amount).toFixed(2);

	/****** ricarico la lista dei metodi di pagamento disponibili *******/
	var payment_method_tmp="";
	
	$('[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			payment_method_tmp = $(this).val();
			return;
		}
	});	
	ajaxReloadPaymentList(total_amount_4_payment.replace('.',','), String(total_amount).replace('.',','), payment_method_tmp);
	
	/****** ricalcolo le commissioni pagamento *******/

	paymentSelected = false;
	
	$('[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			paymentSelected = true;
			payment_method = $(this).val();
			return;
		}
	});	
	
	currFrom = Number(currFrom.replace(',','.'));
	currTo = Number(currTo.replace(',','.'));
	
	if(paymentSelected){
		payment = listPaymentMethods.get(payment_method);
		commission = payment.substring(0, payment.indexOf("|"));
		type = payment.substring(payment.indexOf("|")+1, payment.length);
		commission_amount = 0;
		commission = Number(commission.replace(',','.'));
	
		if(type == 1){
			commission_amount = (total_order * (commission / 100)).toFixed(2);
			total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
		}else{
			commission_amount = Number(commission).toFixed(2);
			total_order = (Number(total_order)+Number(commission_amount)).toFixed(2);
		}	
	
		// converto in base alla currency selezionata dall'utente
		commission_amount = (commission_amount * (Number(currTo)/Number(currFrom))).toFixed(2);
		
		$(".payment_commission").empty();
		$(".payment_commission").append(addSeparatorsNF(commission_amount,'.',',','.'));
	}
	
	/****** fine ricalcolo commissioni pagamento *******/

	// imposto il totale di carrello in euro
	$(".ord_total_def_curr").empty();
	$(".ord_total_def_curr").append(addSeparatorsNF(total_order,'.',',','.'));

	// converto in base alla currency selezionata dall'utente
	total_order = (total_order * (Number(currTo)/Number(currFrom))).toFixed(2);
	
	$(".ord_total").empty();
	$(".ord_total").append(addSeparatorsNF(total_order,'.',',','.'));
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

function ajaxReloadPaymentList(totale_carrello, tot_and_spese, payment_method){
	var query_string = "totale_carrello="+totale_carrello+"&tot_and_spese="+tot_and_spese+"&payment_method="+payment_method;
	//alert("ajaxReloadPaymentList query_string: "+query_string);

	$.ajax({
		async: false,
		type: "GET",
		cache: false,
		url: "<%=currentBaseURL+"ajaxreloadpaymentlist.aspx"%>",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			$("#payment_list").empty();
			$("#payment_list").append(response);
		},
		error: function() {
			//alert("errorrrrrrrrrr!");
			$("#payment_list").empty();
			$("#payment_list").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
		}
	});
}

function ajaxSetSessionPayAndBills(field){
	//alert("field: "+field.name+"="+field.value);
	query_string=field.name+"="+field.value;
	if(field.type=="checkbox"){
		if(field.checked == true){
			query_string+="&operation=add";
		}else{
			query_string+="&operation=del";		
		}
	}else{
		query_string+="&operation=addone";
	}
	//alert("ajaxSetSessionPayAndBills query_string: "+query_string);
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "<%=currentBaseURL+"ajaxsetsessionpaybills.aspx"%>",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
		},
		error: function(response) {
			//alert("response error: "+response);
		}
	});
}

function selectPayAndBills4Form(applyBills){
	var query_string = "";
	
	$('[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			query_string+="&payment_method="+encodeURIComponent($(this).val());
			return;
		}
	});		

	// CONTROLLO SCELTA SPESE ACCESSORIE PRIMA DI INIVIARE FORM
	if(applyBills==1){
		var group_name = "";
		var arrKeys = listBills4Order.keys();

		//alert("arrKeys.length: "+arrKeys.length);	
		
		for(var k=0; k<arrKeys.length; k++){
			tmpKey = arrKeys[k];
			gn = tmpKey.substring(0, tmpKey.indexOf("-"));
			//alert("tmpKey: "+tmpKey+" - gn: "+gn);	
			
			if(group_name!=gn){group_name=gn;}else{continue;}

			var elem = eval("document.form_insert_carrello."+gn);
			if(elem){
				if(!elem.length || elem.length<=1){
					if(elem.checked == true){		
						query_string+="&"+elem.name+"="+encodeURIComponent(elem.value);
					}	      
				}else{
					var dobreak=false;
					for(var i=0; i<elem.length; i++){		
						if(elem[i].checked == true){
							query_string+="&"+elem[i].name+"="+encodeURIComponent(elem[i].value);
						}	
					}      
				}
			}
		}		
	}
	
	//alert("selectPayAndBills4Form query_string: "+query_string);

	return query_string;
}
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<div id="content-center-prodotto">
			<div align="left" id="contenuti">
				<%if(!String.IsNullOrEmpty(Request["error"]) && "1".Equals(Request["error"])) {%>
						<br><span class="cart-error"><%=Request["error_msg"]%></span><br><br>
				<%}
			
				int counter = 0;
				if(bolFoundLista) {%>
					<br/>			
					<%foreach(string key in prodsData.Keys){
						IList<object> pelements = null;
						bool foundpel = prodsData.TryGetValue(key, out pelements);
						decimal margin = 0.00M;
						decimal price = 0.00M;
						decimal discountperc = 0.00M;
						decimal discount = 0.00M;
						string suppdesc = "";
						Product product = null;
						ShoppingCartProduct scp = null;
						string urlRelProd = "#";
						string numPageTempl = "";
						string hierarchyRelProd = "";
						IList<ShoppingCartProductField> fscpf = null;
						string adsTitle = "";
						
						if(foundpel){
							margin = Convert.ToDecimal(pelements[1]);
							price = Convert.ToDecimal(pelements[3]);
							discountperc = Convert.ToDecimal(pelements[4]);
							suppdesc = Convert.ToString(pelements[5]);
							product = (Product)pelements[6];
							scp = (ShoppingCartProduct)pelements[7];
							urlRelProd = Convert.ToString(pelements[8]);
							numPageTempl = Convert.ToString(pelements[9]);
							hierarchyRelProd = Convert.ToString(pelements[10]);
							if(pelements[11] != null){
								fscpf = (IList<ShoppingCartProductField>)pelements[11];
							}
							adsTitle = Convert.ToString(pelements[13]);
							discount = Convert.ToDecimal(pelements[14]);
						}
						%>
						<form action="<%=shoppingcardURL%>" method="post" name="form_carrello_<%=counter%>" id="form_carrello_<%=counter%>" enctype="multipart/form-data" accept-charset="UTF-8">
						<input type="hidden" value="<%=shoppingCart.id%>" name="cartid">
						<input type="hidden" value="<%=scp.idProduct%>" name="productid">
						<input type="hidden" value="<%=scp.productType%>" name="prod_type">
						<input type="hidden" value="<%=scp.productCounter%>" name="counter_prod">
						<input type="hidden" value="<%=hierarchy%>" name="hierarchy">
						<input type="hidden" value="<%=categoryid%>" name="categoryid">
						<input type="hidden" value="additem" name="operation">
						<input type="hidden" value="<%=product.quantity%>" name="max_prod_qta">	
						<input type="hidden" value="1" name="reset_qta">	
						<input type="hidden" value="<%=voucher_code%>" name="voucher_code"> 
						<div>
							<div class="prodotto-immagine">
							<%if (product.attachments != null && product.attachments.Count>0) {	
								bool hasNotSmallImg = true;
								foreach(ProductAttachment attach in product.attachments){	
									foreach(ProductAttachmentLabel cal in attachmentsLabel){
										if(cal.id==attach.fileLabel){
											if(cal.description.Equals("img small")){%>	
												<img src="/public/upload/files/products/<%=attach.filePath+attach.fileName%>" alt="<%=attach.fileDida%>" width="50" height="50" />
												<%hasNotSmallImg = false;
												break;
											}
										}
									}	
								}		
								if(hasNotSmallImg) {%>
									<img width="50" height="50" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
								<%}
							}else{%>
								<img width="50" height="50" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
							<%}%>
							</div>						
							<div class="prodotto-carrello">
								<h2><a href="javascript:openRelatedProdPage('<%=urlRelProd%>', '<%=hierarchyRelProd%>', <%=product.id%>, <%=numPageTempl%>);"><%=productrep.getMainFieldTranslationCached(product.id, 1 , lang.currentLangCode, true,  product.name, true).value%></a></h2>
								
								<p>
								<%	
								// gestisco il riferimento all'ads se presente
								if(!String.IsNullOrEmpty(adsTitle)){
									Response.Write("<b>"+lang.getTranslated("frontend.carrello.table.label.ads_title")+"</b>&nbsp;"+adsTitle+"<br/>");
								}
								
								
								// gestisco i field per contenuto
								if(fscpf != null && fscpf.Count>0){
									foreach(ShoppingCartProductField scpf in fscpf){
										string flabel = lang.getTranslated("backend.prodotti.detail.table.label.field_description_"+scpf.description+"_"+product.keyword);
										if(String.IsNullOrEmpty(flabel)){
											flabel = scpf.description;
										}
										
										if(scpf.fieldType==8){
											Response.Write(flabel+":&nbsp;<a target='_blank' href='/public/upload/files/shoppingcarts/"+scpf.idCart+"/"+scpf.value+"'>"+scpf.value+"</a><br/>");
										}else{
											Response.Write(flabel+":&nbsp;"+scpf.value+"<br/>");
										}
										if(scpf.fieldType==3 || scpf.fieldType==4 || scpf.fieldType==5 || scpf.fieldType==6){%>
											<input type="hidden" name="product_field_<%=scpf.idField%>" value="<%=HttpUtility.HtmlEncode(scpf.value)%>">	
										<%}
									}
								}%>									
								
								<strong><%=lang.getTranslated("frontend.carrello.table.label.quantita")%>: </strong>
									<%//GESTISCO LA QUANTITA' SELEZIONABILE	
									if(product.status== 1 && product.quantity!=0 && product.setBuyQta){
										int checkqtafields = 1;
										if(product.quantity == -1){checkqtafields = 0;}%>
											<span style="display:none;" id="addtocardloadingimg<%=counter%>"><img src="/common/img/loading_icon.gif" border="0" width="16" height="16" hspace="0" vspace="0"></span>
											<span id="addtocardloading<%=counter%>"><input type="text" class="formFieldTXTSmall" name="quantity" value="<%=scp.productQuantity%>" onkeypress="javascript:return isInteger(event);" onblur="javascript:addToCarrello(<%=scp.productQuantity%>, document.form_carrello_<%=counter%>,<%=counter%>,<%if(applyBills){Response.Write("1");}else{Response.Write("0");}%>,<%=checkqtafields%>);"></span>
									<%}else{%>
										<%=scp.productQuantity%>
									<%}%>							  
								</p>							


								<p>
									<strong><%=lang.getTranslated("frontend.carrello.table.label.totale")%>: </strong><%=currency%>&nbsp;<%=price.ToString("#,###0.00")+"&nbsp;"+suppdesc%>
									<%
									bool hasPrules = false;
									BusinessRuleProductVO prule = null;
									if(productsVO.TryGetValue(scp.idProduct, out prule)){
										if(prule.productCounter==scp.productCounter && prule.rulesInfo != null && prule.rulesInfo.Count>0){
											hasPrules = true;
										}
									}
									
									if ((ug != null && margin > 0) ||  discountperc > 0 || hasPrules){%>&nbsp;<a href="javascript:showHideDiv('prod-commissions-<%=counter%>');">?</a><%}%>
									<div id="prod-commissions-<%=counter%>" style="<%if ((ug != null && margin > 0) || discountperc > 0 || hasPrules){%>margin-bottom:3px;padding:10px;vertical-align:middle;text-align:left;font-size: 10px;text-decoration: none;border:0px solid;background:#FFFFFF;top:0px;<%}%>visibility:hidden;display:none;position:relative;">
									<ul>
									<%if (ug != null && margin > 0) {%>
									<li><%=lang.getTranslated("frontend.carrello.table.label.commissioni")%>: <%=currency%>&nbsp;<%=margin.ToString("#,###0.00")%></li>
									<%}%>
									<%if (discountperc > 0) {
									decimal discountValue = 0-discount;
									if(defCurrency != null && userCurrency != null){
										discountValue = currrep.convertCurrency(discountValue, defCurrency.currency, userCurrency.currency);
									}%>
									<li><%=lang.getTranslated("frontend.carrello.table.label.sconto_applicato")%> <%=discountperc.ToString("#,###0.##")+"%"+":&nbsp;"+currency+"&nbsp;"+discountValue.ToString("#,###0.00")%></li>
									<%}%>
									<%if(hasPrules){%>
										<%foreach(int w in prule.rulesInfo.Keys){
											IList<object> infos = prule.rulesInfo[w];
											string tmpLabel = Convert.ToString(infos[1]);                  
											decimal tmpAmountRule = Convert.ToDecimal(infos[0]);
											bool hasAmount = false;
											if(tmpAmountRule!=0){
												hasAmount = true;
											}
											if(defCurrency != null && userCurrency != null){
												tmpAmountRule = currrep.convertCurrency(tmpAmountRule, defCurrency.currency, userCurrency.currency);
											}
											if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.business_rule.label."+tmpLabel))){
												tmpLabel = lang.getTranslated("portal.commons.business_rule.label."+tmpLabel);
											}
											%>
											<li><%=tmpLabel%>
											<%if(hasAmount){Response.Write(":&nbsp;"+currency+"&nbsp;"+tmpAmountRule.ToString("#,###0.00"));}%>
											</li>
										<%}%>
									<%}%>
									</ul>
									</div>                
								</p>				
							</div>
							<div class="prodotto-cancella"><a href="javascript:delFromCarrello('<%=shoppingcardURL%>',<%=shoppingCart.id%>,<%=scp.idProduct%>,<%=scp.productCounter%>,'<%=hierarchy%>',<%if(applyBills){Response.Write("1");}else{Response.Write("0");}%>);"><span><%=lang.getTranslated("frontend.carrello.table.label.del_prod")%></span></a></div>
							<div class="clear"></div>
							<div class="prodotto-footer"></div>
						</div>
						
						</form>
					<%counter++;
					}%>
					
					
					
					<div id="prodotto-conto">
						<div class="spese-div">         
						<%if (ug != null){%>
							<%if(totalMarginAmount>0){%><%=lang.getTranslated("frontend.carrello.table.label.totale_commissioni")%>:&nbsp;<strong><%=currency%>&nbsp;<%=totalMarginAmount.ToString("#,###0.00")%></strong><br/><%}%>
							<%if(totalDiscountAmount>0){%><%=lang.getTranslated("frontend.carrello.table.label.totale_sconti")%>:&nbsp;<strong><%=currency%>&nbsp;<%=totalDiscountAmount.ToString("#,###0.00")%></strong><br/><%}%>
							<br/>
						<%}%>
						
						<%
						//*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
						
						if(hasOrderRule) {
							foreach(int key in orderRulesData.Keys){
								IList<object> oelements = null;
								bool foundoel = orderRulesData.TryGetValue(key, out oelements);
								decimal oamount = 0.00M;
								string olabel = "";
								
								if(foundoel){
									oamount = Convert.ToDecimal(oelements[0]);
									olabel = Convert.ToString(oelements[1]);
									
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.business_rule.label."+olabel))){
										olabel = lang.getTranslated("portal.commons.business_rule.label."+olabel);
									}
								}%>
								<span class="rules"><%=olabel%></span>:&nbsp;<%=currency%>&nbsp;<%=oamount.ToString("#,###0.00")%><br/>
							<%}
						}%>  
						
						<%=lang.getTranslated("frontend.carrello.table.label.totale_prodotti")%>:&nbsp;<strong><%=currency%>&nbsp;<%=totalProductAmount.ToString("#,###0.00")%></strong>
						<br/>
						<%
						if(ug != null){
							if(logged && login.userLogged.discount != null && login.userLogged.discount >0){
								Response.Write("<br/>"+lang.getTranslated("frontend.carrello.table.label.sconto_cliente")+": "+login.userLogged.discount.ToString("#,###0.##")+"%");
							}
							
							if(logged && login.userLogged.discount != null && login.userLogged.discount >0 && "2".Equals(confservice.get("manage_sconti").value)){
								Response.Write("<br/>"+lang.getTranslated("frontend.carrello.table.label.if_client_has_sconto")+"<br/><br/>");
							}
						}%>              
						</div>
						
						<%if(activeVoucherCampaign){%>        
							<div class="spese-div">
								<form action="<%=shoppingcardURL%>" method="post" name="form_carrello_voucher">
									<input type="hidden" value="0" name="voucher_delete">
									<%if(!String.IsNullOrEmpty(voucher_message)){
										Response.Write("<span class=error>"+voucher_message+"</span><br/>");
									}%>
									<strong><%=lang.getTranslated("frontend.carrello.table.label.voucher_code")%></strong>&nbsp;<input type="text" id="voucher_code" name="voucher_code" value="<%=voucher_code%>">
									<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(0);" value="<%=lang.getTranslated("frontend.carrello.table.label.insert_voucher")%>">&nbsp;<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(1);" value="<%=lang.getTranslated("frontend.carrello.table.label.delete_voucher")%>">   
								</form>
							</div>
						<%}%>			
					
					
						
					
					
						<form action="<%=shoppingcardURL%>" method="post" name="form_insert_carrello" accept-charset="UTF-8">
							<input type="hidden" value="<%=shoppingCart.id%>" name="cartid">
							<input type="hidden" value="<%=voucher_code%>" name="voucher_code"> 
							<input type="hidden" value="process" name="operation">					
							

							<%
							//******** GESTIONE SPESE ACCESSORIE
							if(applyBills){%>
								<div class="spese-div" id="bills-container">
									<strong id="titlebills4card"><%=lang.getTranslated("frontend.carrello.table.label.spese_spedizione")%>:</strong><br/> 
									
									<%
									string oldGroupDesc = "";
									bool hasBills2charge = false;
									IDictionary<string,bool> bills2Charge = new Dictionary<string,bool>();
									
									foreach(int key in billsData.Keys){
										IList<object> belements = null;
										bool foundbel = billsData.TryGetValue(key, out belements);
										decimal billImp = 0.00M;
										decimal billSup = 0.00M;
										decimal billAmount = 0.00M;
										Fee f = null;
										string billGdesc = "";
										string billDesc = "";
										bool isChecked = false;
										int required = 0;
										
										if(foundbel){
											billImp = Convert.ToDecimal(belements[0]);
											billSup = Convert.ToDecimal(belements[1]);
											billAmount = Convert.ToDecimal(belements[2]);
											f = (Fee)belements[3];
											billGdesc = Convert.ToString(belements[4]);
											billDesc = Convert.ToString(belements[5]);
											isChecked = Convert.ToBoolean(belements[6]);
											
											if(f.required){required=1;}
										}
										
										if(!oldGroupDesc.Equals(f.feeGroup)){
											bills2Charge.Add(f.feeGroup,false);
											Response.Write("<strong id="+f.feeGroup+">"+billGdesc+"</strong><br/>");
										}
										
										if(f.autoactive){
											Response.Write("&nbsp;"+billDesc+"&nbsp;&nbsp;&nbsp;<strong>"+currency+"&nbsp;"+billAmount.ToString("#,###0.00")+"</strong><br/>");
											hasBills2charge = true;
										}else{
											if(f.multiply && ((billImp+billSup)>0 || f.typeView==1)){%>
												<input type="checkbox" onclick="javascript:ajaxSetSessionPayAndBills(this),calculateBills4Order('<%=totalCartAmount+totalAutomaticBillsAmount%>','<%=defCurrency.rate%>','<%=userCurrency.rate%>');" name="<%=f.feeGroup%>" id="<%=f.feeGroup+"-"+f.id+"-"+required%>" value="<%=f.id%>" <%if(isChecked){Response.Write(" checked='checked'");}%>/> 
												<%=billDesc+"&nbsp;&nbsp;&nbsp;"+currency+"&nbsp;"+billAmount.ToString("#,###0.00")+"&nbsp;&nbsp;<br/>"%>	
											<%}else if(!f.multiply && (billImp+billSup)>0){%>
												<input type="radio"  onclick="javascript:ajaxSetSessionPayAndBills(this),calculateBills4Order('<%=totalCartAmount+totalAutomaticBillsAmount%>','<%=defCurrency.rate%>','<%=userCurrency.rate%>');" name="<%=f.feeGroup%>" id="<%=f.feeGroup+"-"+f.id+"-"+required%>" value="<%=f.id%>" <%if(isChecked){Response.Write(" checked='checked'");}%>/> 
												<%=billDesc+"&nbsp;&nbsp;&nbsp;"+currency+"&nbsp;"+billAmount.ToString("#,###0.00")+"&nbsp;&nbsp;<br/>"%>				
											<%}%>										
										

							
											<script language="Javascript">
											<%if(isChecked){%>
												jQuery(document).ready(function(){
													calculateBills4Order('<%=totalCartAmount+totalAutomaticBillsAmount%>','<%=defCurrency.rate%>','<%=userCurrency.rate%>');
												});
											<%}
											
											if((billImp+billSup)>0 || f.typeView==1){%>
												listBills4Order.put("<%=f.feeGroup+"-"+f.id+"-"+required%>","<%=billImp+billSup%>");
												<%
												hasBills2charge = true;
												bills2Charge[f.feeGroup] = true;
											}%>
											</script> 											
										
										<%}
										oldGroupDesc=f.feeGroup;
									}%>
								</div>
								
								<script language="Javascript">
								jQuery(document).ready(function(){
									<%if(!hasBills2charge){%>
										//$("#titlebills4card").hide();
										$("#bills-container").hide();
									<%}
									
									foreach(string l in bills2Charge.Keys){
										if(!bills2Charge[l]){%>
											$("#<%=l%>").hide();
										<%}
									}%>
								});
								</script> 
							<%}%>
							
							
							<div class="spese-div">
								<strong><%=lang.getTranslated("frontend.carrello.table.label.tipo_pagam_order")%>:</strong><br>	
								<div id="payment_list">
									<ul>
									<%foreach(int key in paysData.Keys){
										IList<object> pelements = null;
										bool foundpel = paysData.TryGetValue(key, out pelements);
										Payment p = null;
										string logo = "";
										bool isChecked = false;	
										string pdesc = "";
										
										if(foundpel){
											p = (Payment)pelements[0];
											logo = (string)pelements[1];
											isChecked = Convert.ToBoolean(pelements[2]);	
											pdesc = p.description;
											if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+p.description))){
												pdesc = lang.getTranslated("backend.payment.description.label."+p.description);
											}
										}%>
										<li><input type="radio" name="payment_method" value="<%=key%>" <%if(isChecked){Response.Write(" checked='checked'");}%> onclick="javascript:ajaxSetSessionPayAndBills(this),calculatePaymentCommission('<%=totalCartAmount+totalAutomaticBillsAmount%>',<%=key%>,'<%=defCurrency.rate%>','<%=userCurrency.rate%>');">&nbsp;<%=pdesc%>&nbsp;<%=logo%></li>
										<script language="Javascript">
										listPaymentMethods.put("<%=key%>","<%=p.commission+"|"+p.commissionType%>");
										
										<%if(isChecked){%>
										jQuery(document).ready(function(){
											calculatePaymentCommission('<%=totalCartAmount+totalAutomaticBillsAmount%>',<%=key%>,'<%=defCurrency.rate%>','<%=userCurrency.rate%>');
										});											
										<%}%>
										</script>
									<%}%>
									</ul>
								</div>
							</div>
		

							<%
							// *****************************************************		
							// INIZIO: CODICE GESTIONE ACQUISTO SENZA REGISTRAZIONE
							// quando l'utente non e' loggato, quindi non registrato, presento l'opzione per acquistare senza 
							// registrazione; impostando il campo per l'email e i campi creati per la registrazione utente
							// e utilizzando id session per username e password
              
							if(logged){%>
								<input type="hidden" value="0" name="buy_noreg" id="buy_noreg">
							<%}else{%>
								<div class="spese-div">
									<strong><%=lang.getTranslated("frontend.carrello.table.label.buy_noreg")%></strong><br/>
									<select name="buy_noreg" id="buy_noreg">
									<OPTION VALUE="0" <%if("0".Equals(Request["buy_noreg"])){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.no")%></OPTION>
									<OPTION VALUE="1" <%if("1".Equals(Request["buy_noreg"])){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.yes")%></OPTION>
									</select>
									
									<div id="show_buy_noreg">
										<ul>
											<li><span><%=lang.getTranslated("frontend.area_user.manage.label.email")%> (*)</span></li>
											<li><input type="text" name="noreg_email" id="noreg_email" value="<%=noRegEmail%>"/></li><br/>
										</ul>									
								
										<%if(bolFoundFields && "1".Equals(confservice.get("show_user_field_on_direct_buy").value)){
											string style = "text-align:left;vertical-align:top;padding-right:10px;min-width:250px;height:30px;padding-bottom:20px;";
											Response.Write(UserService.renderField(usrfields, login.userLogged, null, style, "user-fields", lang.currentLangCode, lang.defaultLangCode, "2,3"));%>
											
											<script>
											$(document).ready(function() {
											<%foreach(UserField k in usrfields){
												if(k.type==5 || k.type==6){%>
													var fieldTmpVal = "<%=Request["user_field_"+k.id]%>";	
													var splittedVals = fieldTmpVal.split(",");
													
													$('[name*="user_field_<%=k.id%>"]').each( function(){
														for (var j=0; j < splittedVals.length; j++){
															if ($(this).val()==splittedVals[j]){
																$(this).attr('checked',true);
															}
														}	
													});	
												<%}else{
													if(!String.IsNullOrEmpty(Request["user_field_"+k.id])){%>
														$('[name="user_field_<%=k.id%>"]').val('<%=Request["user_field_"+k.id]%>');			
													<%}
												}%>
											<%}%>
											});											
											</script>
										<%}%>
									</div>
								</div>
								
								<script>
									<%if(!String.IsNullOrEmpty(Request["buy_noreg"]) && "1".Equals(Request["buy_noreg"])){%>
									$("#show_buy_noreg").show();
									<%}else{%>
									$("#show_buy_noreg").hide();
									<%}%>
				
									$('#buy_noreg').change(function() {
										var val_buy_noreg = $('#buy_noreg').val();
						
										if(val_buy_noreg==1){
											$("#show_buy_noreg").show();
				
											<%if("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value)){
												if (applyBills || "1".Equals(confservice.get("enable_international_tax_option").value)){%>
													$("#card_shipping_address").show();
												<%}%>		
											<%}%>
											<%if("1".Equals(confservice.get("show_bills_box").value)){%>
												$("#card_bills_address").show();			
											<%}%>                
										}else{
											$("#show_buy_noreg").hide();
				
											if ($("#card_shipping_address").length > 0){
												$("#card_shipping_address").hide();
											}
											if ($("#card_shipping_address").length > 0){
												$("#card_bills_address").hide();	
											}
										}
									});
								</script>
							<%}%>
							
							<%//*************************  GESTIONE CAMPI SPEDIZIONE  ****************************%>
							<div class="spese-div" id="card_shipping_address" style="display:none;">
								<div align="left" onClick="javascript:showHideDiv('divShipCost')"><strong>
									<%if("1".Equals(confservice.get("enable_international_tax_option").value) && !applyBills){%>
										<%=lang.getTranslated("frontend.carrello.table.label.shipping_address_international_tax")%>
									<%}else{%>
										<%=lang.getTranslated("frontend.carrello.table.label.shipping_address")%>
									<%}%>
									</strong>:<img src="/common/img/refresh.gif" vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=lang.getTranslated("frontend.carrello.table.label.change_ship_address")%>"  alt="<%=lang.getTranslated("frontend.carrello.table.label.change_ship_address")%>"><br/>
									<%if(hasShipAddress){
										string userLabelIsCompanyClient = "";
										if(shipaddr.isCompanyClient){
											userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company");
										}else{
											userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private");
										}								
										
										Response.Write(shipaddr.name + " " + shipaddr.surname + " ("+userLabelIsCompanyClient+") - " + shipaddr.cfiscvat + " - " +shipaddr.address +" - "+shipaddr.city+" ("+shipaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+shipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+shipaddr.stateRegion));
									}%>
								</div>	
								
								<div id="divShipCost" style="<%if(!hasShipAddress){Response.Write("visibility:visible;display:block;");}else{Response.Write("visibility:hidden;display:none;");}%>" align="left">
									<br/><div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.name")%></strong><br>
									<input type="text" id="ship_name" name="ship_name" value="<%=shipaddr.name%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.surname")%></strong><br>
									<input type="text" id="ship_surname" name="ship_surname" value="<%=shipaddr.surname%>"></div>
									<div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.address")%></strong><br>
									<input type="text" id="ship_address" name="ship_address" value="<%=shipaddr.address%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.zip_code")%></strong><br>
									<input type="text" id="ship_zip_code" name="ship_zip_code" value="<%=shipaddr.zipCode%>"></div>
									<div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.city")%></strong><br>
									<input type="text" id="ship_city" name="ship_city" value="<%=shipaddr.city%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.cfiscvat")%></strong><br>
									<input type="text" id="ship_cfiscvat" name="ship_cfiscvat" value="<%=shipaddr.cfiscvat%>"></div>
									
									<div style="float:left;padding-right:3px;">
										<strong><%=lang.getTranslated("frontend.carrello.table.label.country")%></strong><br>
										<select id="ship_country" name="ship_country">
										<option value=""></option>
										<%foreach(Country x in countries){%>
										  <option value="<%=x.countryCode%>" <%if(x.countryCode.Equals(shipaddr.country)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.countryCode)%></option>     
										<%}%>
										</select> 
									</div>
									<div style="padding-bottom:10px;"><strong><%=lang.getTranslated("frontend.carrello.table.label.state_region")%></strong><br>	 
										<select name="ship_state_region" id="ship_state_region">
										<option value=""></option>
										<%if(!String.IsNullOrEmpty(shipaddr.country)){
											foreach(Country x in stateRegions){%>
											  <option value="<%=x.stateRegionCode%>" <%if(x.stateRegionCode.Equals(shipaddr.stateRegion)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.stateRegionCode)%></option>     
											<%}
										}%>
										</select>	
									</div>
									
									<div><strong><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company_client")%></strong><br>
									<select name="ship_is_company_client" id="ship_is_company_client">
									<option value="0" <%if(!shipaddr.isCompanyClient){Response.Write("selected");}%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_private")%></option>
									<option value="1" <%if(shipaddr.isCompanyClient){Response.Write("selected");}%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company")%></option>
									</select></div>	
									
									<script>
									<%if("1".Equals(confservice.get("enable_international_tax_option").value)){%>
										$('#ship_country').change(function() {
											$('#prodotto-totale').hide();	
											document.form_insert_carrello.operation.value="";
											document.form_insert_carrello.submit();
										});
										
										$('#ship_state_region').change(function() {
											$('#prodotto-totale').hide();
											document.form_insert_carrello.operation.value="";
											document.form_insert_carrello.submit();
										});
																
										$('#ship_is_company_client').change(function() {
											$('#prodotto-totale').hide();			
											document.form_insert_carrello.operation.value="";
											document.form_insert_carrello.submit();
										});		
									<%}else{%>
										$('#ship_country').change(function() {
											var type_val_ch = $('#ship_country').val();
											var query_string = "field_val="+encodeURIComponent(type_val_ch);
						
											$.ajax({
												async: true,
												type: "GET",
												cache: false,
												url: "<%=currentBaseURL+"ajaxstateregionupdate.aspx"%>",
												data: query_string,
												success: function(response) {
													//alert("response: "+response);
													$("select#ship_state_region").empty();
													$("select#ship_state_region").append($("<option></option>").attr("value","").text(""));
													$("select#ship_state_region").append(response);
												},
												error: function() {
													$("select#ship_state_region").empty();
													$("select#ship_state_region").append($("<option></option>").attr("value","").text(""));
												}
											});		
										});										
									<%}%>
									</script>
								</div>	
							</div>
	
							<script>
								<%
								bool showShipBox =	("1".Equals(Request["buy_noreg"]) && ("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value))) ||
													(applyBills && (logged || "1".Equals(Request["buy_noreg"]))) ||
													(logged && ("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value)));
								
								if(showShipBox){%>
									$("#card_shipping_address").show();
								<%}%>
							</script>
							
							<%//*************************  GESTIONE CAMPI FATTURAZIONE  ****************************%>
							<div class="spese-div" id="card_bills_address" style="display:none;">
								<div align="left" onClick="javascript:showHideDiv('divBillsCost')"><strong>
									<%=lang.getTranslated("frontend.carrello.table.label.bills_address")%>
									</strong>:<img src="/common/img/refresh.gif" vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=lang.getTranslated("frontend.carrello.table.label.change_bills_address")%>"  alt="<%=lang.getTranslated("frontend.carrello.table.label.change_bills_address")%>"><br/>
									<%if(hasBillsAddress){
										Response.Write(billsaddr.name + " " + billsaddr.surname + " - " + billsaddr.cfiscvat + " - " +billsaddr.address +" - "+billsaddr.city+" ("+billsaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+billsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+billsaddr.stateRegion));
									}%>
								</div>	
								
								<div id="divBillsCost" style="<%if(!hasBillsAddress){Response.Write("visibility:visible;display:block;");}else{Response.Write("visibility:hidden;display:none;");}%>" align="left">
									<br/><div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.name")%></strong><br>
									<input type="text" id="bills_name" name="bills_name" value="<%=billsaddr.name%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.surname")%></strong><br>
									<input type="text" id="bills_surname" name="bills_surname" value="<%=billsaddr.surname%>"></div>
									<div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.address")%></strong><br>
									<input type="text" id="bills_address" name="bills_address" value="<%=billsaddr.address%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.zip_code")%></strong><br>
									<input type="text" id="bills_zip_code" name="bills_zip_code" value="<%=billsaddr.zipCode%>"></div>
									<div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.city")%></strong><br>
									<input type="text" id="bills_city" name="bills_city" value="<%=billsaddr.city%>"></div>
									<div><strong><%=lang.getTranslated("frontend.carrello.table.label.cfiscvat")%></strong><br>
									<input type="text" id="bills_cfiscvat" name="bills_cfiscvat" value="<%=billsaddr.cfiscvat%>"></div>
									
									<div style="float:left;padding-right:3px;">
										<strong><%=lang.getTranslated("frontend.carrello.table.label.country")%></strong><br>
										<select id="bills_country" name="bills_country">
										<option value=""></option>
										<%foreach(Country x in countries){%>
										  <option value="<%=x.countryCode%>" <%if(x.countryCode.Equals(billsaddr.country)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.countryCode)%></option>     
										<%}%>
										</select> 
									</div>
									<div style="padding-bottom:10px;"><strong><%=lang.getTranslated("frontend.carrello.table.label.state_region")%></strong><br>	 
										<select name="bills_state_region" id="bills_state_region">
										<option value=""></option>
										<%if(!String.IsNullOrEmpty(billsaddr.country)){
											foreach(Country x in stateRegions){%>
											  <option value="<%=x.stateRegionCode%>" <%if(x.stateRegionCode.Equals(billsaddr.stateRegion)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.stateRegionCode)%></option>     
											<%}
										}%>
										</select>	
									</div>
									
									<script>
									$('#bills_country').change(function() {
										var type_val_ch = $('#bills_country').val();
										var query_string = "field_val="+encodeURIComponent(type_val_ch);
					
										$.ajax({
											async: true,
											type: "GET",
											cache: false,
											url: "<%=currentBaseURL+"ajaxstateregionupdate.aspx"%>",
											data: query_string,
											success: function(response) {
												//alert("response: "+response);
												$("select#bills_state_region").empty();
												$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
												$("select#bills_state_region").append(response);
											},
											error: function() {
												$("select#bills_state_region").empty();
												$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
											}
										});		
									});	
									</script>
								</div>	
							</div>
	
							<script>
								<%
								bool showBillsBox =	("1".Equals(confservice.get("show_bills_box").value) && (logged || "1".Equals(Request["buy_noreg"])));
								
								if(showBillsBox){%>
									$("#card_bills_address").show();
								<%}%>
							</script>							
							
							<div id="spese-totale">
								<%=lang.getTranslated("frontend.carrello.table.label.payment_commission")%>: <strong><%=currency%>&nbsp;<span class="payment_commission"><%=totalPaymentAmount.ToString("#,###0.00")%></span></strong><br/><br/> 
								<%=lang.getTranslated("frontend.carrello.table.label.totale_ordine")%>: <strong><%=currency%>&nbsp;<span class="ord_total"><%=currrep.convertCurrency(totalCartAmount+totalBillsAmount, defCurrency.currency, userCurrency.currency).ToString("#,###0.00")%></span></strong>
								<br/><span id="currency"><%=lang.getTranslated("frontend.carrello.table.label.totale_ordine.currency_transaction1")%>&nbsp;<%=lang.getTranslated("backend.currency.keyword.label."+defCurrency.currency)%>&nbsp;<%=lang.getTranslated("frontend.carrello.table.label.totale_ordine.currency_transaction2")%>:&nbsp;<%=lang.getTranslated("backend.currency.symbol.label."+defCurrency.currency)%>&nbsp;<span class="ord_total_def_curr"><%=(totalCartAmount+totalBillsAmount).ToString("#,###0.00")%></span></span>
							</div>
							
							<div class="spese-div">
								<a name="condition_purchase"></a>
								<input type="checkbox" id="terms_condition_purchase" name="terms_condition_purchase" />&nbsp;<%=lang.getTranslated("frontend.carrello.table.label.accept_term_conditions")%> (<a href="#condition_purchase" id="activate_condition_view"><%=lang.getTranslated("frontend.carrello.table.label.term_conditions_read")%></a>)
								<div id="term_conditions" align="center"><%=lang.getTranslated("frontend.carrello.table.label.text_term_conditions")%></div>
							</div>     
							<script>
							$("#term_conditions").hide();
							$('#activate_condition_view').click(function() {
								if( $('#term_conditions').is(':visible') ) {
									$("#term_conditions").hide();            
								}else{
									$("#term_conditions").show();
								}
							});
							</script>
							
							<div id="prodotto-totale">
								<span style="display:none;padding-left:32px;padding-right:32px;" id="sendtocardloadingimg"><img src="/common/img/loading_icon.gif" border="0" width="20" height="20" align="absmiddle"></span>
								<span id="sendtocardloading"><a href="javascript:sendCarrello(<%if(applyBills){Response.Write("1");}else{Response.Write("0");}%>);"><%=lang.getTranslated("frontend.carrello.table.label.confirm_order")%></a></span>&nbsp;&nbsp;-&nbsp;&nbsp;
								<a href="javascript:continueShopping('<%=backURL%>', '<%=hierarchy%>');"><%=lang.getTranslated("frontend.carrello.table.label.continue_shop")%></a>&nbsp;&nbsp;-&nbsp;&nbsp;
								<a href="<%=shoppingcardURL+"?cart_to_delete="+shoppingCart.id+"&operation=delcart"%>"><%=lang.getTranslated("frontend.carrello.table.label.cancel_card")%></a>
							</div>				
						
						</form>	
					</div>	
				<%}else{%>
					<br/><br/><div align="center"><strong><lang:getTranslated keyword="frontend.carrello.table.label.empty_card" runat="server" /></strong></div>
				<%}%>
			</div>
			
			<form action="" method="post" name="form_cart_rel_prod">	
			<input type="hidden" value="" name="productid">	
			<input type="hidden" value="" name="modelPageNum">	
			<input type="hidden" value="" name="hierarchy">            
			</form>	
			
			<form action="" method="post" name="form_cart_continue_shop">	
			<input type="hidden" value="" name="hierarchy">            
			</form> 	
			
			<form action="" method="post" name="form_cart_del_item">	
			<input type="hidden" value="" name="hierarchy"> 
			<input type="hidden" value="<%=voucher_code%>" name="voucher_code">
			<input type="hidden" value="delitem" name="operation">  
			<input type="hidden" value="" name="cartid">
			<input type="hidden" value="" name="productid">
			<input type="hidden" value="" name="counter_prod">        
			</form> 			
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
