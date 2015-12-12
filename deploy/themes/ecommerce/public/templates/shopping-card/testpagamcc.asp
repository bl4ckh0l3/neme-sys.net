<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<%
strGerarchia = request("gerarchia")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<META http-equiv="refresh" content="10; URL=ConfirmOrdineCarrello.asp?id_ordine=<%=request("id_ordine")&"&gerarchia="&strGerarchia&"&pagamDone=1"%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
</head>
<body>
<table class="tableContainer" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td class="tdContainerTop">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	</td>
  </tr>
  <tr>
    <td class="tdContainerContent">
	<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
	<table class="tableContent" border="0" align="left" cellpadding="0" cellspacing="0">
	  <tr>
		<td class="tdMenu">
		<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" --></td>
		<td class="tdContent">
		<br><br>		
		<table align="center" border="0" class="tabellaCarrello">
		<tr>
		<td class="tdCarrello">
		<span class="labelTabCarrello">Pagamento Carta di Credito</span><br><br>
			Queste saranno le pagine per il pagamento con carta di credito!<br>
			Il numero e il tipo dipendono dal fornitore del servizio di pagamento!<br><br>
			
			Tra qualche secondo verrete redirezionati alla pagina di conferma pagamento con carta di credito!

		</td>
		</tr>
		</table>
		</td>	
		<td class="tdMenuRight">
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
		</td>
	  </tr>
	</table>
	</td>
  </tr>
  <tr>
    <td class="tdContainerBott">
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
	</td>
  </tr>
</table>
</body>
</html>
