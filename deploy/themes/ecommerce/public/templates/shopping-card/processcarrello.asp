<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldClass.asp" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->

<%
Dim objUserLogged, objUserLoggedTmp

Dim objLogger, objGUID
Set objGUID = new GUIDClass
Set objLogger = New LogClass	
Set objShip = new ShippingAddressClass
Set objBills = new BillsAddressClass

Dim checkoutPage
checkoutPage = Application("baseroot")&"/editor/payments/moduli/"

Dim objGroup
Set objGroup = New UserGroupClass
	
'*** controllo se e' stato attivato acquisto diretto senza registrazione e nel caso aggiungo l'utente runtime
if(request("buy_noreg")="1")then
	Dim noregMail, noRegNumUserGroup
	noregMail = request("noreg_email")

	noRegNumUserGroup = null
	
	if(strComp(typename(objGroup.findUserGroupDefault()), "UserGroupClass", 1) = 0)then
		noRegNumUserGroup = objGroup.findUserGroupDefault().getID()
	end if
	
	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()			
	objConn.BeginTrans

	Set objUserLoggedTmp = new UserClass
	idUserMax = objUserLoggedTmp.insertUser(Session.SessionID&"-"&objGUID.CreateGUIDRandom(), Session.SessionID&"-"&objGUID.CreateGUIDRandom(), noregMail, Application("guest_role"), 1, 0, "1", 0, "", Now(), Now(), "0", noRegNumUserGroup, "1", objConn)
	Session("objUtenteLogged") = idUserMax
	Set objUserLoggedTmp = nothing

	if(Application("show_user_field_on_direct_buy") = 1)then
		Dim objUserField, objListUserField
		On Error Resume Next
		Set objUserField = new UserFieldClass
		Set objListUserField = objUserField.getListUserField(1,"2,3")
		if(objListUserField.count > 0)then
			for each k in objListUserField
				On Error Resume Next
					user_field_value = ""
					Set objField = objListUserField(k)
					select Case objField.getTypeField()
					Case 6,7
						user_field_value = request("hidden_"&objUserField.getFieldPrefix()&objField.getID())
					Case Else
						user_field_value = request(objUserField.getFieldPrefix()&objField.getID())			
					End Select
					call objUserField.insertFieldMatch(objField.getID(), idUserMax, user_field_value, objConn)			
				if(Err.number<>0) then
					'response.write(Err.description)
				end if
			next
		end if
	
		Set objUserField =nothing
		Set objListUserField = nothing
	
		if(Err.number <> 0) then
		end if
	end if

	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
	else
		objConn.RollBackTrans
		'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if	
	Set objDB = nothing
end if

if not(isEmpty(Session("objUtenteLogged"))) then
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing

	if(request("buy_noreg")="1")then
		Session.Contents.Remove("objUtenteLogged")
	end if
		
	Dim id_carrello, objCarrelloUser, stato_order, carrello
	Dim totale_ord, tipo_pagam, pagam_done, spese_sped_order, sconto_cliente, user_notified_x_download, orderNotes, noRegistration, id_ads
	
	strGerarchia = request("gerarchia")
	id_carrello = request("id_carrello")
	stato_order = 1
	totale_ord = 0
	tipo_pagam = request("tipo_pagam")
	pagam_done = 0
	spese_sped_order = 0
	sconto_cliente = objUserLogged.getSconto()
	user_notified_x_download = 0
	orderNotes = request("order_notes")
	noRegistration = request("buy_noreg")
	id_ads = request("id_ads")

	Dim hasScontoCli, hasGroup, groupCliente, objSelMargin
	hasScontoCli = false
	hasGroup = false

	groupCliente = objUserLogged.getGroup()
	if(not(groupCliente= "")) then
		On Error Resume Next
		Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
		groupDesc = objTmpGr.getShortDesc()
		if (not(isNull(objTmpGr.getTaxGroup()))) then
			Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
		end if
		hasGroup = true
		Set objTmpGr = nothing
		
		Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
		if(Err.number <> 0) then
			hasGroup = false
		end if
	end if

	if(not(sconto_cliente= "")) then
		sconto_cliente = Cdbl(sconto_cliente)
		if(sconto_cliente > 0) then
			hasScontoCli = true
		end if
	end if
	Set objGroup = nothing
		
	if(id_carrello = "") then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=022")
	end if
	
	Set carrello = New CardClass
	Set objProdField = new ProductFieldClass
	Set objCarrelloUser = carrello.getCarrelloByIDCarello(id_carrello)
	
	Dim totaleProdottoImp4spese, totale_carrello, totaleProdottoImp4order, totaleProdottoTax4order
	totaleProdottoImp4spese = 0
	totaleProdottoImp4order = 0
	totaleProdottoTax4order = 0
	
	if(not(isNull(objCarrelloUser))) then
		call objCarrelloUser.updateIDUtenteCarrello(id_carrello, objUserLogged.getUserID())
		
		Dim objProdPerCarrello, objListaCarrello
		Set objProdPerCarrello = New ProductsCardClass
		Set objListaCarrello = objProdPerCarrello.retrieveListaProdotti(objCarrelloUser.getIDCarrello())
		
		if (not(isNull(objListaCarrello)) AND not(isEmpty(objListaCarrello))) then
			Dim objOrdine, objProdTmp
			Set objOrdine = New OrderClass
			Set objProdTmp = New ProductsClass
			Set objProdField = new ProductFieldClass
			Set objRule = new BusinessRulesClass
			Set objVoucherClass =  new VoucherClass

			Dim hasOrderRule, hasValidVoucher, hasActiveVoucherCampaign
			hasOrderRule = false
			hasValidVoucher = false
			hasActiveVoucherCampaign = false
			bolVoucherExcludeProdRule = false
			objVoucher=null

			'********** VERIFICO SE ESISTE UNA CAMPAGNA VOUCHER ATTIVA E SE E' STATO INSERITO UN VOUCHER E IN TAL CASO CERCO UNA RULE DI TIPO VOUCHER
			On Error Resume Next
			Set objOrderRule = objRule.getListaRules("3", 1)
			if(objOrderRule.count>0) then
				hasActiveVoucherCampaign = true
			end if
			if(Err.number <> 0) then
				hasActiveVoucherCampaign = false
			end if

			if (hasActiveVoucherCampaign AND request("voucher_code")<>"") then
				On Error Resume Next 
				Set objVoucher=  objVoucherClass.validateVoucherCode(Trim(request("voucher_code")))
				'response.write("typename(objVoucher): "&typename(objVoucher)&"<br>")
				if(strComp(typename(objVoucher), "VoucherClass") = 0)then
					hasValidVoucher = true
					if(objVoucher.getExcludeProdRule())then
						bolVoucherExcludeProdRule = true
					end if
				end if
				if(Err.number <> 0) then
					hasValidVoucher = false
				end if 

				On Error Resume Next
				if(hasValidVoucher) then
					hasOrderRule = true
				end if
				if(Err.number <> 0) then
					hasOrderRule = false
				end if  
			end if
			
			if(request("buy_noreg")="0")then
				'*** verifico se esiste una rule primo ordine e se l'utente ne possiede i requisiti
				On Error Resume Next
				if not(hasOrderRule) then  
					if(Cint(objOrdine.countUserOrder(objUserLogged.getUserID()))=0)then
						Set objOrderRule = objRule.getListaRules("4,5", 1)  
						if(objOrderRule.count>0) then
							hasOrderRule = true
						end if
					end if
				end if
				if(Err.number <> 0) then
					hasOrderRule = false
				end if
			end if

			'********** SE NON ESISTE GIA' UNA RULE PRIMO ORDINE, CERCO TUTTE LE RULE PER ORDINE ATTIVE
			if not(hasOrderRule) then
				On Error Resume Next 
				Set objOrderRule = objRule.getListaRules("1,2", 1)  
				if(objOrderRule.count>0) then
					hasOrderRule = true
				end if
				if(Err.number <> 0) then
					hasOrderRule = false
				end if  
			end if

			Dim dta_ins, DD, MM, YY, HH, MIN, SS
			dta_ins = Now()
			DD = DatePart("d", dta_ins)
			MM = DatePart("m", dta_ins)
			YY = DatePart("yyyy", dta_ins)
			HH = DatePart("h", dta_ins)
			MIN = DatePart("n", dta_ins)
			SS = DatePart("s", dta_ins)
			dta_ins = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS	


			Dim objYmpKey, k, objTasse, applyBills
			Dim objProdPerOrder, objProdToChangeQtam, numOldQta, objProdToChangeQta
			objYmpKey = objListaCarrello.Keys			
			Set objProdPerOrder = New Products4OrderClass
			Set objDictProdXOrd = Server.CreateObject("Scripting.Dictionary")  
			Set objDictSpeseXOrd = Server.CreateObject("Scripting.Dictionary")  
			Set objHasField4ProdDict = Server.CreateObject("Scripting.Dictionary") 
			Set objListField4ProdDict = Server.CreateObject("Scripting.Dictionary")
			Set objListProdToChangeQta = Server.CreateObject("Scripting.Dictionary")			


			'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
			Dim international_country_code, international_state_region_code, userIsCompanyClient
			international_country_code = ""
			international_state_region_code = ""
			userIsCompanyClient = 0
			applyBills = false
			
			Set objTasse = new TaxsClass	

			Dim totale_qta_carrello, objListAllFieldxProd
			totale_qta_carrello = 0	

			'** inizializzo mappa dei field per prodotto selezionati				 
			Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")	

			bolHasProdRule = false
			bolHasProdRelRule = false

			if not(bolVoucherExcludeProdRule)then
				'** cerco le business rule basate sui prodotti
				On Error Resume Next 
				Set objProdRule = objRule.getListaRules("6,7,10", 1)  
				if(objProdRule.count>0) then
					bolHasProdRule = true
				end if
				if(Err.number <> 0) then
					bolHasProdRule = false
				end if 

				'** cerco le business rule basate sui prodotti correlati
				On Error Resume Next 
				Set objProdRelRule = objRule.getListaRules("8,9", 1)  
				if(objProdRelRule.count>0) then
					bolHasProdRelRule = true
				end if
				if(Err.number <> 0) then
					bolHasProdRelRule = false
				end if 
			end if

			'*** ciclo sui prodotti per carrello e costruisco due mappe, una con i prodotti recuperati da DB, l'altra con la lista di prodotti abbinati a qta e imponibile da usare per le business rules
			Set objListUniqueConcreteProd = Server.CreateObject("Scripting.Dictionary")
			Set objListProd4Rule = Server.CreateObject("Scripting.Dictionary")

			for each k in objYmpKey
				On Error Resume Next           
				if not(objListUniqueConcreteProd.Exists(objListaCarrello.item(k).getIDProd()))then
					Set objTmpConcreteProd = objProdTmp.findProdottoByID(objListaCarrello.item(k).getIDProd(),0)
					objListUniqueConcreteProd.add objTmpConcreteProd.getIDProdotto(), objTmpConcreteProd

					Set objTmpPRVO = new ProductRulesVO              
					objTmpPRVO.idProd = objTmpConcreteProd.getIDProdotto()
					objTmpPRVO.counterProd = objListaCarrello.item(k).getCounterProd()
					Set objTmpPRVO.objProd = objTmpConcreteProd
					objTmpPRVO.totQta = objListaCarrello.item(k).getQtaProd()
					objListProd4Rule.add objTmpPRVO.idProd, objTmpPRVO
					Set objTmpPRVO=nothing
				else
					tmp_qta = objListProd4Rule(objListaCarrello.item(k).getIDProd()).totQta
					tmp_qta = Cint(tmp_qta)+Cint(objListaCarrello.item(k).getQtaProd())
					objListProd4Rule(objListaCarrello.item(k).getIDProd()).totQta=tmp_qta
				end if          
				if(Err.number <> 0) then
				end if 
			next

		      for each k in objYmpKey
			Set objTmpCarrProd = objListaCarrello.item(k)
			'*** se esistono delle business rules attive sui prodotti correlati cerco le configurazioni specifiche per ogni prodotto e aggiorno l'oggetto objListProd4Rule
			if(bolHasProdRelRule) then
			  for each b in objProdRelRule
			    On Error Resume Next
			    'response.write("objProdRelRule(b): "&objProdRelRule(b).getLabel()&"<br>")
			    Set objTmpResStrategy = objProdRelRule(b).getAmountByStrategy(null, null, objTmpCarrProd.getIDProd(), objListProd4Rule)
			    Set objListProd4Rule = objTmpResStrategy.objListPRVO
			    Set objTmpResStrategy = nothing
			    if(Err.number <> 0) then
			    end if 
			  next
			end if              
		      next

			for each k in objYmpKey
				Set objTmpCarrProd = objListaCarrello.item(k)
				'Set objProdToChangeQta = objProdTmp.findProdottoByID(objTmpCarrProd.getIDProd(),0)
				Set objProdToChangeQta = objListUniqueConcreteProd(objTmpCarrProd.getIDProd())
				
				'*** aggiungo il prodotto recuperato alla lista dei prodotti del carrello, da usare nelle elaborazioni successive senza richiamare il DB
				if not(objListProdToChangeQta.exists(objTmpCarrProd.getIDProd())) then
					objListProdToChangeQta.add objTmpCarrProd.getIDProd(), objProdToChangeQta
				end if				
				
				totaleProdottoImp = 0
				totaleProdottoTax = 0
				taxDesc = ""
				prod_type = objProdToChangeQta.getProdType()
		
				'*** verifico l'esistenza dei field per prodotto
				On Error Resume Next								
				objHasField4ProdDict.add k,false
				
				if (Instr(1, typename(objProdField.findListFieldXCardByProd(objTmpCarrProd.getCounterProd(), objCarrelloUser.getIDCarrello(), objTmpCarrProd.getIDProd())), "Dictionary", 1) > 0) then
					Set objDictField4Prod = objProdField.findListFieldXCardByProd(objTmpCarrProd.getCounterProd(), objCarrelloUser.getIDCarrello(), objTmpCarrProd.getIDProd())
					
					if(objDictField4Prod.count > 0)then
						if (prod_type=0) then
							'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
							Set objDict = Server.CreateObject("Scripting.Dictionary")
							objListAllFieldxProd.add objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd(), objDict
						end if

						for each q in objDictField4Prod										
							Set objTmpField4Prod = objDictField4Prod(q)
							keys = objTmpField4Prod.Keys	
							for each r in keys
								Set tmpF4O = r
								if (prod_type=0) then
									Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
									objDictFieldxProd.add "id", tmpF4O.getID()
									objDictFieldxProd.add "value", tmpF4O.getSelValue()
									objDictFieldxProd.add "qta", objTmpCarrProd.getQtaProd()
									objListAllFieldxProd(objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd()).add objDictFieldxProd, ""
									'call objLogger.write("r id: " & objDictFieldxProd("id")&" - value: " & objDictFieldxProd("value")&" - qta: " & objDictFieldxProd("qta"), "system", "debug")
									Set objDictFieldxProd = nothing
								end if
								Set tmpF4O = nothing
							next
							Set objTmpField4Prod = nothing							
						next
						Set objDict = nothing

						' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
						'objHasField4ProdDict.remove(k)
						'objHasField4ProdDict.add k,true	
						objHasField4ProdDict.Item(k) = true			
					end if
				end if
				if(Err.number <> 0) then
					' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
					'objHasField4ProdDict.remove(k)
					'objHasField4ProdDict.add k,false
					objHasField4ProdDict.Item(k) = false					
				end if

				'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
				if (Instr(1, typename(objProdField.getListProductField4ProdActive(objTmpCarrProd.getIDProd())), "Dictionary", 1) > 0) then
					Set fieldList4CardH = objProdField.getListProductField4ProdActive(objTmpCarrProd.getIDProd())			
				
					if(fieldList4CardH.count > 0)then
						if (prod_type=0) then
							'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
							Set objDict = Server.CreateObject("Scripting.Dictionary")
							if not(objListAllFieldxProd.Exists(objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd()))then
								objListAllFieldxProd.add objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd(), objDict
							end if
	
							for each d in fieldList4CardH
								if((fieldList4CardH(d).getTypeContent()=2 OR fieldList4CardH(d).getTypeContent()=3) AND (fieldList4CardH(d).getEditable()=0))then
									Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
									objDictFieldxProd.add "id", fieldList4CardH(d).getID()
									objDictFieldxProd.add "value", fieldList4CardH(d).getSelValue()
									objDictFieldxProd.add "qta", objTmpCarrProd.getQtaProd()
	
									bolCanAdd = true
									On Error Resume Next
									for each i in objListAllFieldxProd(objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd())
										if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
											bolCanAdd = false
											Exit for
										end if
									next
	
									if(bolCanAdd)then
										objListAllFieldxProd(objTmpCarrProd.getCounterProd()&"-"&objTmpCarrProd.getIDProd()).add objDictFieldxProd, ""
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


				if(hasGroup) then
					On Error Resume Next
					totaleProdottoImp = CDbl(objProdToChangeQta.getPrezzo()) * objTmpCarrProd.getQtaProd()
					totaleProdottoImp = objSelMargin.getAmount(totaleProdottoImp,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objProdToChangeQta.getsconto()),CDbl(sconto_cliente))
					if(Err.number <>0) then
					end if	
				else
					if(objProdToChangeQta.hasSconto() AND (not(hasScontoCli) OR (hasScontoCli AND Application("manage_sconti") = 1))) then
						totaleProdottoImp = CDbl(objProdToChangeQta.getPrezzoScontato()) * objTmpCarrProd.getQtaProd()
						if(hasScontoCli)then
							totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * sconto_cliente)							
						end if
					else
						totaleProdottoImp = CDbl(objProdToChangeQta.getPrezzo()) * objTmpCarrProd.getQtaProd()
						if(hasScontoCli)then
							totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * sconto_cliente)							
						end if
					end if
				end if
				

				'*** se esistono delle business rules attive sui prodotti cerco le configurazioni specifiche per ogni prodotto e applico il risultato all'imponibile prodotto
				if(bolHasProdRule) then
					'response.write("totaleProdottoImp: "&totaleProdottoImp&"<br>")
					for each b in objProdRule
						On Error Resume Next
						'response.write("objProdRule(b): "&objProdRule(b).getLabel()&"<br>")
						Set objTmpResStrategy = objProdRule(b).getAmountByStrategy(null, null, objTmpCarrProd.getIDProd(), objListProd4Rule)
						'response.write("objTmpResStrategy.foundAmount: "&objTmpResStrategy.foundAmount&"<br>")
						found_prule_amount = FormatNumber(objTmpResStrategy.foundAmount, 2,-1)
						Set objListProd4Rule = objTmpResStrategy.objListPRVO
						totaleProdottoImp=totaleProdottoImp+CDbl(found_prule_amount)        
						Set objTmpResStrategy = nothing
						'response.write("totaleProdottoImp: "&totaleProdottoImp&"<br>")
						if(Err.number <> 0) then
						end if 
					next
				end if  
				
				if(bolHasProdRelRule) then
					'*** aggiungo il valore calcolato nella business strategy (> 0 solo se e una regola su prodotto correlato)
					totaleProdottoImp=totaleProdottoImp+CDbl(objListProd4Rule(objTmpCarrProd.getIDProd()).resultAmount)     
					'response.write("objListProd4Rule(objSelProdotto.getIDProd()).resultAmount: "&objListProd4Rule(objTmpCarrProd.getIDProd()).resultAmount&"<br>") 				
				end if

				'***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
				applyOrigTax = true
				if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
					if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
						On Error Resume Next
						' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
						if(Cint(userIsCompanyClient)=1 AND groupClienteTax.isTaxExclusion(groupClienteTax.getID(), international_country_code,international_state_region_code))then
							totaleProdottoTax = 0
							taxDesc = langEditor.getTranslated("backend.prodotti.label.tax_excluded")							
							applyOrigTax = false
						else
							objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
							if(not(isNull(objRelatedTax))) then
							  Set objTaxG = objTasse.findTassaByID(objRelatedTax)
								totaleProdottoTax = groupClienteTax.getImportoTassa(totaleProdottoImp, objTaxG)
								taxDesc = objTaxG.getDescrizioneTassa()
								Set objTaxG = nothing
								applyOrigTax = false
							else
								applyOrigTax = true		
							end if
						end if
						if(Err.number<>0)then
							applyOrigTax = true
						end if	
					else
						On Error Resume Next
						Set groupProdTax = objProdToChangeQta.getTaxGroupObj(objProdToChangeQta.getTaxGroup()) 
						if(Instr(1, typename(groupProdTax), "TaxsGroupClass", 1) > 0) then
							' verifico se l'utente ha selezionato il flag tipologia cliente=societa' e se per il country/region selezionato il falg escludi tassa è attivo
							if(Cint(userIsCompanyClient)=1 AND groupProdTax.isTaxExclusion(groupProdTax.getID(), international_country_code,international_state_region_code))then
								totaleProdottoTax = 0
								taxDesc = langEditor.getTranslated("backend.prodotti.label.tax_excluded")								
								applyOrigTax = false
							else	
								objRelatedTax = groupProdTax.findRelatedTax(groupProdTax.getID(), international_country_code,international_state_region_code)				  
								if(not(isNull(objRelatedTax))) then
									Set objTaxG = objTasse.findTassaByID(objRelatedTax)
									totaleProdottoTax = groupProdTax.getImportoTassa(totaleProdottoImp, objTaxG)
									taxDesc = objTaxG.getDescrizioneTassa()
									Set objTaxG = nothing
									applyOrigTax = false		
								end if
							end if
						else
							applyOrigTax = true
						end if
						Set groupProdTax = nothing
						if(Err.number<>0)then
							applyOrigTax = true
						end if
					end if
				end if
				if(applyOrigTax)then
					totaleProdottoTax = 0
					taxDesc = ""
					if not(isNull(objProdToChangeQta.getIDTassaApplicata())) AND not(objProdToChangeQta.getIDTassaApplicata() = "") then
						totaleProdottoTax = objProdToChangeQta.getImportoTassa(totaleProdottoImp)
						taxDesc = objTasse.findTassaByID(objProdToChangeQta.getIDTassaApplicata()).getDescrizioneTassa()
					end if
				end if


				'************ se il prodotto non e' di tipo scaricabile aggiorno l'imponibile su cui verranno calcolate le spese di spedizione
				if (prod_type=0 AND not(objListProd4Rule(objTmpCarrProd.getIDProd()).bolExcludeBills)) then
					totaleProdottoImp4spese = totaleProdottoImp4spese+totaleProdottoImp
					totale_qta_carrello=totale_qta_carrello+Cint(objTmpCarrProd.getQtaProd())
					applyBills = true
				end if
				
				totaleProdottoImp4order = totaleProdottoImp4order+totaleProdottoImp
				totaleProdottoTax4order = totaleProdottoTax4order+totaleProdottoTax
				totale_ord = totale_ord+totaleProdottoImp+totaleProdottoTax
				
				Set objProdXOrder = new Products4OrderClass
				call objProdXOrder.setIDProdotto(objTmpCarrProd.getIDProd())
				call objProdXOrder.setCounterProd(objTmpCarrProd.getCounterProd())
				call objProdXOrder.setNomeProdotto(objProdToChangeQta.getNomeProdotto())
				call objProdXOrder.setQtaProdotto(objTmpCarrProd.getQtaProd())
				call objProdXOrder.setTotale(totaleProdottoImp)
				call objProdXOrder.setTax(totaleProdottoTax)
				call objProdXOrder.setDescTax(taxDesc)
				call objProdXOrder.setProdType(prod_type)
				objDictProdXOrd.add objTmpCarrProd.getIDProd()&"|"&objTmpCarrProd.getCounterProd(), objProdXOrder 
				Set objProdXOrder = nothing				
				Set objTmpCarrProd = nothing
				Set objProdToChangeQta = nothing
			next


			'*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
			if(hasOrderRule) then
				Set objDictRules = Server.CreateObject("Scripting.Dictionary")
				Set objDictVoucherUsed = Server.CreateObject("Scripting.Dictionary")
				
				totale_ord_old = totale_ord
				for each l in objOrderRule
					found_amount = objOrderRule(l).getAmountByStrategy(totale_ord_old, objVoucher,null,null).foundAmount
					
					'*** verifico se � stato usato un voucher e aggiungo il voucher a quelli da aggiornare su DB per l'ordine corrente
					if(Cint(objOrderRule(l).getRuleType)=3)then
						if ((strComp(typename(objVoucher), "VoucherClass") = 0) AND found_amount<>0)then
							Set objTmpVCode = new VoucherCodeClass	
							objTmpVCode.setID(objVoucher.getObjVoucherCode().getID())	
							objTmpVCode.setVoucherCode(objVoucher.getObjVoucherCode().getVoucherCode())	
							objTmpVCode.setVoucherCampaign(objVoucher.getObjVoucherCode().getVoucherCampaign())	
							objTmpVCode.setInsertDate(objVoucher.getObjVoucherCode().getInsertDate())	
							objTmpVCode.setUsageCounter(objVoucher.getObjVoucherCode().getUsageCounter())	
							objTmpVCode.setIdUserRef(objVoucher.getObjVoucherCode().getIdUserRef())		
							objTmpVCode.setValore(found_amount)								
							objDictVoucherUsed.add objVoucher.getObjVoucherCode().getID(), objTmpVCode
							Set objTmpVCode = nothing
						end if
					end if
					
					if(CDbl(found_amount)<>0)then
						found_amount = FormatNumber(found_amount, 2,-1)
						totale_ord=totale_ord+CDbl(found_amount)

						Set objRuleTmp = new OrderRulesVO
						objRuleTmp.idRule = objOrderRule(l).getID()
						objRuleTmp.label = objOrderRule(l).getLabel()
						objRuleTmp.amount = found_amount
						objDictRules.add objOrderRule(l).getID(), objRuleTmp
						Set objRuleTmp = nothing
					end if
				next
			end if
			

			'*** inserisco o aggiorno lo shipping address
			Dim ship_name, ship_surname, ship_cfiscvat, ship_address, ship_zip_code, ship_city, ship_country, ship_state_region, objShip, orderShip, ship_id
			if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then
				if(applyBills) OR (Application("enable_international_tax_option") = 1) then
					ship_name = request("ship_name")
					ship_surname = request("ship_surname")
					ship_cfiscvat = request("ship_cfiscvat")
					ship_address = request("ship_address")	
					ship_zip_code = request("ship_zip_code")
					ship_city = request("ship_city")
					ship_country = request("ship_country")
					ship_state_region = request("ship_state_region")
					userIsCompanyClient = request("ship_is_company_client")
					
					international_country_code = ship_country
					international_state_region_code = ship_state_region
				end if
			end if


			'*** inserisco o aggiorno il bills address
			'*** e' necessario che sia sempre visibile, anche per gli ordini con prodotti solo scaricabili;
			'*** senza i dati di fatturazione non si riesce a generare una fattura fiscalmente valida
			Dim bills_name, bills_surname, bills_cfiscvat, bills_address, bills_zip_code, bills_city, bills_country, bills_state_region, objBills, orderBills, bills_id
			if(Application("show_bills_box") = 1) then
				bills_name = request("bills_name")
				bills_surname = request("bills_surname")
				bills_cfiscvat = request("bills_cfiscvat")
				bills_address = request("bills_address")	
				bills_zip_code = request("bills_zip_code")
				bills_city = request("bills_city")
				bills_country = request("bills_country")
				bills_state_region = request("bills_state_region")
			end if

			Dim objBillsClass, objSpeseXOrdine, totSpeseImp, totSpeseTax, totSpese
			Dim objListaSpeseXCarrello, objTmpSpesa, objTmpSpesaXCarrello, objTmpSpesaOrd
			Set objBillsClass = new BillsClass		
			Set objSpeseXOrdine = new Bills4OrderClass

			On Error Resume Next
			Set objListaSpeseXCarrello = objBillsClass.getListaSpese(null, null, 1, null)		
			if Err.number <> 0 then
				objListaSpeseXCarrello = null
			end if

			totSpese = 0			
			
			On Error Resume Next
			if(applyBills) then
				if not(isNull(objListaSpese)) then
					oldGroupDesc = ""
					elements = ""
					Set objDictSelBills = Server.CreateObject("Scripting.Dictionary")	
					
					'recupero tutti i gruppi di spesa selezionati dal form
					for each k in objListaSpeseXCarrello
						Set objSpesaTmp = objListaSpeseXCarrello(k)
						if(objSpesaTmp.getAutoactive()=0)then
							if(oldGroupDesc<>objSpesaTmp.getGroup())then
								elements = request(objSpesaTmp.getGroup())								
								if(elements<>"")then
									elelmArr = Split(elements, ",", -1, 1)									
									for each i in elelmArr
										objDictSelBills.add Cint(i),""
									next
								end if
							end if					
							oldGroupDesc = objSpesaTmp.getGroup()
						end if
						Set objSpesaTmp = nothing
					next

					for each j in objListaSpeseXCarrello.Keys
						totSpeseImp = 0
						totSpeseTax = 0
						Set objTmpSpesaXCarrello = objListaSpeseXCarrello(j)

						'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
						totSpeseImp = objTmpSpesaXCarrello.getImpByStrategy(totaleProdottoImp4spese, totale_qta_carrello, objListAllFieldxProd)

						'if(CInt(objTmpSpesaXCarrello.getTipoValore()) = 2) then
							'totSpeseImp = CDbl(totaleProdottoImp4spese) / 100 * CDbl(objTmpSpesaXCarrello.getValore())
						'else
							'totSpeseImp = CDbl(objTmpSpesaXCarrello.getValore())
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
								Set groupBillsTax = objTmpSpesaXCarrello.getTaxGroupObj(objTmpSpesaXCarrello.getTaxGroup())	
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
							if not(isNull(objTmpSpesaXCarrello.getIDTassaApplicata())) AND not(objTmpSpesaXCarrello.getIDTassaApplicata() = "") then
								Set objBillTaxTmp = objTasse.findTassaByID(objTmpSpesaXCarrello.getIDTassaApplicata())
								if(objBillTaxTmp.getTipoValore() = 2) then
									totSpeseTax = CDbl(totSpeseImp) * (CDbl(objBillTaxTmp.getValore()) / 100)
								else
									totSpeseTax = CDbl(objBillTaxTmp.getValore())
								end if	
								Set objBillTaxTmp = nothing
							end if
						end if						
						
						
						if(objTmpSpesaXCarrello.getAutoactive()=1)then
							Set objTmpSpesaOrd = new Bills4OrderClass
							objTmpSpesaOrd.setIDSpesa(objTmpSpesaXCarrello.getSpeseID())
							objTmpSpesaOrd.setImponibile(totSpeseImp)
							objTmpSpesaOrd.setTasse(totSpeseTax)
							objTmpSpesaOrd.setTotale(totSpeseImp+totSpeseTax)
							objTmpSpesaOrd.setDescSpesa(objTmpSpesaXCarrello.getDescrizioneSpesa())
							objDictSpeseXOrd.add objTmpSpesaXCarrello.getSpeseID(), objTmpSpesaOrd 
							Set objTmpSpesaOrd = nothing
							
							totaleProdottoImp4order = totaleProdottoImp4order+totSpeseImp
							totaleProdottoTax4order = totaleProdottoTax4order+totSpeseTax
							totSpese = totSpese+totSpeseImp+totSpeseTax
						else
							if(objDictSelBills.Exists(j))then
								Set objTmpSpesaOrd = new Bills4OrderClass
								objTmpSpesaOrd.setIDSpesa(objTmpSpesaXCarrello.getSpeseID())
								objTmpSpesaOrd.setImponibile(totSpeseImp)
								objTmpSpesaOrd.setTasse(totSpeseTax)
								objTmpSpesaOrd.setTotale(totSpeseImp+totSpeseTax)
								objTmpSpesaOrd.setDescSpesa(objTmpSpesaXCarrello.getDescrizioneSpesa())
								objDictSpeseXOrd.add objTmpSpesaXCarrello.getSpeseID(), objTmpSpesaOrd 
								Set objTmpSpesaOrd = nothing
								
								totaleProdottoImp4order = totaleProdottoImp4order+totSpeseImp
								totaleProdottoTax4order = totaleProdottoTax4order+totSpeseTax
								totSpese = totSpese+totSpeseImp+totSpeseTax								
							end if
						end if
						
						Set objTmpSpesaXCarrello = nothing
					next	

					Set objListAllFieldxProd = nothing
					Set objDictSelBills = nothing
				end if
			end if
			
			Set objTasse = nothing
			Set objListaSpeseXCarrello = nothing
			Set objBillsClass = nothing
			Set objSpeseXOrdine = nothing
			
			If Err.Number<>0 then
			end if		
			
			totale_ord = totale_ord+totSpese
			payment_commission = 0
			

			'*** recupero la tipologia di pagamento selezionata per aggiornare eventuali commissioni
			Dim objPayment, objTmpPayment, payUrl, payId, payModule
			Set objPayment = New PaymentClass			
			Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
			payId = objTmpPayment.getPaymentID()
			payUrl = objTmpPayment.getURL()
			payModule = objTmpPayment.getPaymentModuleID()
			
			'*** se le commissioni sono > 0 e non sono gia state applicate, calcolo e aggiungo le commissioni in base alla tipologia di pagamento scelta
			if(Cdbl(objTmpPayment.getCommission()) > 0) then
				payment_commission = objTmpPayment.getImportoCommissione(totale_ord)
				totale_ord = CDbl(totale_ord)+payment_commission
			end if
	
			'*** imposto a due il numero di decimali
			totale_ord = FormatNumber(totale_ord,2,-1,-2,0)	
			
			Set objTmpPayment = Nothing
			Set objPayment = nothing


			'**** CREO IL GUID PER IL NUOVO ORDINE
			Dim strGUID
			strGUID = objGUID.CreateOrderGUID()
			
			' ***** ELIMINO IL CARRELLO
			call objCarrelloUser.deleteCarrello(objCarrelloUser.getIDCarrello())
			Set objCarrelloUser = nothing
			
			'***** ELIMINO IL VOUCHER CODE IN SESSIONE
			Session("voucher_code")=""


			Set objDB = New DBManagerClass
			Set objConn = objDB.openConnection()			
			objConn.BeginTrans

			Dim newIDOrder, objTmpCarrProd, objDownProd4Order, objDownProdList
			newIDOrder = objOrdine.insertOrdine(objUserLogged.getUserID(), dta_ins, stato_order, totaleProdottoImp4order, totaleProdottoTax4order, totale_ord, tipo_pagam, payment_commission, pagam_done, strGUID, user_notified_x_download, orderNotes, noRegistration, id_ads, objConn)	

			call objLogger.write("processcarrello --> inserimento nuovo ordine id: "&newIDOrder&" - user: "&objUserLogged.getUserID(), "system", "info")

			'*******************  SE ESISTONO DELLE RULES PER ORDINE LE INSERISCO NELLA TABELLA BUSINESS_RULES_X_ORDINE
			if(hasOrderRule) then
				for each a in objDictRules
					call objRule.insertRuleOrder(objDictRules(a).idRule, newIDOrder, 0, 0, objDictRules(a).label, objDictRules(a).amount, objConn)
				next
				Set objDictRules = nothing

				for each e in objDictVoucherUsed
					call objVoucherClass.insertVoucherOrder(newIDOrder, objDictVoucherUsed(e).getVoucherCode(), objDictVoucherUsed(e).getID(), objDictVoucherUsed(e).getValore(), objConn)
					call objVoucherClass.modifyVoucherCode(objDictVoucherUsed(e).getID(), objDictVoucherUsed(e).getVoucherCode(), objDictVoucherUsed(e).getVoucherCampaign(), objDictVoucherUsed(e).getInsertDate(), (objDictVoucherUsed(e).getUsageCounter()+1), objDictVoucherUsed(e).getIdUserRef(), objConn)
				next
				Set objDictVoucherUsed = nothing					
			end if

			'*** inserisco o aggiorno lo shipping address
			if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then
				if(applyBills) OR (Application("enable_international_tax_option") = 1) then	
					On Error Resume Next	
					Set orderShip = objShip.findShippingAddressByUserID(objUserLogged.getUserID())	
					if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
						call objShip.modifyShippingAddress(orderShip.getID(), orderShip.getUserID(), ship_address, ship_name, ship_surname, ship_cfiscvat, ship_city, ship_zip_code, ship_country, ship_state_region, userIsCompanyClient, objConn)
						call objShip.insertOrderShippingAddress(newIDOrder, orderShip.getID(), ship_address, ship_city, ship_zip_code, ship_country, ship_state_region, userIsCompanyClient, objConn)
					else
						ship_id = objShip.insertShippingAddress(objUserLogged.getUserID(), ship_address, ship_name, ship_surname, ship_cfiscvat, ship_city, ship_zip_code, ship_country, ship_state_region, userIsCompanyClient, objConn)
						call objShip.insertOrderShippingAddress(newIDOrder, ship_id, ship_address, ship_city, ship_zip_code, ship_country, ship_state_region, userIsCompanyClient, objConn)
					end if
					Set orderShip = nothing
	
					if(Err.number <> 0) then 
						call objLogger.write("processcarrello --> id ordine: "&newIDOrder&"; shipping address error: "&Err.description, "system", "error")
					end if
				end if
			end if


			'*** inserisco o aggiorno il bills address
			'*** e necessario che sia sempre visibile, anche per gli ordini con prodotti solo scaricabili;
			'*** senza i dati di fatturazione non si riesce a generare una fattura fiscalmente valida
			if(Application("show_bills_box") = 1) then	
				On Error Resume Next	
				Set orderBills = objBills.findBillsAddressByUserID(objUserLogged.getUserID())
				if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
					call objBills.modifyBillsAddress(orderBills.getID(), orderBills.getUserID(), bills_address, bills_name, bills_surname, bills_cfiscvat, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
					call objBills.insertOrderBillsAddress(newIDOrder, orderBills.getID(), bills_address, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
				else
					bills_id = objBills.insertBillsAddress(objUserLogged.getUserID(), bills_address, bills_name, bills_surname, bills_cfiscvat, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
					call objBills.insertOrderBillsAddress(newIDOrder, bills_id, bills_address, bills_city, bills_zip_code, bills_country, bills_state_region, objConn)
				end if	
				Set orderBills = nothing
	
				if(Err.number <> 0) then 
					call objLogger.write("processcarrello --> id ordine: "&newIDOrder&"; shipping address error: "&Err.description, "system", "error")
				end if
			end if

			'call objLogger.write("processcarrello --> punto superato", "system", "debug")


			Set objDownProd = new DownloadableProductClass
			Set objDownProd4Order = new DownloadableProduct4OrderClass

			Set objListDictField4ProdUpdateQta = Server.CreateObject("Scripting.Dictionary")
			Set objDictListOrderProdAvailability = Server.CreateObject("Scripting.Dictionary")
			Set objListOldQta4Prod = Server.CreateObject("Scripting.Dictionary")

			for each k in objDictProdXOrd
				Set objTmpCarrProd = objDictProdXOrd.item(k)
				Set objProdToChangeQta = objListProdToChangeQta(objTmpCarrProd.getIDProdotto())
				hasField4prod = objHasField4ProdDict(k)
				
				if not(objListOldQta4Prod.exists(objTmpCarrProd.getIDProdotto()))then
					objListOldQta4Prod.add objTmpCarrProd.getIDProdotto(), objProdToChangeQta.getQtaDisp()
				end if
				
				if(not(objProdToChangeQta.getQtaDisp() = Application("unlimited_key"))) then
					'*** se il prodotto ha dei campi associati controllo il loro valore e la quantita disponibile, 
					'*** se la quantita selezionata supera quella disponibile rimando indietro con l'errore
					if(hasField4prod)then						
						tmpf4pCounter = 1						
						
						Set objDictField4ProdUpdateQta = Server.CreateObject("Scripting.Dictionary")
			
						Set objDictField4ProdTmp = objListField4ProdDict(k)
						for each q in objDictField4ProdTmp

							Set objTmpField4Card = objDictField4ProdTmp(q)
							keys = objTmpField4Card.Keys										
							for each r in keys
								Set tmpF4O = r
								numOldField4ProdQta_ = objProdField.findFieldValueMatch(tmpF4O.getID(), tmpF4O.getIdProd(), tmpF4O.getSelValue())

								if(Trim(numOldField4ProdQta_) <> "" AND not(isNull(numOldField4ProdQta_)))then	
									if not(objListOldQta4Prod.exists(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()))then
										objListOldQta4Prod.add tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue(), numOldField4ProdQta_
									end if
								
									'********* verifico se esiste già nella lista ordine la combinazione tmpF4O.getIdProd()|tmpF4O.getID()|tmpF4O.getSelValue() e aggiungo il controllo sulla quantità totale
									qtaP4CToChangeTmp_ = objTmpCarrProd.getQtaProdotto()
									if(objDictListOrderProdAvailability.exists(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()))then
										qtaP4CToChangeTmp_ = CLng(objTmpCarrProd.getQtaProdotto()) + CLng(objDictListOrderProdAvailability(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()))
										call objDictListOrderProdAvailability.remove(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue())
									end if
									'call objLogger.write("process carrello qtaP4CToChangeTmp_: " & qtaP4CToChangeTmp_ & " - numOldField4ProdQta_: " &numOldField4ProdQta_ , "system", "debug")
									if(CLng(qtaP4CToChangeTmp_) <> 0 AND (CLng(numOldField4ProdQta_) - CLng(qtaP4CToChangeTmp_) < 0)) then		
										call objOrdine.deleteOrdine(newIDOrder, objConn)
										objConn.RollBackTrans	
										response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_carrello="&id_carrello&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&tmpF4O.getSelValue())&"&gerarchia="&strGerarchia)	
									end if
									'********* aggiorno la quantità totale per la combinazione: tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()
									objDictListOrderProdAvailability.add tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue(), qtaP4CToChangeTmp_

									'********* effettuo controllo sui campi correlati per verificare se la disponibilità è corretta
									On Error Resume Next
									'call objLogger.write("process carrello - tmpF4O.getIdProd(): " & tmpF4O.getIdProd() & ";  tmpF4O.getID(): " &  tmpF4O.getID() &"; tmpF4O.getSelValue(): "&tmpF4O.getSelValue(), "system", "debug")	
									Set listFieldRelVal = objProdField.findListFieldRelValueMatch(tmpF4O.getIdProd(), tmpF4O.getID(), tmpF4O.getSelValue())
									if(Instr(1, typename(listFieldRelVal), "Dictionary", 1) > 0) then
										if(listFieldRelVal.count>0)then
											bolHasRelFieldCombination = false
											for each t in keys
												Set tmpF4OR = t												
												'call objLogger.write("process carrello - tmpF4O.getIdProd(): " & tmpF4O.getIdProd() & ";  tmpF4O.getID(): " &  tmpF4O.getID() &"; tmpF4O.getSelValue(): "&tmpF4O.getSelValue() & "; tmpF4OR.getID(): " & tmpF4OR.getID() & ";  tmpF4OR.getSelValue(): " &  tmpF4OR.getSelValue(), "system", "debug")										
												if((tmpF4OR.getID()&tmpF4OR.getSelValue())<>(tmpF4O.getID()&tmpF4O.getSelValue()))then
													if(listFieldRelVal.exists(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))then
														qtaFieldRel = listFieldRelVal(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue())("qta_rel")	
														
														if not(objListOldQta4Prod.exists(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))then
															objListOldQta4Prod.add tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue(), qtaFieldRel
														end if
														
														'********* verifico se esiste già nella lista ordine la combinazione tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue() e aggiungo il controllo sulla quantità totale
														qtaP4CToChangeTmp_ = objTmpCarrProd.getQtaProdotto()
														if(objDictListOrderProdAvailability.exists(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))then
															qtaP4CToChangeTmp_ = CLng(objTmpCarrProd.getQtaProdotto()) + CLng(objDictListOrderProdAvailability(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()))
															call objDictListOrderProdAvailability.remove(tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue())
														end if
														'call objLogger.write("process carrello qtaP4CToChangeTmp_: " & qtaP4CToChangeTmp_ & " - qtaFieldRel: " &qtaFieldRel , "system", "debug")
														if(CLng(qtaP4CToChangeTmp_) <> 0 AND (CLng(qtaFieldRel) - CLng(qtaP4CToChangeTmp_) < 0)) then		
															call objOrdine.deleteOrdine(newIDOrder, objConn)
															objConn.RollBackTrans	
															response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_carrello="&id_carrello&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&tmpF4O.getSelValue()&" - "&tmpF4OR.getSelValue())&"&gerarchia="&strGerarchia)	
														end if
														
														'********* aggiorno la quantità totale per la combinazione:tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue()
														objDictListOrderProdAvailability.add tmpF4O.getIdProd()&"|"&tmpF4O.getID()&"|"&tmpF4O.getSelValue()&"|"&tmpF4OR.getID()&"|"&tmpF4OR.getSelValue(), CLng(qtaP4CToChangeTmp_)	
														bolHasRelFieldCombination = true
														Exit for
													end if
												end if
												Set tmpF4OR = nothing
											next
											if not(bolHasRelFieldCombination) then
												call objOrdine.deleteOrdine(newIDOrder, objConn)
												objConn.RollBackTrans	
												response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_carrello="&id_carrello&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&tmpF4O.getSelValue())&"&gerarchia="&strGerarchia)	
											end if
										end if
									end if

									Set listFieldRelVal = nothing
									if(err.number<>0)then
										call objLogger.write("process carrello pre check qta (listFieldRelVal) err.description: " & err.description, "system", "error")
									end if
									
									Set objDictField4ProdUpdateObj = Server.CreateObject("Scripting.Dictionary")	
									objDictField4ProdUpdateObj.add "idf4p",tmpF4O.getID()
									objDictField4ProdUpdateObj.add "idp4o",tmpF4O.getIdProd()
									objDictField4ProdUpdateObj.add "valf4p",tmpF4O.getSelValue()
									objDictField4ProdUpdateObj.add "qtach",objTmpCarrProd.getQtaProdotto()
									objDictField4ProdUpdateObj.add "qtaold",numOldField4ProdQta_
									
									objDictField4ProdUpdateQta.add tmpf4pCounter,objDictField4ProdUpdateObj
									Set objDictField4ProdUpdateObj = nothing
								end if
								tmpf4pCounter = tmpf4pCounter +1
								Set tmpF4O = nothing
							next
							Set objTmpField4Card = nothing	
						next
						Set objDictField4ProdTmp = nothing
						
						objListDictField4ProdUpdateQta.add k, objDictField4ProdUpdateQta
						Set objDictField4ProdUpdateQta = nothing
					end if
						
					numOldQta = objProdToChangeQta.getQtaDisp()

					'********* verifico se esiste già nella lista ordine la combinazione objTmpCarrProd.getIDProdotto() e aggiungo il controllo sulla quantità totale
					qtaP4CToChangeTmp_ = objTmpCarrProd.getQtaProdotto()
					if(objDictListOrderProdAvailability.exists(objTmpCarrProd.getIDProdotto()))then
						qtaP4CToChangeTmp_ = CLng(objTmpCarrProd.getQtaProdotto()) + CLng(objDictListOrderProdAvailability(objTmpCarrProd.getIDProdotto()))
						call objDictListOrderProdAvailability.remove(objTmpCarrProd.getIDProdotto())
					end if

					if(CLng(qtaP4CToChangeTmp_) <> 0 AND (CLng(numOldQta) - CLng(qtaP4CToChangeTmp_) < 0)) then
						call objOrdine.deleteOrdine(newIDOrder, objConn)
						objConn.RollBackTrans
						Set carrello = nothing
						response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_carrello="&id_carrello&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&"&gerarchia="&strGerarchia)	
					end if
					
					'********* aggiorno la quantità totale per la combinazione: objTmpCarrProd.getIDProdotto()
					objDictListOrderProdAvailability.add objTmpCarrProd.getIDProdotto(), qtaP4CToChangeTmp_
				end if

				Set objTmpCarrProd = nothing
				Set objProdToChangeQta = nothing
			Next


			for each k in objDictProdXOrd
				'call objLogger.write("k: "&k&" -objDictProdXOrd(k).getIDProdotto(): "&objDictProdXOrd(k).getIDProdotto()&" -objDictProdXOrd(k).getCounterProd(): "&objDictProdXOrd(k).getCounterProd(), "system", "debug")
				Set objTmpCarrProd = objDictProdXOrd.item(k)
				Set objProdToChangeQta = objListProdToChangeQta(objTmpCarrProd.getIDProdotto())
				hasField4prod = objHasField4ProdDict(k)
				
				'call objLogger.write("process carrello -k: "&k&" -hasField4prod: "& hasField4prod&" -objTmpCarrProd.getIDProdotto(): "&objTmpCarrProd.getIDProdotto()&" -objTmpCarrProd.getCounterProd(): "&-objTmpCarrProd.getCounterProd()&" -numOldQta: "&objProdToChangeQta.getQtaDisp()&" -objTmpCarrProd.getQtaProdotto(): " & objTmpCarrProd.getQtaProdotto(), "system", "debug")
				
				if(not(objProdToChangeQta.getQtaDisp() = Application("unlimited_key"))) then
					numOldQta = objListOldQta4Prod(objTmpCarrProd.getIDProdotto())

					isStillActive = objProdTmp.changeQtaProdotto(objTmpCarrProd.getIDProdotto(), objTmpCarrProd.getQtaProdotto(), numOldQta, objConn)
					if(isStillActive = 0) then
						'*** invio la mail prodotto esaurito
						Dim objMail
						Set objMail = New SendMailClass
						call objMail.sendMailProdEndDisp(objTmpCarrProd.getIDProdotto(), Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
						Set objMail = Nothing		
					end if

					newQta = CLng(numOldQta) - CLng(objTmpCarrProd.getQtaProdotto())
					' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
					'objListOldQta4Prod.remove(objTmpCarrProd.getIDProdotto())
					'objListOldQta4Prod.add objTmpCarrProd.getIDProdotto(), newQta
					objListOldQta4Prod.Item(objTmpCarrProd.getIDProdotto()) = newQta

					'call objLogger.write("process carrello (hasField4prod) "&k&": " & hasField4prod, "system", "debug")					
					
					'*** se il prodotto ha dei campi associati controllo il loro valore e la quantita disponibile, 
					'*** se la quantita selezionata supera quella disponibile rimando indietro con l'errore
					if(hasField4prod)then								
						'*** aggiorno le quantita per i singoli field per prodotto
						'call objLogger.write("process carrello objDictField4ProdUpdateQta.count: " & objListDictField4ProdUpdateQta.count, "system", "debug")	
						if(objListDictField4ProdUpdateQta.count > 0)then
							Set objListToChange = objListDictField4ProdUpdateQta(k)
							for each g in objListToChange
								Set objToChange = objListToChange(g)
								'call objLogger.write("process carrello typename(objToChange): " & typename(objToChange), "system", "debug")
								numqtaold= objListOldQta4Prod(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p"))
								isStillActive = objProdField.changeQtaFieldValueMatch(objToChange("idf4p"), objToChange("idp4o"), objToChange("valf4p"), objToChange("qtach"), numqtaold, objConn)

								newqtach = CLng(numqtaold) - CLng(objToChange("qtach"))
								' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
								'objListOldQta4Prod.remove(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p"))
								'objListOldQta4Prod.add objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p"), newqtach
								objListOldQta4Prod.Item(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")) = newqtach

								'********* effettuo controllo sui campi correlati per modificare la disponibilità corretta
								On Error Resume Next
								'call objLogger.write("process carrello - objToChange(idp4o): " & objToChange("idp4o") & "; objToChange(idf4p): " &  objToChange("idf4p") &"; objToChange(valf4p): "&objToChange("valf4p"), "system", "debug")
								Set listFieldRelVal = objProdField.findListFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"))
								if(Instr(1, typename(listFieldRelVal), "Dictionary", 1) > 0) then
									if(listFieldRelVal.count>0)then
										for each t in objListToChange
											Set tmpF4OR = objListToChange(t)
											'call objLogger.write("process carrello - tmpF4OR(idf4p): " & tmpF4OR("idf4p") & "; tmpF4OR(valf4p): " &  tmpF4OR("valf4p"), "system", "debug")
											if((tmpF4OR("idf4p")&tmpF4OR("valf4p"))<>(objToChange("idf4p")&objToChange("valf4p")))then
												if(listFieldRelVal.exists(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p")))then
													qtaFieldRel= objListOldQta4Prod(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p"))
													'call objLogger.write("process carrello qtaFieldRel: " & qtaFieldRel&" -qtach: "&objToChange("qtach"), "system", "debug")
													isStillActive = objProdField.changeQtaFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"), tmpF4OR("idf4p"), tmpF4OR("valf4p"), objToChange("qtach"), qtaFieldRel, objConn)

													newqtaFieldRel = CLng(qtaFieldRel) - CLng(objToChange("qtach"))
													' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
													'objListOldQta4Prod.remove(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p"))
													'objListOldQta4Prod.add objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p"), newqtaFieldRel
													objListOldQta4Prod.Item(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p")) = newqtaFieldRel
												end if
											end if
											Set tmpF4OR = nothing
										next
									end if
								end if

								Set listFieldRelVal = nothing
								if(err.number<>0)then
									call objLogger.write("process carrello post check qta (listFieldRelVal) err.description: " & err.description, "system", "error")
								end if

								Set objToChange = nothing
							next
							Set objListToChange = nothing
						end if
					end if					
				end if

				'*** se il prodotto hai dei campi associati li inserisco sul DB
				if(hasField4prod)then				
					Set objDictField4ProdTmp = objListField4ProdDict(k)
					for each a in objDictField4ProdTmp
						Set objTmpField4Card = objDictField4ProdTmp(a)
						keys = objTmpField4Card.Keys
						
						for each r in keys
							Set tmpF4O = r
							call objProdField.insertFieldXOrder(tmpF4O.getFcCounter(), newIDOrder, tmpF4O.getIdProd(), tmpF4O.getID(), tmpF4O.getQtaProd(), tmpF4O.getSelValue(), objConn)
							Set tmpF4O = nothing
						next
						Set objTmpField4Card = nothing							
					next
					Set objDictField4ProdTmp = nothing	
				end if
				
				call objProdPerOrder.insertProdottiXOrdine(newIDOrder, objTmpCarrProd.getIDProdotto(), objTmpCarrProd.getCounterProd(), objProdToChangeQta.getNomeProdotto(), objTmpCarrProd.getQtaProdotto, objTmpCarrProd.getTotale(), objTmpCarrProd.getTax(), objTmpCarrProd.getDescTax(), objTmpCarrProd.getProdType(), objConn)			

				'*** inserisco gli eventuali prodotti da scaricare con download
				if(objProdToChangeQta.getProdType()=1)then
					On Error Resume Next
					Set objDownProdList = objDownProd.getFilePerProdotto(objTmpCarrProd.getIDProdotto())
					for each r in objDownProdList
						call objDownProd4Order.insertDownProd(newIDOrder, objTmpCarrProd.getIDProdotto(), r, objUserLogged.getUserID(), 0, objProdToChangeQta.getMaxDownload(), now(), null, 0, null,objConn)
					next
					if(Err.number <> 0)then 
						call objLogger.write("processcarrello --> id ordine: "&newIDOrder&"; downloadable prod error: "&Err.description, "system", "error")
					end if
				end if

				Set objTmpCarrProd = nothing
				Set objProdToChangeQta = nothing
			Next

			'*** inserisco eventuali rule per prodotto
			for each l in objListProd4Rule
				if (objListProd4Rule(l).listRelrulesLabel.count>0) then
					for each w in objListProd4Rule(l).listRelrulesLabel
						tmpIdRule = Left(w,InStr(1,w,"-",1)-1)
						tmpLabel = Mid(w,InStr(1,w,"|",1)+1)                  
						tmp_amount_rule = objListProd4Rule(l).listRelrulesLabel(w)
						call objRule.insertRuleOrder(tmpIdRule, newIDOrder, l, objListProd4Rule(l).counterProd, tmpLabel, tmp_amount_rule, objConn)
						'call objLogger.write("processcarrello --> id ordine: "&newIDOrder&"- IDProdotto(): "&l&" -tmpIdRule: "&tmpIdRule&" -tmpLabel: "&tmpLabel&" -tmp_amount_rule: "&tmp_amount_rule, "system", "debug")
					next
				end if
			next
				
			Set objListOldQta4Prod = nothing
			Set objDictListOrderProdAvailability = nothing
			Set objListDictField4ProdUpdateQta = nothing				

			Set objDownProd4Order = nothing
			Set objDownProd = nothing

			for each q in objDictSpeseXOrd.Keys
				Set objTmpSpesaXOrdine = objDictSpeseXOrd.item(q)				
				call objTmpSpesaXOrdine.insertSpeseXOrdine(newIDOrder, objTmpSpesaXOrdine.getIDSpesa(), objTmpSpesaXOrdine.getImponibile(), objTmpSpesaXOrdine.getTasse(), objTmpSpesaXOrdine.getTotale(), objTmpSpesaXOrdine.getDescSpesa(), objConn)
				Set objTmpSpesaXOrdine = nothing
			next

			
			if objConn.Errors.Count = 0 then
				objConn.CommitTrans
			else
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
			end if
			
			Set objDB = nothing
			
			Set objListField4ProdDict = nothing
			Set objHasField4ProdDict = nothing
			Set objProdField = nothing
			Set objDictProdXOrd = nothing
			Set objDictSpeseXOrd = nothing
			Set objProdPerOrder = nothing
			Set objTmpCarrProd = nothing
			Set objProdToChangeQta = nothing
			Set objVoucherClass = nothing
			Set objRule = nothing
			Set objOrdine = nothing
			Set objProdTmp = nothing
			
			if (CInt(payUrl) = 1) then
				Set objCarrelloUser = nothing
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

				Dim objUtil
				Set objUtil = new UtilClass

				checkout_parameters = objUtil.getUniqueKeyOrderIdPayment()&"="&newIDOrder&"&"&objUtil.getUniqueKeyOrderAmountPayment()&"="&objUtil.convertDoubleDelimiter4External(totale_ord)&"&"&objUtil.getUniqueKeyOrderGUIDPayment()&"="&strGUID&"&"&objUtil.getUniqueKeyOrderTypePayment()&"="&tipo_pagam
	
				set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
				objHttp.open "POST", pageModuleCheckout, false
				objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
				objHttp.Send(checkout_parameters)
				response.Write(objHttp.responseText)
				set objHttp = nothing
	
			
				''compongo il codice per l'invio ordine criptato
				''Set objCrypt = new CryptClass
				'Set listaCheckoutMatchFields = Server.CreateObject("Scripting.Dictionary")
				''listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), objCrypt.EnCrypt(strGUID&"|"&newIDOrder&"|"&totale_ord)
				'listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderIdPayment(), strGUID&"|"&newIDOrder&"|"&totale_ord
				'listaCheckoutMatchFields.add objUtil.getUniqueKeyOrderAmountPayment(), totale_ord
				''Set objCrypt = nothing
				
				'Dim objPayment2, obiCurrPayment, objPaymentField, fixedField, obiCurrPaymentFieldMatch, obiCurrPaymentFieldNotMatch, externalURL

				'Set objPayment2 = New PaymentClass
				'Set obiCurrPayment = objPayment2.findPaymentByID(tipo_pagam)
				'Set objPaymentField = new PaymentFieldClass
				'Set obiCurrPaymentFieldMatch = objPaymentField.getListaPaymentFieldDoMatch(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID())	
				'Set obiCurrPaymentFieldNotMatch = objPaymentField.getListaPaymentFieldNotMatch(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID())
				'Set fixedField = objPaymentField.getListaMatchFields()
				'externalURL = objPaymentField.findPaymentFieldByName(obiCurrPayment.getPaymentID(), obiCurrPayment.getPaymentModuleID(), objUtil.getUniqueKeyExtURLPayment()).getValueField()
				'Set fixedField = nothing
				'Set objPaymentField = nothing
				'Set obiCurrPayment = nothing
				'Set objPayment2 = nothing
				Set objUtil = nothing
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
				response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ConfirmOrdineCarrello.asp?id_ordine="&newIDOrder&"&gerarchia="&strGerarchia)			
			end if

		else
			Set carrello = nothing
			response.Redirect(Application("baseroot")&Application("error_page")&"?error=018")
		end if
		
		Set objProdPerCarrello = nothing
		Set objListaCarrello = nothing
	else
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=022")
	end if

	Set objShip = nothing
	Set objBills = nothing
	Set objGUID = nothing	
	Set objLogger = nothing
	Set objUserLogged = nothing
	Set objLogger = nothing
	
	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp?from=carrello")
end if
%>