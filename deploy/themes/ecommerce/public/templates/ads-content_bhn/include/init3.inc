<%
function TestCaptcha(byval valSession, byval valCaptcha)
	dim tmpSession
	valSession = Trim(valSession)
	valCaptcha = Trim(valCaptcha)
	if (valSession = vbNullString) or (valCaptcha = vbNullString) then
		TestCaptcha = false
	else
		tmpSession = valSession
		valSession = Trim(Session(valSession))
		Session(tmpSession) = vbNullString

		if valSession = vbNullString then
			TestCaptcha = false
		else
			valCaptcha = Replace(valCaptcha,"i","I")
			if StrComp(valSession,valCaptcha,1) = 0 then
				TestCaptcha = true
			else
				TestCaptcha = false
			end if
		end if		
	end if
end function

Dim templateContactPath

' recupero url corrente per definire path a send.asp
tmpurl = request.ServerVariables("URL")
tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
      
if(Application("use_recaptcha") = 0) then
	'************* FUNZIONE PER IL VECCHIO CAPTCHA
  ' verifico che il codice captcha inserito dall'utente corrisponda con il captcha generato
  ' in caso contrario rimando alla pagine di registrazione con errore
  ' devo usare campo hidden perchè originale ( request("captchacode") ) non viene recuperato
  if not TestCaptcha("ASPCAPTCHA",  request("sent_captchacode")) then
    response.Redirect(tmpurl&"detail.asp?captcha_err=1&gerarchia="&request("gerarchia")&"&id_news="&request("id_news"))
  end if
else
	'************* RECUPERO PARAMETRI RECAPTCHA
	Dim recaptcha_challenge_field, recaptcha_response_field, recaptcha_private_key, recaptcha_public_key, cTemp
	recaptcha_challenge_field  = request("sent_recaptcha_challenge_field")
	recaptcha_response_field   = request("sent_recaptcha_response_field")
	recaptcha_private_key      = Application("recaptcha_priv_key")
	recaptcha_public_key       = Application("recaptcha_pub_key")

	'************* CHECK VALORE RECAPTCHA
	cTemp = recaptcha_confirm(recaptcha_private_key, recaptcha_challenge_field, recaptcha_response_field)
	If cTemp <> "" Then 
    response.Redirect(tmpurl&"detail.asp?captcha_err=1&gerarchia="&request("gerarchia")&"&id_news="&request("id_news"))
	end if
end if

Dim id_ads, mailText, ads_id_user, mailTo, ads_title
id_ads = request("id_ads")
ads_title = request("ads_title")
ads_id_user = request("ads_id_user")
Set objU = new UserClass
mailTo = objU.findUserByID(ads_id_user).getEmail()
Set objU = nothing
mailText =  request("testo")

subtmpurl = Mid(tmpurl,InStr(1,tmpurl,Application("dir_upload_templ"),1)+Len(Application("dir_upload_templ")),InStrRev(tmpurl,"/",-1,1))
templateContactPath = subtmpurl&"mail.asp"

Set objMail = New SendMailClass
call objMail.sendMailAds(mailTo, mailText, id_ads, ads_title, templateContactPath, lang.getLangCode())
Set objMail = Nothing

pageTemplateTitle = lang.getTranslated("frontend.page.title")

Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
