<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->
<%
Response.ContentType = "text/xml"

'************************ GESTIRE TUTTI I CONTROLLI DI VALIDITA' PAGAMENTO ORDINE
Dim paymentConfirmed
paymentConfirmed = false

Dim query
Dim objHttp
Dim sQuerystring
Dim sParts, iParts, aParts
Dim sResults, sKey, sValue
Dim i, result
Dim firstName, lastName, itemName, mcGross, mcCurrency
Dim idOrdine, idModule, idOrdineAck, authToken, txToken, externalURL
Dim objLogger
Set objLogger = New LogClass

'call objLogger.write("checkin paypal: --> entrato", "system", "debug")

idOrdine = -1
idModule = -1

Set objModulePayment = new PaymentModuleClass
Set objModuleList = objModulePayment.getListaPaymentModuli()
exit1For = false	
for each x in objModuleList
	idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
	for each z in idOrderFieldList
		if not(request.form(z) = "") then
			idOrdineAck = request.form(z)

			Set objUtil = new UtilClass
			' eseguo il decode dell'url passato per avere i caratteri corretti
			idOrdineAck = objUtil.URLDecode(idOrdineAck)			
			'Set objCrypt = new CryptClass
			' decripto il campo contenente il codice ordine
			'idOrdineAck = objCrypt.DeCrypt(idOrdineAck)
			'Set objCrypt = nothing
			Set objUtil = nothing
			idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",0)))	
			idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",0)-1)
			idOrdine = idOrdineAck
			idModule = objModuleList(x).getID()
			exit1For = true
			Exit for
		end if
	next
	if(exit1For) then exit for end if
next
Set objModuleList = nothing
Set objModulePayment = nothing

authToken = ""
txToken = ""

'call objLogger.write("checkin paypal: --> id_ordine: "&idOrdine&"; request.form(): "&request.form(), "system", "debug")

if not(idOrdine = "") AND not(CInt(idOrdine) = -1) then
	Dim objOrdine, objCurrOrder, objPayment, objCurrPayment
	Set objOrdine = New OrderClass	
	Set objCurrOrder = objOrdine.findOrdineByID(idOrdine, false)
	
	'call objLogger.write("checkin paypal: --> objCurrOrder: "& typename(objCurrOrder), "system", "debug")
	
	Set objPayment = New PaymentClass
	Set objCurrPayment = objPayment.findPaymentByID(objCurrOrder.getTipoPagam())	
	Set objPaymentField = new PaymentFieldClass
	
	'call objLogger.write("checkin paypal: --> objCurrPayment.getPaymentID(): " & objCurrPayment.getPaymentID(), "system", "debug")
	'call objLogger.write("checkin paypal: --> objCurrPayment.getPaymentModuleID(): " & objCurrPayment.getPaymentModuleID(), "system", "debug")
	
	Set obiCurrPaymentFieldMatch = objPaymentField.getListaCheckinDoMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
	Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaCheckinNotMatch(objCurrPayment.getPaymentID(), objCurrPayment.getPaymentModuleID())
	'Set fixedField = objPaymentField.getListaMatchFields()		
	Set obiFinalPaymentFieldMatch = Server.CreateObject("Scripting.Dictionary")
	Set obiFinalPaymentFieldNotMatch = Server.CreateObject("Scripting.Dictionary")
	
	'call objLogger.write("checkin paypal: --> superato recupero field paypal", "system", "debug")

	' recuperare tutti i campi obbligatori inviati dal sistema di pagamento
	for each k in obiCurrPaymentFieldMatch
		if not(request(k) = "") then
			obiFinalPaymentFieldMatch.add k, request(k)
			'call objLogger.write("checkin paypal: --> k: "&k&"; obiFinalPaymentFieldMatch(k): "&obiFinalPaymentFieldMatch(k), "system", "debug")
		end if
	next	 
					
	' recuperare tutti i campi specifici inviati dal sistema di pagamento
	for each z in obiCurrPaymentFieldNotMatch
		if not(request(z) = "") then
			obiFinalPaymentFieldNotMatch.add z, request(z)
		else
			obiFinalPaymentFieldNotMatch.add z, obiCurrPaymentFieldNotMatch(z).getValueField()
		end if
		
		'call objLogger.write("checkin paypal: --> z: "&z&"; obiFinalPaymentFieldNotMatch(z): "&obiFinalPaymentFieldNotMatch(z), "system", "debug")
	next
	

	Dim objPaymentTrans, objUtil
	Set objUtil = new UtilClass
	'authToken = request("at")
	'txToken = request("tx")
	authToken = obiFinalPaymentFieldNotMatch("at")
	txToken = obiFinalPaymentFieldNotMatch("tx")
	'call objLogger.write("checkin paypal: --> authToken: "&authToken, "system", "debug")
	'call objLogger.write("checkin paypal: --> txToken: "&txToken, "system", "debug")

	query = "cmd=_notify-synch&tx=" & txToken & "&at=" & authToken
	
	'call objLogger.write("checkin paypal: --> query: "&query, "system", "debug")

	Set objOrdine = nothing
	
	externalURL = obiFinalPaymentFieldNotMatch(objUtil.getUniqueKeyExtURLPayment())	
	'call objLogger.write("checkin paypal: --> externalURL: "&externalURL, "system", "debug")

	On  Error Resume Next

	set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
	objHttp.open "POST", externalURL, false
	objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
	objHttp.Send(query)

	sQuerystring = objHttp.responseText
	
	if Err.number <> 0 then
		call objLogger.write("checkin paypal: --> Err.description: "&Err.description, "system", "error")
	end if
	
	'call objLogger.write("checkin paypal: --> sQuerystring: "&sQuerystring, "system", "debug")
	
	Set objPaymentTrans = new PaymentTransactionClass

	If Mid(sQuerystring,1,7) = "SUCCESS" Then
		'sQuerystring = Mid(sQuerystring,9)
		'sParts = Split(sQuerystring, vbLf)
		'iParts = UBound(sParts) - 1
		'ReDim sResults(iParts, 1)
		'For i = 0 To iParts
		'aParts = Split(sParts(i), "=")
		'sKey = aParts(0)
		'sValue = aParts(1)
		'sResults(i, 0) = sKey
		'sResults(i, 1) = sValue
		
		'Select Case sKey
		'Case "first_name"
		'firstName = sValue
		'Case "last_name"
		'lastName = sValue
		'Case "item_name"
		'itemName = sValue
		'Case "mc_gross"
		'mcGross = sValue
		'Case "mc_currency"
		'mcCurrency = sValue
		'End Select
		'Next
		
		' ***** TODO: verificare se esiste già una transazione per questo ordine e nel caso gestire comportamento corretto (da valutare update+continuazione normale o redirezione verso pagina di errore, o altro)
		call objPaymentTrans.insertPaymentTransactionNoTrans(idOrdine, idModule, txToken, objUtil.getUniqueKeySuccessPaymentTransaction(), 0, now())
		paymentConfirmed = true
	Else
		'******************* log for manual investigation
		call objPaymentTrans.insertPaymentTransactionNoTrans(idOrdine, idModule, txToken, objUtil.getUniqueKeyFailedPaymentTransaction(), 0, now())
		paymentConfirmed = false
	End If
	
	Set objHttp = nothing
	Set objUtil = nothing
	Set objPaymentTrans = nothing
end if

Set objLogger = nothing

response.write("<result_checkin>")
if(paymentConfirmed) then
	response.write("<payment_confirmed>true</payment_confirmed>")
	response.write("<orderid_confirmed>"&idOrdine&"</orderid_confirmed>")
else
	response.write("<payment_confirmed>false</payment_confirmed>")
	response.write("<orderid_confirmed>"&idOrdine&"</orderid_confirmed>")
end if
response.write("</result_checkin>")
%>

