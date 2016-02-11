<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/SendMailClass.asp" -->
<!-- include virtual="/common/include/Objects/CryptClass.asp" -->
<%
Dim strGerarchia
strGerarchia = request("gerarchia")
Dim remoteAddrMatch
remoteAddrMatch = false
Response.Charset="UTF-8"
Session.CodePage  = 65001

Dim fault_motivation
fault_motivation = "<p><strong>"&lang.getTranslated("portal.commons.payment_fault")&"</strong></p>"

On Error Resume Next

idOrdine = -1
idModule = -1

pageModuleCheckinFault = ""
'Dim isHTTPS
isHTTPS = Request.ServerVariables("HTTPS")
If isHTTPS = "off" AND Application("use_https") = 1 Then
	pageModuleCheckinFault = "https://"&Request.ServerVariables("SERVER_NAME")
Else
	pageModuleCheckinFault = "http://"&Request.ServerVariables("SERVER_NAME")
End If
pageModuleCheckinFault = pageModuleCheckinFault & Application("baseroot") & "/editor/payments/moduli/"

'response.write("idOrdine: "&idOrdine&"<br>")
'response.write("idModule: "&idModule&"<br>")
'response.write("pageModuleCheckinFault: "&pageModuleCheckinFault&"<br>")

'response.write("Request.Form(): "&Request.Form()&"<br>")
'response.write("Request.ServerVariables(QUERY_STRING): "&Request.ServerVariables("QUERY_STRING")&"<br>")

Set objModulePayment = new PaymentModuleClass
Set objModuleList = objModulePayment.getListaPaymentModuli()
exit1For = false	
for each x in objModuleList
	idOrderFieldList = Split(objModuleList(x).getIdOrdineField(),"|",-1,1)
	for each z in idOrderFieldList	
		'response.write("z: "&z&"<br>")
		if not(request(z) = "") then
			idOrdineAck = request(z)
			'Set objUtil = new UtilClass
			'Set objCrypt = new CryptClass
			' decripto il campo contenente il codice ordine
			'idOrdineAck = objCrypt.DeCrypt(idOrdineAck)
			'Set objCrypt = nothing
			'Set objUtil = nothing
			'idOrdineAck =  Right(idOrdineAck,(Len(idOrdineAck)-InStr(1,idOrdineAck,"|",1)))	
			'idOrdineAck = Left(idOrdineAck,InStr(1,idOrdineAck,"|",1)-1)
			idOrdine = idOrdineAck
			idModule = objModuleList(x).getID()
			pageModuleCheckinFault = pageModuleCheckinFault& objModuleList(x).getDirectory()
			pageModuleCheckinFault = pageModuleCheckinFault&"/"& objModuleList(x).getCheckinFaultPage()
		
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
	
Set objOrdine = New OrderClass

'response.write("idOrdine after: "&idOrdine&"<br>")
'response.write("pageModuleCheckinFault: "&pageModuleCheckinFault&"<br>")

if(idOrdine <> "-1" AND remoteAddrMatch AND Cint(idModule) <> -1) then

	Dim checkin_parameters
	checkin_parameters = Request.ServerVariables("QUERY_STRING")
	'response.write("checkin_parameters: "&checkin_parameters&"<br>")
	
	set objHttp = Server.CreateObject("Msxml2.ServerXMLHTTP.6.0")
	objHttp.open "POST", pageModuleCheckinFault, false
	objHttp.setRequestHeader "Content-type", "application/x-www-form-urlencoded"
	objHttp.Send(checkin_parameters)
	Set objXML = objHTTP.ResponseXML
	'response.write(objHTTP.responseText)

	'set items = objXML.getElementsByTagName("payment_confirmed")
	'val = items(0).childNodes(0).nodeValue		
	'if(Cbool(val)) then
		'boolChangeStatusOrder = true
	'end if

	Set orderField = objXML.getElementsByTagName("orderid_confirmed")
	order = orderField(0).childNodes(0).nodeValue
	if(Cint(order) <> -1) then
		idOrdine = order
	else
		idOrdine = -1
	end if
	
	'response.write("idOrdine after xml: "&idOrdine&"<br>")
	'response.end

	set items = nothing
	Set objXML = nothing
	set objHttp = nothing	

	if(Cint(idOrdine) <> -1) then		
		dim objOrdine, objTmp, objTmpValue, tipoPagam, objOrdineTmp, id_utente		
		Dim id_ordine, totale_ord, pagam_done
		Set objOrdineTmp = objOrdine.findOrdineByID(idOrdine, 0)

		Dim strMail, objUserTmp, objUserStatic
		Set objUserStatic = New UserClass
		id_utente = objOrdineTmp.getIDUtente()				
		Set objUserTmp = objUserStatic.findUserByID(id_utente)
		strMail = objUserTmp.getEmail()
		Set objUserTmp = nothing
		Set objUserStatic = nothing
		
		id_ordine = objOrdineTmp.getIDOrdine()
		totale_ord = objOrdineTmp.getTotale()
		pagam_done =objOrdineTmp.getPagamEffettuato()
		
		Set objOrdineTmp = nothing

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		call objOrdine.changePagamDoneOrder(idOrdine, 0, objConn)
		call objOrdine.changeStateOrder(idOrdine, 4, objConn)			
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
		end if			
		Set objDB = nothing		
				
		'Spedisco la mail di conferma annullamento ordine ordine
		Dim objMail
		Set objMail = New SendMailClass
		call objMail.sendMailOrder(id_ordine, Application("mail_order_receiver"), 1, Application("str_editor_lang_code_default"))
		call objMail.sendMailOrder(id_ordine, strMail, 0, lang.getLangCode())
		Set objMail = Nothing	
	else
		fault_motivation = fault_motivation & "<br/>"&lang.getTranslated("portal.commons.errors.label.obj_no_found")
	end if
			
	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		fault_motivation = fault_motivation &"<br/>"&Err.description
	end if
end if

Set objOrdine = nothing
Set objModuleList = nothing
Set objModulePayment = nothing

response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Server.URLEncode(fault_motivation))%>