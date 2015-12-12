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

'/**
'* recupero i valori della news selezionata se id_order <> -1
'*/
Dim id_order, id_utente, order_modified
Dim order_prod_by

order_modified = request("order_modified")
if(order_modified = "") then
	order_modified = 0
end if

id_order = Cint(request("id_ordine"))
id_utente = ""
automatic_user = 0

if (id_order <> -1) then
	Dim objOrder, objSelOrder
	Set objOrder = New OrderClass
	Set objSelOrder = objOrder.findOrdineByID(id_order, 0)

	id_order = objSelOrder.getIDOrdine()
	id_utente = objSelOrder.getIDUtente()
	automatic_user = null
end if
Set objSelOrder = Nothing
%>