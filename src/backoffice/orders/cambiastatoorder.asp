<%@ Language=VBScript %>
<% 
option explicit
On error resume next
%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->

<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing

	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_order, stato_order, order_by, items, page, search_ordini
	
	id_order = request("id_order_to_change")
	stato_order = request("stato_order")
	order_by = request("order_by")
	items = request("items")
	page = request("page")
	search_ordini = request("search_ordini")
					
	Dim objOrder, objSelOrder
	Set objOrder = New OrderClass
	Set objSelOrder = objOrder.findOrdineByID(id_order, 0)
	Set objOrder = nothing
	
	call objSelOrder.changeStateOrderNoTransaction(id_order, stato_order)
	
	Set objSelOrder = nothing
	Set objUserLogged = nothing
	response.Redirect(Application("baseroot")&"/editor/ordini/ListaOrdini.asp?order_by="&order_by&"&items="&items&"&page="&page&"&search_ordini="&search_ordini)				


	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>