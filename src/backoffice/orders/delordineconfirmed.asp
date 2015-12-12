<!-- #include virtual="/editor/include/IncludeObjectList.inc" -->
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
		<%cssClass="LO"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">		
		<table border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
		<td>
		<%
		Dim srtReportProdDeleted, arrListProd, arrSingleProd
		Dim id_user
		search_ordini = request("search_ordini")
		
		if not(request("report_modifiche_qta") = "") then
			response.write(langEditor.getTranslated("backend.ordini.include.table.label.order_del_confirm")&"<br><br>")
			srtReportProdDeleted = request("report_modifiche_qta")
						
			'elimino il # in fondo alla stringa
			arrListProd = Split(srtReportProdDeleted, "#", -1, 1)
			
			if(isArray(arrListProd)) then
				response.write(langEditor.getTranslated("backend.ordini.include.table.label.qta_prod_modified")&":<br><br>")
				
				For y=LBound(arrListProd) to UBound(arrListProd)		
					arrSingleProd = Split(arrListProd(y), "|", -1, 1)
					response.Write(langEditor.getTranslated("backend.ordini.include.table.label.id_prodotto") & ": " & arrSingleProd(0)&"<br>")
					response.Write(langEditor.getTranslated("backend.ordini.include.table.label.nome_prod") & ": " & arrSingleProd(1)&"<br>")
					response.Write(langEditor.getTranslated("backend.ordini.include.table.label.new_qta") & ": " & arrSingleProd(2)&"<br>")
					response.Write(langEditor.getTranslated("backend.ordini.include.table.label.old_qta") & ": " & arrSingleProd(3)&"<br><br>")				
				next			
			end if
			
		else
			response.Redirect(Application("baseroot")&"/editor/ordini/ListaOrdini.asp?cssClass=LO&search_ordini="&search_ordini)
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
