<%@LANGUAGE="VBScript"%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->
<%
' dim some variables
Dim Item_name, Item_number, Payment_status, Payment_amount
Dim Txn_id, Receiver_email, Payer_email
Dim objHttp, str
Dim remoteAddrMatch
remoteAddrMatch = false
	
Dim objModulePayment, objModuleList, idOrdine, idModule, orderGuid, orderAmount, pageModuleCheckin, externalURL
idOrdine = -1
idModule = -1

Dim objLogger
Set objLogger = New LogClass

Set objModulePayment = new PaymentModuleClass
Set objModuleList = objModulePayment.getListaPaymentModuli()
exit1For = false	
for each x in objModuleList
	idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
	for each z in idOrderFieldList
		if not(request.form(z) = "") then			
			idOrdineAck = request.form(z)
			'Set objUtil = new UtilClass
			'Set objCrypt = new CryptClass
			' decripto il campo contenente il codice ordine
			'idOrdineAck = objCrypt.DeCrypt(objUtil.URLDecode(idOrdineAck))
			'Set objCrypt = nothing
			'Set objUtil = nothing
			idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",0)))	
			idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",0)-1)
			idOrdine = idOrdineAck
			idModule = objModuleList(x).getID()		
				
			' ***********    TODO  RIPRISTINARE SEMPRE QUESTO CONTROLLO IN AMBIENTE DI PRODUZIONE
			' ***********    L'UTILIZZO DI REMOTE_ADDR SEMBRA NON FUNZIONARE, RITORNA IP ERRATO
			'Dim idValidIPFieldList
			'idValidIPFieldList = Split(objModuleList(x).getIpProvider(),"|",-1,1)
			'for each t in idValidIPFieldList
				'if(t = request.ServerVariables("REMOTE_ADDR")) then
					remoteAddrMatch = true
					'Exit for
				'end if
			'next
				
			exit1For = true
			Exit for			
		end if
	next
	if(exit1For) then exit for end if
next

if(Cint(idOrdine) <> -1 AND remoteAddrMatch) then					
	Dim objOrdine, objCurrOrder, objPayment, objCurrPayment
	Set objOrdine = New OrderClass	
	Set objCurrOrder = objOrdine.findOrdineByID(idOrdine, true)	
	Set objPayment = New PaymentClass
	Set objCurrPayment = objPayment.findPaymentByID(objCurrOrder.getTipoPagam())
	Set objPaymentField = new PaymentFieldClass	
	Set obiCurrPaymentFieldMatch = objPaymentField.getListaCheckinDoMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
	Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaCheckinNotMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
	Set objUtil = new UtilClass
	externalURL = objPaymentField.findPaymentFieldByName(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID(), objUtil.getUniqueKeyExtURLPayment()).getValueField()
	Set objUtil = nothing
	Set fixedField = objPaymentField.getListaMatchFields()		
	Set obiFinalPaymentFieldMatch = Server.CreateObject("Scripting.Dictionary")
	Set obiFinalPaymentFieldNotMatch = Server.CreateObject("Scripting.Dictionary")
	
	'************** GESTIONE PROCEDURA CONFERMA PAGAMENTO *********************
	Dim boolChangeStatusOrder
	boolChangeStatusOrder = false
	
	' recuperare tutti i campi obbligatori inviati dal sistema di pagamento
	for each k in obiCurrPaymentFieldMatch
		if not(request.form(k) = "") then
			fixedField.item(obiCurrPaymentFieldMatch(k).getMatchField()) = request.form(k)
			obiFinalPaymentFieldMatch.add k, request.form(k)
		end if
	next	 
					
	' recuperare tutti i campi specifici inviati dal sistema di pagamento
	for each z in obiCurrPaymentFieldNotMatch
		if not(request.form(z) = "") then
			obiFinalPaymentFieldNotMatch.add z, request.form(z)
		end if
	next
					
	' chiamata a pagina checkin specifica con objHttp.open, passare tutti i parametri necessari
	Dim checkin_parameters
	checkin_parameters = ""
	for each q in obiFinalPaymentFieldMatch
		checkin_parameters = checkin_parameters &q&"="&obiFinalPaymentFieldMatch(q)&"&"
	next	
	for each j in obiFinalPaymentFieldNotMatch
		checkin_parameters = checkin_parameters &j&"="&obiFinalPaymentFieldNotMatch(j)&"&"
	next		
	checkin_parameters = Left(checkin_parameters, Len(checkin_parameters)-1) & "&cmd=_notify-validate&"&request.Form()
	
	checkin_parameters = request.Form()&"&cmd=_notify-validate"
	
	'call objLogger.write("checkin notify: request form paypal --> "&request.Form(), "system", "debug")
	'call objLogger.write("checkin notify: checkin_parameters paypal --> "&checkin_parameters, "system", "debug")
		
	'********************   begin IPN handling	
	set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
	' set objHttp = Server.CreateObject("Microsoft.XMLHTTP")
	objHttp.open "POST", externalURL, false
	objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
	objHttp.Send(checkin_parameters)

	' assign posted variables to local variables
	item_name = Request.Form("item_name")
	item_number = Request.Form("item_number")
	payment_status = Request.Form("payment_status")
	txn_id = Request.Form("txn_id")
	parent_txn_id = Request.Form("parent_txn_id")
	receiver_email = Request.Form("receiver_email")
	payer_email = Request.Form("payer_email")
	reason_code = Request.Form("reason_code")
	business = Request.Form("business")
	quantity = Request.Form("quantity")
	invoice = Request.Form("invoice")
	custom = Request.Form("custom")
	tax = Request.Form("tax")
	option_name1 = Request.Form("option_name1")
	option_selection1 = Request.Form("option_selection1")
	option_name2 = Request.Form("option_name2")
	option_selection2 = Request.Form("option_selection2")
	num_cart_items = Request.Form("num_cart_items")
	pending_reason = Request.Form("pending_reason")
	payment_date = Request.Form("payment_date")
	'*** questo campo corrisponde al campo amount
	mc_gross = Request.Form("mc_gross")
	
	mc_fee = Request.Form("mc_fee")
	mc_currency = Request.Form("mc_currency")
	settle_amount = Request.Form("settle_amount")
	settle_currency = Request.Form("settle_currency")
	exchange_rate = Request.Form("exchange_rate")
	txn_type = Request.Form("txn_type")
	first_name = Request.Form("first_name")
	last_name = Request.Form("last_name")
	payer_business_name = Request.Form("payer_business_name")
	address_name = Request.Form("address_name")
	address_street = Request.Form("address_street")
	address_city = Request.Form("address_city")
	address_state = Request.Form("address_state")
	address_zip = Request.Form("address_zip")
	address_country = Request.Form("address_country")
	address_status = Request.Form("address_status")
	payer_email = Request.Form("payer_email")
	payer_id = Request.Form("payer_id")
	payer_status = Request.Form("payer_status")
	payment_type = Request.Form("payment_type")
	notify_version = Request.Form("notify_version")
	verify_sign = Request.Form("verify_sign")

	'subscription information
	subscr_date = Request.Form("subscr_date")
	period1 = Request.Form("period1")
	period2 = Request.Form("period2")
	period3 = Request.Form("period3")
	amount1 = Request.Form("mc_amount1")
	amount2 = Request.Form("mc_amount2")
	amount3 = Request.Form("mc_amount3")
	recurring = Request.Form("recurring")
	reattempt = Request.Form("reattempt")
	retry_at = Request.Form("retry_at")
	recur_times = Request.Form("recur_times")
	username = Request.Form("username")
	password = Request.Form("password")
	subscr_id = Request.Form("subscr_id")

	'auction information
	for_auction = Request.Form("for_auction")
	auction_buyer_id = Request.Form("auction_buyer_id")
	auction_closing_date = Request.Form("auction_closing_date")
	
	
	'call objLogger.write("checkin notify: custom paypal --> "&custom, "system", "debug")
	'call objLogger.write("checkin notify: txn_id paypal --> "&txn_id, "system", "debug")
	'call objLogger.write("checkin notify: objHttp.status --> "&objHttp.status, "system", "debug")
	'call objLogger.write("checkin notify: payment_status paypal --> "&payment_status, "system", "debug")
	'call objLogger.write("checkin notify: objHttp.responseText --> "&objHttp.responseText, "system", "debug")
	'call objLogger.write("checkin notify: Request.Form() back --> "&Request.Form(), "system", "debug")
	'call objLogger.write("Request.Form(amount1) --> "&Request.Form("amount1"), "system", "debug")
	'call objLogger.write("Request.Form(amount2) --> "&Request.Form("amount2"), "system", "debug")
	'call objLogger.write("Request.Form(amount3) --> "&Request.Form("amount3"), "system", "debug")
	'call objLogger.write("Request.Form(payment_status) --> "&Request.Form("payment_status"), "system", "debug")
	'call objLogger.write("Request.Form(pending_reason) --> "&Request.Form("pending_reason"), "system", "debug")

	' Check notification validation
	if (objHttp.status <> 200 ) then
		call objLogger.write("modificato ordine paypal --> objHttp.status: "&objHttp.status, "system", "info")
		' HTTP error handling
	elseif (objHttp.responseText = "VERIFIED") then
		' check that Payment_status=Completed or Pending
		boolPaymentComplete = (payment_status = "Completed")
		boolPaymentPending = (payment_status = "Pending")
		'call objLogger.write("checkin notify: boolPaymentComplete --> "&boolPaymentComplete, "system", "debug")
		'call objLogger.write("checkin notify: boolPaymentPending --> "&boolPaymentPending, "system", "debug")

		'implement IPN handling logic for DB insertion '#########################################################
	
		' gestire la verifica validità sull'ordine
		Dim objPaymentTrans, objUtil
		Set objUtil = new UtilClass		
		Set objPaymentTrans = new PaymentTransactionClass
		idOrdineAckResp = custom
		'Set objUtil = new UtilClass
		'Set objRc4 = new rc4Class
		' decripto il campo contenente il codice ordine
		'idOrdineAckResp = objRc4.EnDeCrypt(idOrdineAckResp,objUtil.getUniqueKeyEncryptDecrypt())
		'Set objRc4 = nothing
		'Set objUtil = nothing
		orderGuid = Left(idOrdineAckResp,InStr(1,idOrdineAckResp,"|",0)-1)
		idOrdineAckResp =  Right(idOrdineAckResp,(Len(idOrdineAckResp)-InStr(1,idOrdineAckResp,"|",0)))	
		orderAmount = Right(idOrdineAckResp,(Len(idOrdineAckResp)-InStr(1,idOrdineAckResp,"|",0)))
		idOrdineAckResp = Left(idOrdineAckResp,InStr(1,idOrdineAckResp,"|",0)-1)
		idOrdine = idOrdineAckResp
		'call objLogger.write("checkin notify: idOrdine --> "&idOrdine, "system", "debug")
		'call objLogger.write("checkin notify: orderAmount --> "&orderAmount, "system", "debug")
		'call objLogger.write("checkin notify: orderGuid --> "&orderGuid, "system", "debug")
		'call objLogger.write("checkin notify: verifyOrder --> "&(objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount)), "system", "debug")
		'call objLogger.write("checkin notify: mc_gross=orderAmount --> "&(CDbl(mc_gross) = CDbl(orderAmount)), "system", "debug")

		Dim objMail
		Set objMail = New SendMailClass
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		if(boolPaymentComplete AND objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount) AND (CDbl(mc_gross) = CDbl(orderAmount))) then
			call objLogger.write("checkin notify: modificato ordine paypal --> id: "&idOrdine&"; pagamdone: 1", "system", "info")
			' se tutto corretto cambiare stato ordine : pagato e notificato			
			'******************** QUESTA CHIAMATA E' DA GESTIRE IN SICUREZZA
			call objOrdine.changePagamDoneOrder(idOrdine, 1, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, txn_id, objUtil.getUniqueKeySuccessPaymentTransaction(), 1, now(), objConn)	
			
			'*** inserisco o aggiorno la lista dei file scaricabili
			'*** se il pagamento è stato effettuato e non era pagato in precedenza, imposto active = true
			'*** se il pagamento era già stato effettuato non faccio nulla
			Set objProdList = objCurrOrder.getProdottiXOrdine()
			id_utente_tmp = objCurrOrder.getIDUtente()	
			Dim objDownProd, objDownProd4Order, objDownProdList
			Dim expireDate, isActive
			Set objDownProd = new DownloadableProductClass
			Set objDownProd4Order = new DownloadableProduct4OrderClass	
			Set objProdTmp = New ProductsClass
			Set objAds = new AdsClass

			Dim hasDown
			hasDown = false			

			id_ads = objCurrOrder.getIdAdRef()
	
			for each j in objProdList
				Set tmpProd = objProdTmp.findProdottoByID(Left(j,Instr(1,j,"|",1 )-1),0)
				if(tmpProd.getProdType()=1)then
					hasDown = true
					Set objDownProdList = objDownProd.getFilePerProdotto(tmpProd.getIDProdotto())
					for each r in objDownProdList
						'*** verifico se esiste già questo record su DB e imposto i valori corretti da inserire
						expireDate = null
						isActive = 1				

						if(tmpProd.getMaxDownloadTime() <> -1) then
							expireDate = DateAdd("n",tmpProd.getMaxDownloadTime(),now()) 
						end if
						'call objLogger.write("modificato ordine paypal --> expireDate: "&expireDate, "system", "debug")
		
						if not(isNull(objDownProd4Order.getFileByIDProdDown(idOrdine, tmpProd.getIDProdotto(), r))) then
							'call objLogger.write("modifyDownProd paypal --> objDownProd: "&objDownProd.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r).getID()&"; id_ordine: "&r&"; IDProdotto: "&tmpProd.getIDProdotto()&"; objDownProd: "&r&"; id_utente: "&id_utente, "system", "debug")
							Set objDownProd4OrderTmp = objDownProd4Order.getFileByIDProdDown(idOrdine, tmpProd.getIDProdotto(), r)
							call objDownProd4Order.modifyDownProd(objDownProd4OrderTmp.getID(), idOrdine, tmpProd.getIDProdotto(), r, id_utente_tmp, isActive, tmpProd.getMaxDownload(), now(), expireDate, objDownProd4OrderTmp.getDownloadCounter(), objDownProd4OrderTmp.getDownloadDate(),objConn)
							Set objDownProd4OrderTmp = nothing
						end if
						
					next
					Set objDownProdList = nothing
				elseif(tmpProd.getProdType()=2)then
					'*** Se il pagamento e'  andato a buon fine verifico se nella lista prodotti ci sono degli annunci a pagamento e imposto activate a true e la data di attivazione alla data corrente			
					On Error Resume Next
					if(id_ads<>"")then
						call objAds.activateAdsPromotion(id_ads, tmpProd.getIDProdotto(), objConn)
					end if
					If Err.Number<>0 then
						'response.write(Err.description)
					end if
				end if		
				Set tmpProd = nothing
			next
			
			Set objAds = nothing
			Set objProdTmp = nothing
			Set objDownProd4Order = nothing
			Set objDownProd = nothing
			Set objProdList = nothing			

			Set objUserStatic = New UserClass			
			Set objUserTmp = objUserStatic.findUserByID(id_utente_tmp)
			strMail = objUserTmp.getEmail()
			Set objUserTmp = nothing
			Set objUserStatic = nothing
			
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
				hasDown = false
			end if
		
			if(hasDown) then
				call objMail.sendMailOrderDown(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
				call objMail.sendMailOrderDown(idOrdine, strMail, 0, Application("str_lang_code_default"))						
				call objOrdine.changeUserNotifiedOrderNoTransaction(idOrdine, 1)
			end if
			
		elseif(boolPaymentPending AND objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount) AND (CDbl(mc_gross) = CDbl(orderAmount))) then
			call objLogger.write("checkin notify: modificato ordine paypal --> id: "&idOrdine&"; pagamdone: 0 (pending)", "system", "info")
			call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, txn_id, objUtil.getUniqueKeyPendingPaymentTransaction(), 0, now(), objConn)		
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
			end if			
		else
			call objLogger.write("checkin notify: modificato ordine paypal --> id: "&idOrdine&"; pagamdone: 0", "system", "info")
			call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
			call objOrdine.changeStateOrder(idOrdine, 4, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, txn_id, objUtil.getUniqueKeyFailedPaymentTransaction(), 0, now(), objConn)
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
			end if
		end if

		call objMail.sendMailOrder(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))	
			
		Set objDB = nothing		
		
		Set objMail = Nothing
		Set objUtil = nothing
		Set objPaymentTrans = nothing


		'decide what to do based on txn_type - using Select Case
		'Select Case txn_type
		'	Case "subscr_signup"
		'		subscriptionPayments()
		'	Case "subscr_payment"
		'		subscriptionPayments()
		'	Case "subscr_modify"
		'		subscriptionPayments()
		'	Case "subscr_failed"
		'		subscriptionPayments()
		'	Case "subscr_cancel"
		'		subscriptionPayments()
		'	Case "subscr_eot"
		'		subscriptionPayments()
		'	Case Else
		'		allPayments()
		'End Select


	elseif (objHttp.responseText = "INVALID") then
		call objLogger.write("modificato ordine paypal --> id: "&idOrdine&"; objHttp.responseText: INVALID", "system", "info")
		' log for manual investigation
		' add code to handle the INVALID scenario
	else
		' error
	end if
	set objHttp = nothing
	
	Set obiFinalPaymentFieldMatch = nothing
	Set obiFinalPaymentFieldNotMatch = nothing
	Set fixedField = nothing
	Set obiCurrPaymentFieldMatch = nothing
	Set obiCurrPaymentFieldNotMatch = nothing
	Set objPaymentField = nothing
	
	Set objCurrPayment = nothing
	Set objPayment = nothing
	Set objCurrOrder = nothing
	Set objOrdine = nothing
else
	' TODO gestire caso ordine non trovato;
	' valutare redirect a pagina errore o altra pagina.
	'response.Write("Ordine non trovato!")
end if

Set objLogger = nothing
Set objModuleList = nothing
Set objModulePayment = nothing
%>