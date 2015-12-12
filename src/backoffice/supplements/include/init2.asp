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
'* recupero i valori della news selezionata se id_tassa <> -1
'*/
Dim id_tassa, strDescrizione, iValore, iType
id_tassa = request("id_tassa")
strDescrizione = ""
iValore = ""
iType = ""

if (Cint(id_tassa) <> -1) then
	Dim objTassa, objSelTassa
	Set objTassa = New TaxsClass
	Set objSelTassa = objTassa.findTassaByID(id_tassa)
	Set objTassa = nothing
	
	id_tassa = objSelTassa.getTasseID()
	strDescrizione = objSelTassa.getDescrizioneTassa()		
	iValore = objSelTassa.getValore()	
	iType = objSelTassa.getTipoValore()	
	Set objSelTassa = Nothing
end if
%>