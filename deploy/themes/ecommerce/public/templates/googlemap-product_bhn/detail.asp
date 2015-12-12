<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include file="include/init2.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<SCRIPT SRC="<%=Application("baseroot") & "/common/js/hashtable.js"%>"></SCRIPT>
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%>
<script language="Javascript">
var mapid = "map";
var latlng = new Array();
var infowin = new Array();
<%if(objListPoint.count>0)then
	for each k in objListPoint
		//response.write("//getLatitude: "&k.getLatitude()&" -getLongitude: "&k.getLongitude())
		if(k.getLatitude()<>"" AND k.getLongitude()<>"")then%>
			latlng.push(new GLatLng(replaceCommaInNumber('<%=k.getLatitude()%>'), replaceCommaInNumber('<%=k.getLongitude()%>')));
			infowin.push("<%=objListPoint(k)%>");
		<%end if
	next%>
<%end if%>

function showMap(mapid){
	if (GBrowserIsCompatible()) {
		$('#'+mapid).show();		
		var map = new GMap2(document.getElementById(mapid));	
		map.setCenter(new GLatLng(0, 0), 2);
		map.addControl(new GLargeMapControl());	
		var latlngbounds = new GLatLngBounds( );

		if(latlng.length==1){
			map.setCenter(latlng[0],10);
		}else{
			for (var j=0; j<latlng.length; j++){
				latlngbounds.extend(latlng[j]);
			}
			map.setCenter(latlngbounds.getCenter(), map.getBoundsZoomLevel(latlngbounds));
		}

		for (var j=0; j<latlng.length; j++){
			//alert("lat: "+latlng[j].lat()+" -lng: "+latlng[j].lng());
			var infowintxt = infowin[j];
			//alert("infowin: "+infowintxt);
			var marker = createMarker(latlng[j], infowintxt);
			map.addOverlay(marker);
		}
	} 
}

function createMarker(point,html) {
  var marker = new GMarker(point);
  GEvent.addListener(marker, "click", function() {
    marker.openInfoWindowHtml(html);
  });
  return marker;
}
	
jQuery(document).ready(function(){
	<%if(objListPoint.count>0)then%>
		showMap(mapid);
	<%end if%>
});

function replaceCommaInNumber(number){
	return number.replace(',','.');
}
</script>  
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
function addToCarrello(theFrom){
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
    tmpFieldName = eval("document."+theFrom.name+"."+tmpKey);
  
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
		$("#addtocardloading").hide();
		$("#addtocardloadingimg").show();
		final_qta = ajaxCheckQta4X(theFrom.name, theFrom.id_prodotto.value, sel_qta, "", 0, 0);
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
			$("#addtocardloadingimg").hide();
			$("#addtocardloading").show();
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
			return;
		}
	}
	
	if(formSent == false){
		formSent = true;
		$("#addtocardloading").hide();
		$("#addtocardloadingimg").show();
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function changeCurrency(){
	document.change_currency.submit();
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
  
function openRelatedProdPage(strAction, strGerarchia, numIdProd, numPageNum){
    document.form_detail_rel_prod.action=strAction;
    document.form_detail_rel_prod.gerarchia.value=strGerarchia;
    document.form_detail_rel_prod.id_prodotto.value=numIdProd;
    document.form_detail_rel_prod.modelPageNum.value=numPageNum;
    document.form_detail_rel_prod.submit();
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
			
			<!-- **********************************  START: CODICE PER LA GESTIONE DETTAGLIO PRODOTTI ********************************** -->
			<div id="torna" style="padding-top:7px;<%if(bolEcommerceEnabled)then response.write("float:left;") end if%>">
			<form name="go_back" method="post" action="<%=backUrl%>">
			<input type="hidden" value="<%=strGerarchia%>" name="gerarchia">	
			<input type="hidden" value="<%=numPage%>" name="page">
			<input type="hidden" value="<%=order_by%>" name="order_by">
			<a href="javascript:document.go_back.submit();"><%=lang.getTranslated("frontend.template_prodotto.table.label.back_to_list")%></a>
			</form>
			</div>
			<%if(bolEcommerceEnabled) then%>
				<div>
				<form name="change_currency" method="post" action="<%=request.ServerVariables("URL")%>">
				<input type="hidden" value="<%=strGerarchia%>" name="gerarchia">	
				<input type="hidden" value="<%=numPage%>" name="page">
				<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">
				<input type="hidden" value="<%=id_prodotto%>" name="id_prodotto">
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
				'response.write(Err.description) 
				end if%>
				</form>
				</div>
			<%end if%>
				<%    
				response.Write("<h1><br/>"&objCurrentProdotto.findFieldTranslation(1 ,lang.getLangCode(),1) & "</h1>")%>				
				<div style="float:right;width:300px;height:250px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;margin-left:3px;" id="map">
				</div>
				<%response.Write("<p>"&objCurrentProdotto.findFieldTranslation(3 ,lang.getLangCode(),1) & "</p>")%>		
		    
			<form action="<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ManageCarrello.asp"%>" method="post" name="form_add_to_carrello" id="form_add_to_carrello" enctype="multipart/form-data">		    
		    <%if(bolEcommerceEnabled) then%>
		    <%		
				Dim numPrezzoReal, numPrezzoOld
				numPrezzoReal = objCurrentProdotto.getPrezzo() 
		    numPrezzoOld = numPrezzoReal 
		    discountPercent = 0
			    
		    if(hasGroup) then
		      On Error Resume Next
		      discountPercent = objSelMargin.getDiscountPercentual(CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objCurrentProdotto.getsconto()),CDbl(scontoCliente))
		      numPrezzoReal = objSelMargin.getAmount(numPrezzoReal,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objCurrentProdotto.getsconto()),CDbl(scontoCliente))
		      if(Err.number <>0) then
		      end if
		    else
		      if(objCurrentProdotto.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then
			numPrezzoReal = objCurrentProdotto.getPrezzoScontato()
			discountPercent = CDbl(objCurrentProdotto.getsconto())
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
		    
		    Set objTasse = new TaxsClass
		    
		    
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
			Set groupProdTax = objCurrentProdotto.getTaxGroupObj(objCurrentProdotto.getTaxGroup()) 
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
		      if not(isNull(objCurrentProdotto.getIDTassaApplicata())) AND not(objCurrentProdotto.getIDTassaApplicata() = "") then
			numPrezzoReal = numPrezzoReal+objCurrentProdotto.getImportoTassa(numPrezzoReal)
			numPrezzoOld = numPrezzoOld+objCurrentProdotto.getImportoTassa(numPrezzoOld)
			descTassa = objTasse.findTassaByID(objCurrentProdotto.getIDTassaApplicata()).getDescrizioneTassa()
		      end if
		    end if

		  if not(lang.getTranslated("portal.commons.order_taxs.label."&descTassa)="") then
			  descTassa = lang.getTranslated("portal.commons.order_taxs.label."&descTassa) 
		  end if
		    
		    if(descTassa<>"") then descTassa = "&nbsp;&nbsp;("&descTassa&")" end if       
		    
		    
				Set objTasse = nothing   
		    
		    
				'************ converto il prezzo in base alla valuta selezionata
				if not(defCurrObj="") AND not(thisCurrObj="") then
					numPrezzoOld = currClass.convertCurrency(numPrezzoOld, defCurrObj, thisCurrObj)
					numPrezzoReal = currClass.convertCurrency(numPrezzoReal, defCurrObj, thisCurrObj)
				end if
		    %>
		    <h3>
				<%if(discountPercent > 0) then%><span class="testoBarrato"><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoOld, 2,-1)&descTassa%></span><br/><%end if%>
				<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoReal, 2,-1) &descTassa & "</h3>"%>
				<%if(discountPercent > 0) then response.Write("<h3><strong>"&lang.getTranslated("frontend.template_prodotto.table.label.sconto") & " " & discountPercent & "%</strong></h3>") end if%>		
				<%if(objCurrentProdotto.getAttivo() = 0) then response.Write("<h3>"&lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile") & "</h3>") end if%>
				<input type="hidden" value="<%=objCurrentProdotto.getIDProdotto()%>" name="id_prodotto">
				<input type="hidden" value="add" name="operation">
				<input type="hidden" value="<%=objCurrentProdotto.getProdType()%>" name="prod_type">	
		    
				<%
				On Error Resume Next
				hasProdFields=false
				
				Set objListProdField = objProdField.getListProductField4ProdActive(objCurrentProdotto.getIDProdotto())
				
				if(objListProdField.Count > 0)then
					hasProdFields = true
				end if
				
				if(Err.number <> 0) then
					hasProdFields = false
				end if	
				
				if(hasProdFields)then	
					
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
								response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "", objCurrentProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
							<%
							else
								valueTmp = objField.getSelValue()
								response.write(labelForm & ":&nbsp;" & valueTmp & "<br/>")
							end if			
						Case 3,4,5,6						
							if(CInt(objField.getTypeField())=4) then
								fieldCssClass="formFieldMultiple"
							end if
							response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "", objCurrentProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")
			Case 7
			  fieldValueMatch = objProdField.findFieldMatchValue(k,objCurrentProdotto.getIDProdotto())
			  response.write(objProdField.renderProductFieldHTML(objField,fieldCssClass, "", objCurrentProdotto.getIDProdotto(), fieldValueMatch,lang,1,objField.getEditable()))
						Case 8
							fieldCssClass="formFieldTXTMedium"
							if(objField.getEditable()="1")then
								response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "", objCurrentProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
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
			    var cloptions<%=objProdField.getFieldPrefix()&objField.getID()%> = {
			    width:280,	// width not including margins, borders or padding
			    height:200,	// height not including margins, borders or padding
			    controls:"bold italic underline strikethrough subscript superscript | font size style | color highlight removeformat | bullets numbering | alignleft center alignright justify | rule | cut copy paste | image",	// controls to add to the toolbar
			    }
								</script>
								<%response.write(labelForm & ":&nbsp;" &objProdField.renderProductFieldHTML(objField,fieldCssClass, "", objCurrentProdotto.getIDProdotto(), "",lang,1,objField.getEditable()) & "<br/>")%>
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
			end if
		%>
		    
				<%if(not(isNull(objCommento.findCommentiByIDElement(objCurrentProdotto.getIDProdotto(),2,1)))) AND (Instr(1, typename(objCommento.findCommentiByIDElement(objCurrentProdotto.getIDProdotto(),2,1)), "dictionary", 1) > 0) then%>
				<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupComments.asp?id_element="&objCurrentProdotto.getIDProdotto()&"&element_type=2&active=1"%>','popupallegati',400,400,100,100);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.see_comments")%>"><img src="<%=Application("baseroot")&"/common/img/ico-commenti.png"%>" hspace="0" vspace="0" border="0"></a>
				<%end if%>
				
				<%if(Application("disable_ecommerce") = 0) then%>
					<%if(objCurrentProdotto.getAttivo() = 1) then%>
						<span style="display:none;" id="addtocardloadingimg"><img src="<%=Application("baseroot") & "/common/img/loading_icon.gif"%>" border="0" width="16" height="16" hspace="0" vspace="0"></span>
						<span id="addtocardloading"><a href="javascript:addToCarrello(document.form_add_to_carrello);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="<%=Application("baseroot")&"/common/img/cart_add.png"%>" hspace="0" vspace="0" border="0"></a></span>
						<!--<a href="javascript:ajaxCheckQta6Multiple('form_add_to_carrello', document.form_add_to_carrello.id_prodotto.value, document.form_add_to_carrello.qta_prodotto.value, ''),addToCarrello(document.form_add_to_carrello);" title="<%'=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="<%'=Application("baseroot")&"/common/img/cart_add.png"%>" hspace="0" vspace="0" border="0"></a>-->
					<%else%>
						<img src="<%=Application("baseroot")&"/common/img/ico-carrello.png"%>" hspace="0" vspace="0" border="0" alt="<%=lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")%>">
					<%end if%>

					<%'GESTISCO LA QUANTITA' SELEZIONABILE		      
						if(objCurrentProdotto.getQtaDisp() = Application("unlimited_key")) then
							if(objCurrentProdotto.getEditBuyQta()=1) then%>
								<input type="text" name="qta_prodotto" value="" onkeypress="javascript:return isInteger(event);" class="formFieldTXTShort">
								<!--<input type="text" name="qta_prodotto" value="" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkQta6Multiple(this);" class="formFieldTXTShort">-->
							<%else%>
								<input type="hidden" name="qta_prodotto" value="1">
							<%end if
						else
							if(objCurrentProdotto.getEditBuyQta()=1) then%>
								<input type="text" name="qta_prodotto" id="qta_prodotto" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%=objCurrentProdotto.getQtaDisp()%>,this);">
								<!--<input type="text" name="qta_prodotto" id="qta_prodotto" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%'=objCurrentProdotto.getQtaDisp()%>,this),checkQta6Multiple(this);">-->				
							<%else%>
								<input type="hidden" name="qta_prodotto" value="1">
							<%end if%>
							&nbsp;<%=lang.getTranslated("frontend.template_prodotto.table.label.product_disp")&"&nbsp;"&objCurrentProdotto.getQtaDisp()%>&nbsp;&nbsp;
						<%end if
				end if%>
				</form>
		<br/><br/>        
				<%
				On Error Resume next
				Set objRelationsProd = objCurrentProdotto.getRelationPerProdotto(id_prodotto)
				if (strComp(typename(objRelationsProd), "Dictionary", 1) = 0) then%>
					<div style="display:block " align="left">
					<h2><%=lang.getTranslated("frontend.template_prodotto.table.label.related_prod")%></h2>
					<%
					counter = 1
					for each k in objRelationsProd
						Set objRelProd = objRelationsProd(k)

						On Error Resume Next
							Set objFilesRelProd = objRelProd.getFileXProdotto()	
						If(Err.number <> 0) then
							objFilesRelProd = null
						end if%>

						<%if(counter MOD 5 = 0)then%><div id="clear"></div><%end if%>
						<div id="prodotto-immagine">
						<%
							Dim urlRelProd, gerCatRelProd
							urlRelProd = "#"
							On Error Resume Next							
							gerCatRelProd = objCurrentProdotto.getGerCatProd4Relation(objRelProd.getIDProdotto())            
							Set objCategoriaRelTmp = objCat.findExsitingCategoriaByGerarchia(gerCatRelProd)
							if not(isNull(objCategoriaRelTmp)) then
								Set objTemplateSelectedRel = objTemplate.findTemplateByID(objCategoriaRelTmp.findLangTemplateXCategoria(lang.getLangCode(),true))
								numPageTempl = objPageTempl.getMaxNumPageByIDTemplate(objTemplateSelectedRel.getID()) 
								urlRelProd = objMenuFruizione.resolveHrefUrl(base_url, numPageTempl, lang, objCategoriaRelTmp, objTemplateSelectedRel, objPageTempl)
								Set objTemplateSelectedRel = nothing
							else
								urlRelProd = "#"                  
							end if
							Set objCategoriaRelTmp = nothing
							if(Err.number <>0) then
								urlRelProd = "#"
							end if  

							if not(isNull(objFilesRelProd)) then%>
								<%Dim hasNotSmallImg
								hasNotSmallImg = true			
								for each xObjFile in objFilesRelProd
									Set objFileXProdotto = objFilesRelProd(xObjFile)
									iTypeFile = objFileXProdotto.getFileTypeLabel()
									if(Cint(iTypeFile) = 1) then%>	
										<a href="javascript:openRelatedProdPage('<%=urlRelProd%>', '<%=gerCatRelProd%>', <%=objRelProd.getIDProdotto()%>, <%=numPageTempl%>);" title="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>"><img src="<%=Application("dir_upload_prod")&objFileXProdotto.getFilePath()%>" alt="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>" width="100" height="100" align="top" /></a>
										<%hasNotSmallImg = false
										Exit for
									end if
									Set objFileXProdotto = nothing	
								next		
								if(hasNotSmallImg) then%>
								<a href="javascript:openRelatedProdPage('<%=urlRelProd%>', '<%=gerCatRelProd%>', <%=objRelProd.getIDProdotto()%>, <%=numPageTempl%>);" title="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>"><img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" alt="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>" hspace="0" vspace="0" border="0" align="top"></a>
								<%end if
								Set objFilesRelProd = nothing
							else%>
								<a href="javascript:openRelatedProdPage('<%=urlRelProd%>', '<%=gerCatRelProd%>', <%=objRelProd.getIDProdotto()%>, <%=numPageTempl%>);" title="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>"><img width="100" height="100" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" alt="<%=objRelProd.findFieldTranslation(1 ,lang.getLangCode(),1)%>" hspace="0" vspace="0" border="0" align="top"></a>
							<%end if%>
						</div>
						<%Set objRelProd = nothing				
						counter = counter +1
					next%>
					</div>
				<%end if

				Set objRelationsProd = nothing

				if(Err.number<>0) then
				'response.write(Err.description)
				end if	


		    if(bolHasAttach) then 
		      for each key in attachMap
			if(attachMap(key).count > 0)then%>
			  <br/><br/><strong><%=lang.getTranslated(attachMultiLangKey(key))%></strong><br/>
			  <%for each item in attachMap(key)%>
			    <a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popup.asp?id_allegato="&item.getFileID()&"&parent_type=2"%>','popupallegati',400,400,100,100)"><%=item.getFileName()%></a><br>
			  <%next
			end if
		      next
		    end if    
		    
		Set objCurrentProdotto = nothing%>				
			<!-- **********************************  END: CODICE PER LA GESTIONE DETTAGLIO PRODOTTI ********************************** -->

			<form action="" method="post" name="form_detail_rel_prod">	
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
Set Prodotto = Nothing
%>
