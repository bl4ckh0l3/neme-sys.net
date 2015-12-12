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
	
	Dim id_spesa, strDescrizione, iType, iValore, bolDelSpesa, tassa_applicata, taxs_group, applicaFrontend, applicaBackend, autoactive, multiply, required, group, type_view, bills_strategy_counter
	id_spesa = request("id_spesa")
	strDescrizione = request("descrizione")
	iValore = request("valore")	
	iType = request("tipo_valore")
	tassa_applicata = request("id_tassa_applicata")
	taxs_group = request("taxs_group")
	applicaFrontend = request("applica_frontend")
	applicaBackend = request("applica_backend")
	autoactive = request("autoactive")
	multiply = request("multiply")
	required = request("required")
	group = request("group")
	type_view = request("type_view")
	bolDelSpesa = request("delete_spesa")
	bills_strategy_counter = request("bills_strategy_counter")
	
	Dim objSpesa
	Set objSpesa = New BillsClass
	Set objLogger = New LogClass
	
	if (Cint(id_spesa) <> -1) then
		if(strComp(bolDelSpesa, "del", 1) = 0) then
			call objSpesa.deleteSpesa(id_spesa)
			response.Redirect(Application("baseroot")&"/editor/spese/ListaSpeseaccessorie.asp")		
		end if

		'call objLogger.write("bills_strategy_counter: "&bills_strategy_counter, "system", "debug")
	 		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans	
	
		call objSpesa.modifySpesa(id_spesa, strDescrizione, iValore, iType, tassa_applicata, applicaFrontend, applicaBackend, autoactive, multiply, required, group, taxs_group, type_view, objConn)		

		'call objLogger.write("modifico spesa id_spesa: "&id_spesa, "system", "debug")
		if(iType<>0 AND iType<>1 AND iType<>2)then
			if(bills_strategy_counter <> "")then
				arrFieldList = split(bills_strategy_counter, ",", -1, 1)			
				call objSpesa.deleteSpesaConfigBySpesa(id_spesa, objConn)	
				for each xField in arrFieldList
					'call objLogger.write("inserisco spesa id_spesa config: "&xField, "system", "debug")
					tmp_id_prod_field = request("id_prod_field"&xField)
					tmp_operation = request("operation"&xField)
					call objLogger.write("iType: "&iType, "system", "debug")
					if(iType<>7 AND iType<>8)then
						tmp_id_prod_field = null
					end if	
					if(iType<>6 AND iType<>8)then
						tmp_operation = null
					end if	
					call objSpesa.insertSpesaConfig(id_spesa, tmp_id_prod_field, request("rate_from"&xField), request("rate_to"&xField), tmp_operation, request("valore"&xField), objConn)		
				next				
			end if
		end if		

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if			
		Set objDB = nothing		
		Set objSpesa = nothing
		response.Redirect(Application("baseroot")&"/editor/spese/ListaSpeseaccessorie.asp")		
	else	 		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans

		Dim newMaxID 
		newMaxID = objSpesa.insertSpesa(strDescrizione, iValore, iType, tassa_applicata, applicaFrontend, applicaBackend, autoactive, multiply, required, group, taxs_group, type_view, objConn)
		
		if(iType<>0 AND iType<>1 AND iType<>2)then
			if(bills_strategy_counter <> "")then
				arrFieldList = split(bills_strategy_counter, ",", -1, 1)		
				for each xField in arrFieldList
					tmp_id_prod_field = request("id_prod_field"&xField)
					tmp_operation = request("operation"&xField)
					if(iType<>7 AND iType<>8)then
						tmp_id_prod_field = null
					end if	
					if(iType<>6 AND iType<>8)then
						tmp_operation = null
					end if	
					call objSpesa.insertSpesaConfig(newMaxID, tmp_id_prod_field, request("rate_from"&xField), request("rate_to"&xField), tmp_operation, request("valore"&xField), objConn)		
				next				
			end if	
		end if	

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if			
		Set objDB = nothing		
		Set objSpesa = nothing
		response.Redirect(Application("baseroot")&"/editor/spese/ListaSpeseaccessorie.asp")				
	end if
	Set objLogger = nothing
	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>