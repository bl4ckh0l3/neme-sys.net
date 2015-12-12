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
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

'/**
'* recupero i valori della news selezionata se id_group <> -1
'*/
Dim id_group, shortDesc, longDesc,defaultGroup, taxsGroup
id_group = request("id_group")
shortDesc = ""
longDesc = ""
defaultGroup = 0
taxsGroup = ""

if (Cint(id_group) <> -1) then
	Dim objGroup, objSelGroup
	Set objGroup = New UserGroupClass
	Set objSelGroup = objGroup.findUserGroupByID(id_group)
	Set objGroup = nothing
	
	id_group = objSelGroup.getID()
	shortDesc = objSelGroup.getShortDesc()		
	longDesc = objSelGroup.getLongDesc()	
	defaultGroup = objSelGroup.isDefault()
	taxsGroup = objSelGroup.getTaxGroup()
	Set objSelGroup = Nothing
end if
%>