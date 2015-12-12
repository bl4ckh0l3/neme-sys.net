<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/ShippingAddressClass.asp" -->
<!-- #include virtual="/common/include/Objects/BillsAddressClass.asp" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table border="0" cellpadding="0" cellspacing="0" class="principal">
		<tr>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.id_ordine")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.dta_insert_order")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.stato_order")%></th>
		</tr>
		<tr>
		<td><%=id_order%></td>
		<td class="separator">&nbsp;</td>
		<td><%=dta_ins%></td>
		<td class="separator">&nbsp;</td>
		<td>
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
		%></td>	
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.guid_ordine")%></th>
		</tr>
		<tr>
		<td colspan="5"><%=order_guid%>&nbsp;</td>
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.order_notes")%></th>
		</tr>
		<tr>
		<td colspan="5"><%=order_notes%>&nbsp;</td>
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.order_client")%></th>
		</tr>
		<tr>
		<td colspan="5"><%
		Set objTmpUser = objUtente.findUserByID(id_utente)
		response.Write("<strong>ID:</strong> " & objTmpUser.getUserName() & "; <strong>mail:</strong> "&objTmpUser.getEmail())
		
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
			if(Cint(orderShip.isCompanyClient())=0) then
				userIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_private")
			else
				userIsCompanyClient = langEditor.getTranslated("backend.utenti.detail.table.label.is_company")
			end if
			userCountry = orderShip.getCountry()	
			userStateRegion = ""	
			if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
				userStateRegion = " - " & langEditor.getTranslated("portal.commons.select.option.country."&orderShip.getStateRegion())
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
		%></td>
		</tr>
		<tr>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.pagam_order_done")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.user_notified_x_download")%></th>
		</tr>
		<tr>
		<td><%
		Dim objPayment, objTmpPayment
		Set objPayment = New PaymentClass
		Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
		response.write(langEditor.getTranslated(objTmpPayment.getKeywordMultilingua()))
		Set objTmpPayment = Nothing
		Set objPayment = Nothing
		%></td>
		<td class="separator">&nbsp;</td>
		<td><%
		Select Case pagam_done
		Case 0
			response.write(langEditor.getTranslated("backend.commons.no"))
		Case 1
			response.write(langEditor.getTranslated("backend.commons.yes"))
		Case Else
		End Select
		%></td>
		<td class="separator">&nbsp;</td>
		<td><%
		Select Case user_notified_x_download
		Case 0
			response.write(langEditor.getTranslated("backend.commons.no"))
		Case 1
			response.write(langEditor.getTranslated("backend.commons.yes"))
		Case Else
		End Select
		%></td>
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.list_transaction_order")%></th>
		</tr>
		<tr>
		<td colspan="5"><%
		Dim objPaymentTrans, objTmpPaymentTransList
		Set objPaymentTrans = new PaymentTransactionClass
		On error resume next
		Set objTmpPaymentTransList = objPaymentTrans.getListaOrderPaymentTransaction(id_order)
		for each q in objTmpPaymentTransList
			response.write("<strong>INSERT DATE:</strong> "&objTmpPaymentTransList(q).getInsertDate()&";&nbsp;")
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
		%>&nbsp;</td>
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.attached_prods")%></th>
		</tr>
		<tr>
		<td colspan="5">
		<%
		Set objRule = new BusinessRulesClass
		
		if not(isNull(objSelProdPerOrder)) then
		Dim styleRow, styleRow2, counter
		styleRow2 = "table-list-on"
		counter = 0
		%>
			<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
			  	<tr>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.totale_prod")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.totale_tax")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")%></th>	
				<th><%=langEditor.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>	
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.prod_type")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.view.table.header.status_download")%></th>				
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


			Dim objTmpProdPerOrder, objTasse, descTassa, imponibile, tasse	, objProd, prod_type					
			Set objTasse = new TaxsClass					
			for each z in objSelProdPerOrder
				imponibile = 0
				tasse = 0
				descTassa = ""
				prod_type = 0
				styleRow = "table-list-off"
				if(counter MOD 2 = 0) then styleRow = styleRow2 end if
				Set objTmpProdPerOrder = objSelProdPerOrder(z)					
				imponibile = objTmpProdPerOrder.getTotale()
				
				if(objTmpProdPerOrder.getTax() <> "") then 
				  tasse = objTmpProdPerOrder.getTax()
				  if not(langEditor.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())="") then
					  descTassa = "&nbsp;&nbsp;("&langEditor.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())&")" 
				  else 
					  descTassa = "&nbsp;&nbsp;("&objTmpProdPerOrder.getDescTax()&")"
				  end if
				end if	
				prod_type = objTmpProdPerOrder.getProdType()					
				%>
			  	<tr class="<%=styleRow%>">
				<td><%=Server.HTMLEncode(objTmpProdPerOrder.getNomeProdotto())%></td>
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
										'hasQtaViewed = false
										for each r in keys
											Set tmpF4O = r
											
											'if not(hasQtaViewed) then
												'response.write(langEditor.getTranslated("backend.ordini.view.table.header.qta_prod")&":&nbsp;"&r.getQtaProd()&"<br/>")
												'hasQtaViewed = true
											'end if
											
											labelTmpForm = tmpF4O.getDescription()
											if(Cint(tmpF4O.getTypeField())<>9)then
												valueTmp = Server.HTMLEncode(tmpF4O.getSelValue())
											else
												valueTmp = tmpF4O.getSelValue()
											end if
											if(Cint(objListProdField(tmpF4O.getID()).getTypeField())=8)then
												valueTmp = "<a href=""" & valueTmp & """ target=_blank>click</a>"
											end if
											if not(langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())="") then labelForm = langEditor.getTranslated("backend.prodotti.detail.table.label."&tmpF4O.getDescription())
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
				<td>
				<%if(prod_type = 0)then 
					response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_portable")) 
				elseif(prod_type = 1)then 
					response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_download"))
				elseif(prod_type = 2)then 
					response.Write(langEditor.getTranslated("backend.prodotti.detail.table.label.type_ads"))
				end if
				%></td>	
				<td>
				<%if(prod_type = 1)then%>
				<a href="javascript:openWin('<%=Application("baseroot")&"/editor/ordini/include/popupDownloadStatus.asp?id_ordine="&id_order&"&id_prodotto="&objTmpProdPerOrder.getIDProdotto()%>','popupallegatidown',420,400,100,100);" title="<%=langEditor.getTranslated("backend.ordini.view.table.alt.status_download")%>"><img src="<%=Application("baseroot")&"/editor/img/zoom.png"%>" hspace="0" vspace="0" border="0"></a>
				<%end if%>
				&nbsp;</td>		
			  	</tr>
				<%Set objTmpProdPerOrder = nothing
				counter = counter +1
			next
			if(bolHasProdRule)then
				Set objListProd4Rule = nothing
			end if
			Set objTasse = nothing%>	
			</table><br/>			
			<%
			Set objSelProdPerOrder = nothing
		end if
		%>	
		</td>
		</tr>
		<tr>
		<th><span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.spese_spediz_order")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.payment_commission")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.ordini.view.table.label.business_rules")%></th>
		</tr>
		<tr>
		<td><%
		On Error Resume Next
		Dim objBillsClass, objBills4OrderClass
		Dim objListaSpeseXOrdine, objTmpSpesa, objTmpSpesaXOrdine
		Set objBills4OrderClass = new Bills4OrderClass	
		
		Set objListaSpeseXOrdine = objBills4OrderClass.getSpeseXOrdine(id_order)
		
		for each j in objListaSpeseXOrdine.Keys
			Set objTmpSpesaXOrdine = objListaSpeseXOrdine(j)
			response.write(objTmpSpesaXOrdine.getDescSpesa()&"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"&FormatNumber(objTmpSpesaXOrdine.getTotale(),2,-1,-2,0)&"<br/>")
			Set objTmpSpesaXOrdine = nothing
		next
		
		Set objListaSpeseXOrdine = nothing
		Set objBills4OrderClass = nothing			
		
		If Err.Number<>0 then
		end if
		
		Set objProdField = nothing	
		Set objSelOrdine = nothing
		%></td>
		<td class="separator">&nbsp;</td>
		<td >&euro;&nbsp;<%=FormatNumber(payment_commission,2,-1)%></td>
		<td class="separator">&nbsp;</td>
		<td>
		<%
		On Error Resume Next
		Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_order, false)
		if(strComp(typename(objRule4Order), "Dictionary") = 0)then
			if(objRule4Order.count>0)then
				for each x in objRule4Order%>
					<%if(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>&nbsp;&nbsp;&nbsp;&euro;&nbsp;<%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1,-2,0)%><br/>
			<%	next
			end if	
		end if		
		Set objRule4Order = nothing
		If Err.Number<>0 then
			'response.write(Err.description)					
		end if
		Set objRule = nothing
		%>		
		</td>
		</tr>
		<tr>
		<th colspan="5"><%=langEditor.getTranslated("backend.ordini.view.table.label.totale_order")%></th>
		</tr>
		<tr>
		<td colspan="5">&euro;&nbsp;<%=FormatNumber(totale_ord,2,-1)%></td>
		</tr>
		</table><br/>
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/ordini/ListaOrdini.asp?cssClass=LO"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>