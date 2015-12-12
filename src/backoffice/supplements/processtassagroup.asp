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
	
	Dim id_group, strDescrizione, country, stateReg, tax, group_ass_match_div, exclude_calculation
	id_group = request("id_group")
	strDescrizione = request("description")
	country = request("country_code")
	stateReg = request("state_region_code")
	tax = request("id_tassa_applicata")
	operation = request("operation")
	group_ass_match_div = request("group_ass_match_div")
	exclude_calculation = request("exclude_calculation")
	
	Dim objTaxsGroup
	Set objTaxsGroup = New TaxsGroupClass

	select Case operation
	Case "group"
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()	
		objConn.BeginTrans
		call objTaxsGroup.insertTaxsGroup(strDescrizione, objConn)
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if	
	Case "group_value"
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()	
		objConn.BeginTrans
		call objTaxsGroup.insertTaxsGroupValue(id_group, country, stateReg, tax, exclude_calculation, objConn)
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if	
	Case "delete_group"
		'if(objTaxsGroup.findTasseAssociations(id_tassa)) then
			'response.Redirect(Application("baseroot")&Application("error_page")&"?error=011")		
		'else
			call objTaxsGroup.deleteTaxsGroup(id_group)	
		'end if
	Case "delete_group_value"
		'if(objTaxsGroup.findTasseAssociations(id_tassa)) then
			'response.Redirect(Application("baseroot")&Application("error_page")&"?error=011")		
		'else
			call objTaxsGroup.deleteTaxsGroupValue(id_group,country, stateReg)
		'end if
	Case Else
	End Select
	Set objTaxsGroup = nothing
			
	response.Redirect(Application("baseroot")&"/editor/tax/ListaTasse.asp?showtab=taxsgroup&group_ass_match_div="&group_ass_match_div)

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>