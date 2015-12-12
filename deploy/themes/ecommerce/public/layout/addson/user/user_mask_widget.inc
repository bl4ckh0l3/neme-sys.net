<div id="user-mask-widget">     
<%if isEmpty(Session("objUtenteLogged")) then
	Dim strLoginAction
	strLoginAction = base_url&Application("srt_default_server_name")&Application("baseroot")&"/common/include/VerificaUtente.asp"
	If Request.ServerVariables("HTTPS") = "off" AND Application("use_https") = 1 Then
	strLoginAction = "https://"&Application("srt_default_server_name")&Application("baseroot")&"/common/include/VerificaUtente.asp"
	End If%>
	<script>
	function sendLoginForm(){
		if(document.login.j_username.value == "<%=lang.getTranslated("frontend.login.label.username")%>"){
			document.login.j_username.value = "";
		}
		if(document.login.j_username.value == ""){
			alert("<%=lang.getTranslated("frontend.login.js.alert.insert_username")%>");
			document.login.j_username.focus();
			return false;						
		}

		if(document.login.j_password.value == ""){
			alert("<%=lang.getTranslated("frontend.login.js.alert.insert_password")%>");
			/*if(document.getElementById('divpwd2').style.display=="visible"){
			document.login.j_password.focus();
			}*/
			return false;
		}					

		document.login.submit();
	}

	function cleanLoginField(formfieldId){
		var elem = document.getElementById(formfieldId);
		elem.value="";
	}

	function restoreLoginField(formfieldId, valueField){
		var elem = document.getElementById(formfieldId);
		if(elem.value==''){
			elem.value=valueField;
		}
	}
	</script>
	<h2><a href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&"/login.asp"%>"><%=lang.getTranslated("frontend.menu.label.login_button")%></a></h2>
	<form name="login" method="post" action="<%=strLoginAction%>" onsubmit="return sendLoginForm();">
		<input type="hidden" name="from" value="<%=request("from")%>">
		<input type="text" name="j_username" id="j_username" value="<%=lang.getTranslated("frontend.login.label.username")%>" onfocus="cleanLoginField('j_username');" onBlur="restoreLoginField('j_username','<%=lang.getTranslated("frontend.login.label.username")%>');">
		<br/><br/>        
		<input name="j_password" id="j_password" type="text" value="<%=lang.getTranslated("frontend.login.label.password")%>" />
		<script>
		$('#j_password').focus(function() {        
			$('#j_password').val("");
			document.getElementById('j_password').setAttribute('type', 'password');
		});

		/*$('#j_password').blur(function() {          
		document.getElementById('j_password').setAttribute('type', 'text');
		$('#j_password').val("<%=lang.getTranslated("frontend.login.label.password")%>");
		});*/
		</script>           
		<br/><br/>
		<input type="checkbox" value="1" name="keep_logged">&nbsp;<span><%=lang.getTranslated("frontend.login.label.keep_logged")%></span>
		<input name="sendForm" type="submit" value="<%=lang.getTranslated("frontend.menu.label.login_button")%>"/>
	</form>
<%else
	Dim objUsrLog, objUsrLogTmp, strUsrN, nIDUsr,hasAv
	Set objUsrLogTmp = new UserClass
	Set objUsrLog = objUsrLogTmp.findUserByID(Session("objUtenteLogged"))
	strUsrN = objUsrLog.getUserName()
	nIDUsr=objUsrLog.getUserID()
	hasAv =  objUsrLog.hasImageUser(nIDUsr)
	Set objUsrLog = nothing
	Set objUsrLogTmp = nothing%>     	      
	<h2><%=lang.getTranslated("frontend.header.label.utente")%>&nbsp;<em><%=strUsrN%></em></h2>
	<script>
	$(function() {
		$(".imgAvatarUser").aeImageResize({height: 50, width: 50});
	});
	</script>
	<%if(hasAv)then%>
		<img class="imgAvatarUser" src="<%=Application("baseroot") & "/common/include/userImage.asp?userID="&nIDUsr%>" <%If (InStr(1, Request.ServerVariables("HTTP_USER_AGENT"), "MSIE",1) > 0) then response.write(" width=50 height=50") end if%> />
	<%else%>
		<img class="imgAvatarUser" src="<%=Application("baseroot") & "/common/img/unkow-user.jpg"%>" <%If (InStr(1, Request.ServerVariables("HTTP_USER_AGENT"), "MSIE",1) > 0) then response.write(" width=50 height=50") end if%> />
	<%end if%>
	<!--nsys-modcommunity2-->
  <a href="<%=Application("baseroot")&"/area_user/userprofile.asp"%>"><%=lang.getTranslated("frontend.area_user.manage.label.profile")%></a>
  <!---nsys-modcommunity2-->
  <!--nsys-incecom1-->
	<a href="<%=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?ext_ger=card"%>"><%=lang.getTranslated("frontend.area_user.index.label.go_to_carrello")%></a>
	<a href="<%=Application("baseroot")&"/area_user/ListaOrdini.asp"%>"><%=lang.getTranslated("frontend.area_user.index.label.list_ordini")%></a>
  <!---nsys-incecom1-->
	<%if(Application("enable_user_content")=1)then%><a href="<%=Application("baseroot")&"/area_user/ads/ListaNews.asp"%>"><%=lang.getTranslated("backend.menu.item.contenuti.lista")%></a><%end if%>
	<a href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&"/common/include/LogOFF.asp"%>"><%=lang.getTranslated("frontend.header.label.logoff")%></a>
  <!--nsys-modcommunity3-->
	<!-- #include virtual="/public/layout/addson/user/user_profile_widget.inc" -->
  <!---nsys-modcommunity3-->
	<div id="clear"></div>	
<%end if%>
</div>	