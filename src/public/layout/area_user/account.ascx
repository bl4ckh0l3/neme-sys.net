<%@control Language="c#" description="user-account-control"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<script runat="server">
	protected ASP.MultiLanguageControl lang;
	protected ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected IList<UserGroup> groupsu;
	protected IList<Language> languages;
	protected IList<Language> usrlanguages;	
	protected IList<Category> categories;
	protected IList<Newsletter> newsletters;
	protected IList<UserField> usrfields;
	protected bool bolFoundFields;
	protected IUserRepository usrrep;	
	protected User user;
	protected UserGroup userGroup;
	protected bool usrHasAvatar;
	protected string avatarPath;
	protected bool usrHasCookie;
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{	
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		login.acceptedRoles = "3";
		bool loggedin = login.checkedUser();
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect("~/backoffice/index.aspx");
		}
		
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		INewsletterRepository newslrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		confservice = new ConfigurationService();

/*<!--nsys-userproc1-->*/
		IVoucherRepository voucherep = RepositoryFactory.getInstance<IVoucherRepository>("IVoucherRepository");
		IList<VoucherCampaign> vcampaignFounds = new List<VoucherCampaign>();
/*<!---nsys-userproc1-->*/
		
		user = new User();	
		user.id = -1;					
		user.userGroup = -1;
		user.role = new UserRole((int)UserRole.Roles.GUEST);
		user.isActive = false;
		if("1" == confservice.get("confirm_registration").value){
			user.isActive = true;
		}		
		user.languages = new List<UserLanguage>();	
		user.categories = new List<UserCategory>();	
		user.newsletters = new List<UserNewsletter>();
		user.fields = new List<UserFieldsMatch>();
		usrHasAvatar = false;
		usrHasCookie = false;
		avatarPath = "";
		userGroup = null;				
		usrlanguages = new List<Language>();	
		usrfields = new List<UserField>();
		bolFoundFields = false;
		
		//recupero i campi dalla sessione se presenti per gestire i form sempre valorizzati
		user.username = (string)Session["s_username"];
		if(!String.IsNullOrEmpty((string)Session["s_public_profile"])){
			user.isPublicProfile = Convert.ToBoolean(Convert.ToInt32(Session["s_public_profile"]));
		}
		user.email = (string)Session["s_email"];
		
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
		StringBuilder happyUrl = new StringBuilder("/area_user/account.aspx");		
		Logger log = new Logger();
		
		// recupero elementi della pagina necessari
		try{				
			userGroup = usrrep.getDefaultUserGroup();
		}catch (Exception ex){
			userGroup = null;
		}
		try{				
			groupsu = usrrep.getAllUserGroup();
			if(groupsu == null){				
				groupsu = new List<UserGroup>();						
			}
		}catch (Exception ex){
			groupsu = new List<UserGroup>();
		}
		try{				
			categories = catrep.getCategoryList();
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{				
			newsletters = newslrep.findActive();		
			if(newsletters == null){				
				newsletters = new List<Newsletter>();						
			}
		}catch (Exception ex){
			newsletters = new List<Newsletter>();
		}
		try{
			List<string> usesFor = new List<string>();
			usesFor.Add("1");
			usesFor.Add("3");
			List<string> applyTo = new List<string>();
			applyTo.Add("0");
			applyTo.Add("2");				
			usrfields = usrrep.getUserFields(true,usesFor,applyTo);
			if(usrfields != null && usrfields.Count>0){
				bolFoundFields = true;
			}else{				
				bolFoundFields = false;					
			}
		}catch (Exception ex){
			usrfields = new List<UserField>();
			bolFoundFields = false;	
		}

		if(login.userLogged != null)
		{
			bool changePathByCookie = false;
			try{
				user = usrrep.getById(login.userLogged.id);
				if(user.languages != null)
				{
					foreach(UserLanguage ul in user.languages)
					{
						foreach(Language l in languages)
						{						
							if(l.id==ul.idLanguage){
								usrlanguages.Add(l);
								break;
							}
						}
					}
				}

				UserAttachment avatar = UserService.getUserAvatar(user);
				if(avatar != null){
					usrHasAvatar = true;
					avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
				}

				HttpCookie userCookie = Request.Cookies["KeepLoggedUser"];
				if(userCookie!=null && !String.IsNullOrEmpty(userCookie.Value)){
					usrHasCookie = true;
				}
				if(Request["del_autologin"]=="1") {
					HttpCookie myCookie = new HttpCookie("KeepLoggedUser");
					myCookie.Expires = DateTime.Now.AddDays(-1d);
					Response.Cookies.Add(myCookie);
					changePathByCookie = true;
				}
				
				if(user.userGroup != -1){
					userGroup = usrrep.getUserGroup(user);
				}
			}catch (Exception ex){
				user = new User();		
				user.id = -1;
				user.userGroup = -1;
				user.role = new UserRole((int)UserRole.Roles.GUEST);
				user.isActive = false;
				if("1" == confservice.get("confirm_registration").value){
					user.isActive = true;
				}
				user.languages = new List<UserLanguage>();	
				user.categories = new List<UserCategory>();	
				user.newsletters = new List<UserNewsletter>();				
				user.fields = new List<UserFieldsMatch>();
				userGroup = null;
				usrfields = new List<UserField>();
				bolFoundFields = false;
				//Response.Write("Exception:"+ex.Message+"<br>");
			}
			
			if(changePathByCookie){
				Response.Redirect(happyUrl.ToString());				
			}	
		}

						
		//******** INSERISCO NUOVO UTENTE / MODIFICO ESISTENTE				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;	
			try
			{
				UriBuilder builder = new UriBuilder(Request.Url);
				builder.Scheme = "http";
				builder.Port = -1;
				builder.Path="";			
			
				// resolve captcha code
				UriBuilder errCaptcha = new UriBuilder(Request.Url);
				errCaptcha.Port = -1;
				errCaptcha.Query = "captcha_err=1";	
				if(confservice.get("use_recaptcha").value == "1"){
					string captchacode = Request["captchacode"];
					if(captchacode.ToLower() != Session["CaptchaImageText"].ToString().ToLower())
					{	
						url = new StringBuilder(errCaptcha.ToString());
						carryOn = false;					
					}
				}else if(confservice.get("use_recaptcha").value == "2"){
					if(CaptchaService.verifyRecaptcha(Request.ServerVariables["REMOTE_ADDR"], Request["recaptcha_challenge_field"], Request["recaptcha_response_field"]))
					{
						carryOn = true;
					}else{
						url = new StringBuilder(errCaptcha.ToString());
						carryOn = false;	
					}
				}
			
				if(carryOn)
				{
					string username = Request["username"];						
					string email = Request["email"];	
					
					// verify mail non already exists
					if(usrrep.userAlreadyExists(username, email, user.id))
					{				
						url.Append("001&id_usr=").Append(user.id);
						carryOn = false;						
					}				
	
					if(carryOn)
					{						
						string password = Request["password"];
						if(!String.IsNullOrEmpty(password)){
							password = usrrep.getMd5Hash(password);	
						}
						bool isPublicProfile = Convert.ToBoolean(Convert.ToInt32(Request["public_profile"]));		
						bool privacy = Convert.ToBoolean(Request["privacy"]);
						bool newsletter = Convert.ToBoolean(Request["newsletter"]);	
						
						user.username = username;
						if(!String.IsNullOrEmpty(password)){
							user.password = password;	
						}
						user.isPublicProfile = isPublicProfile;
						user.email = email;
						user.privacyAccept = privacy;	
						user.hasNewsletter = newsletter;	
						int tmpug = -1;
						if(userGroup != null){
							tmpug = userGroup.id;
						}
						user.userGroup =  tmpug;
						
						// aggiorno lingue e categorie automatiche per i nuovi utenti
						string confirmationCode = ""; 
						bool sendWelcomeMail = false;						
						if(user.id == -1)
						{
							user.languages.Clear();
							if(languages!=null){
								foreach(Language x in languages){
									UserLanguage ul = new UserLanguage();
									ul.idParentUser = user.id;
									ul.idLanguage = x.id;
									user.languages.Add(ul);
								}
							}
		
							user.categories.Clear();
							if(categories!=null){
								foreach(Category x in categories){
									if(x.automatic){
										UserCategory uc = new UserCategory();
										uc.idParentUser = user.id;
										uc.idCategory = x.id;
										user.categories.Add(uc);
									}
								}
							}
							
							// check for user confermation code creation
							if("2" == confservice.get("confirm_registration").value){
								confirmationCode = Guids.createUserGuid();
							}
							
							sendWelcomeMail = true;							
						}
						
						// aggiorno le newsletter utente
						user.newsletters.Clear();
						if(!String.IsNullOrEmpty(Request["list_newsletter"])){
							string[] usrNewsletters = Request["list_newsletter"].Split(',');
							if(usrNewsletters!=null){
								foreach(string x in usrNewsletters){
									UserNewsletter un = new UserNewsletter();
									un.idParentUser = user.id;
									un.newsletterId = Convert.ToInt32(x);
									user.newsletters.Add(un);
									
									
/*<!--nsys-userproc2-->*/
									Newsletter nl = newslrep.getById(un.newsletterId);
									if(nl != null && nl.idVoucherCampaign>0){
										VoucherCampaign campaign = voucherep.getById(nl.idVoucherCampaign);
										if(campaign != null){											
											vcampaignFounds.Add(campaign);
										}
									}
/*<!---nsys-userproc2-->*/									
									
									
								}
							}
						}
	
						// aggiorno i fields utente
						user.fields.Clear();
						foreach(string key in Request.Form.Keys){
							if(key.StartsWith("user_field_")){
								string value = Request.Form[key];
								string fieldid = key.Substring(key.LastIndexOf('_')+1);						
								//Response.Write("key:"+key+" -startswith: "+key.StartsWith("user_field_")+" -fieldid: "+ fieldid + " -value:"+value+" -userid:"+user.id+"<br>");
								
								UserFieldsMatch nufm = new UserFieldsMatch();	
								nufm.idParentField=Convert.ToInt32(fieldid);
								nufm.idParentUser = user.id;
								nufm.value = value;
								user.fields.Add(nufm);		
							}							
						}
						
						// aggiorno avatar utente
						bool bolDelAvatar = false;
						string pathDelAvatar = "";
						HttpFileCollection MyFileCollection = Request.Files;
						HttpPostedFile MyFile;							
						MyFile = MyFileCollection[0];						
						string fileName = Path.GetFileName(MyFile.FileName);

						IList<UserAttachment> newUserAttachment = new List<UserAttachment>();
						if(user.attachments != null && user.attachments.Count>0)
						{								
							if(Request["del_avatar"]=="true"){
								bolDelAvatar = true;
							}
														
							foreach(UserAttachment attachment in user.attachments)
							{
								//Response.Write("UserAttachment: "+attachment.ToString()+"<br>");
								//Response.Write("bolDelAvatar: "+bolDelAvatar+" -attachment.isAvatar: "+attachment.isAvatar+"<br>");
								if((bolDelAvatar && attachment.isAvatar) || (!String.IsNullOrEmpty(fileName) && attachment.isAvatar)){
									pathDelAvatar = attachment.filePath+attachment.fileName;
									bolDelAvatar = true;
									continue;	
								}
								//Response.Write("attachment.fileName==fileName: "+(attachment.fileName==fileName)+"<br>");
								if(attachment.fileName!=fileName){
									newUserAttachment.Add(attachment);
								}
							}
						}
																			
						if(!String.IsNullOrEmpty(fileName))
						{
							switch (Path.GetExtension(fileName))
							{
								case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":						
									UserAttachment uaa = new UserAttachment();
									uaa.fileName=fileName;
									uaa.contentType=MyFile.ContentType;
									uaa.fileLabel="";
									uaa.fileDida="";
									uaa.filePath=user.id+"/";
									uaa.isAvatar = true;
									uaa.idUser = user.id;	
									newUserAttachment.Add(uaa);							
									carryOn = true;
									break;
								default:
									errCaptcha.Query = "error_code=022";	
									url = new StringBuilder(errCaptcha.ToString());
									carryOn = false;										
									break;
							}
						}						
						
						if(carryOn)
						{									
							try
							{
								user.attachments = newUserAttachment;
								usrrep.saveCompleteUser(user,confirmationCode);
								user = usrrep.getById(user.id);	
								
/*<!--nsys-userproc3-->*/								
								if(vcampaignFounds.Count>0){
									foreach(VoucherCampaign vcampaign in vcampaignFounds){
										int generatedCounter = voucherep.countVoucherCodeByCampaign(vcampaign.id, user.id);
										
										if(generatedCounter<vcampaign.maxGeneration || vcampaign.maxGeneration==-1){
											IList<string> existsVoucherCodes = voucherep.getAllVoucherCodes();
											
											string code = "";
											
											bool ahead = true;
											while(ahead) 
											{ 
												code = Guids.createVoucherCodeGuid();
												if (!existsVoucherCodes.Contains(code)) 
												{ 
													ahead=false;
												} 
											} 								
											
											VoucherCode voucher = new VoucherCode();
											voucher.id=-1;
											voucher.code=code;
											voucher.campaign=vcampaign.id;
											voucher.usageCounter=0;
											voucher.userId=user.id;
											voucher.insertDate=DateTime.Now;
							
											voucherep.insertVoucherCode(voucher);
											
											VoucherService.sendVoucherMail(vcampaign, voucher, null, user.email, lang.currentLangCode, lang.defaultLangCode, builder.ToString());
										}
									}
								}								
/*<!---nsys-userproc3-->*/

								log.usr= user.username;
								log.msg = "area user: save user: "+user.ToString();
								log.type = "info";
								log.date = DateTime.Now;
								lrep.write(log);
	
								// aggiorno avatar utente						
								if(bolDelAvatar && !String.IsNullOrEmpty(pathDelAvatar))
								{
									UserService.deleteUserAttachment(pathDelAvatar);								
								}				
								string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+user.id); 
								if (!Directory.Exists(dirName))
								{
									Directory.CreateDirectory(dirName);
								}					
								if(!String.IsNullOrEmpty(fileName))
								{
									TemplateService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+user.id+"/"+MyFile.FileName));								
								}	
									
								// se l'utente aggiornato è l'utente in sessione aggiorno la sessione
								if("1" == confservice.get("confirm_registration").value || !sendWelcomeMail)
									{
									if(login.userLogged != null){
										if(login.userLogged.id == user.id)
										{
											login.updateUserLogged(user);
										}
									}else{
										login.updateUserLogged(user);
									}
								}
								else
								{
									login.updateUserLogged(null);
									string query = "";
									if("2" == confservice.get("confirm_registration").value){query="?id="+user.id+"&reg_code=true";}
									happyUrl = new StringBuilder("/area_user/registration_confirm.aspx").Append(query);
								}
								
								//if new user send welcome mail
								if(sendWelcomeMail)
								{
									ListDictionary replacementsUser = new ListDictionary();
									ListDictionary replacementsAdmin = new ListDictionary();
									StringBuilder userMessage = new StringBuilder();
									StringBuilder adminMessage = new StringBuilder();	
									replacementsUser.Add("mail_receiver",user.email);	
									replacementsAdmin.Add("mail_receiver",confservice.get("mail_receiver").value);
									replacementsUser.Add("<%intro%>",lang.getTranslated("backend.utenti.mail.label.intro"));
									replacementsUser.Add("<%intro_detail%>",lang.getTranslated("backend.utenti.mail.label.intro_detail"));		
									replacementsAdmin.Add("<%intro%>",lang.getTranslated("backend.utenti.mail.label.intro"));
									replacementsAdmin.Add("<%intro_detail%>",lang.getTranslated("backend.utenti.mail.label.intro_detail"));	
																
									string isActivated = lang.getTranslated("portal.commons.yes");
									if(!user.isActive){
										isActivated = lang.getTranslated("portal.commons.no");
										if("2" == confservice.get("confirm_registration").value){
											userMessage.Append(lang.getTranslated("frontend.registration.manage.label.confirm_registration_with_code"))
											.Append(":&nbsp;<a href='").Append(builder.ToString()).Append("area_user/confirmregcode.aspx?id=").Append(user.id).Append("&confirm_reg_code=").Append(confirmationCode).Append("'>")
												.Append(lang.getTranslated("backend.utenti.mail.label.confirm_registration"))
											.Append("</a><br/>")
											.Append(lang.getTranslated("backend.utenti.mail.label.no_link_confirm")).Append("<br/>")
											.Append(builder.ToString()).Append("area_user/confirmregcode.aspx?id=").Append(user.id).Append("&confirm_reg_code=").Append(confirmationCode).Append("<br/><br/>");										
										}
									}
									
									//start user message
									userMessage.Append(lang.getTranslated("frontend.registration.manage.label.username")).Append(":&nbsp;<b>").Append(user.username).Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.password")).Append(":&nbsp;<b>").Append(Request["password"]).Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.email")).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.is_active")).Append(":&nbsp;<b>").Append(isActivated).Append("</b><br/><br/>");		
									
									//start admin message
									adminMessage.Append(lang.getTranslated("frontend.registration.manage.label.username")).Append(":&nbsp;<b>").Append(user.username).Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.password")).Append(":&nbsp;<b>").Append("**************").Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.email")).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>")
									.Append(lang.getTranslated("frontend.registration.manage.label.is_active")).Append(":&nbsp;<b>").Append(isActivated).Append("</b><br/><br/>");									
									
									// gestione lista newsletter
									if(user.newsletters != null && user.newsletters.Count>0){
										userMessage.Append("<b>").Append(lang.getTranslated("frontend.registration.manage.label.iscriz_newsletter")).Append(":</b><br/>");
										adminMessage.Append("<b>").Append(lang.getTranslated("frontend.registration.manage.label.iscriz_newsletter")).Append(":</b><br/>");
										foreach(UserNewsletter un in user.newsletters){
											Newsletter tmp = newslrep.getById(un.newsletterId);
											userMessage.Append(tmp.description).Append("<br/>");		
											adminMessage.Append(tmp.description).Append("<br/>");											
										}
									}
								
									if(user.fields != null && user.fields.Count>0 && usrfields != null && usrfields.Count>0){							
										foreach(UserFieldsMatch f in user.fields){
											string label = "";
											string value = "";
											foreach(UserField uf in usrfields){
												if(uf.id==f.idParentField){
													label = uf.description;
													value = f.value;
													if(uf.typeContent==7 || uf.typeContent==8){
														if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.select.option.country."+f.value))){
															value = lang.getTranslated("portal.commons.select.option.country."+f.value);
														}
													}	
													if(!String.IsNullOrEmpty(lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value))){
														label = lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value);
													}
													break;
												}										
											}
											userMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");
											adminMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");								
										}
									}
									
									replacementsUser.Add("<%content%>",Server.HtmlDecode(userMessage.ToString()));
									replacementsAdmin.Add("<%content%>",Server.HtmlDecode(adminMessage.ToString()));
									//replacements.Add("mail_subject",Request["mail_subject"]);	
									
									MailService.prepareAndSend("user-welcome-mail", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, builder.ToString());
									MailService.prepareAndSend("user-welcome-mail", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacementsAdmin, null, builder.ToString());			
								}
							}
							catch(Exception ex)
							{
								//Response.Write("child repository operation error: "+ ex.Message);
								throw;	
							}	
						}						
					}	
				}
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;
				//Response.Write("parent repository operation error: "+ ex.Message);
			}		
			
			if(carryOn){
				// ripulisco i campi del form dalla sessione
				Session["s_username"] = "";
				Session["s_public_profile"] = "";
				Session["s_email"] = "";	
				foreach(Newsletter newsletter in newsletters){
					Session["s_newsletter_"+newsletter.id] = "";
				}
				// TODO togliere field utente dalla sessione
				
				Response.Redirect(happyUrl.ToString());
			}else{
				// aggiungo i campi del form in sessione
				Session["s_username"] = Request["username"];
				Session["s_public_profile"] = Request["public_profile"];
				Session["s_email"] = Request["email"];
				if(!String.IsNullOrEmpty(Request["list_newsletter"])){
					string[] usrNewsletters = Request["list_newsletter"].Split(',');
					if(usrNewsletters!=null){
						foreach(string x in usrNewsletters){							
							Session["s_newsletter_"+x] = x;
						}
					}
				}
				// TODO aggiungere field utente in sessione
				
				Response.Redirect(url.ToString());
			}								
		}
		else if("delete".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{
				bool deleted = usrrep.delete(user, false);
				login.updateUserLogged(null);
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;				
			}		
			
			if(carryOn){
				Response.Redirect("~/login.aspx?messages=003");
			}else{
				Response.Redirect(url.ToString());
			}
		}
		
		// init menu frontend
		this.mf1.modelPageNum = 1;
		this.mf1.categoryid = "";	
		this.mf1.hierarchy = "";	
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";		
	}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script language="JavaScript">
var step2ok = true;
var step3ok, step4ok = false;

function deleteUser(){
	if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.conf_del")%>")){
		//location.href = "/area_user/userdelete.aspx";
		document.form_delete.submit();
	}

}

function insertUser(){
	if(controllaCampiInput()){
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function checkStep2(){
	step3ok, step4ok = false;
	if(document.form_inserisci.username.value == "<%=lang.getTranslated("frontend.area_user.manage.label.username")%>"){
		document.form_inserisci.username.value = "";
	}	
	if(document.form_inserisci.username.value == ""){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_username")%>");
		document.form_inserisci.username.focus();
		return false;
	}

  <%if(user.id == -1){%>
	if(document.form_inserisci.password.value == ""){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_pwd")%>");
		document.form_inserisci.password.focus();
		return false;
	}	
  <%}%>
	if(document.form_inserisci.password.value != document.form_inserisci.conferma_password.value){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.pwd_no_match")%>");
		document.form_inserisci.conferma_password.focus();
		return false;
	}

	if(document.form_inserisci.email.value == "<%=lang.getTranslated("frontend.area_user.manage.label.email")%>"){
		document.form_inserisci.email.value = "";
	}	
	var strMail = document.form_inserisci.email.value;
	if(strMail != ""){
		if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
			alert("<%=lang.getTranslated("frontend.area_user.js.alert.wrong_mail")%>");
			document.form_inserisci.email.focus();
			return false;
		}
	}else if(strMail == ""){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_mail")%>");
		document.form_inserisci.email.focus();
		return false;
	}	
	<%if (user.id == -1) {%>	
	if(document.form_inserisci.email.value != document.form_inserisci.conferma_email.value){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.email_no_match")%>");
		document.form_inserisci.conferma_email.focus();
		return false;
	}
	<%}%>

	step2ok = false;
	step3ok = true;
	return true;
}

function checkStep3(){
	step4ok = false;
	
	<%if(bolFoundFields) {
		Response.Write(UserService.renderFieldJsFormValidation(usrfields, user, lang.currentLangCode, lang.defaultLangCode));
	}%>
	
	step2ok = false;
	step3ok = false;
	step4ok = true;
	return true;
}

function checkStep4(){
	document.form_inserisci.newsletter.value = "true";
	step2ok = false;
	step3ok = false;
	step4ok = false;
	return true;
}

function checkStep5(){	
	if(document.form_inserisci.privacy.checked == false){
		alert("<%=lang.getTranslated("frontend.area_user.js.alert.privacy_confirm_needed")%>");
		document.form_inserisci.privacy.checked = true;
		return false;
	}


  <%if(confservice.get("use_recaptcha").value == "1") {%>
    // VECCHIA FUNZIONE PER CAPTCHA 	
    if(document.form_inserisci.captchacode.value == ""){
      alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
      document.form_inserisci.captchacode.focus();
      return false;
    }
  <%}else if(confservice.get("use_recaptcha").value == "2"){%>
    // FUNZIONE PER RECAPTCHA  
    if(document.form_inserisci.recaptcha_response_field.value == ""){
      alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
      document.form_inserisci.recaptcha_response_field.focus();
      return false;
    }
      // imposto campo hidden sent_recaptcha_challenge_field e  sent_recaptcha_response_field
    // perchè quello originale non viene recuperato in process
    //document.form_inserisci.sent_recaptcha_challenge_field.value = document.form_inserisci.recaptcha_challenge_field.value;
    //document.form_inserisci.sent_recaptcha_response_field.value = document.form_inserisci.recaptcha_response_field.value;
  <%}%>

	if(document.form_inserisci.del_usrimage){
		if(document.form_inserisci.del_usrimage.checked == false){
			document.form_inserisci.del_avatar.value = "false";	
		}else{
			document.form_inserisci.del_avatar.value = "true";		
		}
	}
		
	return true;
}

function controllaCampiInput(){
	<%if(confservice.get("use_wizard_registration").value ==  "1"){%>	
	return checkStep5();
	<%}else{%>
	if(checkStep2() && checkStep3() && checkStep4() && checkStep5()){return true;}else{return false;}
	<%}%>
}

function replaceChars(inString){
	var outString = inString;

	for(a = 0; a < outString.length; a++){
		if(outString.charAt(a) == '"'){
			outString=outString.substring(0,a) + "&quot;" + outString.substring(a+1, outString.length);
		}
	}
	return outString;
}

function RefreshImage(valImageId) {
	var objImage = document.images[valImageId];
	if (objImage == undefined) {
		return;
	}
	var now = new Date();
	objImage.src = objImage.src.split('?')[0] + '?x=' + now.toUTCString();
}

function checkNewsletter(formField){	
	if(document.form_inserisci.ck_newsletter.checked == false){
		formField.checked = false;
	}	
}

function uncheckNewsletter(){	
	if(document.form_inserisci.ck_newsletter.checked == false){
		if(document.form_inserisci.list_newsletter != null){
			if(document.form_inserisci.list_newsletter.length == null){
				document.form_inserisci.list_newsletter.checked = false;
			}else{
				for(i=0; i<document.form_inserisci.list_newsletter.length; i++){				
					document.form_inserisci.list_newsletter[i].checked = false;
				}
			}
		}
	}	
}

function changeTab(number){
	if(number==1)
		location.href='/area_user/profile.aspx';
	else if(number==2)
		location.href='/area_user/account.aspx';
	else if(number==3)
		location.href='/area_user/friends.aspx';
	else if(number==4)
		location.href='/area_user/photos.aspx';

}
  
function userWizard(step){
	eval("moveStep = step"+step+"ok;");
	
	if(moveStep){
		eval("var action = checkStep"+step+"();");
		if(action==true){
			for (var i=1; i < 5; i++){
				if(i==step){
					showWizardDiv(i);
				}else{
					hideWizardDiv(i);      
				}
			}
		}
	}
}

function showWizardDiv(step){
	var element = document.getElementById('wizard'+step);
  element.style.visibility = "visible";		
  element.style.display = "block";
  
	var elementA = document.getElementById("step"+step);
  elementA.className="active";
}

function hideWizardDiv(step){
	var element = document.getElementById('wizard'+step);
  element.style.visibility = "hidden";
  element.style.display = "none";
  
  var elementA = document.getElementById("step"+step);
  elementA.className="";
}

function showPwdBox(elemId){
	$('#'+elemId).toggle();
	//showHideDiv(elemId);
}

jQuery(document).ready(function(){
<%if(confservice.get("use_wizard_registration").value ==  "0"){%>
   $("#wizard2").show(); 
   $("#wizard3").show();
   $("#wizard4").show();
<%}%>
});
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">
		<form action="/area_user/account.aspx" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">		  
		<input type="hidden" value="<%=user.id%>" name="id">	  
		<input type="hidden" name="operation" value="insert">
		<input type="hidden" name="newsletter" value="<%=user.hasNewsletter%>">
		<input type="hidden" name="del_avatar" value="0">
		
		<h1><%=lang.getTranslated("frontend.header.label.utente_modify")%>&nbsp;<em><%=user.username%></em>
		<%if (user.id != -1) {%>&nbsp;<input name="delete" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.del_user")%>" type="button" onclick="javascript:deleteUser();"><%}%>
		</h1>

<!--nsys-modcommunity1-->
		<p class="area_user_tabs">
		<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.profile")%>" type="button" onclick="javascript:changeTab(1);">
		<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.modify")%>" type="button" class="active" onclick="javascript:changeTab(2);">
		<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.friends")%>" type="button" onclick="javascript:changeTab(3);">
		<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.photos")%>" type="button" onclick="javascript:changeTab(4);">
		</p>
<!---nsys-modcommunity1-->

		<p style="padding-top:10px;padding-bottom:10px;"><%=lang.getTranslated("frontend.area_user.manage.label.txt_intro_registrazione")%></p>
		  
		<%if(confservice.get("use_wizard_registration").value ==  "1"){%>
			<div id="profilo-utente-wizard">
				<span class="active" id="step1">STEP 1</span>&nbsp;-&nbsp;<a href="javascript:userWizard(2);" id="step2">STEP 2</a>&nbsp;-&nbsp;<a href="javascript:userWizard(3);" id="step3">STEP 3</a>&nbsp;-&nbsp;<a href="javascript:userWizard(4);" id="step4">STEP 4</a>
			</div>
		<%}%>        
		<div id="profilo-utente">
      
        <div id="wizard1">
		<h2><%=lang.getTranslated("frontend.header.label.utente_profile_group")%></h2>
			
		<div class="form_reg_container_sx">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.username")%> (*)</span>
		</div>
		<div class="form_reg_container_dx">
		<%if (user.id != -1) {%>
			<em style="padding-left:5px;padding-top:10px; font-weight:bold;"><%=user.username%></em>
			<%if (user.id != -1) {%>&nbsp;&nbsp;<span style="text-decoration:underline;cursor:pointer;" onclick="showPwdBox('change_pwd_box');"><%=lang.getTranslated("frontend.area_user.manage.label.show_pwd_box")%></span><%}%>
			<%if(usrHasCookie){%>
				&nbsp;<a href="/area_user/account.aspx?del_autologin=1"><%=lang.getTranslated("frontend.area_user.manage.label.reset_auto_login")%></a>
			<%}%>
			<input type="hidden" name="username" id="username" value="<%=user.username%>">	
		<%}else{%>
			<input type="text" class="input_form" name="username" id="username" value="<%=user.username%>" onfocus="cleanInputField('username');" onBlur="restoreInputField('username','<%=lang.getTranslated("frontend.area_user.manage.label.username")%>');">
		<%}%>
		</div>
		<div style="clear:left;"></div>
 		
		<div id="change_pwd_box" style="<%if(user.id != -1){Response.Write("display:none;");}%>">
		<div class="form_reg_container_sx">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.password")%> (*)</span> 
		</div>			
		<div class="form_reg_container_dx">
			<input type="password" class="input_form" name="password" id="password" value="" onkeypress="javascript:return notSpecialCharAndSpace(event);"/>
		</div>
		<div style="clear:left;"></div>
		
		<div class="form_reg_container_sx">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.conf_password")%> (*)</span> 
		</div>			
		<div class="form_reg_container_dx">
			<input name="conferma_password" class="input_form" id="conferma_password" type="password" value=""  onkeypress="javascript:return notSpecialCharAndSpace(event);"/>
		</div>	
		<div style="clear:left;"></div>
		</div>
		
		<div class="form_reg_container_sx">
		<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.email")%> (*)</span> 
		</div>			
		<div class="form_reg_container_dx">
			<input type="text" name="email" class="input_form" value="<%=user.email%>" id="email" onfocus="cleanInputField('email');" onBlur="restoreInputField('email','<%=user.email%>');"/>
		</div>
		<div style="clear:left;"></div>
		
		<%if (user.id == -1) {%>		
		<div class="form_reg_container_sx">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.confirm_email")%> (*)</span>
		</div>			
		<div class="form_reg_container_dx">
			<input type="text" class="input_form" name="conferma_email" id="conferma_email" value="<%if(!String.IsNullOrEmpty((string)Session["s_email"])){Response.Write(Session["s_email"].ToString());}else{Response.Write(lang.getTranslated("frontend.area_user.manage.label.confirm_email"));}%>" onfocus="cleanInputField('conferma_email');" onBlur="restoreInputField('conferma_email','<%=lang.getTranslated("frontend.area_user.manage.label.confirm_email")%>');"/>
		</div>	
		<div style="clear:left;"></div>
		<%}%>
			
        <div class="form_reg_container_sx">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.public_profile")%></span>	
		</div>			
		<div class="form_reg_container_dx">	
        	<p style="height:8px;"></p><span style="margin-left:5px;"><select name="public_profile" id="public_profile">
				<OPTION VALUE="1" <%if (user.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.yes")%></OPTION>
				<OPTION VALUE="0" <%if (!user.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.no")%></OPTION>
          	</select></span>
		</div>
		<div style="clear:left;"></div>
		
        <div class="form_reg_container_sx2">
			<span class="form_reg_label"><%=lang.getTranslated("frontend.area_user.manage.label.avatar")%></span>
		</div>			
		<div class="form_reg_container_dx">	
			<input type="file" name="imageupload" /><br/>
			<%if (usrHasAvatar) {%>	
				<script>
				$(function() {
					$(".imgAvatarUser").aeImageResize({height: 50, width: 50});
				});
				</script>	
				<img class="imgAvatarUser" align="top" width="50" src="<%=avatarPath%>" /><br/>&nbsp;<input type="checkbox" align="left" value="false" name="del_usrimage">&nbsp;<%=lang.getTranslated("frontend.area_user.manage.label.del_avatar")%>

				<script>				
				<%if(!String.IsNullOrEmpty(avatarPath)){%>
					var varIntervalCounterU = 0;
					var myTimerU;
				
					function reloadAvatarImageU(){       
						  preloadSelectedImages("<%=avatarPath%>");
						  $(".imgAvatarUser").aeImageResize({height: 50, width: 50});
						  varIntervalCounterU++;
						  
						  if(varIntervalCounterU>10){
							clearInterval(myTimerU);    
						  }
					}
						
					jQuery(document).ready(function(){	
					  myTimerU = setInterval("reloadAvatarImageU()",10);
					});
				<%}%>
				</script>
			<%}%>
	
			<%
			if(Request["error_code"] == "021") {
			  Response.Write("<span class=\"imgError\">"+lang.getTranslated("portal.commons.errors.label.max_content_length")+"</span><br/>");
			}
			if(Request["error_code"] == "022") {
			  Response.Write("<span class=\"imgError\">"+lang.getTranslated("portal.commons.errors.label.invalid_contenttype")+"</span><br/>");
			}
			%>     
		</div>		
		<div style="clear:left;"></div>

		<%if(confservice.get("use_wizard_registration").value ==  "1"){%>
        <div>
        <input name="wizard" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.carryon")%>" type="button" onclick="javascript:userWizard(2);">
        </div>
		<%}%>
        </div>
              
        
        <div id="wizard2" style="display:none;">
       <!--******** GESTIONE FIELDS UTENTE PERSONALIZZATI ********-->	  
	<%if(bolFoundFields) {
		//string fclass = "text-align:left;vertical-align:top;padding-right:10px;min-width:250px;min-height:30px;padding-bottom:20px;";
		string fclass = "usr_field_container";
		Response.Write(UserService.renderField(usrfields, user, null, null, fclass, lang.currentLangCode, lang.defaultLangCode, "1,3"));
	}%>		
	<!--******** FINE GESTIONE FIELDS UTENTE PERSONALIZZATI ********-->

		<%if(confservice.get("use_wizard_registration").value ==  "1"){%>            
        <div>
        <input name="wizard" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.carryon")%>" type="button" onclick="javascript:userWizard(3);">
        </div>
		<%}%>
        </div>
        
        <div id="wizard3" style="display:none;">
        <h2><%=lang.getTranslated("frontend.header.label.iscriz_newsletter")%></h2>
        <div class="form_reg_container_sx2">
			<span><%=lang.getTranslated("frontend.area_user.manage.label.iscriz_newsletter")%></span>
		</div>
        <div class="form_reg_container_dx2" id="profilo-utente-newsletter">          
			<%if(newsletters!=null) {
				foreach(Newsletter x in newsletters){					
					string chechedVal = "";										
					if(user.newsletters!=null && user.newsletters.Count>0){
						foreach(UserNewsletter un in user.newsletters){
							if(un.newsletterId==x.id || x.id.ToString()==(string)Session["s_newsletter_"+x.id]){
								chechedVal = " checked='checked'";
								break;
							}
						}
					}else{
						if(x.id.ToString()==(string)Session["s_newsletter_"+x.id]){
							chechedVal = " checked='checked'";
						}						
					}
					%>
					<input type="checkbox" style="vertical-align:middle;text-align:left;margin:2px;" value="<%=x.id%>" align="left" name="list_newsletter" <%=chechedVal%>>&nbsp;<%=x.description%><br/>			  
				<%}%>
			<%}%>	
        </div>
		<div style="clear:left;"></div>		

		<%if(confservice.get("use_wizard_registration").value ==  "1"){%>
        <div>
        <input name="wizard" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.carryon")%>" type="button" onclick="javascript:userWizard(4);">
        </div>
		<%}%>
        </div>
        
        <div id="wizard4" style="display:none;">
        <h2><%=lang.getTranslated("frontend.header.label.info_privacy")%></h2>

        <div class="form_reg_container_sx">
			<span><%=lang.getTranslated("frontend.area_user.manage.label.info_privacy")%></span><br/><br/>
			<span><%=lang.getTranslated("frontend.area_user.manage.label.confirm_privacy")%> (*)</span>
			<span id="profilo-utente-confirm-privacy"><input type="checkbox" value="true" name="privacy" checked/ ></span>
		</div>
	<div class="form_reg_container_dx2" id="profilo-utente-privacy">
		<textarea class="textarea_form" name="txt_privacy"><%=lang.getTranslated("frontend.area_user.manage.label.text_privacy")%></textarea>
	</div>
	<div style="clear:left;"></div>		
        <div>
        <%
          if(Request["captcha_err"] == "1") {
            Response.Write("<span class=imgError>"+lang.getTranslated("frontend.area_user.manage.label.wrong_captcha_code")+"</span><br/>");
          }
		  
		  if(confservice.get("use_recaptcha").value == "1"){%>
		  	<img id="imgCaptcha" width="210" align="left" style="padding-right:10px;" src="/common/include/captcha/base_captcha.aspx"/>
			<a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%=lang.getTranslated("frontend.area_user.manage.label.change_captcha_img")%></a>
			<br/><input name="captchacode" style="margin-top:3px;" type="text" id="captchacode" /><br/><br/>            
          <%}else if(confservice.get("use_recaptcha").value == "2"){%>
            <br/><%=CaptchaService.renderRecaptcha()%><br/>
          <%}%>
          <br/>
          
          <input name="send" align="left" value="<%if(user.id==-1){Response.Write(lang.getTranslated("frontend.area_user.manage.label.do_registration"));}else{Response.Write(lang.getTranslated("frontend.area_user.manage.label.modify_user"));}%>" type="button" onclick="javascript:insertUser();">
	  </div>	

        </div>
       </div>
		</form>	

		<form action="/area_user/account.aspx" method="post" name="form_delete" accept-charset="UTF-8">		  
		<input type="hidden" value="<%=user.id%>" name="id">
		<input type="hidden" name="operation" value="delete">
		</form>				
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>