<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUserLogged, objUserLoggedTmp
Set objUserLoggedTmp = new UserClass
Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
Set objUserLoggedTmp = nothing

Dim strRuoloLogged
strRuoloLogged = objUserLogged.getRuolo()
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if

'/**
'* recupero i valori della news selezionata se id_order <> -1
'*/
Dim id_order, id_utente, dta_ins, totale_imp_ord, totale_tasse_ord, order_modified, order_notes
Dim totale_ord, spese_sped_order, stato_order, tipo_pagam, pagam_done, objProdPerOrder, payment_commission
Dim objSelProdPerOrder, objProdTmp

order_modified = request("order_modified")			  
if(order_modified = "") then
	order_modified = 0
end if

id_order = Cint(request("id_ordine"))
objSelProdPerOrder = null

Dim objOrder, objSelOrder, tmp_imp_ord
Set objOrder = New OrderClass
Set objSelOrder = objOrder.findOrdineByID(id_order, 0)
Set objProdPerOrder = New Products4OrderClass

id_order = objSelOrder.getIDOrdine()
id_utente = objSelOrder.getIDUtente()
dta_ins = objSelOrder.getDtaInserimento()
totale_imp_ord = objSelOrder.getTotaleImponibile()
totale_tasse_ord = objSelOrder.getTotaleTasse()
totale_ord = objSelOrder.getTotale()
tipo_pagam = objSelOrder.getTipoPagam()
payment_commission = objSelOrder.getPaymentCommission()
pagam_done = objSelOrder.getPagamEffettuato()
stato_order = objSelOrder.getStatoOrdine()
order_notes = objSelOrder.getOrderNotes() 
Set objSelOrder = Nothing

Dim hasSelProdPerOrder
hasSelProdPerOrder = false

On Error Resume Next
	Set objSelProdPerOrder = objProdPerOrder.getListaProdottiXOrdine(id_order)
	if(objSelProdPerOrder.count > 0)then
		hasSelProdPerOrder = true
	end if	
if(Err.number <> 0)then
	hasSelProdPerOrder = false
end if	


Set objProdField = new ProductFieldClass

Dim objClientTmp, groupClienteTax, hasSconto, scontoCliente, hasGroup, groupCliente, groupDesc
Dim objGroup
Set objGroup = new UserGroupClass

hasSconto=false
hasGroup = false
scontoCliente = 0
groupCliente = ""
groupDesc = ""
groupClienteTax = null

if(not(id_utente = "")) then
	Set objClientTmp = objUserLogged.findUserByID(id_utente)		
	groupCliente = objClientTmp.getGroup()
	objClientTmpUsr = objClientTmp.getUserName()
	if(not(groupCliente= "")) then
		On Error Resume Next
		Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
		groupDesc = objTmpGr.getShortDesc()
		if (not(isNull(objTmpGr.getTaxGroup()))) then
			Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
		end if
		hasGroup = true
		Set objTmpGr = nothing
		if(Err.number <> 0) then
			hasGroup = false
		end if
	end if

	scontoCliente = objClientTmp.getSconto()
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if

Dim objShip, orderShip, hasShipAddress
Dim userName, userSurname, userCfiscVat, userAddress, userCity, userZipCode, userCountry, userStateRegion, userIsCompanyClient

userName = ""
userSurname = ""
userCfiscVat = ""
userAddress = ""
userCity = ""
userZipCode = ""
userCountry = ""
userStateRegion = ""
userIsCompanyClient = 0
hasShipAddress = false

Set objShip = new ShippingAddressClass
On Error Resume Next

Set orderShip = objShip.findShippingAddressByUserID(id_utente)

if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
userName = orderShip.getName()
userSurname = orderShip.getSurname()
userCfiscVat = orderShip.getCfiscVat()
userAddress = orderShip.getAddress()
userCity = orderShip.getCity()
userZipCode = orderShip.getZipCode()
userCountry = orderShip.getCountry()	
userIsCompanyClient = orderShip.isCompanyClient()	
if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
	userStateRegion = orderShip.getStateRegion()
	userStateRegionLabel = " - " & langEditor.getTranslated("portal.commons.select.option.country."&userStateRegion)
end if		
hasShipAddress = true
end if		  

Set orderShip = nothing

if(Err.number <> 0) then 
'response.write(Err.description)
end if


Dim objBills, orderBills, hasBillsAddress
Dim buserName, buserSurname, buserCfiscVat, buserAddress, buserCity, buserZipCode, buserCountry, buserStateRegion

buserName = ""
buserSurname = ""
buserCfiscVat = ""
buserAddress = ""
buserCity = ""
buserZipCode = ""
buserCountry = ""
buserStateRegion = ""
hasBillsAddress = false

Set objBills = new BillsAddressClass
On Error Resume Next

Set orderBills = objBills.findBillsAddressByUserID(id_utente)

if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
buserName = orderBills.getName()
buserSurname = orderBills.getSurname()
buserCfiscVat = orderBills.getCfiscVat()
buserAddress = orderBills.getAddress()
buserCity = orderBills.getCity()
buserZipCode = orderBills.getZipCode()
buserCountry = orderBills.getCountry()			
if not(isNull(orderBills.getStateRegion()) AND not(orderBills.getStateRegion()="")) then
	buserStateRegion = orderBills.getStateRegion()
	buserStateRegionLabel = " - " & langEditor.getTranslated("portal.commons.select.option.country."&buserStateRegion)
end if	
hasBillsAddress = true
end if		  

Set orderBills = nothing

if(Err.number <> 0) then 
'response.write(Err.description)
end if

'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
Dim international_country_code, international_state_region_code
international_country_code = ""
international_state_region_code = ""

if(Application("enable_international_tax_option")=1)then
	international_country_code = request("ship_country")
	international_state_region_code = request("ship_state_region")

	if(Trim(international_country_code) <> "") then
		userCountry = Trim(international_country_code)
		userStateRegion = Trim(international_state_region_code)
		userStateRegionLabel = " - " & langEditor.getTranslated("portal.commons.select.option.country."&userStateRegion)

		if(Trim(request("noreg_email"))<>"") then noreg_email = request("noreg_email") end if

		if(Trim(request("ship_name"))<>"") then userName = request("ship_name") end if
		if(Trim(request("ship_surname"))<>"") then userSurname = request("ship_surname") end if
		if(Trim(request("ship_cfiscvat"))<>"") then userCfiscVat = request("ship_cfiscvat") end if            
		if(Trim(request("ship_address"))<>"") then userAddress = request("ship_address") end if
		if(Trim(request("ship_zip_code"))<>"") then userCity = request("ship_zip_code") end if
		if(Trim(request("ship_city"))<>"") then userZipCode = request("ship_city") end if
		if(Trim(request("ship_is_company_client"))<>"") then userIsCompanyClient = request("ship_is_company_client") end if
		
		if(Trim(request("bills_name"))<>"") then buserName = request("bills_name") end if
		if(Trim(request("bills_surname"))<>"") then buserSurname = request("bills_surname") end if
		if(Trim(request("bills_cfiscvat"))<>"") then buserCfiscVat = request("bills_cfiscvat") end if            
		if(Trim(request("bills_address"))<>"") then buserAddress = request("bills_address") end if
		if(Trim(request("bills_zip_code"))<>"") then buserCity = request("bills_zip_code") end if
		if(Trim(request("bills_city"))<>"") then buserZipCode = request("bills_city") end if
		if(Trim(request("bills_country"))<>"") then buserCountry = request("bills_country") end if
		if(Trim(request("bills_state_region"))<>"") then 
			buserStateRegion = request("bills_state_region")
			buserStateRegionLabel = " - " & langEditor.getTranslated("portal.commons.select.option.country."&buserStateRegion) 
		end if
	end if

	if(Trim(international_country_code) = "")then
		if(Trim(userCountry) <> "")then
			international_country_code = Trim(userCountry)
			international_state_region_code = Trim(userStateRegion)
		end if
	end if	
end if

Set objRule = new BusinessRulesClass
bolHasCalculatedRules = false
tot_rule_amount = 0
On Error Resume Next
Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_order, false)
if(strComp(typename(objRule4Order), "Dictionary") = 0)then
	if(objRule4Order.count>0)then
		for each x in objRule4Order
			tot_rule_amount=tot_rule_amount+Cdbl(objRule4Order(x).getValoreConf())
		next
		bolHasCalculatedRules = true
	end if
end if
If Err.Number<>0 then
	'response.write(Err.description)					
end if


Set objVoucherClass =  new VoucherClass
voucher_message = request("voucher_message")
hasActiveVoucherCampaign = false
On Error Resume Next
Set objOrderRule = objRule.getListaRules("3", 1)
if(objOrderRule.count>0) then
  hasActiveVoucherCampaign = true
end if
if(Err.number <> 0) then
    hasActiveVoucherCampaign = false
end if
Set objVoucherClass =  nothing

'response.write("request(ship_country): "&request("ship_country")&"<br>")
'response.write("request(ship_state_region): "&request("ship_state_region")&"<br>")
'response.write("request(bills_country): "&request("bills_country")&"<br>")
'response.write("request(bills_state_region): "&request("bills_state_region")&"<br>")
'response.write("userCountry: "&userCountry&"<br>")
'response.write("userStateRegion: "&userStateRegion&"<br>")
'response.write("buserCountry: "&buserCountry&"<br>")
'response.write("buserStateRegion: "&buserStateRegion&"<br>")
'response.write("international_country_code: "&international_country_code&"<br>")
'response.write("international_state_region_code: "&international_state_region_code&"<br>")
%>