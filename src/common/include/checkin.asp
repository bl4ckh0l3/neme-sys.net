<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->
<%
	Dim objLogger
	Set objLogger = New LogClass

	Dim remoteAddrMatch
	remoteAddrMatch = false
	
	Dim objModulePayment, objModuleList, idOrdine, idOrdineAck, idModule, pageModuleCheckin
	idOrdine = -1
	idModule = -1

	pageModuleCheckin = ""
	Dim isHTTPS
	isHTTPS = Request.ServerVariables("HTTPS")
	If isHTTPS = "off" AND Application("use_https") = 1 Then
		pageModuleCheckin = "https://"&Request.ServerVariables("SERVER_NAME")
	Else
		pageModuleCheckin = "http://"&Request.ServerVariables("SERVER_NAME")
	End If
	pageModuleCheckin = pageModuleCheckin & Application("baseroot") & "/editor/payments/moduli/"
	Set objModulePayment = new PaymentModuleClass
	Set objModuleList = objModulePayment.getListaPaymentModuli()
	exit1For = false
	for each x in objModuleList
		idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
		for each z in idOrderFieldList
			if not(request(z) = "") then
				idOrdineAck = request(z)
				''Set objUtil = new UtilClass
				''Set objCrypt = new CryptClass
				''decripto il campo contenente il codice ordine
				''response.Write("idOrdineAck before decode: "&idOrdineAck&"<br>")
				''response.Write("idOrdineAck a f te r decode: "&objUtil.URLDecode(idOrdineAck)&"<br>")
				''idOrdineAck = objCrypt.DeCrypt(objUtil.URLDecode(idOrdineAck))
				''response.Write("idOrdineAck after: "&idOrdineAck&"<br>")
				''response.End()
				''Set objCrypt = nothing
				''Set objUtil = nothing
				'idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
				'idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
				idOrdine = idOrdineAck
				idModule = objModuleList(x).getID()
				pageModuleCheckin = pageModuleCheckin& objModuleList(x).getDirectory()
				pageModuleCheckin = pageModuleCheckin&"/"& objModuleList(x).getCheckinPage()
				
				' ***********    TODO  RIPRISTINARE SEMPRE QUESTO CONTROLLO IN AMBIENTE DI PRODUZIONE
				' ***********    L'UTILIZZO DI REMOTE_ADDR SEMBRA NON FUNZIONARE, RITORNA IP ERRATO
				''Dim idValidIPFieldList
				''idValidIPFieldList = Split(objModuleList(x).getIpProvider(),"|",-1,1)
				''for each t in idValidIPFieldList
					''if(t = request.ServerVariables("REMOTE_ADDR")) then
						remoteAddrMatch = true
						''Exit for
					''end if
				''next				

				exit1For = true
				Exit for
			end if
		next
		if(exit1For) then exit for end if
	next
	
	if(idOrdine <> "-1" AND remoteAddrMatch AND Cint(idModule) <> -1) then
		Dim objOrdine, objCurrOrder, objPayment, objCurrPayment
		Set objOrdine = New OrderClass	
		'Set objCurrOrder = objOrdine.findOrdineByID(idOrdine, false)
		'Set objPayment = New PaymentClass
		'Set objCurrPayment = objPayment.findPaymentByID(objCurrOrder.getTipoPagam())	
		'Set objPaymentField = new PaymentFieldClass
		'Set obiCurrPaymentFieldMatch = objPaymentField.getListaCheckinDoMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
		'Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaCheckinNotMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
		'Set fixedField = objPaymentField.getListaMatchFields()		
		'Set obiFinalPaymentFieldMatch = Server.CreateObject("Scripting.Dictionary")
		'Set obiFinalPaymentFieldNotMatch = Server.CreateObject("Scripting.Dictionary")

		'************** GESTIONE PROCEDURA CONFERMA PAGAMENTO *********************
		Dim boolChangeStatusOrder, items, orderField
		boolChangeStatusOrder = false
		
		' recuperare tutti i campi obbligatori inviati dal sistema di pagamento
		'for each k in obiCurrPaymentFieldMatch
			'if not(request(k) = "") then
				'fixedField.item(obiCurrPaymentFieldMatch(k).getMatchField()) = request(k)
				'obiFinalPaymentFieldMatch.add k, request(k)
			'end if
		'next	 
						
		' recuperare tutti i campi specifici inviati dal sistema di pagamento
		'for each z in obiCurrPaymentFieldNotMatch
			'if not(request(z) = "") then
				'obiFinalPaymentFieldNotMatch.add z, request(z)
			'else
				'obiFinalPaymentFieldNotMatch.add z, obiCurrPaymentFieldNotMatch(z).getValueField()
			'end if
		'next
						
		' chiamata a pagina checkin specifica con objHttp.open, passare tutti i parametri necessari
		Dim checkin_parameters
		checkin_parameters = ""
		'for each q in obiFinalPaymentFieldMatch
			'checkin_parameters = checkin_parameters &q&"="&obiFinalPaymentFieldMatch(q)&"&"
		'next	
		'for each j in obiFinalPaymentFieldNotMatch
			'checkin_parameters = checkin_parameters &j&"="&obiFinalPaymentFieldNotMatch(j)&"&"
		'next		
		'checkin_parameters = Left(checkin_parameters, Len(checkin_parameters)-1)
		checkin_parameters = Request.ServerVariables("QUERY_STRING")'
		
		set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0") 'Msxml2.ServerXMLHTTP.6.0 - Microsoft.XMLHTTP
		'objHttp.setTimeouts 30000, 60000, 30000, 120000
		objHttp.open "POST", pageModuleCheckin, false
		objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
		objHttp.Send(checkin_parameters)
		Set objXML = objHTTP.ResponseXML
		'response.write(objHTTP.responseText)
		'call objLogger.write("checkin: --> objHTTP.responseText: " &objHTTP.responseText, "system", "debug")

		set items = objXML.getElementsByTagName("payment_confirmed")
		val = items(0).childNodes(0).nodeValue		
		if(Cbool(val)) then
			boolChangeStatusOrder = true
		end if

		Set orderField = objXML.getElementsByTagName("orderid_confirmed")
		order = orderField(0).childNodes(0).nodeValue
		if(Cint(order) <> -1) then
			idOrdine = order
		else
			idOrdine = -1
		end if
		
		set items = nothing
		Set objXML = nothing
		set objHttp = nothing	

		if(Cint(idOrdine) <> -1) then
			' se tutto corretto inviare mail solo all'amministratore ecommerce che l'ordine è stato effettuato
			' risulta la prima verifica di pagamento, è stato cambiato lo stato ordine, ma non è ancora stato notificato il pagamento
			' la notifica di pagamento viene cambiata solo nella pagina di notifica			
			'******************** QUESTA CHIAMATA E' DA GESTIRE IN SICUREZZA
			Dim objMail
			Set objMail = New SendMailClass
			if(boolChangeStatusOrder) then
				call objOrdine.changePagamDoneOrderNoTransaction(idOrdine, 1)	
				' ****************  TODO inviare mail amministratore
				call objMail.sendMailOrder(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
		
			else
				call objOrdine.changePagamDoneOrderNoTransaction(idOrdine, 0)
				' ****************  TODO inviare mail INVESTIGAZIONE MANUALE PAGAMENTO NON ESEGUITO all'amministratore	
				call objMail.sendMailOrder(idOrdine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
			end if	
			Set objMail = Nothing					
			'Set obiFinalPaymentFieldMatch = nothing
			'Set obiFinalPaymentFieldNotMatch = nothing
			'Set fixedField = nothing
			'Set obiCurrPaymentFieldMatch = nothing
			'Set obiCurrPaymentFieldNotMatch = nothing
			'Set objPaymentField = nothing
			
			'***** finita la procedura se tutto a buon fine invio l'utente alla pagina corretta di conferma a seconda della tipologia utente
			if not(isEmpty(Session("objUtenteLogged"))) OR not(isEmpty(Session("objCMSUtenteLogged")))then
				Dim objUserLogged, objUserLoggedTmp, objCMSUtenteLoggedTmp
				Set objUserLogged = new UserClass
				Dim strRuoloLogged
				strRuoloLogged = -1
				
				if not(isEmpty(Session("objUtenteLogged"))) AND not(Session("objUtenteLogged") = "") then
					Set objUserLoggedTmp = objUserLogged.findUserByID(Session("objUtenteLogged"))
					if not(isNull(objUserLoggedTmp)) AND (Instr(1, typename(objUserLoggedTmp), "UserClass", 1) > 0) then strRuoloLogged = objUserLoggedTmp.getRuolo() end if
					Set objUserLoggedTmp = nothing
				end if
				if not(isEmpty(Session("objCMSUtenteLogged")))then
					Set objCMSUtenteLoggedTmp = objUserLogged.findUserByID(Session("objCMSUtenteLogged"))
					if not(isNull(objCMSUtenteLoggedTmp)) AND (Instr(1, typename(objCMSUtenteLoggedTmp), "UserClass", 1) > 0) then strRuoloLogged = objCMSUtenteLoggedTmp.getRuolo() end if
					Set objCMSUtenteLoggedTmp = nothing
				end if
				
				Set objUserLogged = nothing
				
				if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
					response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ConfirmOrdineCarrello.asp?id_ordine="&idOrdine)
				else
					response.Redirect(Application("baseroot")&"/editor/ordini/ConfirmInsertOrdine.asp?id_ordine="&idOrdine)
				end if
			else
				response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ConfirmOrdineCarrello.asp?id_ordine="&idOrdine)
			end if		
			'Set objCurrPayment = nothing
			'Set objPayment = nothing
			'Set objCurrOrder = nothing
			Set objOrdine = nothing
		else
			response.Write("Ordine non trovato!")
		end if
	else
		' TODO gestire caso ordine non trovato;
		' valutare redirect a pagina errore o altra pagina.
		response.Write("Ordine non trovato!")
	end if
	
	Set objModuleList = nothing
	Set objModulePayment = nothing
	Set objLogger = nothing
%>