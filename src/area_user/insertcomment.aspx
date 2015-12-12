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
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommentsWidget" TagName="render" Src="~/public/layout/addson/comments/comments-widget.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
protected ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected string style, cssClass;
protected int posted;
	
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
	bool logged = login.checkedUser();
	confservice = new ConfigurationService();	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
	Logger log;		
	
	posted = 0;
	if(logged){
		User user = usrrep.getById(login.userLogged.id);
		int id_element = Convert.ToInt32(Request["id_element"]);
		int element_type = Convert.ToInt32(Request["element_type"]);
		int comment_type = Convert.ToInt32(Request["comment_type"]);
		string message = Request["message"];
		int active = Convert.ToInt32(Request["active"]);
	
		try
		{
			if(!String.IsNullOrEmpty(message)){
				Comment comment = new Comment();
				comment.message = message;
				comment.elementId = id_element;
				comment.elementType = element_type;
				comment.voteType = comment_type;
				comment.userId = user.id;
				comment.active = Convert.ToBoolean(active);
				comment.insertDate = DateTime.Now;		
				commentrep.insert(comment);
				
				if("1".Equals(confservice.get("use_comments_filter").value) && !String.IsNullOrEmpty(confservice.get("mail_comment_receiver").value)) {
					UriBuilder ubuilder = new UriBuilder(Request.Url);
					ubuilder.Scheme = "http";
					ubuilder.Port = -1;
					ubuilder.Path="";
					ubuilder.Query = "";
					try
					{	
						FContent content = contentrep.getByIdCached(comment.elementId, true);
								
						MailMsg mtemplate = mailrep.getByName("confirm-comment", lang.currentLangCode, "true");
						ListDictionary replacements = new ListDictionary();
						
						StringBuilder newsContent = new StringBuilder();
						newsContent.Append("<h2>").Append(lang.getTranslated("frontend.confirm_comment.mail.label.intro")).Append("</h2>").Append("<br/><br/>");
						newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.user_comment")).Append("</b>:&nbsp;<i>").Append(user.username).Append("</i></div>");
						newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.comment_elem_title")).Append("</b>:&nbsp;").Append(content.title).Append("</div>");
						newsContent.Append("<p align=\"left\">");	
						newsContent.Append(comment.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("<br/>");
						newsContent.Append(comment.message);
						newsContent.Append("</p>");
						newsContent.Append("<hr><br/><br/><a href=\"").Append(ubuilder.ToString()).Append("common/include/confirmcomment.aspx?id_comment=").Append(comment.id).Append("\">").Append(lang.getTranslated("backend.confirm_comment.mail.label.confirm")).Append("</a><br/><br/>");
						
						replacements.Add("mail_receiver",confservice.get("mail_comment_receiver").value);				
						replacements.Add("<%content%>",newsContent.ToString());						
						MailService.prepareAndSend(mtemplate.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, ubuilder.ToString());				
					}catch(Exception ex){
						//Response.Write(ex.Message);
						throw;
					}
				}
				
				posted = 1;
			}
		}catch(Exception ex){
			//Response.Write(ex.Message);
			posted = 0;
		}	
	}
}
</script>
<body onload="document.controller_redirect.submit();">
<form method="post" name="controller_redirect" action="<%=Request["from"]%>">
<input type="hidden" name="categoryid" value="<%=Request["categoryid"]%>">
<input type="hidden" name="hierarchy" value="<%=Request["hierarchy"]%>">
<input type="hidden" name="elemid" value="<%=Request["elemid"]%>">
<input type="hidden" name="elemtype" value="<%=Request["elemtype"]%>">
<input type="hidden" name="page" value="<%=Request["page"]%>">
<input type="hidden" name="modelPageNum" value="<%=Request["modelPageNum"]%>">
<input type="hidden" name="posted" value="<%=posted%>">
</form>
</body>