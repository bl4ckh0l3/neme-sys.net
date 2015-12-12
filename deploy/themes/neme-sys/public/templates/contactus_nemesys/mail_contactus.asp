<%On Error Resume Next%>
<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<%
Dim userMail, mailText, nome, cognome, telefono, indirizzo, zipcode, citta, nazione

'*** verifico se 柳tata passata la lingua dell'utente e la imposto come lang.setLangCode(xxx)
if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
	lang.setLangCode(request("lang_code"))
	lang.setLangElements(lang.getListaElementsByLang(lang.getLangCode()))
end if

userMail= request("userMail")
mailText= request("mailText")
nome= request("nome")
cognome= request("cognome")
telefono= request("telefono")
indirizzo= request("indirizzo")
zipcode= request("zipcode")
citta= request("citta")
nazione= request("nazione")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title><%=langEditor.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Testa Denis; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
		<strong><%=langEditor.getTranslated("backend.utenti.mail.label.intro")%></strong><br><br>
		<%=langEditor.getTranslated("backend.utenti.mail.label.intro_detail")%><br><br>
		
		<strong><%=lang.getTranslated("backend.utenti.mail.label.name")%>:</strong>&nbsp;<%=nome%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.surname")%>:</strong>&nbsp;<%=cognome%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.email")%>:</strong>&nbsp;<%=userMail%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.telephone")%>:</strong>&nbsp;<%=telefono%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.address")%>:</strong>&nbsp;<%=indirizzo%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.zipcode")%>:</strong>&nbsp;<%=zipcode%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.city")%>:</strong>&nbsp;<%=citta%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.country")%>:</strong>&nbsp;<%=nazione%><br><br>
		<strong><%=lang.getTranslated("backend.utenti.mail.label.message")%>:</strong>&nbsp;<%=mailText%><br><br>
</body>
</html>
<%
Set objUtente = nothing

if(Err.number <> 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>
