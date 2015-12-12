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

Dim objCarrelli, objListaCarrelli
Set objCarrelli = New CardClass

Dim order_carrello_by, reqOrderBy
order_carrello_by = null
reqOrderBy = request("order_by")

if (not(isNull(reqOrderBy)) AND not(reqOrderBy = "")) then
	order_carrello_by = reqOrderBy	
end if

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	session("carrelliItems") = request("items")
	itemsXpage = session("carrelliItems")
	session("carrelliPage") = 1
else
	if not(session("carrelliItems") = "") then
		itemsXpage = session("carrelliItems")
	else
		session("carrelliItems") = 20
		itemsXpage = session("carrelliItems")
	end if
end if

if not(request("page") = "") then
	session("carrelliPage") = request("page")
	numPage = session("carrelliPage")
else
	if not(session("carrelliPage") = "") then
		numPage = session("carrelliPage")
	else
		session("carrelliPage") = 1
		numPage = session("carrelliPage")
	end if
end if	


Dim carrelloCounter, iIndex, objTmpCarrello, objTmpCarrelloKey, FromCarrello, ToCarrello, Diff
Dim objUtente, objListaUtenti, userCounter, objTmpUtenti, objTmpUtentiKey, tmpObjUsr
Dim intCount, styleRow, styleRow2
%>