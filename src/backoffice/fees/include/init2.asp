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
'* recupero i valori della news selezionata se id_spesa <> -1
'*/
Dim id_spesa, strDescrizione, iValore, iType, tassa_applicata, taxs_group, applica_frontend, applica_backend, autoactive, multiply, required, group
id_spesa = request("id_spesa")
strDescrizione = ""
iValore = ""
iType = 0
applica_frontend = ""
applica_backend = ""
tassa_applicata = ""
taxs_group = ""
autoactive = ""
multiply = ""
required = ""
group = ""
type_view = ""

Dim objSpesa
Set objSpesa = New BillsClass

if (Cint(id_spesa) <> -1) then
	Dim objSelSpesa
	
	Set objSelSpesa = objSpesa.findSpesaByID(id_spesa)
		
	id_spesa = objSelSpesa.getSpeseID()
	strDescrizione = objSelSpesa.getDescrizioneSpesa()		
	iValore = objSelSpesa.getValore()	
	iType = objSelSpesa.getTipoValore()	
	tassa_applicata = objSelSpesa.getIDTassaApplicata()
	taxs_group = objSelSpesa.getTaxGroup()
	applica_frontend = objSelSpesa.getApplicaFrontend()
	applica_backend = objSelSpesa.getApplicaBackend()
	autoactive = objSelSpesa.getAutoactive()
	multiply = objSelSpesa.getMultiply()
	required = objSelSpesa.getRequired()
	group = objSelSpesa.getGroup()
	type_view = objSelSpesa.getTypeView()
	Set objSelSpesa = Nothing
end if

Set objField = New ProductFieldClass
%>