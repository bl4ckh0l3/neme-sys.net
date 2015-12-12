		<%if(not(request("error")) = "" AND request("error") = 1) then%>
				<br><span class="labelTabCarrello"><%=lang.getTranslated("frontend.carrello.table.label.error_wrong_qta") & " " & request("nome_prod")%></span><br><br>
		<%end if
		
		'************** codice per la lista Prodotto e paginazione
		if(not(isNull(objCarrelloUser))) then
			id_carrello = objCarrelloUser.getIDCarrello()
			Dim objProdPerCarrello
			Set objProdPerCarrello = New ProductsCardClass
			
			bolHasObj = false
			
			on error Resume Next
			Set objListaCarrello = objProdPerCarrello.retrieveListaProdotti(objCarrelloUser.getIDCarrello())	
			
			if(objListaCarrello.Count > 0) then
        '*** se non è presente l'id_ads devo eliminare dalla lista prodotti carrello tutti i prodotti di tipo 2 (annunci)
        bolMakeDel = false
        if(ref_id_ads="")then
          for each g in objListaCarrello
            if(objListaCarrello(g).getProdType()=2)then
                  call objProdPerCarrello.delItemNoTransaction(objListaCarrello(g).getIDCarrello(), objListaCarrello(g).getIDProd(), objListaCarrello(g).getCounterProd())
                  bolMakeDel = true
            end if
          next
        end if

        if(bolMakeDel)then
           Set objListaCarrello = objProdPerCarrello.retrieveListaProdotti(objCarrelloUser.getIDCarrello())	
          if(objListaCarrello.Count > 0) then
              bolHasObj = true
          end if
        else
          bolHasObj = true
        end if
			end if
				
			if Err.number <> 0 then
				bolHasObj = false
			end if	
			
			Dim totaleProdottoImp4spese, totale_carrello, totale_qta_carrello
			totaleProdottoImp4spese = 0
			totale_carrello = 0
			totale_qta_carrello = 0
			
			if(bolHasObj) then
				Dim objTmpProdComplete, objSelProdotto, objListaFile, ProdottoCounter, iIndex 
				Dim objTmpProdotto, FromProdotto, ToProdotto, Diff
				Dim totaleProdottoImp, totaleProdottoTax, marginPercent, discountPercent
				Dim totMarginAmount, totDiscountAmount, singleMarginAmount, objListAllFieldxProd
        Dim urlRelProd, gerCatRelProd
        Set objCat = new CategoryClass
        Set objPageTempl = new Page4TemplateClass
        Set objTemplateRel = new TemplateClass
        Set objMenuFruizioneRel = new MenuClass
      
				objYmpKey = objListaCarrello.Keys

				'** inizializzo mappa dei field per prodotto selezionati				 
				Set objListAllFieldxProd = Server.CreateObject("Scripting.Dictionary")%>	
				
				<div id="carrello-lista"><%
					Dim counter_card ,descTassa, applyBills
					counter_card = 0
					totMarginAmount = 0
					totDiscountAmount = 0
					
					applyBills = false


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
              Set objTmpConcreteProd = Prodotto.findProdottoByID(objListaCarrello.item(k).getIDProd(),1)
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
            Set objSelProdotto = objListaCarrello.item(k)
            '*** se esistono delle business rules attive sui prodotti correlati cerco le configurazioni specifiche per ogni prodotto e aggiorno l'oggetto objListProd4Rule
            if(bolHasProdRelRule) then
              for each b in objProdRelRule
                On Error Resume Next
                'response.write("objProdRelRule(b): "&objProdRelRule(b).getLabel()&"<br>")
                Set objTmpResStrategy = objProdRelRule(b).getAmountByStrategy(null, null, objSelProdotto.getIDProd(), objListProd4Rule)
                Set objListProd4Rule = objTmpResStrategy.objListPRVO
                Set objTmpResStrategy = nothing
                if(Err.number <> 0) then
                end if 
              next
            end if              
          next
            
					for each k in objYmpKey
						Set objSelProdotto = objListaCarrello.item(k)
						'Set objTmpProdComplete = Prodotto.findProdottoByID(objSelProdotto.getIDProd(),1)
            Set objTmpProdComplete = objListUniqueConcreteProd(objSelProdotto.getIDProd())
						totaleProdottoImp = 0
						totaleProdottoTax = 0
						marginPercent = 0
						discountPercent = 0
						singleMarginAmount = 0

            if(hasGroup) then
              On Error Resume Next
              marginPercent = objSelMargin.getMargin()
              discountPercent = objSelMargin.getDiscountPercentual(CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objTmpProdComplete.getsconto()),CDbl(scontoCliente))
              totaleProdottoImp = CDbl(objTmpProdComplete.getPrezzo()) * objSelProdotto.getQtaProd()
              singleMarginAmount = objSelMargin.getMarginAmount(totaleProdottoImp,CDbl(objSelMargin.getMargin()))
              totMarginAmount = totMarginAmount + singleMarginAmount
              totDiscountAmount = totDiscountAmount + objSelMargin.getDiscountAmount(totaleProdottoImp,CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objTmpProdComplete.getsconto()),CDbl(scontoCliente))
              totaleProdottoImp = objSelMargin.getAmount(totaleProdottoImp,CDbl(objSelMargin.getMargin()),CDbl(objSelMargin.getDiscount()),objSelMargin.isApplyProdDiscount(),objSelMargin.isApplyUserDiscount(),CDbl(objTmpProdComplete.getsconto()),CDbl(scontoCliente))
              if(Err.number <>0) then
              end if	
            else          
              if(objTmpProdComplete.hasSconto() AND (not(hasSconto) OR (hasSconto AND Application("manage_sconti") = 1))) then
                totaleProdottoImp = CDbl(objTmpProdComplete.getPrezzoScontato()) * objSelProdotto.getQtaProd()
                discountPercent = CDbl(objTmpProdComplete.getsconto())
                if(hasSconto)then
                totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * scontoCliente)
                discountPercent = discountPercent+CDbl(scontoCliente)
                end if
              else
                totaleProdottoImp = CDbl(objTmpProdComplete.getPrezzo()) * objSelProdotto.getQtaProd()
                if(hasSconto)then
                totaleProdottoImp = totaleProdottoImp - (totaleProdottoImp / 100 * scontoCliente)
                discountPercent = CDbl(scontoCliente)
                end if
              end if
            end if            

            '*** se esistono delle business rules attive sui prodotti cerco le configurazioni specifiche per ogni prodotto e applico il risultato all'imponibile prodotto
            if(bolHasProdRule) then
              'response.write("totaleProdottoImp: "&totaleProdottoImp&"<br>")
              for each b in objProdRule
                On Error Resume Next
                'response.write("objProdRule(b): "&objProdRule(b).getLabel()&"<br>")
                Set objTmpResStrategy = objProdRule(b).getAmountByStrategy(null, null, objSelProdotto.getIDProd(), objListProd4Rule)
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
              '*** aggiungo il valore calcolato nella business strategy (> 0 solo se è una regola su prodotto correlato)
              totaleProdottoImp=totaleProdottoImp+CDbl(objListProd4Rule(objSelProdotto.getIDProd()).resultAmount)     
              'response.write("<br>objListProd4Rule(objSelProdotto.getIDProd()).resultAmount: "&objListProd4Rule(objSelProdotto.getIDProd()).resultAmount&"<br>")             	
            end if
                  
            '***********************************   INTERNAZIONALIZZAZIONE TASSE   ****************************
						descTassa = ""
            applyOrigTax = true
            if(Application("enable_international_tax_option")=1) AND (international_country_code<>"") then
              if(hasGroup AND (Instr(1, typename(groupClienteTax), "TaxsGroupClass", 1) > 0)) then
                On Error Resume Next
                ' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
                if(Cint(userIsCompanyClient)=1 AND groupClienteTax.isTaxExclusion(groupClienteTax.getID(), international_country_code,international_state_region_code))then
                  totaleProdottoTax = 0
                  descTassa = lang.getTranslated("frontend.prodotti.label.tax_excluded")							
                  applyOrigTax = false
                else
                  objRelatedTax = groupClienteTax.findRelatedTax(groupClienteTax.getID(), international_country_code,international_state_region_code)
                  if(not(isNull(objRelatedTax))) then
                    Set objTaxG = objTasse.findTassaByID(objRelatedTax)
                    totaleProdottoTax = groupClienteTax.getImportoTassa(totaleProdottoImp, objTaxG)
                    descTassa = objTaxG.getDescrizioneTassa()
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
				Set groupProdTax = objTmpProdComplete.getTaxGroupObj(objTmpProdComplete.getTaxGroup()) 
				if(Instr(1, typename(groupProdTax), "TaxsGroupClass", 1) > 0) then
          ' verifico se l'utente ha selezionato il flag tipologia cliente=società e se per il country/region selezionato il falg escludi tassa è attivo
          if(Cint(userIsCompanyClient)=1 AND groupProdTax.isTaxExclusion(groupProdTax.getID(), international_country_code,international_state_region_code))then
            totaleProdottoTax = 0
            descTassa = lang.getTranslated("frontend.prodotti.label.tax_excluded")							
            applyOrigTax = false
          else	
            objRelatedTax = groupProdTax.findRelatedTax(groupProdTax.getID(), international_country_code,international_state_region_code)				  
            if(not(isNull(objRelatedTax))) then
            Set objTaxG = objTasse.findTassaByID(objRelatedTax)
            totaleProdottoTax = groupProdTax.getImportoTassa(totaleProdottoImp, objTaxG)
            descTassa = objTaxG.getDescrizioneTassa()
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
              if not(isNull(objTmpProdComplete.getIDTassaApplicata())) AND not(objTmpProdComplete.getIDTassaApplicata() = "") then
                totaleProdottoTax = objTmpProdComplete.getImportoTassa(totaleProdottoImp)
                descTassa = objTasse.findTassaByID(objTmpProdComplete.getIDTassaApplicata()).getDescrizioneTassa()
              end if
            end if

		  if not(lang.getTranslated("portal.commons.order_taxs.label."&descTassa)="") then
			  descTassa = lang.getTranslated("portal.commons.order_taxs.label."&descTassa) 
		  end if
						
            if(descTassa<>"") then descTassa = "&nbsp;&nbsp;("&descTassa&")" end if             
				
					'************ se il prodotto non e' di tipo scaricabile e non ci sono regole di esclusione bills, aggiorno l'imponibile su cui verranno calcolate le spese di spedizione
					if (objTmpProdComplete.getProdType()=0 AND not(objListProd4Rule(objSelProdotto.getIDProd()).bolExcludeBills)) then
					  totaleProdottoImp4spese = totaleProdottoImp4spese+totaleProdottoImp
					  totale_qta_carrello=totale_qta_carrello+Cint(objSelProdotto.getQtaProd())
					  applyBills = true
					end if
            
						totale_carrello = totale_carrello+totaleProdottoImp+totaleProdottoTax
						%>
						<div>
						<form action="<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/ManageCarrello.asp"%>" method="post" name="form_carrello_<%=counter_card%>" id="form_carrello_<%=counter_card%>" enctype="multipart/form-data">	
						<input type="hidden" value="<%=objSelProdotto.getIDProd()%>" name="id_prodotto">	
						<input type="hidden" value="<%=objSelProdotto.getCounterProd()%>" name="counter_prod">	
						<input type="hidden" value="del" name="operation">
						<input type="hidden" value="<%=objSelProdotto.getQtaProd()%>" name="qta_prodotto">	
						<input type="hidden" value="" name="reset_qta">	
            <input type="hidden" value="<%=ref_id_ads%>" name="id_ads">
						<div id="prodotto-immagine">
							<%if (not(isNull(objTmpProdComplete.getFileXProdotto())) AND not(isEmpty(objTmpProdComplete.getFileXProdotto()))) then
								Dim hasNotSmallImg
								hasNotSmallImg = true
								Set objListaFilePerProdotto = objTmpProdComplete.getFileXProdotto()					
								for each xObjFile in objListaFilePerProdotto
									Set objFileXProdotto = objListaFilePerProdotto(xObjFile)
									iTypeFile = objFileXProdotto.getFileTypeLabel()
									if(Cint(iTypeFile) = 1) then%>	
										<img src="<%=Application("dir_upload_prod")&objFileXProdotto.getFilePath()%>" hspace="0" vspace="0" border="0" width="50" height="50" alt="<%=objTmpProdComplete.getNomeProdotto()%>" />
										<%hasNotSmallImg = false
										Exit for
									end if
									Set objFileXProdotto = nothing	
								next
								
								if(hasNotSmallImg) then%>
								<img width="50" height="50" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
								<%end if
								Set objListaFilePerProdotto = nothing		
							else%>
							<img width="50" height="50" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
							<%end if%>
						</div>
						<div id="prodotto-carrello">
              <%
							urlRelProd = "#"

              On Error Resume Next							
							gerCatRelProd = objTmpProdComplete.getGerCatProd4Relation(objSelProdotto.getIDProd())            
              Set objCategoriaRelTmp = objCat.findExsitingCategoriaByGerarchia(gerCatRelProd)
              if not(isNull(objCategoriaRelTmp)) then
                Set objTemplateSelectedRel = objTemplateRel.findTemplateByID(objCategoriaRelTmp.findLangTemplateXCategoria(lang.getLangCode(),true))
                numPageTempl = objPageTempl.getMaxNumPageByIDTemplate(objTemplateSelectedRel.getID()) 
                urlRelProd = objMenuFruizioneRel.resolveHrefUrl(base_url, numPageTempl, lang, objCategoriaRelTmp, objTemplateSelectedRel, objPageTempl)
                Set objTemplateSelectedRel = nothing
              else
                urlRelProd = "#"                  
              end if
              Set objCategoriaRelTmp = nothing
              if(Err.number <>0) then
                urlRelProd = "#"
              end if              
              %>
							<h2><a href="javascript:openRelatedProdPage('<%=urlRelProd%>', '<%=gerCatRelProd%>', <%=objSelProdotto.getIDProd()%>, <%=numPageTempl%>);"><%=objTmpProdComplete.findFieldTranslation(1 ,lang.getLangCode(),1)%></a></h2>
							
							<%
							if (Instr(1, typename(objProdField.findListFieldXCardByProd(objSelProdotto.getCounterProd(), id_carrello, objSelProdotto.getIDProd())), "Dictionary", 1) > 0) then
								Set fieldList4Card = objProdField.findListFieldXCardByProd(objSelProdotto.getCounterProd(), id_carrello, objSelProdotto.getIDProd())			
							
								if(fieldList4Card.count > 0)then
									if (objTmpProdComplete.getProdType()=0) then
										'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
										Set objDict = Server.CreateObject("Scripting.Dictionary")
										objListAllFieldxProd.add objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd(), objDict
									end if%>
									<p>											
									<%for each q in fieldList4Card
										
										Set objTmpField4Card = fieldList4Card(q)
										keys = objTmpField4Card.Keys
										
										for each r in keys
											Set tmpF4O = r
											if (objTmpProdComplete.getProdType()=0) then
												Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
												objDictFieldxProd.add "id", tmpF4O.getID()
												objDictFieldxProd.add "value", tmpF4O.getSelValue()
												objDictFieldxProd.add "qta", objSelProdotto.getQtaProd()
												objListAllFieldxProd(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()).add objDictFieldxProd, ""
												Set objDictFieldxProd = nothing
											end if

											labelTmp = ""
											labelTmp = tmpF4O.getDescription()
											if(Cint(tmpF4O.getTypeField())<>9)then
												valueTmp = Server.HTMLEncode(tmpF4O.getSelValue())
											else
												valueTmp = tmpF4O.getSelValue()
											end if
											if(Cint(tmpF4O.getTypeField())=8)then
												valueTmp = "<a href=""" & valueTmp & """ target=_blank>click</a>"
											end if
											if not(lang.getTranslated("frontend.prodotto.field.label."&tmpF4O.getDescription())="") then labelTmp = lang.getTranslated("frontend.prodotto.field.label."&tmpF4O.getDescription())
											response.write(labelTmp & ":&nbsp;" & valueTmp & "<br/>")%><input type="hidden" name="<%=objProdField.getFieldPrefix()&tmpF4O.getID()%>" value="<%=tmpF4O.getSelValue()%>">					
											<%Set tmpF4O = nothing
										next
										Set objTmpField4Card = nothing							
									next%>
									</p>
									<%Set objDict = nothing
								end if
								Set fieldList4Card = nothing
							end if
							
							'response.write("<b>field dictionary prima di aggiunta field prodotto:</b><br>")
							'for each f in objListAllFieldxProd
								'response.write("f: "&f&"<br>")
								'response.write("objListAllFieldxProd(f).count: "&objListAllFieldxProd(f).count&"<br>")
								'for each e in objListAllFieldxProd(f)
										'response.write("e.count: "&e.count&"<br>")
										'response.write("e(id): "&e("id")&"<br>")
										'response.write("e(value): "&e("value")&"<br>")
										'response.write("e(qta): "&e("qta")&"<br>")
								'next
							'next

							'************ aggiungo all'oggetto objListAllFieldxProd i field prodotto non modificabili di tipo int o double
							if (Instr(1, typename(objProdField.getListProductField4ProdActive(objSelProdotto.getIDProd())), "Dictionary", 1) > 0) then
								Set fieldList4CardH = objProdField.getListProductField4ProdActive(objSelProdotto.getIDProd())			
							
								if(fieldList4CardH.count > 0)then
									if (objTmpProdComplete.getProdType()=0) then
										'******** aggiungo alla mappa dei field per prodotto, da usare nella strategy delle spese accessorie
										Set objDict = Server.CreateObject("Scripting.Dictionary")
										if not(objListAllFieldxProd.Exists(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()))then
											objListAllFieldxProd.add objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd(), objDict
										end if

										'response.write("<b>recupero e aggiunta field prodotto:</b><br>")

										for each d in fieldList4CardH
											if((fieldList4CardH(d).getTypeContent()=2 OR fieldList4CardH(d).getTypeContent()=3) AND (fieldList4CardH(d).getEditable()=0))then
												Set objDictFieldxProd = Server.CreateObject("Scripting.Dictionary")
												objDictFieldxProd.add "id", fieldList4CardH(d).getID()
												objDictFieldxProd.add "value", fieldList4CardH(d).getSelValue()
												objDictFieldxProd.add "qta", objSelProdotto.getQtaProd()

												'response.write("objDictFieldxProd(id): "&objDictFieldxProd("id")&"<br>")
												'response.write("objDictFieldxProd(value): "&objDictFieldxProd("value")&"<br>")
												'response.write("objDictFieldxProd(qta): "&objDictFieldxProd("qta")&"<br>")
												'response.write("objListAllFieldxProd.count: "&objListAllFieldxProd.count&"<br>")
												'response.write("Exists: "& objListAllFieldxProd.Exists(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()) &"<br>")
												'response.write("count: "& objListAllFieldxProd(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()).count &"<br>")
												bolCanAdd = true
												On Error Resume Next
												for each i in objListAllFieldxProd(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd())
													'response.write(" - i(id): "&i("id")&" - list(id): "&objDictFieldxProd("id")&" - diversi: "& (Cint(i("id"))<>Cint(objDictFieldxProd("id"))) &"<br>")
													if(Cint(i("id"))=Cint(objDictFieldxProd("id")))then
														'response.write("esiste gi�l field associato a objListAllFieldxProd - id: "&objDictFieldxProd("id")&"<br>")
														bolCanAdd = false
														Exit for
													end if
												next

												if(bolCanAdd)then
													objListAllFieldxProd(objSelProdotto.getCounterProd()&"-"&objSelProdotto.getIDProd()).add objDictFieldxProd, ""
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
							%>							
							
							<p><strong><%=lang.getTranslated("frontend.carrello.table.label.quantita")%>: </strong>
              <%if(objTmpProdComplete.getEditBuyQta()<>"0")then%>
                <%'GESTISCO LA QUANTITA' SELEZIONABILE	
                if(objTmpProdComplete.getAttivo() = 1) then							
                  if(objTmpProdComplete.getQtaDisp() = Application("unlimited_key")) then%>
                    <input type="text" class="formFieldTXTSmall" name="qta_prodotto_change" value="<%=objSelProdotto.getQtaProd()%>" onkeypress="javascript:return isInteger(event);" onblur="javascript:changeQtaToCarrello(<%=objSelProdotto.getQtaProd()%>, document.form_carrello_<%=counter_card%>,-1,<%if(applyBills) then response.write("1") else response.write("0") end if%>);">
                  <%else%>
                    <input type="text" class="formFieldTXTSmall" name="qta_prodotto_change" value="<%=objSelProdotto.getQtaProd()%>" onkeypress="javascript:return isInteger(event);" onblur="javascript:changeQtaToCarrello(<%=objSelProdotto.getQtaProd()%>, document.form_carrello_<%=counter_card%>,<%=objTmpProdComplete.getQtaDisp()%>,<%if(applyBills) then response.write("1") else response.write("0") end if%>);">
                  <%end if
                end if
              else
                response.write(objSelProdotto.getQtaProd())
              end if%>             
              </p>
							
							<%
							'************ converto il prezzo in base alla valuta selezionata
							if(hasCurrency) then
								numPrezzoProd = currClass.convertCurrency(totaleProdottoImp+totaleProdottoTax, defCurrObj, Session("currency"))
                singleMarginAmount = currClass.convertCurrency(singleMarginAmount, defCurrObj, Session("currency"))
							else
								numPrezzoProd = totaleProdottoImp+totaleProdottoTax
							end if
							%>
							<p><strong><%=lang.getTranslated("frontend.carrello.table.label.totale")%>: </strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(numPrezzoProd, 2,-1)&descTassa%>
						  <%if ((hasGroup AND singleMarginAmount > 0) OR (discountPercent > 0) OR (objListProd4Rule(objSelProdotto.getIDProd()).counterProd=objSelProdotto.getCounterProd() AND objListProd4Rule(objSelProdotto.getIDProd()).listRelrulesLabel.count>0)) then%>&nbsp;<a href="javascript:showHideDiv('prod-commissions-<%=counter_card%>');">?</a><%end if%>
						  <div id="prod-commissions-<%=counter_card%>" style="<%if ((hasGroup AND singleMarginAmount > 0) OR (discountPercent > 0) OR (objListProd4Rule(objSelProdotto.getIDProd()).counterProd=objSelProdotto.getCounterProd() AND objListProd4Rule(objSelProdotto.getIDProd()).listRelrulesLabel.count>0)) then%>margin-bottom:3px;padding:10px;vertical-align:middle;text-align:left;font-size: 10px;text-decoration: none;border:0px solid;background:#FFFFFF;width:160px;left:-10px;top:0px;<%end if%>visibility:hidden;display:none;position:relative;">
							<%if (hasGroup AND singleMarginAmount > 0) then%>
							<%=lang.getTranslated("frontend.carrello.table.label.commissioni")%>: <%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(singleMarginAmount, 2,-1)%><%'="&nbsp;"&marginPercent&"%"%><br/>
							<%end if%>
							<%if (discountPercent > 0) then%>
							<%=lang.getTranslated("frontend.carrello.table.label.sconto_applicato")%>: <%=discountPercent&"%"%>
							<%end if%>
							<%if (objListProd4Rule(objSelProdotto.getIDProd()).counterProd=objSelProdotto.getCounterProd() AND objListProd4Rule(objSelProdotto.getIDProd()).listRelrulesLabel.count>0) then%>
                  <ul>
                  <%for each w in objListProd4Rule(objSelProdotto.getIDProd()).listRelrulesLabel
                    tmpLabel = Mid(w,InStr(1,w,"|",1)+1)                  
                    tmp_amount_rule = objListProd4Rule(objSelProdotto.getIDProd()).listRelrulesLabel(w)
                    if(hasCurrency) then
                      tmp_amount_rule = currClass.convertCurrency(tmp_amount_rule, defCurrObj, Session("currency"))
                    end if%>
                    <li><%if(lang.getTranslated("portal.commons.business_rule.label."&tmpLabel) <> "") then response.write(lang.getTranslated("portal.commons.business_rule.label."&tmpLabel)) else response.write(tmpLabel) end if%>:&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(tmp_amount_rule, 2,-1)%><br/>
							<%next%>
                  </ul>
              <%end if%>
						  </div>                
						  </p>
						</div>
						<div id="prodotto-cancella"><a href="javascript:delFromCarrello(document.form_carrello_<%=counter_card%>,<%if(applyBills) then response.write("1") else response.write("0") end if%>);"><span><%=lang.getTranslated("frontend.carrello.table.label.del_prod")%></span></a></div>
						<div id="clear"></div>
						<div id="prodotto-footer"></div>
						</form>									
						<%
            Set objTmpProdComplete = nothing
						Set objSelProdotto = nothing
						counter_card = counter_card +1%>
						</div>
					<%next            
          Set objCat = nothing
          Set objMenuFruizioneRel = nothing
          Set objTemplateRel = nothing
          Set objPageTempl = nothing            
          %>	


          <form action="" method="post" name="form_carrello_rel_prod">	
          <input type="hidden" value="" name="id_prodotto">	
          <input type="hidden" value="" name="modelPageNum">	
          <input type="hidden" value="" name="gerarchia">            
          </form>
            
					<div id="prodotto-conto">
						<div class="spese-div">
						<%
						if(hasCurrency) then
              totMarginAmount = currClass.convertCurrency(totMarginAmount, defCurrObj, Session("currency"))
              totDiscountAmount = currClass.convertCurrency(totDiscountAmount, defCurrObj, Session("currency"))
						end if %>           

            <%if (hasGroup) then%>
              <%if(totMarginAmount>0)then%><%=lang.getTranslated("frontend.carrello.table.label.totale_commissioni")%>:&nbsp;<strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(totMarginAmount, 2,-1)%></strong><br/><%end if%>
              <%if(totDiscountAmount>0)then%><%=lang.getTranslated("frontend.carrello.table.label.totale_sconti")%>:&nbsp;<strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(totDiscountAmount, 2,-1)%></strong><br/><%end if%>
              <br/>
            <%end if%>
          
            <%totale_carrello_old = totale_carrello
            '*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
            'response.write("totale_carrello before rule: "&totale_carrello&"<br>")
              
            if(hasOrderRule) then
              for each l in objOrderRule
                found_amount = objOrderRule(l).getAmountByStrategy(totale_carrello_old, objVoucher,null,null).foundAmount
                if(CDbl(found_amount)<>0)then
                  found_amount = FormatNumber(found_amount, 2,-1)
                  totale_carrello=totale_carrello+CDbl(found_amount)
                  if(hasCurrency) then
                    found_amount = currClass.convertCurrency(found_amount, defCurrObj, Session("currency"))
                  end if%>
                  <span class="rules"><%if(lang.getTranslated("portal.commons.business_rule.label."&objOrderRule(l).getLabel()) <> "") then response.write(lang.getTranslated("portal.commons.business_rule.label."&objOrderRule(l).getLabel())) else response.write(objOrderRule(l).getLabel()) end if%></span>:&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(found_amount, 2,-1)%><br/>
              <%end if
                next
            end if            
            
            
						'****************  RIVEDERE CALCOLI IMPONIBILE E TASSE PER SINGOLI PRODOTTI
						'****************  SPESE SPEDIZIONE E TOTALE
						totale_carrello = FormatNumber(totale_carrello, 2,-1)
							
						'************ converto il prezzo in base alla valuta selezionata
						if(hasCurrency) then
              totale_carrello_old = currClass.convertCurrency(totale_carrello_old, defCurrObj, Session("currency"))
							totale_carrello_tmp = currClass.convertCurrency(totale_carrello, defCurrObj, Session("currency"))
						else
							totale_carrello_tmp = totale_carrello
						end if%>
            <%=lang.getTranslated("frontend.carrello.table.label.totale_prodotti")%>:<!--<%'if(hasOrderRule)then%>&nbsp;<span class="testoBarrato"><%'if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%'=FormatNumber(totale_carrello_old, 2,-1)%></span><%'end if%>-->&nbsp;<strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(totale_carrello_tmp, 2,-1)%></strong>
						<br/>
            <%
            if not(hasGroup) then
              if(hasSconto) then
                response.write("<br/>"&lang.getTranslated("frontend.carrello.table.label.sconto_cliente") & ": " &  scontoCliente&" %")
              end if
                
                if(hasSconto AND Application("manage_sconti") = 0) then
                  response.write("<br/>"&lang.getTranslated("frontend.carrello.table.label.if_client_has_sconto")&"<br/><br/>")
                end if
            end if%>              
            </div>

        <%if(hasActiveVoucherCampaign)then%>        
       <div class="spese-div">
         <form action="<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp"%>" method="post" name="form_carrello_voucher">
        <input type="hidden" value="0" name="voucher_delete">
       <%if(voucher_message<>"")then
         response.write("<span class=error>"&voucher_message&"</span><br/>")
       end if%>
       <strong><%=lang.getTranslated("frontend.carrello.table.label.voucher_code")%></strong>&nbsp;<input type="text" id="voucher_code" name="voucher_code" value="<%=voucher_code%>">
       <input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(0);" value="<%=lang.getTranslated("frontend.carrello.table.label.insert_voucher")%>">&nbsp;<input class="buttonForm" vspace="4" type="button" hspace="2" border="0" align="absmiddle" onclick="javascript:insertVoucher(1);" value="<%=lang.getTranslated("frontend.carrello.table.label.delete_voucher")%>">   
       </form>
       </div>
        <%end if%>

			<%
				'for each q in objListAllFieldxProd
					'response.write("q: "&q&"<br>")
					'response.write("objListAllFieldxProd(q).count: "&objListAllFieldxProd(q).count&"<br>")
					'for each w in objListAllFieldxProd(q)
							'response.write("w.count: "&w.count&"<br>")
							'response.write("w(id): "&w("id")&"<br>")
							'response.write("w(value): "&w("value")&"<br>")
							'response.write("w(qta): "&w("qta")&"<br>")
					'next
				'next
			%>

			<form action="<%=Application("baseroot") &Application("dir_upload_templ")&"shopping-card/ProcessCarrello.asp"%>" method="post" name="form_insert_carrello">
      <input type="hidden" value="<%=ref_id_ads%>" name="id_ads" id="id_ads">
      <input type="hidden" value="<%=voucher_code%>" name="voucher_code">   
			<%
			On Error Resume Next
			Dim objBillsClass, totSpeseImp, totSpeseTax, totSpese
			Dim objListaSpeseXCarrello, objTmpSpesa, objTmpSpesaXCarrello
			Set objBillsClass = new BillsClass		
			Set objListaSpeseXCarrello = objBillsClass.getListaSpese(null, null, 1, null)
			totSpese = 0
			totSpeseAuto = 0
						
            if(applyBills) then%>
				<div class="spese-div">
				<strong id="titlebills4card"><%=lang.getTranslated("frontend.carrello.table.label.spese_spedizione")%>:<br/></strong> 
				<%
				oldGroupDesc = ""
 
				bolHasBills2charge = false
				bolHasBills2chargeInner = false
				Set objListHasBillsCharge = Server.CreateObject("Scripting.Dictionary")
           
              for each j in objListaSpeseXCarrello.Keys
                Set objTmpSpesaXCarrello = objListaSpeseXCarrello(j)
                totSpeseImp = 0
                totSpeseTax = 0

                if(oldGroupDesc<>objTmpSpesaXCarrello.getGroup())then 
                  if not(lang.getTranslated("portal.commons.order_bills.label.group."&objTmpSpesaXCarrello.getGroup())="") then response.write("<b id="&objTmpSpesaXCarrello.getGroup()&">"&lang.getTranslated("portal.commons.order_bills.label.group."&objTmpSpesaXCarrello.getGroup())&"<br/></b>") else response.write("<b id="&objTmpSpesaXCarrello.getGroup()&">"&objTmpSpesaXCarrello.getGroup()&"<br/></b>") end if	
				  bolHasBills2chargeInner = false
					objListHasBillsCharge.add objTmpSpesaXCarrello.getGroup(), bolHasBills2chargeInner
                end if

				'**** INTEGRO LA CHIAMATA PER RECUPERARE L'IMPONIBILE DELLA SPESA IN BASE ALLA STRATEGIA DEFINITA
				totSpeseImp = objTmpSpesaXCarrello.getImpByStrategy(totaleProdottoImp4spese, totale_qta_carrello, objListAllFieldxProd)                


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
                  

                '************ converto il prezzo in base alla valuta selezionata
                if(hasCurrency) then
                  totale_spese_tmp = currClass.convertCurrency(totSpeseImp+totSpeseTax, defCurrObj, Session("currency"))
                else
                  totale_spese_tmp = totSpeseImp+totSpeseTax
                end if
                
                 
                if(objTmpSpesaXCarrello.getAutoactive()=1)then
                  totSpese = totSpese+totSpeseImp+totSpeseTax
                  totSpeseAuto = totSpeseAuto+totSpeseImp+totSpeseTax                  

                  if not(lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())="") then response.write("&nbsp;"&lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())&"&nbsp;&nbsp;&nbsp;<strong>") else response.write("&nbsp;"&objTmpSpesaXCarrello.getDescrizioneSpesa()&"&nbsp;&nbsp;&nbsp;<strong>") end if
                  if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then 
                    response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) 
                  else 
                    response.write(Session("currency")) 
                  end if
                  response.write("&nbsp;"&FormatNumber(totale_spese_tmp,2,-1,-2,0)&"</strong><br>")                  
                else%>	
                  <%
				is_checked=false

				for each q in Split(Trim(request(objTmpSpesaXCarrello.getGroup())),",")
					if(Cint(Trim(q))=j) then
						is_checked=true
						exit for
					end if
				next
				'ciclo sulla sessione per recuperare la selezione dell'utente
				for each q in Split(Trim(Session(objTmpSpesaXCarrello.getGroup())),",")
					if(Cint(Trim(q))=j) then
						is_checked=true
						exit for
					end if
				next
				if(objTmpSpesaXCarrello.getMultiply()=1 AND (totale_spese_tmp>0 OR objTmpSpesaXCarrello.getTypeView()=1))then%>
                    <input type="checkbox" onclick="javascript:ajaxSetSessionPayAndBills(this),calculateBills4Order('<%=Cdbl(totale_carrello)+Cdbl(totSpeseAuto)%>','<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%if(Trim(Session("currency")) <> "") then response.write(currClass.findCurrencyByCurrency(Session("currency")).getRate()) else response.write(currClass.findCurrencyByCurrency(defCurrObj).getRate()) end if%>');" name="<%=objTmpSpesaXCarrello.getGroup()%>" id="<%=objTmpSpesaXCarrello.getGroup()&"-"&j&"-"&objTmpSpesaXCarrello.getRequired()%>" value="<%=j%>" <%if(is_checked)then response.write(" checked='checked'") end if%>/> <%if not(lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())="") then response.write(lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())) else response.write(objTmpSpesaXCarrello.getDescrizioneSpesa()) end if%>&nbsp;&nbsp;&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(totale_spese_tmp,2,-1)%>&nbsp;&nbsp;<BR>
                  <%elseif(objTmpSpesaXCarrello.getMultiply()<>1 AND totale_spese_tmp>0)then%>
                    <input type="radio"  onclick="javascript:ajaxSetSessionPayAndBills(this),calculateBills4Order('<%=Cdbl(totale_carrello)+Cdbl(totSpeseAuto)%>','<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%if(Trim(Session("currency")) <> "") then response.write(currClass.findCurrencyByCurrency(Session("currency")).getRate()) else response.write(currClass.findCurrencyByCurrency(defCurrObj).getRate()) end if%>');" name="<%=objTmpSpesaXCarrello.getGroup()%>" id="<%=objTmpSpesaXCarrello.getGroup()&"-"&j&"-"&objTmpSpesaXCarrello.getRequired()%>" value="<%=j%>" <%if(is_checked)then response.write(" checked='checked'") end if%>/> <%if not(lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())="") then response.write(lang.getTranslated("portal.commons.order_bills.label."&objTmpSpesaXCarrello.getDescrizioneSpesa())) else response.write(objTmpSpesaXCarrello.getDescrizioneSpesa()) end if%>&nbsp;&nbsp;&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<%=FormatNumber(totale_spese_tmp,2,-1)%>&nbsp;&nbsp;<BR>					
                  <%end if%>

                  <script language="Javascript">
					<%if(is_checked)then%>
					jQuery(document).ready(function(){
					 calculateBills4Order('<%=Cdbl(totale_carrello)+Cdbl(totSpeseAuto)%>','<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%if(Trim(Session("currency")) <> "") then response.write(currClass.findCurrencyByCurrency(Session("currency")).getRate()) else response.write(currClass.findCurrencyByCurrency(defCurrObj).getRate()) end if%>');
				    });
					<%end if
           
				if(totale_spese_tmp>0 OR objTmpSpesaXCarrello.getTypeView()=1)then%>
            listBills4Order.put("<%=objTmpSpesaXCarrello.getGroup()&"-"&j&"-"&objTmpSpesaXCarrello.getRequired()%>","<%=CDbl(totSpeseImp)+CDbl(totSpeseTax)%>");
					<%bolHasBills2charge = true
response.write("//bolHasBills2charge: "&bolHasBills2charge)
					if not(bolHasBills2chargeInner)then
						bolHasBills2chargeInner=true
            ' commento vecchio modo per modificare valore esistente, uso invece il metodo obj.Item("key") = "value"
						'objListHasBillsCharge.remove(objTmpSpesaXCarrello.getGroup())
						'objListHasBillsCharge.add objTmpSpesaXCarrello.getGroup(), bolHasBills2chargeInner
            objListHasBillsCharge.Item(objTmpSpesaXCarrello.getGroup()) = bolHasBills2chargeInner
response.write("//objListHasBillsCharge: "&objListHasBillsCharge(objTmpSpesaXCarrello.getGroup())&" - bolHasBills2chargeInner: "&bolHasBills2chargeInner)
					end if
				end if
				%>

                </script>                  
                <%end if
                  
                oldGroupDesc = objTmpSpesaXCarrello.getGroup()
                Set objTmpSpesaXCarrello = nothing
              next%>
            </div>
				<script language="Javascript">
				jQuery(document).ready(function(){
					<%if not(bolHasBills2charge)then%>
						$("#titlebills4card").hide(); 
					<%end if%>
					<%
					for each l in objListHasBillsCharge
						if not(objListHasBillsCharge(l))then%>
							$("#<%=l%>").hide();
						<%end if
					next
					%>
				});
				</script> 
				<%
				Set objListHasBillsCharge = nothing
				Set objListAllFieldxProd = nothing
			end if
						
			Set objListaSpeseXCarrello = nothing
			Set objBillsClass = nothing
			
			If Err.Number<>0 then
			end if
			%>
						
            <div class="spese-div">
						<input type="hidden" value="<%=id_carrello%>" name="id_carrello">
						  <strong><%=lang.getTranslated("frontend.carrello.table.label.tipo_pagam_order")%>:</strong><br>	
						  <div id="payment_list">
						  <%
               On Error Resume Next
						   Dim objPayment, objTmpPayment, objListaPayment, objModuloPayment, objModulo, strLogo, loadDirectPayment		   
               loadDirectPayment = null
               if((totSpese+totale_carrello)<=0) then
                loadDirectPayment = 0
               end if
						   Set objPayment = New PaymentClass
						   Set objModulo = new PaymentModuleClass					   
						   Set objListaPayment = objPayment.getListaPayment(1,loadDirectPayment)
              if not(isEmpty(objListaPayment)) AND (Instr(1, typename(objListaPayment), "Dictionary", 1) > 0) then%>

						<script language="Javascript">
						<%for each k in objListaPayment.Keys%>
						listPaymentMethods.put("<%=k%>","<%=objListaPayment(k).getCommission()&"|"&objListaPayment(k).getCommissionType()%>");	
						<%next%>
						</script>
						<ul>
						  <%for each k in objListaPayment.Keys
							strLogo = ""
							if(Cint(objListaPayment(k).getPaymentModuleID()) <> -1) then
								Set objModuloPayment = objModulo.findPaymentModuloByID(objListaPayment(k).getPaymentModuleID())
								strLogo = objModuloPayment.getLogo()
								Set objModuloPayment = nothing
							end if
							is_checked=false

							for each q in Split(Trim(request("tipo_pagam")),",")
								if(Cint(Trim(q))=k) then
									is_checked=true
									exit for
								end if
							next
							'ciclo sulla sessione per recuperare la selezione dell'utente
							for each q in Split(Trim(Session("tipo_pagam")),",")
								if(Cint(Trim(q))=k) then
									is_checked=true
									exit for
								end if
							next%>
								<li><INPUT type="radio" name="tipo_pagam" value="<%=k%>" <%if(is_checked)then response.write(" checked='checked'") end if%> onclick="javascript:ajaxSetSessionPayAndBills(this),calculatePaymentCommission('<%=Cdbl(totale_carrello)+Cdbl(totSpeseAuto)%>',<%=k%>,'<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%=currClass.findCurrencyByCurrency(Session("currency")).getRate()%>');"> <%=lang.getTranslated(objListaPayment(k).getKeywordMultilingua())%>&nbsp;<%=strLogo%></li>
								<%if(is_checked)then%>
								<script language="Javascript">
								jQuery(document).ready(function(){
								calculatePaymentCommission('<%=Cdbl(totale_carrello)+Cdbl(totSpeseAuto)%>',<%=k%>,'<%=currClass.findCurrencyByCurrency(defCurrObj).getRate()%>','<%=currClass.findCurrencyByCurrency(Session("currency")).getRate()%>');
								});
								</script>
								<%end if%>
						  <%next%>
						</ul>
              <%end if						  
						  
			   Set objModulo = nothing
			   Set objListaPayment = nothing
			   Set objPayment = nothing
              
              If Err.Number<>0 then'
              end if
						  %>
            </div>              
						</div>
						<%
						'************ converto il prezzo in base alla valuta selezionata
						if(hasCurrency) then
							totale_spese_all = currClass.convertCurrency(totSpese+totale_carrello, defCurrObj, Session("currency"))
						else
							totale_spese_all = totSpese+totale_carrello
						end if
						%>   

            <%' *****************************************************		
              ' INIZIO: CODICE GESTIONE ACQUISTO SENZA REGISTRAZIONE
			  ' quando l'utente non 柧i�oggato, quindi non registrato, presento l'opzione per acquistare senza 
              ' registrazione; impostando il campo per l'email e i campi creati per la registrazione utente
              ' e utilizzando id session per username e password

			if(isEmpty(Session("objUtenteLogged")))then%>
				<div class="spese-div">
					<strong><%=lang.getTranslated("frontend.carrello.table.label.buy_noreg")%></strong><br/>
					<select name="buy_noreg" id="buy_noreg">
					  <OPTION VALUE="0" <%if(request("buy_noreg")=0)then response.write("selected") end if%>><%=lang.getTranslated("portal.commons.no")%></OPTION>
					  <OPTION VALUE="1" <%if(request("buy_noreg")=1)then response.write("selected") end if%>><%=lang.getTranslated("portal.commons.yes")%></OPTION>
					</select>
					
					<div id="show_buy_noreg">
					<ul>
					<li><span><%=lang.getTranslated("frontend.area_user.manage.label.email")%> (*)</span></li>
					<li><input type="text" name="noreg_email" id="noreg_email" value="<%=noreg_email%>"/></li><br/>
					</ul>
					
				   <!--******** GESTIONE FIELDS UTENTE PERSONALIZZATI ********-->
			
					<%
					'********** RECUPERO LA LISTA DI FIELD UTENTE DISPONIBILI
					Dim strPrecFieldgroup, strFieldgroup               
					strPrecFieldgroup = ""
							
					On Error Resume next
					Dim userFieldcount, fieldCssClass
					userFieldcount =1
					if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then
					  for each k in objListUserField
						Set objField = objListUserField(k)
						fieldCssClass=""
					  
						  if(CInt(objField.getTypeField())=5) then
							fieldCssClass="formFieldMultiple"
						  end if
						  
						  labelForm = objField.getDescription()
						  if not(lang.getTranslated("frontend.area_user.manage.label."&objField.getDescription())="") then labelForm = lang.getTranslated("frontend.area_user.manage.label."&objField.getDescription())
					  
						if(userFieldcount=1) then
						  strFieldgroup = objField.getObjGroup().getDescription()
						  strPrecFieldgroup = strFieldgroup%>
						  <h2><%if not(lang.getTranslated("frontend.area_user.manage.label.group."&strFieldgroup)="") then response.write(lang.getTranslated("frontend.area_user.manage.label.group."&strFieldgroup)) else response.write(strFieldgroup) end if%></h2>
						  <ul>
						  <li><span><%=labelForm%><%if(CInt(objField.getRequired())=1) then response.write("&nbsp;(*)")%></span></li>
						  <li><%=objUserField.renderUserFieldHTML(objField,fieldCssClass, id_utente, labelForm,lang)%></li><br>
					  <%else
							strFieldgroup = objField.getObjGroup().getDescription()
							if(strFieldgroup = strPrecFieldgroup) then%>
							  <li><span><%=labelForm%><%if(CInt(objField.getRequired())=1) then response.write("&nbsp;(*)")%></span></li>
							  <li><%=objUserField.renderUserFieldHTML(objField,fieldCssClass, id_utente, labelForm,lang)%></li><br>                
							<%else%>
							  </ul>
							  <h2><%if not(lang.getTranslated("frontend.area_user.manage.label.group."&strFieldgroup)="") then response.write(lang.getTranslated("frontend.area_user.manage.label.group."&strFieldgroup)) else response.write(strFieldgroup) end if%></h2>
							  <ul>
							  <li><span><%=labelForm%><%if(CInt(objField.getRequired())=1) then response.write("&nbsp;(*)")%></span></li>
							  <li><%=objUserField.renderUserFieldHTML(objField,fieldCssClass, id_utente, labelForm,lang)%></li><br>                
							<%strPrecFieldgroup = strFieldgroup
							  end if              
						  end if
							  
						  if(userFieldcount = objListUserField.Count) then response.write("</ul>") end if
							
						userFieldcount=userFieldcount+1
					  next
					end if
			
					if(Err.number<>0) then
					'response.write(Err.description)
					end if        
				  %>
				  <!--******** FINE GESTIONE FIELDS UTENTE PERSONALIZZATI ********-->  					
					</div>				
				</div>
	
				<script>
					<%if(request("buy_noreg") <> "" AND request("buy_noreg")=1)then%>
					$("#show_buy_noreg").show();
					<%else%>
					$("#show_buy_noreg").hide();
					<%end if%>

					$('#buy_noreg').change(function() {
						var val_buy_noreg = $('#buy_noreg').val();
		
						if(val_buy_noreg==1){
							$("#show_buy_noreg").show();

							<%if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) then
								if (applyBills) OR (Application("enable_international_tax_option") = 1) then%>
									$("#card_shipping_address").show();
								<%end if%>		
							<%end if%>
							<%if(Application("show_bills_box") = 1) then%>
								$("#card_bills_address").show();			
							<%end if%>                
						}else{
							$("#show_buy_noreg").hide();

							if ($("#card_shipping_address").length > 0){
								$("#card_shipping_address").hide();
							}
							if ($("#card_shipping_address").length > 0){
								$("#card_bills_address").hide();	
							}
						}
					});
				</script>
			<%else%>
			<input type="hidden" value="0" name="buy_noreg" id="buy_noreg">
			<%end if%>

            <%
			  Dim objCountry 
			  Set objCountry = New CountryClass

              ' *****************************************************		
              ' INIZIO: CODICE GESTIONE SHIPPING ADDRESS
              ' SE L'UTENTE NON E' IN SESSIONE NON PRESENTO NESSUN DATO%>

              <div class="spese-div" id="card_shipping_address">
              <div align="left" onClick="javascript:showHideDiv('divShipCost')"><strong>
			  <%if(Application("enable_international_tax_option") = 1 AND not(applyBills))then%>
			  <%=lang.getTranslated("frontend.carrello.table.label.shipping_address_international_tax")%>
			  <%else%>
			  <%=lang.getTranslated("frontend.carrello.table.label.shipping_address")%>
			  <%end if%>
			  </strong>:<img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=lang.getTranslated("frontend.carrello.table.label.change_ship_address")%>"><br/>
              <%if(hasShipAddress)then
              if(Cint(userIsCompanyClient)=0) then
                userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private")
              else
                userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company")
              end if              
              response.write(userName & " " & userSurname & " ("&userLabelIsCompanyClient&") - " & userCfiscVat & " - " &userAddress &" - "&userCity&" ("&userZipCode&") - "&lang.getTranslated("portal.commons.select.option.country."&userCountry)&userStateRegionLabel)
              end if%>
              </div>
              <div id="divShipCost"  <%if not(hasShipAddress)then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
                <br/><div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.name")%></strong><br>
                <input type="text" id="ship_name" name="ship_name" value="<%=userName%>"></div>
                <div><strong><%=lang.getTranslated("frontend.carrello.table.label.surname")%></strong><br>
                <input type="text" id="ship_surname" name="ship_surname" value="<%=userSurname%>"></div>
                <div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.address")%></strong><br>
                <input type="text" id="ship_address" name="ship_address" value="<%=userAddress%>"></div>
                <div><strong><%=lang.getTranslated("frontend.carrello.table.label.zip_code")%></strong><br>
                <input type="text" id="ship_zip_code" name="ship_zip_code" value="<%=userZipCode%>"></div>
                <div>
                <strong><%=lang.getTranslated("frontend.carrello.table.label.city")%></strong><br>
                <input type="text" id="ship_city" name="ship_city" value="<%=userCity%>"></div>

                <div style="float:left;padding-right:3px;">
                <strong><%=lang.getTranslated("frontend.carrello.table.label.country")%></strong><br>
                <select id="ship_country" name="ship_country">
                <option value=""></option>
                <%On Error Resume next
                Set specialFieldValue = objCountry.findCountryListOnly("2,3")	
                if (Instr(1, typename(specialFieldValue), "Dictionary", 1) > 0) then		    
                for each x in specialFieldValue
                  key =  specialFieldValue(x).getCountryCode()
                  selected = ""
                  if (strComp(key, userCountry, 1) = 0) then selected=" selected" end if%>
                  <option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(lang.getTranslated("portal.commons.select.option.country."&key))%></option>     
                <%next
                end if
                Set specialFieldValue = nothing
                if(Err.number<>0) then
                end if%>
                </select> 
                </div>
              <div style="padding-bottom:10px;"><strong><%=lang.getTranslated("frontend.carrello.table.label.state_region")%></strong><br>	 
                <select name="ship_state_region" id="ship_state_region">
                <option value=""></option>
                <%
                if(userCountry<>"")then
                  On Error Resume next
                  Set specialFieldValueSR = objCountry.findStateRegionListByCountry(userCountry,"2,3")			
                  if (Instr(1, typename(specialFieldValueSR), "Dictionary", 1) > 0) then		    
                  for each x in specialFieldValueSR
                    key =  specialFieldValueSR(x).getStateRegionCode()
                    selected = ""
                    if (strComp(key, userStateRegion, 1) = 0) then selected=" selected" end if%>
                    <option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(lang.getTranslated("portal.commons.select.option.country."&key))%></option>     
                  <%next
                  end if
                  Set specialFieldValueSR = nothing
                  if(Err.number<>0) then
                  end if
                end if%>
                </select>	
                </div>

                <div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.cfiscvat")%></strong><br>
                <input type="text" id="ship_cfiscvat" name="ship_cfiscvat" value="<%=userCfiscVat%>"></div>
                <div><strong><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company_client")%></strong><br>
                <select name="ship_is_company_client" id="ship_is_company_client">
                <option value="0" <%if (Cint(userIsCompanyClient) = 0) then response.Write("selected")%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_private")%></option>
                <option value="1" <%if (Cint(userIsCompanyClient) = 1) then response.Write("selected")%>><%=lang.getTranslated("frontend.utenti.detail.table.label.is_company")%></option>
                </select></div>
				<script>
				// se 柳tata modificato country al refresh ripristino i valori dei campi utente personalizzati
				<%
				if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then%>
					$(document).ready(function() {
					<%for each k in objListUserField
						Set objField = objListUserField(k)

						select Case objField.getTypeField()
						Case 6,7%>
							var fieldTmp = document.form_insert_carrello.<%=objUserField.getFieldPrefix()&objField.getID()%>;
							var fieldTmpVal = "<%=request(objUserField.getFieldPrefix()&objField.getID())%>";

							if (fieldTmp){
								if(fieldTmp != null){
									var splittedVals = fieldTmpVal.split(",");
									if(fieldTmp.length == null){
										for (var j=0; j < splittedVals.length; j++){
											if (fieldTmp.value==splittedVals[j]){
												fieldTmp.checked=true;
												break;
											}
										}
									}else{
										for (var i=0; i < fieldTmp.length; i++){
											for (var j=0; j < splittedVals.length; j++){
												if (fieldTmp[i].value==splittedVals[j]){
													fieldTmp[i].checked=true;
												}
											}
										}
									}
								}
							}
						<%Case Else%>
							$('#<%=objUserField.getFieldPrefix()&objField.getID()%>').val('<%=request(objUserField.getFieldPrefix()&objField.getID())%>');			
						<%End Select%>
			
						<%Set objField = nothing
					next%>
					});
				<%end if

				if(Application("enable_international_tax_option") = 1) then%>	

				$('#ship_country').change(function() {
					$('#prodotto-totale').hide();					

					var query_string = "?ship_country="+escape($('#ship_country').val())
					query_string+="&ship_state_region="
					query_string+="&buy_noreg="+escape($('#buy_noreg').val());

					query_string+="&noreg_email="+escape($('#noreg_email').val());
        
					query_string+="&id_ads="+escape($('#id_ads').val());

					query_string+="&ship_name="+escape($('#ship_name').val());
					query_string+="&ship_surname="+escape($('#ship_surname').val());
					query_string+="&ship_cfiscvat="+escape($('#ship_cfiscvat').val());
					query_string+="&ship_address="+escape($('#ship_address').val());
					query_string+="&ship_zip_code="+escape($('#ship_zip_code').val());
					query_string+="&ship_city="+escape($('#ship_city').val());
					query_string+="&ship_is_company_client="+escape($('#ship_is_company_client').val());

					<%if(Application("show_bills_box") = 1)then%>
					query_string+="&bills_name="+escape($('#bills_name').val());
					query_string+="&bills_surname="+escape($('#bills_surname').val());
					query_string+="&bills_cfiscvat="+escape($('#bills_cfiscvat').val());
					query_string+="&bills_address="+escape($('#bills_address').val());
					query_string+="&bills_zip_code="+escape($('#bills_zip_code').val());
					query_string+="&bills_city="+escape($('#bills_city').val());
					query_string+="&bills_country="+escape($('#bills_country').val());
					query_string+="&bills_state_region="+escape($('#bills_state_region').val());
					<%end if

					if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then
						for each k in objListUserField
							Set objField = objListUserField(k)

							select Case objField.getTypeField()
							Case 6,7%>
								var fieldTmpS = document.form_insert_carrello.<%=objUserField.getFieldPrefix()&objField.getID()%>;
								var fieldTmpValS = "";
								if (fieldTmpS){
									if(fieldTmpS != null){
										if(fieldTmpS.length == null){
											if (fieldTmpS.checked){
												fieldTmpValS = fieldTmpValS + fieldTmpS.value + ",";
											}
										}else{
											for (var i=0; i < fieldTmpS.length; i++){
												if (fieldTmpS[i].checked){
													fieldTmpValS = fieldTmpValS + fieldTmpS[i].value + ",";
												}
											}
										}
										fieldTmpValS = fieldTmpValS.substring(0, fieldTmpValS.lastIndexOf(','));
									}
								}
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape(fieldTmpValS);	
							<%Case Else%>
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape($('#<%=objUserField.getFieldPrefix()&objField.getID()%>').val());				
							<%End Select%>					
							<%Set objField = nothing
						next
					end if
					%>

					query_string+=selectPayAndBills4Form(<%if(applyBills) then response.write("1") else response.write("0") end if%>);

					var url = '<%=Application("baseroot") &Application("dir_upload_templ")&"shopping-card/card.asp"%>'+query_string;

					window.location.href = url;
				});

				$('#ship_state_region').change(function() {
					$('#prodotto-totale').hide();

					var query_string = "?ship_country="+escape($('#ship_country').val())
					query_string+="&ship_state_region="+escape($('#ship_state_region').val())
					query_string+="&buy_noreg="+escape($('#buy_noreg').val());

					query_string+="&noreg_email="+escape($('#noreg_email').val());
          
					query_string+="&id_ads="+escape($('#id_ads').val());

					query_string+="&ship_name="+escape($('#ship_name').val());
					query_string+="&ship_surname="+escape($('#ship_surname').val());
					query_string+="&ship_cfiscvat="+escape($('#ship_cfiscvat').val());
					query_string+="&ship_address="+escape($('#ship_address').val());
					query_string+="&ship_zip_code="+escape($('#ship_zip_code').val());
					query_string+="&ship_city="+escape($('#ship_city').val());
					query_string+="&ship_is_company_client="+escape($('#ship_is_company_client').val());

					<%if(Application("show_bills_box") = 1)then%>
					query_string+="&bills_name="+escape($('#bills_name').val());
					query_string+="&bills_surname="+escape($('#bills_surname').val());
					query_string+="&bills_cfiscvat="+escape($('#bills_cfiscvat').val());
					query_string+="&bills_address="+escape($('#bills_address').val());
					query_string+="&bills_zip_code="+escape($('#bills_zip_code').val());
					query_string+="&bills_city="+escape($('#bills_city').val());
					query_string+="&bills_country="+escape($('#bills_country').val());
					query_string+="&bills_state_region="+escape($('#bills_state_region').val());
					<%end if
					
					if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then
						for each k in objListUserField
							Set objField = objListUserField(k)							

							select Case objField.getTypeField()
							Case 6,7%>
								var fieldTmpB = document.form_insert_carrello.<%=objUserField.getFieldPrefix()&objField.getID()%>;
								var fieldTmpValB = "";
								if (fieldTmpB){
									if(fieldTmpB != null){
										if(fieldTmpB.length == null){
											if (fieldTmpB.checked){
												fieldTmpValB = fieldTmpValB + fieldTmpB.value + ",";
											}
										}else{
											for (var i=0; i < fieldTmpB.length; i++){
												if (fieldTmpB[i].checked){
													fieldTmpValB = fieldTmpValB + fieldTmpB[i].value + ",";
												}
											}
										}
										fieldTmpValB = fieldTmpValB.substring(0, fieldTmpValB.lastIndexOf(','));
									}
								}
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape(fieldTmpValB);	
							<%Case Else%>
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape($('#<%=objUserField.getFieldPrefix()&objField.getID()%>').val());				
							<%End Select%>					
							<%Set objField = nothing
						next
					end if
					%>
					query_string+=selectPayAndBills4Form(<%if(applyBills) then response.write("1") else response.write("0") end if%>);
					var url = '<%=Application("baseroot") &Application("dir_upload_templ")&"shopping-card/card.asp"%>'+query_string;

					window.location.href = url;
				});

				$('#ship_is_company_client').change(function() {
					$('#prodotto-totale').hide();

					var query_string = "?ship_country="+escape($('#ship_country').val())
					query_string+="&ship_state_region="+escape($('#ship_state_region').val())
					query_string+="&buy_noreg="+escape($('#buy_noreg').val());

					query_string+="&noreg_email="+escape($('#noreg_email').val());
          
					query_string+="&id_ads="+escape($('#id_ads').val());

					query_string+="&ship_name="+escape($('#ship_name').val());
					query_string+="&ship_surname="+escape($('#ship_surname').val());
					query_string+="&ship_cfiscvat="+escape($('#ship_cfiscvat').val());
					query_string+="&ship_address="+escape($('#ship_address').val());
					query_string+="&ship_zip_code="+escape($('#ship_zip_code').val());
					query_string+="&ship_city="+escape($('#ship_city').val());
					query_string+="&ship_is_company_client="+escape($('#ship_is_company_client').val());

					<%if(Application("show_bills_box") = 1)then%>
					query_string+="&bills_name="+escape($('#bills_name').val());
					query_string+="&bills_surname="+escape($('#bills_surname').val());
					query_string+="&bills_cfiscvat="+escape($('#bills_cfiscvat').val());
					query_string+="&bills_address="+escape($('#bills_address').val());
					query_string+="&bills_zip_code="+escape($('#bills_zip_code').val());
					query_string+="&bills_city="+escape($('#bills_city').val());
					query_string+="&bills_country="+escape($('#bills_country').val());
					query_string+="&bills_state_region="+escape($('#bills_state_region').val());
					<%end if
					
					if(hasUserFields AND Application("show_user_field_on_direct_buy") = 1) then
						for each k in objListUserField
							Set objField = objListUserField(k)							

							select Case objField.getTypeField()
							Case 6,7%>
								var fieldTmpB = document.form_insert_carrello.<%=objUserField.getFieldPrefix()&objField.getID()%>;
								var fieldTmpValB = "";
								if (fieldTmpB){
									if(fieldTmpB != null){
										if(fieldTmpB.length == null){
											if (fieldTmpB.checked){
												fieldTmpValB = fieldTmpValB + fieldTmpB.value + ",";
											}
										}else{
											for (var i=0; i < fieldTmpB.length; i++){
												if (fieldTmpB[i].checked){
													fieldTmpValB = fieldTmpValB + fieldTmpB[i].value + ",";
												}
											}
										}
										fieldTmpValB = fieldTmpValB.substring(0, fieldTmpValB.lastIndexOf(','));
									}
								}
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape(fieldTmpValB);	
							<%Case Else%>
								query_string+="&<%=objUserField.getFieldPrefix()&objField.getID()%>="+escape($('#<%=objUserField.getFieldPrefix()&objField.getID()%>').val());				
							<%End Select%>					
							<%Set objField = nothing
						next
					end if
					%>
					query_string+=selectPayAndBills4Form(<%if(applyBills) then response.write("1") else response.write("0") end if%>);
					var url = '<%=Application("baseroot") &Application("dir_upload_templ")&"shopping-card/card.asp"%>'+query_string;

					window.location.href = url;
				});
				
				<%else%>

				$('#ship_country').change(function() {
					var type_val_ch = $('#ship_country').val();
					var query_string = "field_val="+escape(type_val_ch);
					query_string+=selectPayAndBills4Form(<%if(applyBills) then response.write("1") else response.write("0") end if%>);

					$.ajax({
						async: true,
						type: "GET",
						cache: false,
						url: "<%=Application("baseroot") & "/common/include/ajaxstateregionlistupdate.asp"%>",
						data: query_string,
						success: function(response) {
							//alert("response: "+response);
							$("select#ship_state_region").empty();
							$("select#ship_state_region").append($("<option></option>").attr("value","").text(""));
							$("select#ship_state_region").append(response);
						},
						error: function() {
							$("select#ship_state_region").empty();
							$("select#ship_state_region").append($("<option></option>").attr("value","").text(""));
						}
					});		
				});
				<%end if%>
				</script>
              </div>            
            </div>
	
			<script>
				$("#card_shipping_address").hide();

				<%if(Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1) OR (request("buy_noreg") = 1 AND ((Application("show_ship_box") = 1) OR (Application("enable_international_tax_option") = 1))) then
					if ((not(isEmpty(Session("objUtenteLogged"))) OR (request("buy_noreg") = 1))  AND (applyBills)) OR (Application("enable_international_tax_option") = 1 AND request("buy_noreg") = 1) OR (Application("enable_international_tax_option") = 1 AND not(isEmpty(Session("objUtenteLogged")))) then%>
						$("#card_shipping_address").show();
					<%end if
				end if%>
			</script>


            <%			
			  Set objListUserField = nothing
			  Set objUserField = nothing

			  ' *****************************************************		
              ' INIZIO: CODICE GESTIONE BILLS ADDRESS
              ' SE L'UTENTE NON E' IN SESSIONE NON PRESENTO NESSUN DATO
              '*** 柮ecessario che sia sempre visibile, anche per gli ordini con prodotti solo scaricabili;
              '*** senza i dati di fatturazione non si riesce a generare una fattura fiscalmente valida%>

              <div class="spese-div" id="card_bills_address">
              <div align="left" onClick="javascript:showHideDiv('divBillsCost')"><strong><%=lang.getTranslated("frontend.carrello.table.label.bills_address")%></strong>:<img src=<%=Application("baseroot")&"/common/img/refresh.gif"%> vspace="0" hspace="4" width="12" height="16" border="0" align="absmiddle" title="<%=lang.getTranslated("frontend.carrello.table.label.change_bills_address")%>"><br/>
              <%if(hasBillsAddress)then
              response.write(buserName & " " & buserSurname & " - " & buserCfiscVat & " - " &buserAddress &" - "&buserCity&" ("&buserZipCode&") - "&lang.getTranslated("portal.commons.select.option.country."&buserCountry)&buserStateRegionLabel)
              end if%>
              </div>
              <div id="divBillsCost"  <%if not(hasBillsAddress)then response.Write("style=""visibility:visible;display:block;""") else response.Write("style=""visibility:hidden;display:none;""") end if%> align="left">
                <br/><div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.name")%></strong><br>
                <input type="text" id="bills_name" name="bills_name" value="<%=buserName%>"></div>
                <div><strong><%=lang.getTranslated("frontend.carrello.table.label.surname")%></strong><br>
                <input type="text" id="bills_surname" name="bills_surname" value="<%=buserSurname%>"></div>
                <div style="float:left;"><strong><%=lang.getTranslated("frontend.carrello.table.label.address")%></strong><br>
                <input type="text" id="bills_address" name="bills_address" value="<%=buserAddress%>"></div>
                <div><strong><%=lang.getTranslated("frontend.carrello.table.label.zip_code")%></strong><br>
                <input type="text" id="bills_zip_code" name="bills_zip_code" value="<%=buserZipCode%>"></div>
                <div>
                <strong><%=lang.getTranslated("frontend.carrello.table.label.city")%></strong><br>
                <input type="text" id="bills_city" name="bills_city" value="<%=buserCity%>"></div>

                <div style="float:left;padding-right:3px;">
                <strong><%=lang.getTranslated("frontend.carrello.table.label.country")%></strong><br>
                <select id="bills_country" name="bills_country">
                <option value=""></option>
                <%On Error Resume next
                Set specialFieldValueB = objCountry.findCountryListOnly("2,3")
                if (Instr(1, typename(specialFieldValueB), "Dictionary", 1) > 0) then			    
                for each x in specialFieldValueB
                  key =  specialFieldValueB(x).getCountryCode()
                  selected = ""
                  if (strComp(key, buserCountry, 1) = 0) then selected=" selected" end if%>
                  <option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(lang.getTranslated("portal.commons.select.option.country."&key))%></option>     
                <%next
                end if
                Set specialFieldValueB = nothing
                if(Err.number<>0) then
                end if%>
                </select>  
                </div>  
                <div style="padding-bottom:10px;">
                <strong><%=lang.getTranslated("frontend.carrello.table.label.state_region")%></strong><br>	 
                <select name="bills_state_region" id="bills_state_region">
                <option value=""></option>
                <%
                if(buserCountry<>"")then
                  On Error Resume next
                  Set specialFieldValueBSR = objCountry.findStateRegionListByCountry(buserCountry,"2,3")	
                  if (Instr(1, typename(specialFieldValueBSR), "Dictionary", 1) > 0) then	    
                  for each x in specialFieldValueBSR
                    key =  specialFieldValueBSR(x).getStateRegionCode()
                    selected = ""
                    if (strComp(key, buserStateRegion, 1) = 0) then selected=" selected" end if%>
                    <option value="<%=key%>" <%=selected%>><%=Server.HTMLEncode(lang.getTranslated("portal.commons.select.option.country."&key))%></option>     
                  <%next
                  end if
                  Set specialFieldValueBSR = nothing					
                  if(Err.number<>0) then
                  end if
                end if%>
                </select>	  
                </div>
                <div><strong><%=lang.getTranslated("frontend.carrello.table.label.cfiscvat")%></strong><br>
                <input type="text" id="bills_cfiscvat" name="bills_cfiscvat" value="<%=buserCfiscVat%>"></div>
				<script>
				$('#bills_country').change(function() {
					var type_val_ch = $('#bills_country').val();
					var query_string = "field_val="+escape(type_val_ch);
					query_string+=selectPayAndBills4Form(<%if(applyBills) then response.write("1") else response.write("0") end if%>);

					$.ajax({
						async: true,
						type: "GET",
						cache: false,
						url: "<%=Application("baseroot") & "/common/include/ajaxstateregionlistupdate.asp"%>",
						data: query_string,
						success: function(response) {
							//alert("response: "+response);
							$("select#bills_state_region").empty();
							$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
							$("select#bills_state_region").append(response);
						},
						error: function() {
							$("select#bills_state_region").empty();
							$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
						}
					});		
				});
				</script> 
              </div>
              <%Set objBills = nothing
				Set objCountry = nothing%>             
            </div>
	
			<script>
				$("#card_bills_address").hide();

				<%if(Application("show_bills_box") = 1) then
					if not(isEmpty(Session("objUtenteLogged"))) OR (request("buy_noreg") = 1) then%>
						$("#card_bills_address").show();
					<%end if
				end if%>
			</script>
                    
            
            <div id="spese-totale">
			  <%=lang.getTranslated("frontend.carrello.table.label.payment_commission")%>: <strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<span class="payment_commission"><%=FormatNumber(payment_commission, 2,-1)%></span></strong><br/><br/> 
              <%=lang.getTranslated("frontend.carrello.table.label.totale_ordine")%>: <strong><%if(lang.getTranslated("backend.currency.symbol.label."&Session("currency")) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&Session("currency"))) else response.write(Session("currency")) end if%>&nbsp;<span class="ord_total"><%=FormatNumber(totale_spese_all, 2,-1)%></span></strong>
			<br/><span id="currency"><%=lang.getTranslated("frontend.carrello.table.label.totale_ordine.currency_transaction1")%>&nbsp;<%=lang.getTranslated("backend.currency.keyword.label."&defCurrObj)%>&nbsp;<%=lang.getTranslated("frontend.carrello.table.label.totale_ordine.currency_transaction2")%>:&nbsp;<%if(lang.getTranslated("backend.currency.symbol.label."&defCurrObj) <> "") then response.write(lang.getTranslated("backend.currency.symbol.label."&defCurrObj)) else response.write(defCurrObj) end if%>&nbsp;<span class="ord_total_def_curr"><%=FormatNumber(totSpese+totale_carrello, 2,-1)%></span></span>
			</div>

			<div class="spese-div">
				<a name="condition_purchase"></a>
				<input type="checkbox" id="terms_condition_purchase" name="terms_condition_purchase" />&nbsp;<%=lang.getTranslated("frontend.carrello.table.label.accept_term_conditions")%> (<a href="#condition_purchase" id="activate_condition_view"><%=lang.getTranslated("frontend.carrello.table.label.term_conditions_read")%></a>)
				<div id="term_conditions" align="center"><%=lang.getTranslated("frontend.carrello.table.label.text_term_conditions")%></div>
			</div>     
			<script>
				$("#term_conditions").hide();
				
				$('#activate_condition_view').click(function() {
				if( $('#term_conditions').is(':visible') ) {
					$("#term_conditions").hide();            
				}else{
					$("#term_conditions").show();
				}
				});
			</script>

            <div id="prodotto-totale">
						<span style="display:none;padding-left:32px;padding-right:32px;" id="sendtocardloadingimg"><img src="<%=Application("baseroot") & "/common/img/loading_icon.gif"%>" border="0" width="20" height="20" align="absmiddle"></span>
						<span id="sendtocardloading"><a href="javascript:sendCarrello(<%if(applyBills) then response.write("1") else response.write("0") end if%>);"><%=lang.getTranslated("frontend.carrello.table.label.confirm_order")%></a></span>&nbsp;&nbsp;
						<a href="<%=Request.ServerVariables("HTTP_REFERER")%>"><%=lang.getTranslated("frontend.carrello.table.label.continue_shop")%></a>&nbsp;&nbsp;
						<a href="<%=Application("baseroot") &Application("dir_upload_templ")&"shopping-card/DeleteCarrello.asp?id_carrello_to_delete=" & id_carrello%>"><%=lang.getTranslated("frontend.carrello.table.label.cancel_card")%></a>
						</div>
            </form>			
					</div>
				</div>
				<%Set objListaCarrello = nothing			
			else
				response.write("<br><br><p align='center'>"&lang.getTranslated("frontend.carrello.table.label.empty_card")&"</p>")
			end if
		else			
			response.write("<br><br><p align='center'>"&lang.getTranslated("frontend.carrello.table.label.empty_card")&"</p>")
		end if%>