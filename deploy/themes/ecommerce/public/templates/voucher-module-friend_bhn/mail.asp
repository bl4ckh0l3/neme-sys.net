<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/VoucherClass.asp" -->
<%
Dim userMail, mailText, nome, cognome, telefono, indirizzo, zipcode, citta, nazione

'*** verifico se e' stata passata la lingua dell'utente e la imposto come lang.setLangCode(xxx)
if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
	lang.setLangCode(request("lang_code"))
	lang.setLangElements(lang.getListaElementsByLang(lang.getLangCode()))
end if

is_gift = request("is_gift")
strUsername=""
voucher_code=request("voucher_code")

Set objVoucher = new VoucherClass
Set objTmpV = objVoucher.findExtendedVoucherByCode(voucher_code)
valore=objTmpV.getValore()
operation=objTmpV.getOperation()
max_usage=objTmpV.getMaxUsage()
enable_date=objTmpV.getEnableDate()
expire_date=objTmpV.getExpireDate()
id_user_ref=objTmpV.getObjVoucherCode().getIdUserRef()

value_label = "&euro;&nbsp;"&valore
if(Cint(operation)=0)then
	value_label=valore&"%"
end if
if(enable_date<>"")then
	enable_date=FormatDateTime(enable_date,2)&" "&FormatDateTime(enable_date,vbshorttime)
end if
if(expire_date<>"")then
	expire_date=FormatDateTime(expire_date,2)&" "&FormatDateTime(expire_date,vbshorttime)
end if

if (not(isNull(id_user_ref)) AND id_user_ref<>"" AND is_gift) then
	Set objUtente = New UserClass
	strUsername=objUtente.findUserByID(id_user_ref).getUserName()
	Set objUtente = nothing
end if

Set objTmpV =nothing
Set objVoucher = nothing
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
		<b><%=lang.getTranslated("backend.voucher.mail.label.intro")%></b><br><br>
		
		<%if(is_gift)then%>		
		<b><%=lang.getTranslated("backend.voucher.mail.label.username_ref")%>:</b>&nbsp;<%=strUsername%><br><br>
		<%end if%>
		
		<b><%=lang.getTranslated("backend.voucher.mail.label.voucher_code")%>:</b>&nbsp;<%=voucher_code%><br><br>
		<b><%=lang.getTranslated("backend.voucher.mail.label.value")%>:</b>&nbsp;<%=value_label%><br><br>
		<b><%=lang.getTranslated("backend.voucher.mail.label.max_usage")%>:</b>&nbsp;<%=max_usage%><br><br>
		<%if(enable_date<>"")then%>		
		<b><%=lang.getTranslated("backend.voucher.mail.label.enable_date")%>:</b>&nbsp;<%=enable_date%><br><br>
		<%end if%>
		<%if(expire_date<>"")then%>		
		<b><%=lang.getTranslated("backend.voucher.mail.label.expire_date")%>:</b>&nbsp;<%=expire_date%><br><br>
		<%end if%>		
		</div>
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
