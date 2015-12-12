<%@ Language=VBScript %>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->

<%
Dim checkoutPage
checkoutPage = Application("baseroot")&"/editor/payments/moduli/"

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
	
	Dim id_ordine, apply_bills, tot_imp_tmp4bills, totale_qta_order, id_utente, dta_ins, totale_ord, stato_order, tipo_pagam, pagam_done
	Dim objProdPerOrder, order_guid, user_notified_x_download, order_notes, noRegistration, id_ads, complete_selected_prod_list
	
	id_ordine = request("id_ordine")	
	apply_bills = request("apply_bills")
	tot_imp_tmp4bills = request("tot_imp_tmp4bills")
	totale_qta_order = request("totale_qta_order") 
	tipo_pagam = request("tipo_pagam")
	pagam_done = request("pagam_done")
	stato_order = request("stato_order")
	order_notes = request("order_notes")
	
	Dim objOrdine
	Set objOrdine = New OrderClass

	Dim objOrdineEmail, objListaTipiPagamento, strTipoPagam, StrPagamDone, spese_sped_order, strOldPagamDone
	Dim strCognomecliente, strNomeCliente, objUserTmp, sconto_cliente, objProdList, payment_commission
	Dim DD, MM, YY, HH, MIN, SS
	Dim tot_prod_tmp, nome_prod_tmp
	
	Dim objLogger
	Set objLogger = New LogClass
	Dim objModOrder	
	Set objModOrder = objOrdine.findOrdineByID(id_ordine, true)
	
	id_utente = objModOrder.getIDUtente()
	dta_ins = objModOrder.getDtaInserimento()		
	DD = DatePart("d", dta_ins)
	MM = DatePart("m", dta_ins)
	YY = DatePart("yyyy", dta_ins)
	HH = DatePart("h", dta_ins)
	MIN = DatePart("n", dta_ins)
	SS = DatePart("s", dta_ins)
	dta_ins = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS		
	totale_imp_ord = CDbl(objModOrder.getTotaleImponibile())
	totale_tasse_ord = CDbl(objModOrder.getTotaleTasse())
	totale_ord = CDbl(objModOrder.getTotale())
	payment_commission = objModOrder.getPaymentCommission()
	order_guid = objModOrder.getOrderGUID()
	strOldPagamDone = objModOrder.getPagamEffettuato()
	user_notified_x_download = objModOrder.isUserNotifiedXDownload()
	noRegistration = objModOrder.getNoRegistration()
	id_ads = objModOrder.getIdAdRef()
	Set objProdList = objModOrder.getProdottiXOrdine()

	Dim objGroup
	Set objGroup = new UserGroupClass
	Dim objClientTmp, hasGroup, groupCliente	
	hasGroup = false
	groupCliente = ""
	
	if(not(id_utente = "")) then
		Set objClientTmp = objUserLogged.findUserByID(id_utente)	

		groupCliente = objClientTmp.getGroup()
		if(not(groupCliente= "")) then
			On Error Resume Next
			Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
			groupDesc = objTmpGr.getShortDesc()
			if (not(isNull(objTmpGr.getTaxGroup()))) then
				Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
			end if
			hasGroup = true
			Set objTmpGr = nothing
			if(Err.number <> 0) then
				hasGroup = false
			end if
		end if
		Set objClientTmp = nothing
	else
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	Set objGroup = nothing

	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans


	'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
	Dim international_country_code, international_state_region_code
	international_country_code = ""
	international_state_region_code = ""


	'*** inserisco o aggiorno lo shipping address
	if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then
		Dim ship_name, ship_surname, ship_cfiscvat, ship_address, ship_zip_code, ship_city, ship_country, ship_state_region, ship_is_company_client, objShip, orderShip, ship_id
		ship_name = request("ship_name")
		ship_surname = request("ship_surname")
		ship_cfiscvat = request("ship_cfiscvat")
		ship_address = request("ship_address")	
		ship_zip_code = request("ship_zip_code")
		ship_city = request("ship_city")
		ship_country = request("ship_country")
		ship_state_region = request("ship_state_region")
		ship_is_company_client = request("ship_is_company_client")
					
		international_country_code = ship_country
		international_state_region_code = ship_state_region
	
		if(ship_name <> "")then
			Set objShip = new ShippingAddressClass
			On Error Resume Next
		
			Set orderShip = objShip.getOrderShippingAddress(id_ordine)
		
			if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
				call objShip.modifyShippingAddress(orderShip.getID(), orderShip.getUserID(), ship_address, ship_name, ship_surname, ship_cfiscvat, ship_city, ship_zip_code, ship_country, ship_state_region, ship_is_company_client, objConn)
				call objShip.modifyOrderShippingAddress(id_ordine, orderShip.getID(), ship_address, ship_city, ship_zip_code, ship_country, ship_state_region, ship_is_company_client, objConn)
			else
				Set orderShip = objShip.findShippingAddressByUserID(id_utente)
				
				if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
					call objShip.modifyShippingAddress(orderShip.getID(), orderShip.getUserID(), ship_address, ship_name, ship_surname, ship_cfiscvat, ship_city, ship_zip_code, ship_country, ship_state_region, ship_is_company_client, objConn)
					ship_id = orderShip.getID()
				else
					ship_id = objShip.insertShippingAddress(id_utente, ship_address, ship_name, ship_surname, ship_cfiscvat, ship_city, ship_zip_code, ship_country, ship_state_region, ship_is_company_client, objConn)			
				end if
				
				call objShip.insertOrderShippingAddress(id_ordine, ship_id, ship_address, ship_city, ship_zip_code, ship_country, ship_state_region, ship_is_company_client, objConn)
			end if		  
		
			Set orderShip = nothing
			Set objShip = nothing
		
			if(Err.number <> 0) then 
				call objLogger.write("processordine --> id ordine: "&id_ordine&"; shipping address error: "&Err.description, "system", "error")
			end if
		end if
	end if


	'*** inserisco o aggiorno il bills address
	if(Application("show_bills_box") = 1) then
		Dim bills_name, bills_surname, bills_cfiscvat, bills_address, bills_zip_code, bills_city, bills_country, bills_state_region, objBills, orderBills, bills_id
		bills_name = request("bills_name")
		bills_surname = request("bills_surname")
		bills_cfiscvat = request("bills_cfiscvat")
		bills_address = request("bills_address")	
		bills_zip_code = request("bills_zip_code")
		bills_city = request("bills_city")
		bills_country = request("bills_country")
		bills_state_region = request("bills_state_region")
	
		Set objBills = new BillsAddressClass
		On Error Resume Next
	
		Set orderBills = objBills.getOrderBillsAddress(id_ordine)
	
		if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
			call objBills.modifyBillsAddress(orderBills.getID(), orderBills.getUserID(), bills_address, bills_name, bills_surname, bills_cfiscvat, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
			call objBills.modifyOrderBillsAddress(id_ordine, orderBills.getID(), bills_address, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
		else
			Set orderBills = objBills.findBillsAddressByUserID(id_utente)
			
			if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
				call objBills.modifyBillsAddress(orderBills.getID(), orderBills.getUserID(), bills_address, bills_name, bills_surname, bills_cfiscvat, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
				bills_id = orderBills.getID()
			else
				bills_id = objBills.insertBillsAddress(id_utente, bills_address, bills_name, bills_surname, bills_cfiscvat, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)			
			end if
			
			call objBills.insertOrderBillsAddress(id_ordine, bills_id, bills_address, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
		end if		  
	
		Set orderBills = nothing
		Set objBills = nothing
	
		if(Err.number <> 0) then 
			call objLogger.write("processordine --> id ordine: "&id_ordine&"; bills address error: "&Err.description, "system", "error")
		end if
	end if

	Dim objListAllFieldxProd
	'totale_qta_order = 0
	'** inizializzo mappa dei field per prodotto selezionati				 
	Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")

	'*** inserisco o aggiorno la lista dei file scaricabili
	'*** se il pagamento è stato effettuato e non era pagato in precedenza, imposto active = true
	'*** se il pagamento era già stato effettuato non faccio nulla
	Dim objDownProd, objDownProd4Order, objDownProdList
	Dim expireDate, isActive
	Set objDownProd = new DownloadableProductClass
	Set objDownProd4Order = new DownloadableProduct4OrderClass	
	Set objProdTmp = New ProductsClass	
	Set objProdField = new ProductFieldClass
	
	for each j in objProdList

		'call objLogger.write("modifyDownProd --> objProdList(j): "&Left(j,Instr(1,j,"|",1 )-1), "system", "debug")
		'*** verifico che per ogni prodotto sia ancora disponibile la quantità impostata per l'ordine
		Set tmpProd = objProdTmp.findProdottoByID(Left(j,Instr(1,j,"|",1 )-1),0)	

		'if (tmpProd.getProdType()=0) then
		'totale_qta_order=totale_qta_order+Cint(objProdList(j).getQtaProdotto())
		'end if

		bolHasListFieldXOrd = false
		if(strComp(typename(objProdField.findListFieldXOrderByProd(objProdList(j).getCounterProd(),id_ordine,tmpProd.getIDProdotto())), "Dictionary") = 0)then
			Set objTmpListP4O_ = objProdField.findListFieldXOrderByProd(objProdList(j).getCounterProd(),id_ordine,tmpProd.getIDProdotto())
			
			if(objTmpListP4O_.count > 0)then
				bolHasListFieldXOrd = true

				if (tmpProd.getProdType()=0) then
					'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
					Set objDict = Server.CreateObject("Scripting.Dictionary")
					objListAllFieldxProd.add objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto(), objDict
		
					for each k in objTmpListP4O_
						for each x in objTmpListP4O_(k)
							Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
							objDictFieldxProd.add "id", x.getID()
							objDictFieldxProd.add "value", x.getSelValue()
							objDictFieldxProd.add "qta", objProdList(j).getQtaProdotto()
							objListAllFieldxProd(objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto()).add objDictFieldxProd, ""
							call objLogger.write("r id: " & objDictFieldxProd("id")&" - value: " & objDictFieldxProd("value")&" - qta: " & objDictFieldxProd("qta"), "system", "debug")
							Set objDictFieldxProd = nothing					
						next
					next
				end if
			end if
		end if

		'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
		if (Instr(1, typename(objProdField.getListProductField4ProdActive(tmpProd.getIDProdotto())), "Dictionary", 1) > 0) then
			Set fieldList4CardH = objProdField.getListProductField4ProdActive(tmpProd.getIDProdotto())			
		
			if(fieldList4CardH.count > 0)then
				if (tmpProd.getProdType()=0) then
					'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
					Set objDict = Server.CreateObject("Scripting.Dictionary")
					if not(objListAllFieldxProd.Exists(objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto()))then
						objListAllFieldxProd.add objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto(), objDict
					end if

					for each d in fieldList4CardH
						if((fieldList4CardH(d).getTypeContent()=2 OR fieldList4CardH(d).getTypeContent()=3) AND (fieldList4CardH(d).getEditable()=0))then
							Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
							objDictFieldxProd.add "id", fieldList4CardH(d).getID()
							objDictFieldxProd.add "value", fieldList4CardH(d).getSelValue()
							objDictFieldxProd.add "qta", objProdList(j).getQtaProdotto()

							bolCanAdd = true
							On Error Resume Next
							for each i in objListAllFieldxProd(objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto())
								if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
									bolCanAdd = false
									Exit for
								end if
							next

							if(bolCanAdd)then
								objListAllFieldxProd(objProdList(j).getCounterProd()&"-"&tmpProd.getIDProdotto()).add objDictFieldxProd, ""
							end if
							if(Err.number<>0)then
							'response.write("Error: "&Err.description)
							end if
							Set objDictFieldxProd = nothing		
						end if
					next
					Set objDict = nothing								
				end if									
			end if
			Set fieldList4CardH = nothing
		end if


		if not(tmpProd.getQtaDisp() = Application("unlimited_key")) then
			'call objLogger.write("objProdList(j).getCounterProd()= "&objProdList(j).getCounterProd(), "system", "debug")
			if(bolHasListFieldXOrd)then
				'call objLogger.write("objTmpListP4O_= "&typename(objTmpListP4O_), "system", "debug")
				for each k in objTmpListP4O_
					for each x in objTmpListP4O_(k)
						'call objLogger.write("objProdField.findFieldValueMatch("&x.getID()&", "&x.getIdProd()&", "&x.getSelValue()&")= "&objProdField.findFieldValueMatch(x.getID(), x.getIdProd(), x.getSelValue()), "system", "debug")
						numOldField4ProdQta_ = objProdField.findFieldValueMatch(x.getID(), x.getIdProd(), x.getSelValue())
						if(numOldField4ProdQta_ <> "" AND not(isNull(numOldField4ProdQta_)))then
							if(numOldField4ProdQta_ < 0) then
								objConn.RollBackTrans
								response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&resetMenu=1&nome_prod="&Server.URLEncode("<br/>"&tmpProd.getNomeProdotto()&": "&x.getSelValue()))							
							end if

							'********* effettuo controllo sui campi correlati per verificare se la disponibilità è corretta
							On Error Resume Next
							hasListfieldVal = false
							Set listFieldRelVal = objProdField.findListFieldRelValueMatch(x.getIdProd(), x.getID(), x.getSelValue())
							if(listFieldRelVal.count>0)then
								hasListfieldVal = true
							end if
							if(err.number<>0)then
							hasListfieldVal = false
							end if
						
							if(hasListfieldVal)then
								bolHasRelFieldCombination = false
								On Error Resume Next
								for each t in objTmpListP4O_(k)
									Set tmpF4OR = t
									if((tmpF4OR.getID()&tmpF4OR.getSelValue())<>(x.getID()&x.getSelValue()))then
										if(listFieldRelVal.exists(tmpProd.getIDProdotto()&"|"&x.getID()&"|"&x.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))then
											qtaFieldRel = listFieldRelVal(tmpProd.getIDProdotto()&"|"&x.getID()&"|"&x.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue())("qta_rel")
											'call objLogger.write("process ordine 3 qtaFieldRel: " & qtaFieldRel, "system", "debug")
											if(CLng(qtaFieldRel) < 0) then		
												objConn.RollBackTrans	
												response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&resetMenu=1&nome_prod="&Server.URLEncode("<br/>"&tmpProd.getNomeProdotto()&": "&x.getSelValue()&" - "&tmpF4OR.getSelValue()))
											end if
											bolHasRelFieldCombination = true											
											Exit for
										'else
											'objConn.RollBackTrans	
											'response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&resetMenu=1&nome_prod="&Server.URLEncode("<br/>"&tmpProd.getNomeProdotto()&": "&x.getSelValue()&" - "&tmpF4OR.getSelValue()))										
										end if
									end if
									Set tmpF4OR = nothing
								next
								if not(bolHasRelFieldCombination) then
									objConn.RollBackTrans
									response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&resetMenu=1&nome_prod="&Server.URLEncode("<br/>"&tmpProd.getNomeProdotto()&": "&x.getSelValue()))	
								end if

								Set listFieldRelVal = nothing
								if(err.number<>0)then
								call objLogger.write("process ordine 3 (listFieldRelVal) err.description: " & err.description, "system", "error")
								end if
							end if
						end if
					next
				next							
			end if			
		
			if(tmpProd.getQtaDisp() < 0) then
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&resetMenu=1&nome_prod="&tmpProd.getNomeProdotto())
			elseif(tmpProd.getQtaDisp() = 0)then
				'*** invio la mail prodotto esaurito
				'call objLogger.write("modificato ordine --> invio mail prodotto esaurito: id_prodotto="&j&"; qta disp="&tmpProd.getQtaDisp(), "system", "debug")
				Dim objMail
				Set objMail = New SendMailClass
				call objMail.sendMailProdEndDisp(Left(j,Instr(1,j,"|",1 )-1), Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
				Set objMail = Nothing		
			end if
		end if
		'call objLogger.write("modifyDownProd --> typename(tmpProd): "&typename(tmpProd), "system", "debug")
		
		if(bolHasListFieldXOrd)then
			Set objTmpListP4O_ = nothing
		end if

		'call objLogger.write("modifyDownProd --> tmpProd.getProdType(): "&(tmpProd.getProdType()), "system", "debug")
		if(tmpProd.getProdType()=1)then
			On Error Resume Next
			Set objDownProdList = objDownProd.getFilePerProdotto(tmpProd.getIDProdotto())
			'call objLogger.write("modifyDownProd --> typename(objDownProdList): "&typename(objDownProdList), "system", "debug")
			for each r in objDownProdList
				'*** verifico se esiste già questo record su DB e imposto i valori corretti da inserire
				expireDate = null
				isActive = 0
				
				if(pagam_done = 1) then
					isActive = 1
				end if
				
				if(pagam_done = 1 AND strOldPagamDone = 0)then
					isActive = 1
					if(tmpProd.getMaxDownloadTime() <> -1) then
						expireDate = DateAdd("n",tmpProd.getMaxDownloadTime(),now()) 
					end if
				end if
				'call objLogger.write("modificato ordine --> expireDate: "&expireDate, "system", "debug")
				'call objLogger.write("is null: "&isNull(objDownProd4Order.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r)), "system", "debug")

				if not(isNull(objDownProd4Order.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r))) then
					'call objLogger.write("modifyDownProd --> objDownProd: "&objDownProd.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r).getID()&"; id_ordine: "&r&"; IDProdotto: "&tmpProd.getIDProdotto()&"; objDownProd: "&r&"; id_utente: "&id_utente, "system", "debug")
					Set objDownProd4OrderTmp = objDownProd4Order.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r)
					'call objLogger.write("typename: "&typename(objDownProd4OrderTmp), "system", "debug")
					if(pagam_done = 1 AND strOldPagamDone = 1) then
						isActive = objDownProd4OrderTmp.isActive()
						expireDate = objDownProd4OrderTmp.getExpireDate()
					end if
					call objDownProd4Order.modifyDownProd(objDownProd4OrderTmp.getID(), id_ordine, tmpProd.getIDProdotto(), r, id_utente, isActive, tmpProd.getMaxDownload(), now(), expireDate, objDownProd4OrderTmp.getDownloadCounter(), objDownProd4OrderTmp.getDownloadDate(),objConn)
					Set objDownProd4OrderTmp = nothing
				else
					'call objLogger.write("insertDownProd --> id_ordine: "&id_ordine&"; IDProdotto: "&tmpProd.getIDProdotto()&"; objDownProd: "&r&"; id_utente: "&id_utente, "system", "debug")
					call objDownProd4Order.insertDownProd(id_ordine, tmpProd.getIDProdotto(), r, id_utente, isActive, tmpProd.getMaxDownload(), now(), expireDate, 0, null,objConn)
				end if
				
				'call objLogger.write("passato da download product ordine --> id_ordine: "&id_ordine, "system", "debug")
				
			next
			Set objDownProdList = nothing
			if(Err.number <> 0)then 
				call objLogger.write("process ordine 3 --> id ordine: "&id_ordine&"; downloadable prod error: "&Err.description, "system", "error")
			end if
		end if		
		Set tmpProd = nothing
	next
	
	Set objProdField = nothing
	Set objProdTmp = nothing
	Set objDownProd4Order = nothing
	Set objDownProd = nothing


	Dim objSpesa, objListaSpese, objSpesaTmp, objSpeseXOrdine, objListaSpeseXOrdine, hasBill4Order, objTasse
	Set objSpesa = new BillsClass
	Set objSpeseXOrdine = new Bills4OrderClass
	Set objTasse = new TaxsClass
	hasBill4Order = false

	On Error Resume Next
	Set objListaSpese = objSpesa.getListaSpese(null, null, null, 1)			
	if Err.number <> 0 then
		objListaSpese = null
	end if

	On Error Resume Next
	Set objListaSpeseXOrdine = objSpeseXOrdine.getSpeseXOrdine(id_ordine)
	if(objListaSpeseXOrdine.Count > 0)then
		hasBill4Order = true
	end if
	if Err.number <> 0 then
		hasBill4Order = false
	end if
	
	'call objLogger.write("apply_bills: "& apply_bills&"; hasBill4Order: "& hasBill4Order, "system", "debug")
	
	if(apply_bills) then
		if not(isNull(objListaSpese)) then
			
			Dim objTassa, totSpeseImp, totSpeseTax, totSpese					
			
			oldGroupDesc = ""
			elements = ""
			Set objDictSelBills = Server.CreateObject("Scripting.Dictionary")	
			
			'recupero tutti i gruppi di spesa selezionati dal form
			for each k in objListaSpese
				Set objSpesaTmp = objListaSpese(k)
				if(objSpesaTmp.getAutoactive()=0)then
					if(oldGroupDesc<>objSpesaTmp.getGroup())then
						elements = request(objSpesaTmp.getGroup())
						
						'call objLogger.write("objSpesaTmp.getGroup(): "&objSpesaTmp.getGroup()&"; elements: "&elements, "system", "debug")
						
						if(elements<>"")then
							elelmArr = Split(elements, ",", -1, 1)
							
							for each i in elelmArr
								objDictSelBills.add Cint(i),""
								'call objLogger.write("elelmArr(i): "&i&"; typename(i): "&typename(i)&"; objDictSelBills.Exists(i): "& objDictSelBills.Exists(Cint(i)), "system", "debug")
							next
						end if
					end if					
					oldGroupDesc = objSpesaTmp.getGroup()
				end if
				Set objSpesaTmp = nothing
			next
			
			
			for each k in objListaSpese
				totSpeseImp = 0
				totSpeseTax = 0
				Set objSpesaTmp = objListaSpese(k)
				
				if(objSpesaTmp.getAutoactive()=0)then
					'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
					totSpeseImp = objSpesaTmp.getImpByStrategy(tot_imp_tmp4bills, totale_qta_order, objListAllFieldxProd)

					' verifico se si tratta di valore fisso o percentuale
					'if(CInt(objSpesaTmp.getTipoValore()) = 2) then
						'totSpeseImp = CDbl(tot_imp_tmp4bills) / 100 * CDbl(objSpesaTmp.getValore())				
					'else
						'totSpeseImp = CDbl(objSpesaTmp.getValore())
					'end if
					
					
					'***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
					applyOrigTax = true
					if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
						if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
							On Error Resume Next
							objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
							if(not(isNull(objRelatedTax))) then
								Set objTaxG = objTasse.findTassaByID(objRelatedTax)
								totSpeseTax = groupClienteTax.getImportoTassa(totSpeseImp, objTaxG)
								Set objTaxG = nothing
								applyOrigTax = false
							else
								applyOrigTax = true		
							end if			
							if(Err.number<>0)then
							  applyOrigTax = true
							end if	
						else
							On Error Resume Next
                    		Set groupBillsTax = objSpesaTmp.getTaxGroupObj(objSpesaTmp.getTaxGroup())
							if(Instr(1, typename(groupBillsTax), "TaxsGroupClass", 1) > 0) then
					  			objRelatedTax = groupBillsTax.findRelatedTax(groupBillsTax.getID(), international_country_code,international_state_region_code)
								if(not(isNull(objRelatedTax))) then
									Set objTaxG = objTasse.findTassaByID(objRelatedTax)
									totSpeseTax = groupBillsTax.getImportoTassa(totSpeseImp, objTaxG)
									Set objTaxG = nothing
									applyOrigTax = false		
								end if								
							else
								applyOrigTax = true
							end if
							Set groupBillsTax = nothing	
							if(Err.number<>0)then
							  applyOrigTax = true
							end if
						end if
					end if
					if(applyOrigTax)then
						totSpeseTax = 0
						if not(isNull(objSpesaTmp.getIDTassaApplicata())) AND not(objSpesaTmp.getIDTassaApplicata() = "") then
							Set objBillTaxTmp = objTasse.findTassaByID(objSpesaTmp.getIDTassaApplicata())
							if(objBillTaxTmp.getTipoValore() = 2) then
								totSpeseTax = CDbl(totSpeseImp) * (CDbl(objBillTaxTmp.getValore()) / 100)
							else
								totSpeseTax = CDbl(objBillTaxTmp.getValore())
							end if	
							Set objBillTaxTmp = nothing
						end if
					end if					
					
					
					'call objLogger.write("totSpeseImp: "&totSpeseImp&"; totSpeseTax: "& totSpeseTax, "system", "debug")
					
					if(hasBill4Order)then
						if(objListaSpeseXOrdine.Exists(k))then
							call objSpeseXOrdine.deleteSpesaXOrdine(id_ordine, objSpesaTmp.getSpeseID(), objConn)	
							
							totale_imp_ord = totale_imp_ord-totSpeseImp
							totale_tasse_ord = totale_tasse_ord-totSpeseTax	
					
							'call objLogger.write("a) totale_imp_ord: "&totale_imp_ord&"; totale_tasse_ord: "& totale_tasse_ord, "system", "debug")						
						end if
					end if

					'call objLogger.write("k: "&k&"; objDictSelBills.Exists(k): "& objDictSelBills.Exists(k), "system", "debug")

					if(objDictSelBills.Exists(k))then
						call objSpeseXOrdine.insertSpeseXOrdine(id_ordine, objSpesaTmp.getSpeseID(), totSpeseImp, totSpeseTax, (totSpeseImp+totSpeseTax), objSpesaTmp.getDescrizioneSpesa(), objConn)
						totale_imp_ord = totale_imp_ord+totSpeseImp
						totale_tasse_ord = totale_tasse_ord+totSpeseTax		
						'call objLogger.write("b) totale_imp_ord: "&totale_imp_ord&"; totale_tasse_ord: "& totale_tasse_ord, "system", "debug")	
						'call objLogger.write("b) typename(totale_imp_ord): "&typename(totale_imp_ord)&"; typename(totale_tasse_ord): "& typename(totale_tasse_ord), "system", "debug")				
					end if
					
				end if
				
				Set objSpesaTmp = nothing
			next
						
			'call objLogger.write("c) totale_imp_ord: "&totale_imp_ord&"; totale_tasse_ord: "& totale_tasse_ord, "system", "debug")	
			Set objListAllFieldxProd = nothing			
			Set objDictSelBills = nothing
		end if
	end if
	
	Set objTasse = nothing			
	Set objSpeseXOrdine = nothing
	Set objListaSpeseXOrdine = nothing
	Set objListaSpese = nothing
	Set objSpesa = nothing	

	'*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE ORDINE PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
	Set objRule = new BusinessRulesClass
	tot_rule_amount = 0
	On Error Resume Next
	Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_ordine, false)
	if(objRule4Order.count>0)then
		for each x in objRule4Order
			tot_rule_amount=tot_rule_amount+Cdbl(objRule4Order(x).getValoreConf())
		next
	end if
	If Err.Number<>0 then
		'response.write(Err.description)					
	end if
	Set objRule = nothing
	'call objLogger.write("tot_rule_amount: "&tot_rule_amount, "system", "debug")


	'*** recupero la tipologia di pagamento selezionata per aggiornare eventuali commissioni	
	Dim objPayment, objTmpPayment, payUrl, payModule, commission
	Set objPayment = New PaymentClass
	Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
	payUrl = objTmpPayment.getURL()
	payModule = objTmpPayment.getPaymentModuleID()
	strTipoPagam = langEditor.getTranslated(objTmpPayment.getKeywordMultilingua())
		
	'*** se le commissioni sono > 0 e non sono già state applicate, calcolo e aggiungo le commissioni in base alla tipologia di pagamento scelta
	'payment_commission = 0
	'if(tipo_pagam<>objModOrder.getTipoPagam()) then
		payment_commission = objTmpPayment.getImportoCommissione(totale_imp_ord+totale_tasse_ord)
		'call objLogger.write("payment_commission: "&payment_commission, "system", "debug")	
	'end if
	
	totale_ord = totale_imp_ord+totale_tasse_ord+payment_commission+tot_rule_amount
	
	Set objTmpPayment = Nothing
	Set objPayment = nothing	
	Set objModOrder = nothing


	'*** imposto a due il numero di decimali
	totale_ord = FormatNumber(totale_ord,2,-1,-2,0)
	'call objLogger.write("totale_ord: "&totale_ord, "system", "debug")	

	call objOrdine.modifyOrdine(id_ordine, id_utente, dta_ins, stato_order, totale_imp_ord, totale_tasse_ord, totale_ord, tipo_pagam, payment_commission, pagam_done, user_notified_x_download,order_notes,noRegistration,id_ads,objConn)

	Set objProdList = nothing
			
	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
	else
		objConn.RollBackTrans
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
	
	Set objDB = nothing
			
	Set objOrdine = nothing

	call objLogger.write("process ordine 3 modificato ordine --> id: "&id_ordine, objUserLogged.getUserName(), "info")


	if (CInt(payUrl) = 1) AND pagam_done = 0 then
		Dim checkout_parameters, pageModuleCheckout, externalURL
		pageModuleCheckout = ""
		Dim isHTTPS
		isHTTPS = Request.ServerVariables("HTTPS")
		If isHTTPS = "off" AND Application("use_https") = 1 Then
			pageModuleCheckout = "https://"&Request.ServerVariables("SERVER_NAME")
		Else
			pageModuleCheckout = "http://"&Request.ServerVariables("SERVER_NAME")
		End If
		pageModuleCheckout = pageModuleCheckout & checkoutPage


		'******** recupero il modulo di pagamento e la pagina di checkout
		Dim objModulePayment, objModule, modulePageCheckout
		Set objModulePayment = new PaymentModuleClass
		Set objModule = objModulePayment.findPaymentModuloByID(payModule)
		modulePageCheckout = objModule.getDirectory()&"/"&objModule.getCheckoutPage()
		'******** termino URL pagina checkuot specifica del modulo
		pageModuleCheckout = pageModuleCheckout & modulePageCheckout
		Set objModule = nothing
		Set objModulePayment = nothing
		
		Dim objUtil, objCrypt
		Set objUtil = new UtilClass

		checkout_parameters = objUtil.getUniqueKeyOrderIdPayment()&"="&id_ordine&"&"&objUtil.getUniqueKeyOrderAmountPayment()&"="&objUtil.convertDoubleDelimiter4External(totale_ord)&"&"&objUtil.getUniqueKeyOrderGUIDPayment()&"="&order_guid&"&"&objUtil.getUniqueKeyOrderTypePayment()&"="&tipo_pagam
		'call objLogger.write("processOrdine3 --> checkout_parameters: "&checkout_parameters, objUserLogged.getUserName(), "debug")

		set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
		objHttp.open "POST", pageModuleCheckout, false
		objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
		objHttp.Send(checkout_parameters)
		response.Write(objHttp.responseText)
		set objHttp = nothing

		''Set objCrypt = new CryptClass
		'Set listaCheckoutMatchFields = Server.CreateObject("Scripting.Dictionary")
		''compongo il codice per l'invio ordine criptato
		''listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), objCrypt.EnCrypt(order_guid&"|"&id_ordine&"|"&totale_ord)
		'listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), order_guid&"|"&id_ordine&"|"&totale_ord
		'listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderAmountPayment(), totale_ord
		''response.Write("listaCheckoutMatchFields: "&objCrypt.EnCrypt(order_guid&"|"&id_ordine&"|"&totale_ord))		
		''Set objCrypt = nothing		
		''response.Write("listaCheckoutMatchFields: "&objUtil.URLEncode(listaCheckoutMatchFields.item("id_order_ack")))	
		''response.End()
		
		'Dim obiCurrPayment, objPaymentField, fixedField, obiCurrPaymentFieldMatch, obiCurrPaymentFieldNotMatch
		'Set objPayment = New PaymentClass
		'Set obiCurrPayment = objPayment.findPaymentByID(tipo_pagam)
		'Set objPaymentField = new PaymentFieldClass
		'Set obiCurrPaymentFieldMatch = objPaymentField.getListaPaymentFieldDoMatch(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID())
		'Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaPaymentFieldNotMatch(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID())
		'Set fixedField = objPaymentField.getListaMatchFields()
		
		'externalURL = objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), objUtil.getUniqueKeyExtURLPayment()).getValueField()
		
		'Set fixedField = nothing
		'Set objPaymentField = nothing
		'Set obiCurrPayment = nothing
		'Set objPayment = nothing
		'Set objUtil = nothing
		%>
		<!--<HTML>
		<BODY onload="document.checkout_redirect.submit();">
		<form method="post" name="checkout_redirect" action="<%'=externalURL%>">
		<%'For Each y In obiCurrPaymentFieldMatch%>
		<input type="hidden" name="<%'=obiCurrPaymentFieldMatch(y).getNameField()%>" value="<%'=listaCheckoutMatchFields(obiCurrPaymentFieldMatch(y).getMatchField())%>">
		<%'Next
		'Set obiCurrPaymentFieldMatch = nothing%>
		<%'For Each y In obiCurrPaymentFieldNotMatch%>
		<input type="hidden" name="<%'=obiCurrPaymentFieldNotMatch(y).getNameField()%>" value="<%'=obiCurrPaymentFieldNotMatch(y).getValueField()%>">
		<%'Next
		'Set obiCurrPaymentFieldNotMatch = nothing
		'Set listaCheckoutMatchFields = nothing%>
		</form>
		</BODY>
		</HTML>-->
	<%else
		response.Redirect(Application("baseroot")&"/editor/ordini/ConfirmInsertOrdine.asp?id_ordine="&id_ordine&"&already_paied="&strOldPagamDone)
	end if		

	Set objUserLogged = nothing
	
	Set objLogger = nothing
	
	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>