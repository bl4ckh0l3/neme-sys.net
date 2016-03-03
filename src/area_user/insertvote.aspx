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
protected int voteDone;
	
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
	IUserPreferencesRepository preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
	Logger log;		
	
	voteDone = 0;
	if(logged){
		int userId = Convert.ToInt32(Request["userid"]);
		User friend = usrrep.getById(login.userLogged.id);
		User user = usrrep.getById(userId);

		int vote = Convert.ToInt32(Request["vote"]);
		string message = Request["message"];
		int id_comment = Convert.ToInt32(Request["id_comment"]);
		int comment_type = Convert.ToInt32(Request["comment_type"]);
		bool active = false;
		if(!String.IsNullOrEmpty(Request["active"])){
			active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));
		}
		
		if (friend != null && (friend.id != user.id)) {
			try
			{
				IList<Preference> existsPreferences = preferencerep.find(friend.id, userId, id_comment, comment_type, null, false, false);
				if(existsPreferences == null || (existsPreferences != null && existsPreferences.Count==0)){			
					Preference preference = new Preference();
					preference.userId = friend.id;
					preference.friendId = userId;
					preference.commentId = id_comment;
					preference.commentType = comment_type;
					preference.type = vote;
					preference.message = message;
					preference.active = active;
					preference.insertDate = DateTime.Now;
					preferencerep.insert(preference);
								
					voteDone = 1;
					
					if("1".Equals(confservice.get("use_comments_filter").value) && !String.IsNullOrEmpty(confservice.get("mail_comment_receiver").value)) {
						UriBuilder ubuilder = new UriBuilder(Request.Url);
						ubuilder.Scheme = "http";
						ubuilder.Port = -1;
						ubuilder.Path="";
						ubuilder.Query = "";
						try
						{
							Comment comment = commentrep.getById(id_comment);
							FContent content = contentrep.getByIdCached(comment.elementId, true);
									
							MailMsg mtemplate = mailrep.getByName("confirm-vote", lang.currentLangCode, true);
							ListDictionary replacements = new ListDictionary();
							
							StringBuilder newsContent = new StringBuilder();
							newsContent.Append("<h2>").Append(lang.getTranslated("frontend.confirm_vote.mail.label.intro")).Append("</h2>").Append("<br/><br/>");
							newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.user_comment")).Append("</b>:&nbsp;<i>").Append(user.username).Append("</i></div>");
							newsContent.Append("<div style=\"padding-bottom:15px;\"><b>").Append(lang.getTranslated("portal.commons.label.comment_elem_title")).Append("</b>:&nbsp;").Append(content.title).Append("</div>");
							newsContent.Append("<p align=\"left\">");	
							newsContent.Append(preference.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("<br/>");
							newsContent.Append(preference.message);
							newsContent.Append("</p>");
							newsContent.Append("<hr><br/><br/><a href=\"").Append(ubuilder.ToString()).Append("common/include/confirmvote.aspx?id_vote=").Append(preference.id).Append("\">").Append(lang.getTranslated("backend.confirm_comment.mail.label.confirm_vote")).Append("</a><br/><br/>");
							
							replacements.Add("mail_receiver",confservice.get("mail_comment_receiver").value);				
							replacements.Add("<%content%>",newsContent.ToString());						
							MailService.prepareAndSend(mtemplate.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, ubuilder.ToString());	
							voteDone = 2;			
						}catch(Exception ex){
							//Response.Write(ex.Message);
							throw;
						}
					}
				}
			}catch(Exception ex){
				//Response.Write(ex.Message);
				voteDone = 0;
			}	
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
<input type="hidden" name="vode_done" value="<%=voteDone%>">
</form>
</body>