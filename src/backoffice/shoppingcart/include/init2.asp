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
Dim id_carrello, id_utente, dta_ins, totale_carrello, objProdXCarrello, objSelProdPerCarrello
id_carrello = request("id_carrello")
id_utente = ""
dta_ins = ""
totale_carrello = cDbl(0)
objSelProdPerCarrello = null

Dim objUtente, objTmpUser, objCarrellonumSconto, scontoCliente, hasSconto
hasSconto = false

Set objTasse = new TaxsClass
					
if not (isNull(id_carrello)) then
	Set carrello = New CardClass	
	Set objCarrello = carrello.getCarrelloByIDCarello(id_carrello)
	id_utente = objCarrello.getIDUtente()
	dta_ins = objCarrello.getDtaCreazione()	
	Set objProdXCarrello = New ProductsCardClass
	if(not(isNull(objProdXCarrello.retrieveListaProdotti(id_carrello))) AND not(isEmpty(objProdXCarrello.retrieveListaProdotti(id_carrello)))) then
	Set objSelProdPerCarrello = objProdXCarrello.retrieveListaProdotti(id_carrello)
	end if
	Set objProdXCarrello = nothing
	Set objCarrello = nothing
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=004")			
end if
%>