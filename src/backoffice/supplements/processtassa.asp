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
	
	Dim id_tassa, strDescrizione, iType, iValore, bolDelTassa
	id_tassa = request("id_tassa")
	strDescrizione = request("descrizione")
	iValore = request("valore")
	iType = request("tipo_valore")
	bolDelTassa = request("delete_tassa")
	
	Dim objTassa
	Set objTassa = New TaxsClass
	
	if (Cint(id_tassa) <> -1) then
		if(strComp(bolDelTassa, "del", 1) = 0) then
			if(objTassa.findTasseAssociations(id_tassa)) then
				response.Redirect(Application("baseroot")&Application("error_page")&"?error=011")		
			else
				call objTassa.deleteTassa(id_tassa)
				response.Redirect(Application("baseroot")&"/editor/tax/ListaTasse.asp")	
			end if
		
		end if
		
	
		call objTassa.modifyTassa(id_tassa, strDescrizione, iValore, iType)
		Set objTassa = nothing
		response.Redirect(Application("baseroot")&"/editor/tax/ListaTasse.asp")		
	else
		call objTassa.insertTassa(strDescrizione, iValore, iType)
		Set objTassa = nothing
		response.Redirect(Application("baseroot")&"/editor/tax/ListaTasse.asp")				
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>