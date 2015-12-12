<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<%
Dim id_ordine, id_prodotto
id_ordine = request("id_ordine")
id_prodotto = request("id_prodotto")

Set objDownProd = new DownloadableProductClass
Set objDownProd4Order = new DownloadableProduct4OrderClass	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
</head>
<body>
<table width="400" height="100%" border="0" align="left" cellpadding="2" cellspacing="0">
<tr>
<td>
	<%
	On Error Resume Next
	Set objDownProdList = objDownProd.getFilePerProdotto(id_prodotto)%>
	<table border="0" cellpadding="0" cellspacing="0" id="order-table-down-status">
	<%for each r in objDownProdList
		if not(isNull(objDownProd4Order.getFileByIDProdDown(id_ordine, id_prodotto, r))) then
			Set objDownProd4OrderTmp = objDownProd4Order.getFileByIDProdDown(id_ordine, id_prodotto, r)%>
			<tr class="filename">
			<td colspan="4"><%=langEditor.getTranslated("backend.popup.label.filename")%>: <%=objDownProdList(r).getFileName()%></td>
			</tr>
			<tr>
			<th><%=langEditor.getTranslated("backend.popup.label.max_download")%>:</th>
			<td><%if(objDownProd4OrderTmp.getMaxNumDownload() = -1)then response.Write(langEditor.getTranslated("backend.popup.label.unlimited_download")) else response.Write(objDownProd4OrderTmp.getMaxNumDownload()) end if%></td>
			<th><%=langEditor.getTranslated("backend.popup.label.download_counter")%>:</th>
			<td><%=objDownProd4OrderTmp.getDownloadCounter()%></td>
			</tr>
			<tr>
			<th><%=langEditor.getTranslated("backend.popup.label.expire_date")%>:</th>
			<td><%=objDownProd4OrderTmp.getExpireDate()%></td>
			<th><%=langEditor.getTranslated("backend.popup.label.download_date")%>:</th>
			<td><%=objDownProd4OrderTmp.getDownloadDate()%></td>
			</tr>
			<%Set objDownProd4OrderTmp = nothing
		end if		
	next%>
	</table>
	<%Set objDownProdList = nothing
	if(Err.number <> 0)then 
		response.Write("<div align='center'>"&langEditor.getTranslated("backend.popup.label.no_prod_download")&"</div><br>") 
	end if%>
</td>
</tr>
<tr>
<td align="center" height="20" valign="middle">	
<br>	
<a href="javascript:window.close();" class="link-close-popup"><%=langEditor.getTranslated("backend.popup.label.close_window")%></a><br><br></td>
</tr>
</table>
</body>
</html>
<%
Set objDownProd4Order = nothing
Set objDownProd = nothing
%>