<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/area_user.css"%>" type="text/css">
</head>
<body>
<!-- #include file="grid_top.asp" -->

		<table border="0" cellpadding="0" cellspacing="0" class="principal">
			<tr> 
			<th align="center" width="25">&nbsp;</th>
			<!--<th><%'=lang.getTranslated("frontend.area_user.ordini.table.header.id_ordine")%></th>-->
			<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.dta_insert_order")%></th>
			<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.totale_order")%></th>
			<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.tipo_pagam_order")%></th>
			<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.pagam_order_done")%></th>
			<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.stato_order")%></th>
			</tr>
			<%				
			if(hasOrder) then
				intCount = 0
				
				iIndex = objListaOrdini.Count
				iIndexStatiOrder = objListaStatiOrdine.Count
				
				FromOrder = ((numPage * orderXpage) - orderXpage)
				Diff = (iIndex - ((numPage * orderXpage)-1))
				if(Diff < 1) then
					Diff = 1
				end if
				
				ToOrder = iIndex - Diff
				
				totPages = iIndex\orderXpage
				if(totPages < 1) then
					totPages = 1
				elseif((iIndex MOD orderXpage <> 0) AND not ((totPages * orderXpage) >= iIndex)) then
					totPages = totPages +1	
				end if		
						
				objTmpOrder = objListaOrdini.Items				

				styleRow2 = "table-list-on"					
						
				for orderCounter = FromOrder to ToOrder
					styleRow = "table-list-off"
					if(orderCounter MOD 2 = 0) then styleRow = styleRow2 end if
					Set objFilteredOrder = objTmpOrder(orderCounter)
					%>
					<tr class="<%=styleRow%>">
					<td align="center"><a href="<%=Application("baseroot") & "/area_user/VisualizzaOrdine.asp?id_ordine=" & objFilteredOrder.getIDOrdine()%>"><img src="<%=Application("baseroot")&"/editor/img/zoom.png"%>" alt="<%=lang.getTranslated("frontend.area_user.ordini.alt.view_order")%>" hspace="2" vspace="0" border="0"></a></td>
					<!--<td><%'=objFilteredOrder.getIDOrdine()%></td>-->
					<td><%=objFilteredOrder.getDtaInserimento()%></td>
					<td>&euro;&nbsp;<%=FormatNumber(objFilteredOrder.getTotale(),2,-1)%></td>
					<td>
					<%
					Set objTmpPayment = objPayment.findPaymentByID(objFilteredOrder.getTipoPagam())
					response.write(lang.getTranslated(objTmpPayment.getKeywordMultilingua()))
					Set objTmpPayment = Nothing%>
					</td>
					<td>
					<%
					Select Case objFilteredOrder.getPagamEffettuato()
					Case 0
						response.write(lang.getTranslated("portal.commons.no"))
					Case 1
						response.write(lang.getTranslated("portal.commons.yes"))
					Case Else
					End Select
					%>
					</td>
					<td>
						<%=lang.getTranslated(objListaStatiOrdine(objFilteredOrder.getStatoOrdine()))%>
					</td>
					</tr>				
					<%intCount = intCount +1
					Set objFilteredOrder = nothing
				next
				Set objTmpOrder = nothing
				Set objTmpStatiOrder = nothing
				Set objTmpStatiOrderKey = nothing
				Set objListaOrdini = nothing
				%>
			  
			  <tr> 
				<th colspan="8" align="center">
				<%		
				'**************** richiamo paginazione
				call PaginazioneFrontend(totPages, numPage, strGerarchia, "/area_user/ListaOrdini.asp", "order_by="&order_ordine_by)%>
			</th>			
              </tr>		
		<%end if%>
		 </table>	
		
<!-- #include file="grid_bottom.asp" -->
</body>
</html>