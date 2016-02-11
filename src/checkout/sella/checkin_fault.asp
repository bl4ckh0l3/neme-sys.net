<%@LANGUAGE="VBScript"%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->		
<%
Response.ContentType = "text/xml"

On Error Resume Next

idOrdine = -1
idModule = -1

Dim objdeCrypt
'Sintassi Oggetto COM
Set objdeCrypt =Server.Createobject("GestPayCrypt.GestPayCrypt")

parametro_a = trim(request("a"))
parametro_b = trim(request("b"))

objdeCrypt.SetShopLogin(parametro_a)
objdeCrypt.SetEncryptedString(parametro_b)

call objdeCrypt.Decrypt

if Err.number = 0 then 
	idOrdineAck = trim(objdeCrypt.GetShopTransactionID)
	idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
	idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
	idOrdine = idOrdineAck	
end if

dim objOrdine
Set objOrdine = New OrderClass

if(Cint(idOrdine) <> -1 AND remoteAddrMatch) then
	dim objOrdineTmp
	Set objOrdineTmp = objOrdine.findOrdineByID(idOrdine, 0)	
	idOrdine = objOrdineTmp.getIDOrdine()
	Set objOrdineTmp = nothing
end if

response.write("<result_checkin_fault>")
response.write("<orderid_confirmed>"&idOrdine&"</orderid_confirmed>")
response.write("</result_checkin_fault>")

Set objOrdine = nothing
'Set objModuleList = nothing%>