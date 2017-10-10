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
	lang.set();
	IUserRepository userep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	ConfigurationService configuration = new ConfigurationService();
	string username = Request["j_username"];
	string password = Request["j_password"];
	string email = Request["j_mail"];
	string keepLogged = Request["keep_logged"];
	string backurl = Request["from"];
	
	string secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();

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
	
			ListDictionary replacements = new ListDictionary();
			replacements.Add("<%intro%>",lang.getTranslated("backend.utenti.mail.label.intro"));
			replacements.Add("<%intro_detail%>",lang.getTranslated("backend.utenti.mail.label.intro_detail"));
			replacements.Add("<%password%>",newpwd);	
			replacements.Add("<%username%>",lostPwdBeLogged.username);	
			replacements.Add("mail_receiver",lostPwdBeLogged.email);	
			
			try
			{
				MailService.prepareAndSend("user-send-lost-pwd", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, secureURL);
			}
			catch(Exception ex){
				StringBuilder url = new StringBuilder()
				.Append(secureURL)
				.Append("error.aspx?error_code=")					
				.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));				
				Response.Redirect(url.ToString());
			}
		
			Response.Redirect(secureURL+"login.aspx?messages=001");	
		}else{
			Response.Redirect(secureURL+"login.aspx?error_code=002");		
		}		
	}
	
	if(Request["j_username"]!=null)
	{
		User toBeLogged = new User(); 
		toBeLogged.username = username;
		toBeLogged.password = password;
		toBeLogged = userep.login(toBeLogged);
		if(toBeLogged != null){
			Session["user-logged"]=toBeLogged;
			
			//'**** GESTISCO LA SCRITTURA DEL COOKIE PER MANTENERE L'UTENTE LOGGATO
			if(keepLogged == "1"){	
				HttpCookie keepLoggedUser = new HttpCookie("KeepLoggedUser");
				keepLoggedUser.Value = Convert.ToString(toBeLogged.id);
				keepLoggedUser.Expires = DateTime.Now.AddMonths(6);	
				Response.Cookies.Add(keepLoggedUser);
			}

			if(toBeLogged.role.isAdmin() || toBeLogged.role.isEditor())
			{		
				Response.Redirect(secureURL+"backoffice/index.aspx");
			}
			else
			{
				Session["user-online"] = toBeLogged;		
				
				UserService.addOnlineUser(Session.SessionID, toBeLogged);			

				switch(backurl)
				{
					case "modify_user":
						Response.Redirect(secureURL+"area_user/account.aspx");
						break;
					case "area_user":
						Response.Redirect(secureURL+"area_user/account.aspx");
						break;
					case "shopcard":
						Response.Redirect(secureURL+"public/templates/shopping-cart/checkout.aspx");
						break;
					case "default":
						Response.Redirect(secureURL+"default.aspx");
						break;
					default:
						if (!String.IsNullOrEmpty(backurl)){
							Response.Redirect(backurl);
						}
						Response.Redirect(secureURL+"default.aspx");
						break;
				}			
			}
		}
		else
		{
			Response.Redirect(secureURL+"login.aspx?error_code=003");
		}	 
	}

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