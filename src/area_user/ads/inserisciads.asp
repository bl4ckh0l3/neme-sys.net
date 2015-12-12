<%@Language=VBScript codepage=65001 %>
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/NewsClass.asp" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<!-- #include file="include/init4.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("backend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/area_user.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<%
Dim objAds, objSelAd
Set objAds = New AdsClass
	
if (Cint(id_element) <> -1) then
	Dim objNews, objSelNews
	Set objNews = New NewsClass
	Set objSelNews = objNews.findNewsByID(id_element)
	Set objNews = nothing
	
	if not(Instr(1, typename(objSelNews), "NewsClass", 1) > 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=004")
	end if
	
	On Error Resume Next
	Set objSelAd = objAds.findAdByElement(id_utente, id_element)	
	if (Instr(1, typename(objSelAd), "AdsClass", 1) > 0) then
		id_ads=objSelAd.getID()
		ads_type=objSelAd.getAdsType()
		price=objSelAd.getPrice()
		strPhone=objSelAd.getPhone()
		dta_ins=objSelAd.getDtaInserimento()
	end if
	if(Err.number <> 0) then 
	end if	
end if
%>
<script language="JavaScript">
function sendForm(){
	if(controllaCampiInput()){		
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function confirmDelete(){
	if(confirmDel()){
		document.form_cancella_ad.submit();
	}else{
		return;
	}
}

function confirmDel(){
	return confirm('<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_ad")%>');
}

function controllaCampiInput(){	
	var thisPrice = document.form_inserisci.price.value;
	if(thisPrice.indexOf('.') != -1){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.price.focus();
		return false;		
	}	

	return true;
}

/*function ajaxAddToCard(id_prod,field){
	var formID, operation;
	formID="#form_promotion";
	
	if(field.checked == true){		
		operation = "add";
	}else{
		operation = "del";
	}

	$('#operation_buy').val(operation);
	$('#id_prodotto_buy').val(id_prod);
	
	// prepare Options Object 
	var options = { 
	    type: "POST", 
	    url: '<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ManageCarrello.asp"%>',
	    iframe:true	    
	}; 
	 
	// pass options to ajaxForm 
	$(formID).ajaxSubmit(options);
	return false;
}*/
</script>
</head>
<body>
<!-- #include virtual="/public/layout/area_user/grid_top.asp" -->

			<table border="0" cellspacing="0" cellpadding="0" class="principal">
			<tr> 		  		  
				<td>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.title")%></span><br>
					<%=objSelNews.getTitolo()%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.abstract_field")%></span><br>
					<%=objSelNews.getAbstract1()%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.text")%></span><br>
					<%=objSelNews.getTesto()%><br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.data_pub")%></span><br>
					<%=FormatDateTime(dta_ins,2)&" "&FormatDateTime(dta_ins,vbshorttime)%><br/><br/>
				
				
					<form action="<%=Application("baseroot") & "/area_user/ads/ProcessAds.asp"%>" method="post" name="form_inserisci" accept-charset="UTF-8">
					<input type="hidden" value="<%=id_ads%>" name="id_ads">  
					<input type="hidden" value="<%=id_element%>" name="id_element"> 
					<input type="hidden" value="<%=id_utente%>" name="id_utente">
					<input type="hidden" value="<%=dta_ins%>" name="dta_ins"> 

					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.ads_type")%></span><br>
					<select name="ads_type" class="formFieldTXT">
					<option value="0" <%if (ads_type = 0) then response.Write("selected")%>><%=lang.getTranslated("backend.ads.lista.table.select.option.sell")%></option>
					<option value="1" <%if (ads_type = 1) then response.Write("selected")%>><%=lang.getTranslated("backend.ads.lista.table.select.option.buy")%></option>
					</select>
					<br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.price")%></span><br>
					<input type="text" name="price" value="<%=price%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);">
					<br/><br/>
					<span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.phone")%></span><br>
					<input type="text" name="phone" value="<%=strPhone%>" class="formFieldTXT" />					
					<br/>

					<%
					'************************************ GESTIONE PROMOZIONE ANNUNCI CON RECUPERO LISTA PRODOTTI DI TIPO ANNUNCIO E INVIO A CARRELLO SE SELEZIONATI DA UTENTE
					on error Resume Next
					Set Prodotto = new ProductsClass
					Set objListaProdotto = Prodotto.findProdotti(null, null, null, null, null, null, null, 2, 1, null, null, null, 1, 0)	

					if(objListaProdotto.Count > 0) then
					
						'**************** IMPOSTO LE CLASSI PER LA VALUTA
						Dim currClass, defCurrObj, thisCurrObj
						Set currClass = new CurrencyClass
						On Error Resume Next
						defCurrObj = currClass.getDefaultCurrency().getCurrency()
						if(Err.number <> 0) then
							defCurrObj = ""
						end if

						if(request("currency") <> "") then
							Session("currency") = request("currency")
							thisCurrObj = Session("currency")
						elseif(Session("currency") <> "") then
							thisCurrObj = Session("currency")
						else
							thisCurrObj = defCurrObj
							Session("currency") = thisCurrObj
						end if

						Set objProdField = new ProductFieldClass
						Set objProdFieldGroup = new ProductFieldGroupClass

						hasSconto=false
						hasGroup = false
						scontoCliente = 0
						groupCliente = ""
						groupDesc = ""
						groupClienteTax = null	
						objSelMargin = null	

						'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
						Dim international_country_code, international_state_region_code, userIsCompanyClient
						international_country_code = ""
						international_state_region_code = ""
						userIsCompanyClient = 0
						groupClienteTax = null

						groupCliente = objUserLogged.getGroup()
						if(not(groupCliente= "")) then
							On Error Resume Next
							Dim objGroup
							Set objGroup = New UserGroupClass
							Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
							groupDesc = objTmpGr.getShortDesc()
							if (not(isNull(objTmpGr.getTaxGroup()))) then
								Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
							end if
							hasGroup = true
							Set objTmpGr = nothing
								Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
							Set objGroup = nothing
							if(Err.number <> 0) then
								hasGroup = false
							end if
						end if

						scontoCliente= objUserLogged.getSconto()

						if(scontoCliente <> "" AND Cdbl(scontoCliente) > 0) then
							hasSconto = true
						end if

						Set objUserLogged = nothing

						On Error Resume Next
						Set objShip = new ShippingAddressClass
						Set orderShip = objShip.findShippingAddressByUserID(id_utente)

						if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
							international_country_code = orderShip.getCountry()	
							if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
								international_state_region_code = orderShip.getStateRegion()
							end if
							userIsCompanyClient = orderShip.isCompanyClient()	    
						end if
						Set orderShip = nothing
						Set objShip = nothing

						if(Err.number <> 0) then 
							'response.write(Err.description)
						end if

						Set objTasse = new TaxsClass
						
						
						'*********************************** VERIFICO SE CI SONO GIÀ PROMOZIONI CARICATE PER QUESTO ANNUNCIO
						bolHasPromotion = false
						On Error Resume Next
						
						if(id_ads<>-1)then
							Set objListPromotion = objAds.findAdsPromotionByID(id_ads)
							if(objListPromotion.count>0)then
								bolHasPromotion=true
							end if
						end if
						
						if(Err.number <> 0) then 
							'response.write(Err.description)
							bolHasPromotion = false
						end if						
						%>
						
						<br><br><span class="labelForm"><%=lang.getTranslated("backend.ads.detail.table.label.ads_promotion")%></span><br>
						<%for each t in objListaProdotto
							Set objSelProdotto = objListaProdotto(t) 
							bolSkipPromotion = false
							if(bolHasPromotion)then
								if(objListPromotion.exists(id_ads&"#"&objSelProdotto.getIDProdotto()))then
									if(objListPromotion(id_ads&"#"&objSelProdotto.getIDProdotto()).isActive())then
										bolSkipPromotion = true
									end if
								end if
							end if
							
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
							end if							

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

							title = objSelProdotto.findFieldTranslation(1 ,lang.getLangCode(),1)
							condition = objSelProdotto.findFieldTranslation(2 ,lang.getLangCode(),1)
							description = objSelProdotto.findFieldTranslation(3 ,lang.getLangCode(),1)%>
							<br/><input type="checkbox" style="vertical-align:middle;" value="<%=objSelProdotto.getIDProdotto()&"|"&objSelProdotto.getCodiceProd()%>" name="promotional">&nbsp;<!--  onclick="javascript:ajaxAddToCard(<%'=objSelProdotto.getIDProdotto()%>,this);" -->
							<b><%=title%></b><%if(bolSkipPromotion)then%>&nbsp;<span class="txtSmall">(<%=lang.getTranslated("frontend.area_user.ads.label.already_buy")%>&nbsp;<%=FormatDateTime(objListPromotion(id_ads&"#"&objSelProdotto.getIDProdotto()).getDtaInserimento(),2)&" "&FormatDateTime(objListPromotion(id_ads&"#"&objSelProdotto.getIDProdotto()).getDtaInserimento(),vbshorttime)%>)</span><%end if%>
							<br><%=condition&" - "%>
							<%if(discountPercent > 0) then%><span class="testoBarrato"><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoOld, 2,-1)&descTassa%></span> --><%end if%>&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoReal, 2,-1)&descTassa%>
							<%if(discountPercent > 0) then response.Write("&nbsp;&nbsp;" & lang.getTranslated("frontend.template_prodotto.table.label.sconto") & " " & discountPercent & "%") end if%>
							<br/><span class="txtUserPreference"><%=description%></span><br/>
							<%Set objSelProdotto = Nothing
						next  
						Set objTasse = nothing						
					end if
					
					Set objListaProdotto = Nothing
					Set Prodotto = Nothing

					if Err.number <> 0 then
					end if
					%>

					<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="/editor/img/loading.gif" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
					</form>
					
					<iframe id="upload_form_ads" name="upload_form_ads" height="0" width="0" frameborder="0" scrolling="yes"></iframe>
					<form action="" method="post" name="form_promotion" id="form_promotion" enctype="multipart/form-data" target="upload_form_ads">					
					<input type="hidden" name="qta_prodotto" value="1">
					<input type="hidden" value="" name="id_prodotto" id="id_prodotto_buy">
					<input type="hidden" value="add" name="operation" id="operation_buy">
					</form>
				</td>
			</tr>
			</table>
			<br/>
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.inserisci.label")%>" onclick="javascript:sendForm();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/area_user/ads/ListaNews.asp?cssClass=LN"%>';" />
			<br/><br/>			
			<%if (Cint(id_ads) <> -1) then%>		
				<form action="<%=Application("baseroot") & "/area_user/ads/DeleteAds.asp"%>" method="post" name="form_cancella_ad">
				<input type="hidden" value="<%=id_ads%>" name="id_ads_to_delete">
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" onclick="javascript:confirmDelete();" />
				</form>
			<%end if%>	

<!-- #include virtual="/public/layout/area_user/grid_bottom.asp" -->
</body>
</html>
<%
Set objSelAd = Nothing
Set objSelNews = Nothing
Set objAds = nothing
%>