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
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

Dim objSpesa, objListaSpese
Set objSpesa = New BillsClass

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	session("speseItems") = request("items")
	itemsXpage = session("speseItems")
	session("spesePage") = 1
else
	if not(session("speseItems") = "") then
		itemsXpage = session("speseItems")
	else
		session("speseItems") = 20
		itemsXpage = session("speseItems")
	end if
end if

if not(request("page") = "") then
	session("spesePage") = request("page")
	numPage = session("spesePage")
else
	if not(session("spesePage") = "") then
		numPage = session("spesePage")
	else
		session("spesePage") = 1
		numPage = session("spesePage")
	end if
end if	
%>