<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/captcha/adovbs.asp"-->
<!-- #include virtual="/common/include/captcha/iasutil.asp"-->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include virtual="/common/include/captcha/functions.asp"--> 
<!-- #include file="include/init1.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>    
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%> 
<script type="text/javascript" language="JavaScript">
<!--

function sendMail(){
	if(controllaCampiMail()){
		return true;
		//document.form_send_mail.submit();
	}else{
		return false;
	}
}

function controllaCampiMail(){
	
	var strMail = document.form_send_mail.email.value;
	if(strMail != ""){
		if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
			alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.alert.wrong_mail")%>");
			document.form_send_mail.email.focus();
			return false;
		}
	}else if(strMail == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_mail")%>");
		document.form_send_mail.email.focus();
		return false;
	}			
	
	if(!document.form_send_mail.acceptPrivacy.checked){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.confirm_privacy")%>");
		return false;
	}	

  <%if(Application("use_recaptcha") = 0) then%>
    if(document.form_send_mail.captchacode.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.captchacode.focus();
      return false;
    }
    
    // imposto campo hidden sent_captchacode 
    // perch� quello originale non viene recuperato in process
    document.form_send_mail.sent_captchacode.value = document.form_send_mail.captchacode.value;
  <%else%>
    // FUNZIONE PER RECAPTCHA  
    if(document.form_send_mail.recaptcha_response_field.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.recaptcha_response_field.focus();
      return false;
    }
      // imposto campo hidden sent_recaptcha_challenge_field e  sent_recaptcha_response_field
    // perch� quello originale non viene recuperato in process
    document.form_send_mail.sent_recaptcha_challenge_field.value = document.form_send_mail.recaptcha_challenge_field.value;
    document.form_send_mail.sent_recaptcha_response_field.value = document.form_send_mail.recaptcha_response_field.value;
  <%end if%>
	
	return true;
}


function RefreshImage(valImageId) {
	var objImage = document.images[valImageId];
	if (objImage == undefined) {
		return;
	}
	var now = new Date();
	objImage.src = objImage.src.split('?')[0] + '?x=' + now.toUTCString();
}
//-->
</script>
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
		<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">
			<!-- #include virtual="/public/layout/include/menutips.inc" -->
			
			<div align="left" id="contenuti">
			<%
			'************** codice per la lista news e paginazione	
			if(bolHasObj) then%>
				<%for newsCounter = FromNews to ToNews
					Set objSelNews = objTmpNews(newsCounter)%>
					<div><p class="title_contenuti"><%=objSelNews.getTitolo()%></p>
					<%if (Len(objSelNews.getAbstract1()) > 0) then response.Write(objSelNews.getAbstract1()) end if
					if (Len(objSelNews.getAbstract2()) > 0) then response.Write(objSelNews.getAbstract2()) end if
					if (Len(objSelNews.getAbstract3()) > 0) then response.Write(objSelNews.getAbstract3()) end if
					if (Len(objSelNews.getTesto()) > 0) then response.Write(objSelNews.getTesto()) end if%>
					</div><p class="line"></p>
					<%Set objSelNews = nothing
				next%>
				<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "") end if%></div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
			<%
			' recupero url corrente per definire path a confirm.asp
			tmpurl = request.ServerVariables("URL")
			tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
			%>
			<div id="profilo-utente">
			<form action="<%=tmpurl&"confirm.asp"%>" method="post" name="form_send_mail" onSubmit="return sendMail();">
			<input type="hidden" name="gerarchia" value="<%=strGerarchia%>">
			<input type="hidden" name="sent_captchacode" value="">
			<input type="hidden" name="sent_recaptcha_challenge_field" value="">
			<input type="hidden" name="sent_recaptcha_response_field" value="">

			<p><%=lang.getTranslated("frontend.template_contatti.label.testo_intro_mail2")%></p>
			<ul>
			<li><span><%=lang.getTranslated("frontend.template_voucher.label.email_friend")%> (*)</span></li>
			<li><input type="text" name="email" value="" /></li>
			</ul>
			<ul>
			<li><span><%=lang.getTranslated("frontend.template_contatti.label.info_privacy")%> (*)</span></li>
			<li><textarea name="testo_privacy" rows="3"><%=lang.getTranslated("frontend.template_contatti.label.info_privacy_law")%></textarea></li>
			</ul>
			<ul>
			<li><input type="checkbox" name="acceptPrivacy" value="1" hspace="0" vspace="0"><%=lang.getTranslated("frontend.template_contatti.label.privacy_accept")%></li>
			</ul>
			<ul>
			<li>    
			<%
			if(request("captcha_err") = 1) then
			response.write("<span  class=imgError>"&lang.getTranslated("frontend.template_contatti.label.wrong_captcha_code") & "</span><br/>")
			end if

			if(Application("use_recaptcha") = 0) then%>
			<br/><img id="imgCaptcha" src="<%=Application("baseroot")&"/common/include/captcha/base_captcha.asp"%>" />&nbsp;&nbsp;<input name="captchacode" type="text" id="captchacode" />
			<br/><a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%'=lang.getTranslated("frontend.template_contatti.label.change_captcha_img")%></a>
			<%else%>
			<br/><%=recaptcha_challenge_writer(Application("recaptcha_pub_key"))%>
			<%end if%>
			</li>
			</ul>    
			<ul>
			<li><br/><input type="submit" name="submit" value="<%=lang.getTranslated("frontend.template_contatti.button.send.label")%>" vspace="0" align="absmiddle">&nbsp;<input type="reset" name="reset" value="<%=lang.getTranslated("frontend.template_contatti.button.cancel.label")%>" vspace="0" align="absmiddle"></li>
			</ul>
			</div>
			</form>
			</div>		
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>
