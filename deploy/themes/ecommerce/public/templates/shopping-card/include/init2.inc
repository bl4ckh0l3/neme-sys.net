<%
Dim id_user, scontoCliente, objCarrelloUser, carrello, Prodotto 
Dim groupClienteTax, objSelMargin, hasSessionIDCard, hasSconto, objTasse, hasGroup, groupCliente, groupDesc
Dim objGroup
Set objGroup = new UserGroupClass

hasSconto=false
hasGroup = false
scontoCliente = 0
groupCliente = ""
groupDesc = ""
groupClienteTax = null	
objSelMargin = null	
hasOrderRule = false
hasValidVoucher = false
hasActiveVoucherCampaign = false
bolVoucherExcludeProdRule = false
objVoucher=null
voucher_code = ""
voucher_message = ""

Set carrello = New CardClass
Set Prodotto = New ProductsClass
Set objTasse = new TaxsClass
Set objOrder = new OrderClass
Set objRule = new BusinessRulesClass
Set objVoucherClass =  new VoucherClass

Set objProdField = new ProductFieldClass
Set objProdFieldGroup = new ProductFieldGroupClass

Set objShip = new ShippingAddressClass
Set objBills = new BillsAddressClass

objCarrelloUser = null


'********** VERIFICO SE ESISTE UNA CAMPAGNA VOUCHER ATTIVA E SE E' STATO INSERITO UN VOUCHER E IN TAL CASO CERCO UNA RULE DI TIPO VOUCHER
On Error Resume Next
Set objOrderRule = objRule.getListaRules("3", 1)
if(objOrderRule.count>0) then
  hasActiveVoucherCampaign = true
  '*** recupero il voucher_code dalla request o dalla session
  if(request("voucher_delete")="1")then
    Session("voucher_code") = ""
  end if
  if(request("voucher_code")<>"")then
      Session("voucher_code") = Trim(request("voucher_code"))
  end if
  voucher_code = Session("voucher_code")
end if
if(Err.number <> 0) then
    hasActiveVoucherCampaign = false
end if

'response.write("hasActiveVoucherCampaign: "& hasActiveVoucherCampaign&"<br>")

if (hasActiveVoucherCampaign AND voucher_code<>"") then
  On Error Resume Next 
    Set objVoucher=  objVoucherClass.validateVoucherCode(Trim(voucher_code))
    'response.write("typename(objVoucher): "&typename(objVoucher)&"<br>")
    if (strComp(typename(objVoucher), "VoucherClass") = 0)then
      hasValidVoucher = true
      if(objVoucher.getExcludeProdRule())then
        bolVoucherExcludeProdRule = true
      end if
    else
      voucher_message = lang.getTranslated("portal.commons.voucher.message.error_invalid")
      Session("voucher_code")=""
      voucher_code = Session("voucher_code")
    end if
  if(Err.number <> 0) then
    hasValidVoucher = false
  end if 

  'response.write("hasValidVoucher: "& hasValidVoucher&"<br>")
  
  On Error Resume Next
  if(hasValidVoucher) then
      hasOrderRule = true
  end if
  if(Err.number <> 0) then
    hasOrderRule = false
  end if  
end if

'response.write("hasOrderRule: "& hasOrderRule&"<br>")

if not(isEmpty(Session("objUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing
	
	if(objUserLogged.getRuolo() <> 3) then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error=023")
	end if	
		
	hasSessionIDCard = carrello.findCarrelloByIDUser(Session.SessionID)	
	id_user = objUserLogged.getUserID()

	groupCliente = objUserLogged.getGroup()
	if(not(groupCliente= "")) then
		On Error Resume Next
		Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
		groupDesc = objTmpGr.getShortDesc()
		if (not(isNull(objTmpGr.getTaxGroup()))) then
			Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
		end if
		hasGroup = true
		Set objTmpGr = nothing
		Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
		if(Err.number <> 0) then
			hasGroup = false
		end if
	end if

	scontoCliente= objUserLogged.getSconto()
	
	if(scontoCliente <> "" AND Cdbl(scontoCliente) > 0) then
		hasSconto = true
	end if

  '*** verifico se esiste una rule primo ordine e se l'utente ne possiede i requisiti
  On Error Resume Next
  if not(hasOrderRule) then 
    if(Cint(objOrder.countUserOrder(id_user))=0)then
      Set objOrderRule = objRule.getListaRules("4,5", 1)  
      if(objOrderRule.count>0) then
        hasOrderRule = true
      end if
    end if
  end if
  if(Err.number <> 0) then
    hasOrderRule = false
  end if
  
	if(hasSessionIDCard) then	
		Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)	
		call objCarrelloUser.updateIDUtenteCarrello(objCarrelloUser.getIDCarrello(), id_user)
		Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
	else
		Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
	end if
	
	Set objUserLogged = nothing
end if	

Dim objListaCarrello, order_carrello_by
Dim id_prodotto, operation, qta_prod, prezzo, totale_prod, id_carrello, ref_id_ads
order_carrello_by = 3
ref_id_ads = request("id_ads")

if(carrello.findCarrelloByIDUser(Session.SessionID) = true) then
	Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)
end if

'**************** IMPOSTO LE CLASSI PER LA VALUTA
Dim currClass, defCurrObj, hasCurrency
Set currClass = new CurrencyClass
On Error Resume Next
hasCurrency = false
defCurrObj = currClass.getDefaultCurrency().getCurrency()
if(Err.number <> 0) then
	defCurrObj = ""
end if

if not(defCurrObj="") AND not(Session("currency")="") then
	hasCurrency = true
end if

'********** RECUPERO LA LISTA DI FIELD UTENTE DISPONIBILI
Dim objUserField, objListUserField, hasUserFields, noreg_email
hasUserFields=false
On Error Resume Next
Set objUserField = new UserFieldClass
Set objListUserField = objUserField.getListUserField(1,"2,3")
if(objListUserField.count > 0)then
	hasUserFields=true
end if
if(Err.number <> 0) then
	hasUserFields=false
end if

'********** SE NON ESISTE GIA' UNA RULE PRIMO ORDINE, CERCO TUTTE LE RULE PER ORDINE ATTIVE
if not(hasOrderRule) then
  On Error Resume Next 
  Set objOrderRule = objRule.getListaRules("1,2", 1)  
  if(objOrderRule.count>0) then
    hasOrderRule = true
  end if
  if(Err.number <> 0) then
    hasOrderRule = false
  end if  
end if


'********** GESTIONE RECUPERO SHIPPING DATA
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

On Error Resume Next
Set orderShip = objShip.findShippingAddressByUserID(id_user)

if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
	userName = orderShip.getName()
	userSurname = orderShip.getSurname()
	userCfiscVat = orderShip.getCfiscVat()
	userAddress = orderShip.getAddress()
	userCity = orderShip.getCity()
	userZipCode = orderShip.getZipCode()
	userCountry = orderShip.getCountry()	
	if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
		userStateRegion = orderShip.getStateRegion()
		userStateRegionLabel = " - " & lang.getTranslated("portal.commons.select.option.country."&userStateRegion)
	end if
  userIsCompanyClient = orderShip.isCompanyClient()	
	hasShipAddress = true
end if
Set orderShip = nothing

if(Err.number <> 0) then 
'response.write(Err.description)
end if

'********** GESTIONE RECUPERO BILLS DATA
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

On Error Resume Next
Set orderBills = objBills.findBillsAddressByUserID(id_user)

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
		buserStateRegionLabel = " - " & lang.getTranslated("portal.commons.select.option.country."&buserStateRegion)
	end if	
	hasBillsAddress = true
end if		  

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
		userStateRegionLabel = " - " & lang.getTranslated("portal.commons.select.option.country."&userStateRegion)

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
			buserStateRegionLabel = " - " & lang.getTranslated("portal.commons.select.option.country."&buserStateRegion)
		end if
	end if

	if(Trim(international_country_code) = "")then
		if(Trim(userCountry) <> "")then
			international_country_code = Trim(userCountry)
			international_state_region_code = Trim(userStateRegion)
		end if
	end if	
end if

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