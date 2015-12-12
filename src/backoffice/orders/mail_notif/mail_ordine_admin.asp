<%On Error Resume Next%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/UserFieldClass.asp" -->
<%
'/**
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_order, order_guid, id_utente, dta_ins, totale_ord, tipo_pagam, pagam_done, stato_order, objSelProdPerOrder, payment_commission
id_order = request("id_ordine")
order_guid = ""
id_utente = ""
dta_ins = ""
totale_ord = 0
tipo_pagam = ""
payment_commission = 0
pagam_done = 0
stato_order = 0
objSelProdPerOrder = null

Dim objUtente, objTmpUser
Set objUtente = New UserClass
					
if not (isNull(id_order)) then

	'*** verifico se � stata passata la lingua dell'utente e la imposto come langEditor.setLangCode(xxx)
	if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
		langEditor.setLangCode(request("lang_code"))
		langEditor.setLangElements(langEditor.getListaElementsByLang(langEditor.getLangCode()))
	end if

	Dim objOrdini, objSelOrdine, objProdPerOrder
	Set objOrdini = New OrderClass
	Set objSelOrdine = objOrdini.findOrdineByID(id_order, 1)
	Set objProdPerOrder = New Products4OrderClass
	Set objOrdini = nothing
	
	id_order = objSelOrdine.getIDOrdine()
	order_guid = objSelOrdine.getOrderGUID()
	id_utente = objSelOrdine.getIDUtente()
	dta_ins = objSelOrdine.getDtaInserimento()
	totale_ord = objSelOrdine.getTotale()
	tipo_pagam = objSelOrdine.getTipoPagam()
	payment_commission = objSelOrdine.getPaymentCommission()
	pagam_done = objSelOrdine.getPagamEffettuato()
	stato_order = objSelOrdine.getStatoOrdine()
	
	if (isObject(objProdPerOrder.getListaProdottiXOrdine(id_order)) AND not(isNull(objProdPerOrder.getListaProdottiXOrdine(id_order))) AND not(isEmpty(objProdPerOrder.getListaProdottiXOrdine(id_order)))) then
		Set objSelProdPerOrder = objProdPerOrder.getListaProdottiXOrdine(id_order)	
	end if	
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=004")			
end if
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=langEditor.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<link rel="stylesheet" href="<%="http://" & request.ServerVariables("SERVER_NAME") & Application("baseroot") & "/editor/css/stile.css"%>" type="text/css">
</head>
<body>
<div id="backend-warp">
	<div id="backend-content">
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.id_ordine")%>:</span>&nbsp;<%=id_order%><br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.guid_ordine")%>:</span>&nbsp;<%=order_guid%><br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.order_client")%>:</span>&nbsp;
		<%
		Set objTmpUser = objUtente.findUserByID(id_utente)
		response.Write("<strong>ID:</strong> " & objTmpUser.getUserName() & "; <strong>mail:</strong> "&objTmpUser.getEmail())

		' **************************
		' Se � stato attivato l'uso dei field utente per gli ordini senza registrazione visualizzo la lista di field/valore
		if(objSelOrdine.getNoRegistration()="1") then
			if(Application("show_user_field_on_direct_buy") = 1)then

				On Error Resume next
				Dim objUserField, objListUserField, hasUserFields
				hasUserFields=false
				On Error Resume Next
				Set objUserField = new UserFieldClass
				Set objListUserField = objUserField.getListUserField(1,"2,3")
				if(objListUserField.count > 0)then
					hasUserFields=true
				end if
				if(Err.number <> 0) then
					hasUserFields=false
				end if
				if(hasUserFields) then
					response.write("<br/><br/>")

					for each k in objListUserField
						Set objField = objListUserField(k)%>
						<span class="labelForm"><%if not(langEditor.getTranslated("backend.utenti.mail.label."&objField.getDescription())="") then response.write(langEditor.getTranslated("backend.utenti.mail.label."&objField.getDescription())) else response.write(objField.getDescription()) end if%>:</span>&nbsp;
						<%
						On Error Resume next
						Set objFieldValue=objUserField.findFieldMatch(objField.getID(), id_utente)
						fieldValue=objFieldValue.Item("value")
						
						if(CInt(objField.getTypeField())=4) then
							label = fieldValue
							if(CInt(objField.getTypeContent())=5) then
								if not(langEditor.getTranslated("portal.commons.select.option.country."&fieldValue)="") then label=langEditor.getTranslated("portal.commons.select.option.country."&fieldValue) end if
							else
								if not(langEditor.getTranslated("portal.commons.user_field.label."&fieldValue)="") then label=langEditor.getTranslated("portal.commons.user_field.label."&fieldValue) end if
							end if
							response.write(label)
						elseif(CInt(objField.getTypeField())=5 OR CInt(objField.getTypeField())=6 OR CInt(objField.getTypeField())=7) then
							label = ""
							fieldValue = split(fieldValue,",")
							for each y in fieldValue
								if not(langEditor.getTranslated("portal.commons.user_field.label."&y)="") then 
									label=label&langEditor.getTranslated("portal.commons.user_field.label."&y)&",&nbsp;"
								else
									label=label&y&",&nbsp;"
								end if
							next
							if(Len(label) > 0) then label = Left(label,(Len(label)-7))
							response.write(label)
						else
							label = fieldValue
							if not(langEditor.getTranslated("portal.commons.user_field.label."&fieldValue)="") then label=langEditor.getTranslated("portal.commons.user_field.label."&fieldValue) end if
							response.write(label)
						end if
						
						response.write("<br/><br/>")
						
						if(Err.number<>0) then
							'response.write(Err.description)
						end if
					next
				end if
		
				Set objListUserField = nothing
				Set objUserField = nothing
				
			end if
		end if

		
		' *****************************************************		
		  ' INIZIO: CODICE GESTIONE SHIPPING ADDRESS
		  Dim objShip, orderShip
		  Dim userName, userSurname, userCfiscVat, userAddress, userCity, userZipCode, userCountry, userStateRegion, userIsCompanyClient
		  
		  Set objShip = new ShippingAddressClass
		  On Error Resume Next
		  
		  Set orderShip = objShip.getOrderShippingAddress(id_order)
		  
		  if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
			userName = orderShip.getName()
			userSurname = orderShip.getSurname()
			userCfiscVat = orderShip.getCfiscVat()
			userAddress = orderShip.getAddress()
			userCity = orderShip.getCity()
			userZipCode = orderShip.getZipCode()
			userCountry = orderShip.getCountry()	
			userStateRegion = ""
			if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
				userStateRegion = " - " & langEditor.getTranslated("portal.commons.select.option.country."&orderShip.getStateRegion())
			end if
			if(Cint(orderShip.isCompanyClient())=0) then
				userIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_private")
			else
				userIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_company")
			end if			
			response.write("<br/><b>"&langEditor.getTranslated("backend.ordini.view.table.label.shipping_address")&":</b> "&userName & " " & userSurname & " ("&userIsCompanyClient&") - " & userCfiscVat & " - " &userAddress &" - "&userCity&" ("&userZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegion)
		  end if		  
		  
		  Set orderShip = nothing
		  
		  if(Err.number <> 0) then 
			'response.write(Err.description)
		  end if
		  Set objShip = nothing		  
		  
		
		' *****************************************************		
		  ' INIZIO: CODICE GESTIONE BILLS ADDRESS
		  Dim objBills, orderBills
		  
		  Set objBills = new BillsAddressClass
		  On Error Resume Next
		  
		  Set orderBills = objBills.getOrderBillsAddress(id_order)
		  
		  if (Instr(1, typename(orderBills), "BillsAddressClass", 1) > 0) then
			userName = orderBills.getName()
			userSurname = orderBills.getSurname()
			userCfiscVat = orderBills.getCfiscVat()
			userAddress = orderBills.getAddress()
			userCity = orderBills.getCity()
			userZipCode = orderBills.getZipCode()
			userCountry = orderBills.getCountry()	
			userStateRegion = ""		
			if not(isNull(orderBills.getStateRegion()) AND not(orderBills.getStateRegion()="")) then
				userStateRegion = " - " & langEditor.getTranslated("portal.commons.select.option.country."&orderBills.getStateRegion())
			end if		
			response.write("<br/><b>"&langEditor.getTranslated("backend.ordini.view.table.label.bills_address")&":</b> "&userName & " " & userSurname & " - " & userCfiscVat & " - " &userAddress &" - "&userCity&" ("&userZipCode&") - "&langEditor.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegion)
		  end if		  
		  
		  Set orderBills = nothing
		  
		  if(Err.number <> 0) then 
			'response.write(Err.description)
		  end if
		  Set objBills = nothing
		%>
		<br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.dta_insert_order")%>:</span>&nbsp;<%=dta_ins%>
		<br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.attached_prods")%></span><br/>
		<%
		Set objRule = new BusinessRulesClass
		
		if not(isNull(objSelProdPerOrder)) then
		Dim styleRow, styleRow2, counter
		styleRow2 = "table-list-on"
		counter = 0
		%>
			<table border="0" align="top" cellpadding="3" cellspacing="0">							
			  	<tr>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.sommario_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.totale_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.totale_tax")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%></th>	
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>				
			  	</tr>
			<%
			bolHasProdRule = false
			On Error Resume Next
			Set objListProd4Rule = objRule.findRuleOrderAssociationsByOrder(id_order, true)
			if (objListProd4Rule.count>0) then
				bolHasProdRule = true
			end if
			If Err.Number<>0 then
				bolHasProdRule = false
			end if
			
			Dim objTmpProdPerOrder, objTasse, descTassa, imponibile, tasse	, objProd					
			Set objTasse = new TaxsClass
			Set objProd = new ProductsClass	
			Set objProdField = new ProductFieldClass
					
			for each z in objSelProdPerOrder
				imponibile = 0
				tasse = 0
				descTassa = ""
				styleRow = "table-list-off"
				if(counter MOD 2 = 0) then styleRow = styleRow2 end if
				Set objTmpProdPerOrder = objSelProdPerOrder(z)					
				imponibile = objTmpProdPerOrder.getTotale()
				Set objProdTmp = objProd.findProdottoByID(objTmpProdPerOrder.getIDProdotto(), false)
				'if not(isNull(objProdTmp.getIDTassaApplicata())) AND not(objProdTmp.getIDTassaApplicata() = "") then
					'tasse = objProdTmp.getImportoTassa(imponibile)
					'descTassa = objTasse.findTassaByID(objProdTmp.getIDTassaApplicata()).getDescrizioneTassa()
					tasse = objTmpProdPerOrder.getTax()
				    if not(langEditor.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())="") then
					    descTassa = "&nbsp;&nbsp;("&langEditor.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())&")" 
				    else 
					    descTassa = "&nbsp;&nbsp;("&objTmpProdPerOrder.getDescTax()&")"
				    end if
				'end if%>
			  	<tr class="<%=styleRow%>">
				<td><%=objProdTmp.findFieldTranslation(1 ,langEditor.getLangCode(),1)%></td>
				<td><%=objProdTmp.findFieldTranslation(2 ,langEditor.getLangCode(),1)%></td>
				<td>&euro;&nbsp;<%=FormatNumber(imponibile,2,-1)%>
				<%					
				On Error Resume Next
				if (bolHasProdRule) then
					for each w in objListProd4Rule
						tmpIdProd = objListProd4Rule(w).getProdID() 
						tmpCounterProd = objListProd4Rule(w).getCounterProd() 
						if(tmpIdProd=objTmpProdPerOrder.getIDProdotto() AND tmpCounterProd=objTmpProdPerOrder.getCounterProd())then
							tmpLabel = objListProd4Rule(w).getLabel()                 
							tmp_amount_rule = objListProd4Rule(w).getValoreConf()%>
							<li style="list-style-type:none;"><%if(langEditor.getTranslated("portal.commons.business_rule.label."&tmpLabel) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&tmpLabel)) else response.write(tmpLabel) end if%>:&nbsp;&euro;&nbsp;<%=FormatNumber(tmp_amount_rule, 2,-1)%><br/>
					<%	end if
					next%>
				<%end if
				If Err.Number<>0 then
				end if
				%>				
				</td>	
				<td>&euro;&nbsp;<%=FormatNumber(tasse,2,-1)&descTassa%></td>	
				<td><%=objTmpProdPerOrder.getQtaProdotto()%></td>		
				<td>
					<%
					On Error Resume Next
					Set objListProdField = objProdField.getListProductField4ProdActive(objTmpProdPerOrder.getIDProdotto())
					
					if (Instr(1, typename(objListProdField), "Dictionary", 1) > 0) then
						if(objListProdField.count > 0)then							
							if (Instr(1, typename(objProdField.findListFieldXOrderByProd(objTmpProdPerOrder.getCounterProd(), id_order, objTmpProdPerOrder.getIDProdotto())), "Dictionary", 1) > 0) then
								Set fieldList4Order = objProdField.findListFieldXOrderByProd(objTmpProdPerOrder.getCounterProd(), id_order, objTmpProdPerOrder.getIDProdotto())			

								if(fieldList4Order.count > 0)then			
									for each w in fieldList4Order
										Set objTmpField4Order = fieldList4Order(w)
										keys = objTmpField4Order.Keys
																	
										labelTmpForm = ""
										for each r in keys
											Set tmpF4O = r
											
											labelTmpForm = tmpF4O.getDescription()
											if(Cint(objListProdField(tmpF4O.getID()).getTypeField())<>9)then
												valueTmp = Server.HTMLEncode(tmpF4O.getSelValue())
											else
												valueTmp = tmpF4O.getSelValue()
											end if
											if(Cint(objListProdField(tmpF4O.getID()).getTypeField())=8)then
												valueTmp = "<a href=""" & "http://" & request.ServerVariables("SERVER_NAME") & Application("baseroot") & valueTmp & """ target=_blank>click</a>"
											end if
											if not(langEditor.getTranslated("backend.prodotti.mail.label."&tmpF4O.getDescription())="") then labelTmpForm = langEditor.getTranslated("backend.prodotti.mail.label."&tmpF4O.getDescription())
											response.write(labelTmpForm & ":&nbsp;" & valueTmp & "<br/>")
										
											Set tmpF4O = nothing
										next
										Set objTmpField4Order = nothing
									next				
									Set fieldList4Order = nothing
								end if
							end if
							
						end if
					end if
					if(Err.number <> 0) then
					end if
					%>					
				</td>					
				
			  	</tr>
				<%
				Set objProdTmp = nothing
				Set objTmpProdPerOrder = nothing
				counter = counter +1
			next
			if(bolHasProdRule)then
				Set objListProd4Rule = nothing
			end if
			
			Set objProdField = nothing
			Set objProd = nothing
			Set objTasse = nothing%>	
			</table>			
			<%
			Set objSelProdPerOrder = nothing
		end if
		%>		
		<br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")%>:</span>&nbsp;
		<%
		Dim objPayment, objTmpPayment
		Set objPayment = New PaymentClass
		Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
		response.write(langEditor.getTranslated(objTmpPayment.getKeywordMultilingua())&"<br/><br/>")
		response.write(objTmpPayment.getDatiPagamento())
		Set objTmpPayment = Nothing
		Set objPayment = Nothing
		%>		
		<br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.pagam_order_done")%>:</span>&nbsp;
		<%
		Select Case pagam_done
		Case 0
			response.write(langEditor.getTranslated("backend.commons.no"))
		Case 1
			response.write(langEditor.getTranslated("backend.commons.yes"))
		Case Else
		End Select
		%>
		<br/><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.list_transaction_order")%>:</span><br/>
		<%
		Dim objPaymentTrans, objTmpPaymentTransList
		Set objPaymentTrans = new PaymentTransactionClass
		On error resume next
		Set objTmpPaymentTransList = objPaymentTrans.getListaOrderPaymentTransaction(id_order)
		for each q in objTmpPaymentTransList
			response.write("<strong>ID:</strong> "&objTmpPaymentTransList(q).getIdTransaction()&";&nbsp;")
			response.write("<strong>STATUS:</strong> "&objTmpPaymentTransList(q).getPaymentStatus()&";&nbsp;")
			Select Case objTmpPaymentTransList(q).isNotified()
			Case 0
				response.write("<strong>NOTIFIED:</strong> "&langEditor.getTranslated("backend.commons.no")&";<br/>")
			Case 1
				response.write("<strong>NOTIFIED:</strong> "&langEditor.getTranslated("backend.commons.yes")&";<br/>")
			Case Else
			End Select
		next
		Set objTmpPaymentTransList = Nothing		
		
		if (Err.number <> 0) then
		end if
		
		Set objPaymentTrans = nothing
		%>		
		<br/><br/>		
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.stato_order")%>:</span>&nbsp;
		<%
		Select Case stato_order
		Case 1
			response.write(langEditor.getTranslated("backend.ordini.view.table.label.ord_inserting"))
		Case 2
			response.write(langEditor.getTranslated("backend.ordini.view.table.label.ord_executing"))
		Case 3
			response.write(langEditor.getTranslated("backend.ordini.view.table.label.ord_executed"))
		Case 4
			response.write(langEditor.getTranslated("backend.ordini.view.table.label.ord_sca"))
		Case Else
		End Select
		%>
		<br/><br/>		
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.spese_spediz_order")%>:</span><br/>
		<%
		On Error Resume Next
		Dim objBillsClass, objBills4OrderClass
		Dim objListaSpeseXOrdine, objTmpSpesa, objTmpSpesaXOrdine
		Set objBillsClass = new BillsClass
		Set objBills4OrderClass = new Bills4OrderClass	
		
		Set objListaSpeseXOrdine = objBills4OrderClass.getSpeseXOrdine(id_order)
		
		for each j in objListaSpeseXOrdine.Keys
			Set objTmpSpesaXOrdine = objListaSpeseXOrdine(j)
			Set objTmpSpesa = objBillsClass.findSpesaByID(objTmpSpesaXOrdine.getIDSpesa())
			response.write(objTmpSpesa.getDescrizioneSpesa()&"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"&FormatNumber(objTmpSpesaXOrdine.getTotale(),2,-1,-2,0)&"<br/>")
			Set objTmpSpesa = nothing
			Set objTmpSpesaXOrdine = nothing
		next
		
		Set objListaSpeseXOrdine = nothing
		Set objBillsClass = nothing
		Set objBills4OrderClass = nothing			
		
		If Err.Number<>0 then
		end if
		%><br/>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.payment_commission")%>:</span>&nbsp;&euro;&nbsp;<%=FormatNumber(payment_commission,2,-1)%>
		<br/><br/>
		<%
		On Error Resume Next
		Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_order, false)
		if(strComp(typename(objRule4Order), "Dictionary") = 0)then
			if(objRule4Order.count>0)then%>
				<%=langEditor.getTranslated("backend.ordini.view.table.label.business_rules")%>:<br/>
				<%for each x in objRule4Order%>
					<%if(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>&nbsp;&nbsp;&nbsp;&euro;&nbsp;<%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1)%><br/>
				<%next%>
				<br/>
			<%end if	
		end if		
		Set objRule4Order = nothing
		If Err.Number<>0 then
			'response.write(Err.description)					
		end if
		Set objRule = nothing
		%>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.totale_order")%>:</span>&nbsp;&euro;&nbsp;<%=FormatNumber(totale_ord,2,-1)%>
	</div>
</div>
</body>
</html>
<%
Set objUtente = nothing
Set Ordine = Nothing

if(Err.number <> 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>
