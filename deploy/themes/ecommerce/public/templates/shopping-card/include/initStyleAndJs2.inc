<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%>
<script type="text/JavaScript" src="<%=Application("baseroot") & "/common/js/jsDraw2D_Uncompressed.js"%>"></script> 
<script language="JavaScript">
var isSentCard = false;
function sendCarrello(applyBills){
	var id_carrello = document.form_insert_carrello.id_carrello.value;
	if(id_carrello == ""){
		alert("<%=lang.getTranslated("frontend.carrello.js.alert.no_carrello_found")%>");
		return;
	}
	
	// CONTROLLO SCELTA TIPO PAGAMENTO PRIMA DI INIVIARE FORM
	var paymentSelected = false;
  if(document.form_insert_carrello.tipo_pagam){
    if(!document.form_insert_carrello.tipo_pagam.length || document.form_insert_carrello.tipo_pagam.length<=1){
        if(document.form_insert_carrello.tipo_pagam.checked == true){		
          paymentSelected = true;
        }	      
    }else{
      for(var i=0; i<document.form_insert_carrello.tipo_pagam.length; i++){		
        if(document.form_insert_carrello.tipo_pagam[i].checked == true){		
          paymentSelected = true;
          break;
        }		
      }      
    }
  }
	
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

    <%if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then%>  
	if(applyBills==1 <%if(Application("enable_international_tax_option") = 1)then response.write(" || true") end if%>){
		var check_ship = false;
		<%if(isEmpty(Session("objUtenteLogged"))) then%>
			if(document.getElementById("buy_noreg").value== "1"){
				check_ship = true;
			}
		<%else%>
			check_ship = true;
		<%end if%>

		// CONTROLLO CHE SIA STATO IMPOSTATO UNO SHIPPING ADDRESS
		if(check_ship){	
			if(document.getElementById("ship_name") && document.getElementById("ship_surname") && document.getElementById("ship_cfiscvat") && document.getElementById("ship_address") && document.getElementById("ship_zip_code") && document.getElementById("ship_city") && document.getElementById("ship_country")){
				if(document.getElementById("ship_name").value=="" || document.getElementById("ship_surname").value=="" || document.getElementById("ship_cfiscvat").value=="" || document.getElementById("ship_address").value=="" || document.getElementById("ship_zip_code").value=="" || document.getElementById("ship_city").value=="" || document.getElementById("ship_country").value==""){
					alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_shipping_address")%>");
					return;		
				}
			}
		}
	}
	<%end if	

	if(Application("show_bills_box") = 1) then%>
	var check_bills = false;
	<%if(isEmpty(Session("objUtenteLogged"))) then%>
		if(document.getElementById("buy_noreg").value== "1"){
			check_bills = true;
		}
	<%else%>
		check_bills = true;
	<%end if%>

	// CONTROLLO CHE SIA STATO IMPOSTATO UN BILLS ADDRESS	
	if(check_bills){
		if(document.getElementById("bills_name") && document.getElementById("bills_surname") && document.getElementById("bills_cfiscvat") && document.getElementById("bills_address") && document.getElementById("bills_zip_code") && document.getElementById("bills_city") && document.getElementById("bills_country")){
			if(document.getElementById("bills_name").value=="" || document.getElementById("bills_surname").value=="" || document.getElementById("bills_cfiscvat").value=="" || document.getElementById("bills_address").value=="" || document.getElementById("bills_zip_code").value=="" || document.getElementById("bills_city").value=="" || document.getElementById("bills_country").value==""){
				alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_bills_address")%>");
				return;		
			}
		}
	}
	<%end if%>

	// CONTROLLO SE E' STATA SELEZIONATA L'OPZIONE ACQUISTA SENZA REGISTRAZIONE
	if(document.getElementById("buy_noreg").value== "1"){
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
		if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then
		for each k in objListUserField
		  Set objField = objListUserField(k)
		  labelForm = objField.getDescription()
		  if not(lang.getTranslated("frontend.area_user.manage.label."&objField.getDescription())="") then labelForm = lang.getTranslated("frontend.area_user.manage.label."&objField.getDescription())
		  response.write(objUserField.renderUserFieldJS(objField,"form_insert_carrello",lang,labelForm,false))
		next
		end if
		%>	
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

function delFromCarrello(theForm, applyBills){
	if(confirm("<%=lang.getTranslated("frontend.carrello.js.alert.confirm_del_prod")%>")){
    theForm.action+="?"+selectPayAndBills4Form(applyBills)
		theForm.submit();
	}
}


function insertVoucher(doDelete){
  if(doDelete==1){
    document.form_carrello_voucher.voucher_delete.value="1";
    document.form_carrello_voucher.voucher_code.value="";
  }else{
    var voucher_code = document.form_carrello_voucher.voucher_code.value;
    if(voucher_code == ""){
      alert("<%=lang.getTranslated("frontend.carrello.js.alert.insert_code")%>");
      return;
    }
  }
  
  document.form_carrello_voucher.submit();
}

var listPaymentMethods;
listPaymentMethods = new Hashtable();

function calculatePaymentCommission(amount,payment_method, currFrom, currTo){
	var payment,commission,type;
	total_amount = amount.replace('.','');
	total_amount = Number(total_amount.replace(',','.'));
  
	/****** ricalcolo le spese accessorie *******/  
	var arrKeys = listBills4Order.keys();		
			
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	
    	bill_amount = tmpValue.replace('.','');
		bill_amount = bill_amount.replace(',','.');
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

	if(type == 2){
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


/**************
 metodo per il calcolo delle spese per ordine selezionate dall'utente
***************/
var listBills4Order;
listBills4Order = new Hashtable();  
  
function calculateBills4Order(amount, currFrom, currTo){
  
	var bill_amount,total_amount,elem, total_amount_4_payment;
	total_amount = amount.replace('.','');
  	total_amount_4_payment = total_amount;
	total_amount = Number(total_amount.replace(',','.'));
	
	var arrKeys = listBills4Order.keys();	
		
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = listBills4Order.get(tmpKey);	

		bill_amount = tmpValue.replace('.','');
		bill_amount = bill_amount.replace(',','.');
	
		elem = document.getElementById(tmpKey);
		
		if(elem.checked==true){
			total_amount = Number(total_amount)+Number(bill_amount);
		}
	}

	total_order = Number(total_amount).toFixed(2);

	/****** ricarico la lista dei metodi di pagamento disponibili *******/
  var tipo_pagam_tmp="";
	if(document.form_insert_carrello.tipo_pagam){
		if(!document.form_insert_carrello.tipo_pagam.length || document.form_insert_carrello.tipo_pagam.length<=1){
			if(document.form_insert_carrello.tipo_pagam.checked == true){		
				tipo_pagam_tmp = document.form_insert_carrello.tipo_pagam.value;
			}	      
		}else{
			for(var i=0; i<document.form_insert_carrello.tipo_pagam.length; i++){		
				if(document.form_insert_carrello.tipo_pagam[i].checked == true){		
					tipo_pagam_tmp = document.form_insert_carrello.tipo_pagam[i].value;
					break;
				}		
			}      
		}
	}
	ajaxReloadPaymentList(total_amount_4_payment, String(total_amount).replace('.',','), tipo_pagam_tmp);
	
	/****** ricalcolo le commissioni pagamento *******/

	paymentSelected = false;
	if(document.form_insert_carrello.tipo_pagam){
		if(!document.form_insert_carrello.tipo_pagam.length || document.form_insert_carrello.tipo_pagam.length<=1){
			if(document.form_insert_carrello.tipo_pagam.checked == true){		
				paymentSelected = true;
				payment_method = document.form_insert_carrello.tipo_pagam.value;
			}	      
		}else{
			for(var i=0; i<document.form_insert_carrello.tipo_pagam.length; i++){		
				if(document.form_insert_carrello.tipo_pagam[i].checked == true){		
					paymentSelected = true;
					payment_method = document.form_insert_carrello.tipo_pagam[i].value;
					break;
				}		
			}      
		}
	}

	currFrom = Number(currFrom.replace(',','.'));
	currTo = Number(currTo.replace(',','.'));
	
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
	var query_string = "totale_carrello="+totale_carrello+"&tot_and_spese="+tot_and_spese+"&tipo_pagam="+payment_method;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "GET",
		cache: false,
		url: "<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ajaxreloadpaymentlist.asp"%>",
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


var formSent = false;
function changeQtaToCarrello(oldQta, theFrom, maxQtaProd, applyBills){
	var sel_qta = theFrom.qta_prodotto_change.value;
	if(sel_qta == "" || Number(sel_qta) == 0){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.select_qta_prod")%>");
		theFrom.qta_prodotto_change.value = oldQta;
		return;
	}else if(isNaN(sel_qta)){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.qta_prodotto_change.value = oldQta;
		return;
	}else if(sel_qta.indexOf('.') != -1){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.qta_prodotto_change.value = oldQta;
		return;
	}else if(sel_qta==oldQta){
    return;  
  }

  if(maxQtaProd && maxQtaProd!=-1){
    if(sel_qta > maxQtaProd){
      alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%>");
		theFrom.qta_prodotto_change.value = oldQta;
		return;
    }
	}

	var hasfield4prod = false;
	var query_string = "id_prod="+theFrom.id_prodotto.value+"&qta_prodotto="+sel_qta;
	$("#"+theFrom.name).find("input:hidden[name*='<%=objProdField.getFieldPrefix()%>']").each(function(){
		var key, value;
		key = $(this).attr('name').substring($(this).attr('name').lastIndexOf("<%=objProdField.getFieldPrefix()%>")+<%=Len(objProdField.getFieldPrefix())%>, $(this).attr('name').length);
		value = $(this).val();
		//alert("key: "+key+" - value: "+value);
		hasfield4prod = true;
		query_string+="&"+key+"="+escape(value);
	});

	//integro chiamata ajax per verificare disponibilit? combinazione field prodotto
	if(hasfield4prod){
		result = ajaxCheckFieldAvailability(query_string);
		//alert("result: "+result);

		var ischecked, message_error_qta;
		if(window.DOMParser){
			ischecked = $(result).find("#checked_qta").text();
			message_error_qta = $(result).find("#message_error_qta").text();
		}else{
			var xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
			xmlDoc.async=false;
			xmlDoc.loadXML(result);	
			
			ischecked = xmlDoc.documentElement.selectSingleNode("/result/checked").text;
			message_error_qta = xmlDoc.documentElement.selectSingleNode("/result/message_error").text;
		}

		if (ischecked!="1"){
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
			theFrom.qta_prodotto_change.value = oldQta;
			return;
		}
	}
  
	if(formSent == false){
		formSent = true;
    	theFrom.operation.value = "add";
    	theFrom.qta_prodotto.value = sel_qta;
    	theFrom.reset_qta.value="1";
		//uploadFormUsingAjax(theFrom.name)
		theFrom.action+="?"+selectPayAndBills4Form(applyBills)
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function uploadFormUsingAjax(formID){
	// prepare Options Object 
	var options = { 
	    type: "POST", 
	    url: '<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ManageCarrello.asp"%>',
	    iframe:true	    
	}; 
	 
	// pass options to ajaxForm 
	$("#"+formID).ajaxSubmit(options);
	return false;
}

function selectPayAndBills4Form(applyBills){
	var query_string = "&";
	if(document.form_insert_carrello.tipo_pagam){
		if(!document.form_insert_carrello.tipo_pagam.length || document.form_insert_carrello.tipo_pagam.length<=1){
			if(document.form_insert_carrello.tipo_pagam.checked == true){	
//alert("document.form_insert_carrello.tipo_pagam.value: "+document.form_insert_carrello.tipo_pagam.value);	
				query_string+="tipo_pagam="+escape(document.form_insert_carrello.tipo_pagam.value);
			}	      
		}else{
			for(var i=0; i<document.form_insert_carrello.tipo_pagam.length; i++){		
				if(document.form_insert_carrello.tipo_pagam[i].checked == true){		
					query_string+="tipo_pagam="+escape(document.form_insert_carrello.tipo_pagam[i].value)+"&";
//alert("document.form_insert_carrello.tipo_pagam[i].value: "+document.form_insert_carrello.tipo_pagam[i].value);
				}		
			}      
		}
	}

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
						query_string+=elem.name+"="+escape(elem.value);
					}	      
				}else{
					var dobreak=false;
					for(var i=0; i<elem.length; i++){		
						if(elem[i].checked == true){
							query_string+=elem[i].name+"="+escape(elem[i].value)+"&";
						}	
					}      
				}
			}
		}		
	}

	return query_string;
}

function ajaxCheckFieldAvailability(query_string){
	<%
	' recupero url corrente per definire path a ajaxcheckprodqta.asp
	tmpurl = request.ServerVariables("URL")
	tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
	%>
	
	//alert("query_string: "+query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		//dataType: "xml",
		url: "<%=tmpurl&"ajaxcheckprodavailability.asp"%>",
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

function ajaxSetSessionPayAndBills(field){
	<%
	' recupero url corrente per definire path a ajaxcheckprodqta.asp
	tmpurl = request.ServerVariables("URL")
	tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
	%>
	
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
	//alert("query_string: "+query_string);
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "<%=tmpurl&"ajaxsetsessionpaybills.asp"%>",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
		},
		error: function(response) {
			//alert("response error: "+response);
		}
	});
}
  
function openRelatedProdPage(strAction, strGerarchia, numIdProd, numPageNum){
    document.form_carrello_rel_prod.action=strAction;
    document.form_carrello_rel_prod.gerarchia.value=strGerarchia;
    document.form_carrello_rel_prod.id_prodotto.value=numIdProd;
    document.form_carrello_rel_prod.modelPageNum.value=numPageNum;
    document.form_carrello_rel_prod.submit();
}
</SCRIPT>