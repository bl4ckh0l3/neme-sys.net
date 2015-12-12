<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing

	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
end if	

Dim objLogger
Set objLogger = New LogClass
'call objLogger.write("aggiornamento payment list", "system", "debug")

Dim totale_ord, totale_imp_ord, totale_tasse_ord, tipo_pagam, payment_selected
totale_ord = request("totale_ord")
totale_imp_ord = request("totale_imp_ord")
totale_tasse_ord = request("totale_tasse_ord")
totale_rule_ord = request("totale_rule_ord")
tipo_pagam =  request("tipo_pagam")
payment_selected = false

On Error Resume Next
Dim objPayment, objTmpPayment, objListaPayment, loadDirectPayment
loadDirectPayment = null
Set objPayment = New PaymentClass
if(totale_ord<=0) then
loadDirectPayment = 0
end if
Set objListaPayment = objPayment.getListaPayment(1,loadDirectPayment)	


if not(isEmpty(objListaPayment)) AND (Instr(1, typename(objListaPayment), "Dictionary", 1) > 0) then%>
	<script language="Javascript">
	<%for each k in objListaPayment.Keys%>
	listPaymentMethods.put("<%=k%>","<%=objListaPayment(k).getCommission()&"|"&objListaPayment(k).getCommissionType()%>");	
	<%next%>
	</script>
	<%for each k in objListaPayment.Keys
		if (tipo_pagam = CStr(k)) then payment_selected=true end if
		%>
		<INPUT type="radio" name="tipo_pagam" value="<%=k%>" <%if (tipo_pagam = CStr(k)) then response.Write("checked='checked'") end if%> onclick="javascript:calculatePaymentCommission('<%=totale_imp_ord%>','<%=totale_tasse_ord%>','<%=totale_rule_ord%>',<%=k%>);"> <%if not(langEditor.getTranslated(objListaPayment(k).getKeywordMultilingua())="") then response.write(langEditor.getTranslated(objListaPayment(k).getKeywordMultilingua())) else response.write(objListaPayment(k).getKeywordMultilingua()) end if%><BR>
	<%next

	if not(payment_selected) then%>
		<script language="Javascript">
		$("#payment_commission").empty();
		$("#payment_commission").append('0,00');
		</script>
	<%end if
end if
Set objListaPayment = nothing
Set objPayment = nothing

If Err.Number<>0 then
	call objLogger.write("aggiornamento payment list ERR: "&Err.description, "system", "debug")
end if

Set objLogger = nothing
%>