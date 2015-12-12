<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->

<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing

	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	Dim id_payment, strKeywordMultilingua, strDescrizione, datiPagamento, commission, commission_type, url, module, active, paymentType, bolDelPayment
	id_payment = request("id_payment")
	strKeywordMultilingua = request("keyword_multilingua")
	strDescrizione = request("descrizione")
	datiPagamento = request("dati_pagamento")
	commission = request("commission")
	commission_type = request("commission_type")
	url = request("url")
	module = request("payment_module")
	if(module = "") then
		module = -1
	end if
	
	active = request("active")
	paymentType = request("payment_type")
	bolDelPayment = request("delete_payment")
	
	Dim objPayment
	Set objPayment = New PaymentClass
	
	if (Cint(id_payment) <> -1) then
		if(strComp(bolDelPayment, "del", 1) = 0) then
			call objPayment.deletePayment(id_payment)
			response.Redirect(Application("baseroot")&"/editor/payments/ListaPayment.asp")			
		end if	
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans			
	
		call objPayment.modifyPayment(id_payment, strKeywordMultilingua, strDescrizione, datiPagamento, commission, commission_type, url, module, active, paymentType, objConn)
		Dim objPaymentField, fixedField, sub_field_name
		Set objPaymentField = new PaymentFieldClass
		Set fixedField = objPaymentField.getListaMatchFields()
		
		call objPaymentField.deletePaymentFieldList(id_payment, objConn)
				
		for each w in request.Form()
			if(InStr(1,w,"fieldname_",0) > 0) then
				sub_field_name = Right(w,(Len(w)-(InStr(1,w,"fieldname_",0)+9)))
				if(fixedField.exists(replace(request.Form(w), " ", "", 1, -1, 1))) then
					call objPaymentField.insertPaymentField(id_payment, module, sub_field_name, "", request.Form(w), objConn)
				else
					call objPaymentField.insertPaymentField(id_payment, module, sub_field_name, request.Form(w), "", objConn)
				end if				
			end if
		next
		
		Set fixedField = nothing
		Set objPaymentField = nothing
		Set objPayment = nothing	
			
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing		

		response.Redirect(Application("baseroot")&"/editor/payments/ListaPayment.asp")		
	else
		call objPayment.insertPayment(strKeywordMultilingua, strDescrizione, datiPagamento, commission, commission_type, url, module, active, paymentType)
		Set objPayment = nothing
		response.Redirect(Application("baseroot")&"/editor/payments/ListaPayment.asp")				
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>