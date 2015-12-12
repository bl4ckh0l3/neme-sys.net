<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->

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
	
	Dim action
	action = request("action")
	
	Dim id_field,id_group, description, id_type,id_type_content, values, order, required, enabled, editable, maxLenght, bolDelField, field_values_counter
	id_field = request("id_field")
	id_group = request("id_group")
	description = request("description")
	id_type = request("id_type")
	id_type_content = request("id_type_content")
	values = request("field_values")
	order = request("order")
	required = request("required")
	enabled = request("enabled")
	editable = request("editable")
	maxLenght = request("max_lenght")
	bolDelField = request("delete_field")
	field_values_counter = request("field_values_counter")
	
	Dim desc_new_group, order_new_group, id_del_group
	desc_new_group = request("desc_new_group")
	order_new_group = request("order_new_group")
	id_del_group = request("id_del_group")
	
	Dim objfield, objGroup
	Set objfield = new ProductFieldClass
	Set objGroup = New ProductFieldGroupClass

	if (strComp(action, "del_group", 1) = 0) then
		call objGroup.deleteProductFieldGroup(id_del_group)
		Set objGroup = nothing
		response.Redirect(Application("baseroot")&"/editor/prodotti/inseriscifield.asp?id_field="&id_field)	
	elseif(strComp(action, "ins_group", 1) = 0) then
		call objGroup.insertProductFieldGroupNoTransaction(desc_new_group,order_new_group)		
		Set objGroup = nothing
		response.Redirect(Application("baseroot")&"/editor/prodotti/inseriscifield.asp?id_field="&id_field)
	else
		if (Cint(id_field) <> -1) then
			if(strComp(bolDelField, "del", 1) = 0) then
				call objfield.deleteProductField(id_field)
				response.Redirect(Application("baseroot")&"/editor/prodotti/Listaprodotti.asp?showtab=prodfield")	
			end if


			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()	
			objConn.BeginTrans
			call objfield.modifyProductField(id_field,description, id_group, order,id_type,id_type_content,required,enabled,editable,Trim(maxLenght),objConn)

			if(field_values_counter <> "")then
				arrFieldList = split(field_values_counter, ",", -1, 1)
				
				call objfield.deleteProductFieldValueByField(id_field,objConn)
				
				fieldValuecounter = 1
				for each xField in arrFieldList
					call objfield.insertProductFieldValue(id_field, request("field_values"&xField), fieldValuecounter, objConn)	
					fieldValuecounter = fieldValuecounter+1
				next				
			end if

			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
			end if

			Set objDB = Nothing
			Set objfield = nothing
			response.Redirect(Application("baseroot")&"/editor/prodotti/Listaprodotti.asp?showtab=prodfield")		
		else
			Dim newMaxID 
			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()
			objConn.BeginTrans
			newMaxID = objfield.insertProductField(description, id_group, order,id_type,id_type_content,required,enabled,editable,Trim(maxLenght),objConn)

			if(field_values_counter <> "")then
				arrFieldList = split(field_values_counter, ",", -1, 1)
				
				fieldValuecounter = 1
				for each xField in arrFieldList
					call objfield.insertProductFieldValue(newMaxID, request("field_values"&xField), fieldValuecounter, objConn)	
					fieldValuecounter = fieldValuecounter+1
				next				
			end if

			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
			end if

			Set objDB = Nothing
			Set objfield = nothing
			response.Redirect(Application("baseroot")&"/editor/prodotti/Listaprodotti.asp?showtab=prodfield")				
		end if
	end if
	
	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>