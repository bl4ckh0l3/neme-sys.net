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

Dim objVoucher, objListaVoucher
Set objVoucher = New VoucherClass

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	session("voucherItems") = request("items")
	itemsXpage = session("voucherItems")
	session("voucherPage") = 1
else
	if not(session("voucherItems") = "") then
		itemsXpage = session("voucherItems")
	else
		session("voucherItems") = 20
		itemsXpage = session("voucherItems")
	end if
end if

if not(request("page") = "") then
	session("voucherPage") = request("page")
	numPage = session("voucherPage")
else
	if not(session("voucherPage") = "") then
		numPage = session("voucherPage")
	else
		session("voucherPage") = 1
		numPage = session("voucherPage")
	end if
end if	
%>