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

'/**
'* recupero i valori della news selezionata se id_payment <> -1
'*/
Dim id_payment, strKeywordMultilingua, strDescrizione, datiPagamento, commission, url, modulo, active, payment_type
id_payment = request("id_payment")
strKeywordMultilingua = ""
strDescrizione = ""
datiPagamento = ""
commission = 0
commission_type = 1
url = 0
modulo = -1
active = 0
payment_type = 0

Set objPayment = New PaymentClass

if (Cint(id_payment) <> -1) then
	Dim objPayment, objSelPayment
	Set objSelPayment = objPayment.findPaymentByID(id_payment)
	
	id_payment = objSelPayment.getPaymentID()
	strKeywordMultilingua = objSelPayment.getKeywordMultilingua()
	strDescrizione = objSelPayment.getDescrizione()		
	datiPagamento = objSelPayment.getDatiPagamento()	
	commission = objSelPayment.getCommission()	
	commission_type = objSelPayment.getCommissionType()	
	url = objSelPayment.getURL()	
	if not(isNull(objSelPayment.getPaymentModuleID())) AND not (objSelPayment.getPaymentModuleID() = "") then
	modulo = objSelPayment.getPaymentModuleID()
	end if
	active = objSelPayment.getAttivo()
	payment_type = objSelPayment.getPaymentType()
	Set objSelPayment = Nothing
end if
Set objPayment = nothing

if not(request("id_modulo") = "") then modulo = request("id_modulo") end if
if not(request("ext_url") = "") then url = request("ext_url") end if
%>