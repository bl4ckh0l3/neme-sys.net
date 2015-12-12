<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="SellaClass.asp" -->

<br/><br/><span class="labelFormTitle"><%=langEditor.getTranslated("backend.payment.detail.table.field.label.list_intro")%>:</span><br/><br/>			
<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUserLogged, objUserLoggedTmp
Set objUserLoggedTmp = new UserClass
Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
Set objUserLoggedTmp = nothing

Dim strRuoloLogged
strRuoloLogged = objUserLogged.getRuolo()
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

'***** CREO UNA MAPPA CON I CAMPI NECESSARI PER QUESTO SISTEMA DI PAGAMENTO
Dim objSella
Set objSella = new SellaClass
Set objDictSellaNeedField = objSella.getListaSellaFieldMatch()
Set objDictSellaField = objSella.getListaSellaFieldNotMatch()
Set objSella = nothing


Dim objPaymentField, objPaymentFixedMatchFieldList, objPaymentFieldListMatch, matchCurrPaymentValue, matchCurrPaymentName
Dim modulo, id_payment
Set objPaymentField = new PaymentFieldClass

modulo  = Session("id_modulo")
id_payment = Session("id_payment")%>
<%On Error Resume Next
Set objPaymentFixedMatchFieldList = objPaymentField.getListaMatchFields()
if (Instr(1, typename(objPaymentFixedMatchFieldList), "dictionary", 1) > 0) then%>
<div id="matchPaymentField" align="left" style="float:top;" title="<%=langEditor.getTranslated("backend.payment.detail.table.field.label.list_needed")%>">
<div align="left" style="float:top;width:200px;">				
<span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.field.label.value")%></span>
</div>
<%for each y in objPaymentFixedMatchFieldList.Keys
	for each q in objDictSellaNeedField.Keys
		if(y = objDictSellaNeedField.item(q)) then%>	
		<div align="left" style="float:top">				
		<input type="text" name="fieldname_<%=q%>" value="<%=objDictSellaNeedField.item(q)%>" class="formFieldTXTReadOnly" readonly="true">
		&nbsp;<span class="labelFormThin"><%=langEditor.getTranslated("backend.payment.detail.table.field.label.match")%>:&nbsp;</span><%=objPaymentFixedMatchFieldList(y)%>
		</div>
<%		end if
	next
next%>
</div>	
<%end if%>	
<br/><br/>
<div id="othersPaymentField" align="left" style="float:top;" title="<%=langEditor.getTranslated("backend.payment.detail.table.field.label.list_specific")%>">
<div align="left" style="float:top;width:200px;">				
<span class="labelForm"><%=langEditor.getTranslated("backend.payment.detail.table.field.label.value")%></span>
</div>
<%
Dim objPaymentFieldListNotMatch
Set objPaymentFieldListNotMatch = objPaymentField.getListaPaymentFieldNotMatch(id_payment, modulo)

Dim otherFieldName, otherFieldValue, hasValue
hasValue = false
for each q in objDictSellaField.Keys
	otherFieldName = q
	otherFieldValue = ""
	if (Instr(1, typename(objPaymentFieldListNotMatch), "dictionary", 1) > 0) then
		for each k in objPaymentFieldListNotMatch.Keys		
			if(strComp(q, objPaymentFieldListNotMatch(k).getNameField(), 1) = 0) then
				otherFieldValue = objPaymentFieldListNotMatch(k).getValueField()
				hasValue = true
				Exit for
			end if
		next
	end if
	
	if not(hasValue) then
		otherFieldValue = objDictSellaField(q)
	end if
	%>
	<div align="left" style="float:top">				
	<input type="text" name="fieldname_<%=q%>" value="<%=otherFieldValue%>" class="formFieldTXT">
	&nbsp;<span class="labelFormThin"><%=langEditor.getTranslated("backend.payment.detail.table.field.label.match")%>:&nbsp;</span><%=q%>
	</div>	
<%next%>
</div>	
<%
if Err.number <> 0 then
	'response.write("error="&Err.description)
end if		
		
Set objDictSellaNeedField = nothing
Set objDictSellaField = nothing
Set objPaymentField = Nothing
%>