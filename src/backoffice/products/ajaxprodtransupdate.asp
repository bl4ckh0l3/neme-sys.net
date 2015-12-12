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

	Dim main_field, field_val, lang_code, id_objref, optype
	id_objref = request("id_objref")
	main_field = request("main_field")
	lang_code = request("lang_code")
	field_val = request("field_val")
	optype = request("optype")
	use_def = request("use_def")

	Dim objRef
	Set objRef = New ProductsClass
	
	Select Case optype
		Case "find"
			Set objTmp = objRef.findProdottoByID(id_objref, 0)
			response.write(objTmp.findFieldTranslation(main_field , lang_code, use_def))
			Set objTmp = nothing
		Case Else
			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()
			objConn.BeginTrans
			call objRef.deleteFieldTranslation(id_objref, main_field, lang_code, objConn)
			call objRef.insertFieldTranslation(id_objref, main_field, lang_code, field_val, objConn)
			
			if objConn.Errors.Count = 0 AND Err.Number = 0 then
				objConn.CommitTrans
			else		
				objConn.RollBackTrans	
				'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
			end if		
	End Select
	
	Set objRef = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>
