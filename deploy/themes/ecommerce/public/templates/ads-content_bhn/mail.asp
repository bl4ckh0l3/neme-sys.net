<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<%
Dim userMail, mailText, nome, cognome, telefono, indirizzo, zipcode, citta, nazione

'*** verifico se e' stata passata la lingua dell'utente e la imposto come lang.setLangCode(xxx)
if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
	lang.setLangCode(request("lang_code"))
	lang.setLangElements(lang.getListaElementsByLang(lang.getLangCode()))
end if

id_ads= request("id_ads")
mailText= request("mailText")
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
		<b><%=lang.getTranslated("frontend.template_ads.label.intro")%></b><br><br>
		<b><%=lang.getTranslated("frontend.template_ads.label.testo_mail")%>:</b>&nbsp;<%=mailText%><br><br>
		</div>
	</div>
</div>
</body>
</html>
