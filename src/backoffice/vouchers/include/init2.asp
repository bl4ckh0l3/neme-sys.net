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

Dim objVoucher
Set objVoucher = New VoucherClass
	
'/**
'* recupero i valori della news selezionata se id_voucher <> -1
'*/
Dim id_voucher
id_voucher = request("id_voucher")
label = ""
description = ""
voucher_type = 0
activate = 0
valore = ""
operation = 0
max_generation = -1
max_usage = -1
enable_date = ""
expire_date = ""
exclude_prod_rule = 0

if (Cint(id_voucher) <> -1) then
	Dim objSelVoucher
	Set objSelVoucher = objVoucher.findCampaignByID(id_voucher)	
	id_voucher = objSelVoucher.getID()
	voucher_type = objSelVoucher.getVoucherType()
	label = objSelVoucher.getLabel()	
	description = objSelVoucher.getDescrizione()	
	activate = objSelVoucher.getActivate()		
	valore = objSelVoucher.getValore()	
	operation = objSelVoucher.getOperation()	
	max_generation = objSelVoucher.getMaxGeneration()	
	max_usage = objSelVoucher.getMaxUsage()	
	enable_date = objSelVoucher.getEnableDate()	
	expire_date = objSelVoucher.getExpireDate()	
	exclude_prod_rule = objSelVoucher.getExcludeProdRule()	
	Set objSelVoucher = Nothing
end if
%>