<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
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
		<%cssClass="LCI"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
			<tr>
			<th><%=langEditor.getTranslated("backend.carrello.view.table.label.id_carrello")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.carrello.view.table.label.carrello_client")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.carrello.view.table.label.dta_insert_carrello")%></th>
			</tr>
			<tr>
			<td><%=id_carrello%></td>
			<td class="separator">&nbsp;</td>
			<td><%scontoCliente= 0
			Set objUtente = New UserClass		
			on error Resume Next
			Set objTmpUser = objUtente.findUserByIDExt(id_utente, false)
			scontoCliente= objTmpUser.getSconto()
			if(Cdbl(scontoCliente) > 0) then 
				hasSconto = true
			end if
			response.Write(objTmpUser.getUserName())
			Set objTmpUser = nothing
			Set objUtente = nothing
			
			if Err.number <> 0 then
				response.Write(langEditor.getTranslated("backend.commons.sessione")&": "& id_utente)
				hasSconto = false			
			end if	
			%></td>
			<td class="separator">&nbsp;</td>
			<td>
			<%if(DateDiff("d",dta_ins,Now()) > Application("day_carrello_is_valid")) then%>
				<span class="carrello_too_old"><%=dta_ins%></span><br><br>
			<%else%>
				<%=dta_ins%><br><br>
			<%end if%></td>	
			</tr>
			<tr>
			<th colspan="5"><%=langEditor.getTranslated("backend.carrello.view.table.label.attached_prods_carrello")%></th>
			</tr>
			<tr>
			<td colspan="5"><%
			if not(isNull(objSelProdPerCarrello)) then
			Dim styleRow, styleRow2, counter, prodotto, objProdTmp
			styleRow2 = "table-list-on"
			counter = 0
			Set prodotto = New ProductsClass
			%>
				<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
					<tr>
					<th><%=langEditor.getTranslated("backend.carrello.view.table.header.nome_prod")%></th>
					<th><%=langEditor.getTranslated("backend.carrello.view.table.header.qta_prod")%></th>
					<th><%=langEditor.getTranslated("backend.carrello.view.table.header.totale_prod")%></th>	
					<th><%=langEditor.getTranslated("backend.carrello.view.table.header.totale_tax")%></th>		
					</tr>
				<%Dim objTmpProdPerCarrello, totaleProdottoImp, totaleProdottoTax, totaleProdottoImp4spese, totale_qta_carrello, objListAllFieldxProd
				totaleProdottoImp4spese = 0
				totale_qta_carrello = 0

				'** inizializzo mappa dei field per prodotto selezionati				 
				Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")
	
				for each z in objSelProdPerCarrello
					styleRow = "table-list-off"
					if(counter MOD 2 = 0) then styleRow = styleRow2 end if
					Set objTmpProdPerCarrello = objSelProdPerCarrello(z)
					Set objProdTmp = prodotto.findProdottoByID(objTmpProdPerCarrello.getIDProd(),0)
					prod_type = objProdTmp.getProdType()
					totaleProdottoImp = 0
					totaleProdottoTax = 0 
					if(objProdTmp.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then
						totaleProdottoImp = objProdTmp.getPrezzoScontato() * objTmpProdPerCarrello.getQtaProd()
						if(hasSconto)then
							totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * scontoCliente)							
						end if
					else
						totaleProdottoImp = objProdTmp.getPrezzo() * objTmpProdPerCarrello.getQtaProd()
						if(hasSconto)then
							totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * scontoCliente)							
						end if
					end if

					if not(isNull(objProdTmp.getIDTassaApplicata())) AND not(objProdTmp.getIDTassaApplicata() = "") then
						totaleProdottoTax = objProdTmp.getImportoTassa(totaleProdottoImp)
					end if
					descTassa = ""
					descTassa = objTasse.findTassaByID(objProdTmp.getIDTassaApplicata()).getDescrizioneTassa()
					descTassa = "&nbsp;&nbsp;("&descTassa&")"
					totaleProdottoImp4spese = totaleProdottoImp4spese+totaleProdottoImp
					totale_carrello = totale_carrello+totaleProdottoImp+totaleProdottoTax
					if (prod_type=0) then
						totale_qta_carrello=totale_qta_carrello+Cint(objTmpProdPerCarrello.getQtaProd())
					end if%>
					<tr class="<%=styleRow%>">
					<td><%=Server.HTMLEncode(objProdTmp.getNomeProdotto())%></td>
					<td><%=objTmpProdPerCarrello.getQtaProd()%></td>
					<td>&euro;&nbsp;<%=FormatNumber(totaleProdottoImp,2,-1)%></td>	
					<td>&euro;&nbsp;<%=FormatNumber(totaleProdottoTax,2,-1)&descTassa%></td>			
					</tr>
					<%
					Set objProdField = new ProductFieldClass
					'response.write("fieldList4Card.count: " & fieldList4Card.count&"<br>")
					if (Instr(1, typename(objProdField.findListFieldXCardByProd(objTmpProdPerCarrello.getCounterProd(), id_carrello, objTmpProdPerCarrello.getIDProd())), "Dictionary", 1) > 0) then
						Set fieldList4Card = objProdField.findListFieldXCardByProd(objTmpProdPerCarrello.getCounterProd(), id_carrello, objTmpProdPerCarrello.getIDProd())			
		
						'response.write("fieldList4Card.count: " & fieldList4Card.count&"<br>")
			
						if(fieldList4Card.count > 0)then
							if (prod_type=0) then
								'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
								Set objDict = Server.CreateObject("Scripting.Dictionary")
								objListAllFieldxProd.add objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd(), objDict
							end if%>
							<p>											
							<%for each q in fieldList4Card
								
								Set objTmpField4Card = fieldList4Card(q)
								keys = objTmpField4Card.Keys
								'response.write("objTmpField4Card.count: " & objTmpField4Card.count&"<br>")
								
								for each r in keys
									Set tmpF4O = r
									if (prod_type=0) then
										Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
										objDictFieldxProd.add "id", tmpF4O.getID()
										objDictFieldxProd.add "value", tmpF4O.getSelValue()
										objDictFieldxProd.add "qta", objTmpProdPerCarrello.getQtaProd()
										objListAllFieldxProd(objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd()).add objDictFieldxProd, ""
										'response.write("r id: " & objDictFieldxProd("id"))
										'response.write(" - value: " & objDictFieldxProd("value"))
										'response.write(" - qta: " & objDictFieldxProd("qta"))
										Set objDictFieldxProd = nothing
									end if
									Set tmpF4O = nothing
								next
								Set objTmpField4Card = nothing							
							next%>
							</p>
							<%Set objDict = nothing
						end if
						Set fieldList4Card = nothing
					end if

					'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
					if (Instr(1, typename(objProdField.getListProductField4ProdActive(objTmpProdPerCarrello.getIDProd())), "Dictionary", 1) > 0) then
						Set fieldList4CardH = objProdField.getListProductField4ProdActive(objTmpProdPerCarrello.getIDProd())			
					
						if(fieldList4CardH.count > 0)then
							if (prod_type=0) then
								'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
								Set objDict = Server.CreateObject("Scripting.Dictionary")
								if not(objListAllFieldxProd.Exists(objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd()))then
									objListAllFieldxProd.add objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd(), objDict
								end if

								for each d in fieldList4CardH
									if((fieldList4CardH(d).getTypeContent()=2 OR fieldList4CardH(d).getTypeContent()=3) AND (fieldList4CardH(d).getEditable()=0))then
										Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
										objDictFieldxProd.add "id", fieldList4CardH(d).getID()
										objDictFieldxProd.add "value", fieldList4CardH(d).getSelValue()
										objDictFieldxProd.add "qta", objTmpProdPerCarrello.getQtaProd()

										bolCanAdd = true
										On Error Resume Next
										for each i in objListAllFieldxProd(objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd())
											if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
												bolCanAdd = false
												Exit for
											end if
										next

										if(bolCanAdd)then
											objListAllFieldxProd(objTmpProdPerCarrello.getCounterProd()&"-"&objTmpProdPerCarrello.getIDProd()).add objDictFieldxProd, ""
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


					Set objProdField = nothing

					Set objTmpProdPerCarrello = nothing
					counter = counter +1
				next%>	
				</table>			
				<%
				Set objSelProdPerCarrello = nothing
			end if%></td>
			</tr>
			<tr>
			<th><%=langEditor.getTranslated("backend.carrello.view.table.label.spese_accessorie")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.carrello.view.table.label.totale_carrello")%></th>
			<td class="separator">&nbsp;</td>
			<th>&nbsp;</th>
			</tr>
			<tr>
			<td>
			&euro;&nbsp;<%
				On Error Resume Next
				Dim objBillsClass, totSpeseImp, totSpeseTax, totSpese
				Dim objListaSpeseXCarrello, objTmpSpesa, objTmpSpesaXCarrello
				Set objBillsClass = new BillsClass		
				Set objListaSpeseXCarrello = objBillsClass.getListaSpese(null, null, 1, null)
				totSpese = 0
				
				for each j in objListaSpeseXCarrello.Keys
					Set objTmpSpesaXCarrello = objListaSpeseXCarrello(j)

					'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
					totSpeseImp = objTmpSpesaXCarrello.getImpByStrategy(totaleProdottoImp4spese, totale_qta_carrello, objListAllFieldxProd)

					'if(CInt(objTmpSpesaXCarrello.getTipoValore()) = 2) then
						'totSpeseImp = totaleProdottoImp4spese / 100 * objTmpSpesaXCarrello.getValore()
					'else
						'totSpeseImp = objTmpSpesaXCarrello.getValore()
					'end if

					if not(isNull(objTmpSpesaXCarrello.getIDTassaApplicata())) AND not(objTmpSpesaXCarrello.getIDTassaApplicata() = "") then
						Dim iValore
						iValore = objTasse.findTassaByID(objTmpSpesaXCarrello.getIDTassaApplicata()).getValore()
						iValore = CDbl(iValore)
						if(objTasse.findTassaByID(objTmpSpesaXCarrello.getIDTassaApplicata()).getTipoValore() = 2) then
							totSpeseTax = totSpeseImp * (iValore / 100)
						else
							totSpeseTax = iValore
						end if	
					end if
									
					totSpese = totSpese+totSpeseImp+totSpeseTax
					Set objTmpSpesaXCarrello = nothing
				next
				
				Set objListAllFieldxProd = nothing
				Set objListaSpeseXCarrello = nothing
				Set objBillsClass = nothing					
				Set objTasse = nothing	
				Set objSelOrdine = nothing
				
				If Err.Number<>0 then
				end if
				response.Write(FormatNumber(totSpese,2,-1,-2,0))
				%></td>
			<td class="separator">&nbsp;</td>
			<td>&euro;&nbsp;<%=FormatNumber(totSpese+totale_carrello,2,-1)%></td>
			<td class="separator">&nbsp;</td>
			<td>&nbsp;</td>	
			</tr>		
			</table><br/>
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/carrelli/ListaCarrelli.asp?cssClass=LCI"%>';" />
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>