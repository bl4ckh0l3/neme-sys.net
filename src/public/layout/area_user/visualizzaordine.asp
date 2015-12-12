<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/area_user.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
</head>
<body>
<!-- #include file="grid_top.asp" -->

		<form action="<%=Application("baseroot") & "/area_user/VisualizzaOrdine.asp"%>" method="get" name="form_reload_page">
		<input type="hidden" name="id_ordine" value="<%=id_order%>">
		</form>
		<%
			Set objRule = new BusinessRulesClass
			
			if not(isNull(objSelProdPerOrder)) then
			Dim styleRow, styleRow2, counter
			styleRow2 = "table-list-on"
			counter = 0
			%>
				<table border="0" cellspacing="0" cellpadding="0" class="principal">							
					<tr>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.nome_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.totale_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.tax_prod")%></th>
					<th><%=lang.getTranslated("frontend.area_user.ordini.table.prod.header.qta_prod")%></th>
					<th>&nbsp;</td>			
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
				
				for each z in objSelProdPerOrder
					imponibile = 0
					tasse = 0
					descTassa = ""
					styleRow = "table-list-off"
					if(counter MOD 2 = 0) then styleRow = styleRow2 end if
					Set objTmpProdPerOrder = objSelProdPerOrder(z)					
					imponibile = objTmpProdPerOrder.getTotale()
			
					if(objTmpProdPerOrder.getTax() <> "") then 
					  tasse = objTmpProdPerOrder.getTax()
					  if not(lang.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())="") then
						  descTassa = "&nbsp;&nbsp;("&lang.getTranslated("portal.commons.order_taxs.label."&objTmpProdPerOrder.getDescTax())&")" 
					  else 
						  descTassa = "&nbsp;&nbsp;("&objTmpProdPerOrder.getDescTax()&")"
					  end if
					end if%>
					<tr class="<%=styleRow%>">
					<td><%=objTmpProdPerOrder.getNomeProdotto()%><br/><br/>
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
												valueTmp = tmpF4O.getSelValue()
												if(Cint(tmpF4O.getTypeField())=8)then
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
								<li style="list-style-type:none;"><%if(lang.getTranslated("portal.commons.business_rule.label."&tmpLabel) <> "") then response.write(lang.getTranslated("portal.commons.business_rule.label."&tmpLabel)) else response.write(tmpLabel) end if%>:&nbsp;&euro;&nbsp;<%=FormatNumber(tmp_amount_rule, 2,-1)%><br/>
						<%	end if
						next%>
					<%end if
					If Err.Number<>0 then
					end if
					%>						
					</td>
					<td nowrap>&euro;&nbsp;<%=FormatNumber(tasse,2,-1)&descTassa%></td>				
					<td align="center"><%=objTmpProdPerOrder.getQtaProdotto()%></td>
					<td align="center">
					<%
					Dim objCommento
					Set objCommento = New CommentsClass
					if(not(Instr(1, typename(objCommento.findCommentiByIDUtente(id_utente, objTmpProdPerOrder.getIDProdotto(),2,null)), "Dictionary", 1) > 0)) then%>
					<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupInsertComments.asp?id_element="&objTmpProdPerOrder.getIDProdotto()&"&element_type=2"%>','popupallegati',400,400,100,100);" title="<%=lang.getTranslated("frontend.area_user.ordini.table.prod.label.insert_comment")%>"><img src="<%=Application("baseroot")&"/common/img/comment_add.png"%>" hspace="0" vspace="0" border="0" alt="<%=lang.getTranslated("frontend.area_user.ordini.table.prod.label.insert_comment")%>"></a>
					<%
					Set objCommento = nothing
					else%>
					&nbsp;
					<%end if%>
					</td>			
					</tr>
					<%Set objTmpProdPerOrder = nothing
					counter = counter +1
				next
				if(bolHasProdRule)then
					Set objListProd4Rule = nothing
				end if
				Set objTasse = nothing%>	
				</table>		
				<br/>
				<%
				Set objSelProdPerOrder = nothing
			end if
			%>
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.id_ordine")%>:</span>&nbsp;<%=id_order%><br/><br/>
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.dta_insert_order")%>:</span>&nbsp;<%=dta_ins%><br/><br/>
			<!--<span class="labelTabAreaUser"><%'=lang.getTranslated("frontend.area_user.ordini.table.label.attached_prods")%></span><br/>-->
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.tipo_pagam_order")%>:</span>&nbsp;
			<%
			Dim objPayment, objTmpPayment
			Set objPayment = New PaymentClass
			Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
			response.write(lang.getTranslated(objTmpPayment.getKeywordMultilingua()))
			Set objTmpPayment = Nothing
			Set objPayment = Nothing
			%>		
			<br/><br/>
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.pagam_order_done")%>:</span>&nbsp;
			<%
			Select Case pagam_done
			Case 0
				response.write(lang.getTranslated("portal.commons.no"))
			Case 1
				response.write(lang.getTranslated("portal.commons.yes"))
			Case Else
			End Select
			%>
			<br/><br/>		
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.stato_order")%>:</span>&nbsp;
			<%
			Select Case stato_order
			Case 1
				response.write(lang.getTranslated("frontend.area_user.ordini.table.label.ord_inserting"))
			Case 2
				response.write(lang.getTranslated("frontend.area_user.ordini.table.label.ord_executing"))
			Case 3
				response.write(lang.getTranslated("frontend.area_user.ordini.table.label.ord_executed"))
			Case 4
				response.write(lang.getTranslated("frontend.area_user.ordini.table.label.ord_sca"))
			Case Else
			End Select
			%>
			<br/><br/>		
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.spese_spediz_order")%>:</span><br/>
			<%
			On Error Resume Next
			Dim objBillsClass, objBills4OrderClass
			Dim objListaSpeseXOrdine, objTmpSpesa, objTmpSpesaXOrdine
			Set objBills4OrderClass = new Bills4OrderClass	
			
			Set objListaSpeseXOrdine = objBills4OrderClass.getSpeseXOrdine(id_order)
			
			for each j in objListaSpeseXOrdine.Keys
				Set objTmpSpesaXOrdine = objListaSpeseXOrdine(j)
				response.write("&nbsp;"&objTmpSpesaXOrdine.getDescSpesa()&"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"&FormatNumber(objTmpSpesaXOrdine.getTotale(),2,-1,-2,0)&"<br/>")
				Set objTmpSpesaXOrdine = nothing
			next
			
			Set objListaSpeseXOrdine = nothing
			Set objBills4OrderClass = nothing			
			
			If Err.Number<>0 then
			end if
			%>
			<!--<%'if(CDbl(sconto_cliente)>0) then%><br/><span class="labelTabAreaUser"><%'=lang.getTranslated("frontend.carrello.table.label.confirm_sconto_cli")%>:</span>&nbsp;&nbsp;<%'=sconto_cliente%>%<br/><%'end if%>-->
			<br/>
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.payment_commission")%>:</span>&nbsp;&euro;&nbsp;<%=FormatNumber(payment_commission,2,-1)%>
			<br/><br/>
			
			<%
			On Error Resume Next
			Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_order, false)
			if(objRule4Order.count>0)then
				for each x in objRule4Order%>
					<span class="labelForm"><%if(lang.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(lang.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>:</span>&nbsp;&euro;&nbsp;<%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1)%><br/>
				<%next%>
				<br/>
			<%end if					
			Set objRule4Order = nothing
			If Err.Number<>0 then
				'response.write(Err.description)					
			end if
			Set objRule = nothing
			%>

			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.totale_order")%>:</span>&nbsp;&euro;&nbsp;<%=FormatNumber(totale_ord,2,-1)%>
			<br/><br/>
		
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.shipping_address")%>:</span><br/>
			<%
			' *****************************************************		
			  ' INIZIO: CODICE GESTIONE SHIPPING ADDRESS
			  Dim objShip, orderShip
			  Dim userName, userSurname, userCfiscVat, userAddress, userCity, userZipCode, userCountry, userStateRegion
			  
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
					userStateRegion = " - " & lang.getTranslated("portal.commons.select.option.country."&orderShip.getStateRegion())
				  end if	
				  response.write(userName & " " & userSurname & " - " & userCfiscVat & " - " & userAddress &" - "&userCity&" ("&userZipCode&") - "&lang.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegion)
			  end if		  
			  
			  Set orderShip = nothing
			  
			  if(Err.number <> 0) then 
				'response.write(Err.description)
			  end if
			  Set objShip = nothing    
			  %>
			  <br/><br/>
		
			<span class="labelForm"><%=lang.getTranslated("frontend.area_user.ordini.table.label.bills_address")%>:</span><br/>
			<%
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
					userStateRegion = " - " & lang.getTranslated("portal.commons.select.option.country."&orderBills.getStateRegion())
				  end if	
				  response.write(userName & " " & userSurname & " - " & userCfiscVat & " - " & userAddress &" - "&userCity&" ("&userZipCode&") - "&lang.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegion)
			  end if		  
			  
			  Set orderBills = nothing
			  
			  if(Err.number <> 0) then 
				'response.write(Err.description)
			  end if
			  Set objBills = nothing %>
		  <br/><br/>	
		   
<!-- #include file="grid_bottom.asp" -->
</body>
</html>