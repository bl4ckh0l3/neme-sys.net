<%@control Language="c#" description="tellafriend-widget-control" className="TellaFriendWidgetControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService confservice;

private string _index;	
public string index {
	get { if(!String.IsNullOrEmpty(_index)){return _index;}else{return "tellafriend_container";} }
	set { _index = value; }
}
private string _style;	
public string style {
	get { if(_style!=null){return _style;}else{return "";} }
	set { _style = value; }
}
private string _cssClass;	
public string cssClass {
	get { if(_cssClass!=null){return _cssClass;}else{return "";} }
	set { _cssClass = value; }
}

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(object sender, EventArgs e) 
{	
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	confservice = new ConfigurationService();

	//se il sito � offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		Response.Redirect(CommonService.getBaseUrl(Request.Url.ToString(),2).ToString());
	}
}	
</script>

<script>
function controllaCampiInput(){
	if(document.form_tellafriend.user_mail.value == ""){
		alert("<%=lang.getTranslated("frontend.tellafriend.js.alert.insert_user_mail")%>");
		document.form_tellafriend.user_mail.focus();
		return false;
	}	
	if(document.form_tellafriend.friend_mails.value == ""){
		alert("<%=lang.getTranslated("frontend.tellafriend.js.alert.insert_mail_to")%>");
		document.form_tellafriend.friend_mails.focus();
		return false;
	}	

	<%if(confservice.get("use_recaptcha").value == "1") {%>
		// VECCHIA FUNZIONE PER CAPTCHA 	
		if(document.form_tellafriend.captchacode.value == ""){
			alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
			document.form_tellafriend.captchacode.focus();
			return false;
		}
	<%}else if(confservice.get("use_recaptcha").value == "2"){%>
		// FUNZIONE PER RECAPTCHA  
		if(document.form_tellafriend.recaptcha_response_field.value == ""){
			alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
			document.form_tellafriend.recaptcha_response_field.focus();
			return false;
		}
	<%}%>
  
	var query_string = "user_mail="+document.form_tellafriend.user_mail.value+"&friend_mails="+document.form_tellafriend.friend_mails.value+"&message="+document.form_tellafriend.message.value+"&page_url="+document.form_tellafriend.page_url.value+"&captchacode="+document.form_tellafriend.captchacode.value;
	//alert(query_string);
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=CommonService.getBaseUrl(Request.Url.ToString(),2).ToString()%>public/layout/addson/user/ajaxtellafriend.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			$(".imgError").empty();
			$(".imgError").append("<%=lang.getTranslated("frontend.tellafriend.label.mail_sent")%>");
			$('#<%=index%>').fadeOut(3000);
			
		},
		error: function() {
			$(".imgError").empty();
			$(".imgError").append("<%=lang.getTranslated("frontend.area_user.manage.label.wrong_captcha_code")%>");
		}
	});	
}

function RefreshImage(valImageId) {
	var objImage = document.images[valImageId];
	if (objImage == undefined) {
		return;
	}
	var now = new Date();
	objImage.src = objImage.src.split('?')[0] + '?x=' + now.toUTCString();
}
</script>
<div id="<%=index%>" style="<%=style%>" class="<%=cssClass%>">
	<form method="post" name="form_tellafriend" action="" accept-charset="UTF-8">
		<input type="hidden" name="page_url" value="<%=Request.Url%>" />
		<%=lang.getTranslated("frontend.tellafriend.label.insert_user_mail")%><br/><input type="text" name="user_mail" value="" /><br/><br/>
		<%=lang.getTranslated("frontend.tellafriend.label.insert_mail_list")%><br/><input type="text" name="friend_mails" value="" class="formFieldTXTLong"/><br/><br/>
		<%=lang.getTranslated("frontend.tellafriend.label.insert_mail_msg")%><br/><textarea name="message" class="formFieldTXTLong"></textarea><br/><br/>
		<div align="center" style="text-align:left;">
		<span class=imgError></span><br/>
		<%
		if(confservice.get("use_recaptcha").value == "1"){%>
			<img id="imgCaptcha" width="210" align="left" style="padding-right:10px;" src="/common/include/captcha/base_captcha.aspx"/>
			<a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%=lang.getTranslated("frontend.area_user.manage.label.change_captcha_img")%></a>
			<br/><input name="captchacode" style="margin-top:3px;" type="text" id="captchacode" /><br/><br/>            
			<%}else if(confservice.get("use_recaptcha").value == "2"){%>
			<br/><%=CaptchaService.renderRecaptcha()%><br/>
		<%}%>
		</div>
		<input type="button" value="submit" onclick="javascript:controllaCampiInput();" />
	</form>
</div>