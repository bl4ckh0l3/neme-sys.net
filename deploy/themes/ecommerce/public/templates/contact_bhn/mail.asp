<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<%
Dim userMail, mailText, nome, cognome, telefono, indirizzo, zipcode, citta, nazione

'*** verifico se e' stata passata la lingua dell'utente e la imposto come lang.setLangCode(xxx)
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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<style>
* { margin:0; padding:0; }
body, html { background:url(/common/img/page-background.png) repeat-x top left; text-align:center; margin:0 auto; font-family:Arial, Helvetica, sans-serif; color:#333333;}
a { color:#333333;}
img { border:none; }
#warp { margin:0 auto; width:900px; height:100%; text-align:center; background:#FFFFFF;}
#content-center{ width:480px; padding:10px; text-align:left; font-size:13px;}
</style>
</head>
<body>
<div id="warp">
	<div id="container">	
		<div id="content-center">
		<b><%=lang.getTranslated("backend.utenti.mail.label.intro")%></b><br><br>
		<%=lang.getTranslated("backend.utenti.mail.label.intro_detail")%><br><br>
		
		<b><%=lang.getTranslated("backend.utenti.mail.label.name")%>:</b>&nbsp;<%=nome%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.surname")%>:</b>&nbsp;<%=cognome%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.email")%>:</b>&nbsp;<%=userMail%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.telephone")%>:</b>&nbsp;<%=telefono%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.address")%>:</b>&nbsp;<%=indirizzo%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.zipcode")%>:</b>&nbsp;<%=zipcode%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.city")%>:</b>&nbsp;<%=citta%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.country")%>:</b>&nbsp;<%=nazione%><br><br>
		<b><%=lang.getTranslated("backend.utenti.mail.label.message")%>:</b>&nbsp;<%=mailText%><br><br>
		</div>
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
