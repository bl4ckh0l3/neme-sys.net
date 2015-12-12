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
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_order, order_guid, id_utente, dta_ins, totale_ord, tipo_pagam, pagam_done, stato_order, objSelProdPerOrder, user_notified_x_download, order_notes, payment_commission
id_order = request("id_ordine")
order_guid = ""
id_utente = ""
dta_ins = ""
totale_ord = 0
tipo_pagam = ""
payment_commission = 0
pagam_done = 0
stato_order = 0
objSelProdPerOrder = null
user_notified_x_download = 0
order_notes = ""

Dim objUtente, objTmpUser
					
if not (isNull(id_order)) then
	Dim objOrdini, objSelOrdine, objProdPerOrder
	Set objOrdini = New OrderClass
	Set objSelOrdine = objOrdini.findOrdineByID(id_order, 1)
	Set objProdPerOrder = New Products4OrderClass
	Set objOrdini = nothing
	
	id_order = objSelOrdine.getIDOrdine()
	order_guid = objSelOrdine.getOrderGUID()
	id_utente = objSelOrdine.getIDUtente()
	dta_ins = objSelOrdine.getDtaInserimento()
	totale_ord = objSelOrdine.getTotale()
	tipo_pagam = objSelOrdine.getTipoPagam()
	payment_commission = objSelOrdine.getPaymentCommission()
	pagam_done = objSelOrdine.getPagamEffettuato()
	stato_order = objSelOrdine.getStatoOrdine()
	user_notified_x_download = objSelOrdine.isUserNotifiedXDownload()
	order_notes = objSelOrdine.getOrderNotes()
	
	if (isObject(objProdPerOrder.getListaProdottiXOrdine(id_order)) AND not(isNull(objProdPerOrder.getListaProdottiXOrdine(id_order))) AND not(isEmpty(objProdPerOrder.getListaProdottiXOrdine(id_order)))) then
		Set objSelProdPerOrder = objProdPerOrder.getListaProdottiXOrdine(id_order)	
	end if
		
	Set objUtente = New UserClass
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=004")			
end if

Set objProdField = new ProductFieldClass
%>