<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<%
Dim strGerarchia
strGerarchia = request("gerarchia")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%>
<link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css">
<%end if%>
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<%
dim objOrdine, objTmp, objTmpValue, tipoPagam, objOrdineTmp, strTipoPagam, StrPagamDone, id_utente		
Dim id_ordine, totale_ord, pagam_done, spese_sped_order, sconto_cliente, objListaTipiPagamento, tipo_pagam, payment_commission

Set objOrdine = New OrderClass
Set objOrdineTmp = objOrdine.findOrdineByID(request("id_ordine"), 0)

Dim strCognomecliente, strNomeCliente, strMail, objUserTmp, objUserStatic
Set objUserStatic = New UserClass
id_utente = objOrdineTmp.getIDUtente()				
Set objUserTmp = objUserStatic.findUserByID(id_utente)
'strCognomecliente = objUserTmp.getCognome()
'strNomeCliente = objUserTmp.getNome()
strMail = objUserTmp.getEmail()
sconto_cliente = objUserTmp.getSconto()
Set objUserTmp = nothing
Set objUserStatic = nothing

id_ordine = objOrdineTmp.getIDOrdine()
payment_commission = objOrdineTmp.getPaymentCommission()
totale_ord = objOrdineTmp.getTotale()
pagam_done =objOrdineTmp.getPagamEffettuato()

StrPagamDone = ""
Select Case pagam_done
case 1
	StrPagamDone = lang.getTranslated("portal.commons.payment_ok_to_verify")
case 0
	StrPagamDone = lang.getTranslated("portal.commons.no")
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
Dim objPayment, objTmpPayment
Set objPayment = New PaymentClass
Set objTmpPayment = objPayment.findPaymentByID(tipo_pagam)
strTipoPagam = lang.getTranslated(objTmpPayment.getKeywordMultilingua())		
if(strTipoPagam = "")then
	strTipoPagam = objTmpPayment.getKeywordMultilingua()
end if
Set objTmpPayment = Nothing
Set objPayment = Nothing				
%>
<script type="text/javascript">
  _gaq.push(['_addTrans',
    '<%=id_ordine%>'    					// order ID - required
    ,'<%=Application("srt_default_server_name")%>'  // affiliation or store name
    ,'<%=Replace(totale_ord, ",",".")%>'		// total - required
    ,'' 							// tax
    ,<%=Replace(spese_sped_order, ",",".")%>' 		// shipping
    ,''								// city
    ,''								// state or province
    ,'' 							// country
  ]);

   // add item might be called for every item in the shopping cart
   // where your ecommerce engine loops through each item in the cart and
   // prints out _addItem for each
  /*_gaq.push(['_addItem',
    '<%'=id_ordine%>',           	// order ID - required
    'DD44',           			// SKU/code - required
    'T-Shirt',        			// product name
    'Green Medium',   		// category or variation
    '11.99',          			// unit price - required
    '1'               				// quantity - required
  ]);*/
  
  _gaq.push(['_trackTrans']); //submits transaction to the Analytics servers
</script>
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">			
			<div id="carrello-lista">   
				<div id="prodotto-conto">
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_id_ordine")%>: <strong><%=id_ordine%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_1")%>: <strong><%=strTipoPagam%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_pagam_done")%>: <strong><%=StrPagamDone%></strong></div>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_spese_sped")%>: <strong>&euro;  <%=FormatNumber(spese_sped_order, 2,-1)%></strong></div>
					<!--<%'if(CDbl(sconto_cliente)>0) then%><div class="spese-div"><%'=lang.getTranslated("frontend.carrello.table.label.confirm_sconto_cli")%>: <strong><%'=sconto_cliente%> %</strong></div><%'end if%>-->
					<%
					On Error Resume Next
					Set objRule = new BusinessRulesClass
					Set objRule4Order = objRule.findRuleOrderAssociationsByOrder(id_ordine, false)
					if(strComp(typename(objRule4Order), "Dictionary") = 0)then
						if(objRule4Order.count>0)then
							for each x in objRule4Order%>
								<div class="spese-div"><%if(lang.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel()) <> "") then response.write(lang.getTranslated("portal.commons.business_rule.label."&objRule4Order(x).getLabel())) else response.write(objRule4Order(x).getLabel()) end if%>: <strong>&euro;  <%=FormatNumber(objRule4Order(x).getValoreConf(), 2,-1)%></strong></div>
						<%	next
						end if
					end if					
					Set objRule4Order = nothing
					Set objRule = nothing
					If Err.Number<>0 then
						'response.write(Err.description)					
					end if
					%>
					<div class="spese-div"><%=lang.getTranslated("frontend.carrello.table.label.confirm_payment_commission")%>: <strong>&euro;  <%=FormatNumber(payment_commission, 2,-1)%></strong></div>
					<div id="spese-totale"><%=lang.getTranslated("frontend.carrello.table.label.confirm_tot_ord")%>: <strong>&euro;  <%=FormatNumber(totale_ord, 2,-1)%></strong></div>
					
					<%		
					'Spedisco la mail di conferma registrazione ordine
					Dim objMail
					Set objMail = New SendMailClass
					call objMail.sendMailOrder(id_ordine, strMail, 0, lang.getLangCode())
					call objMail.sendMailOrder(id_ordine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
					Set objMail = Nothing	
					
					if (CInt(pagam_done) = 1) then%>					
						<h2><%=lang.getTranslated("frontend.carrello.table.label.ordine_complete")%></h2>
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_complete")%></p>
					<%else%>
						<h2><%=lang.getTranslated("frontend.carrello.table.label.ordine_complete")%></h2>
						<p><%=lang.getTranslated("frontend.carrello.table.label.ordine_payment_to_do_2")%></p>
					<%end if
					
					Set objTmp = nothing
					Set objOrdineTmp = nothing
					Set objOrdine = nothing
					
					Dim objCarrello, objCarrelloUser
					Set objCarrello = New CardClass
					Set objCarrelloUser = objCarrello.getCarrelloByIDUser(id_utente)
					call objCarrello.deleteCarrello(objCarrelloUser.getIDCarrello())
					
					Set objCarrelloUser = nothing
					Set objCarrello = nothing
					
					' If something fails inside the script, but the exception is handled
					If Err.Number<>0 then
						response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
					end if
					%>
				</div>
			</div>
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
