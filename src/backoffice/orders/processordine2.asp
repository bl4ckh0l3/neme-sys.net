<%@ Language=VBScript %>
<%
Server.ScriptTimeout=3600 ' max value = 2147483647
Response.Expires=-1500
Response.Buffer = TRUE
Response.Clear%>
<!-- #include virtual="/common/include/Objects/FileUploadClass.asp" -->
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<%
'******************************* CREO UNA INNER CLASS PER GENERARE UNA COLLECTION DA UTILIZZARE NELL'ELABORAZIONE DELLA LISTA PRODOTTI
Class OrderProdVO
	Public idProdByList
	Public hasField4prod
	Public field4prodCounter
	Public idProd4Order
	Public qtaProd4Order
	Public objDictField4Prod
	Public updateqta4prod
	Public finalQta2change
	Public finalOldQta2change
	Public objProdToChangeQta
	Public objDictField4ProdUpdateQta

	Private Sub Class_Initialize()				
		hasField4prod = false
		field4prodCounter = 0
		idProd4Order = -1
		qtaProd4Order = 0
		Set objDictField4Prod = Server.CreateObject("Scripting.Dictionary")
		updateqta4prod = false
		finalQta2change = 0
		finalOldQta2change = 0
		objProdToChangeQta = null
		Set objDictField4ProdUpdateQta = Server.CreateObject("Scripting.Dictionary")
	End Sub

	Private Sub Class_Terminate()
	End Sub
End Class


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
	
	Dim id_ordine, id_utente, dta_ins, totale_ord, stato_order, tipo_pagam
	Dim pagam_done, complete_selected_prod_list, objProdPerOrder, order_modified, user_notified_x_download, orderNotes, noRegistration, id_ads


	Set Upload = New FileUploadClass
	Upload.SaveField()
	
	id_ordine = Upload.Form("id_ordine")		
	complete_selected_prod_list = Upload.Form("complete_selected_prod_list")
	order_modified = Upload.Form("order_modified")
	come_from_pagination = Upload.Form("come_from_pagination")

	Dim objOrdine, obiProdPerOrder
	Dim id_prodotto, nome_prodotto, qta_prod, totale_prod, arrProd
	Dim listOrder
	Dim objProdTmp, objProdToChangeQta, numOldQta
	Set objOrdine = New OrderClass
	Set objProdPerOrder = New Products4OrderClass
	Set objProdField = new ProductFieldClass

	Dim objOrdineEmail, objListaTipiPagamento, strTipoPagam, StrPagamDone
	Dim strCognomecliente, strNomeCliente, objUserTmp, sconto_cliente, payment_commission
	Dim DD, MM, YY, HH, MIN, SS
	Dim tot_prod_tmp, nome_prod_tmp
	
	Dim objLogger
	Set objLogger = New LogClass
	Dim objModOrder	
	Set objModOrder = objOrdine.findOrdineByID(id_ordine, false)
	
	id_utente = objModOrder.getIDUtente()
	dta_ins = objModOrder.getDtaInserimento()		
	DD = DatePart("d", dta_ins)
	MM = DatePart("m", dta_ins)
	YY = DatePart("yyyy", dta_ins)
	HH = DatePart("h", dta_ins)
	MIN = DatePart("n", dta_ins)
	SS = DatePart("s", dta_ins)
	dta_ins = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS		
	totale_imp_ord = objModOrder.getTotaleImponibile()
	totale_tasse_ord = objModOrder.getTotaleTasse()
	totale_ord = objModOrder.getTotale()
	tipo_pagam = objModOrder.getTipoPagam()
	payment_commission = objModOrder.getPaymentCommission()
	pagam_done = objModOrder.getPagamEffettuato()
	stato_order = objModOrder.getStatoOrdine()
	user_notified_x_download = objModOrder.isUserNotifiedXDownload()
	orderNotes = objModOrder.getOrderNotes()
	noRegistration = objModOrder.getNoRegistration()
	id_ads = objModOrder.getIdAdRef()
	Set objModOrder = nothing


	'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
	Dim international_country_code, international_state_region_code, userIsCompanyClient
	international_country_code = ""
	international_state_region_code = ""
	redirectParameters = ""
	userIsCompanyClient = 0
	
	if(Application("enable_international_tax_option")=1)then
		international_country_code = Upload.Form("ship_country")
		international_state_region_code = Upload.Form("ship_state_region")
	
		if(Trim(international_country_code) <> "") then
			userCountry = Trim(international_country_code)
			userStateRegion = Trim(international_state_region_code)
	
			if(Trim(Upload.Form("ship_name"))<>"") then userName = Upload.Form("ship_name") end if
			if(Trim(Upload.Form("ship_surname"))<>"") then userSurname = Upload.Form("ship_surname") end if
			if(Trim(Upload.Form("ship_cfiscvat"))<>"") then userCfiscVat = Upload.Form("ship_cfiscvat") end if            
			if(Trim(Upload.Form("ship_address"))<>"") then userAddress = Upload.Form("ship_address") end if
			if(Trim(Upload.Form("ship_zip_code"))<>"") then userCity = Upload.Form("ship_zip_code") end if
			if(Trim(Upload.Form("ship_city"))<>"") then userZipCode = Upload.Form("ship_city") end if
			if(Trim(Upload.Form("ship_is_company_client"))<>"") then userIsCompanyClient = Upload.Form("ship_is_company_client") end if
			
			if(Trim(Upload.Form("bills_name"))<>"") then buserName = Upload.Form("bills_name") end if
			if(Trim(Upload.Form("bills_surname"))<>"") then buserSurname = Upload.Form("bills_surname") end if
			if(Trim(Upload.Form("bills_cfiscvat"))<>"") then buserCfiscVat = Upload.Form("bills_cfiscvat") end if            
			if(Trim(Upload.Form("bills_address"))<>"") then buserAddress = Upload.Form("bills_address") end if
			if(Trim(Upload.Form("bills_zip_code"))<>"") then buserCity = Upload.Form("bills_city") end if
			if(Trim(Upload.Form("bills_city"))<>"") then buserZipCode = Upload.Form("bills_zip_code") end if
			if(Trim(Upload.Form("bills_country"))<>"") then buserCountry = Upload.Form("bills_country") end if
			if(Trim(Upload.Form("bills_state_region"))<>"") then buserStateRegion = Upload.Form("bills_state_region") end if

			redirectParameters = redirectParameters & "&ship_name=" & Server.URLEncode(userName)
			redirectParameters = redirectParameters & "&ship_surname=" & Server.URLEncode(userSurname)
			redirectParameters = redirectParameters & "&ship_cfiscvat=" & Server.URLEncode(userCfiscVat)
			redirectParameters = redirectParameters & "&ship_address=" & Server.URLEncode(userAddress)
			redirectParameters = redirectParameters & "&ship_zip_code=" & Server.URLEncode(userZipCode)
			redirectParameters = redirectParameters & "&ship_city=" & Server.URLEncode(userCity)
			redirectParameters = redirectParameters & "&ship_country=" & Server.URLEncode(userCountry)
			redirectParameters = redirectParameters & "&ship_state_region=" & Server.URLEncode(userStateRegion)
			redirectParameters = redirectParameters & "&ship_is_company_client=" & Server.URLEncode(userIsCompanyClient)

			redirectParameters = redirectParameters & "&bills_name=" & Server.URLEncode(buserName)
			redirectParameters = redirectParameters & "&bills_surname=" & Server.URLEncode(buserSurname)
			redirectParameters = redirectParameters & "&bills_cfiscvat=" & Server.URLEncode(buserCfiscVat)
			redirectParameters = redirectParameters & "&bills_address=" & Server.URLEncode(buserAddress)
			redirectParameters = redirectParameters & "&bills_zip_code=" & Server.URLEncode(buserZipCode)
			redirectParameters = redirectParameters & "&bills_city=" & Server.URLEncode(buserCity)
			redirectParameters = redirectParameters & "&bills_country=" & Server.URLEncode(buserCountry)
			redirectParameters = redirectParameters & "&bills_state_region=" & Server.URLEncode(buserStateRegion)
		end if
	
		if(Trim(international_country_code) = "")then
			Set objShip = new ShippingAddressClass
			On Error Resume Next		
			Set orderShip = objShip.findShippingAddressByUserID(id_utente)
			if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
			international_country_code = orderShip.getCountry()	
			if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
				international_state_region_code = orderShip.getStateRegion()
			end if		
			userIsCompanyClient = orderShip.isCompanyClient()
			hasShipAddress = true
			end if			
			Set orderShip = nothing			
			if(Err.number <> 0) then 
			'response.write(Err.description)
			end if
		end if	
	end if

	Dim redirectPage
	if(come_from_pagination="1") then
		redirectPage = Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?page="&Upload.Form("page")&"&items="&Upload.Form("items")&"&"
		redirectPage = redirectPage & "id_ordine="&id_ordine&"&order_modified="&order_modified
		redirectPage = redirectPage & "&target_cat="&Upload.Form("target_cat")&"&strGerarchiaTmp="&Upload.Form("strGerarchiaTmp")
	else
		redirectPage = Application("baseroot")&"/editor/ordini/InserisciOrdine3.asp?"	
		redirectPage = redirectPage & "id_ordine="&id_ordine&"&order_modified="&order_modified
		redirectPage = redirectPage & redirectParameters & "&complete_selected_prod_list="&Server.URLEncode(complete_selected_prod_list)
	end if

	'call objLogger.write("redirectPage: "&redirectPage, "system", "debug")

	Dim objGroup
	Set objGroup = new UserGroupClass
	Dim hasSconto, objClientTmp, scontoCliente, hasGroup, groupCliente
	
	hasSconto=false
	hasGroup = false
	scontoCliente = 0
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

		scontoCliente = objClientTmp.getSconto()
		if(not(scontoCliente= "")) then
			scontoCliente = Cdbl(scontoCliente)
			if(scontoCliente > 0) then
				hasSconto = true
			end if
		end if
		Set objClientTmp = nothing
	else
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	Dim objTmpListaProdBeforeChange, hasListaProdBeforeChange
	objTmpListaProdBeforeChange = null
	hasListaProdBeforeChange = false

	Set objProdTmp = New ProductsClass
	listOrder = Split(complete_selected_prod_list, "#", -1, 1)		
			
	On Error Resume Next
	Set objTmpListaProdBeforeChange = objProdPerOrder.getListaProdottiXOrdine(id_ordine)
	hasListaProdBeforeChange = true
	
	if(Err.number <> 0)then
		hasListaProdBeforeChange = false
	end if

	Set objRule = new BusinessRulesClass
	Set objVoucherClass =  new VoucherClass

	Dim hasOrderRule, hasValidVoucher, hasActiveVoucherCampaign, objDictRules, bolRulesAlreadyDeleted
	hasOrderRule = false
	hasValidVoucher = false
	hasActiveVoucherCampaign = false
	bolRulesAlreadyDeleted = false
	bolVoucherExcludeProdRule = false
	objVoucher=null
	hasOldActiveVoucher = false

	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans
			
	if(isArray(listOrder)) then
		Dim totImptmp, totTaxTmp, taxDesc, objTasse, prod_type, totImpTmp4bills, applyBills
		Set objTasse = new TaxsClass	

		totImptmp = 0
		totImpTmp4bills = 0
		totTaxTmp = 0
		taxDesc = ""	
		applyBills = false
		
		hasField4prod = false
		field4prodCounter = 0
		idProd4Order = -1
		qtaProd4Order = 0
				
	
		'call objProdPerOrder.deleteProdottiXOrdine(id_ordine, objConn)		

		Set objDictListOrderVO = Server.CreateObject("Scripting.Dictionary")
		Set objDictListOrderProdAvailability = Server.CreateObject("Scripting.Dictionary")
		Set objListOldQta4Prod = Server.CreateObject("Scripting.Dictionary")
		
		For y=LBound(listOrder) to UBound(listOrder)
			Set objOPVO= new OrderProdVO
	
			'ad ogni iterazione inizializzo la mappa dei field per prodotto e le variabili necessarie per fare update di prodotto, field e field correlati se non ci sono errori
			Set objDictField4Prod = Server.CreateObject("Scripting.Dictionary")
			updateqta4prod = false
			finalQta2change = 0
			finalOldQta2change = 0			
		
			'arrProd = Split(listOrder(y), "|", -1, 1)	
			arrProd = listOrder(y)
			
			'response.write("arrProd: "&arrProd&"<br>")
			'response.write("InStr: "&Instr(1,arrProd,"|",1 )&"<br>")
			
			sign = Left(arrProd,1)
			idProd4Order = Mid(arrProd,2,Instr(1,arrProd,"|",1 )-2)
			
			'response.write("sign: "&sign&"<br>")
			'response.write("idProd4Order: "&idProd4Order&"<br>")
			
			qtaProd4Order = 0
			
			if(Trim(sign)="+")then
				hasField4prod = true
				field4prodCounter = Mid(arrProd,Instr(1,arrProd,"|",1 )+1,Instr(1,arrProd,"[",1 )-Instr(1,arrProd,"|",1 )-1)
				qtaProd4Order = Right(arrProd,(Len(arrProd)-InStrRev(arrProd,"]",-1,1)))
				'response.write("Len(arrProd): "&Len(arrProd)&"<br>")				
				'response.write("Instr: "&Instr(1,arrProd,"]",1)&"<br>")
				'response.write("InstrRev: "&InStrRev(arrProd,"]",-1,1)&"<br>")
				arrProd = Mid(arrProd,Instr(1,arrProd,"[",1 )+1,Instr(1,arrProd,"]",1)-Instr(1,arrProd,"[",1 )-1)
				'response.write("sign: "&sign&"<br>")				
				'response.write("arrProd: "&arrProd&"<br>")
				'response.write("field4prodCounter: "&field4prodCounter&"<br>")
				'response.write("qtaProd4Order: "&qtaProd4Order&"<br>")
				arrProdFieldList = Split(arrProd, "$", -1, 1)	
				
				'call objLogger.write("field4prodCounter: "&field4prodCounter&"; qtaProd4Order: "&qtaProd4Order&"; arrProd: "&arrProd, "system", "debug")
			
				
				For t=LBound(arrProdFieldList) to UBound(arrProdFieldList)
					keyValue = Split(arrProdFieldList(t), "|", -1, 1)
					objDictField4Prod.add keyValue(0), keyValue(1)
				next
				
			else
				hasField4prod = false
				field4prodCounter = 0
				qtaProd4Order = Right(arrProd,(Len(arrProd)-InStrRev(arrProd,"|",-1,1)))
				
				'response.write("qtaProd4Order: "&qtaProd4Order&"<br>")
			end if
			
			'response.end
			
			Set objProdToChangeQta = objProdTmp.findProdottoByID(CLng(idProd4Order),false)

			if not(objListOldQta4Prod.exists(idProd4Order))then
				objListOldQta4Prod.add idProd4Order, objProdToChangeQta.getQtaDisp()
			end if

			'call objLogger.write("0) recuperato prodotto x ordine selezionato: idProd4Order --> id_prod: "&idProd4Order&"; typename(objProdToChangeQta): "&typename(objProdToChangeQta)&"; QtaDisp: "&objProdToChangeQta.getQtaDisp(), "system", "debug")
			'call objLogger.write("0A) (objProdToChangeQta.getQtaDisp() = Application(unlimited_key)): "&(objProdToChangeQta.getQtaDisp() = Application("unlimited_key")), "system", "debug")
			'call objLogger.write("0B) objTmpListaProdBeforeChange.Exists(idProd4Order|field4prodCounter): "&objTmpListaProdBeforeChange.Exists(idProd4Order&"|"&field4prodCounter), "system", "debug")
			'call objLogger.write("0C) hasListaProdBeforeChange: " & hasListaProdBeforeChange, "system", "debug")

			'creo una mappa con la sequenza di fieldXOrder da aggiornare				
			Set objDictField4ProdUpdateQta = Server.CreateObject("Scripting.Dictionary")	

			'******* INIZIALIZZO I PRIMI FIELD STABILI PER L'OGGETTO objOPVO
			objOPVO.idProd4Order = idProd4Order
			objOPVO.hasField4prod = hasField4prod
			objOPVO.qtaProd4Order = qtaProd4Order
			objOPVO.field4prodCounter = field4prodCounter
			Set objOPVO.objDictField4Prod = objDictField4Prod
			Set objOPVO.objProdToChangeQta = objProdToChangeQta

				
			if(not(objProdToChangeQta.getQtaDisp() = Application("unlimited_key"))) then			
			
				if (hasListaProdBeforeChange) then
					if(objTmpListaProdBeforeChange.Exists(idProd4Order&"|"&field4prodCounter)) then	
					
						'******* QUESTO IF CONTROLLA LE QUANTITA' PER I FIELD PER PRODOTTO PER ORDINE: DA VERIFICARE CON ATTENZIONE
						if(hasField4prod)then
							tmpf4pCounter = 1

							'call objLogger.write(" aggiorno ordine esistente con lista prodotti e prodotto gi� inserito - check su field prodotto ", "system", "debug")
							
							for each k in objDictField4Prod
								tmpField4ProdQta_ = 0
								
								if(strComp(typename(objProdField.findFieldXOrder(field4prodCounter,id_ordine,idProd4Order,k)), "ProductFieldClass") = 0)then
									Set objTmpP4O_ = objProdField.findFieldXOrder(field4prodCounter,id_ordine,idProd4Order,k)
									tmpField4ProdQta_ = objTmpP4O_.getQtaProd()								
									Set objTmpP4O_ = nothing
								end if
								
								qtaP4OToChange_ = 0		
								
								if(tmpField4ProdQta_ < CLng(qtaProd4Order)) then
									qtaP4OToChange_ = CLng(qtaProd4Order) - tmpField4ProdQta_
								elseif(tmpField4ProdQta_ > CLng(qtaProd4Order)) then
									qtaP4OToChange_ = -tmpField4ProdQta_ + CLng(qtaProd4Order)
								end if
						
								'call objLogger.write("k: "&k&"; idProd4Order: "&idProd4Order&"; objDictField4Prod(k): "&objDictField4Prod(k)&"; tmpField4ProdQta_: "&tmpField4ProdQta_&"; qtaProd4Order: "&qtaProd4Order&"; qtaP4OToChange_: "&qtaP4OToChange_&" - qtaP4OToChange_ <> 0:"& (qtaP4OToChange_ <> 0), "system", "debug")
						
								if(qtaP4OToChange_ <> 0) then
									numOldField4ProdQta_ = objProdField.findFieldValueMatch(k, idProd4Order, objDictField4Prod(k))
									if(numOldField4ProdQta_ <> "" AND not(isNull(numOldField4ProdQta_)))then
									
										if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
											objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), numOldField4ProdQta_
										end if
									
										'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k) e aggiungo il controllo sulla quantità totale
										qtaP4OToChangeTmp_ = qtaP4OToChange_
										'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 0A: " & qtaP4OToChangeTmp_, "system", "debug")
										'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 0A: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")
										if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
											qtaP4OToChangeTmp_ = CLng(qtaP4OToChange_) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))
											call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k))
										end if	
										'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 0B: " & qtaP4OToChangeTmp_, "system", "debug")									
										if(CLng(numOldField4ProdQta_) - CLng(qtaP4OToChangeTmp_) < 0) then
											objConn.RollBackTrans
											response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
										end if
										'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)
										objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), CLng(qtaP4OToChangeTmp_)	
										'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 0B: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")								

										'********* effettuo controllo sui campi correlati per verificare se la disponibilit� � corretta
										On Error Resume Next
										hasListfieldVal = false
										Set listFieldRelVal = objProdField.findListFieldRelValueMatch(idProd4Order, k, objDictField4Prod(k))
										if(listFieldRelVal.count>0)then
											hasListfieldVal = true
										end if
										if(err.number<>0)then
										hasListfieldVal = false
										end if
									
										if(hasListfieldVal)then
											bolHasRelFieldCombination = false
											On Error Resume Next
											for each t in objDictField4Prod
												if((t&objDictField4Prod(t))<>(k&objDictField4Prod(k)))then
													if(listFieldRelVal.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
														qtaFieldRel = listFieldRelVal(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))("qta_rel")	
														
														if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
															objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), qtaFieldRel
														end if
														
														'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t) e aggiungo il controllo sulla quantità totale
														qtaP4OToChangeTmp_ = qtaP4OToChange_
														if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
															qtaP4OToChangeTmp_ = CLng(qtaP4OToChange_) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))
															call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))
														end if														
														if((CLng(qtaFieldRel) - CLng(qtaP4OToChangeTmp_) < 0)) then		
															objConn.RollBackTrans	
															response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")
														end if
														'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t)
														objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), CLng(qtaP4OToChangeTmp_)
														bolHasRelFieldCombination = true														
														Exit for
													'else
														'objConn.RollBackTrans	
														'response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")														
													end if
												end if
											next
											if not(bolHasRelFieldCombination) then
												objConn.RollBackTrans
												response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
											end if
	
											Set listFieldRelVal = nothing
											if(err.number<>0)then
												call objLogger.write("process ordine 2 (listFieldRelVal) err.description: " & err.description, "system", "error")
											end if
										end if
										
										Set objDictField4ProdUpdateObj = Server.CreateObject("Scripting.Dictionary")	
										objDictField4ProdUpdateObj.add "idf4p",k
										objDictField4ProdUpdateObj.add "idp4o",idProd4Order
										objDictField4ProdUpdateObj.add "valf4p",objDictField4Prod(k)
										objDictField4ProdUpdateObj.add "qtach",qtaP4OToChange_
										objDictField4ProdUpdateObj.add "qtaold",numOldField4ProdQta_
										
										objDictField4ProdUpdateQta.add tmpf4pCounter,objDictField4ProdUpdateObj
										Set objDictField4ProdUpdateObj = nothing
									end if
								end if
								tmpf4pCounter = tmpf4pCounter +1
							next
						end if					
				
						'call objLogger.write("1) esiste gi� il prodotto x ordine selezionato: idProd4Order --> id_prod: "&idProd4Order, "system", "debug")
						Dim objTmpP_, tmpQta_, qtaToChange_
						Set objTmpP_ = objTmpListaProdBeforeChange(idProd4Order&"|"&field4prodCounter)
						'call objLogger.write("2) recuperato prodotto x ordine selezionato gi� esistente: objTmpP_: "&typename(objTmpP_), "system", "debug")
						tmpQta_ = CLng(objTmpP_.getQtaProdotto())
						'call objLogger.write("3) vecchia quantità del prodotto x ordine selezionato già esistente: tmpQta_: "&tmpQta_, "system", "debug")
						Set objTmpP_ = nothing
						qtaToChange_ = 0
						'call objLogger.write("4) nuova quantità del prodotto x ordine impostata: qtaProd4Order --> new qta: "&qtaProd4Order, "system", "debug")
						if(tmpQta_ < CLng(qtaProd4Order)) then
							qtaToChange_ = CLng(qtaProd4Order) - tmpQta_
						elseif(tmpQta_ > CLng(qtaProd4Order)) then
							qtaToChange_ = -tmpQta_ + CLng(qtaProd4Order)
						end if
						'call objLogger.write("5) quantità da mofificare sul DB: qtaToChange_: "&qtaToChange_&" - qtaToChange_ <> 0:"& (qtaToChange_ <> 0) &" - updateqta4prod before: "&updateqta4prod, "system", "debug")

						if(qtaToChange_ <> 0) then						
							numOldQta_ = CLng(objProdToChangeQta.getQtaDisp())

							'********* verifico se esiste già nella lista ordine la combinazione idProd4Order e aggiungo il controllo sulla quantità totale
							qtaToChangeTmp_ = qtaToChange_
							if(objDictListOrderProdAvailability.exists(idProd4Order))then
								qtaToChangeTmp_ = CLng(qtaToChangeTmp_) + CLng(objDictListOrderProdAvailability(idProd4Order))
								call objDictListOrderProdAvailability.remove(idProd4Order)
							end if

							if(CLng(numOldQta_) - CLng(qtaToChangeTmp_) < 0) then
								objConn.RollBackTrans
								response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&"&order_modified="&order_modified&"&resetMenu=1")
							end if
					
							'********* aggiorno la quantità totale per la combinazione: idProd4Order
							objDictListOrderProdAvailability.add idProd4Order, qtaToChangeTmp_
					
							'*** imposto le variabili necessarie per fare update del prodotto, field e field correlati
							updateqta4prod = true
							finalQta2change = qtaToChange_
							finalOldQta2change = numOldQta_

							'*** imposto le variabili ottenute nell'oggetto objOPVO per il ciclo for successivo
							objOPVO.updateqta4prod = updateqta4prod
							objOPVO.finalQta2change = finalQta2change
							objOPVO.finalOldQta2change = finalOldQta2change

							'call objLogger.write("6) qtaToChange_: "&qtaToChange_&" - updateqta4prod:"&updateqta4prod&" - finalQta2change: "&finalQta2change&" - finalOldQta2change: "&finalOldQta2change, "system", "debug")	
						end if
					else
					
						'*** se il prodotto ha dei campi associati controllo il loro valore e la quantit� disponibile, 
						'*** se la quantit� selezionata supera quella disponibile rimando indietro con l'errore
						'call objLogger.write("hasField4prod: " & hasField4prod, "system", "debug")	
						if(hasField4prod)then
							tmpf4pCounter = 1

							'call objLogger.write(" aggiorno ordine esistente con lista prodotti e prodotto non inserito - check su field prodotto ", "system", "debug")
						
							'call objLogger.write("objDictField4Prod.count: " & objDictField4Prod.count, "system", "debug")	
							for each k in objDictField4Prod
								numOldField4ProdQta_ = objProdField.findFieldValueMatch(k, idProd4Order, objDictField4Prod(k))
								'call objLogger.write("numOldField4ProdQta_: " & numOldField4ProdQta_, "system", "debug")	
								if(numOldField4ProdQta_ <> "" AND not(isNull(numOldField4ProdQta_)))then	
									
									if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
										objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), numOldField4ProdQta_
									end if
										
									'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k) e aggiungo il controllo sulla quantità totale
									qtaP4OToChangeTmp_ = qtaProd4Order
									'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 1A: " & qtaP4OToChangeTmp_, "system", "debug")
									'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 1A: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")
									if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
										qtaP4OToChangeTmp_ = CLng(qtaProd4Order) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))
										call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k))
									end if
									'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 1B: " & qtaP4OToChangeTmp_, "system", "debug")	
									if(qtaP4OToChangeTmp_ <> 0 AND (CLng(numOldField4ProdQta_) - CLng(qtaP4OToChangeTmp_) < 0)) then
										objConn.RollBackTrans
										response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
									end if
									'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)
									objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), CLng(qtaP4OToChangeTmp_)
									'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 1B: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")	

									'********* effettuo controllo sui campi correlati per verificare se la disponibilit� � corretta
									On Error Resume Next
									hasListfieldVal = false
									Set listFieldRelVal = objProdField.findListFieldRelValueMatch(idProd4Order, k, objDictField4Prod(k))
									if(listFieldRelVal.count>0)then
										hasListfieldVal = true
									end if
									if(err.number<>0)then
									hasListfieldVal = false
									end if
								
									if(hasListfieldVal)then
										bolHasRelFieldCombination = false
										On Error Resume Next
										for each t in objDictField4Prod
											if((t&objDictField4Prod(t))<>(k&objDictField4Prod(k)))then
												if(listFieldRelVal.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
													qtaFieldRel = listFieldRelVal(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))("qta_rel")
														
													if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
														objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), qtaFieldRel
													end if
														
													'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t) e aggiungo il controllo sulla quantità totale
													qtaP4OToChangeTmp_ = qtaProd4Order
													if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
														qtaP4OToChangeTmp_ = CLng(qtaProd4Order) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))
														call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))
													end if
													if((CLng(qtaFieldRel) - CLng(qtaP4OToChangeTmp_) < 0)) then		
														objConn.RollBackTrans	
														response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")
													end if
													'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t)
													objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), CLng(qtaP4OToChangeTmp_)	
													bolHasRelFieldCombination = true
													Exit for
												'else
													'objConn.RollBackTrans	
													'response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")
												end if
											end if
										next
										if not(bolHasRelFieldCombination) then
											objConn.RollBackTrans
											response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
										end if

										Set listFieldRelVal = nothing
										if(err.number<>0)then
										call objLogger.write("process ordine 2 (listFieldRelVal) err.description: " & err.description, "system", "debug")
										end if
									end if
									
									Set objDictField4ProdUpdateObj = Server.CreateObject("Scripting.Dictionary")	
									objDictField4ProdUpdateObj.add "idf4p",k
									objDictField4ProdUpdateObj.add "idp4o",idProd4Order
									objDictField4ProdUpdateObj.add "valf4p",objDictField4Prod(k)
									objDictField4ProdUpdateObj.add "qtach",qtaProd4Order
									objDictField4ProdUpdateObj.add "qtaold",numOldField4ProdQta_
									
									objDictField4ProdUpdateQta.add tmpf4pCounter,objDictField4ProdUpdateObj
									Set objDictField4ProdUpdateObj = nothing
								end if
								tmpf4pCounter = tmpf4pCounter +1
							next
						end if
					
						'call objLogger.write("1C) NOT objTmpListaProdBeforeChange.Exists(idProd4Order&"|"&field4prodCounter)", "system", "debug")
						
						numOldQta_ = CLng(objProdToChangeQta.getQtaDisp())						
						'call objLogger.write("2C) numOldQta_: "&numOldQta_, "system", "debug")

						'********* verifico se esiste già nella lista ordine la combinazione idProd4Order e aggiungo il controllo sulla quantità totale
						qtaToChangeTmp_ = qtaProd4Order
						if(objDictListOrderProdAvailability.exists(idProd4Order))then
							qtaToChangeTmp_ = CLng(qtaToChangeTmp_) + CLng(objDictListOrderProdAvailability(idProd4Order))
							call objDictListOrderProdAvailability.remove(idProd4Order)
						end if
							
						if(qtaToChangeTmp_ <> 0 AND (CLng(numOldQta_) - CLng(qtaToChangeTmp_) < 0)) then
							objConn.RollBackTrans
							response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&"&order_modified="&order_modified&"&resetMenu=1")	
						end if
					
						'********* aggiorno la quantità totale per la combinazione: idProd4Order
						objDictListOrderProdAvailability.add idProd4Order, qtaToChangeTmp_
							
						'*** imposto le variabili necessarie per fare update del prodotto, field e field correlati
						updateqta4prod = true
						finalQta2change = qtaProd4Order
						finalOldQta2change = numOldQta_			

						'*** imposto le variabili ottenute nell'oggetto objOPVO per il ciclo for successivo
						objOPVO.updateqta4prod = updateqta4prod
						objOPVO.finalQta2change = finalQta2change
						objOPVO.finalOldQta2change = finalOldQta2change		
					end if
				else					
					'*** se il prodotto ha dei campi associati controllo il loro valore e la quantit� disponibile, 
					'*** se la quantit� selezionata supera quella disponibile rimando indietro con l'errore
					'call objLogger.write("0) hasField4prod: " & hasField4prod, "system", "debug")	
					if(hasField4prod)then
						tmpf4pCounter = 1

						'call objLogger.write(" aggiorno ordine nuovo - check su field prodotto ", "system", "debug")
					
						'call objLogger.write("1) objDictField4Prod.count: " & objDictField4Prod.count, "system", "debug")	
						for each k in objDictField4Prod
							numOldField4ProdQta_ = objProdField.findFieldValueMatch(k, idProd4Order, objDictField4Prod(k))
							'call objLogger.write("2) qtaProd4Order: " & qtaProd4Order, "system", "debug")	
							'call objLogger.write("2) numOldField4ProdQta_: " & numOldField4ProdQta_, "system", "debug")	
							'call objLogger.write("2) sub: " & (CLng(numOldField4ProdQta_) - CLng(qtaProd4Order)), "system", "debug")	
							
							if(numOldField4ProdQta_ <> "" AND not(isNull(numOldField4ProdQta_)))then	
									
								if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
									objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), numOldField4ProdQta_
								end if
									
								'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k) e aggiungo il controllo sulla quantità totale
								qtaP4OToChangeTmp_ = qtaProd4Order
								'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 2A: " & qtaP4OToChangeTmp_, "system", "debug")
								'call objLogger.write("process ordine 2 key 2A: " & idProd4Order&"|"&k&"|"&objDictField4Prod(k), "system", "debug")
								'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 2A: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")
								if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))then
									qtaP4OToChangeTmp_ = CLng(qtaProd4Order) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)))
									call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k))
								end if
								'call objLogger.write("process ordine 2 qtaP4OToChangeTmp_ 2B: " & qtaP4OToChangeTmp_, "system", "debug")	
								if(qtaP4OToChangeTmp_ <> 0 AND (CLng(numOldField4ProdQta_) - CLng(qtaP4OToChangeTmp_) < 0)) then
									objConn.RollBackTrans
									response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
								end if
								'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)
								objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k), qtaP4OToChangeTmp_
								'call objLogger.write("process ordine 2 objDictListOrderProdAvailability 2B: " & objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)), "system", "debug")
								'call objLogger.write("process ordine 2 objDictListOrderProdAvailability.Count 2B: " & objDictListOrderProdAvailability.Count, "system", "debug")

								'********* effettuo controllo sui campi correlati per verificare se la disponibilit� � corretta
								On Error Resume Next
								hasListfieldVal = false
								Set listFieldRelVal = objProdField.findListFieldRelValueMatch(idProd4Order, k, objDictField4Prod(k))
								if(listFieldRelVal.count>0)then
									hasListfieldVal = true
								end if
								if(err.number<>0)then
								hasListfieldVal = false
								end if
							
								if(hasListfieldVal)then
									bolHasRelFieldCombination = false
									On Error Resume Next
									for each t in objDictField4Prod
										if((t&objDictField4Prod(t))<>(k&objDictField4Prod(k)))then
											'call objLogger.write(objDictField4Prod(k)&" a) diversi: " & t&objDictField4Prod(t)&"<>"&k&objDictField4Prod(k), "system", "debug")
											if(listFieldRelVal.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
												'call objLogger.write(objDictField4Prod(k)&" b) esiste: " & listFieldRelVal.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))&" - check su chiave: " & (idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)), "system", "debug")
												'call objLogger.write(objDictField4Prod(k)&" typename: " & typename(objFieldRelValTmp), "system", "debug")
												qtaFieldRel = listFieldRelVal(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))("qta_rel")
														
												if not(objListOldQta4Prod.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
													objListOldQta4Prod.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), qtaFieldRel
												end if
													
												'call objLogger.write(objDictField4Prod(k)&" c) qtaFieldRel: " & qtaFieldRel&" - qtaProd4Order: " & qtaProd4Order, "system", "debug")	
												'call objLogger.write(objDictField4Prod(k)&" d) diff: " & (CLng(qtaFieldRel) - CLng(qtaProd4Order)), "system", "debug")
												'********* verifico se esiste già nella lista ordine la combinazione idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t) e aggiungo il controllo sulla quantità totale
												qtaP4OToChangeTmp_ = qtaProd4Order
												if(objDictListOrderProdAvailability.exists(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))then
													qtaP4OToChangeTmp_ = CLng(qtaProd4Order) + CLng(objDictListOrderProdAvailability(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t)))
													call objDictListOrderProdAvailability.remove(idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t))
												end if
												if(CLng(qtaFieldRel) - CLng(qtaP4OToChangeTmp_) < 0) then		
													objConn.RollBackTrans	
													response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")
												end if
												'********* aggiorno la quantità totale per la combinazione: idProd4Order|k|objDictField4Prod(k)|t|objDictField4Prod(t)
												objDictListOrderProdAvailability.add idProd4Order&"|"&k&"|"&objDictField4Prod(k)&"|"&t&"|"&objDictField4Prod(t), CLng(qtaP4OToChangeTmp_)	
												bolHasRelFieldCombination = true
												Exit for
											'else
												'objConn.RollBackTrans	
												'response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&Server.URLEncode("<br/>"&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&" - "&objDictField4Prod(t))&"&order_modified="&order_modified&"&resetMenu=1")											
											end if
										end if
									next
									if not(bolHasRelFieldCombination) then
										objConn.RollBackTrans
										response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&": "&objDictField4Prod(k)&"&order_modified="&order_modified&"&resetMenu=1")	
									end if

									Set listFieldRelVal = nothing
									if(err.number<>0)then
									call objLogger.write("process ordine 2 (listFieldRelVal) err.description: " & err.description, "system", "debug")
									end if
								end if
								
								Set objDictField4ProdUpdateObj = Server.CreateObject("Scripting.Dictionary")	
								objDictField4ProdUpdateObj.add "idf4p",k
								objDictField4ProdUpdateObj.add "idp4o",idProd4Order
								objDictField4ProdUpdateObj.add "valf4p",objDictField4Prod(k)
								objDictField4ProdUpdateObj.add "qtach",qtaProd4Order
								objDictField4ProdUpdateObj.add "qtaold",numOldField4ProdQta_
								
								objDictField4ProdUpdateQta.add tmpf4pCounter,objDictField4ProdUpdateObj
								Set objDictField4ProdUpdateObj = nothing
							end if
							'isStillActive = objProdField.changeQtaFieldValueMatch(k, idProd4Order, objDictField4Prod(k), qtaProd4Order, numOldField4ProdQta_, objConn)
							tmpf4pCounter = tmpf4pCounter +1
						next
						'call objLogger.write("3) tmpf4pCounter: " & tmpf4pCounter, "system", "debug")	
					end if					
					
					numOldQta_ = CLng(objProdToChangeQta.getQtaDisp())					
					'call objLogger.write("4) numOldQta_: "&numOldQta_, "system", "debug")	

					'********* verifico se esiste già nella lista ordine la combinazione idProd4Order e aggiungo il controllo sulla quantità totale
					qtaToChangeTmp_ = qtaProd4Order
					if(objDictListOrderProdAvailability.exists(idProd4Order))then
						qtaToChangeTmp_ = CLng(qtaToChangeTmp_) + CLng(objDictListOrderProdAvailability(idProd4Order))
						call objDictListOrderProdAvailability.remove(idProd4Order)
					end if
						
					if(qtaToChangeTmp_ <> 0 AND (CLng(numOldQta_) - CLng(qtaToChangeTmp_) < 0)) then
						objConn.RollBackTrans
						response.Redirect(Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_ordine&"&error=1&nome_prod="&objProdToChangeQta.getNomeProdotto()&"&order_modified="&order_modified&"&resetMenu=1")	
					end if
				
					'********* aggiorno la quantità totale per la combinazione: idProd4Order
					objDictListOrderProdAvailability.add idProd4Order, qtaToChangeTmp_
							
					'*** imposto le variabili necessarie per fare update del prodotto, field e field correlati
					updateqta4prod = true
					finalQta2change = qtaProd4Order
					finalOldQta2change = numOldQta_			

					'*** imposto le variabili ottenute nell'oggetto objOPVO per il ciclo for successivo
					objOPVO.updateqta4prod = updateqta4prod
					objOPVO.finalQta2change = finalQta2change
					objOPVO.finalOldQta2change = finalOldQta2change	

					'call objLogger.write("qtaProd4Order: "&qtaProd4Order&" -finalQta2change: "&finalQta2change&" -objOPVO.finalQta2change: "&objOPVO.finalQta2change, "system", "debug")					
				end if
			end if
			
			'call objLogger.write("7) updateqta4prod:"&updateqta4prod&" - finalQta2change: "&finalQta2change&" - finalOldQta2change: "&finalOldQta2change, "system", "debug")
			Set objOPVO.objDictField4ProdUpdateQta = objDictField4ProdUpdateQta	
			objDictListOrderVO.add y, objOPVO
			Set objOPVO = nothing
		Next

		'call objLogger.write("arrivato prima di inizio creazione business rule - parametri ordine --> id: "&id_ordine&" - id_utente: "&id_utente, "system", "debug")

		'***************************************************************** INIZIO: GESTIONE BUSINESS RULES *****************************************************************
		'********** VERIFICO SE ESISTE UNA CAMPAGNA VOUCHER ATTIVA E SE E' STATO INSERITO UN VOUCHER E IN TAL CASO CERCO UNA RULE DI TIPO VOUCHER
		On Error Resume Next
		Set objOrderRule = objRule.getListaRules("3", 1)
		if(objOrderRule.count>0) then
			hasActiveVoucherCampaign = true
		end if
		if(Err.number <> 0) then
			hasActiveVoucherCampaign = false
		end if
		
		'********** VERIFICO SE EISTE GIA' UN VOUCHER ASSOCIATO ALL'ORDINE E IN TAL CASO SE NON E' STATO PASSATO UN NUOVO VOUCHER CODE LO RIAPPLICO ALL'ORDINE CORRENTE
		On Error Resume Next
		Set objOldVoucher = objVoucherClass.findLastVoucherOrderAssociationsByOrder(id_ordine)
		
		if (strComp(typename(objOldVoucher), "VoucherCodeClass") = 0)then
			Set objOldVoucher = objVoucherClass.findExtendedVoucherByCode(objOldVoucher.getVoucherCode())
			if (strComp(typename(objOldVoucher), "VoucherClass") = 0)then
				hasOldActiveVoucher = true
			end if
		end if
		if(Err.number <> 0) then
			hasOldActiveVoucher = false
		end if

		'call objLogger.write("typename(objOldVoucher): "& typename(objOldVoucher)&" -hasOldActiveVoucher: "& hasOldActiveVoucher, "system", "debug")		

		if ((hasActiveVoucherCampaign AND Upload.Form("voucher_code")<>"") OR hasOldActiveVoucher) then
			On Error Resume Next 
			if(Upload.Form("voucher_code")<>"")then
				Set objVoucher=  objVoucherClass.validateVoucherCode(Upload.Form("voucher_code"))
				'call objLogger.write("Upload.Form(voucher_code): "&Upload.Form("voucher_code")&" -typename(objVoucher): "& typename(objVoucher), "system", "debug")	
				if (strComp(typename(objVoucher), "VoucherClass") = 0)then				
					'call objLogger.write("typename(objVoucher): "& typename(objVoucher)&" -isNull(objVoucher): "& isNull(objVoucher), "system", "debug")
					if(hasOldActiveVoucher)then
						'scall objLogger.write("objOldVoucher.getVoucherCode(): "&objOldVoucher.getVoucherCode(), "system", "debug")
						if(Upload.Form("voucher_code")=objOldVoucher.getVoucherCode())then
							Set objVoucher=  objOldVoucher
							hasOldActiveVoucher = true
							voucher_message = langEditor.getTranslated("portal.commons.voucher.message.error_already_associated")
							redirectPage = redirectPage & "&voucher_message="&voucher_message
						end if
					else
						hasOldActiveVoucher = false
					end if
				elseif(not(strComp(typename(objVoucher), "VoucherClass") = 0) AND hasOldActiveVoucher)then
					Set objVoucher=  objOldVoucher
					voucher_message = langEditor.getTranslated("portal.commons.voucher.message.error_invalid")
					redirectPage = redirectPage & "&voucher_message="&voucher_message
				end if
			elseif(hasOldActiveVoucher) then
				Set objVoucher=  objOldVoucher
			end if
			
			if (strComp(typename(objVoucher), "VoucherClass") = 0)then
				hasValidVoucher = true
				if(objVoucher.getExcludeProdRule())then
					bolVoucherExcludeProdRule = true
				end if
			else
				voucher_message = langEditor.getTranslated("portal.commons.voucher.message.error_invalid")
				redirectPage = redirectPage & "&voucher_message="&voucher_message
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
		
		'*** verifico se esiste una rule primo ordine e se l'utente ne possiede i requisiti
		On Error Resume Next
		if not(hasOrderRule) then  
			if(Cint(objOrdine.countUserOrder(id_utente))=0)then
				Set objOrderRule = objRule.getListaRules("4,5", 1)  
				if(objOrderRule.count>0) then
					hasOrderRule = true
				end if
			end if
		end if
		if(Err.number <> 0) then
			hasOrderRule = false
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
		
		'*** ciclo sui prodotti per ordine e costruisco una mappa, con la lista di prodotti abbinati a qta e imponibile da usare per le business rules
		Set objListProd4Rule = Server.CreateObject("Scripting.Dictionary")

		For y=LBound(listOrder) to UBound(listOrder)
			On Error Resume Next
			Set objOrderVO = objDictListOrderVO(y)
			'call objLogger.write("objOrderVO.idProd4Order: "&objOrderVO.idProd4Order&" -typename(objOrderVO.objProdToChangeQta): "&typename(objOrderVO.objProdToChangeQta)&" -finalQta2change: "&objOrderVO.finalQta2change&" -objOrderVO.qtaProd4Order: "&objOrderVO.qtaProd4Order, "system", "debug")			
			
			'tmpFinalQta2change = objOrderVO.qtaProd4Order
			'if(not(objOrderVO.objProdToChangeQta.getQtaDisp() = Application("unlimited_key"))) then
			'	tmpFinalQta2change = objOrderVO.finalQta2change
			'end if
			
			if not(objListProd4Rule.Exists(Clng(objOrderVO.idProd4Order)))then
				Set objTmpPRVO = new ProductRulesVO              
				objTmpPRVO.idProd = objOrderVO.idProd4Order
				objTmpPRVO.counterProd = objOrderVO.field4prodCounter
				Set objTmpPRVO.objProd = objOrderVO.objProdToChangeQta
				objTmpPRVO.totQta = objOrderVO.qtaProd4Order
				objListProd4Rule.add Clng(objOrderVO.idProd4Order), objTmpPRVO
				Set objTmpPRVO=nothing
			else
				tmp_qta = objListProd4Rule(Clng(objOrderVO.idProd4Order)).totQta
				tmp_qta = Cint(tmp_qta)+Cint(objOrderVO.qtaProd4Order)
				objListProd4Rule(Clng(objOrderVO.idProd4Order)).totQta=tmp_qta
			end if  
			Set objOrderVO = nothing			
			if(Err.number <> 0) then
				'response.write(Err.description)
				'call objLogger.write("Err.description: "&Err.description, "system", "debug")	
			end if 
		next
		
		'for each q in objListProd4Rule
		'	call objLogger.write("q: "&q, "system", "debug")			
		'next

		For y=LBound(listOrder) to UBound(listOrder)
			'*** se esistono delle business rules attive sui prodotti correlati cerco le configurazioni specifiche per ogni prodotto e aggiorno l'oggetto objListProd4Rule
			if(bolHasProdRelRule) then
				for each b in objProdRelRule
					On Error Resume Next
					'call objLogger.write("objProdRelRule(b): "&objProdRelRule(b).getLabel()&" -idProd4Order: "&objDictListOrderVO(y).idProd4Order, "system", "debug")
					Set objTmpResStrategy = objProdRelRule(b).getAmountByStrategy(null, null, Clng(objDictListOrderVO(y).idProd4Order), objListProd4Rule)
					Set objListProd4Rule = objTmpResStrategy.objListPRVO
					Set objTmpResStrategy = nothing
					if(Err.number <> 0) then
					end if 
				next
			end if              
		next		
		'***************************************************************** FINE: GESTIONE BUSINESS RULES *****************************************************************

		'for each e in objListProd4Rule
			'call objLogger.write("e: "&e, "system", "debug")			
		'next

		Dim totale_qta_order, objListAllFieldxProd
		totale_qta_order = 0
		'** inizializzo mappa dei field per prodotto selezionati				 
		Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")

		For y=LBound(listOrder) to UBound(listOrder)
			Set objOrderVO = objDictListOrderVO(y)
			idProd4Order = objOrderVO.idProd4Order
			hasField4prod = objOrderVO.hasField4prod
			field4prodCounter = objOrderVO.field4prodCounter
			qtaProd4Order = objOrderVO.qtaProd4Order
			Set objDictField4Prod = objOrderVO.objDictField4Prod
			updateqta4prod = objOrderVO.updateqta4prod
			finalQta2change = objOrderVO.finalQta2change
			finalOldQta2change = objOrderVO.finalOldQta2change
			Set objProdToChangeQta = objOrderVO.objProdToChangeQta
			Set objDictField4ProdUpdateQta = objOrderVO.objDictField4ProdUpdateQta
			prod_type = objProdToChangeQta.getProdType()
			
			if (prod_type=0) then
				'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
				Set objDict = Server.CreateObject("Scripting.Dictionary")
				objListAllFieldxProd.add field4prodCounter&"-"&idProd4Order, objDict
	
				'call objLogger.write("verifico che carichi i field per le spese accessorie", "system", "debug")
				'call objLogger.write("objDictField4ProdUpdateQta.count: "&objDictField4ProdUpdateQta.count, "system", "debug")
				'call objLogger.write("objDictField4Prod.count: "&objDictField4Prod.count, "system", "debug")
				for each x in objDictField4Prod			
					Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
					objDictFieldxProd.add "id", x
					objDictFieldxProd.add "value", objDictField4Prod(x)
					objDictFieldxProd.add "qta", qtaProd4Order
					objListAllFieldxProd(field4prodCounter&"-"&idProd4Order).add objDictFieldxProd, ""
					'call objLogger.write("x id: " & objDictFieldxProd("id"), "system", "debug")
					'call objLogger.write("x value: " & objDictFieldxProd("value"), "system", "debug")
					'call objLogger.write("x qta: " & objDictFieldxProd("qta"), "system", "debug")
					Set objDictFieldxProd = nothing
				next

				'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
				if (Instr(1, typename(objProdField.getListProductField4ProdActive(idProd4Order)), "Dictionary", 1) > 0) then
					Set fieldList4CardH = objProdField.getListProductField4ProdActive(idProd4Order)			
				
					if(fieldList4CardH.count > 0)then	
						for each d in fieldList4CardH
							if((fieldList4CardH(d).getTypeContent()=2 OR fieldList4CardH(d).getTypeContent()=3) AND (fieldList4CardH(d).getEditable()=0))then
								Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
								objDictFieldxProd.add "id", fieldList4CardH(d).getID()
								objDictFieldxProd.add "value", fieldList4CardH(d).getSelValue()
								objDictFieldxProd.add "qta", qtaProd4Order
	
								bolCanAdd = true
								On Error Resume Next
								for each i in objListAllFieldxProd(field4prodCounter&"-"&idProd4Order)
									if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
										bolCanAdd = false
										Exit for
									end if
								next
	
								if(bolCanAdd)then
									objListAllFieldxProd(field4prodCounter&"-"&idProd4Order).add objDictFieldxProd, ""
								end if
								if(Err.number<>0)then
								'response.write("Error: "&Err.description)
								end if
								Set objDictFieldxProd = nothing		
							end if
						next					
					end if
					Set fieldList4CardH = nothing
				end if
				Set objDict = nothing
			end if

			'*** se sono arrivato fino a questo punto cancello il prodotto per ordine corrente per inserirlo dopo i vari calcoli
			call objProdPerOrder.deleteProdottoXOrdProdCount(id_ordine, idProd4Order, field4prodCounter, objConn)

			'*** se l'ordine ha già dei campi associati al prodotto elimino quelli esistenti dal DB
			if(hasField4prod)then
				call objProdField.deleteFieldXOrderByProd(field4prodCounter, id_ordine,idProd4Order, objConn)
			end if

			
			if(qtaProd4Order > 0) then				
				tot_prod_tmp = 0
				tot_tax_tmp = 0 
				
				if(hasGroup) then
					On Error Resume Next
					Dim objSelMargin
					Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
					tot_prod_tmp = CDbl(objProdToChangeQta.getPrezzo()) * CLng(qtaProd4Order)
					tot_prod_tmp = objSelMargin.getAmount(tot_prod_tmp,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objProdToChangeQta.getsconto()),CDbl(scontoCliente))
					if(Err.number <>0) then
					end if	
					Set objSelMargin = nothing
				else
					if(objProdToChangeQta.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then 
						tot_prod_tmp = CDbl(objProdToChangeQta.getPrezzoScontato()) * CLng(qtaProd4Order)
						if(hasSconto)then
							tot_prod_tmp = tot_prod_tmp - (tot_prod_tmp / 100 * scontoCliente)							
						end if
					else
						tot_prod_tmp = CDbl(objProdToChangeQta.getPrezzo()) * CLng(qtaProd4Order)
						if(hasSconto)then
							tot_prod_tmp = tot_prod_tmp - (tot_prod_tmp / 100 * scontoCliente)							
						end if
					end if
				end if

				'*** se esistono delle business rules attive sui prodotti cerco le configurazioni specifiche per ogni prodotto e applico il risultato all'imponibile prodotto
				if(bolHasProdRule) then
					for each b in objProdRule
						On Error Resume Next
						'call objLogger.write("objProdRule(b): "&objProdRule(b).getLabel()&" -idProd4Order: "&idProd4Order, "system", "debug")
						Set objTmpResStrategy = objProdRule(b).getAmountByStrategy(null, null, Clng(idProd4Order), objListProd4Rule)
						'call objLogger.write("objProdRule(b): "&objProdRule(b).getLabel()&" -objTmpResStrategy.foundAmount: "&objTmpResStrategy.foundAmount&" -idProd4Order: "&idProd4Order, "system", "debug")
						found_prule_amount = FormatNumber(objTmpResStrategy.foundAmount, 2,-1)
						Set objListProd4Rule = objTmpResStrategy.objListPRVO
						tot_prod_tmp=tot_prod_tmp+CDbl(found_prule_amount)        
						Set objTmpResStrategy = nothing
						'call objLogger.write("tot_prod_tmp: "&tot_prod_tmp&" -idProd4Order: "&idProd4Order, "system", "debug")
						if(Err.number <> 0) then
						end if 
					next
					
					'for each f in objListProd4Rule
						'call objLogger.write("f: "&f, "system", "debug")			
					'next					
				end if  
				
				if(bolHasProdRelRule) then
					'*** aggiungo il valore calcolato nella business strategy (> 0 solo se e una regola su prodotto correlato)
					tot_prod_tmp=tot_prod_tmp+CDbl(objListProd4Rule(Clng(idProd4Order)).resultAmount)     			
				end if


				'***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
				applyOrigTax = true
				'call objLogger.write("hasGroup: "& hasGroup&"; applyOrigTax: "&applyOrigTax&"; international_country_code: "&international_country_code&"; groupClienteTax: "&typename(groupClienteTax), "system", "debug")		
				if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
					if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
						On Error Resume Next
						' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
						if(Cint(userIsCompanyClient)=1 AND groupClienteTax.isTaxExclusion(groupClienteTax.getID(), international_country_code,international_state_region_code))then
							tot_tax_tmp = 0
							taxDesc = langEditor.getTranslated("backend.prodotti.label.tax_excluded")								
							applyOrigTax = false
						else
							objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
							if(not(isNull(objRelatedTax))) then
								Set objTaxG = objTasse.findTassaByID(objRelatedTax)
								tot_tax_tmp = groupClienteTax.getImportoTassa(tot_prod_tmp, objTaxG)
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
						'call objLogger.write("id_ordine: "&id_ordine&"; tot_tax_tmp: "&tot_tax_tmp&"; taxDesc: "&taxDesc, "system", "debug")		
					else
						On Error Resume Next
						Set groupProdTax = objProdToChangeQta.getTaxGroupObj(objProdToChangeQta.getTaxGroup()) 
						if(Instr(1, typename(groupProdTax), "TaxsGroupClass", 1) > 0) then
							' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
							if(Cint(userIsCompanyClient)=1 AND groupProdTax.isTaxExclusion(groupProdTax.getID(), international_country_code,international_state_region_code))then
								tot_tax_tmp = 0
								taxDesc = langEditor.getTranslated("backend.prodotti.label.tax_excluded")								
								applyOrigTax = false
							else						
								objRelatedTax = groupProdTax.findRelatedTax(groupProdTax.getID(), international_country_code,international_state_region_code)	
								if(not(isNull(objRelatedTax))) then
									Set objTaxG = objTasse.findTassaByID(objRelatedTax)
									tot_tax_tmp = groupProdTax.getImportoTassa(tot_prod_tmp, objTaxG)
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
					tot_tax_tmp = 0
					taxDesc = ""
					if not(isNull(objProdToChangeQta.getIDTassaApplicata())) AND not(objProdToChangeQta.getIDTassaApplicata() = "") then
						tot_tax_tmp = objProdToChangeQta.getImportoTassa(tot_prod_tmp)
						taxDesc = objTasse.findTassaByID(objProdToChangeQta.getIDTassaApplicata()).getDescrizioneTassa()
					end if
				end if
									
				totImptmp = totImptmp + tot_prod_tmp
				totTaxTmp = totTaxTmp + tot_tax_tmp	
								
				'************ se il prodotto non � di tipo scaricabile aggiorno l'imponibile su cui verranno calcolate le spese di spedizione
				if (prod_type=0 AND not(objListProd4Rule(Clng(idProd4Order)).bolExcludeBills)) then
					totImpTmp4bills = totImpTmp4bills + tot_prod_tmp
					totale_qta_order = totale_qta_order+qtaProd4Order
					applyBills = true
				end if

				'call objLogger.write("8) updateqta4prod: " & updateqta4prod&" - idProd4Order: " & idProd4Order&" - finalQta2change: " & finalQta2change&" - finalOldQta2change: " & finalOldQta2change, "system", "debug")
												
				'*** se non ci sono stati errori aggiorno le quantità disponibili per prodotto, field e field correlati
				if(updateqta4prod) then
					numOldQta = objListOldQta4Prod(idProd4Order)				
					isStillActive = objProdTmp.changeQtaProdotto(idProd4Order, finalQta2change, numOldQta, objConn)

					newQta = CLng(numOldQta) - CLng(finalQta2change)
					' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
					'objListOldQta4Prod.remove(idProd4Order)
					'objListOldQta4Prod.add idProd4Order, newQta
					objListOldQta4Prod.Item(idProd4Order) = newQta
					
					'call objLogger.write("aggiornamento changeQtaProdotto per prodotto: "&idProd4Order&" - quantità da modificare: "&finalQta2change&" - vecchia quantità: "&finalOldQta2change &" - isStillActive: "&isStillActive, "system", "debug")

					if(hasField4prod)then
						'aggiorno le quantit� per i singoli field per prodotto
						for each g in objDictField4ProdUpdateQta
							Set objToChange = objDictField4ProdUpdateQta(g)
							isStillActive = objProdField.changeQtaFieldValueMatch(objToChange("idf4p"), objToChange("idp4o"), objToChange("valf4p"), objToChange("qtach"), objToChange("qtaold"), objConn)

							'********* effettuo controllo sui campi correlati per modificare la disponibilit� corretta
							On Error Resume Next
							hasListfieldVal = false
							Set listFieldRelVal = objProdField.findListFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"))
							if(listFieldRelVal.count>0)then
								hasListfieldVal = true
							end if
							if(err.number<>0)then
							hasListfieldVal = false
							end if
						
							if(hasListfieldVal)then
								On Error Resume Next	
								for each t in objDictField4ProdUpdateQta
									Set tmpF4OR = objDictField4ProdUpdateQta(t)
									if((tmpF4OR("idf4p")&tmpF4OR("valf4p"))<>(objToChange("idf4p")&objToChange("valf4p")))then
										if(listFieldRelVal.exists(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p")))then
											qtaFieldRel = listFieldRelVal(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p"))("qta_rel")
											'TODO: decidere se inviare la mail di esaurimento anche per i singoli field correlati
											isStillActive = objProdField.changeQtaFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"), tmpF4OR("idf4p"), tmpF4OR("valf4p"), CLng(finalQta2change), CLng(qtaFieldRel), objConn)
											'call objLogger.write("aggiornamento changeQtaFieldRelValueMatch per prodotto: "&objToChange("idp4o")&" - field: "&objToChange("idf4p")&" - val field: "&objToChange("valf4p")&" - refer field: "&tmpF4OR("idf4p")&" - refer value: "&tmpF4OR("valf4p")&" - quantità da modificare: "&finalQta2change&" - vecchia quantità: "&qtaFieldRel &" - isStillActive: "&isStillActive, "system", "debug")
										end if
									end if
									Set tmpF4OR = nothing
								next

								Set listFieldRelVal = nothing
								if(err.number<>0)then
								call objLogger.write("process ordine 2 (listFieldRelVal) err.description: " & err.description, "system", "debug")
								end if
							end if

							Set objToChange = nothing
						next
					end if
				end if
				
				'*** se il prodotto hai dei campi associati li inserisco sul DB
				if(hasField4prod)then
					Set objFSO = Server.CreateObject("Scripting.FileSystemObject")							
					uploadsDirVar = Application("dir_upload_prod")&"fields/"
					uploadsDirVarVal = uploadsDirVar
					uploadsDirVarVal = uploadsDirVarVal & idProd4Order &"/"&id_utente&"/"
					uploadsDirVar = Server.MapPath(uploadsDirVar)
					uploadsDirVar = uploadsDirVar & "\" & idProd4Order &"\"
					'call objLogger.write("uploadsDirVar: "&uploadsDirVar, "system", "debug")
					'call objLogger.write("uploadsDirVarVal: "&uploadsDirVarVal, "system", "debug")
					'call objLogger.write("typename(objFSO): "&typename(objFSO), "system", "debug")
					'call objLogger.write("objFSO.FolderExists(uploadsDirVar): "& objFSO.FolderExists(uploadsDirVar), "system", "debug")
					on Error Resume Next
					if not(objFSO.FolderExists(uploadsDirVar)) then
						call objFSO.CreateFolder(uploadsDirVar)
						if not(objFSO.FolderExists(uploadsDirVar & id_utente &"\")) then
							call objFSO.CreateFolder(uploadsDirVar & id_utente &"\")
						end if
						'call objLogger.write("f.Path: "&f.Path, "system", "debug")
					end if
					if not(objFSO.FolderExists(uploadsDirVar & id_utente &"\")) then
						call objFSO.CreateFolder(uploadsDirVar & id_utente &"\")
					end if
					if(Err.number<>0)then
					call objLogger.write("Err.description: "&Err.description, "system", "debug")
					end if	
					uploadsDirVar = uploadsDirVar & id_utente &"\"
					Set objFSO = nothing
					call Upload.Save(uploadsDirVar)
				
					for each k in objDictField4Prod
						call objProdField.insertFieldXOrder(field4prodCounter, id_ordine, idProd4Order, k, qtaProd4Order, objDictField4Prod(k), objConn)
					next
				end if
				
				nome_prod_tmp = objProdToChangeQta.getNomeProdotto()
				call objProdPerOrder.insertProdottiXOrdine(id_ordine, idProd4Order, field4prodCounter, nome_prod_tmp, qtaProd4Order, tot_prod_tmp, tot_tax_tmp, taxDesc, prod_type, objConn)
				'call objLogger.write("id_ordine: "&id_ordine&"; idProd4Order: "&idProd4Order&"; field4prodCounter: "&field4prodCounter&"; nome_prod_tmp: "&nome_prod_tmp&"; qtaProd4Order: "&qtaProd4Order&"; tot_prod_tmp: "&tot_prod_tmp&"; tot_tax_tmp: "&tot_tax_tmp&"; taxDesc: "&taxDesc&"; prod_type: "&prod_type, "system", "debug")	
			else
				'call objLogger.write("9) updateqta4prod: " & updateqta4prod&" - idProd4Order: " & idProd4Order&" - finalQta2change: " & finalQta2change&" - finalOldQta2change: " & finalOldQta2change, "system", "debug")
												
				'*** se non ci sono stati errori aggiorno le quantità disponibili per prodotto, field e field correlati
				if(updateqta4prod) then
					numOldQta = objListOldQta4Prod(idProd4Order)							
					isStillActive = objProdTmp.changeQtaProdotto(idProd4Order, finalQta2change, numOldQta, objConn)

					newQta = CLng(numOldQta) - CLng(finalQta2change)
					' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
					'objListOldQta4Prod.remove(idProd4Order)
					'objListOldQta4Prod.add idProd4Order, newQta
					objListOldQta4Prod.Item(idProd4Order) = newQta
					
					'call objLogger.write("10) aggiornamento changeQtaProdotto per prodotto: "&idProd4Order&" - quantità da modificare: "&finalQta2change&" - vecchia quantità: "&finalOldQta2change &" - isStillActive: "&isStillActive, "system", "debug")

					if(hasField4prod)then
						'aggiorno le quantit� per i singoli field per prodotto
						for each g in objDictField4ProdUpdateQta
							Set objToChange = objDictField4ProdUpdateQta(g)
							isStillActive = objProdField.changeQtaFieldValueMatch(objToChange("idf4p"), objToChange("idp4o"), objToChange("valf4p"), objToChange("qtach"), objToChange("qtaold"), objConn)

							'********* effettuo controllo sui campi correlati per modificare la disponibilit� corretta
							On Error Resume Next
							hasListfieldVal = false
							Set listFieldRelVal = objProdField.findListFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"))
							if(listFieldRelVal.count>0)then
								hasListfieldVal = true
							end if
							if(err.number<>0)then
							hasListfieldVal = false
							end if
						
							if(hasListfieldVal)then
								On Error Resume Next	
								for each t in objDictField4ProdUpdateQta
									Set tmpF4OR = objDictField4ProdUpdateQta(t)
									if((tmpF4OR("idf4p")&tmpF4OR("valf4p"))<>(objToChange("idf4p")&objToChange("valf4p")))then
										if(listFieldRelVal.exists(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p")))then
											qtaFieldRel = listFieldRelVal(objToChange("idp4o")&"|"&objToChange("idf4p")&"|"&objToChange("valf4p")&"|"&tmpF4OR("idf4p")&"|"&tmpF4OR("valf4p"))("qta_rel")
											'TODO: decidere se inviare la mail di esaurimento anche per i singoli field correlati
											isStillActive = objProdField.changeQtaFieldRelValueMatch(objToChange("idp4o"), objToChange("idf4p"), objToChange("valf4p"), tmpF4OR("idf4p"), tmpF4OR("valf4p"), CLng(finalQta2change), CLng(qtaFieldRel), objConn)
											'call objLogger.write("aggiornamento changeQtaFieldRelValueMatch per prodotto: "&objToChange("idp4o")&" - field: "&objToChange("idf4p")&" - val field: "&objToChange("valf4p")&" - refer field: "&tmpF4OR("idf4p")&" - refer value: "&tmpF4OR("valf4p")&" - quantità da modificare: "&finalQta2change&" - vecchia quantità: "&qtaFieldRel &" - isStillActive: "&isStillActive, "system", "debug")
										end if
									end if
									Set tmpF4OR = nothing
								next

								Set listFieldRelVal = nothing
								if(err.number<>0)then
								call objLogger.write("process ordine 2 (listFieldRelVal) err.description: " & err.description, "system", "debug")
								end if
							end if

							Set objToChange = nothing
						next
					end if
				end if				
			end if
				
			Set objOrderVO = nothing
			Set objDictField4ProdUpdateQta = nothing				
			Set objDictField4Prod = nothing
			Set objProdToChangeQta = nothing
		Next

		'*** inserisco eventuali rule per prodotto
		if not(bolRulesAlreadyDeleted)then
			call objRule.deleteRuleOrderByOrderID(id_ordine, objConn)
			bolRulesAlreadyDeleted=true
		end if
		for each l in objListProd4Rule
			'call objLogger.write("ordine --> id: "&id_ordine&" - idProd4Order: "& l& " -count: "&objListProd4Rule(l).listRelrulesLabel.count, "system", "debug")
			'*** inserisco eventuali rule per prodotto
			if (objListProd4Rule(l).listRelrulesLabel.count>0) then
				'call objLogger.write("entro in if per rules", "system", "debug")
				for each w in objListProd4Rule(l).listRelrulesLabel
					tmpIdRule = Left(w,InStr(1,w,"-",1)-1)
					tmpLabel = Mid(w,InStr(1,w,"|",1)+1)                  
					tmp_amount_rule = objListProd4Rule(l).listRelrulesLabel(w)
					'call objLogger.write("processordine2 --> id ordine:"&id_ordine&" -idProd4Order:"&l&" -tmpIdRule:"&tmpIdRule&" -tmpLabel:"&tmpLabel&" -tmp_amount_rule:"&tmp_amount_rule, "system", "debug")
					call objRule.insertRuleOrder(tmpIdRule, id_ordine, l, objListProd4Rule(l).counterProd, tmpLabel, tmp_amount_rule, objConn)
				next
			end if
		next		
		
		Set objListOldQta4Prod = nothing
		Set objDictListOrderProdAvailability = nothing
		Set objDictListOrderVO = nothing
		'******** END ELABORAZIONE PRODOTTI PER ORDINE

				
		'******** A QUESTO PUNTO VANNO RICALCOLATI I TOTALI
		'******** CON SCONTI, SPESE E TASSE
		'******** IN BASE AI NUOVI PRODOTTI SELEZIONATI
		'******** PER MANTENERE L'ORDINE COERENTE CON LE MODIFICHE
		
		totale_imp_ord = totImptmp
		totale_tasse_ord = totTaxTmp


		'*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
		totale_ord_rules = 0
		if(hasOrderRule) then
			Set objDictRules = Server.CreateObject("Scripting.Dictionary")
			Set objDictVoucherUsed = Server.CreateObject("Scripting.Dictionary")
			
			totale_ord_old = totale_imp_ord+totale_tasse_ord
			for each l in objOrderRule
				found_amount = objOrderRule(l).getAmountByStrategy(totale_ord_old, objVoucher,null,null).foundAmount
					
				'*** verifico se è stato usato un voucher e aggiungo il voucher a quelli da aggiornare su DB per l'ordine corrente
				if(Cint(objOrderRule(l).getRuleType)=3 AND not(hasOldActiveVoucher))then
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
					totale_ord_rules=totale_ord_rules+CDbl(found_amount)

					Set objRuleTmp = new OrderRulesVO
					objRuleTmp.idRule = objOrderRule(l).getID()
					objRuleTmp.label = objOrderRule(l).getLabel()
					objRuleTmp.amount = found_amount
					objDictRules.add objOrderRule(l).getID(), objRuleTmp
					Set objRuleTmp = nothing
				end if
			next
		end if
		totale_ord_rules = FormatNumber(totale_ord_rules,2,-1,-2,0)
		

		'******** AGGIUNGO TUTTE LE SPESE ACCESSORIE
		Dim objSpesa, objListaSpese, objSpesaTmp, objSpeseXOrdine, objListaSpeseXOrdine, hasBill4Order
		Set objSpesa = new BillsClass
		Set objSpeseXOrdine = new Bills4OrderClass
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
			'objListaSpeseXOrdine = null
			hasBill4Order = false
		end if
		
		'call objLogger.write("ordine --> id: "&id_ordine&" - hasBill4Order: "& hasBill4Order, objUserLogged.getUserName(), "debug")

		
		if(applyBills) then
			if not(isNull(objListaSpese)) then
				'if(hasBill4Order) then
					'call objSpeseXOrdine.deleteSpeseXOrdine(id_ordine, objConn)
				'end if
				
				Dim objTassa, totSpeseImp, totSpeseTax, totSpese
				Dim totaleImpTmp, totaleTaxTmp
				totaleImpTmp = 0
				totaleTaxTmp = 0					
				
				for each k in objListaSpese
					totSpeseImp = 0
					totSpeseTax = 0
					Set objSpesaTmp = objListaSpese(k)

					'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
					totSpeseImp = objSpesaTmp.getImpByStrategy(totImpTmp4bills, totale_qta_order, objListAllFieldxProd)	

					' verifico se si tratta di valore fisso o percentuale
					'if(CInt(objSpesaTmp.getTipoValore()) = 2) then
						'totSpeseImp = CDbl(totImpTmp4bills) / 100 * CDbl(objSpesaTmp.getValore())				
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

					
					if(objSpesaTmp.getAutoactive()=1)then
						call objSpeseXOrdine.deleteSpesaXOrdine(id_ordine, objSpesaTmp.getSpeseID(), objConn)
						call objSpeseXOrdine.insertSpeseXOrdine(id_ordine, objSpesaTmp.getSpeseID(), totSpeseImp, totSpeseTax, (totSpeseImp+totSpeseTax), objSpesaTmp.getDescrizioneSpesa(), objConn)
					
						totaleImpTmp = totaleImpTmp+totSpeseImp					
						totaleTaxTmp = totaleTaxTmp+totSpeseTax
					else
						if(hasBill4Order)then
							if(objListaSpeseXOrdine.Exists(k))then
								call objSpeseXOrdine.modifySpeseXOrdine(id_ordine, objSpesaTmp.getSpeseID(), totSpeseImp, totSpeseTax, (totSpeseImp+totSpeseTax), objSpesaTmp.getDescrizioneSpesa(), objConn)		
				
								totaleImpTmp = totaleImpTmp+totSpeseImp					
								totaleTaxTmp = totaleTaxTmp+totSpeseTax							
							end if
						end if
					end if					
					
					Set objSpesaTmp = nothing
				next
				Set objListAllFieldxProd = nothing
				totale_imp_ord = totale_imp_ord+totaleImpTmp	
				totale_tasse_ord = totale_tasse_ord+totaleTaxTmp
			end if
		end if
			
		totale_ord = totale_imp_ord+totale_tasse_ord

		'call objLogger.write("process ordine 2 totale_imp_ord: "&totale_imp_ord&" - totale_tasse_ord: "&totale_tasse_ord&" - totale_ord_rules: "&totale_ord_rules&" - totale_ord: "&totale_ord, "system", "debug")
		
		Set objTasse = nothing			
		Set objSpeseXOrdine = nothing
		Set objListaSpeseXOrdine = nothing
		Set objListaSpese = nothing
		Set objSpesa = nothing	
	end if
	
	'*** aggiorno il totale ordine con le commissioni di pagamento e l'eventuale totale per le business rules, per gestire il caso di un ordine gi� esistente
	totale_ord = CDbl(totale_ord)+CDbl(payment_commission)+CDbl(totale_ord_rules)
	'*** imposto a due il numero di decimali
	totale_ord = FormatNumber(totale_ord,2,-1,-2,0)
	
	'call objLogger.write("parametri ordine --> id: "&id_ordine&" - id_utente: "&id_utente&" - dta_ins: "&dta_ins&" - stato_order: "&stato_order&" - totale_imp_ord: "&totale_imp_ord&" - totale_tasse_ord: "&totale_tasse_ord&" - totale_ord: "&totale_ord&" - tipo_pagam: "&tipo_pagam&" - pagam_done: "&pagam_done&" - user_notified_x_download: "&user_notified_x_download&" - orderNotes: "&orderNotes, objUserLogged.getUserName(), "debug")
	
	call objOrdine.modifyOrdine(id_ordine, id_utente, dta_ins, stato_order, totale_imp_ord, totale_tasse_ord, totale_ord, tipo_pagam, payment_commission, pagam_done, user_notified_x_download, orderNotes, noRegistration, id_ads, objConn)

	'*******************  SE ESISTONO DELLE RULES PER ORDINE LE INSERISCO NELLA TABELLA BUSINESS_RULES_X_ORDINE
	if(hasOrderRule) then
		if not(bolRulesAlreadyDeleted)then
			call objRule.deleteRuleOrderByOrderID(id_ordine, objConn)
		end if
		for each a in objDictRules
			call objRule.insertRuleOrder(objDictRules(a).idRule, id_ordine, 0, 0, objDictRules(a).label, objDictRules(a).amount, objConn)
		next
		Set objDictRules = nothing

		if not(hasOldActiveVoucher) then
			for each e in objDictVoucherUsed
				call objVoucherClass.insertVoucherOrder(id_ordine, objDictVoucherUsed(e).getVoucherCode(), objDictVoucherUsed(e).getID(), objDictVoucherUsed(e).getValore(), objConn)
				call objVoucherClass.modifyVoucherCode(objDictVoucherUsed(e).getID(), objDictVoucherUsed(e).getVoucherCode(), objDictVoucherUsed(e).getVoucherCampaign(), objDictVoucherUsed(e).getInsertDate(), (objDictVoucherUsed(e).getUsageCounter()+1), objDictVoucherUsed(e).getIdUserRef(), objConn)
			next
		end if
		Set objDictVoucherUsed = nothing	
	end if

	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
	else
		objConn.RollBackTrans
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
	
	Set objDB = nothing		
	
	Set objTmpListaProdBeforeChange = nothing
	Set objProdTmp = nothing
	Set objVoucherClass =  nothing
	Set objRule = nothing
	Set objOrdine = nothing
	Set objProdField = nothing
	Set objProdPerOrder = nothing
	Set objGroup = nothing

	call objLogger.write("process ordine 2 modificato ordine --> id: "&id_ordine, objUserLogged.getUserName(), "info")
	response.Redirect(redirectPage)

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