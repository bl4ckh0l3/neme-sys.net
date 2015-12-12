<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->
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

Set listaCheckoutMatchFields = Server.CreateObject("Scripting.Dictionary")
'compongo il codice per l'invio ordine criptato
'Set objCrypt = new CryptClass
'listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), objCrypt.EnCrypt(order_guid&"|"&id_ordine&"|"&amount)
listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), order_guid&"|"&id_ordine&"|"&amount
listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderAmountPayment(), amount
'Set objCrypt = nothing

Dim objPayment, obiCurrPayment, objPaymentField, fixedField, obiCurrPaymentFieldMatch, obiCurrPaymentFieldNotMatch
Set objPayment = New PaymentClass
Set obiCurrPayment = objPayment.findPaymentByID(payment_id)
Set objPaymentField = new PaymentFieldClass
Set obiCurrPaymentFieldMatch = objPaymentField.getListaPaymentFieldDoMatch(payment_id, obiCurrPayment.getPaymentModuleID())
Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaPaymentFieldNotMatch(payment_id, obiCurrPayment.getPaymentModuleID())
Set fixedField = objPaymentField.getListaMatchFields()

externalURL = objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), objUtil.getUniqueKeyExtURLPayment()).getValueField()

Set fixedField = nothing
Set objPaymentField = nothing
Set obiCurrPayment = nothing
Set objPayment = nothing
Set objUtil = nothing
%>
<HTML>
<BODY onload="document.checkout_redirect.submit();">
<form method="post" name="checkout_redirect" action="<%=externalURL%>">
<%For Each y In obiCurrPaymentFieldMatch%>
<input type="hidden" name="<%=obiCurrPaymentFieldMatch(y).getNameField()%>" value="<%=listaCheckoutMatchFields(obiCurrPaymentFieldMatch(y).getMatchField())%>">
<%Next
Set obiCurrPaymentFieldMatch = nothing%>
<%For Each y In obiCurrPaymentFieldNotMatch%>
<input type="hidden" name="<%=obiCurrPaymentFieldNotMatch(y).getNameField()%>" value="<%=obiCurrPaymentFieldNotMatch(y).getValueField()%>">
<%Next
Set obiCurrPaymentFieldNotMatch = nothing
Set listaCheckoutMatchFields = nothing%>
</form>
</BODY>
</HTML>