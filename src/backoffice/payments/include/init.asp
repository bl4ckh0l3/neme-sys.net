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

Dim objPayment, objListaPayment
Set objPayment = New PaymentClass

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	session("paymentItems") = request("items")
	itemsXpage = session("paymentItems")
	session("paymentPage") = 1
else
	if not(session("paymentItems") = "") then
		itemsXpage = session("paymentItems")
	else
		session("paymentItems") = 20
		itemsXpage = session("paymentItems")
	end if
end if

if not(request("page") = "") then
	session("paymentPage") = request("page")
	numPage = session("paymentPage")
else
	if not(session("paymentPage") = "") then
		numPage = session("paymentPage")
	else
		session("paymentPage") = 1
		numPage = session("paymentPage")
	end if
end if	
%>