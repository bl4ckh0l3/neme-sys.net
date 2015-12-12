<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/fckeditor/fckeditor.asp" -->
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
	optype = request("optype")
	field_val = request("field_val") 

	Dim objRef
	Set objRef = New ProductsClass
	
	Select Case optype
		Case "show"
			Set objTmp = objRef.findProdottoByID(id_objref, 0)
			field_val = objTmp.findFieldTranslation(main_field , lang_code, 0)
			field_desc = ""
			Select Case main_field
				Case 2
					field_desc = langEditor.getTranslated("backend.prodotti.detail.table.label.sommario_prod")
				Case 3
					field_desc = langEditor.getTranslated("backend.prodotti.detail.table.label.desc_prod") 
				Case else
			End Select			
			Set objTmp = nothing%>
			<HTML>
			<head>
			<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
			<!-- #include virtual="/editor/include/initCommonJs.inc" -->
			</head>
			<BODY>
			<form method="post" name="fckprodtransupdate" action="<%=Application("baseroot")&"/editor/prodotti/fckprodtransupdate.asp"%>">					
			<input type="hidden" name="id_objref" value="<%=id_objref%>">
			<input type="hidden" name="main_field" value="<%=main_field%>">		
			<input type="hidden" name="lang_code" value="<%=lang_code%>">					
			<input type="hidden" name="optype" value="write">
			<%
			Dim oFCKeditor
			Set oFCKeditor = New FCKeditor
			'oFCKeditor.Width = 400
			oFCKeditor.Height = 300
			oFCKeditor.BasePath = "/fckeditor/"
			%>
			<div id="base_prod_fck"><%
			oFCKeditor.Value = field_val
			oFCKeditor.Create "field_val"
			%>
			</div>
			<div>
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.prodotti.detail.button.inserisci.label")%>" onclick="javascript:document.fckprodtransupdate.submit();" />&nbsp;&nbsp;-&nbsp;&nbsp;<%=field_desc%>&nbsp;&nbsp;(<%=lang_code%>)
			</div>
			
			</form>
			</BODY>
			</HTML>	
		<%Case Else
			Dim result
			result = false
			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()
			objConn.BeginTrans
			call objRef.deleteFieldTranslation(id_objref, main_field, lang_code, objConn)
			call objRef.insertFieldTranslation(id_objref, main_field, lang_code, field_val, objConn)
			
			if objConn.Errors.Count = 0 AND Err.Number = 0 then
				objConn.CommitTrans
				result = true
			else		
				objConn.RollBackTrans
				result = false	
			end if%>
			<HTML>
			<%if(result)then%>
			<BODY onload="window.close();">
			<%else%>
			<BODY>
			<%=langEditor.getTranslated("portal.commons.errors.label.error")%>
			<%end if%>
			</BODY>
			</HTML>					
	<%End Select
	
	Set objRef = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>
