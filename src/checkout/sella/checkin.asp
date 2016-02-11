<%@LANGUAGE="VBScript"%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
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

idOrdine = -1
idModule = -1

Dim objdeCrypt
'Sintassi Oggetto COM
Set objdeCrypt =Server.Createobject("GestPayCrypt.GestPayCrypt")

'Set objModulePayment = new PaymentModuleClass
'Set objModuleList = objModulePayment.getListaPaymentModuli()
'exit1For = false	
'for each x in objModuleList
	'idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
	'for each z in idOrderFieldList
		'if not(request.form(z) = "") then
			'idOrdineAck = request.form(z)
			'idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",0)))	
			'idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",0)-1)
			'idOrdine = idOrdineAck
			'idModule = objModuleList(x).getID()
			'exit1For = true
			'Exit for
		'end if
	'next
	'if(exit1For) then exit for end if
'next
'Set objModuleList = nothing
'Set objModulePayment = nothing

parametro_a = trim(request("a"))
parametro_b = trim(request("b"))

objdeCrypt.SetShopLogin(parametro_a)
objdeCrypt.SetEncryptedString(parametro_b)

call objdeCrypt.Decrypt

if Err.number = 0 then 
	idOrdineAck = trim(objdeCrypt.GetShopTransactionID)
	idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
	idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
	idOrdine = idOrdineAck	
end if

if not(idOrdine = "") AND not(CInt(idOrdine) = -1) then
	Dim myshoplogin,mycurrency,myamount,myshoptransactionID,mytransactionresult,myerrorcode,myerrordescription,myauthorizationcode
	myshoplogin=trim(objdeCrypt.GetShopLogin)
	mycurrency=objdeCrypt.GetCurrency
	myamount=objdeCrypt.GetAmount
	myshoptransactionID=trim(objdeCrypt.GetShopTransactionID)
	mytransactionresult=trim(objdeCrypt.GetTransactionResult)
	myauthorizationcode=trim(objdeCrypt.GetAuthorizationCode)
	myerrorcode=trim(objdeCrypt.GetErrorCode)
	myerrordescription=trim(objdeCrypt.GetErrorDescription)

	'call objLogger.write("myshoplogin sella chechin --> "&myshoplogin, "system", "debug")
	'call objLogger.write("mycurrency sella chechin --> "&mycurrency, "system", "debug")
	'call objLogger.write("myamount sella chechin --> "&myamount, "system", "debug")
	'call objLogger.write("myshoptransactionID sella chechin --> "&myshoptransactionID, "system", "debug")
	'call objLogger.write("mytransactionresult sella chechin --> "&mytransactionresult, "system", "debug")
	'call objLogger.write("myauthorizationcode sella chechin --> "&myauthorizationcode, "system", "debug")
	'call objLogger.write("myerrorcode sella chechin --> "&myerrorcode, "system", "debug")
	'call objLogger.write("myerrordescription sella chechin --> "&myerrordescription, "system", "debug")

	Dim objOrdine, objCurrOrder, objPayment, objCurrPayment
	Set objOrdine = New OrderClass	
	Set objCurrOrder = objOrdine.findOrdineByID(idOrdine, false)
	Set objPayment = New PaymentClass
	Set objCurrPayment = objPayment.findPaymentByID(objCurrOrder.getTipoPagam())	
	idModule = objCurrPayment.getPaymentModuleID()
	Set objCurrPayment = nothing
	Set objPayment = nothing
	Set objOrdine = nothing	

	Dim objPaymentTrans, objUtil
	Set objUtil = new UtilClass
	Set objPaymentTrans = new PaymentTransactionClass

	if ((mytransactionresult = "OK") OR (mytransactionresult = "XX")) then		
		' ***** TODO: verificare se esiste già una transazione per questo ordine e nel caso gestire comportamento corretto (da valutare update+continuazione normale o redirezione verso pagina di errore, o altro)
		call objPaymentTrans.insertPaymentTransactionNoTrans(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeySuccessPaymentTransaction(), 0, now())
		paymentConfirmed = true
	Else
		'******************* log for manual investigation
		call objPaymentTrans.insertPaymentTransactionNoTrans(idOrdine, idModule, myauthorizationcode, objUtil.getUniqueKeyFailedPaymentTransaction(), 0, now())
		paymentConfirmed = false
	End If
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