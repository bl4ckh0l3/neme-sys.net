<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include file="include/init4.asp" -->
<!-- #include virtual="/editor/include/setlistatargetprod.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
//VARIABILE GLOBALE
var browserName=navigator.appName;
var browserConst = "Microsoft Internet Explorer";
var items, itemsOld;
var itemsField4prodOrder, itemsField4prodOrderOld;
items = new Hashtable();
itemsOld = new Hashtable();
itemsField4prodOrder = new Hashtable();
itemsField4prodOrderOld = new Hashtable();

//RIEMPIO hashtable js con la lista dei prodotti già esistenti, se è una modifica ordine
<%
if(hasObjProdPerOrder) then
	Dim objOldProd
	
	for each z in objSelProdPerOrder
		Set objOldProd = objSelProdPerOrder(z)		
		
		hasInitProdFields=false
		
		On Error Resume Next
		Set objInitListProdField = objProdField.getListProductField4ProdActive(objOldProd.getIDProdotto())
		
		if (Instr(1, typename(objInitListProdField), "Dictionary", 1) > 0) then
			if(objInitListProdField.count > 0)then
				hasInitProdFields=true							
			end if
		end if
		if(Err.number <> 0) then
			hasInitProdFields=false
		end if				
		
		if not(hasInitProdFields) then		
			response.Write("items.put(" & objOldProd.getIDProdotto() & ", '" & objOldProd.getIDProdotto() & "|" &  objOldProd.getQtaProdotto() & "');")
			response.Write("itemsOld.put(" & objOldProd.getIDProdotto() & ", '" & objOldProd.getIDProdotto() & "|" & objOldProd.getQtaProdotto() & "');")
		else		
			if (Instr(1, typename(objProdField.findListFieldXOrderByProd(objOldProd.getCounterProd(),id_order, objOldProd.getIDProdotto())), "Dictionary", 1) > 0) then
				Set fieldInitList4Order = objProdField.findListFieldXOrderByProd(objOldProd.getCounterProd(),id_order, objOldProd.getIDProdotto())	
					
				for each p in fieldInitList4Order					
					initKeytoInsert = ""
					initQtatoInsert = ""
					Set objTmpInitField4Order = fieldInitList4Order(p)
					initKeys = objTmpInitField4Order.Keys
					initKeytoInsert = initKeytoInsert & p & "|-|" & objOldProd.getIDProdotto() & "|-|"
					
					for each c in initKeys
						Set tmpInitF4O = c
						initQtatoInsert = c.getQtaProd()
						initKeytoInsert = initKeytoInsert & c.getID() & "|" & c.getSelValue() & "$"
						Set tmpInitF4O = nothing
					next
					
					if(initKeytoInsert > "") then
						initKeytoInsert = Left( initKeytoInsert, InStrRev( initKeytoInsert, "$" ) - 1 )
					end if
					
					response.Write("itemsField4prodOrder.put('" & initKeytoInsert & "', '" & initQtatoInsert & "');")
					response.Write("itemsField4prodOrderOld.put('" & initKeytoInsert & "', '" & initQtatoInsert & "');")
					
					Set objTmpInitField4Order = nothing					
				next
			else
				initKeytoInsert = objOldProd.getCounterProd()&"|-|" & objOldProd.getIDProdotto() & "|-|"
				
				response.Write("itemsField4prodOrder.put('" & initKeytoInsert & "', '" & objOldProd.getQtaProdotto() & "');")
				response.Write("itemsField4prodOrderOld.put('" & initKeytoInsert & "', '" & objOldProd.getQtaProdotto() & "');")				
			end if
			Set objInitListProdField = nothing			
		end if
	next
end if
%>

function sendForm(bolHasProdField,comeFromPagination){
	if(controllaCampiInput(bolHasProdField,comeFromPagination)){
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function controllaCampiInput(bolHasProdField,comeFromPagination){
	/*
	Se la chiamata arriva dalla paginazione imposto i parametri necessari per la processordine2.asp
	*/
	if(comeFromPagination==1){
		$("#ins_come_from_pagination").val("1");
	}	


	/* 
	CREAZIONE DELLA LISTA CHIAVI DI TUTTI I PRODOTTI, FIELDS E QUANTITA' SELEZIONATE
		La lista di chiavi create si differenzia per i prodotti con e senza fields aggiuntivi per prodotto;
		
		Per i prodotti che non hanno fields aggiuntivi la chiave sarà composta nel modo seguente:
		
		1) segno iniziale (-) che indica l'assenza di fields aggiuntivi;
		2) id prodotto;
		3) simbolo di separazione (|);
		3) quantità selezionata;
		4) simbolo di separazione di ogni chiave (#);
		
		es: -2|5#
	
		Per i prodotti che hanno fileds aggiuntivi invece la chiave sarà composta nel modo seguente:
		
		1) segno iniziale (+) che indica la presenza di fields aggiuntivi;
		2) id prodotto;
		3) simbolo di separazione (|);
		4) contatore della selezione prodotti+field;
		5) apertura parentesi quadra ([);
		6) lista fields+valore per prodotto: contiene una sequenza chiave|valore di fields per prodotto, separati da $		
		5) chiusura parentesi quadra (]);
		3) quantità selezionata;
		4) simbolo di separazione di ogni chiave (#);
		
		es: +2|1[1|xl$3|rosso$2|10/05/2010]5#
		
	*/
	
	var prodValue = "";
	var tmpKey;
	var tmpValue;	
	var arrKeys = items.keys();	
	
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = items.get(tmpKey);
			
		if(itemsOld != null && itemsOld.containsKey(tmpKey)){
			itemsOld.remove(tmpKey);
		}		
		
		if(tmpValue != null){
			prodValue += "-" + tmpValue + "#";
		}
	}
	
	if(itemsOld != null && itemsOld.size() > 0){
		var tmpKeyOld;
		var tmpValueOld;
		var arrKeyOld = itemsOld.keys()
		for(var y=0; y<arrKeyOld.length; y++){
			tmpKeyOld = arrKeyOld[y];
			tmpValueOld = itemsOld.get(tmpKeyOld);
			tmpValueOld = tmpValueOld.substring(0, tmpValueOld.lastIndexOf('|')) + "|0";
			if(tmpValueOld != null){
				prodValue += "-" + tmpValueOld + "#";
			}
		}
	}
	
	// verifico se esistono prodotti con field accessori e creo le chiavi opportune
	var harOneSelectedProdField = false;
	if(bolHasProdField==1){
		arrKeys = itemsField4prodOrder.keys();
		
		for(var z=0; z<arrKeys.length; z++){
			tmpKey = arrKeys[z];
			tmpValue = itemsField4prodOrder.get(tmpKey);
			//alert("tmpKey: "+tmpKey);
				
			if(itemsField4prodOrderOld != null && itemsField4prodOrderOld.containsKey(tmpKey)){
				itemsField4prodOrderOld.remove(tmpKey);
			}		
			
			if(tmpValue != null){				
				tmpCounter = tmpKey.substring(0, tmpKey.indexOf('|-|'));	
				tmpIdProd = tmpKey.substring(tmpKey.indexOf('|-|')+3, tmpKey.lastIndexOf('|-|'));
				tmpFieldList = tmpKey.substring(tmpKey.lastIndexOf('|-|')+3, tmpKey.length);	
				//alert("tmpFieldList: "+tmpFieldList);			
				tmpFinalKey = "+" + tmpIdProd+"|"+tmpCounter+"["+tmpFieldList+"]"+tmpValue + "#";
				
				prodValue += tmpFinalKey;
				harOneSelectedProdField = true;
			}
		}
		
		if(itemsField4prodOrderOld != null && itemsField4prodOrderOld.size() > 0){
			var arrKeyOld = itemsField4prodOrderOld.keys()
			for(var y=0; y<arrKeyOld.length; y++){
				tmpKeyOld = arrKeyOld[y];
				tmpCounter = tmpKeyOld.substring(0, tmpKeyOld.indexOf('|-|'));	
				tmpIdProd = tmpKeyOld.substring(tmpKeyOld.indexOf('|-|')+3, tmpKeyOld.lastIndexOf('|-|'));
				tmpFieldList = tmpKeyOld.substring(tmpKeyOld.lastIndexOf('|-|')+3, tmpKeyOld.length);	
				//alert("tmpFieldList: "+tmpFieldList);			
				tmpFinalKey = "+" + tmpIdProd+"|"+tmpCounter+"["+tmpFieldList+"]0#";
				
				prodValue += tmpFinalKey;
			}
		}		
	}
	
	
	prodValue = prodValue.substring(0, prodValue.lastIndexOf('#'));
	document.form_inserisci.complete_selected_prod_list.value = prodValue;
	
	//alert("prodValue: "+document.form_inserisci.complete_selected_prod_list.value);
	
	var isProdListEmpty = true;
	
	<%if(bolCanModifyProd = true) then%>
		for(var y=0; y<document.prod_list_size.size.value; y++){
			var commandElem = "document.form_lista_"+y
			var commandTest = "document.form_lista_"+y+".add_prod"
			var command = "document.form_lista_"+y+".add_prod.checked == true"
			if(eval(commandElem) && eval(commandTest) && eval(command)){
				isProdListEmpty = false;
				break;
			}	
		}
		
		//imposto a false anche se c'è un prodotto con field accessori e almeno uno è stato selezionato
		if(bolHasProdField && harOneSelectedProdField){
			isProdListEmpty = false;
		}
	<%else%>
		isProdListEmpty = false;
	<%end if%>
	
	if(isProdListEmpty && comeFromPagination!=1){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.seleziona_prodotto")%>");
		return false;
	}		
	
	return true;
}

function setProdListPaginationNumber(page){
	$("#ins_page_num").val(page);
}


function trimAll(sString) {
	while (sString.substring(0,1) == ' '){
		sString = sString.substring(1, sString.length);
	}
	while (sString.substring(sString.length-1, sString.length) == ' '){
		sString = sString.substring(0,sString.length-1);
	}
	
	return sString;
}

function replaceCommaInNumber(number){
	return number.replace(',','.')
} 

function replaceDotInNumber(number){
	return number.replace('.',',')
} 


function addItemToOrder(theForm, idProd, qtaType, index){
	var sel_qta = trimAll(theForm.qta_prodotto.value);
		
	if(theForm.add_prod.checked == true && !sel_qta.length == 0){
		var sel_prod = theForm.selected_prodotto.value;
		sel_prod += "|" + sel_qta;
		
		if(isNaN(sel_qta)){
			alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.isnan_value")%>");
			theForm.add_prod.checked = false;
			theForm.qta_prodotto.value = "";
		}else{
			items.put(idProd, sel_prod);	
		}
		
		lockQtaInputOnFly(sel_qta, qtaType, theForm, index);			
	}else if(theForm.add_prod.checked == true && sel_qta.length == 0){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.select_qta_prod")%>");
		theForm.add_prod.checked = false;
		theForm.qta_prodotto.value = "";
	}else{
		theForm.add_prod.checked = false;		
		//modifico l'html della qta prodotto
		changeQtaOnFly(sel_qta, qtaType, theForm, index);
		items.remove(idProd);		
	}
}

function changeQtaOnFly(qta, type, theForm, index){
	if(document.getElementById){
		var divName = "qtaProdTxt_" + index;
		var divName2 = "qtaProdTxtOldProdQta_" + index;
		var divName3 = "fieldProdTxt_" + index;
		var divName4 = "fieldProdTxtOldProdfield_" + index;
		var elem = document.getElementById(divName);
		var elem2 = document.getElementById(divName2);
		var elem3 = document.getElementById(divName3);
		var elem4 = document.getElementById(divName4);
		elem.style.visibility= "visible";
		elem.style.display = "block";
		elem2.style.visibility= "hidden";
		elem2.style.display = "none";
		if(elem3){
		elem3.style.visibility= "visible";
		elem3.style.display = "block";
		}
		if(elem4){
		elem4.style.visibility= "hidden";
		elem4.style.display = "none";
		}
	}
	
	if(type != "<%=Application("unlimited_key")%>"){		
		var newQta = Number(type) + Number(qta);
		theForm.qta_prodotto_orig.value = newQta;
	}
}

function lockQtaInputOnFly(qta, type, theForm, index){	
	if(document.getElementById){
		var divName = "qtaProdTxt_" + index;
		var divName2 = "qtaProdTxtOldProdQta_" + index;
		var divName3 = "fieldProdTxt_" + index;
		var divName4 = "fieldProdTxtOldProdfield_" + index;
		var elem = document.getElementById(divName);
		var elem2 = document.getElementById(divName2);
		var elem3 = document.getElementById(divName3);
		var elem4 = document.getElementById(divName4);
		elem.style.visibility= "hidden";
		elem.style.display = "none";
		elem2.style.visibility= "visible";
		elem2.style.display = "block";
		elem2.innerHTML = qta;
		if(elem3){
		elem3.style.visibility= "hidden";
		elem3.style.display = "none";
		}
		if(elem4){
		elem4.style.visibility= "visible";
		elem4.style.display = "block";
		}
	}
	
	if(type != "<%=Application("unlimited_key")%>"){	
		var newQta = Number(type) - Number(qta);
		theForm.qta_prodotto_orig.value = newQta;	
	}
}

function checkMaxQtaProd(maxQtaProd, oldQta, field){
	if(Number(field.value) > maxQtaProd){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.exceed_qta_prod")%>");
		if(oldQta>0){
			field.value=oldQta;
		}else{
			field.value="";
		}
	}
}

function uploadFileUsingAjax(formID){
	// prepare Options Object 
	var options = { 
	    type: "POST", 
	    url: '<%=Application("baseroot") & "/editor/ordini/ajaxuploadfile.asp"%>',
	    iframe:true	    
	}; 
	 
	// pass options to ajaxForm 
	$(formID).ajaxSubmit(options);
	return false;
}


function addProductCombination(theForm, id_prod,cssRow,fieldValueList,prodCounter){
	var selQta = theForm.qta_prodotto.value;
	
	if(isNaN(selQta)){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.isnan_value")%>");
		theForm.qta_prodotto.value = "";
		return;	
	}

	if(selQta.length == 0 || selQta==0){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.select_qta_prod")%>");
		theForm.qta_prodotto.value = "";
		return;	
	}
	
	var formID = "#"+theForm.name;
	var counter = $("#internal_field_prod_counter"+prodCounter).val();
	var nextCounter = Number(counter)+1;
	var parentElem;
	//alert("fieldValueList: "+fieldValueList);
	var arrFieldList = fieldValueList.split("#");
	var key4Map = (nextCounter)+"|-|"+id_prod+"|-|";

	parentElem = "#base-order-prod-list-"+id_prod+"-"+prodCounter;
	
	var render = "";
	
	render +=('<tr class="'+cssRow+'" id="order-prod-list-'+id_prod+'-'+nextCounter+'">');
	render +=('<td colspan="3">&nbsp;</td>');
	render +=('<td colspan="3" align="right">');
	
	//alert("counter: "+counter);
	
	render +=('<div class="div-order-prod-list" align="right">');
	render +=('<div align="right" style="float:left;padding-right:10px;text-align:left;">');
	render +=('<span id="qta-order-prod-list-'+id_prod+'-'+nextCounter+'"><b><%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%>:</b>&nbsp;'+selQta+'<br/></span>');
	
	//lista di field/value;
	var internalKey4Map = "";
	
	//alert("arrFieldList.length: "+arrFieldList.length);
	
	for(var i=0;i<arrFieldList.length;i++){
		var compositeKey = arrFieldList[i];
		var internalKey = compositeKey.split("|");
		var key = internalKey[0];
		var desc = internalKey[1];
		var required = internalKey[2];
		var fieldType = internalKey[3];
		//alert("key: "+key);
		//alert("desc: "+desc);
		//alert("required: "+required);
		//alert("fieldType: "+fieldType);
		//alert("value: "+document.getElementById("productfield_019").value);
		
		//var fieldVal = eval("document."+theForm.name+".productfield_"+prodCounter+key+".value");
		var fieldVal = document.getElementById("productfield_"+prodCounter+key);
		if(fieldVal){	
			fieldVal = fieldVal.value; 
			if(required=="+" && fieldVal.length==0){
				alert('<%=langEditor.getTranslated("backend.ordini.detail.js.alert.insert_value_for_field")%> '+desc);
				return;
			}
			
			// verifico se si tratta di un campo file e spedisco il form via ajax
			if(fieldType==8 && fieldVal.length>0){
				filepath = "<%=Application("dir_upload_prod")&"fields/"%>"+id_prod+"<%="/"&Session.SessionID&"/"%>"+fieldVal;
				fieldVal = filepath;

				uploadFileUsingAjax(formID);
			}
			
			if(trimAll(fieldVal).length>0){
				internalKey4Map+=key+"|"+fieldVal+"$";
			}
			
			if(fieldType==8 && fieldVal.length>0){
					fieldVal = '<a href="'+fieldVal+'" target="_blank">click</a>';
			}
			//alert("fieldVal: "+fieldVal);	
			render+="<b>"+desc+":</b>&nbsp;"+fieldVal+"<br/>";
		}
	}
	internalKey4Map = internalKey4Map.substring(0, internalKey4Map.lastIndexOf('$'));
	
	key4Map+=internalKey4Map;
	
	//alert("key4Map: "+key4Map);
	
	render +=('</div>');
	render +=('<div align="right" style="padding-top:2px;">');	
	render +='<a href="';
	render+="javascript:delProductCombination(document."+theForm.name+",'"+key4Map+"','order-prod-list-"+id_prod+"-"+nextCounter+"',"+prodCounter+");";
	render+='">';
	render +=('<img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" hspace="5" vspace="0" border="0">');
	render +=('</a>');
	render +=('</div>');	
	render +=('</div></td></tr>');

	//alert(render);
	
	
	
	// aggiorno la mappa dei field
	if(itemsField4prodOrder != null){

		var arrKeys = itemsField4prodOrder.keys();	
		var foundedKey = false;
		
		for(var z=0; z<arrKeys.length; z++){
			var keyMatch = true;
			tmpKey = arrKeys[z];
			tmpQta = itemsField4prodOrder.get(tmpKey);
			
			tmpCounter = tmpKey.substring(0, tmpKey.indexOf('|-|'));	
			tmpIdProd = tmpKey.substring(tmpKey.indexOf('|-|')+3, tmpKey.lastIndexOf('|-|'));	
			tmpIdProd4Map = key4Map.substring(key4Map.indexOf('|-|')+3, key4Map.lastIndexOf('|-|'));
				
			//alert("tmpIdProd: "+tmpIdProd);	
			//alert("tmpIdProd4Map: "+tmpIdProd4Map);	
			//alert("tmpCounter: "+tmpCounter);	
			
			keyMatch = keyMatch && (tmpIdProd==tmpIdProd4Map)
			
			//alert("keyMatch: "+keyMatch);	
			
			tmpKeyProdField = tmpKey.substring(tmpKey.lastIndexOf('|-|')+3, tmpKey.length);
			tmpKeyProdField4Map = key4Map.substring(key4Map.lastIndexOf('|-|')+3, key4Map.length);
			
			//alert("tmpKeyProdField: "+tmpKeyProdField);	
			//alert("tmpKeyProdField4Map: "+tmpKeyProdField4Map);	
			
			arrTmpKeyProdField = tmpKeyProdField.split("$");
			arrTmpKeyProdField4Map = tmpKeyProdField4Map.split("$");
			
			for(var w=0;w<arrTmpKeyProdField.length;w++){
				var innerTmpKey = arrTmpKeyProdField[w];
				//alert("innerTmpKey: "+innerTmpKey);	
				var innerTmpKeyMatch = false;
				
				for(var j=0;j<arrTmpKeyProdField4Map.length;j++){
						var innerTmpKey4Map = arrTmpKeyProdField4Map[j];
						//alert("innerTmpKey4Map: "+innerTmpKey4Map);	
						if(innerTmpKey==innerTmpKey4Map){
							innerTmpKeyMatch = true;
							break;
						}
				}
				
				keyMatch = keyMatch && (innerTmpKeyMatch)				
			}			
			
			//alert("tmpKey.indexOf('|-|'): "+tmpKey.indexOf('|-|'));	
			//alert("tmpKey.lastIndexOf('|-|'): "+tmpKey.lastIndexOf('|-|'));	
			//alert("tmpKey: "+tmpKey);		
			//alert("tmpKeyProd: "+tmpKeyProd);	
			//alert("tmpKey4Map: "+tmpKey4Map);	
			//alert("tmpCounter: "+tmpCounter);	
			//alert("tmpIdProd: "+tmpIdProd);	
			
			//alert("keyMatch: "+keyMatch);	
			
			if(keyMatch){
				var newQta = Number(selQta)+Number(tmpQta);	
		
				$("#qta-order-prod-list-"+tmpIdProd+"-"+tmpCounter).empty();
				$("#qta-order-prod-list-"+tmpIdProd+"-"+tmpCounter).append('<%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%>:&nbsp;'+newQta+'<br/>');
		
				itemsField4prodOrder.put(tmpKey,newQta);	
		
				foundedKey = true;
				break;
			}			
		}

		if(!foundedKey){
			$(parentElem).after(render);	
			$("#internal_field_prod_counter"+prodCounter).val(nextCounter);
			
			itemsField4prodOrder.put(key4Map,selQta);				
		}

	}else{
		$(parentElem).after(render);	
		$("#internal_field_prod_counter"+prodCounter).val(nextCounter);
		
		itemsField4prodOrder.put(key4Map,selQta);	
	}

}

function delProductCombination(theForm, delCombKey, field,index){
	var key4Map = delCombKey;

	if(itemsField4prodOrder != null){

		var arrKeys = itemsField4prodOrder.keys();	
		var foundedKey = false;
		
		for(var z=0; z<arrKeys.length; z++){
			var keyMatch = true;
			tmpKey = arrKeys[z];
			
			tmpCounter = tmpKey.substring(0, tmpKey.indexOf('|-|'));	
			tmpIdProd = tmpKey.substring(tmpKey.indexOf('|-|')+3, tmpKey.lastIndexOf('|-|'));	
			tmpCounter4Map = key4Map.substring(0, key4Map.indexOf('|-|'));	
			tmpIdProd4Map = key4Map.substring(key4Map.indexOf('|-|')+3, key4Map.lastIndexOf('|-|'));
				
			//alert("tmpIdProd: "+tmpIdProd);	
			//alert("tmpIdProd4Map: "+tmpIdProd4Map);	
			//alert("tmpCounter: "+tmpCounter);	
			//alert("tmpCounter4Map: "+tmpCounter4Map);	
			
			keyMatch = keyMatch && (tmpIdProd==tmpIdProd4Map)
			keyMatch = keyMatch && (tmpCounter==tmpCounter4Map)
			
			//alert("keyMatch: "+keyMatch);	
			
			tmpKeyProdField = tmpKey.substring(tmpKey.lastIndexOf('|-|')+3, tmpKey.length);
			tmpKeyProdField4Map = key4Map.substring(key4Map.lastIndexOf('|-|')+3, key4Map.length);
			
			//alert("tmpKeyProdField: "+tmpKeyProdField);	
			//alert("tmpKeyProdField4Map: "+tmpKeyProdField4Map);	
			
			arrTmpKeyProdField = tmpKeyProdField.split("$");
			arrTmpKeyProdField4Map = tmpKeyProdField4Map.split("$");
			
			for(var w=0;w<arrTmpKeyProdField.length;w++){
				var innerTmpKey = arrTmpKeyProdField[w];
				//alert("innerTmpKey: "+innerTmpKey);	
				var innerTmpKeyMatch = false;
				
				for(var j=0;j<arrTmpKeyProdField4Map.length;j++){
						var innerTmpKey4Map = arrTmpKeyProdField4Map[j];
						//alert("innerTmpKey4Map: "+innerTmpKey4Map);	
						if(innerTmpKey==innerTmpKey4Map){
							innerTmpKeyMatch = true;
							break;
						}
				}
				
				keyMatch = keyMatch && (innerTmpKeyMatch)				
			}			
			
			//alert("keyMatch: "+keyMatch);	
			
			if(keyMatch){		
				itemsField4prodOrder.remove(tmpKey);	
				break;
			}
			
		}
	}
	
	$("#"+field).remove();
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
		  <%Dim objClientTmp, hasSconto, scontoCliente, hasGroup, groupCliente, groupDesc, objSelMargin
			Dim objGroup
			Set objGroup = new UserGroupClass
			
			hasSconto=false
			hasGroup = false
			scontoCliente = 0
			groupCliente = ""
			groupDesc = ""
			
			if(not(id_utente = "")) then
				Set objClientTmp = objUserLogged.findUserByID(id_utente)		  
		  		response.write(objClientTmp.getUserName())
		  
				groupCliente = objClientTmp.getGroup()
				if(not(groupCliente= "")) then
					On Error Resume Next
					Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
					groupDesc = objTmpGr.getShortDesc()
					hasGroup = true
					Set objTmpGr = nothing
					Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
					if(Err.number <> 0) then
						hasGroup = false
					end if
				end if
		  
				scontoCliente = objClientTmp.getSconto()
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
						
				Set objClientTmp = nothing
			else
				response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
			end if
		  
		  Set tmpObjUsr = nothing
		  Set objUtente = nothing
		  Set objUserLogged = nothing
		  %>
		<br><br>

		<table border="0" cellpadding="0" cellspacing="0" align="center" class="filter-table">
		<tr>
		<th align="center"><%=langEditor.getTranslated("backend.prodotti.lista.table.menu.header.txt")%></th>
		</tr>
		<%
		Dim menuFruizioneTmp, iGerLevelTmp, strGerarchiaTmp
		Set menuFruizioneTmp = new MenuClass
		if(isNull(session("strGerTmp")) OR session("strGerTmp") = "" OR (not(isNull(request("resetMenu"))) AND request("resetMenu") = "1")) then
			session("strGerTmp") = "00" 
			session("ordiniPage") = 1
			numPage = session("ordiniPage")
		end if
		if(request("strGerarchiaTmp") = "") then 
			strGerarchiaTmp = session("strGerTmp") 
		else 
			strGerarchiaTmp = request("strGerarchiaTmp")
			session("strGerTmp") = strGerarchiaTmp
		end if		
		iGerLevelTmp = menuFruizioneTmp.getLivello(strGerarchiaTmp)
		
		Set objListCatXProdTmp = CategoryClassTmp.findCategorieByTypeAndMixed(Application("strProdCat"))
		
		for each x in objListCatXProdTmp
			level = menuFruizioneTmp.getLivello(objListCatXProdTmp(x).getCatGerarchia())
			iGerDiff = level - iGerLevelTmp
				
			if(level > 1) then
				iWidth = (level-1) * 10 
				iLenGer = (level * 2) + (level -1)
				strSubTmpGer = Left(strGerarchiaTmp, iLenGer)
				strSubTmpGerFiltered = Left(strSubTmpGer, iLenGer-3)
				
				if(iGerDiff <= 1) then
					if (InStr(1, Left(objListCatXProdTmp(x).getCatGerarchia(), iLenGer-3), strSubTmpGerFiltered, 0) > 0) then
						hrefGer = objListCatXProdTmp(x).getCatGerarchia()%>
						<tr>
							<td><img width="<%=iWidth%>" height="5" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0" align="left"><img src="<%=Application("baseroot")&"/editor/img/folder_explore.png"%>" hspace="0" vspace="0" border="0" align="left"><a href="<%=Application("baseroot") & "/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_order&"&page=1&target_cat="&objListCatXProdTmp(x).getCatID()&"&strGerarchiaTmp="&hrefGer&"&items="&itemsXpage%>" class="filter-list<%if(strComp(objListCatXProdTmp(x).getCatGerarchia(), strSubTmpGer, 1) = 0) then response.Write("-active")%>"><%if not(isNull(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()))) AND not(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()) = "") then response.write(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia())) else response.Write(objListCatXProdTmp(x).getCatDescrizione()) end if%></a></td>
						</tr>			
					<%end if
				end if
			else
				iWidth = 0
				iLenGer = 2
				strSubTmpGer = Left(strGerarchiaTmp, iLenGer)
				hrefGer = objListCatXProdTmp(x).getCatGerarchia()%>
				<tr>
					<td><img src="<%=Application("baseroot")&"/editor/img/folder_explore.png"%>" hspace="0" vspace="0" border="0" align="left"><a href="<%=Application("baseroot") & "/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_order&"&page=1&target_cat="&objListCatXProdTmp(x).getCatID()&"&strGerarchiaTmp="&hrefGer&"&items="&itemsXpage%>" class="filter-list<%if(strComp(objListCatXProdTmp(x).getCatGerarchia(), strSubTmpGer, 1) = 0) then response.Write("-active")%>"><%if not(isNull(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()))) AND not(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia()) = "") then response.write(langEditor.getTranslated(objListCatXProdTmp(x).getCatGerarchia())) else response.Write(objListCatXProdTmp(x).getCatDescrizione()) end if%></a></td>
				<tr>
			<%end if		
		next	

		Set menuFruizioneTmp = Nothing
		%>
		<tr> 
			<th>&nbsp;</th>
		</tr>
		</table>
		<br/>


		<%' *****************************************************		
		  ' INIZIO: CODICE RECUPERO/GESTIONE LISTA PRODOTTI			
			
		Dim objProdotti, objListaProdotti
		Set objProdotti = New ProductsClass
		
		if(not(request("error")) = "" AND request("error") = 1) then%>
		<br><span class="labelErrorOrder"><%=langEditor.getTranslated("backend.ordini.detail.table.label.error_wrong_qta") & " " & request("nome_prod")%></span><br><br>
		<%end if
		
		if(bolCanModifyProd = false) then%>
			<br><span class="labelErrorOrder"><%=langEditor.getTranslated("backend.ordini.detail.table.label.error_prod_no_modity")%></span>&nbsp;<span class="labelTimeblack"><%=Application("minute_order_modify_permit")%></span>&nbsp;<span class="labelErrorOrder"><%=langEditor.getTranslated("backend.ordini.detail.table.label.time")%></span><br><br>
		<%end if%>
		<br><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%></span><br>
		<div id="order_prod_list">
		<table class="prod-list-table" border="0" cellpadding="0" cellspacing="0">
	        <tr> 
			<th width="25">&nbsp;</th>
			<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.nome_prod")%></th>
			<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.prezzo_prod")%></th>
			<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.qta_prod")%></th>
			<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>
			<th width="15">&nbsp;</th>
	        </tr>				  
			<%
			Dim bolHasProdList
			bolHasProdList = false
			
			Dim active
			active = 1
			
			if (id_order <> -1) then	
				'active = 0
				active = null
			end if			
			
			On Error Resume Next
			Set objListaProdotti = objProdotti.findProdotti(null, null, null, null, null, null, null, null, active, order_prod_by, objListaTargetProdTmp, objListaTargetLangTmp, 1, 0)
			if(objListaProdotti.Count > 0) then
				bolHasProdList = true
			end if
			if(Err.number <> 0)then
				bolHasProdList = false
			end if
		
			
			if (bolHasProdList) then	
				Dim intCount, subCounter
				intCount = 0
				
				Dim prodCounter, iIndexProd, objTmpProd, objTmpProdKey
				
				subCounter = 0
				iIndex = objListaProdotti.Count				
				FromProd = ((numPage * itemsXpage) - itemsXpage)
				Diff = (iIndex - ((numPage * itemsXpage)-1))
				if(Diff < 1) then
					Diff = 1
				end if
				
				ToProd = iIndex - Diff
				
				totPages = iIndex\itemsXpage
				if(totPages < 1) then
					totPages = 1
				elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
					totPages = totPages +1	
				end if
				objTmpProd = objListaProdotti.Items	
				
				
				hasOneProdField = false
				hasProdFields=false
				hasListProdField4Order = false
				numCounterProdField4Order = 0
				Set objListF4pNoField = Server.CreateObject("Scripting.Dictionary")

				Dim styleRow, styleRow2
				styleRow2 = "table-list-on"				
					
				for each z in objListaProdotti.Keys
					if(subCounter>=FromProd AND subCounter <= ToProd) then					
						Set objFilteredProd = objListaProdotti(z)
						
						'***** RECUPERO GLI EVENTUALI FIELDS PER PRODOTTO AGGIUNTIVI E LA LISTA DI PRODOTTI PER ORDINE CON LE DIFFERENTI COMBINAZIONI DI ATTRIBUTI
						hasProdFields=false
						hasListProdField4Order = false
						numCounterProdField4Order = 0
						
						On Error Resume Next
						Set objListProdField = objProdField.getListProductField4ProdActive(objFilteredProd.getIDProdotto())
						
						if (Instr(1, typename(objListProdField), "Dictionary", 1) > 0) then
							if(objListProdField.count > 0)then
								hasProdFields=true
								hasOneProdField = true
								
								if (Instr(1, typename(objProdField.findListFieldXOrderByProd(null, id_order, objFilteredProd.getIDProdotto())), "Dictionary", 1) > 0) then
									Set fieldList4Order = objProdField.findListFieldXOrderByProd(null, id_order, objFilteredProd.getIDProdotto())			

									if(fieldList4Order.count > 0)then
										hasListProdField4Order = true
										
										for each l in fieldList4Order
											if(l> numCounterProdField4Order)then
												numCounterProdField4Order = l
											end if
										next
									end if
								end if
								
							end if
						end if
						if(Err.number <> 0) then
							hasProdFields=false
							hasListProdField4Order = false
						end if
						
						Dim bolHasOldProdSelected, numOldProdQta, objTmpOldProds
						bolHasOldProdSelected = false
						numOldProdQta = ""
						
						if(hasObjProdPerOrder) then
							if(objSelProdPerOrder.Exists(z&"|"&numCounterProdField4Order)) then
								bolHasOldProdSelected = true
								Set objTmpOldProds = objSelProdPerOrder(z&"|"&numCounterProdField4Order)
								numOldProdQta = objTmpOldProds.getQtaProdotto()
								Set objTmpOldProds = nothing
							end if
							
							'**** recupero dai prodotti per ordine quelle quei prodotti che hanno dei field associati ma che hanno delle varianti senza field
							'**** se per un prodotto esistono varianti con field assieme a varianti senza field in questo modo posso recuperare le varianti senza field e visualizzarle
							for each r in objSelProdPerOrder
								Set objTmpP4O = objSelProdPerOrder(r)
								
								if(objTmpP4O.getIDProdotto() = objFilteredProd.getIDProdotto())then
									if not(Instr(1, typename(objProdField.findListFieldXOrderByProd(objTmpP4O.getCounterProd(), id_order, objTmpP4O.getIDProdotto())), "Dictionary", 1) > 0)then
										objListF4pNoField.add r, objTmpP4O
										
										if(objTmpP4O.getCounterProd()>numCounterProdField4Order)then
											numCounterProdField4Order = objTmpP4O.getCounterProd()
										end if
									end if
								end if
								
								Set objTmpP4O = nothing
							next
						end if
						
						Dim qtaProdType
						qtaProdType = objFilteredProd.getQtaDisp()
						
						
						styleRow = "table-list-off"
						if(intCount MOD 2 = 0) then styleRow = styleRow2 end if
						%>
						<iframe id="upload_form_lista_<%=intCount%>" name="upload_form_lista_<%=intCount%>" height="0" width="0" frameborder="0" scrolling="yes"></iframe>
						<form action="" method="post" name="form_lista_<%=intCount%>" id="form_lista_<%=intCount%>" enctype="multipart/form-data" target="upload_form_lista_<%=intCount%>">					
						<input type="hidden" name="qta_prodotto_orig" value="<%=qtaProdType%>">
						<input type="hidden" value="<%=objFilteredProd.getIDProdotto()%>" name="selected_prodotto">
						<input type="hidden" id="internal_field_prod_counter<%=intCount%>" name="internal_field_prod_counter" value="<%=numCounterProdField4Order%>">
						<tr class="<%=styleRow%>" id="prod_row_<%=intCount%>">
						<%
						Dim numPrezzoReal
						numPrezzoReal = objFilteredProd.getPrezzo() 
						
						if(hasGroup) then
							On Error Resume Next
							Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
							numPrezzoReal = objSelMargin.getAmount(numPrezzoReal,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objFilteredProd.getsconto()),CDbl(scontoCliente))
							if(Err.number <>0) then
							end if
						else
							if(objFilteredProd.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then 
								numPrezzoReal = objFilteredProd.getPrezzoScontato()
							end if
						end if					
						%>
						<td align="center" class="order-prod-list">
						<%if(bolCanModifyProd AND not(hasProdFields)) then%>
						<input type="checkbox" name="add_prod" onClick="addItemToOrder(document.form_lista_<%=intCount%>, <%=objFilteredProd.getIDProdotto()%>, document.form_lista_<%=intCount%>.qta_prodotto_orig.value, <%=intCount%>);" <%if(bolHasOldProdSelected) then response.write("checked") end if%>>
						<%end if%>
						</td>
						<td nowrap class="order-prod-list"><strong><%=Server.HTMLEncode(objFilteredProd.getNomeProdotto())%></strong></td>
						<td class="order-prod-list">&euro;&nbsp;<%=FormatNumber(numPrezzoReal,2,-1)%><%if(objFilteredProd.hasSconto()) then response.Write("<br/>(" & langEditor.getTranslated("backend.ordini.detail.table.label.sconto") & " " & objFilteredProd.getSconto() & "%)") end if%>
						</td>
						<td class="order-prod-list">
							<div id="qtaProdTxtOldProdQta_<%=intCount%>" align="left" style="text-align:left;float:left;padding-top:3px;visibility:<%if((bolHasOldProdSelected OR not(bolCanModifyProd)) AND not(hasProdFields)) then%>visible<%else%>hidden<%end if%>;"><%=numOldProdQta%></div>
							
							<div id="qtaProdTxt_<%=intCount%>" align="left" style="text-align:left;float:left;visibility:<%if(((bolHasOldProdSelected OR not(bolCanModifyProd)) AND not(hasProdFields))OR (not(bolCanModifyProd) AND hasProdFields)) then%>hidden<%else%>visible<%end if%>;">					
							<%'GESTISCO LA QUANTITA' SELEZIONABILE								
							if(objFilteredProd.getQtaDisp() = Application("unlimited_key") AND objFilteredProd.getAttivo()) then%>
								<input type="text" name="qta_prodotto" id="qta_prodotto_<%=intCount%>" value="<%if not(hasProdFields)then response.write(numOldProdQta) end if%>" class="formFieldTXTQtaProd" onKeyPress="javascript:return isInteger(event);">
							<%else%>
								<%
								if(objFilteredProd.getAttivo())then
									qtaDispOptionNumber = qtaProdType
									if(bolHasOldProdSelected OR not(bolCanModifyProd)) then
										qtaDispOptionNumber = qtaDispOptionNumber+numOldProdQta
									end if%>
									<input type="text" name="qta_prodotto" id="qta_prodotto_<%=intCount%>" value="<%if not(hasProdFields)then response.write(numOldProdQta) end if%>" class="formFieldTXTQtaProd" onKeyPress="javascript:return isInteger(event);" onBlur="javascript:checkMaxQtaProd(<%=qtaDispOptionNumber%>,<%if(numOldProdQta <>"")then response.write(numOldProdQta) else response.write("0") end if%>,this);"><br/><%=langEditor.getTranslated("backend.ordini.detail.table.label.product_disp")&"&nbsp;"&qtaDispOptionNumber%>
							<%end if
							end if%>
							</div>
						</td>
						<td class="order-prod-list">
						<%'***** GESTISCO LA SELEZIONE DEI FIELDS PER PRODOTTO AGGIUNTIVI
						if(hasProdFields AND bolCanModifyProd) then
						
							strCanModifyProd = ""
							labelForm = ""
							addCombinationKey = ""
							
							for each k in objListProdField
								On Error Resume next
								Set objField = objListProdField(k)
								labelForm = objField.getDescription()
								if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&objField.getDescription())

								fieldCssClass=""
								required = "-"
								
								if(objField.getRequired()="1") then required= "+" end if

								addCombinationKey = addCombinationKey & objField.getID() & "|" & Trim(labelForm) & "|" & required  & "|" & objField.getTypeField()  & "#"

								select Case objField.getTypeField()								
								Case 1,2,9
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then
										strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "_"&intCount, objFilteredProd.getIDProdotto(), "",langEditor,1,objField.getEditable()) & "<br/>"								
									else
										strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" & Server.HTMLEncode(objField.getSelValue()) & "<br/>"
									end if
								Case 8
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then%>
										<%strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "_"&intCount, objFilteredProd.getIDProdotto(), "",langEditor,1,objField.getEditable()) & "<br/>"
									else
										strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" & Server.HTMLEncode(objField.getSelValue()) & "<br/>"
									end if							
								Case 3,4,5,6							
									if(CInt(objField.getTypeField())=4) then
										fieldCssClass="formFieldMultiple"
									end if
									strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "_"&intCount, objFilteredProd.getIDProdotto(), "",langEditor,1,objField.getEditable()) & "<br/>"
								Case 7
									strCanModifyProd = strCanModifyProd & objProdField.renderProductFieldHTML(objField,fieldCssClass, "_"&intCount, objFilteredProd.getIDProdotto(), "",langEditor,1,objField.getEditable())
								Case 9
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then%>
										<!--<script>
										/*$.cleditor.defaultOptions.width = 280;
										$.cleditor.defaultOptions.height = 200;
										$.cleditor.defaultOptions.controls = "bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image";			
										*/</script>-->	
										<%strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "_"&intCount, objFilteredProd.getIDProdotto(), "",langEditor,1,objField.getEditable()) & "<br/>"
									else
										strCanModifyProd = strCanModifyProd & "<b>" & labelForm & ":</b>&nbsp;" & Server.HTMLEncode(objField.getSelValue()) & "<br/>"
									end if	
								Case Else
								End Select
			
								Set objField = nothing

								if(Err.number<>0) then
								'response.write(Err.description)
								end if
							next						
							
							addCombinationKey
							if(addCombinationKey > "") then
								addCombinationKey = Left( addCombinationKey, InStrRev( addCombinationKey, "#" ) - 1 )
							end if						
							%>
							
							<div id="fieldProdTxt_<%=intCount%>" style="float:left;visibility:visible;">					
							<%=strCanModifyProd%>
							</div>
							
						<%end if%>
						</td>
						<td class="order-prod-list-r">&nbsp;<%if(hasProdFields AND bolCanModifyProd AND objFilteredProd.getAttivo())then%><a href="javascript:addProductCombination(document.form_lista_<%=intCount%>, <%=objFilteredProd.getIDProdotto()%>, '<%=styleRow%>','<%=Trim(addCombinationKey)%>',<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/add.png"%>" title="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" hspace="5" vspace="0" border="0" align="top"></a><%end if%></td>
						</tr>				
						
						<%if(hasProdFields)then%>
						<tr class="<%=styleRow%>" id="base-order-prod-list-<%=objFilteredProd.getIDProdotto()%>-<%=intCount%>">
						<td colspan="3">&nbsp;</td>
						<td colspan="3" style="text-align:center;">
						<div class="div-order-prod-list-head" align="center">
						<%=langEditor.getTranslated("backend.ordini.detail.table.label.field_prod_list_header")%>
						</div>
						</td>					
						</tr>		
						<%
						end if
						
						if(hasProdFields AND hasListProdField4Order) then
							innerCounter = 1%>					
							<%for each w in fieldList4Order
								Set objTmpField4Order = fieldList4Order(w)
								keys = objTmpField4Order.Keys
								delCombinationKey = ""
								innerCounter = w%>
								<tr class="<%=styleRow%>" id="order-prod-list-<%=objFilteredProd.getIDProdotto()%>-<%=innerCounter%>">
								<td colspan="3">&nbsp;</td>							
								<td colspan="3" align="right">
								<div class="div-order-prod-list" align="right">							
									<div align="right" style="float:left;padding-right:10px;text-align:left;">
									<%							
									labelTmpForm = ""
									hasQtaViewed = false
									for each r in keys
										Set tmpF4O = r
										
										delCombinationKey = delCombinationKey & tmpF4O.getID() & "|" & tmpF4O.getSelValue() & "$"
										
										if not(hasQtaViewed) then
											response.write("<span id=""qta-order-prod-list-"&objFilteredProd.getIDProdotto()&"-"&innerCounter&""">"&"<b>"&langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")&":</b>&nbsp;"&r.getQtaProd()&"<br/></span>")
											hasQtaViewed = true
										end if
										
										labelTmpForm = tmpF4O.getDescription()
										if(Cint(objListProdField(tmpF4O.getID()).getTypeField())<>9)then
											valueTmp = Server.HTMLEncode(tmpF4O.getSelValue())
										else
											valueTmp = tmpF4O.getSelValue()
										end if
										if(Cint(objListProdField(tmpF4O.getID()).getTypeField())=8)then
											valueTmp = "<a href=""" & valueTmp & """ target=_blank>click</a>"
										end if
										if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())
										response.write("<b>"&labelTmpForm & ":</b>&nbsp;" & valueTmp & "<br/>")
									
										Set tmpF4O = nothing
									next
									
									if(delCombinationKey > "") then
										delCombinationKey = Left( delCombinationKey, InStrRev( delCombinationKey, "$" ) - 1 )
										delCombinationKey = w & "|-|" & objFilteredProd.getIDProdotto() & "|-|" & delCombinationKey
									end if
									%>
									</div>	
									<div align="right" style="padding-top:2px;"><%if(bolCanModifyProd)then%><a href="javascript:delProductCombination(document.form_lista_<%=intCount%>, '<%=delCombinationKey%>', 'order-prod-list-<%=objFilteredProd.getIDProdotto()%>-<%=innerCounter%>',<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" hspace="5" vspace="0" border="0"></a><%end if%></div>					
								</div>
								</td>
								</tr>
								<%	
								Set objTmpField4Order = nothing
								innerCounter = innerCounter+1
							next				
							Set fieldList4Order = nothing
							
							'**** se esistono delle varianti per prodotto senza field le aggiungo in coda
							for each y in objListF4pNoField
								Set objTmpProdNoField = objListF4pNoField(y)
								numProdNoFieldQta = objTmpProdNoField.getQtaProdotto()
								counterProdNoField = objTmpProdNoField.getCounterProd()
								if(objTmpProdNoField.getIDProdotto()=objFilteredProd.getIDProdotto()) then
								%>
								<tr class="<%=styleRow%>" id="order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>">
								<td colspan="3">&nbsp;</td>							
								<td colspan="3" align="right">
								<div class="div-order-prod-list" align="right">							
									<div align="right" style="float:left;padding-right:10px;text-align:left;">
									<span id="qta-order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>"><b><%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%>:</b>&nbsp;<%=numProdNoFieldQta%><br/></span>
									<%delCombinationKey = counterProdNoField & "|-|" & objTmpProdNoField.getIDProdotto() & "|-|"%>
									</div>	
									<div align="right" style="padding-top:2px;"><a href="javascript:delProductCombination(document.form_lista_<%=intCount%>, '<%=delCombinationKey%>', 'order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>',<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" hspace="5" vspace="0" border="0"></a></div>					
								</div>
								</td>
								</tr>			
								<%
								end if
								Set objTmpProdNoField = nothing
							next						
							
						elseif(hasProdFields AND not(hasListProdField4Order)) then					
							if(hasObjProdPerOrder) then	
								for each y in objSelProdPerOrder
									Set objTmpProdNoField = objSelProdPerOrder(y)
									if(objTmpProdNoField.getIDProdotto()=objFilteredProd.getIDProdotto())then
										numProdNoFieldQta = objTmpProdNoField.getQtaProdotto()
										counterProdNoField = objTmpProdNoField.getCounterProd()
										%>
										<tr class="<%=styleRow%>" id="order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>">
										<td colspan="3">&nbsp;</td>							
										<td colspan="3" align="right">
										<div class="div-order-prod-list" align="right">							
											<div align="right" style="float:left;padding-right:10px;text-align:left;">
											<span id="qta-order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>"><b><%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%>:</b>&nbsp;<%=numProdNoFieldQta%><br/></span>
											<%delCombinationKey = counterProdNoField & "|-|" & objTmpProdNoField.getIDProdotto() & "|-|"%>
											</div>	
											<div align="right" style="padding-top:2px;"><a href="javascript:delProductCombination(document.form_lista_<%=intCount%>, '<%=delCombinationKey%>', 'order-prod-list-<%=objTmpProdNoField.getIDProdotto()%>-<%=counterProdNoField%>',<%=intCount%>);"><img src="<%=Application("baseroot")&"/editor/img/delete.png"%>" title="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.alt.delete_prod_combination")%>" hspace="5" vspace="0" border="0"></a></div>					
										</div>
										</td>
										</tr>				
										<%
									end if
									Set objTmpProdNoField = nothing
								next
							end if
						end if%>						
						</form>
						<%
						Set objListProdField = nothing	
						Set objFilteredProd = nothing
						
					end if
					intCount = intCount +1
					subCounter = subCounter +1
				next%>
				
				<form name="prod_list_size" method="post" action="">
				<input type="hidden" name="size" value="<%=intCount%>">
				</form>
				<%
				Set objListF4pNoField = nothing
				Set objListaProdotti = nothing%>
			<form action="<%=Application("baseroot") & "/editor/ordini/inserisciordine2.asp"%>" method="post" name="item_x_page">
			<input type="hidden" value="<%=id_order%>" name="id_ordine">
			  <input type="hidden" value="<%=request("strGerarchiaTmp")%>" name="strGerarchiaTmp">
			  <input type="hidden" value="<%=request("target_cat")%>" name="target_cat">		
			  <tr> 
				<th colspan="6" align="left">
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onBlur="javascript:submit();" onKeyPress="javascript:return isInteger(event);">
				<%		
				'**************** richiamo paginazione
				if(hasOneProdField)then jsPagParam =1 else jsPagParam =0 end if 
				call PaginazioneOrderProd(totPages, numPage, jsPagParam)%>
			</th>	
			</tr>		
			</form>
			<%else%>
			<tr class="table-list-off">
			<td colspan="6" align="center"><strong><%=langEditor.getTranslated("backend.ordini.detail.table.label.no_product_disp")%></strong></td>
			</tr>
			<%end if

			Set objSelMargin = nothing				
			Set objProdField = nothing
			Set objGroup =nothing
			Set objSelProdPerOrder = nothing
			Set objSelOrder = Nothing%>
		</table>
		</div>

		<%'FINE: *******************************************************%>
		</td>
		</tr>	
		</table>
		
		<form action="<%=Application("baseroot") & "/editor/ordini/ProcessOrdine2.asp"%>" method="post" name="form_inserisci" enctype="multipart/form-data">
		  <input type="hidden" value="<%=id_order%>" name="id_ordine">		
		  <input type="hidden" value="" name="complete_selected_prod_list"> 
		  <input type="hidden" value="1" name="order_modified"> 	
		  <input type="hidden" value="<%=numPage%>" name="page" id="ins_page_num"> 
		  <input type="hidden" value="<%=request("strGerarchiaTmp")%>" name="strGerarchiaTmp">
		  <input type="hidden" value="<%=request("target_cat")%>" name="target_cat">
		  <input type="hidden" value="<%=itemsXpage%>" name="items">  	
		  <input type="hidden" value="0" name="come_from_pagination" id="ins_come_from_pagination"> 		
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.detail.button.prosegui.label")%>" onClick="javascript:sendForm(<%if(hasOneProdField)then response.write("1") else response.write("0")%>);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onClick="javascript:location.href='<%=Application("baseroot")&"/editor/ordini/ListaOrdini.asp?cssClass=LO"%>';" />
		</form>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>