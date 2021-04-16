<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Net.Mail" %>
<%@ import Namespace="System.Net.Mime" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	ASP.BoMultiLanguageControl lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	IContentRepository contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
	INewsletterRepository newsrep = RepositoryFactory.getInstance<INewsletterRepository>("INewsletterRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	StringBuilder builder;
		
	try
	{
		FContent content = contrep.getById(Convert.ToInt32(Request["id_content"]));
		Newsletter newsletter = newsrep.getById(Convert.ToInt32(Request["id_newsletter"]));
		MailMsg template = mailrep.getById(newsletter.templateId);
		ListDictionary replacements = new ListDictionary();
		
		StringBuilder newsContent = new StringBuilder()
		.Append("<b>").Append(content.title).Append("</b><br/><br/>")
		.Append(content.summary).Append("<br/><br/>")
		.Append(content.description).Append("<br/><br/>");

		if(content.fields != null && content.fields.Count>0) {
			foreach(ContentField cf in content.fields){			
				string labelForm = cf.description;
				
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm))){
					 labelForm = lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm);
				}
				
				string currvalue = cf.value;
				if(!String.IsNullOrEmpty(currvalue)){
					newsContent.Append("<b class=labelForm>").Append(labelForm).Append("</b>:&nbsp;").Append(currvalue).Append("<br/>");
				}
			}
		}

		replacements.Add("<%content%>",newsContent.ToString());
		//replacements.Add("mail_bcc","denismind@libero.it");
		//replacements.Add("mail_bcc",Request["mail_bcc"]);
		//replacements.Add("mail_subject",Request["mail_subject"]);			
		UriBuilder ubuilder = new UriBuilder(Request.Url);
		ubuilder.Scheme = "http";
		ubuilder.Port = -1;
		ubuilder.Path="";
		ubuilder.Query = "";
		
		MailMessage message = MailService.prepareMessage(template.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, ubuilder.ToString());

		
		StringBuilder responseContent = new StringBuilder()
		.Append(lang.getTranslated("backend.contenuti.detail.newsletter_preview.label.sender")).Append(message.From).Append("<br/><br/>")
		.Append(lang.getTranslated("backend.contenuti.detail.newsletter_preview.label.subject")).Append(message.Subject).Append("<br/><br/><br/>")
		.Append(message.Body).Append("<br/><br/>");
				
		Response.Write(responseContent.ToString());
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>