using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _User : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundFields;	
	protected string cssClass;
	protected IList<UserGroup> groupsu;
	protected IList<Language> languages;
	protected IList<Language> usrlanguages;	
	protected IList<Category> categories;
	protected IList<Newsletter> newsletters;
	protected IList<UserField> usrfields;
	protected IUserRepository usrrep;	
	protected ICommentRepository commentrep;	
	protected IUserPreferencesRepository preftrep;	
	protected User user;
	protected int groupid = -1;
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="LCE";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		INewsletterRepository newslrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
		preftrep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ConfigurationService confservice = new ConfigurationService();

		user = new User();	
		user.id = -1;	
		user.role=new UserRole((int)UserRole.Roles.GUEST);	
		user.languages = new List<UserLanguage>();	
		user.categories = new List<UserCategory>();	
		user.newsletters = new List<UserNewsletter>();
		user.fields = new List<UserFieldsMatch>();
				
		usrlanguages = new List<Language>();	
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		usrfields = new List<UserField>();
		bolFoundFields = false;

		// recupero elementi della pagina necessari
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
			applyTo.Add("1");
			applyTo.Add("2");			
			usrfields = usrrep.getUserFields(true,usesFor, applyTo);
			if(usrfields != null && usrfields.Count>0){
				bolFoundFields = true;
			}else{				
				bolFoundFields = false;					
			}
		}catch (Exception ex){
			usrfields = new List<UserField>();
			bolFoundFields = false;	
		}

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{	
			try{
				user = usrrep.getById(Convert.ToInt32(Request["id"]));
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

				UserGroup groupu = usrrep.getUserGroup(user);
				if (groupu!=null) {
					groupid=groupu.id;
				}
			}catch (Exception ex){
				user = new User();		
				user.id = -1;
				user.role=new UserRole((int)UserRole.Roles.GUEST);	
				user.languages = new List<UserLanguage>();	
				user.categories = new List<UserCategory>();	
				user.newsletters = new List<UserNewsletter>();
				user.fields = new List<UserFieldsMatch>();
				usrfields = new List<UserField>();
				bolFoundFields = false;
			}	
		}
				
		//******** INSERISCO NUOVO UTENTE / MODIFICO ESISTENTE				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;	
			try
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
					int groupid = -1;
					if(!String.IsNullOrEmpty(Request["user_group"])){
						groupid = Convert.ToInt32(Request["user_group"]);	
					}
					int role = Convert.ToInt32(Request["role"]);
					bool isActive = Convert.ToBoolean(Convert.ToInt32(Request["user_active"]));
					bool isPublicProfile = Convert.ToBoolean(Convert.ToInt32(Request["public_profile"]));			
					decimal discount = Convert.ToDecimal(Request["discount"]);
					string boComments = Request["admin_comments"];
					bool privacy = Convert.ToBoolean(Request["privacy"]);
					bool newsletter = Convert.ToBoolean(Request["newsletter"]);	
					
					user.username = username;
					if(!String.IsNullOrEmpty(password)){
						user.password = password;	
					}
					user.userGroup = groupid;
					user.role = new UserRole(role);
					user.isActive = isActive;
					user.isPublicProfile = isPublicProfile;
					user.email = email;
					user.discount = discount;	
					user.boComments = boComments;	
					user.privacyAccept = privacy;	
					user.hasNewsletter = newsletter;	
	
					// aggiorno le lingue utente
					user.languages.Clear();
					if(!String.IsNullOrEmpty(Request["usr_languages"])){
						string[] usrLanguages = Request["usr_languages"].Split('|');
						if(usrLanguages!=null){
							foreach(string x in usrLanguages){
								UserLanguage ul = new UserLanguage();
								ul.idParentUser = user.id;
								ul.idLanguage = Convert.ToInt32(x);
								user.languages.Add(ul);
							}
						}
					}
	
					// aggiorno le categorie utente
					user.categories.Clear();
					if(!String.IsNullOrEmpty(Request["usr_categories"])){
						string[] usrCategories = Request["usr_categories"].Split(',');
						if(usrCategories!=null){
							foreach(string x in usrCategories){
								UserCategory uc = new UserCategory();
								uc.idParentUser = user.id;
								uc.idCategory = Convert.ToInt32(x);
								user.categories.Add(uc);
							}
						}
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
					
					
					try
					{
					 
						bool sendWelcomeMail = false;
						if(user.id == -1)
						{
							sendWelcomeMail = true;
						}
						usrrep.saveCompleteUser(user, null);
						user = usrrep.getById(user.id);		
						
						log.usr= login.userLogged.username;
						log.msg = "save user: "+user.ToString();
						log.type = "info";
						log.date = DateTime.Now;
						lrep.write(log);

						// se l'utente aggiornato � l'utente in sessione aggiorno la sessione
						if(login.userLogged.id==user.id){
							login.updateUserLogged(usrrep.getById(user.id));
						}
								
						//if new user send welcome mail
						if(sendWelcomeMail)
						{
							UriBuilder builder = new UriBuilder(Request.Url);
							builder.Scheme = "http";
							builder.Port = -1;
							builder.Path="";
							
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
									userMessage.Append(tmp.description).Append(":<br/>");		
									adminMessage.Append(tmp.description).Append(":<br/>");											
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
						//Response.Write("repository operation error: "+ ex.Message);
						throw;	
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
				Response.Redirect("/backoffice/users/userlist.aspx?showtab=usrlist&cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}								
		}
	}
}