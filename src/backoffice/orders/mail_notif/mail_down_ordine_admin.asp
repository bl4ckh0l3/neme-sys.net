<%On Error Resume Next%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<%
'/**
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_order, order_guid, id_utente, dta_ins, totale_ord, tipo_pagam, pagam_done, stato_order, objSelProdPerOrder
id_order = request("id_ordine")
order_guid = ""
id_utente = ""
dta_ins = ""
totale_ord = 0
tipo_pagam = ""
pagam_done = 0
stato_order = 0
objSelProdPerOrder = null

Dim objUtente, objTmpUser
Set objUtente = New UserClass
					
if not (isNull(id_order)) then

	'*** verifico se è stata passata la lingua dell'utente e la imposto come langEditor.setLangCode(xxx)
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
<link rel="stylesheet" href="<%="http://" & request.ServerVariables("SERVER_NAME") &Application("baseroot") & "/editor/css/stile.css"%>" type="text/css">
</head>
<body>
<div id="backend-warp">
	<div id="backend-content">
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.id_ordine")%>:</span>&nbsp;<%=id_order%><br><br>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.guid_ordine")%>:</span>&nbsp;<%=order_guid%><br><br>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.order_client")%>:</span>&nbsp;
		<%
		Set objTmpUser = objUtente.findUserByID(id_utente)
		response.Write("<strong>ID:</strong> " & objTmpUser.getUserName() & "; <strong>mail:</strong> "&objTmpUser.getEmail())
		%>
		<br><br>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.dta_insert_order")%>:</span>&nbsp;<%=dta_ins%>
		<br><br>
		<span class="labelForm"><%=langEditor.getTranslated("backend.ordini.view.table.label.attached_prods")%></span><br>
		<%
		if not(isNull(objSelProdPerOrder)) then
			Dim styleRow, styleRow2, counter
			styleRow2 = "table-list-on"
			counter = 0%>
			<table border="0" align="top" cellpadding="0" cellspacing="0">							
			<%					
			Set objDownProd = new DownloadableProductClass
			Set objDownProd4Order = new DownloadableProduct4OrderClass	
			Set objProdTmp = New ProductsClass

			for each z in objSelProdPerOrder
				styleRow = "table-list-off"
				if(counter MOD 2 = 0) then styleRow = styleRow2 end if
				
				Set tmpProd = objProdTmp.findProdottoByID(Left(z,Instr(1,z,"|",1 )-1),0)
				if(tmpProd.getProdType()=1)then%>
					<tr class="<%=styleRow%>">
					<td><%=langEditor.getTranslated("backend.ordini.view.table.header.nome_prod")%>:&nbsp;&nbsp;<%=tmpProd.getNomeProdotto()%></td>
					<td>
					<%Set objDownProdList = objDownProd.getFilePerProdotto(tmpProd.getIDProdotto())
					for each r in objDownProdList
						if not(isNull(objDownProd4Order.getFileByIDProdDown(id_ordine, tmpProd.getIDProdotto(), r))) then
							Set objDownProd4OrderTmp = objDownProd4Order.getFileByIDProdDown(id_order, tmpProd.getIDProdotto(), r)
							if(objDownProd4OrderTmp.isActive())then%>
								&nbsp;&nbsp;<%=objDownProdList(r).getFileName()%><br/>
							<%end if
							Set objDownProd4OrderTmp = nothing
						end if						
					next
					Set objDownProdList = nothing%>				
					</td>		
					</tr>
				<%end if		
				Set tmpProd = nothing				
				
				%>
				<%counter = counter +1
			next%>	
			</table>			
			<%
			Set objSelProdPerOrder = nothing
			Set objProdTmp = nothing
			Set objDownProd4Order = nothing
			Set objDownProd = nothing
		end if%>			
		<br><br>
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
