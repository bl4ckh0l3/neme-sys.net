<%@LANGUAGE="VBScript"%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<%
' dim some variables
Dim Item_name, Item_number, Payment_status, Payment_amount
Dim Txn_id, Receiver_email, Payer_email
Dim objHttp, str
	
Dim objModulePayment, objModuleList, idOrdine, idModule, orderGuid, orderAmount, pageModuleCheckin, externalURL

idOrdine = -1
idModule = -1

Dim objdeCrypt
'Sintassi Oggetto COM
Set objdeCrypt =Server.Createobject("GestPayCrypt.GestPayCrypt")

Dim objLogger
Set objLogger = New LogClass

parametro_a = trim(request("a"))
parametro_b = trim(request("b"))

objdeCrypt.SetShopLogin(parametro_a)
objdeCrypt.SetEncryptedString(parametro_b)

call objdeCrypt.Decrypt

if Err.number = 0 then 
	idOrdineAck = trim(objdeCrypt.GetShopTransactionID)
	if(Len(idOrdineAck)>0) then
		idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
		idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
		idOrdine = idOrdineAck	
	end if
end if

if(Cint(idOrdine) <> -1) then	
	Dim myshoplogin,mycurrency,myamount,myshoptransactionID,mytransactionresult,myerrorcode,myerrordescription,myauthorizationcode
	myshoplogin=trim(objdeCrypt.GetShopLogin)
	mycurrency=objdeCrypt.GetCurrency
	myamount=objdeCrypt.GetAmount
	myshoptransactionID=trim(objdeCrypt.GetShopTransactionID)
	mytransactionresult=trim(objdeCrypt.GetTransactionResult)
	myauthorizationcode=trim(objdeCrypt.GetAuthorizationCode)
	myerrorcode=trim(objdeCrypt.GetErrorCode)
	myerrordescription=trim(objdeCrypt.GetErrorDescription)
			
	Dim objOrdine, objCurrOrder, objPayment, objCurrPayment
	Set objOrdine = New OrderClass	
	Set objCurrOrder = objOrdine.findOrdineByID(idOrdine, true)	
	Set objPayment = New PaymentClass
	Set objCurrPayment = objPayment.findPaymentByID(objCurrOrder.getTipoPagam())
	idModule = objCurrPayment.getPaymentModuleID()
	
	'************** GESTIONE PROCEDURA CONFERMA PAGAMENTO *********************
	
	'call objLogger.write("myshoplogin sella chechin notif --> "&myshoplogin, "system", "debug")
	'call objLogger.write("mycurrency sella chechin notif --> "&mycurrency, "system", "debug")
	'call objLogger.write("myamount sella chechin notif --> "&myamount, "system", "debug")
	'call objLogger.write("myshoptransactionID sella chechin notif --> "&myshoptransactionID, "system", "debug")
	'call objLogger.write("mytransactionresult sella chechin notif --> "&mytransactionresult, "system", "debug")
	'call objLogger.write("myauthorizationcode sella chechin notif --> "&myauthorizationcode, "system", "debug")
	'call objLogger.write("myerrorcode sella chechin notif --> "&myerrorcode, "system", "debug")
	'call objLogger.write("myerrordescription sella chechin notif --> "&myerrordescription, "system", "debug")
	
	' gestire la verifica validità sull'ordine
	Dim objPaymentTrans, objUtil
	Set objUtil = new UtilClass		
	Set objPaymentTrans = new PaymentTransactionClass
	idOrdineAckResp = myshoptransactionID
	orderGuid = Left(idOrdineAckResp,InStr(1,idOrdineAckResp,"|",0)-1)
	idOrdineAckResp =  Right(idOrdineAckResp,(Len(idOrdineAckResp)-InStr(1,idOrdineAckResp,"|",0)))	
	orderAmount = Right(idOrdineAckResp,(Len(idOrdineAckResp)-InStr(1,idOrdineAckResp,"|",0)))
	idOrdineAckResp = Left(idOrdineAckResp,InStr(1,idOrdineAckResp,"|",0)-1)
	idOrdine = idOrdineAckResp
	'call objLogger.write("idOrdine --> "&idOrdine, "system", "debug")
	'call objLogger.write("orderAmount --> "&orderAmount, "system", "debug")
	'call objLogger.write("orderGuid --> "&orderGuid, "system", "debug")

	Set objDB = New DBManagerClass

	Dim objMail
	Set objMail = New SendMailClass

	' Check notification validation
	if ((mytransactionresult = "OK") OR (mytransactionresult = "XX")) then
		' check that mytransactionresult=Completed or Pending
		boolPaymentComplete = (mytransactionresult = "OK")
		boolPaymentPending = (mytransactionresult = "XX")
		'call objLogger.write("checkin notify: boolPaymentComplete --> "&boolPaymentComplete, "system", "debug")
		'call objLogger.write("checkin notify: boolPaymentPending --> "&boolPaymentPending, "system", "debug")
				
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		if(boolPaymentComplete AND objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount) AND (CDbl(myamount) = CDbl(orderAmount))) then
			call objLogger.write("modificato ordine sella --> id: "&idOrdine&"; pagamdone: 1", "system", "info")
			' se tutto corretto cambiare stato ordine : pagato e notificato			
			'******************** QUESTA CHIAMATA E' DA GESTIRE IN SICUREZZA
			call objOrdine.changePagamDoneOrder(idOrdine, 1, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeySuccessPaymentTransaction(), 1, now(), objConn)	
			
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
						'call objLogger.write("modificato ordine sella --> expireDate: "&expireDate, "system", "debug")
		
						if not(isNull(objDownProd4Order.getFileByIDProdDown(idOrdine, tmpProd.getIDProdotto(), r))) then
							'call objLogger.write("modifyDownProd sella --> objDownProd: "&objDownProd.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r).getID()&"; id_ordine: "&r&"; IDProdotto: "&tmpProd.getIDProdotto()&"; objDownProd: "&r&"; id_utente: "&id_utente, "system", "debug")
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
			
		elseif(boolPaymentPending AND objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount) AND (CDbl(myamount) = CDbl(orderAmount))) then
			call objLogger.write("modificato ordine sella --> id: "&idOrdine&"; pagamdone: 0 (pending)", "system", "info")
			call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeyPendingPaymentTransaction(), 0, now(), objConn)	
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
			end if		
		else
			call objLogger.write("modificato ordine sella --> id: "&idOrdine&"; pagamdone: 0", "system", "info")
			call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
			call objOrdine.changeStateOrder(idOrdine, 4, objConn)
			call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeyFailedPaymentTransaction(), 0, now(), objConn)	
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
			end if			
		end if
			
		call objMail.sendMailOrder(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))			
		
		Set objPaymentTrans = nothing
	elseif (mytransactionresult = "KO" AND objOrdine.verifyOrder(idOrdine, orderGuid, orderAmount) AND (CDbl(myamount) = CDbl(orderAmount))) then
		call objLogger.write("modificato ordine sella --> id: "&idOrdine&"; mytransactionresult: KO; pagamdone: 0", "system", "info")
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
		call objOrdine.changeStateOrder(idOrdine, 4, objConn)
		call objPaymentTrans.insertPaymentTransaction(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeyFailedPaymentTransaction(), 0, now(), objConn)			
		call objMail.sendMailOrder(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
		end if	
	else
		' error
	end if
	Set objDB = nothing		

	Set objMail = Nothing
	Set objUtil = nothing	
	
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
%>
<html>
</html>