<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/common/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="LoginBody" TagName="insert" Src="~/public/layout/include/login.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{

	//UriBuilder builder = new UriBuilder(Request.Url.Scheme|"https", Request.Url.Host, Request.Url.Port, Request.Url.AbsolutePath);
	//builder.Fragment = "main";	
	//Response.Write("builder.Scheme:"+builder.Scheme.ToString()+"<br>");
	//Response.Write("builder.Host:"+builder.Host.ToString()+"<br>");
	//Response.Write("builder.Port:"+builder.Port.ToString()+"<br>");
	//Response.Write("builder.Path:"+builder.Path.ToString()+"<br>");
	//Response.Write("builder.Uri.AbsolutePath:"+builder.Uri.AbsolutePath+"<br>");
	//Response.Write("builder Complete:"+builder.ToString());
	
	//UriBuilder builder = new UriBuilder(Request.Url);
	//builder.Scheme = "http";
	//builder.Port = -1;
	//builder.Path = "default.aspx";
	//Response.Write("builder URI:"+builder.ToString());


	lang.set();
	IUserRepository userep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	ConfigurationService configuration = new ConfigurationService();
	string username = Request["j_username"];
	string password = Request["j_password"];
	string email = Request["j_mail"];
	string keepLogged = Request["keep_logged"];
	string backurl = Request["from"];

	if(backurl=="lost_pwd")
	{
		User lostPwdBeLogged = userep.getByUsernameAndMail(username, email);
			
		//'**** CREO IL GUID PER IL NUOVA PASSWORD
		string newpwd = Guids.createPasswordGuid();
	
		if(lostPwdBeLogged!=null){	
			//'Aggiorno password su DB
			newpwd = userep.getMd5Hash(newpwd);
			lostPwdBeLogged.password = newpwd;
			userep.update(lostPwdBeLogged);
	
			//'Spedisco la mail di recupero password
			//Dim objMail
			//Set objMail = New SendMailClass
			//call objMail.sendMailUserPwd(objUtenteVerify.getUserID(), strGUID, strParamMail, langMail)
			//Set objMail = Nothing



			ListDictionary replacements = new ListDictionary();
			replacements.Add("<%intro%>",lang.getTranslated("backend.utenti.mail.label.intro"));
			replacements.Add("<%intro_detail%>",lang.getTranslated("backend.utenti.mail.label.intro_detail"));
			replacements.Add("<%password%>",newpwd);	
			replacements.Add("<%username%>",lostPwdBeLogged.username);	
			replacements.Add("mail_receiver",lostPwdBeLogged.email);	
			UriBuilder builder = new UriBuilder(Request.Url);
			builder.Scheme = "http";
			builder.Port = -1;
			builder.Path="";
			try
			{
				MailService.prepareAndSend("user-send-lost-pwd", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, builder.ToString());
			}
			catch(Exception ex){
				StringBuilder url = new StringBuilder("/error.aspx?error_code=");						
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));				
				Response.Redirect(url.ToString());
			}
		
			Response.Redirect("~/login.aspx?messages=001");	
		}else{
			Response.Redirect("~/login.aspx?error_code=002");		
		}		
	}
	
	if(Request["j_username"]!=null)
	{
		User toBeLogged = new User(); 
		toBeLogged.username = username;
		toBeLogged.password = password;
		toBeLogged = userep.login(toBeLogged);
		if(toBeLogged != null){
			//Response.Write("<b>after login: toBeLogged != null - toString: </b>"+toBeLogged.ToString()+" - Session.SessionID:"+Session.SessionID+"<br>");
			Session["user-logged"]=toBeLogged;

			
			//'**** GESTISCO LA SCRITTURA DEL COOKIE PER MANTENERE L'UTENTE LOGGATO
			if(keepLogged == "1"){	
				HttpCookie keepLoggedUser = new HttpCookie("KeepLoggedUser");
				keepLoggedUser.Value = Convert.ToString(toBeLogged.id);
				keepLoggedUser.Expires = DateTime.Now.AddMonths(6);	
				Response.Cookies.Add(keepLoggedUser);
				//Response.Write("<b>cokie name:</b>"+Request.Cookies["KeepLoggedUser"].Name+" - value: "+Request.Cookies["KeepLoggedUser"].Value+"<br>");
			}

			if(toBeLogged.role.isAdmin() || toBeLogged.role.isEditor())
			{		
				Response.Redirect("~/backoffice/index.aspx");
			}
			else
			{
				Session["user-online"] = toBeLogged;				
				
				/*
				string userAvatar = "";				
				UserAttachment avatar = UserService.getUserAvatar(toBeLogged);
				if(avatar != null)
				{
					userAvatar = avatar.filePath+avatar.fileName;
				}
				
				StringBuilder builder = new StringBuilder()
				.Append(toBeLogged.id)
				.Append("|").Append(toBeLogged.isPublicProfile)
				.Append("|").Append(userAvatar)
				.Append("|").Append(toBeLogged.username);
			
				Session["user-online"]= builder.ToString();
				*/
				
				UserService.addOnlineUser(Session.SessionID, toBeLogged);			
			

				//IDictionary<string, User> users = UserService.getOnlineUsers();
				//foreach(string k in users.Keys){
					//Response.Write("<b>keyword: </b>"+k+" - value: "+users[k].ToString()+"<br>");
				//}
				//Response.Write("<b>backurl: </b>"+backurl+"<br>");
				switch(backurl)
				{
					case "modify_user":
						Response.Redirect("/area_user/account.aspx");
						//Response.Write("<b>modify: </b> /area_user/manageuser.aspx<br>");
						break;
					//case "lost_pwd":
						//Response.Redirect("/area_user/manageuser.aspx");
						//Response.Write("<b>lost_pwd: </b> /area_user/manageuser.aspx<br>");
						//break;
					case "area_user":
						Response.Redirect("/area_user/account.aspx");
						//Response.Redirect("/default.aspx");
						//Response.Write("<b>area_user: </b> /default.aspx<br>");
						break;
					case "shopcard":
						Response.Redirect("/public/templates/shopping-cart/checkout.aspx");
						//Response.Write("<b>shopcard: </b> /public/templates/shopping-card/checkout.aspx<br>");
						break;
					case "default":
						Response.Redirect("/default.aspx");
						//Response.Write("<b>default: </b> /default.aspx<br>");
						break;
					default:
						if (!String.IsNullOrEmpty(backurl)){
							Response.Redirect(backurl);
							//Response.Write("<b>backurl: </b> "+backurl+"<br>");
						}
						Response.Redirect("/default.aspx");
						//Response.Write("<b>default: </b> /default.aspx<br>");
						break;
				}			
			}
		}
		else
		{
			//Response.Write("<b>error after login: toBeLogged == null</b><br>");
			//_reqmessage = lang.getTranslated(langRepository.convertErrorCode("001"));
			Response.Redirect("~/login.aspx?error_code=003");
		}	 
	}

	//Response.Write("<br>username: "+Request["j_username"]);

	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
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
	
	if(document.lost_pwd.mail_to.value == ""){
		alert("<%=lang.getTranslated("frontend.login.js.alert.insert_mail")%>");
		document.lost_pwd.mail_to.focus();
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
<body onload="document.login.j_username.focus();">
<LoginBody:insert runat="server" />
</body>
</html>