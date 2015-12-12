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
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if

	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_order, status_order, report_modifiche_qta	
	
	id_order = request("id_order_to_delete")
	status_order = request("status_order_to_delete")
	search_ordini = request("search_ordini")
	report_modifiche_qta = ""

	On Error Resume next
	
	Dim objOrder, objCurrOrder, objCurrListProd, objProd, objTmpProd, objTmpProdPerOrder, objProdPerOrder, hasProdList
	Set objOrder = New OrderClass
	Set objProdPerOrder = New Products4OrderClass
	Set objProdField = new ProductFieldClass
	
	Dim objLogger
	Set objLogger = New LogClass	
		
	Set objCurrOrder = objOrder.findOrdineByID(id_order, 1)
	hasProdList = false
	
	if(strComp(typename(objCurrOrder.getProdottiXOrdine()), "Dictionary") = 0)then
		Set objCurrListProd = objCurrOrder.getProdottiXOrdine()
		hasProdList = true
	end if
	
	
	
	Dim objDB, objConn
	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans

	if(status_order = 4 OR status_order = 3) then
		'*** cancello tutti gli eventuali field per prodotto
		for each j in objCurrListProd
			if(strComp(typename(objProdField.findListFieldXOrderByProd(objCurrListProd(j).getCounterProd(),id_order,objCurrListProd(j).getIDProdotto())), "Dictionary") = 0)then
				Set objTmpListP4O_ = objProdField.findListFieldXOrderByProd(objCurrListProd(j).getCounterProd(),id_order,objCurrListProd(j).getIDProdotto())
				for each k in objTmpListP4O_
					call objProdField.deleteFieldXOrderByProd(k, id_order, objCurrListProd(j).getIDProdotto(), objConn)
				next							
				Set objTmpListP4O_ = nothing
			end if			
		next
	
		call objProdPerOrder.deleteProdottiXOrdine(id_order, objConn)
		call objOrder.deleteOrdine(id_order, objConn)
		
		call objLogger.write("cancellato ordine --> id: "&id_order, objUserLogged.getUserName(), "info")
	else	
		if(hasProdList) then			
			Set objProd = New ProductsClass
			Dim z
			for each z in objCurrListProd.Keys
				On error resume next
				Set objTmpProdPerOrder = objCurrListProd.Item(z)
				Set objTmpProd = objProd.findProdottoByID(objTmpProdPerOrder.getIDProdotto(),0)
				if(not(objTmpProd.getQtaDisp() = Application("unlimited_key"))) then
					isStillActiveGlobal = true	
					qtaCurrProdToChange = CLng(objTmpProdPerOrder.getQtaProdotto())

					'******* QUESTO IF CONTROLLA LE QUANTITA' PER I FIELD PER PRODOTTO PER ORDINE: DA VERIFICARE CON ATTENZIONE	
					
					'call objLogger.write("1) getCounterProd(): "&objTmpProdPerOrder.getCounterProd()&" - id_ordine: "&id_order&" - getIDProdotto(): "&objTmpProdPerOrder.getIDProdotto()&" - getQtaProdotto(): "&qtaCurrProdToChange, "system", "debug")
						
					if(strComp(typename(objProdField.findListFieldXOrderByProd(objTmpProdPerOrder.getCounterProd(),id_order,objTmpProdPerOrder.getIDProdotto())), "Dictionary") = 0)then
						Set objTmpListP4O_ = objProdField.findListFieldXOrderByProd(objTmpProdPerOrder.getCounterProd(),id_order,objTmpProdPerOrder.getIDProdotto())
					
						'call objLogger.write("2) objTmpListP4O_: "&typename(objTmpListP4O_)&" - objTmpListP4O_.count: "&objTmpListP4O_.count, "system", "debug")
					
						for each k in objTmpListP4O_
							'call objLogger.write("3) k: "&k, "system", "debug")
							for each x in objTmpListP4O_(k)														
								tmpField4ProdQta_ = objProdField.findFieldValueMatch(x.getID(), x.getIdProd(), x.getSelValue())
								'call objLogger.write("4) x.getID(): "&x.getID()&" - x.getIdProd(): "&x.getIdProd()& " - x.getSelValue(): "&x.getSelValue()& " - tmpField4ProdQta_: "&tmpField4ProdQta_& " qtaToChange: "&(tmpField4ProdQta_ - -qtaCurrProdToChange), "system", "debug")
								isStillActiveField = objProdField.changeQtaFieldValueMatch(x.getID(), x.getIdProd(), x.getSelValue(), -qtaCurrProdToChange, tmpField4ProdQta_, objConn)


								'********* effettuo controllo sui campi correlati per modificare la disponibilità corretta
								On Error Resume Next
								hasListfieldVal = false
								Set listFieldRelVal = objProdField.findListFieldRelValueMatch(x.getIdProd(), x.getID(), x.getSelValue())
								if(listFieldRelVal.count>0)then
									hasListfieldVal = true
								end if
								if(err.number<>0)then
								hasListfieldVal = false
								end if

								'call objLogger.write("5) delete ordine hasListfieldVal: " & hasListfieldVal, "system", "error")
										
								if(hasListfieldVal)then
									'On Error Resume Next	
									for each t in objTmpListP4O_(k)									
										Set tmpF4OR = t
										if((tmpF4OR.getID()&tmpF4OR.getSelValue())<>(x.getID()&x.getSelValue()))then
											'call objLogger.write("6) delete ordine objTmpProdPerOrder.getIDProdotto(): " &objTmpProdPerOrder.getIDProdotto()&" - x.getID(): " & x.getID()&" - x.getSelValue(): " & x.getSelValue()&" - tmpF4OR.getID: " & tmpF4OR.getID()&" - tmpF4OR.getSelValue: " & tmpF4OR.getSelValue(), "system", "error")
											if(listFieldRelVal.exists(objTmpProdPerOrder.getIDProdotto()&"|"&x.getID()&"|"&x.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))then
												qtaFieldRel = listFieldRelVal(objTmpProdPerOrder.getIDProdotto()&"|"&x.getID()&"|"&x.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue())("qta_rel")
												isStillActiveField = objProdField.changeQtaFieldRelValueMatch(objTmpProdPerOrder.getIDProdotto(), x.getID(), x.getSelValue(), tmpF4OR.getID(), tmpF4OR.getSelValue(), -qtaCurrProdToChange, CLng(qtaFieldRel), objConn)	
												'call objLogger.write("7) delete ordine qtaFieldRel: "& qtaFieldRel & " - isStillActiveField: " & isStillActiveField&" - qtaCurrProd: "& -qtaCurrProdToChange, "system", "error")
											end if
										end if
										Set tmpF4OR = nothing									
									next

									Set listFieldRelVal = nothing
									'if(err.number<>0)then
									'call objLogger.write("8) delete ordine (listFieldRelVal) err.description: " & err.description, "system", "error")
									'end if
								end if
							

								if(isStillActiveField = 1)then
									isStillActiveField = true
								else
									isStillActiveField = false
								end if
								isStillActiveGlobal = (Cbol(isStillActiveGlobal) AND Cbol(isStillActiveField))
								'call objLogger.write("isStillActiveGlobal: "&isStillActiveGlobal, "system", "debug")
							next
						next							
						Set objTmpListP4O_ = nothing
					end if				
					
					
					Dim newQta, oldQta, qtaChanged
					oldQta = objTmpProd.getQtaDisp()
					newQta = -Cint(objTmpProdPerOrder.getQtaProdotto())				
					qtaChanged = Cint(oldQta) + Cint(objTmpProdPerOrder.getQtaProdotto())	
									
					report_modifiche_qta = report_modifiche_qta & objTmpProd.getIDProdotto() & "|" & objTmpProd.getNomeProdotto() & "|" & qtaChanged & "|" & oldQta & "#"
					
					isStillActive = objProd.changeQtaProdotto(objTmpProd.getIDProdotto(), newQta, oldQta, objConn)
					if(isStillActive = 0 OR not(isStillActiveGlobal)) then
						'*** invio la mail prodotto esaurito
						Dim objMail
						Set objMail = New SendMailClass
						call objMail.sendMailProdEndDisp(objTmpProd.getIDProdotto(), Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
						'call objLogger.write("cancellato ordine --> invio mail prodotto esaurito: id_prodotto="&objTmpProd.getIDProdotto(), "system", "debug")
						Set objMail = Nothing							
					end if		
				end if
				
				Set objTmpProd = nothing
				Set objTmpProdPerOrder = nothing
				If Err.Number<>0 then
					call objLogger.write("Errore in fase di recupero prodotto per ordine --> prodotto per ordine: ("&objTmpProd.getIDProdotto()&") "&objTmpProd.getNomeProdotto(), "system", "error")
				end if
			next
			Set objProd = nothing				
		end if

		report_modifiche_qta = Mid(report_modifiche_qta,1,InStrRev(report_modifiche_qta, "#")-1)

		'*** cancello tutti gli eventuali field per prodotto
		for each j in objCurrListProd
			if(strComp(typename(objProdField.findListFieldXOrderByProd(objCurrListProd(j).getCounterProd(),id_order,objCurrListProd(j).getIDProdotto())), "Dictionary") = 0)then
				Set objTmpListP4O_ = objProdField.findListFieldXOrderByProd(objCurrListProd(j).getCounterProd(),id_order,objCurrListProd(j).getIDProdotto())
				for each k in objTmpListP4O_
					call objProdField.deleteFieldXOrderByProd(k, id_order, objCurrListProd(j).getIDProdotto(), objConn)
				next							
				Set objTmpListP4O_ = nothing
			end if			
		next

		call objProdPerOrder.deleteProdottiXOrdine(id_order, objConn)
		call objOrder.deleteOrdine(id_order, objConn)	
		
		call objLogger.write("cancellato ordine --> id: "&id_order, objUserLogged.getUserName(), "info")
	end if

	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
	end If	
	
	Set objDB = nothing	
	
	if(hasProdList)then	
		Set objCurrListProd = nothing
	end if
	
	Set objCurrOrder = nothing
	Set objProdField = nothing
	Set objProdPerOrder = nothing
	Set objOrder = nothing	
	Set objUserLogged = nothing
	
	Set objLogger = nothing
		
	response.Redirect(Application("baseroot")&"/editor/ordini/DelOrdineConfirmed.asp?search_ordini="&search_ordini&"&report_modifiche_qta="&Server.URLEncode(report_modifiche_qta))				


	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>