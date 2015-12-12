<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	Dim id_strategy
	id_strategy = request("id_strategy")
	
	Dim objfield
	Set objfield = new BusinessRulesClass

	call objfield.deleteRuleConfigNoTransaction(id_strategy)
				
	Set objfield = nothing
	Set objUserLogged = nothing
else
end if
%>