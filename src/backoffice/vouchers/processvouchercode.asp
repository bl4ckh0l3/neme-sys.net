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
	
	Dim id_voucher
	id_voucher = request("id_voucher")
	id_user_ref = request("id_user_ref")
	error_message = ""
	id_new_code = ""
	
	if (Cint(id_voucher) <> -1) then
		Dim objVoucher
		Set objVoucher = New VoucherClass

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		id_new_code = objVoucher.generateVoucherCode(id_voucher, id_user_ref, objConn)
		
		if(id_new_code="")then
			error_message=langEditor.getTranslated("backend.voucher.label.error_generate_code")
		end if
		if objConn.Errors.Count = 0 AND Err.Number = 0 then
			objConn.CommitTrans
		else		
			objConn.RollBackTrans
			error_message=langEditor.getTranslated("backend.voucher.label.error_generate_code")
		end if	
		Set objDB = nothing
		Set objVoucher = nothing
		response.Redirect(Application("baseroot")&"/editor/voucher/visualizzavoucher.asp?id_voucher="&id_voucher&"&error_message="&error_message&"&id_new_code="&id_new_code)		
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>