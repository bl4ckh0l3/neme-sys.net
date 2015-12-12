<%@ Language=VBScript %>
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
	
	Dim id_ordine, id_utente, dta_ins, totale_imp_ord, totale_tasse_ord
	Dim totale_ord, spese_sped_order, stato_order, tipo_pagam, pagam_done, order_modified, user_notified_x_download, orderNotes, noRegistration, id_ads
	
	id_ordine = request("id_ordine")	
	id_utente = request("id_utente")
	order_modified = request("order_modified")
	dta_ins = ""
	totale_imp_ord = CDbl(0)
	totale_tasse_ord = CDbl(0)
	totale_ord = CDbl(0)
	tipo_pagam = ""
	payment_commission = CDbl(0)
	pagam_done = 0
	stato_order = 1
	user_notified_x_download = 0
	orderNotes = ""
	noRegistration = 0
	id_ads = ""

	Dim objOrdine
	Dim listOrder
	Set objOrdine = New OrderClass

	Dim strCognomecliente, strNomeCliente, objUserTmp
	Dim DD, MM, YY, HH, MIN, SS
	
	Dim objLogger
	Set objLogger = New LogClass	
	
	if (Cint(id_ordine) <> -1) then			
		Dim objModOrder
		Set objModOrder = objOrdine.findOrdineByID(id_ordine, false)

		dta_ins = objModOrder.getDtaInserimento()
		totale_imp_ord = objModOrder.getTotaleImponibile()
		totale_tasse_ord = objModOrder.getTotaleTasse()
		totale_ord = objModOrder.getTotale()
		tipo_pagam = objModOrder.getTipoPagam()
		payment_commission = objModOrder.getPaymentCommission()
		pagam_done = objModOrder.getPagamEffettuato()
		stato_order = objModOrder.getStatoOrdine()	
		user_notified_x_download = objModOrder.isUserNotifiedXDownload()
		orderNotes = objModOrder.getOrderNotes()
		noRegistration = objModOrder.getNoRegistration()
		id_ads = objModOrder.getIdAdRef()
		
		DD = DatePart("d", dta_ins)
		MM = DatePart("m", dta_ins)
		YY = DatePart("yyyy", dta_ins)
		HH = DatePart("h", dta_ins)
		MIN = DatePart("n", dta_ins)
		SS = DatePart("s", dta_ins)
		dta_ins = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS		
		
		Set objModOrder = nothing
			
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		
		call objOrdine.modifyOrdineNoTransaction(id_ordine, id_utente, dta_ins, stato_order, totale_imp_ord, totale_tasse_ord, totale_ord, tipo_pagam, payment_commission, pagam_done, user_notified_x_download, orderNotes, noRegistration, id_ads)

		Set objDB = nothing		
		Set objOrdine = nothing

		call objLogger.write("modificato ordine --> id: "&id_ordine, objUserLogged.getUserName(), "info")
		response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&order_modified="&order_modified&"&resetMenu=1")			
	else
		Dim newIDOrder
		dta_ins = Now()
		DD = DatePart("d", dta_ins)
		MM = DatePart("m", dta_ins)
		YY = DatePart("yyyy", dta_ins)
		HH = DatePart("h", dta_ins)
		MIN = DatePart("n", dta_ins)
		SS = DatePart("s", dta_ins)
		dta_ins = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS
		
		'**** CREO IL GUID PER IL NUOVO ORDINE
		Dim objGUID, strGUID
		Set objGUID = new GUIDClass
		strGUID = objGUID.CreateOrderGUID()
		Set objGUID = nothing

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
					
		newIDOrder = objOrdine.insertOrdineNoTransaction(id_utente, dta_ins, stato_order, totale_imp_ord, totale_tasse_ord, totale_ord, tipo_pagam, payment_commission, pagam_done, strGUID, user_notified_x_download, orderNotes, noRegistration, id_ads)
		id_ordine = newIDOrder 	

		Set objDB = nothing		
		Set objOrdine = nothing
		response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&order_modified="&order_modified&"&resetMenu=1")				
	end if

	Set objUserLogged = nothing
	
	Set objLogger = nothing
	
	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>