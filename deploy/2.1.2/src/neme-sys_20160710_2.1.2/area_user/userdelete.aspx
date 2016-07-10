<%On Error Resume Next%>
<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<%if (isEmpty(Session("objUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUsrLogged, objUsrLoggedTmp, idFriend
Set objUsrLoggedTmp = new UserClass
Set objUsrLogged = objUsrLoggedTmp.findUserByID(Session("objUtenteLogged"))
id_utente = objUsrLogged.getUserID()
strUserName = objUsrLogged.getUserName()
Set objUsrLogged = nothing

Dim objLogger
Set objLogger = New LogClass

if (Cint(id_utente) <> -1) then
	Dim canDel
	canDel = objUsrLoggedTmp.deleteUser(id_utente)
	if(canDel = true) then
		call objLogger.write("cancellato utente --> id: "&id_utente&"; username: "&strUserName, "system", "info")	
	else
		objUsrLoggedTmp.disableUser(id_utente)
		call objLogger.write("disabilitato utente (non cancellabile) --> id: "&id_utente&"; username: "&strUserName, "system", "info")					
	end if	

	response.redirect(Application("baseroot")&"/common/include/LogOFF.asp")	
else
	response.Redirect(Application("baseroot")&"/login.asp")				
end if

Set objLogger = nothing
Set objUsrLoggedTmp = nothing

if(Err.number <> 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>