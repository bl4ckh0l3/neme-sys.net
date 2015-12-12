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
	label = request("label")
	description = request("descrizione")
	voucher_type = request("voucher_type")
	activate = request("activate")
	valore = request("valore")
	operation = request("operation")
	max_generation = request("max_generation")
	max_usage = request("max_usage")
	enable_date = request("enable_date")
	expire_date = request("expire_date")
	exclude_prod_rule = request("exclude_prod_rule")
	
	Dim objVoucher
	Set objVoucher = New VoucherClass
	
	if (Cint(id_voucher) <> -1) then

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		call objVoucher.modifyCampaign(id_voucher, label, voucher_type, description, valore, operation, activate, max_generation, max_usage, enable_date, expire_date, exclude_prod_rule, objConn)
		if objConn.Errors.Count = 0 AND Err.Number = 0 then
			objConn.CommitTrans
		else		
			objConn.RollBackTrans	
			'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if	
		Set objDB = nothing
		Set objVoucher = nothing
		response.Redirect(Application("baseroot")&"/editor/voucher/ListaVoucher.asp")		
	else
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		call objVoucher.insertCampaign(label, voucher_type, description, valore, operation, activate, max_generation, max_usage, enable_date, expire_date, exclude_prod_rule, objConn)
		if objConn.Errors.Count = 0 AND Err.Number = 0 then
			objConn.CommitTrans
		else		
			objConn.RollBackTrans	
			'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if	
		Set objDB = nothing
		Set objVoucher = nothing
		response.Redirect(Application("baseroot")&"/editor/voucher/ListaVoucher.asp")				
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>