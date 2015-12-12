<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<script>
function sendForm(){
	var doSubmit = true;
	if(document.login.j_username.value == ""){
		alert("<%=lang.getTranslated("frontend.login.js.alert.insert_username")%>");
		document.login.j_username.focus();
		return false;
		
	}
	
	if(document.login.j_password.value == ""){
		alert("<%=lang.getTranslated("frontend.login.js.alert.insert_password")%>");
		document.login.j_password.focus();
		return false;
	}
		
	document.login.submit();
}

function sendFormLostPwd(){
	if(document.lost_pwd.j_username.value == ""){
		alert("<%=lang.getTranslated("frontend.login.js.alert.insert_username")%>");
		document.lost_pwd.j_username.focus();
		return false;
	}
	
	if(document.lost_pwd.j_email.value == ""){
		alert("<%=lang.getTranslated("frontend.login.js.alert.insert_mail")%>");
		document.lost_pwd.j_email.focus();
		return false;
	}
		
	document.lost_pwd.submit();
}

function fadeDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;
	
	if($(jquery_id).is(':visible')){
		$(jquery_id).hide('slow');
		element.style.visibility = 'hidden';
		element.style.display = "none";
	}else if($(jquery_id).is(':hidden')){
		$(jquery_id).show('slow');	
		element.style.visibility = 'visible';	
		element.style.display = "block";
	}
	
	if(elemID=="login" && $(jquery_id).is(':hidden')){
		$("#login-lostpwd").html("<%=lang.getTranslated("frontend.login.label.login_mask")%>");	
	}else if(elemID=="lost-pwd" && $(jquery_id).is(':hidden')){
		$("#login-lostpwd").html("<%=lang.getTranslated("frontend.login.label.lost_pwd")%>");	
	}
}
</script>
</head>
<body onload="document.login.j_username.focus()">

<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->
	<div id="container">    	
		<div id="menu-left"></div>
		<div id="content-center">
			<h1><%=lang.getTranslated("frontend.login.label.login_needed")%></h1>
			
			<%=strErrorMessage%>
			
			<div id="login" style="visibility:visible;display:block;">
			<form name="login" method="post" action="<%=strLoginAction%>" onsubmit="return sendForm();">
			<input name="from" type="hidden" value="<%=request("from")%>" />			
			<h3>Username</h3>
			<input name="j_username" type="text" class="larghezza100" />
			<h3>Password</h3>
			<input name="j_password" type="password" class="larghezza100" />
			
			<p><input type="checkbox" value="1" name="keep_logged">&nbsp;<%=lang.getTranslated("frontend.login.label.keep_logged")%>			
			<span id="allinea-destra"><input name="login" type="submit" value="login" /></span></p>
			</form>
			</div>
			
			<div id="lost-pwd" style="visibility:hidden;display:none;">
			<form name="lost_pwd" method="post" action="<%=strLoginAction%>" onsubmit="return sendFormLostPwd();">
			<input name="from" type="hidden" value="lost_pwd" />
			<input name="lang_mail" type="hidden" value="<%=lang.getLangcode()%>" />			
			<h3>Username</h3>
			<input name="j_username" type="text" class="larghezza100" />			
			<h3 class="lost-pwd-mail">Email</h3>
			<input name="j_email" type="text" class="larghezza100" />
			
			<p><input type="checkbox" value="1" name="keep_logged">&nbsp;<%=lang.getTranslated("frontend.login.label.keep_logged")%>			
			<span id="allinea-destra"><input name="login" type="submit" value="login" /></span></p>
			</form>
			</div>
			
			<p><a id="login-lostpwd" href="javascript:fadeDiv('login');fadeDiv('lost-pwd');"><%=lang.getTranslated("frontend.login.label.lost_pwd")%></a></p>

			<h2><%=lang.getTranslated("frontend.login.label.no_yet_reg")%></h2>
			<p><%=lang.getTranslated("frontend.login.label.compile_module")%></p>
			<a href="<%=Application("baseroot")&"/area_user/manageUser.asp"%>"><%=lang.getTranslated("frontend.login.label.registration")%></a>
			<div class="spese-div"></div>
		</div>
		<div id="menu-right"></div>
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>