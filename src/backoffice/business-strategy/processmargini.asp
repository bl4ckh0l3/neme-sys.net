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
	
	Dim id_margine, dblMargine, dblSconto, bolProdDisc, bolUserdisc, bolDelMargine, reqGroups, arrGroup
	id_margine = request("id_margine")
	dblMargine = request("margine")
	dblSconto = request("discount")
	bolProdDisc = request("prod_disc")
	bolUserdisc = request("user_disc")
	bolDelMargine = request("delete_margine")
	reqGroups = request("ListGroups")
	arrGroup = split(reqGroups, "|", -1, 1)	
	
	Dim objMargine
	Set objMargine = New MarginDiscountClass

	if (Cint(id_margine) <> -1) then
		if(strComp(bolDelMargine, "del", 1) = 0) then
			call objMargine.deleteMarginDiscount(id_margine)
			response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=margindiscount")	
		end if

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		call objMargine.modifyMarginDiscount(id_margine, dblMargine, dblSconto, bolProdDisc, bolUserdisc, objConn)
		
		'/**
		'* cancello i vecchi groups e inserisco i nuovi groups per margine
		'*/
		On Error Resume Next
		Set objGroup = new UserGroupClass
		Set objSelGroup = objGroup.getUserGroupXMarginDiscount(id_margine)		
		Set objGroup = nothing
		if (Instr(1, typename(objSelGroup), "dictionary", 1) > 0) AND not(isEmpty(objSelGroup)) then		
			for each xGroup in objSelGroup
				call objMargine.deleteMarginDiscountXUserGroup(xGroup, objConn)
			next
		end if
		Set objSelGroup = nothing
	
		for each xGroup in arrGroup
			call objMargine.insertMarginDiscountXUserGroup(id_margine, xGroup, objConn)	
		next				

		if(Err.number <> 0) then
		end if	

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objMargine = nothing

		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=margindiscount")		
	else
		Dim newIDmargine
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans

		newIDmargine = objMargine.insertMarginDiscount(dblMargine, dblSconto, bolProdDisc, bolUserdisc, objConn)
	
		for each xGroup in arrGroup
			call objMargine.insertMarginDiscountXUserGroup(newIDmargine, xGroup, objConn)	
		next				

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objMargine = nothing	

		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=margindiscount")				
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>