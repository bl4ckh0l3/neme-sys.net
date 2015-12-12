<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
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
		<%strGerarchia = request("gerarchia")%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">	
		<table border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
		<td>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.include.table.label.ordine_complete")%></span><br><br>
		
		<%
		Dim objOrdine, objTmp, objTmpValue, tipoPagam, objOrdineTmp, strTipoPagam, StrPagamDone, id_utente		
		Dim id_ordine, totale_ord, pagam_done, spese_sped_order, sconto_cliente, objListaTipiPagamento, tipo_pagam
		Dim strMail, objUserTmp, objUserStatic, already_paied, payment_commission, id_ads, objProdList
		
		Set objOrdine = New OrderClass
		Set objOrdineTmp = objOrdine.findOrdineByID(request("id_ordine"), 0)
		already_paied = request("already_paied")

		Set objUserStatic = New UserClass
		id_utente = objOrdineTmp.getIDUtente()				
		Set objUserTmp = objUserStatic.findUserByID(id_utente)
		strMail = objUserTmp.getEmail()
		sconto_cliente = objUserTmp.getSconto()
		Set objUserTmp = nothing
		Set objUserStatic = nothing
		
		id_ordine = objOrdineTmp.getIDOrdine()
		payment_commission = objOrdineTmp.getPaymentCommission()
		totale_ord = objOrdineTmp.getTotale()
		pagam_done =objOrdineTmp.getPagamEffettuato()
		id_ads = objOrdineTmp.getIdAdRef()		
		
		StrPagamDone = ""
		Select Case pagam_done
		case 1
			StrPagamDone = langEditor.getTranslated("portal.commons.payment_ok_to_verify")
		case 0
			StrPagamDone = langEditor.getTranslated("portal.commons.no")
		End Select
		
		spese_sped_order = 0
		On Error Resume Next
		Dim objBills4OrderClass
		Dim objListaSpeseXOrdine
		Set objBills4OrderClass = new Bills4OrderClass			
		Set objListaSpeseXOrdine = objBills4OrderClass.getSpeseXOrdine(id_ordine)		
		for each j in objListaSpeseXOrdine.Keys
			spese_sped_order = spese_sped_order+CDbl(objListaSpeseXOrdine(j).getTotale())
		next		
		Set objListaSpeseXOrdine = nothing
		Set objBills4OrderClass = nothing			
		
		If Err.Number<>0 then
		end if
				
		tipo_pagam = objOrdineTmp.getTipoPagam()		
		Dim objPayment, objTmpPayment, payUrl
		Set objPayment = New PaymentClass
		Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
		payUrl = objTmpPayment.getURL()
		strTipoPagam = langEditor.getTranslated(objTmpPayment.getKeywordMultilingua())	
		if(strTipoPagam = "")then
			strTipoPagam = objTmpPayment.getKeywordMultilingua()
		end if
		Set objTmpPayment = Nothing
		Set objPayment = Nothing

		'Spedisco la mail di conferma registrazione ordine
		Dim objMail
		Set objMail = New SendMailClass
		call objMail.sendMailOrder(id_ordine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
		call objMail.sendMailOrder(id_ordine, strMail, 0, Application("str_lang_code_default"))

		if(payUrl = 0 AND pagam_done = 1 AND already_paied = 0) then	
			bolHasProdList = false
			On Error Resume Next
			Set objP4O = new Products4OrderClass
			Set objProdList = objP4O.getListaProdottiXOrdine(id_ordine)
			if(objProdList.Count>0)then
				bolHasProdList = true
			end if
			Set objP4O = nothing			
			If Err.Number<>0 then
				'response.write(Err.description)
				bolHasProdList = false
			end if

			'*** Spedisco la mail di download ordine secondo le regole prestabilite
			if(objOrdineTmp.isUserNotifiedXDownload() = 0) then
				if(bolHasProdList)then
					bolHasDownload = false
					for each k in objProdList
						if(objProdList(k).getProdType()=1)then
							bolHasDownload = true
							exit for
						end if
					next
					if(bolHasDownload)then
						call objMail.sendMailOrderDown(id_ordine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
						call objMail.sendMailOrderDown(id_ordine, strMail, 0, Application("str_lang_code_default"))			
						call objOrdine.changeUserNotifiedOrderNoTransaction(id_ordine, 1)
					end if
				end if
			end if
			
			'*** Se il pagamento e'  andato a buon fine verifico se nella lista prodotti ci sono degli annunci a pagamento e imposto activate a true e la data di attivazione alla data corrente			
			On Error Resume Next
			if(bolHasProdList)then
				if(id_ads<>"")then
					Set objAds = new AdsClass
					for each j in objProdList
						'response.write("id_ads: "&id_ads&" - objProdList(j).getIDProdotto(): "&objProdList(j).getIDProdotto()&" - objProdList(j).getProdType(): "&objProdList(j).getProdType()&"<br>")
						if(objProdList(j).getProdType()=2)then
							call objAds.activateAdsPromotionNoTransaction(id_ads, objProdList(j).getIDProdotto())
						end if		
					next			
					Set objAds = nothing
				end if
				Set objProdList = nothing
			end if
			If Err.Number<>0 then
				'response.write(Err.description)
			end if
		end if
		
		Set objMail = Nothing	
		%>
		
		<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_id_ordine")%>: <%=id_ordine%><br>
		<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_spese_sped")%>: &euro;  <%=FormatNumber(spese_sped_order,2,-1,-2,0)%><br>
		<!--<%'=langEditor.getTranslated("backend.ordini.include.table.label.confirm_sconto_cli")%>: <%'=sconto_cliente%> %<br>-->
		<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_payment_commission")%>: &euro;  <%=FormatNumber(payment_commission,2,-1,-2,0)%><br>

		<%
		On Error Resume Next
		Set objRule = new BusinessRulesClass
		Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_ordine, false)
		if(strComp(typename(objRule4Order), "Dictionary") = 0)then
			if(objRule4Order.count>0)then
				for each x in objRule4Order%>
					<%if(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(langEditor.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>: &euro;  <%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1,-2,0)%><br/>
			<%	next
			end if	
		end if		
		Set objRule4Order = nothing
		Set objRule = nothing
		If Err.Number<>0 then
			'response.write(Err.description)					
		end if
		%>

		<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_tot_ord")%>: &euro;  <%=FormatNumber(totale_ord,2,-1,-2,0)%><br>
		
		<%
		if (CInt(pagam_done) = 1) then%>	
			<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_pagam_done")%>: <%=StrPagamDone%><br><br><br>	
			<%=langEditor.getTranslated("backend.ordini.include.table.label.ordine_payment_to_do_1") & " " & strTipoPagam%><br>				
			<%=langEditor.getTranslated("backend.ordini.include.table.label.ordine_payment_complete")%><br><br>
		<%else%>
			<%=langEditor.getTranslated("backend.ordini.include.table.label.confirm_pagam_done")%>: <%=StrPagamDone%><br><br><br>
			<%=langEditor.getTranslated("backend.ordini.include.table.label.ordine_payment_to_do_1") & " " & strTipoPagam%><br>
			<%=langEditor.getTranslated("backend.ordini.include.table.label.ordine_payment_to_do_2")%><br><br>
		<%end if
		
		Set objOrdineTmp = nothing
		Set objOrdine = nothing
		
		' If something fails inside the script, but the exception is handled
		If Err.Number<>0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		%>
		</td>
		</tr>
		</table>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
