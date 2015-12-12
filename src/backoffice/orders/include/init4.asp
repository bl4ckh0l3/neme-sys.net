<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if


' procedura di paginazione per il catalogo prodotti
Sub PaginazioneOrderProd(totPages, currPage, sendFormParam)
	page = Cint(currPage)
	totalPages = Cint(totPages)
	Max = 10
	
	EndPage = Cint(page + max)
	startPage = 1
	
	' qualche controllo
	if (EndPage> totalPages) then
		EndPage = totalPages
	end if

	' qualche controllo
	if (startPage < page) then
		startPage = page
	end if
	if(Cbool((EndPage - startPage) < Max)) then
		startPage = (EndPage - Max)
	end if
	if (startPage < 1) then
		startPage = 1
	end if

	if (page > 1) then%>
	  <a title="<%=langEditor.getTranslated("portal.commons.pagination.label.prec_page")%>" class="link-paginazione" href="javascript:setProdListPaginationNumber(<%=(page-1)%>);sendForm('<%=sendFormParam%>',1);"><span class="link-paginazione"><%=langEditor.getTranslated("portal.commons.pagination.label.prec_page")%></span></a>
	
	<%end if
	
	for i = startPage to EndPage
		if(i = page) then
			class_ = "link-paginazione-active"
		else
			class_ = "link-paginazione"
		end if%>
	  <a title="<%=langEditor.getTranslated("portal.commons.pagination.label.page") & " " &  i%>" class="<%=class_%>" href="javascript:setProdListPaginationNumber(<%=(i)%>);sendForm('<%=sendFormParam%>',1);"><span class="link-paginazione">[</span><%=i%><span class="link-paginazione">]</span></a>
	<%next
			
	if (page < totalPages) then%>
	  <a title="<%=langEditor.getTranslated("portal.commons.pagination.label.next_page")%>" class="link-paginazione" href="javascript:setProdListPaginationNumber(<%=(page+1)%>);sendForm('<%=sendFormParam%>',1);"><span class="link-paginazione"><%=langEditor.getTranslated("portal.commons.pagination.label.next_page")%></span></a>
	
	<%end if
End Sub

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
'* recupero i valori della news selezionata se id_order <> -1
'*/
Dim id_order, id_utente, dta_ins, totale_imp_ord, totale_tasse_ord, totale_ord
Dim spese_sped_order, stato_order, tipo_pagam, pagam_done, objProdPerOrder, order_modified
Dim objSelProdPerOrder

order_modified = request("order_modified")
if(order_modified = "") then
	order_modified = 0
end if

id_order = Cint(request("id_ordine"))
objSelProdPerOrder = null

Dim objOrder, objSelOrder, tmp_imp_ord
Set objOrder = New OrderClass
Set objSelOrder = objOrder.findOrdineByID(id_order, 0)
Set objProdPerOrder = New Products4OrderClass
Set objOrder = nothing

id_order = objSelOrder.getIDOrdine()
id_utente = objSelOrder.getIDUtente()
dta_ins = objSelOrder.getDtaInserimento()
totale_imp_ord = objSelOrder.getTotaleImponibile()
totale_tasse_ord = objSelOrder.getTotaleTasse()
totale_ord = objSelOrder.getTotale()
tipo_pagam = objSelOrder.getTipoPagam()
pagam_done = objSelOrder.getPagamEffettuato()
stato_order = objSelOrder.getStatoOrdine()

hasObjProdPerOrder = false
On Error Resume Next
Set objSelProdPerOrder = objProdPerOrder.getListaProdottiXOrdine(id_order)
if (Instr(1, typename(objSelProdPerOrder), "Dictionary", 1) > 0) AND (objSelProdPerOrder.Count > 0) then
	hasObjProdPerOrder = true
end if	
if(Err.number <> 0)then
	hasObjProdPerOrder = false
end if	

Dim bolCanModifyProd, numDateDiff
bolCanModifyProd = false
numDateDiff = -1
if(not(dta_ins = "")) then
	numDateDiff = DateDiff("n",dta_ins,Now())
end if

if(id_order = -1 OR (stato_order = 1 AND (dta_ins = "" OR (numDateDiff < Cint(Application("minute_order_modify_permit")))))) then
	bolCanModifyProd = true
end if


Set objProdField = new ProductFieldClass

Dim totPages, itemsXpage, numPage

if not(request("items") = "") then
	itemsXpage = request("items")
else
	itemsXpage = 10
end if

if not(request("page") = "") then
	numPage = request("page")
else
	numPage = 1
end if

Dim target_prod_param
target_prod_param = ""

Dim CategoryClassTmp, objListCatXProdTmp
Set CategoryClassTmp = new CategoryClass
%>