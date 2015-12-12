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
	
	Dim id_rule, rule_type, label, descrizione, bolDelRule, activate, voucher_id, rules_strategy_counter
	id_rule = request("id_rule")
	rule_type = request("rule_type")
	label = request("label")
	descrizione = request("descrizione")	
	activate = request("activate")
	voucher_id = request("voucher_id")
	bolDelRule = request("delete_rule")
	rules_strategy_counter = request("rules_strategy_counter")
	
	'For Each x In request.form
	'	key = x
	'	value =  request.form(x)
	'	response.write("key: "&key&" - value: "&value&"<br>")	
	'Next
	'response.end
	
	Dim objRule
	Set objRule = New BusinessRulesClass
	Set objLogger = New LogClass
	
	if (Cint(id_rule) <> -1) then
		if(strComp(bolDelRule, "del", 1) = 0) then
			call objRule.deleteRule(id_rule)
			response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=businessrules")		
		end if

		'call objLogger.write("rules_strategy_counter: "&rules_strategy_counter, "system", "debug")
	 		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans	
	
		call objRule.modifyRule(id_rule, rule_type, label, descrizione, activate, voucher_id, objConn)		

		'call objLogger.write("modifico rule id_rule: "&id_rule, "system", "debug")
		if(rules_strategy_counter <> "")then
			arrFieldList = split(rules_strategy_counter, ",", -1, 1)			
			call objRule.deleteRuleConfigByRule(id_rule, objConn)	
			for each xField in arrFieldList
				'call objLogger.write("inserisco rule id_rule config: "&xField, "system", "debug")
				tmp_id_prod_orig = request("id_prod_orig"&xField)
				tmp_id_prod_ref = request("id_prod_ref"&xField)
				tmp_rate_from_ref = request("rate_from_ref"&xField)
				tmp_rate_to_ref = request("rate_to_ref"&xField)
				tmp_apply_4_qta = request("apply_4_qta"&xField)
				tmp_valore = request("valore"&xField)
				'call objLogger.write("rule_type: "&rule_type, "system", "debug")
				if(rule_type<>6 AND rule_type<>7 AND rule_type<>8 AND rule_type<>9 AND rule_type<>10)then
					tmp_id_prod_orig = null
					tmp_id_prod_ref = null
					tmp_apply_4_qta= 0
				end if
				if(rule_type<>8 AND rule_type<>9)then
					tmp_rate_from_ref = null
					tmp_rate_to_ref = null
				end if
				if(rule_type=3 OR rule_type=10) then
					tmp_apply_4_qta= 0
					tmp_valore=0
				end if
				call objRule.insertRuleConfig(id_rule, tmp_id_prod_orig, tmp_id_prod_ref, request("rate_from"&xField), request("rate_to"&xField), tmp_rate_from_ref, tmp_rate_to_ref, request("operation"&xField), request("applyto"&xField), tmp_apply_4_qta, tmp_valore, objConn)				
			next				
		end if		

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if			
		Set objDB = nothing		
		Set objRule = nothing
		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=businessrules")		
	else	 		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans

		Dim newMaxID
		newMaxID = objRule.insertRule(rule_type, label, descrizione, activate, voucher_id, objConn)		
		
		if(rules_strategy_counter <> "")then
			arrFieldList = split(rules_strategy_counter, ",", -1, 1)	
			for each xField in arrFieldList
				'call objLogger.write("inserisco rule id_rule config: "&xField, "system", "debug")
				tmp_id_prod_orig = request("id_prod_orig"&xField)
				tmp_id_prod_ref = request("id_prod_ref"&xField)
				tmp_rate_from_ref = request("rate_from_ref"&xField)
				tmp_rate_to_ref = request("rate_to_ref"&xField)
				tmp_apply_4_qta = request("apply_4_qta"&xField)
				tmp_valore = request("valore"&xField)
				'call objLogger.write("rule_type: "&rule_type, "system", "debug")
				if(rule_type<>6 AND rule_type<>7 AND rule_type<>8 AND rule_type<>9 AND rule_type<>10)then
					tmp_id_prod_orig = null
					tmp_id_prod_ref = null
					tmp_apply_4_qta= 0
				end if
				if(rule_type<>8 AND rule_type<>9)then
					tmp_rate_from_ref = null
					tmp_rate_to_ref = null
				end if
				if(rule_type=3 OR rule_type=10) then
					tmp_apply_4_qta= 0
					tmp_valore=0
				end if
				call objRule.insertRuleConfig(newMaxID, tmp_id_prod_orig, tmp_id_prod_ref, request("rate_from"&xField), request("rate_to"&xField), tmp_rate_from_ref, tmp_rate_to_ref, request("operation"&xField), request("applyto"&xField), tmp_apply_4_qta, tmp_valore, objConn)				
			next				
		end if		

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if			
		Set objDB = nothing		
		Set objRule = nothing
		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=businessrules")				
	end if
	Set objLogger = nothing
	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>