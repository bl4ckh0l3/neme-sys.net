using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using NHibernate;
using NHibernate.Criterion;

public partial class _Mail : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	public ASP.BoPaginationControl pagination;
	protected bool bolFoundLista = false;	
	protected int itemsXpage, numPage;
	protected string cssClass;	
	protected IList<Language> languages;
	protected MailMsg mail;
	protected IMultiLanguageRepository mlangrep;
	protected IMailRepository mailrep;
	
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
		cssClass="LMT";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		mail = new MailMsg();		
		mail.id = -1;
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		body_html.Config["EnterMode"]="br";
		body_html.Config["StartupShowBlocks"]="false";
		body_html.Config["FormatOutput"]="true";
		body_html.Config["HtmlEncodeOutput"]="false";
		body_html.Config["FullPage"]="true";
		
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				mail = mailrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				mail = new MailMsg();		
				mail.id = -1;
			}	
		}
		if(!String.IsNullOrEmpty(mail.body)){
			body_html.Value = mail.body;
		}			
		
		//******** INSERISCO NUOVA MAIL / MODIFICO ESISTENTE
		int savesc = Convert.ToInt32(Request["savesc"]);				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{
				string name = Request["name"];
				string langCode = Request["mlang_code"];

				// verify mail non already exists
				if(mailrep.mailAlreadyExists(name, langCode, mail.id))
				{				
					url.Append("041&id_mail=").Append(mail.id);
					carryOn = false;						
				}
				
				if(carryOn)
				{			
					string description = Request["description"];				
					MailCategory mailCat = null;
					if(!String.IsNullOrEmpty(Request["mail_category"])){
						mailCat =  new MailCategory(Request["mail_category"]);	
					}
					if(!String.IsNullOrEmpty(Request["new_mail_category"])){
						mailCat =  new MailCategory(Request["new_mail_category"]);
					}
					string msender = Request["sender"];
					string mreceiver = Request["receiver"];
					string mcc = Request["cc"];
					string mbcc = Request["bcc"];
					string priority = Request["priority"];
					string msubject = Request["subject"];
					bool isActive = Convert.ToBoolean(Convert.ToInt32(Request["active"]));
					bool isBodyHTML = Convert.ToBoolean(Convert.ToInt32(Request["is_body_html"]));
					bool isExternalBody = Convert.ToBoolean(Convert.ToInt32(Request["is_ext_body"]));
					bool isBase = Convert.ToBoolean(Convert.ToInt32(Request["base"]));
					
					mail.name = name;
					mail.description = description;
					mail.mailCategory = mailCat;
					mail.langCode = langCode;
					mail.sender = msender;
					mail.receiver = mreceiver;
					mail.cc = mcc;
					mail.bcc = mbcc;
					mail.priority = Convert.ToInt32(priority);
					mail.subject = msubject;
					mail.isActive = isActive;
					mail.isBodyHTML = isBodyHTML;
					mail.isBase = isBase;	
	
					/*********** gestione salvataggio body:
					caso 1: is_body_html interno (is_body_html && !is_ext_body)
						recupero il testo dal campo: body_html;
						associazione a mail.body;
					caso 2: body_text interno (!is_body_html && !is_ext_body)
						recupero il testo dal campo: body_text; 
						associazione a mail.body;
					caso 3: body esterno (is_body_html && is_ext_body)
						recupero il file per upload dal campo: body_external; 
						TODO gestione file upload http;
						recupero del testo del file;
						associazione a mail.body;
					*/
					if(mail.isBodyHTML && !isExternalBody){
						mail.body = Request["body_html"];
					}else if(!mail.isBodyHTML && !isExternalBody){
						mail.body = Request["body_text"];					
					}else if(mail.isBodyHTML && isExternalBody){					
						HttpFileCollection MyFileCollection;
						HttpPostedFile MyFile;
						int FileLen;
						System.IO.Stream MyStream;
						String MyString ="";
						
						MyFileCollection = Request.Files;
						MyFile = MyFileCollection[0];
						
						//for(int k = 0; k<MyFileCollection.Keys.Count;k++){
						//	HttpPostedFile tmp = MyFileCollection[k];
							//Response.Write("filename:"+tmp.FileName);
						//}
						
						FileLen = MyFile.ContentLength;
						byte[] input = new byte[FileLen];
						
						// Initialize the stream.
						MyStream = MyFile.InputStream;
						
						// Read the file into the byte array.
						MyStream.Read(input, 0, FileLen);
						
						// Copy the byte array into a string.
						//for (int Loop1 = 0; Loop1 < FileLen; Loop1++)
						//	MyString = MyString + input[Loop1].ToString();
						MyString = Encoding.UTF8.GetString(input, 0, input.Length);
							
						MyStream.Close();
					
						mail.body = MyString;					
					}					
					
					//Response.Write("mail:"+mail.ToString()+"<br>");
	
					// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
					IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
					MultiLanguage ml;
					foreach (Language x in languages){
						//*** insert subject
						ml = mlangrep.find("backend.mails.detail.table.label.subject_"+mail.subject, x.label);
						if(ml != null){
							ml.value = Request["subject_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.mails.detail.table.label.subject_"+mail.subject;
							ml.langCode = x.label;
							ml.value = Request["subject_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){				
								newtranslactions.Add(ml);
							}
						}
					}
	
					try
					{
						mailrep.saveCompleteMailMsg(mail, newtranslactions, updtranslactions, deltranslactions);
	
						foreach(MultiLanguage value in updtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in deltranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in newtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}
						
						log.usr= login.userLogged.username;
						log.msg = "save mail template: "+mail.ToString();
						log.type = "info";
						log.date = DateTime.Now;
						lrep.write(log);
					}
					catch(Exception ex)
					{
						throw;					
					}
				}		
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}
			
			if(carryOn){
				if(savesc==0){
					Response.Redirect("/backoffice/mails/inserttemplatemail.aspx?cssClass="+Request["cssClass"]+"&id="+mail.id);
				}else{
					Response.Redirect("/backoffice/mails/mailtemplatelist.aspx?cssClass="+Request["cssClass"]);
				}
			}else{
				Response.Redirect(url.ToString());
			}											
		}	
	}
}