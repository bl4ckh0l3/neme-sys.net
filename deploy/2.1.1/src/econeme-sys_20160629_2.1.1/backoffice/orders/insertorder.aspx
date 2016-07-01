<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertorder.aspx.cs" Inherits="_InsertOrder" Debug="true" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script src="/common/js/hashtable.min.js"></script>
<script>
var listPaymentMethods;
listPaymentMethods = new Hashtable();

var listBills4Order;
listBills4Order = new Hashtable(); 

<%
if(products != null && products.Count>0) {
	foreach(Product p in products){%>
		function checkFieldsValidations<%=p.id%>(){
			<%if(p.fields != null && p.fields.Count>0){%>
				<%=ProductService.renderFieldJsFormValidation(p.fields, lang.currentLangCode, lang.defaultLangCode)%>
				return true;
			<%}else{%>
				return true;
			<%}%>
		}
	<%}
}%>

function chooseOrderUser(idOrder, userId){
	if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.confirm_choose_new_order_user")%>")){
		location.href='/backoffice/orders/insertorder.aspx?cssClass=LO&id='+idOrder+'&userid='+userId;
	}
}


function delFromOrder(strAction, cartid, numIdProd, counterProd, hierarchy, applyBills){
	if(confirm("<%=lang.getTranslated("frontend.carrello.js.alert.confirm_del_prod")%>")){
		strAction+="?"+selectPayAndBills4Form(applyBills);
		document.form_cart_del_item.action=strAction;
		document.form_cart_del_item.cartid.value=cartid;
		document.form_cart_del_item.productid.value=numIdProd;
		document.form_cart_del_item.counter_prod.value=counterProd;
		
		$('#form_insert_carrello input[name*="payment_method"]').each( function(){
			if($(this).is(':checked')){
				$("#del_item_payment_method").val($(this).val());
				return;
			}
		});			
	
		$('#bills-container input').each( function(){
			if($(this).is(':checked')){
				$("#form_cart_del_item").append('<input type="hidden" value="'+$(this).val()+'" name="'+$(this).attr("name")+'"/>');
			}
		});
		
		document.form_cart_del_item.submit();		
	}
}

var isSentCard = false;
function sendForm(applyBills){
	var id_carrello = document.form_insert_carrello.cartid.value;
	if(id_carrello == ""){
		alert("<%=lang.getTranslated("frontend.carrello.js.alert.no_carrello_found")%>");
		return;
	}
	
	// CONTROLLO SCELTA TIPO PAGAMENTO PRIMA DI INIVIARE FORM
	var paymentSelected = false;
	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
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
	<%}	

	if("1".Equals(confservice.get("show_bills_box").value)	) {%>
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
	<%}%>
      
	if(!isSentCard && confirm("******  <%=lang.getTranslated("frontend.carrello.js.alert.confirm_ordina_prod")%>  ******")){
		isSentCard = true;
		//$("#sendtocardloading").hide();
		//$("#sendtocardloadingimg").show();
		document.form_insert_carrello.submit();
	}
}

var formSent = false;
function addItemToOrder(idProduct, counter, theFrom){
	var quantity = $("#quantity_"+counter).val();

	if(quantity.length == 0 || quantity==0){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.select_qta_prod")%>");
		return;
	}else if(isNaN(quantity)){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.isnan_value")%>");
		$("#quantity_"+counter).val('');
		return;
	}else if(quantity.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.isnan_value")%>");
		$("#quantity_"+counter).val('');
		return;
	}	

	jQuery.globalEval("var checkf = checkFieldsValidations"+idProduct+"()");
	if(!checkf){return};	

	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			$("#item_payment_method_"+counter).val($(this).val());
			return;
		}
	});			

	$('#bills-container input').each( function(){
		if($(this).is(':checked')){
			$("#form_add_to_order_"+counter).append('<input type="hidden" value="'+$(this).val()+'" name="'+$(this).attr("name")+'"/>');
		}
	});	

	if(formSent == false){
		formSent = true;
		//$("#addtocardloading"+counter).hide();
		//$("#addtocardloadingimg"+counter).show();
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function checkMaxQtaProd(maxQtaProd, field){
	if(maxQtaProd > -1 && Number(field.value) > maxQtaProd){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.exceed_qta_prod")%>");
		field.value="";
	}
}

function selectPayAndBills4Form(applyBills){
	var query_string = "";
	
	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
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

function filterItems(){
	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			$("#search_payment_method").val($(this).val());
			return;
		}
	});		

	$('#bills-container input').each( function(){
		if($(this).is(':checked')){
			$("#form_search").append('<input type="hidden" value="'+$(this).val()+'" name="'+$(this).attr("name")+'"/>');
		}
	});		
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

	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			$("#voucher_payment_method").val($(this).val());
			return;
		}
	});		

	$('#bills-container input').each( function(){
		if($(this).is(':checked')){
			$("#form_carrello_voucher").append('<input type="hidden" value="'+$(this).val()+'" name="'+$(this).attr("name")+'"/>');
		}
	});		
	
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
	total_order = Number(total_amount);	
	/****** fine ricalcolo spese accessorie *******/

	payment = listPaymentMethods.get(payment_method);
	commission = payment.substring(0, payment.indexOf("|"));
	type = payment.substring(payment.indexOf("|")+1, payment.length);
	commission_amount = 0;
	commission = Number(commission.replace(',','.'));
	currFrom = Number(currFrom.replace(',','.'));
	currTo = Number(currTo.replace(',','.'));

	if(type == 1){
		commission_amount = (total_order * (commission / 100));
		total_order = (Number(total_order)+Number(commission_amount));
	}else{
		commission_amount = Number(commission);
		total_order = (Number(total_order)+Number(commission_amount));
	}
  
	// converto in base alla currency selezionata dall'utente
	commission_amount = (commission_amount * (Number(currTo)/Number(currFrom)));
	total_order = (total_order * (Number(currTo)/Number(currFrom)));

	var converted_total_order = round(total_order,4);
	if(converted_total_order<0){
		converted_total_order=0;
	}
	$(".payment_commission").empty();
	$(".ord_total").empty();
	$(".payment_commission").append(addSeparatorsNF(round(commission_amount,4).toFixed(2),'.',',','.'));
	$(".ord_total").append(addSeparatorsNF(converted_total_order.toFixed(2),'.',',','.'));
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

	total_order = Number(total_amount);

	<%if(orderid<0 || !paymentDone){%>
	/****** ricarico la lista dei metodi di pagamento disponibili *******/
	var payment_method_tmp="";
	
	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
		if($(this).is(':checked')){
			payment_method_tmp = $(this).val();
			return;
		}
	});
	ajaxReloadPaymentList(total_amount_4_payment.replace('.',','), String(total_amount).replace('.',','), payment_method_tmp);
	
	/****** ricalcolo le commissioni pagamento *******/

	paymentSelected = false;
	
	$('#form_insert_carrello input[name*="payment_method"]').each( function(){
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
			commission_amount = (total_order * (commission / 100));
			total_order = (Number(total_order)+Number(commission_amount));
		}else{
			commission_amount = Number(commission);
			total_order = (Number(total_order)+Number(commission_amount));
		}	
	
		// converto in base alla currency selezionata dall'utente
		commission_amount = (commission_amount * (Number(currTo)/Number(currFrom)));
		
		$(".payment_commission").empty();
		$(".payment_commission").append(addSeparatorsNF(round(commission_amount,4).toFixed(2),'.',',','.'));
	}
	
	/****** fine ricalcolo commissioni pagamento *******/
	<%}else if(orderid>0 && paymentDone){%>
		total_order = (Number(total_order)+Number(<%=totalPaymentAmount%>));
	<%}%>

	// converto in base alla currency selezionata dall'utente
	total_order = (total_order * (Number(currTo)/Number(currFrom)));
	
	var converted_total_order = round(total_order,4);
	if(converted_total_order<0){
		converted_total_order=0;
	}	
	$(".ord_total").empty();
	$(".ord_total").append(addSeparatorsNF(converted_total_order.toFixed(2),'.',',','.'));
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
		url: "/backoffice/orders/ajaxreloadpaymentlist.aspx",
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
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<%if(!String.IsNullOrEmpty(Request["error"]) && "1".Equals(Request["error"])) {%>
					<br><span class="cart-error"><%=Request["error_msg"]%></span><br><br>
			<%}%>
				
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr>
					<th align="center" width="25">&nbsp;</th>
					<th width="200"><lang:getTranslated keyword="backend.utenti.lista.table.header.username" runat="server" /></th>
					<th width="200"><lang:getTranslated keyword="backend.utenti.lista.table.header.mail" runat="server" /></th>
					<th>&nbsp;</th>
				</tr>
			</table>
			<%if(user!= null){%>
				<table border="0" cellpadding="0" cellspacing="0" class="principal">	
				<tr class="table-list-on">
					<td align="center" width="25">&nbsp;</td>
					<td width="200"><%=user.username%></td>
					<td width="200"><%=user.email%></td>
					<td>&nbsp;</td>
				</tr>	
				</table>			
			<%}else{%>
				<div class="order-user-select">
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<%int selUserCounter = 0;
				foreach(User u in users){%>
					<tr class="<%if(selUserCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
						<td align="center" width="25"><input type="radio" onclick="javascript:chooseOrderUser(<%=orderid%>,<%=u.id%>);" value="<%=u.id%>" name="order_user"></td>
						<td width="200"><%=u.username%></td>
						<td width="200"><%=u.email%></td>
						<td>&nbsp;</td>
					</tr>
					<%selUserCounter++;
				}%>
				</table>
				</div>
			<%}%>
			
			
			<%if(orderid==-1 && user != null){%>
				<div style="padding-top:30px;padding-bottom:20px;float:top;min-height:40px;border: 1px solid rgb(201, 201, 201);">		
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" id="form_search" accept-charset="UTF-8" onsubmit="javascript:filterItems();">
						<input type="hidden" value="<%=orderid%>" name="id">
						<input type="hidden" value="<%=cartid%>" name="cartid">
						<input type="hidden" value="<%=orderUserId%>" name="userid">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">
						<input type="hidden" value="" name="payment_method" id="search_payment_method">
						<div style="float:left;padding-right:10px;padding-top:15px;">
						<input type="submit" value="<%=lang.getTranslated("backend.product.lista.label.search")%>" class="buttonForm" hspace="4">
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.title_filter")%></span><br>
						<input type="text" name="titlef" value="<%=titlef%>" class="formFieldTXT">	
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.keyword_filter")%></span><br>
						<input type="text" name="keywordf" value="<%=keywordf%>" class="formFieldTXT">	
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.type_filter")%></span><br>
						<select name="typef" class="formfieldSelect">
						<option value=""></option>
						<option value="0" <%if ("0".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_portable")%></option>
						<option value="1" <%if ("1".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_download")%></option>
						</SELECT>
						</div>
						<div style="float:top;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.category_filter")%></span><br>
						<select name="categoryf" class="formfieldSelect">
						<option value=""></option>
						<%
						string catdesc;
						foreach (Category c in categories){
							if(CategoryService.checkUserCategory(login.userLogged, c)){
								catdesc = "-&nbsp;"+c.description;
								string[] level = c.hierarchy.Split('.');
								if(level != null){
									for(int l=1;l<level.Length;l++){
										catdesc = "&nbsp;&nbsp;&nbsp;"+catdesc;
									}
								}%>
								<OPTION VALUE="<%=c.id%>" <%if (c.id==categoryf) { Response.Write("selected");}%>><%=catdesc%></OPTION>
							<%}
						}%>
						</SELECT>
						</div>	
				</form>
				</div>
			
				<%if(products != null && products.Count>0){%>
					<table border="0" cellpadding="0" cellspacing="0" class="principal">
						<tr>
							<th align="center" width="25">&nbsp;</th>
							<th width="250"><%=lang.getTranslated("backend.ordini.detail.table.label.nome_prod")%></th>
							<th width="200"><%=lang.getTranslated("backend.ordini.detail.table.label.prezzo_prod")%></th>
							<th width="150"><%=lang.getTranslated("backend.ordini.detail.table.label.qta_prod")%></th>
							<th><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>
						</tr>
					</table>
					<div class="order-product-select">
					<table border="0" cellpadding="0" cellspacing="0" class="principal">
					<%int selProdCounter = 0;
					foreach(Product p in products){%>
						<tr class="<%if(selProdCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_add_to_order_<%=selProdCounter%>" id="form_add_to_order_<%=selProdCounter%>" enctype="multipart/form-data">
							<input type="hidden" value="<%=p.id%>" name="productid">
							<input type="hidden" value="<%=p.prodType%>" name="prod_type">
							<input type="hidden" value="additem" name="operation">
							<input type="hidden" value="<%=selProdCounter%>" name="form_counter">
							<input type="hidden" value="<%=p.quantity%>" name="max_prod_qta">	
							<input type="hidden" value="1" name="reset_qta">		
							<input type="hidden" value="<%=orderid%>" name="id">
							<input type="hidden" value="<%=cartid%>" name="cartid">
							<input type="hidden" value="<%=orderUserId%>" name="userid">
							<input type="hidden" value="<%=cssClass%>" name="cssClass">	
							<input type="hidden" value="<%=titlef%>" name="titlef">		
							<input type="hidden" value="<%=keywordf%>" name="keywordf">		
							<input type="hidden" value="<%=typef%>" name="typef">		
							<input type="hidden" value="<%=categoryf%>" name="categoryf">
							<input type="hidden" value="<%=voucher_code%>" name="voucher_code"> 
							<input type="hidden" value="" name="payment_method" id="item_payment_method_<%=selProdCounter%>">
							<td align="center" width="25"><a href="javascript:addItemToOrder(<%=p.id%>,<%=selProdCounter%>,document.form_add_to_order_<%=selProdCounter%>);"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" alt="<%=lang.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" hspace="2" vspace="0" border="0" align="top"></a></td>
							<td width="250"><%=p.name%></td>
							<td width="200">&euro;&nbsp;<%=p.price.ToString("#,###0.00")%></td>
							<td width="150">
							<input type="text" name="quantity" id="quantity_<%=selProdCounter%>" value="" class="formFieldTXTQtaProd" onKeyPress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%=p.quantity%>,this);">
							<%
							if(p.quantity>-1){%>
								<br/><%=lang.getTranslated("backend.ordini.detail.table.label.product_disp")+"&nbsp;"+p.quantity%>
							<%}%></td>
							<td>
							<%// gestisco i field per contenuto
							if(p.fields != null && p.fields.Count>0){
								Response.Write(ProductService.renderField(p.fields, null, "", "", lang.currentLangCode, lang.defaultLangCode, p.keyword));
							}%>
							</td>
							</form>
						</tr>
						<%selProdCounter++;
					}%>
					</table>
					</div>					
				<%}
			}
			
			if(bolFoundLista || order!=null){%>	
				<br/>
				<br><span class="labelForm"><%=lang.getTranslated("backend.ordini.detail.table.label.prod_list")%></span><br>
				<table class="inner-table" border="0" cellpadding="0" cellspacing="0">
				  <tr> 
				  	<th align="center" width="25">&nbsp;</th>
					<th width="250"><%=lang.getTranslated("backend.ordini.detail.table.label.nome_prod")%></th>
					<th width="250"><%=lang.getTranslated("backend.ordini.detail.table.label.prezzo_prod")%></th>
					<th width="150"><%=lang.getTranslated("backend.ordini.detail.table.label.tax_prod")%></th>
					<th width="100"><%=lang.getTranslated("backend.ordini.detail.table.label.qta_prod")%></th>
					<th><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>
				  </tr>	
				<%int orderProdCounter = 0;
				if(bolFoundLista){
					foreach(string key in prodsData.Keys){
						IList<object> pelements = null;
						bool foundpel = prodsData.TryGetValue(key, out pelements);
						decimal margin = 0.00M;
						decimal price = 0.00M;
						decimal supplement = 0.00M;
						decimal discountperc = 0.00M;
						decimal discount = 0.00M;
						string suppdesc = "";
						Product product = null;
						ShoppingCartProduct scp = null;
						string urlRelProd = "#";
						string numPageTempl = "";
						string hierarchyRelProd = "";
						IList<ShoppingCartProductField> fscpf = null;
						
						if(foundpel){
							price = Convert.ToDecimal(pelements[0]);
							margin = Convert.ToDecimal(pelements[1]);
							supplement = Convert.ToDecimal(pelements[2]);
							discountperc = Convert.ToDecimal(pelements[4]);
							suppdesc = Convert.ToString(pelements[5]);
							product = (Product)pelements[6];
							scp = (ShoppingCartProduct)pelements[7];
							numPageTempl = Convert.ToString(pelements[9]);
							hierarchyRelProd = Convert.ToString(pelements[10]);
							if(pelements[11] != null){
								fscpf = (IList<ShoppingCartProductField>)pelements[11];
							}
							discount = Convert.ToDecimal(pelements[14]);
						}%>
						<tr class="<%if(orderProdCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><%if(orderid==-1){%><a href="javascript:delFromOrder('<%=Request.Url.AbsolutePath%>',<%=shoppingCart.id%>,<%=scp.idProduct%>,<%=scp.productCounter%>,'',<%if(applyBills){Response.Write("1");}else{Response.Write("0");}%>);"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" alt="<%=lang.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" hspace="2" vspace="0" border="0" align="top"></a><%}else{Response.Write("&nbsp;");}%></td>
							<td width="250"><%=productrep.getMainFieldTranslationCached(product.id, 1 , lang.currentLangCode, true,  product.name, true).value%></td>
							<td width="250">&euro;&nbsp;<%=price.ToString("#,###0.00")%>
							<%
							bool hasPrules = false;
							BusinessRuleProductVO prule = null;
							if(productsVO.TryGetValue(scp.idProduct, out prule)){
								if(prule.productCounter==scp.productCounter && prule.rulesInfo != null && prule.rulesInfo.Count>0){
									hasPrules = true;
								}
							}
							
							if ((ug != null && margin > 0) ||  discountperc > 0 || hasPrules){%>
								<ul style="padding-left:10px;padding-top:5px;margin:0px;">
								<%if (ug != null && margin > 0) {%>
								<li><%=lang.getTranslated("frontend.carrello.table.label.commissioni")%>: &euro;&nbsp;<%=margin.ToString("#,###0.00")%></li>
								<%}%>
								<%if (discountperc > 0) {
								decimal discountValue = 0-discount;%>
								<li><%=lang.getTranslated("frontend.carrello.table.label.sconto_applicato")%> <%=discountperc.ToString("#,###0.##")+"%"+":&nbsp;&euro;&nbsp;"+discountValue.ToString("#,###0.00")%></li>
								<%}%>
								<%if(hasPrules){%>
									<%foreach(int w in prule.rulesInfo.Keys){
										IList<object> infos = prule.rulesInfo[w];
										string tmpLabel = Convert.ToString(infos[1]);                  
										decimal tmpAmountRule = Convert.ToDecimal(infos[0]);
										bool hasAmount = false;
										if(tmpAmountRule!=0){
											hasAmount = true;
											if(tmpAmountRule>0){
												totalMarginAmount+=tmpAmountRule;										
											}else if(tmpAmountRule<0){
												totalDiscountAmount+=Math.Abs(tmpAmountRule);	
											}
										}
										if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+tmpLabel))){
											tmpLabel = lang.getTranslated("backend.businessrule.label.label."+tmpLabel);
										}
										%>
										<li><%=tmpLabel%>
										<%if(hasAmount){Response.Write(":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00"));}%>
										</li>
									<%}%>
								<%}%>
								</ul>
							<%}%>
							</div> 						
							</td>
							<td width="150">&euro;&nbsp;<%=supplement.ToString("#,###0.00")+"&nbsp;"+suppdesc%></td>
							<td width="100"><%=scp.productQuantity%></td>
							<td>
							<%// gestisco i field per prodotto
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
								}
							}%>	
							</td>
						</tr>
						<%orderProdCounter++;
					}
				}else if(order.products != null && order.products.Count>0){
					foreach(OrderProduct op in order.products.Values){
						Product prod = productrep.getByIdCached(op.idProduct, false);
						IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
					
						string adsRefTitle = "";
						if(op.idAds != null && op.idAds>-1){
							Ads a = adsrep.getById(op.idAds);
							if(a != null){
								FContent f = contrep.getByIdCached(a.elementId, false);
								if(f != null){
									adsRefTitle = "<br/><b>"+lang.getTranslated("frontend.carrello.table.label.ads_title")+"</b>&nbsp;"+f.title;
								}
							}
						}
						
						//****** MANAGE SUPPLEMENT DESCRIPTION
						string suppdesc = op.supplementDesc;
						string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
						if(!String.IsNullOrEmpty(suppdesctrans)){
							suppdesc = suppdesctrans;
						}
						suppdesc = "&nbsp;("+suppdesc+")";	
	
						string opmargin = "";
						if(op.margin > 0){
							opmargin = "<li>"+lang.getTranslated("frontend.carrello.table.label.commissioni")+":&nbsp;&euro;&nbsp;"+op.margin.ToString("#,###0.00")+"</li>";
						}
						
						string opdiscPerc = "";
						if (op.discountPerc > 0) {
							decimal discountValue = 0-op.discount;
							opdiscPerc ="<li>"+lang.getTranslated("frontend.carrello.table.label.sconto_applicato")+"&nbsp;"+op.discountPerc.ToString("#,###0.##")+"%:&nbsp;&euro;&nbsp;"+discountValue.ToString("#,###0.00")+"</li>";
						}					
						
						//****** MANAGE ORDER RULES FOR PRODUCT
						string orderProdRules = "";
						if (bolHasProdRule){
							foreach(OrderBusinessRule w in productRules){
								int tmpIdProd = w.productId;
								int tmpCounterProd = w.productCounter;
								if(tmpIdProd==op.idProduct && tmpCounterProd==op.productCounter){
									string tmpLabel = w.label;                 
									decimal tmpAmountRule = w.value;
									orderProdRules+="<li>";
									if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+tmpLabel))){
										orderProdRules+=lang.getTranslated("backend.businessrule.label.label."+tmpLabel);
									}else{
										orderProdRules+=tmpLabel;
									}
									if(tmpAmountRule!=0){
										if(tmpAmountRule>0){
											totalMarginAmount+=tmpAmountRule;										
										}else if(tmpAmountRule<0){
											totalDiscountAmount+=Math.Abs(tmpAmountRule);	
										}
										orderProdRules+=":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00");
									}
									orderProdRules+="</li>";
								}
							}
						}	
						
						//****** MANAGE FIELDS FOR PRODUCT
						string productFields = "";
						if(opfs != null && opfs.Count>0){
							foreach(OrderProductField opf in opfs){
								string flabel = lang.getTranslated("backend.prodotti.detail.table.label.field_description_"+opf.description+"_"+prod.keyword);
								if(String.IsNullOrEmpty(flabel)){
									flabel = opf.description;
								}
								
								if(opf.fieldType==8){
									productFields+=flabel+":&nbsp;<a target='_blank' href='"+builder.ToString()+"public/upload/files/orders/"+opf.idOrder+"/"+opf.value+"'>"+opf.value+"</a><br/>";
								}else{
									productFields+=flabel+":&nbsp;"+opf.value+"<br/>";
								}
							}
						}%>				
					
						<tr class="<%if(orderProdCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"></td>
							<td><%=productrep.getMainFieldTranslationCached(op.idProduct, 1 , lang.currentLangCode, true,  op.productName, true).value+adsRefTitle%></td>
							<td>&euro;&nbsp;<%=op.taxable.ToString("#,###0.00")%>
								<ul style=padding-left:10px;padding-top:5px;margin:0px;>
								<%=opmargin+opdiscPerc+orderProdRules%>
								</ul>
							</td>
							<td>&euro;&nbsp;<%=op.supplement.ToString("#,###0.00")+suppdesc%></td>
							<td><%=op.productQuantity%></td>	
							<td><%=productFields%></td>	
						</tr>
						<%orderProdCounter++;
					} 
				}%>
				</table>
			<%}
			
			if(bolFoundLista || order!=null){%>
				<div style="padding-top:20px;">         
				<%//if (ug != null){%>
					<%if(totalMarginAmount>0){%><%=lang.getTranslated("frontend.carrello.table.label.totale_commissioni")%>:&nbsp;<strong>&euro;&nbsp;<%=totalMarginAmount.ToString("#,###0.00")%></strong><br/><%}%>
					<%if(totalDiscountAmount>0){decimal signedTotalDiscountAmount = 0-totalDiscountAmount;%><%=lang.getTranslated("frontend.carrello.table.label.totale_sconti")%>:&nbsp;<strong>&euro;&nbsp;<%=signedTotalDiscountAmount.ToString("#,###0.00")%></strong><br/><%}%>
					<%/*
					*** momentaneamente commentato, lo sconto applicato viene gia indicato nel totalDiscountAmount e nei singoli prodotti
					
					if(user != null && user.discount != null && user.discount >0){
						Response.Write(lang.getTranslated("frontend.carrello.table.label.sconto_cliente")+": "+user.discount.ToString("#,###0.##")+"%");
					}
					
					if(user != null && user.discount != null && user.discount >0 && "2".Equals(confservice.get("manage_sconti").value)){
						Response.Write("<br/>"+lang.getTranslated("frontend.carrello.table.label.if_client_has_sconto")+"<br/><br/>");
					}*/
					%> 
					<br/>
				<%//}%>
	
				<%=lang.getTranslated("frontend.carrello.table.label.totale_prodotti")%>:&nbsp;<strong>&euro;&nbsp;<%=totalProductAmount.ToString("#,###0.00")%></strong>
				<br/>
				
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
							
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+olabel))){
								olabel = lang.getTranslated("backend.businessrule.label.label."+olabel);
							}
						}%>
						<span class="rules"><%=olabel%></span>:&nbsp;&euro;&nbsp;<%=oamount.ToString("#,###0.00")%><br/>
					<%}
				}%>             
				</div>
				
				<%if(activeVoucherCampaign && !paymentDone && (orderid==-1 || (orderid>-1 && !bolHasProdRule))){%>        
					<div style="padding-top:10px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_carrello_voucher" id="form_carrello_voucher">
							<input type="hidden" value="0" name="voucher_delete">
							<input type="hidden" value="<%=orderid%>" name="id">
							<input type="hidden" value="<%=cartid%>" name="cartid">
							<input type="hidden" value="<%=orderUserId%>" name="userid">
							<input type="hidden" value="<%=cssClass%>" name="cssClass">	
							<input type="hidden" value="<%=titlef%>" name="titlef">		
							<input type="hidden" value="<%=keywordf%>" name="keywordf">		
							<input type="hidden" value="<%=typef%>" name="typef">		
							<input type="hidden" value="<%=categoryf%>" name="categoryf">
							<input type="hidden" value="" name="payment_method" id="voucher_payment_method">
							<%if(!String.IsNullOrEmpty(voucherMessage)){
								Response.Write("<span class=error>"+voucherMessage+"</span><br/>");
							}%>
							<strong class="labelForm"><%=lang.getTranslated("frontend.carrello.table.label.voucher_code")%></strong>&nbsp;<input type="text" id="voucher_code" name="voucher_code" value="<%=voucher_code%>">
							<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(0);" value="<%=lang.getTranslated("frontend.carrello.table.label.insert_voucher")%>">&nbsp;<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(1);" value="<%=lang.getTranslated("frontend.carrello.table.label.delete_voucher")%>">   
						</form>
					</div>
				<%}%>			
			

				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_insert_carrello" id="form_insert_carrello" accept-charset="UTF-8">
					<input type="hidden" value="process" name="operation">				
					<input type="hidden" value="<%=orderid%>" name="id">
					<input type="hidden" value="<%=cartid%>" name="cartid">
					<input type="hidden" value="<%=orderUserId%>" name="userid">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					<input type="hidden" value="<%=titlef%>" name="titlef">		
					<input type="hidden" value="<%=keywordf%>" name="keywordf">		
					<input type="hidden" value="<%=typef%>" name="typef">		
					<input type="hidden" value="<%=categoryf%>" name="categoryf">
					<input type="hidden" value="<%=voucher_code%>" name="voucher_code"> 			
					
	
					<%
					//******** GESTIONE SPESE ACCESSORIE
					if(applyBills){%>
						<br/><br/> 
						<strong class="labelForm" id="titlebills4card"><%=lang.getTranslated("frontend.carrello.table.label.spese_spedizione")%>:</strong>
						<div style="padding:0px;padding-left:5px;margin:0px;" id="bills-container">
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
								
								if(!oldGroupDesc.Equals(f.feeGroup) && !String.IsNullOrEmpty(f.feeGroup)){
									bills2Charge.Add(f.feeGroup,false);
									Response.Write("<strong id="+f.feeGroup+">"+billGdesc+"</strong><br/>");
								}
								
								if(f.autoactive){
									Response.Write("&nbsp;"+billDesc+"&nbsp;&nbsp;&nbsp;<strong>&euro;&nbsp;"+billAmount.ToString("#,###0.00")+"</strong><br/>");
									hasBills2charge = true;
								}else{
									if(f.multiply && ((billImp+billSup)>0 || f.typeView==1)){%>
										<input style="margin-left:10px;" <%if(orderid>0 && paymentDone){%>onclick="return false;" onkeydown="return false;"<%}else{%>onclick="javascript:calculateBills4Order('<%=totalCartAmountAndAutoBillsAmount%>','1','1');"<%}%> type="checkbox" name="<%=f.feeGroup%>" id="<%=f.feeGroup+"-"+f.id+"-"+required%>" value="<%=f.id%>" <%if(isChecked){Response.Write(" checked='checked'");}%>/> 
										<%=billDesc+"&nbsp;&nbsp;&nbsp;<strong>&euro;&nbsp;"+billAmount.ToString("#,###0.00")+"</strong>&nbsp;&nbsp;<br/>"%>	
									<%}else if(!f.multiply && (billImp+billSup)>0){%>	
										<input style="margin-left:10px;" onclick="return false;" <%if(orderid>0 && paymentDone){%>onkeydown="return false;"<%}else{%>onclick="javascript:calculateBills4Order('<%=totalCartAmountAndAutoBillsAmount%>','1','1');"<%}%> type="radio" name="<%=f.feeGroup%>" id="<%=f.feeGroup+"-"+f.id+"-"+required%>" value="<%=f.id%>" <%if(isChecked){Response.Write(" checked='checked'");}%>/>
										<%=billDesc+"&nbsp;&nbsp;&nbsp;<strong>&euro;&nbsp;"+billAmount.ToString("#,###0.00")+"</strong>&nbsp;&nbsp;<br/>"%>				
									<%}%>										
								
	
					
									<script language="Javascript">
									<%if(isChecked){%>
										jQuery(document).ready(function(){
											calculateBills4Order('<%=totalCartAmountAndAutoBillsAmount%>','1','1');
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
					
					
					<div style="padding-top:20px;">
						<strong class="labelForm"><%=lang.getTranslated("frontend.carrello.table.label.tipo_pagam_order")%>:</strong><br>	
						<div id="payment_list">
							<ul style="list-style:none;padding-left:5px;padding-top:0px;margin:0px;">
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
								<li><input type="radio" id="payment_method" name="payment_method" value="<%=key%>" <%if(isChecked){Response.Write(" checked='checked'");}%> <%if(orderid>0 && paymentDone){%>onclick="return false;" onkeydown="return false;"<%}else{%>onclick="javascript:calculatePaymentCommission('<%=totalCartAmountAndAutoBillsAmount%>',<%=key%>,'1','1');"<%}%>>&nbsp;<%=pdesc%>&nbsp;<%=logo%></li>
								<script language="Javascript">
								listPaymentMethods.put("<%=key%>","<%=p.commission+"|"+p.commissionType%>");
								
								<%if((orderid<0 || !paymentDone) && isChecked){%>
								jQuery(document).ready(function(){
									calculatePaymentCommission('<%=totalCartAmountAndAutoBillsAmount%>',<%=key%>,'1','1');
								});											
								<%}%>
								</script>
							<%}%>
							</ul>
						</div>
					</div>
					
					<%//*************************  GESTIONE CAMPI SPEDIZIONE  ****************************%>
					<div id="card_shipping_address" style="display:none;padding-top:20px;">
						<div align="left" onClick="javascript:showHideDiv('divShipCost')"><strong class="labelForm">
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
								<%if("0".Equals(confservice.get("enable_international_tax_option").value) || ("1".Equals(confservice.get("enable_international_tax_option").value) && orderid==-1)){%>
									<select id="ship_country" name="ship_country">
									<option value=""></option>
									<%foreach(Country x in countries){%>
									  <option value="<%=x.countryCode%>" <%if(x.countryCode.Equals(shipaddr.country)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.countryCode)%></option>     
									<%}%>
									</select> 
								<%}else if("1".Equals(confservice.get("enable_international_tax_option").value) &&  orderid>-1){%>
									<input type="hidden" value="<%=shipaddr.country%>" name="ship_country" id="ship_country">
									<%=lang.getTranslated("portal.commons.select.option.country."+shipaddr.country)%>
								<%}%>
							</div>
							<div style="padding-bottom:10px;">
								<strong><%=lang.getTranslated("frontend.carrello.table.label.state_region")%></strong><br>
								<%if("0".Equals(confservice.get("enable_international_tax_option").value) || ("1".Equals(confservice.get("enable_international_tax_option").value) && orderid==-1)){%>
									<select name="ship_state_region" id="ship_state_region">
									<option value=""></option>
									<%if(!String.IsNullOrEmpty(shipaddr.country)){
										foreach(Country x in stateRegions){%>
										  <option value="<%=x.stateRegionCode%>" <%if(x.stateRegionCode.Equals(shipaddr.stateRegion)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.stateRegionCode)%></option>     
										<%}
									}%>
									</select>	
								<%}else if("1".Equals(confservice.get("enable_international_tax_option").value) &&  orderid>-1){%>
									<input type="hidden" value="<%=shipaddr.stateRegion%>" name="ship_state_region" id="ship_state_region">
									<%=lang.getTranslated("portal.commons.select.option.country."+shipaddr.stateRegion)%>
								<%}%>
							</div>
							
							<div><strong><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company_client")%></strong><br>
							<%if("0".Equals(confservice.get("enable_international_tax_option").value) || ("1".Equals(confservice.get("enable_international_tax_option").value) && orderid==-1)){%>
								<select name="ship_is_company_client" id="ship_is_company_client">
								<option value="0" <%if(!shipaddr.isCompanyClient){Response.Write("selected");}%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_private")%></option>
								<option value="1" <%if(shipaddr.isCompanyClient){Response.Write("selected");}%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company")%></option>
								</select>
							<%}else if("1".Equals(confservice.get("enable_international_tax_option").value) &&  orderid>-1){%>
								<input type="hidden" value="<%if(shipaddr.isCompanyClient){Response.Write("1");}else{Response.Write("0");}%>" name="ship_is_company_client" id="ship_is_company_client">
								<%if(shipaddr.isCompanyClient){Response.Write(lang.getTranslated("frontend.utenti.detail.table.label.is_company"));}else{Response.Write(lang.getTranslated("frontend.utenti.detail.table.label.is_private"));}
							}%>
							</div>	
							
							<script>
							<%if("1".Equals(confservice.get("enable_international_tax_option").value)){
								if(orderid==-1){%>
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
								<%}
							}else{%>
								$('#ship_country').change(function() {
									var type_val_ch = $('#ship_country').val();
									var query_string = "field_val="+encodeURIComponent(type_val_ch);
				
									$.ajax({
										async: true,
										type: "GET",
										cache: false,
										url: "/backoffice/orders/ajaxstateregionupdate.aspx",
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
						bool showShipBox =	(("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value))) ||
											(applyBills && (user != null)) ||
											(user != null && ("1".Equals(confservice.get("show_ship_box").value) || "1".Equals(confservice.get("enable_international_tax_option").value)));
						
						if(showShipBox){%>
							$("#card_shipping_address").show();
						<%}%>
					</script>
					
					<%//*************************  GESTIONE CAMPI FATTURAZIONE  ****************************%>
					<div id="card_bills_address" style="display:none;padding-top:20px;">
						<div align="left" onClick="javascript:showHideDiv('divBillsCost')"><strong class="labelForm">
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
									url: "/backoffice/orders/ajaxstateregionupdate.aspx",
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
						bool showBillsBox =	("1".Equals(confservice.get("show_bills_box").value) && (user != null));
						
						if(showBillsBox){%>
							$("#card_bills_address").show();
						<%}%>
					</script>							
					
					<div id="spese-totale" style="padding-top:20px;">
						<span class="labelForm"><%=lang.getTranslated("frontend.carrello.table.label.payment_commission")%>:</span> <strong>&euro;&nbsp;<span class="payment_commission"><%=totalPaymentAmount.ToString("#,###0.00")%></span></strong><br/><br/> 
						<span class="labelForm"><%=lang.getTranslated("frontend.carrello.table.label.totale_ordine")%>:</span> <strong>&euro;&nbsp;<span class="ord_total"><%=(totalCartAmountAndBillsAmount).ToString("#,###0.00")%></span></strong>
					</div>

					  <div align="left" style="float:left;padding-top:20px;"><span class="labelForm"><%=lang.getTranslated("backend.ordini.detail.table.label.stato_order")%>&nbsp;&nbsp;&nbsp;</span><br>
					  <select name="status" class="formFieldChangeStato">
					  <%foreach(int w in orderStatus.Keys){
							string labelStatus = orderStatus[w];
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
								labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
							}%>
						<option value="<%=w%>" <%if (oStatus == w){Response.Write("selected");}%>><%=labelStatus%></option>
					  <%}%>
					  </select>&nbsp;&nbsp;</div>	
					  <div align="left" style="float:top;padding-top:20px;"><span class="labelForm"><%=lang.getTranslated("backend.ordini.detail.table.label.pagam_order_done")%></span><br>		  
					  <select name="payment_done" class="formFieldChangeStato">
					  <%if (!paymentDone){%><option value="0" selected><%=lang.getTranslated("backend.commons.no")%></option><%}%>
					  <option value="1" <%if (paymentDone){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
					  </select>
					  </div><br>	
					  
					  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.ordini.detail.table.label.order_notes")%></span><br>		  
					  <textarea name="order_notes" class="formFieldTXTAREAAbstract"><%=orderNotes%></textarea>
					  </div>					
					
					<div id="prodotto-totale" style="padding-top:20px;">
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.detail.button.inserisci.label")%>" onclick="javascript:sendForm(<%if(applyBills){Response.Write("1");}else{Response.Write("0");}%>);" />&nbsp;&nbsp;
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/orders/orderlist.aspx?cssClass=LO';" />
						<br/><br/>	
					</div>					
				</form>			
			<%}%>
			
			<form action="" method="post" name="form_cart_del_item" id="form_cart_del_item">	
			<input type="hidden" value="<%=voucher_code%>" name="voucher_code">
			<input type="hidden" value="delitem" name="operation">  
			<input type="hidden" value="" name="cartid">
			<input type="hidden" value="" name="productid">
			<input type="hidden" value="" name="counter_prod">
			<input type="hidden" value="<%=orderid%>" name="id">
			<input type="hidden" value="<%=orderUserId%>" name="userid">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="<%=titlef%>" name="titlef">		
			<input type="hidden" value="<%=keywordf%>" name="keywordf">		
			<input type="hidden" value="<%=typef%>" name="typef">		
			<input type="hidden" value="<%=categoryf%>" name="categoryf">
			<input type="hidden" value="" name="payment_method" id="del_item_payment_method">
			</form> 
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>		