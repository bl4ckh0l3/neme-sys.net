<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<%
strGerarchia = request("gerarchia")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=langEditor.getTranslated("backend.page.title")%></title>
<META http-equiv="refresh" content="10; URL=ConfirmInsertOrdine.asp?id_ordine=<%=request("id_ordine")&"&gerarchia="&strGerarchia&"&pagamDone=1"%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="<%=Application("baseroot") & "/editor/css/stile.css"%>" type="text/css">
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->
	<div id="container">
		<div id="backend-content">	
		<table align="center" border="0">
		<tr>
		<td>
		<span class="labelForm">Pagamento Carta di Credito</span><br><br>
			Queste saranno le pagine per il pagamento con carta di credito!<br>
			Il numero e il tipo dipendono dal fornitore del servizio di pagamento!<br><br>
			
			Tra qualche secondo verrete redirezionati alla pagina di conferma pagamento con carta di credito!

		</td>
		</tr>
		</table>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
