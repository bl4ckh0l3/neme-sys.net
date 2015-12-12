<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init1.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="content-language" content="<%=LCase(lang.getLangCode())%>">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%>
<script language="JavaScript">
field4prodRequired = new Hashtable();

<%
'*********** recupero la lista di field abilitati e imposto in una mappa quelli obbligatori
'*********** per fare i controlli prima dell'invio del form

On Error Resume Next
Set objListField = objProdField.getListProductField(1)

for each k in objListField
	Set objF = objListField(k)
	if(objF.getRequired()=1)then
		if not(lang.getTranslated("portal.commons.product_field.js.alert.insert_"&objF.getDescription()) = "") then
			response.write("field4prodRequired.put('productfield"&objF.getID()&"','"&lang.getTranslated("portal.commons.product_field.js.alert.insert_"&objF.getDescription())&"');")	
		else
			response.write("field4prodRequired.put('productfield"&objF.getID()&"','"&objF.getDescription()&"');")	
		end if  
	end if
	Set objF = nothing
next

Set objListField = nothing
if(Err.number <> 0) then
end if

bolEcommerceEnabled = false
if(Application("disable_ecommerce") = 0) OR (Application("disable_ecommerce") = 1) then
	bolEcommerceEnabled = true
end if
%>

var formSent = false;
function addToCarrello(theFrom,counter){	
	var sel_qta = theFrom.qta_prodotto.value;
	if(sel_qta == ""){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.select_qta_prod")%>");
		return;
	}else if(isNaN(sel_qta)){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.qta_prodotto.value = "";
		return;
	}else if(sel_qta.indexOf('.') != -1){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.qta_prodotto.value = "";
		return;
	}
	
	var hasfield4prod = false;
	var query_string = "id_prod="+theFrom.id_prodotto.value;
	var arrKeys = field4prodRequired.keys();	
	for(var z=0; z<arrKeys.length; z++){
		tmpKey = arrKeys[z];
		tmpValue = field4prodRequired.get(tmpKey);
		tmpFieldName = eval("document."+theFrom.name+".<%=objProdField.getFieldPrefix()%>"+counter+tmpKey.substring(12));
  
		if(tmpFieldName != undefined){
			if(tmpFieldName.value.length==0){
				alert('<%=lang.getTranslated("frontend.template_prodotto.js.alert.insert_value_for_field")%> '+tmpValue);
				return;		
			}
			hasfield4prod = true;
			query_string+="&"+tmpKey.substring(12)+"="+escape(tmpFieldName.value);			
		}		
	}
	
	//integro chiamata ajax per verificare disponibilit� combinazione field prodotto
	if(hasfield4prod){
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
		final_qta = ajaxCheckQta4X(theFrom.name, theFrom.id_prodotto.value, sel_qta, counter, 0, 0);
		query_string+="&qta_prodotto="+final_qta;
		//alert("query_string 2: "+query_string);

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
			$("#addtocardloadingimg"+counter).hide();
			$("#addtocardloading"+counter).show();
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
			return;
		}
	}
	
	if(formSent == false){
		formSent = true;
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function changeCurrency(){
	document.change_currency.submit();
}

function changeOrder(){
	document.change_order.submit();
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

function ajaxCheckQta4X(theForm, id_prod, qta_prod, counter, x, method){
	var query_string = "id_prod="+id_prod+"&prod_counter="+counter+"&qta_prod="+qta_prod;
  
 
  $(':input', '#'+theForm).each(function() {     
    query_string += "&"+this.name+"="+escape(this.value);
  }); 
  
	//alert("query_string: "+query_string);
	<%
	' recupero url corrente per definire path a ajaxcheckprodqta.asp
	tmpurl = request.ServerVariables("URL")
	tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
	%>
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=tmpurl&"ajaxcheckprodqta.asp"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("response: "+response);
			return;
		},
		error: function(response) {
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=langEditor.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = response;
		}
	});
  
  	var final_qta = Number(qta_prod)+Number(resp);
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
		objForm.qta_prodotto.value="";  
		return;	
	}
}

function ajaxCheckFieldAvailability(query_string){
	<%
	' recupero url corrente per definire path a ajaxcheckprodavailability.asp
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
  
function openDetailProdPage(strAction, strGerarchia, numIdProd, numPageNum){
    document.form_detail_link_prod.action=strAction;
    document.form_detail_link_prod.gerarchia.value=strGerarchia;
    document.form_detail_link_prod.id_prodotto.value=numIdProd;
    document.form_detail_link_prod.modelPageNum.value=numPageNum;
    document.form_detail_link_prod.submit();
}
</SCRIPT>
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
		<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">
			<!-- #include virtual="/public/layout/include/menutips.inc" -->
			
			<!-- **********************************  START: CODICE PER LA GESTIONE LISTA PRODOTTI ********************************** -->
			<%
			if(bolHasObj) then%>
				<div id="content-center-prodotto">
				<div align="left" style="padding-top:0px;<%if(bolEcommerceEnabled)then response.write("float:left;") end if%>">
				<form name="change_order" method="post" action="<%=request.ServerVariables("URL")%>">
				<input type="hidden" value="<%=strGerarchia%>" name="gerarchia">	
				<input type="hidden" value="<%=numPage%>" name="page">
				<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">				
				<span class="prodotto_select_label"><%=lang.getTranslated("frontend.template_prodotto.order.label")%></span>&nbsp;<select class="prodotto_select" name="order_by" onchange="javascript:changeOrder();">
				<option value=""></option>
				<option value="103" <%if(order_by = "103") then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_name_asc")%></option>
				<option value="104" <%if(order_by = "104") then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_name_desc")%></option>
				<option value="105" <%if(order_by = "105") then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_price_asc")%></option>
				<option value="106" <%if(order_by = "106") then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_price_desc")%></option>
				</select>
				</form>
				</div>
				<%if(bolEcommerceEnabled) then%>
					<div>
					<form name="change_currency" method="post" action="<%=request.ServerVariables("URL")%>">
					<input type="hidden" value="<%=strGerarchia%>" name="gerarchia">	
					<input type="hidden" value="<%=numPage%>" name="page">
					<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">
					<input type="hidden" value="<%=order_by%>" name="order_by">
					<%On Error Resume Next
					Set currencyList = currClass.getListaCurrency(null, 1, null)'%>
					&nbsp;|&nbsp;<span class="prodotto_select_label"><%=lang.getTranslated("frontend.template.currency.label")%></span>&nbsp;<select class="prodotto_select" name="currency" onchange="javascript:changeCurrency();">
					<option value=""></option>
					<%for each x in currencyList%>
						<option value="<%=currencyList(x).getCurrency()%>" <%if(currencyList(x).getCurrency() = Session("currency")) then response.write("selected") end if%>><%=currencyList(x).getCurrency()%> (<%=lang.getTranslated("backend.currency.keyword.label."&currencyList(x).getCurrency())%>)</option>
					<%next%>
					</select>
					<%
					Set currencyList = nothing
					if(Err.number <> 0) then 
					end if%>
					</form>
					</div>
				<%end if%>
				<br/><br/>
				<%
				Set objTasse = new TaxsClass
				for ProdottoCounter = FromProdotto to ToProdotto
					Set objSelProdotto = objTmpProdotto(ProdottoCounter)
					Set objListaFile = New File4ProductsClass
					detailURL = "#"
					if(bolHasDetailLink) then
						detailURL = objMenuFruizione.resolveHrefUrl(base_url, (modelPageNum+1), lang, objCategoriaTmp, objTemplateSelected, objPageTempl)
					end if
					%>
					<div>
					<form action="<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ManageCarrello.asp"%>" method="post" name="form_add_to_carrello_<%=ProdottoCounter%>" id="form_add_to_carrello_<%=ProdottoCounter%>" enctype="multipart/form-data"><!--  onSubmit="return addToCarrello(document.form_add_to_carrello_<%=ProdottoCounter%>,<%=ProdottoCounter%>);" -->	
					<input type="hidden" value="<%=objSelProdotto.getIDProdotto()%>" name="id_prodotto">
					<input type="hidden" value="add" name="operation">						
					<input type="hidden" value="<%=ProdottoCounter%>" name="form_counter">
					<input type="hidden" value="<%=objSelProdotto.getProdType()%>" name="prod_type">	
					<div id="prodotto-immagine">
					<%if not(isNull(objListaFile.getFilePerProdotto(objSelProdotto.getIDProdotto()))) AND not(isEmpty(objListaFile.getFilePerProdotto(objSelProdotto.getIDProdotto()))) then%>
						<%Dim hasNotSmallImg
						hasNotSmallImg = true
						Set objListaFilePerProdotto = objListaFile.getFilePerProdotto(objSelProdotto.getIDProdotto())					
						for each xObjFile in objListaFilePerProdotto
							Set objFileXProdotto = objListaFilePerProdotto(xObjFile)
							iTypeFile = objFileXProdotto.getFileTypeLabel()
							if(Cint(iTypeFile) = 1) then%>	
								<img src="<%=Application("dir_upload_prod")&objFileXProdotto.getFilePath()%>" alt="<%=objSelProdotto.getNomeProdotto()%>" width="140" height="130" />
								<%hasNotSmallImg = false
								Exit for
							end if
							Set objFileXProdotto = nothing	
						next		
						if(hasNotSmallImg) then%>
							<img width="140" height="130" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
						<%end if
						Set objListaFilePerProdotto = nothing
					else%>
						<img width="140" height="130" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
					<%end if%>
					</div>				
					<div id="prodotto-testo">					
					<h2><a href="javascript:openDetailProdPage('<%=detailURL%>', '<%=strGerarchia%>', <%=objSelProdotto.getIDProdotto()%>, <%=(modelPageNum+1)%>);"><%=objSelProdotto.findFieldTranslation(1 ,lang.getLangCode(),1)%></a></h2>
					<p><%=objSelProdotto.findFieldTranslation(2 ,lang.getLangCode(),1)%></p>
					
					<%if(bolEcommerceEnabled) then%>
						<p>
						<%           
						Dim numPrezzoReal, descTassa, numPrezzoOld
						numPrezzoReal = objSelProdotto.getPrezzo() 
						numPrezzoOld = numPrezzoReal 
						discountPercent = 0

						if(hasGroup) then
							On Error Resume Next
							discountPercent = objSelMargin.getDiscountPercentual(CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objSelProdotto.getsconto()),CDbl(scontoCliente))
							numPrezzoReal = objSelMargin.getAmount(numPrezzoReal,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objSelProdotto.getsconto()),CDbl(scontoCliente))
							if(Err.number <>0) then
							end if
						else
							if(objSelProdotto.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then
								numPrezzoReal = objSelProdotto.getPrezzoScontato()
								discountPercent = CDbl(objSelProdotto.getsconto())
								if(hasSconto)then
									numPrezzoReal = numPrezzoReal - (numPrezzoReal / 100 * scontoCliente)
									discountPercent = discountPercent+CDbl(scontoCliente)
								end if
							else
								if(hasSconto)then
									numPrezzoReal = numPrezzoReal - (numPrezzoReal / 100 * scontoCliente)
									discountPercent = CDbl(scontoCliente)
								end if
							end if
						end if%>

						<input type="hidden" value="<%=numPrezzoReal%>" name="prezzo">
						<%

						'***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
						descTassa = ""
						applyOrigTax = true
						if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
							if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
								On Error Resume Next
								' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
								if(Cint(userIsCompanyClient)=1 AND groupClienteTax.isTaxExclusion(groupClienteTax.getID(), international_country_code,international_state_region_code))then
									descTassa = lang.getTranslated("frontend.prodotti.label.tax_excluded")							
									applyOrigTax = false
								else
									objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
									if(not(isNull(objRelatedTax))) then
										Set objTaxG = objTasse.findTassaByID(objRelatedTax)
										numPrezzoReal = numPrezzoReal+groupClienteTax.getImportoTassa(numPrezzoReal, objTaxG)
										numPrezzoOld = numPrezzoOld+groupClienteTax.getImportoTassa(numPrezzoOld, objTaxG)
										descTassa = objTaxG.getDescrizioneTassa()
										Set objTaxG = nothing
										applyOrigTax = false
									else
										applyOrigTax = true		
									end if
								end if                
								if(Err.number<>0)then
									applyOrigTax = true
								end if	
							else
								On Error Resume Next
								Set groupProdTax = objSelProdotto.getTaxGroupObj(objSelProdotto.getTaxGroup()) 
								if(Instr(1, typename(groupProdTax), "TaxsGroupClass", 1) > 0) then
									' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
									if(Cint(userIsCompanyClient)=1 AND groupProdTax.isTaxExclusion(groupProdTax.getID(), international_country_code,international_state_region_code))then
										descTassa = lang.getTranslated("frontend.prodotti.label.tax_excluded")							
										applyOrigTax = false
									else	
										objRelatedTax = groupProdTax.findRelatedTax(groupProdTax.getID(), international_country_code,international_state_region_code)			  
										if(not(isNull(objRelatedTax))) then
											Set objTaxG = objTasse.findTassaByID(objRelatedTax)
											numPrezzoReal = numPrezzoReal+groupProdTax.getImportoTassa(numPrezzoReal, objTaxG)
											numPrezzoOld = numPrezzoOld+groupProdTax.getImportoTassa(numPrezzoOld, objTaxG)
											descTassa = objTaxG.getDescrizioneTassa()
											Set objTaxG = nothing
											applyOrigTax = false		
										end if
									end if                  
								else
									applyOrigTax = true
								end if
								Set groupProdTax = nothing
								if(Err.number<>0)then
									applyOrigTax = true
								end if
							end if
						end if
						if(applyOrigTax)then
							descTassa = ""
							if not(isNull(objSelProdotto.getIDTassaApplicata())) AND not(objSelProdotto.getIDTassaApplicata() = "") then
								numPrezzoReal = numPrezzoReal+objSelProdotto.getImportoTassa(numPrezzoReal)
								numPrezzoOld = numPrezzoOld+objSelProdotto.getImportoTassa(numPrezzoOld)
								descTassa = objTasse.findTassaByID(objSelProdotto.getIDTassaApplicata()).getDescrizioneTassa()
							end if
						end if

						  if not(lang.getTranslated("portal.commons.order_taxs.label."&descTassa)="") then
							  descTassa = lang.getTranslated("portal.commons.order_taxs.label."&descTassa) 
						  end if

						if(descTassa<>"") then descTassa = "&nbsp;&nbsp;("&descTassa&")" end if   


						'************ converto il prezzo in base alla valuta selezionata
						if not(defCurrObj="") AND not(thisCurrObj="") then
							numPrezzoOld = currClass.convertCurrency(numPrezzoOld, defCurrObj, thisCurrObj)
							numPrezzoReal = currClass.convertCurrency(numPrezzoReal, defCurrObj, thisCurrObj)
						end if
						%>

						<%if(discountPercent > 0) then%><span class="testoBarrato"><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoOld, 2,-1)&descTassa%></span> --><%end if%>&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoReal, 2,-1)&descTassa%>
						<%if(discountPercent > 0) then response.Write("<br><br>" & lang.getTranslated("frontend.template_prodotto.table.label.sconto") & " " & discountPercent & "%") end if%>
						<%if(objSelProdotto.getAttivo() = 0) then response.Write("<br><br>" & lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")) end if%>

						<%
						On Error Resume Next
						hasProdFields=false

						Set objListProdField = objProdField.getListProductField4ProdActive(objSelProdotto.getIDProdotto())

						if(objListProdField.Count > 0)then
							hasProdFields = true
						end if

						if(Err.number <> 0) then
							hasProdFields = false
						end if	

						if(hasProdFields)then
							tmpGroupDesc = ""	
							tmpGroupDescTrans = ""	

							response.write("<p>")

							for each k in objListProdField
								On Error Resume next
								Set objField = objListProdField(k)

								labelForm = objField.getDescription()
								if not(lang.getTranslated("frontend.prodotto.field.label."&objField.getDescription())="") then labelForm = lang.getTranslated("frontend.prodotto.field.label."&objField.getDescription())

								'*** imposto la descrizione per il gruppo di appartenenza
								if(strComp(typename(objField.getObjGroup()), "ProductFieldGroupClass") = 0)then
									tmpDescG = objField.getObjGroup().getDescription()
									if(tmpDescG <> tmpGroupDesc)then
										tmpGroupDesc = tmpDescG
										tmpGroupDescTrans = tmpGroupDesc
										if not(lang.getTranslated("frontend.prodotto.field.label.group."&tmpGroupDesc)="") then tmpGroupDescTrans = lang.getTranslated("frontend.prodotto.field.label.group."&tmpGroupDesc)

										labelForm = "<div class=""prodotto_field_prod_group"">"& tmpGroupDescTrans & "</div>" & labelForm
									end if
								end if

								fieldCssClass=""

								select Case objField.getTypeField()								
								Case 1,2
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then
										response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, ProdottoCounter, objSelProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
									<%
									else
										valueTmp = objField.getSelValue()
										response.write(labelForm & ":&nbsp;" & valueTmp & "<br/>")
									end if
								Case 3,4,5,6							
									if(CInt(objField.getTypeField())=4) then
										fieldCssClass="formFieldMultiple"
									end if
									response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, ProdottoCounter, objSelProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")
								Case 7
									fieldValueMatch = objProdField.findFieldMatchValue(k,objSelProdotto.getIDProdotto())
									response.write(objProdField.renderProductFieldHTML(objField,fieldCssClass, ProdottoCounter, objSelProdotto.getIDProdotto(), fieldValueMatch,lang,1,objField.getEditable()))
								Case 8									
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then
										response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, ProdottoCounter, objSelProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
									<%
									else
										valueTmp = objField.getSelValue()
										response.write(labelForm & ":&nbsp;" & valueTmp & "<br/>")
									end if
								Case 9
									fieldCssClass="formFieldTXTMedium"
									if(objField.getEditable()="1")then%>
										<script>
										//declare cleditor option array;
										var cloptions<%=objProdField.getFieldPrefix()&ProdottoCounter&objField.getID()%> = {
										width:280,	// width not including margins, borders or padding
										height:200,	// height not including margins, borders or padding
										controls:"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image",	// controls to add to the toolbar
										}
										</script>	
										<%response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, ProdottoCounter, objSelProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
										<%
									else
										valueTmp = Server.HTMLEncode(objField.getSelValue())
										response.write(labelForm & ":&nbsp;" & valueTmp & "<br/>")
									end if                  
								Case Else
								End Select

								Set objField = nothing

								if(Err.number<>0) then
									'response.write(Err.description)
								end if
							next

							response.write("</p>")						

							Set objListProdField = nothing
						end if				
						%>
						</p>
					<%end if%>
					</div>
					<div id="clear"></div>
					<div id="prodotto-footer">
					<%if(Application("disable_ecommerce") = 0) then%>
						<%'GESTISCO LA QUANTITA' SELEZIONABILE					
							if(objSelProdotto.getQtaDisp() = Application("unlimited_key")) then
								if(objSelProdotto.getEditBuyQta()=1) then	%>
									<input type="text" name="qta_prodotto" value="" onkeypress="javascript:return isInteger(event);" class="formFieldTXTShort">
									<!--<input type="text" name="qta_prodotto" value="" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkQta6Multiple(this);" class="formFieldTXTShort">-->
								<%else%>
									<input type="hidden" name="qta_prodotto" value="1">
								<%end if
							else
								if(objSelProdotto.getEditBuyQta()=1) then	%>
									<input type="text" name="qta_prodotto" id="qta_prodotto" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%=objSelProdotto.getQtaDisp()%>,this);">
									<!--<input type="text" name="qta_prodotto" id="qta_prodotto" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%'=objSelProdotto.getQtaDisp()%>,this),checkQta6Multiple(this);">-->		
								<%else%>
									<input type="hidden" name="qta_prodotto" value="1">
								<%end if%>
								&nbsp;<%=lang.getTranslated("frontend.template_prodotto.table.label.product_disp")&"&nbsp;"&objSelProdotto.getQtaDisp()%>&nbsp;&nbsp;
							<%end if

						if(objSelProdotto.getAttivo() = 1) then%>
							<span style="display:none;" id="addtocardloadingimg<%=ProdottoCounter%>"><img src="<%=Application("baseroot") & "/common/img/loading_icon.gif"%>" border="0" width="16" height="16" hspace="0" vspace="0"></span>
							<span id="addtocardloading<%=ProdottoCounter%>"><a href="javascript:addToCarrello(document.form_add_to_carrello_<%=ProdottoCounter%>,<%=ProdottoCounter%>);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="<%=Application("baseroot")&"/common/img/cart_add.png"%>" width="16" height="16" hspace="0" vspace="0" border="0"><%=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%></a></span>
							<!--<a href="javascript:ajaxCheckQta4X('form_add_to_carrello_<%'=ProdottoCounter%>', document.form_add_to_carrello_<%'=ProdottoCounter%>.id_prodotto.value, document.form_add_to_carrello_<%'=ProdottoCounter%>.qta_prodotto.value, <%'=ProdottoCounter%>, 6, 0),addToCarrello(document.form_add_to_carrello_<%'=ProdottoCounter%>,<%'=ProdottoCounter%>);" title="<%'=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="<%'=Application("baseroot")&"/common/img/cart_add.png"%>" width="16" height="16" hspace="0" vspace="0" border="0"><%'=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%></a>-->
						<%else%>
							<img src="<%=Application("baseroot")&"/common/img/ico-carrello.png"%>" hspace="0" vspace="0" border="0" width="16" height="16" alt="<%=lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")%>"><br><br>
						<%end if%>	
					<%end if%>
					<%if(not(isNull(objCommento.findCommentiByIDElement(objSelProdotto.getIDProdotto(),2,1)))) AND (Instr(1, typename(objCommento.findCommentiByIDElement(objSelProdotto.getIDProdotto(),2,1)), "dictionary", 1) > 0) then%>
						&nbsp;|&nbsp;<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupComments.asp?id_element="&objSelProdotto.getIDProdotto()&"&element_type=2&active=1"%>','popupallegati',400,400,100,100);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.see_comments")%>"><img src="<%=Application("baseroot")&"/common/img/ico-commenti.png"%>" hspace="0" vspace="0" width="16" height="16" border="0"><%=lang.getTranslated("frontend.template_prodotto.label.see_comments")%></a>
					<%end if%>
					</div>					    
					</form>
					<%Set objSelProdotto = nothing%>
					</div>
				<%next				
				Set objTasse = nothing
				Set objTemplateSelected = nothing
				Set objCategoriaTmp = nothing%>
				<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "order_by="&order_by&"&modelPageNum="&modelPageNum) end if%></div>
				</div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>		
			<!-- **********************************  END: CODICE PER LA GESTIONE LISTA PRODOTTI ********************************** -->
			
			  <form action="" method="post" name="form_detail_link_prod">	
			  <input type="hidden" value="" name="id_prodotto">	
			  <input type="hidden" value="" name="modelPageNum">	
			  <input type="hidden" value="" name="gerarchia">	
			  <input type="hidden" value="<%=numPage%>" name="page">
			  <input type="hidden" value="<%=order_by%>" name="order_by">            
			  </form>			
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set objCat = nothing
Set objPageTempl = nothing
Set objTemplate = nothing
Set objMenuFruizione = nothing
Set objProdField = nothing
Set objProdFieldGroup = nothing
Set currClass = nothing
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaProdotto = nothing
Set Prodotto = Nothing
%>
