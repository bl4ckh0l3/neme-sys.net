<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<%
Dim objLogger
Set objLogger = New LogClass
'call objLogger.write("aggiornamento payment list", "system", "debug")

Dim totale_carrello, tot_and_spese, tipo_pagam, payment_selected
totale_carrello = request("totale_carrello")
tot_and_spese = request("tot_and_spese")
tipo_pagam =  request("tipo_pagam")
payment_selected = false

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

On Error Resume Next
Dim objPayment, objTmpPayment, objListaPayment, objModuloPayment, objModulo, strLogo, loadDirectPayment		   
loadDirectPayment = null
if(tot_and_spese<=0) then
	loadDirectPayment = 0
end if
Set objPayment = New PaymentClass
Set objModulo = new PaymentModuleClass					   
Set objListaPayment = objPayment.getListaPayment(1,loadDirectPayment)
if not(isEmpty(objListaPayment)) AND (Instr(1, typename(objListaPayment), "Dictionary", 1) > 0) then%>
	<script language="Javascript">
	<%for each k in objListaPayment.Keys%>
	listPaymentMethods.put("<%=k%>","<%=objListaPayment(k).getCommission()&"|"&objListaPayment(k).getCommissionType()%>");	
	<%next%>
	</script>
	<ul>
	<%for each k in objListaPayment.Keys
	strLogo = ""
	if(Cint(objListaPayment(k).getPaymentModuleID()) <> -1) then
	Set objModuloPayment = objModulo.findPaymentModuloByID(objListaPayment(k).getPaymentModuleID())
	strLogo = objModuloPayment.getLogo()
	Set objModuloPayment = nothing
	end if
	if (tipo_pagam = CStr(k)) then payment_selected=true end if%>
	<li><INPUT type="radio" name="tipo_pagam" value="<%=k%>" <%if (tipo_pagam = CStr(k)) then response.Write("checked='checked'") end if%> onclick="javascript:ajaxSetSessionPayAndBills(this),calculatePaymentCommission('<%=totale_carrello%>',<%=k%>,'<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%=currClass.findCurrencyByCurrency(Session("currency")).getRate()%>');"> <%=lang.getTranslated(objListaPayment(k).getKeywordMultilingua())%>&nbsp;<%=strLogo%></li>
	<%next%>
	</ul>
	<%if not(payment_selected) then%>
		<script language="Javascript">
		$(".payment_commission").empty();
		$(".payment_commission").append('0,00');
		</script>
	<%end if
end if						  

Set objModulo = nothing
Set objListaPayment = nothing
Set objPayment = nothing

If Err.Number<>0 then
	call objLogger.write("aggiornamento payment list ERR: "&Err.description, "system", "debug")
end if

Set objLogger = nothing
%>