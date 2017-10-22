<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
protected ConfigurationService confservice;
	
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	confservice = new ConfigurationService();	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;
	bool carryOn = true;	

	try
	{
		// resolve captcha code
		UriBuilder errCaptcha = new UriBuilder(Request.Url);
		errCaptcha.Port = -1;
		errCaptcha.Query = "captcha_err=1";	
		if(confservice.get("use_recaptcha").value == "1"){
			string captchacode = Request["captchacode"];
			if(captchacode.ToLower() != Session["CaptchaImageText"].ToString().ToLower())
			{	
				//url = new StringBuilder(errCaptcha.ToString());
				carryOn = false;					
			}
		}else if(confservice.get("use_recaptcha").value == "2"){
			if(CaptchaService.verifyRecaptcha(Request.ServerVariables["REMOTE_ADDR"], Request["recaptcha_challenge_field"], Request["recaptcha_response_field"]))
			{
				carryOn = true;
			}else{
				//url = new StringBuilder(errCaptcha.ToString());
				carryOn = false;	
			}
		}
		
		if(carryOn)
		{
			UriBuilder builder = new UriBuilder(Request.Url);
			builder.Scheme = "http";
			builder.Port = -1;
			builder.Path="";
			
			ListDictionary replacementsUser = new ListDictionary();
			StringBuilder userMessage = new StringBuilder();
			replacementsUser.Add("mail_receiver",confservice.get("mail_receiver").value);	
			replacementsUser.Add("mail_bcc",Request["friend_mails"]);	
			replacementsUser.Add("<%intro%>",lang.getTranslated("frontend.tellafriend.mail.label.intro"));
			string usermailtxt = lang.getTranslated("frontend.tellafriend.mail.label.user_email") +":&nbsp;"+ Request["user_mail"]+"<br/><br/>";
			replacementsUser.Add("<%refermail%>",usermailtxt);
			string pageurltxt = lang.getTranslated("frontend.tellafriend.mail.label.page_url") +":&nbsp;"+"<a href='"+Request["page_url"]+"'>"+lang.getTranslated("frontend.tellafriend.mail.label.open_page")+"</a><br/><br/>";
			replacementsUser.Add("<%pageurl%>",pageurltxt);
			string messagetxt = lang.getTranslated("frontend.tellafriend.mail.label.msg") +":&nbsp;"+Request["message"]+"<br/><br/>";
			replacementsUser.Add("<%message%>",messagetxt);
			
			MailService.prepareAndSend("mail-tellafriend", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, builder.ToString());				
		}
	}
	catch(Exception ex)
	{
		StringBuilder errbuilder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		log = new Logger(errbuilder.ToString(),"system","error",DateTime.Now);		
		lrep.write(log);
		Response.StatusCode = 400;
	}
}
</script>