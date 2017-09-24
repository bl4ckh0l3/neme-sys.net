using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Collections;
using System.Data;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class MailService
	{		
		private static IMailRepository repository = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
		private static ConfigurationService confservice = new ConfigurationService();
		private static IMultiLanguageRepository mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");

		public static MailMessage prepareMessage(string name, string langCode, string langCodeDefault, string subjectMultiLPrefix, ListDictionary replacements, IList<Attachment> attachments, string baseUrl)
		{
			MailMessage message = null;
			MailMsg template = null;
			try{
				template = repository.getByName(name, langCode);
			}catch(Exception ex){return null;}
			
			if(template!=null){
				MailDefinition md = new MailDefinition();						
				md.IsBodyHtml = template.isBodyHTML;

				md.From = template.sender;
				if(!String.IsNullOrEmpty((string)replacements["mail_sender"]))
				{			
					string sender = (string)replacements["mail_sender"];
					md.From = sender;
				}
				
				// *** gestione caso subject multilingua quando specificato dal template
				//System.Web.HttpContext.Current.Response.Write("template.subject: " + template.subject+" - langCode: "+langCode+"<br>");
				md.Subject = template.subject;
				if(!String.IsNullOrEmpty(template.subject) && !String.IsNullOrEmpty(langCode))
				{
					string testSubject = mlangrep.translate(subjectMultiLPrefix+template.subject, langCode, langCodeDefault);
					//System.Web.HttpContext.Current.Response.Write("testSubject: " + testSubject+"<br>");
					if(!String.IsNullOrEmpty(testSubject)){
						template.subject = testSubject;
						md.Subject = template.subject;
					}
				}			
				if(!String.IsNullOrEmpty((string)replacements["mail_subject"]))
				{	
					string subject = (string)replacements["mail_subject"];
					md.Subject = subject;
				}
				
				if(template.priority!=0)
				{
					MailPriority priority = MailPriority.Normal;
					if(template.priority==1){
						priority = MailPriority.Normal;
					}else if(template.priority==2){
						priority = MailPriority.Low;					
					}else if(template.priority==3){
						priority = MailPriority.High;					
					}
					md.Priority = priority;
				}
				
				if(!String.IsNullOrEmpty((string)replacements["mail_receiver"]))
				{
					string receiver = (string)replacements["mail_receiver"];				
					template.receiver = receiver;
				}

				md.CC = template.cc;
				if(!String.IsNullOrEmpty((string)replacements["mail_cc"]))
				{	
					string cc = (string)replacements["mail_cc"];
					md.CC = cc;
				}
				
				template.body = template.body.Replace("[#","<%").Replace("#]","%>");
				//*** modifico il path delle immagini eventuali caricate dall'editor html, il path deve cominciare con http
				template.body = template.body.Replace("/public/upload/wysiwyg_editor",baseUrl+"public/upload/wysiwyg_editor");
				//System.Web.HttpContext.Current.Response.Write("template.body: " + template.body+"<br>");
				
				ListDictionary subreplacements = new ListDictionary();
				foreach(string key in replacements.Keys)
				{
					if(!key.StartsWith("<%")){continue;}
					subreplacements.Add(key, replacements[key]);
				}
				
				MailMessage textMsg;
				textMsg = md.CreateMailMessage(template.receiver, subreplacements, template.body, new LiteralControl());
				message = textMsg;
				message.BodyEncoding =  System.Text.Encoding.UTF8;
				message.SubjectEncoding = System.Text.Encoding.UTF8;
	
				//******** metto in atto una serie di replacement necessari per gestire correttamente le url della mail e altre info
				string value = message.Body;
				value = value.Replace("/public/upload/wysiwyg_editor",baseUrl+"public/upload/wysiwyg_editor");
				message.Body=value;
	
				AlternateView htmlView = AlternateView.CreateAlternateViewFromString(message.Body, System.Text.Encoding.UTF8, "text/html");
				message.AlternateViews.Add(htmlView);
	
				//System.Web.HttpContext.Current.Response.Write("template.body: " + template.body+"<br>");
				//System.Web.HttpContext.Current.Response.Write("message.body: " + message.Body+"<br>");

				if(!String.IsNullOrEmpty((string)replacements["mail_bcc"]))
				{
					string[] listbcc = ((string)replacements["mail_bcc"]).Split(',');
					if(listbcc != null)
					{
						foreach(string s in listbcc)
						{
							MailAddress bcc = new MailAddress(s);	
							message.Bcc.Add(bcc);
						}
					}
				}else{
					if(!String.IsNullOrEmpty(template.bcc))
					{
						string[] listbcc = template.bcc.Split(',');
						if(listbcc != null)
						{
							foreach(string s in listbcc)
							{
								MailAddress bcc = new MailAddress(s);	
								message.Bcc.Add(bcc);
							}
						}					
					}
				}
	
				//****** aggiungo eventuali attachments
				if(attachments != null)
				{
					foreach(Attachment data in attachments)
					{
						message.Attachments.Add(data);
					}
				}
			}
			//System.Web.HttpContext.Current.Response.Write("message.Body: " + message.Body+"<br><br>");
			//System.Web.HttpContext.Current.Response.Write("message.IsBodyHtml: " + message.IsBodyHtml+"<br>");
			
			return message;
		}

		public static void send(MailMessage message)
		{			
			try 
			{
				string server = confservice.get("mail_server").value;
				SmtpClient sc = new SmtpClient(server);
				
				//*** configuro il client smpt con eventuali cedenziali
				sc.UseDefaultCredentials = true;
				string smptuser = confservice.get("mail_server_usr").value;
				string smptpwd = confservice.get("mail_server_pwd").value;
				if(!String.IsNullOrEmpty(smptuser))
				{
					sc.UseDefaultCredentials = false;
					sc.Credentials = new System.Net.NetworkCredential(smptuser, smptpwd);
				}
				
				//System.Web.HttpContext.Current.Response.Write("message.From: " + message.From+"<br>");
				//System.Web.HttpContext.Current.Response.Write("message.To: " + message.To+"<br>");
				//System.Web.HttpContext.Current.Response.Write("message.CC: " + message.CC+"<br>");
				//System.Web.HttpContext.Current.Response.Write("message.Bcc: " + message.Bcc+"<br>");
				//System.Web.HttpContext.Current.Response.Write("message.Subject: " + message.Subject+"<br>");
				
				sc.Send(message);				
				
				//string userState = "";
				//sc.SendAsync(message, userState);
				message.Dispose();
			}
			catch (Exception ex) {
			  	//System.Web.HttpContext.Current.Response.Write("send mail service - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				throw;
			}
		}


		public static void prepareAndSend(string name, string langCode, string langCodeDefault, string subjectMultiLPrefix, ListDictionary replacements, IList<Attachment> attachments, string baseUrl)
		{
			try 
			{	
				MailMessage msg =  prepareMessage(name, langCode, langCodeDefault, subjectMultiLPrefix, replacements, attachments, baseUrl);
				send(msg);
			}
			catch (Exception ex) 
			{
			  	//System.Web.HttpContext.Current.Response.Write("prepareAndSend mail service - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				throw;
			}
		}
	}
}