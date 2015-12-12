<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/captcha/adovbs.asp"-->
<!-- #include virtual="/common/include/captcha/iasutil.asp"-->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init1.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%>
<link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css">
<%end if%>
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
	
	if(document.form_send_mail.nome.value == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_nome")%>");
		document.form_send_mail.nome.focus();
		return false;
	}	
	
	/*if(document.form_send_mail.cognome.value == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_cognome")%>");
		document.form_send_mail.cognome.focus();
		return false;
	}*/
	
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
	
	/*if(document.form_send_mail.telefono.value == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_telefono")%>");
		document.form_send_mail.telefono.focus();
		return false;
	}		
	
	if(document.form_send_mail.nazione.value == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_country")%>");
		document.form_send_mail.nazione.focus();
		return false;
	}		
	
	if(!document.form_send_mail.acceptPrivacy.checked){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.confirm_privacy")%>");
		return false;
	}*/	

  <%if(Application("use_recaptcha") = 0) then%>
    if(document.form_send_mail.captchacode.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.captchacode.focus();
      return false;
    }
    
    // imposto campo hidden sent_captchacode 
    // perchè quello originale non viene recuperato in process
    document.form_send_mail.sent_captchacode.value = document.form_send_mail.captchacode.value;
  <%else%>
    // FUNZIONE PER RECAPTCHA  
    if(document.form_send_mail.recaptcha_response_field.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.recaptcha_response_field.focus();
      return false;
    }
      // imposto campo hidden sent_recaptcha_challenge_field e  sent_recaptcha_response_field
    // perchè quello originale non viene recuperato in process
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
<!-- inizio container -->
<div id="container">
	<!-- header -->
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<!-- header fine -->
	<!-- main -->
	<div id="main">		
		<!-- content -->	
		<div class="content">
			<!-- include virtual="/public/layout/include/Menutips.inc" -->
			<div align="left" id="contenuti">
			<%
			'************** codice per la lista news e paginazione
			if(bolHasObj) then%>
				<br/>			
				<%		
				for newsCounter = FromNews to ToNews
					Set objSelNews = objTmpNews(newsCounter)%>
					<div class="contact_container"><p class="title_contenuti"><%=objSelNews.getTitolo()%></p>
					<%if (Len(objSelNews.getAbstract1()) > 0) then response.Write(objSelNews.getAbstract1()) end if
					if (Len(objSelNews.getAbstract2()) > 0) then response.Write(objSelNews.getAbstract2()) end if
					if (Len(objSelNews.getAbstract3()) > 0) then response.Write(objSelNews.getAbstract3()) end if
					if (Len(objSelNews.getTesto()) > 0) then response.Write(objSelNews.getTesto()) end if%>
					</div>
					<%Set objSelNews = nothing
				next%>
				<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "") end if%></div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
			</div>
			
			<div id="profilo-utente" class="form_utente">
			<form action="<%=Application("baseroot") &Application("dir_upload_templ")&"contactus/confirm.asp"%>" method="post" name="form_send_mail" onSubmit="return sendMail();">
			<input type="hidden" name="gerarchia" value="<%=strGerarchia%>">
			<input type="hidden" name="mailTo" value="<%=Application("mail_receiver")%>">
			<input type="hidden" name="sent_captchacode" value="">
			<input type="hidden" name="sent_recaptcha_challenge_field" value="">
			<input type="hidden" name="sent_recaptcha_response_field" value="">

			<!--<h2><%'=lang.getTranslated("frontend.template_contatti.label.testo_intro_mail")%></h2>-->
			<p><%=lang.getTranslated("frontend.template_contatti.label.testo_intro_mail2")%></p>
			<div class="fields">
			<span><%=lang.getTranslated("frontend.template_contatti.label.nome")%> (*)</span>
			<input type="text" name="nome" value="" />
			</div>
			<!--<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.cognome")%> (*)</span>
			<input type="text" name="cognome" value="" />
			</div>-->
			<div class="fields">
			<span><%=lang.getTranslated("frontend.template_contatti.label.email")%> (*)</span>
			<input type="text" name="email" value="" />
			</div>
			<!--<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.telefono")%> (*)</span>
			<input type="text" name="telefono" value="" />
			</div>
			<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.indirizzo")%></span>
			<input type="text" name="indirizzo" value="" />
			</div>
			<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.cap_city")%></span>
			<input type="text" name="citta" value="" style="float:left;width:420px;margin-right:10px;" />
			<input type="text" name="zipcode" value="" style="width:84px;"/>			
			</div>
			<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.nazione")%> (*)</span>
			<input type="text" name="nazione" value="" />
			</div>-->
			<div class="fields">
			<span><%=lang.getTranslated("frontend.template_contatti.label.testo_mail")%></span>
			<textarea name="testo" rows="3"></textarea>
			</div>
			<!--<div class="fields">
			<span><%'=lang.getTranslated("frontend.template_contatti.label.info_privacy")%> (*)</span>
			<textarea name="testo_privacy" class="testo_privacy" rows="3"><%'=lang.getTranslated("frontend.template_contatti.label.info_privacy_law")%></textarea>
			</div>
			<label>
			<input type="checkbox" name="acceptPrivacy" value="1" hspace="0" vspace="0"><%'=lang.getTranslated("frontend.template_contatti.label.privacy_accept")%>
			</label>-->

			<!-- chapta -->
			<div>   
			<% if(request("captcha_err") = 1) then
				response.write("<span class=imgError>"&lang.getTranslated("frontend.template_contatti.label.wrong_captcha_code") & "</span>")
			end if

			if(Application("use_recaptcha") = 0) then%>
			<span><img id="imgCaptcha" src="<%=Application("baseroot")&"/common/include/captcha/base_captcha.asp"%>" /></span>
			<input name="captchacode" type="text" id="captchacode" />
			<a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%'=lang.getTranslated("frontend.template_contatti.label.change_captcha_img")%></a>
			<%else%>
			<%=recaptcha_challenge_writer(Application("recaptcha_pub_key"))%>
			<%end if%> 
			</div>
			<!-- chapta fine -->

			<div class="mandacancella">
			<input type="reset" class="btn_form_cancella" name="reset" value="<%=lang.getTranslated("frontend.template_contatti.button.cancel.label")%>" vspace="0" align="absmiddle">

			<input type="submit" class="btn_form_invia" name="submit" value="<%=lang.getTranslated("frontend.template_contatti.button.send.label")%>" vspace="0" align="absmiddle">
			</div>

			</form>
			</div>			
			<!-- #include virtual="/common/include/captcha/functions.asp"--> 
		</div>
		<!-- content fine -->		
	</div>
	<!-- main fine -->	
</div>
<!-- fine container -->
<!-- #include virtual="/public/layout/include/bottom.inc" -->
</body>
</html>
<%
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>
