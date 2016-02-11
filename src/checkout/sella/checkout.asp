<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<%
Dim objListPairKeyValue
Dim id_ordine, amount, order_guid, payment_id, externalURL, listaCheckoutMatchFields

Set objListPairKeyValue = Server.CreateObject("Scripting.Dictionary")
For Each x in request.form()
	key = x
	value = request.form(x)	
	objListPairKeyValue.add key, value
Next
 
Dim objUtil
Set objUtil = new UtilClass

id_ordine= objListPairKeyValue.item(objUtil.getUniqueKeyOrderIdPayment()) 
amount= objListPairKeyValue.item(objUtil.getUniqueKeyOrderAmountPayment()) 
order_guid= objListPairKeyValue.item(objUtil.getUniqueKeyOrderGUIDPayment()) 
payment_id= objListPairKeyValue.item(objUtil.getUniqueKeyOrderTypePayment())

id_ordine_complete=order_guid&"|"&id_ordine&"|"&amount

Dim objPayment, obiCurrPayment, objPaymentField
Set objPayment = New PaymentClass
Set obiCurrPayment = objPayment.findPaymentByID(payment_id)
Set objPaymentField = new PaymentFieldClass

externalURL = objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), objUtil.getUniqueKeyExtURLPayment()).getValueField()
myshoplogin= objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), "shoplogin").getValueField()
mycurrency=objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), "currency").getValueField()
myamount=amount
myshoptransactionID=id_ordine_complete

Set objPaymentField = nothing
Set obiCurrPayment = nothing
Set objPayment = nothing
Set objUtil = nothing

Dim objCrypt
'Sintassi Oggetto COM
Set objCrypt =Server.Createobject("GestPayCrypt.GestPayCrypt")

objCrypt.SetShopLogin(myshoplogin)
objCrypt.SetCurrency(mycurrency)
objCrypt.SetAmount(myamount)
objCrypt.SetShopTransactionID(myshoptransactionID)

'response.write("objCrypt.getShopLogin: "&objCrypt.GetShopLogin()&"<br>")
'response.write("objCrypt.GetCurrency: "&objCrypt.GetCurrency()&"<br>")
'response.write("objCrypt.GetAmount: "&objCrypt.GetAmount()&"<br>")
'response.write("objCrypt.GetShopTransactionID: "&objCrypt.GetShopTransactionID()&"<br>")

call objCrypt.Encrypt()

'response.write("objCrypt.GetShopLogin after encrypt: "&objCrypt.GetShopLogin()&"<br>")
'response.write("objCrypt.GetEncryptedString after encrypt: "&objCrypt.GetEncryptedString()&"<br>")

'response.write("objCrypt.GetErrorCode: "&objCrypt.GetErrorCode()&"<br>")
'response.write("objCrypt.GetErrorDescription: "&objCrypt.GetErrorDescription()&"<br>")

if objCrypt.GetErrorCode = 0 then
	b = objCrypt.GetEncryptedString
	a = objCrypt.GetShopLogin
end if
%>

<HTML>
<BODY onload="document.checkout_redirect.submit();">
<!--<BODY>-->
<form method="post" name="checkout_redirect" action="<%=externalURL%>">

<input name="a" type="hidden" value="<%=a%>">
<input name="b" type="hidden" value="<%=b%>">

</form>
</BODY>
</HTML>