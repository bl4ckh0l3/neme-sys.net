<%@LANGUAGE="VBScript"%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->		
<%
Response.ContentType = "text/xml"

On Error Resume Next

idOrdine = -1
idModule = -1

Set objModulePayment = new PaymentModuleClass
Set objModuleList = objModulePayment.getListaPaymentModuli()
exit1For = false	
for each x in objModuleList
	idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
	for each z in idOrderFieldList	
		if not(request(z) = "") then
			idOrdineAck = request(z)
			idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
			idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
			idOrdine = idOrdineAck
		
			' ***********    TODO  RIPRISTINARE SEMPRE QUESTO CONTROLLO IN AMBIENTE DI PRODUZIONE
			' ***********    L'UTILIZZO DI REMOTE_ADDR SEMBRA NON FUNZIONARE, RITORNA IP ERRATO
			'Dim idValidIPFieldList
			'idValidIPFieldList = Split(objModuleList(x).getIpProvider(),"|",-1,1)
			'for each t in idValidIPFieldList
				'if(t = request.ServerVariables("REMOTE_ADDR")) then
					remoteAddrMatch = true
					'Exit for
				'end if
			'next
	
			exit1For = true
			Exit for
		end if
	next
	if(exit1For) then exit for end if
next
	
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
Set objModuleList = nothing%>