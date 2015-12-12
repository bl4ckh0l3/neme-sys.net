<%On Error Resume Next%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<%
'*** verifico se e' stata passata la lingua dell'utente e la imposto come langEditor.setLangCode(xxx)
if not(isNull(request("lang_code"))) AND not(request("lang_code")="") AND not(request("lang_code")="null")  then
	langEditor.setLangCode(request("lang_code"))
	langEditor.setLangElements(langEditor.getListaElementsByLang(langEditor.getLangCode()))
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
<title><%=langEditor.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<%
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<link rel="stylesheet" href="<%="http://" & request.ServerVariables("SERVER_NAME") & Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->
	<div id="backend-content">
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.intro")%></span><br><br>
		
		<%if(is_gift)then%>		
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.username_ref")%>:</span>&nbsp;<%=strUsername%><br><br>
		<%end if%>
		
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.voucher_code")%>:</span>&nbsp;<%=voucher_code%><br><br>
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.value")%>:</span>&nbsp;<%=value_label%><br><br>
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.max_usage")%>:</span>&nbsp;<%=max_usage%><br><br>
		<%if(enable_date<>"")then%>		
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.enable_date")%>:</span>&nbsp;<%=enable_date%><br><br>
		<%end if%>
		<%if(expire_date<>"")then%>		
		<span class="labelMailSend"><%=langEditor.getTranslated("backend.voucher.mail.label.expire_date")%>:</span>&nbsp;<%=expire_date%><br><br>
		<%end if%>
	</div>
</div>
</body>
</html>
<%

if(Err.number <> 0) then
	'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>
