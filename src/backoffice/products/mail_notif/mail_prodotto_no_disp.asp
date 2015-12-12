<%On Error Resume Next%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<%					
'/**
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_prod, strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod, sconto_prod, objProd, objTarget, id_tassa_applicata
Dim prod_type, max_download, max_download_time
id_prod = request("id_prodotto")
strCodProd = ""
strNomeProd = ""
numQta = 0
stato_prod = 0

if not (isNull(id_prod)) then

	'*** verifico se è stata passata la lingua dell'utente e la imposto come langEditor.setLangCode(xxx)
	if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
		langEditor.setLangCode(request("lang_code"))
		langEditor.setLangElements(langEditor.getListaElementsByLang(langEditor.getLangCode()))
	end if

	Dim objProdotti, objSelProdotti
	Set objProdotti = New ProductsClass
	Set objSelProdotti = objProdotti.findProdottoByID(id_prod, 0)
	Set objProdotti = nothing
	
	id_prod = objSelProdotti.getIDProdotto()
	strCodProd = objSelProdotti.getCodiceProd()
	strNomeProd = objSelProdotti.getNomeProdotto()
	numQta = objSelProdotti.getQtaDisp()	
	stato_prod = objSelProdotti.getAttivo()
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
<link rel="stylesheet" href="<%="http://" & request.ServerVariables("SERVER_NAME") & Application("baseroot") & "/editor/css/stile.css"%>" type="text/css">
</head>
<body>
<div id="backend-warp">
	<div id="backend-content">
		<table border="0" cellpadding="0" cellspacing="0">
		<tr>
		<td align="left" colspan="3"><%=langEditor.getTranslated("backend.prodotti.view.table.label.product_inactive")%>:</td>
		</tr>
		<tr>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.id_prodotto")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.cod_prod")%></th>
		</tr>
		<tr>
		<td align="left"><%=id_prod%></td>
		<td class="separator">&nbsp;</td>
		<td align="left"><%=strCodProd%></td>
		</tr>
		<tr>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.nome_prod")%></th>
		<td class="separator">&nbsp;</td>
		<th><%=langEditor.getTranslated("backend.prodotti.view.table.label.prod_attivo")%></th>		
		</tr>
		<tr>
		<td align="left"><%=strNomeProd%></td>
		<td class="separator">&nbsp;</td>
		<td align="left"><%
		Select Case stato_prod
		Case 0
			response.write(langEditor.getTranslated("backend.commons.no"))
		Case 1
			response.write(langEditor.getTranslated("backend.commons.yes"))
		Case Else
		End Select
		%></td>	
		</tr>
		<tr>
		<th colspan="3"><%=langEditor.getTranslated("backend.prodotti.view.table.label.qta_prod")%></th>		
		</tr>
		<tr>
		<td colspan="3" align="left"><%if(numQta = Application("unlimited_key"))then%><%=langEditor.getTranslated("backend.prodotti.detail.table.label.qta_unlimited")%><%else%><%=numQta%><%end if%></td>		
		</tr>
		</table>
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
