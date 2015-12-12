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

Dim objOrdini, objListaOrdini, objListaStatiOrdine
Dim objPayment, objTmpPayment, objListaPayment, objUtente
Set objOrdini = New OrderClass
Set objPayment = New PaymentClass
Set objUtente = New UserClass

Dim order_ordine_by', reqOrderBy
order_ordine_by = 2
'reqOrderBy = request("order_by")

'if (not(isNull(reqOrderBy)) AND not(reqOrderBy = "")) then
'	order_ordine_by = reqOrderBy	
'end if

if not(request("order_by") = "") then
	session("order_ordine_by") = request("order_by")
	order_ordine_by = session("order_ordine_by")
else
	if not(session("order_ordine_by") = "") then
		order_ordine_by = session("order_ordine_by")
	else
		session("order_ordine_by") = 2
		order_ordine_by = session("order_ordine_by")
	end if
end if

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	session("ordiniItems") = request("items")
	itemsXpage = session("ordiniItems")
	session("ordiniPage") = 1
else
	if not(session("ordiniItems") = "") then
		itemsXpage = session("ordiniItems")
	else
		session("ordiniItems") = 20
		itemsXpage = session("ordiniItems")
	end if
end if

if not(request("page") = "") then
	session("ordiniPage") = request("page")
	numPage = session("ordiniPage")
else
	if not(session("ordiniPage") = "") then
		numPage = session("ordiniPage")
	else
		session("ordiniPage") = 1
		numPage = session("ordiniPage")
	end if
end if	


Dim statiOrderCount, iIndexStatiOrder, objTmpStatiOrder, objTmpStatiOrderKey
Dim orderCounter, iIndex, objTmpOrder, objTmpOrderKey, FromOrder, ToOrder, Diff
Dim objListaUtenti, userCounter, objTmpUtenti, objTmpUtentiKey, tmpObjUsr
Dim intCount, styleRow, styleRow2

Dim id_user_search, dta_ins_search_from, dta_ins_search_to, stato_ord_search, tipo_pagam_search, pagam_done_search, ord_by_search, ord_guid_search

if not(request("id_utente_search") = "") then
	session("id_user_search") = request("id_utente_search")
	id_user_search = session("id_user_search")
	session("ordiniPage") = 1
else
	if not(session("id_user_search") = "") then
		id_user_search = session("id_user_search")
	else
		session("id_user_search") = ""
		id_user_search = session("id_user_search")
	end if
end if
if not(request("dta_ins_search_from") = "") then
	session("dta_ins_search_from") = request("dta_ins_search_from")
	dta_ins_search_from = session("dta_ins_search_from")
	session("ordiniPage") = 1
else
	if not(session("dta_ins_search_from") = "") then
		dta_ins_search_from = session("dta_ins_search_from")
	else
		session("dta_ins_search_from") = ""
		dta_ins_search_from = session("dta_ins_search_from")
	end if
end if
if not(request("dta_ins_search_to") = "") then
	session("dta_ins_search_to") = request("dta_ins_search_to")
	dta_ins_search_to = session("dta_ins_search_to")
	session("ordiniPage") = 1
else
	if not(session("dta_ins_search_to") = "") then
		dta_ins_search_to = session("dta_ins_search_to")
	else
		session("dta_ins_search_to") = ""
		dta_ins_search_to = session("dta_ins_search_to")
	end if
end if
if not(request("stato_ord_search") = "") then
	session("stato_ord_search") = request("stato_ord_search")
	stato_ord_search = session("stato_ord_search")
	session("ordiniPage") = 1
else
	if not(session("stato_ord_search") = "") then
		stato_ord_search = session("stato_ord_search")
	else
		session("stato_ord_search") = ""
		stato_ord_search = session("stato_ord_search")
	end if
end if
if not(request("tipo_pagam_search") = "") then
	session("tipo_pagam_search") = request("tipo_pagam_search")
	tipo_pagam_search = session("tipo_pagam_search")
	session("ordiniPage") = 1
else
	if not(session("tipo_pagam_search") = "") then
		tipo_pagam_search = session("tipo_pagam_search")
	else
		session("tipo_pagam_search") = ""
		tipo_pagam_search = session("tipo_pagam_search")
	end if
end if
if not(request("pagam_done_search") = "") then
	session("pagam_done_search") = request("pagam_done_search")
	pagam_done_search = session("pagam_done_search")
	session("ordiniPage") = 1
else
	if not(session("pagam_done_search") = "") then
		pagam_done_search = session("pagam_done_search")
	else
		session("pagam_done_search") = ""
		pagam_done_search = session("pagam_done_search")
	end if
end if
if not(request("ord_by_search") = "") then
	session("ord_by_search") = request("ord_by_search")
	ord_by_search = session("ord_by_search")
	session("ordiniPage") = 1
else
	if not(session("ord_by_search") = "") then
		ord_by_search = session("ord_by_search")
	else
		session("ord_by_search") = ""
		ord_by_search = session("ord_by_search")
	end if
end if
if not(request("ord_guid_search") = "") then
	session("ord_guid_search") = request("ord_guid_search")
	ord_guid_search = session("ord_guid_search")
	session("ordiniPage") = 1
else
	if not(session("ord_guid_search") = "") then
		ord_guid_search = session("ord_guid_search")
	else
		session("ord_guid_search") = ""
		ord_guid_search = session("ord_guid_search")
	end if
end if

if(not(isNull(request("resetMenu"))) AND request("resetMenu") = "1") then
	session("ordiniPage") = 1
	numPage = session("ordiniPage")
	session("id_user_search") = ""
	id_user_search = session("id_user_search")
	session("dta_ins_search_from") = ""
	dta_ins_search_from = session("dta_ins_search_from")
	session("dta_ins_search_to") = ""
	dta_ins_search_to = session("dta_ins_search_to")
	session("stato_ord_search") = ""
	stato_ord_search = session("stato_ord_search")
	session("tipo_pagam_search") = ""
	tipo_pagam_search = session("tipo_pagam_search")
	session("pagam_done_search") = ""
	pagam_done_search = session("pagam_done_search")
	session("ord_by_search") = ""
	ord_by_search = session("ord_by_search")
	session("ord_guid_search") = ""
	ord_guid_search = session("ord_guid_search")
end if
%>