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
	IMailRepository mailrep = RepositoryFactory.getInstance<IMailRepository>("IMailRepository");
	Logger log;	
	
	int resp = 1;
	if(logged){
		int idFriend = Convert.ToInt32(Request["userid"]);
		User user = usrrep.getById(login.userLogged.id);
		User friend = usrrep.getById(idFriend);
		string mailFriend = "";
		if(friend != null){
			mailFriend = friend.email;
		}
		int active = 0;
		int action = 0;
		if (!String.IsNullOrEmpty(Request["active"])){
			active = Convert.ToInt32(Request["active"]);
		}
		if (!String.IsNullOrEmpty(Request["action"])){
			action = Convert.ToInt32(Request["action"]);
		}	
		
		if(action==0) {
			if (friend != null && (idFriend != user.id)) {
				bool hasFriend = false;
				foreach(UserFriend uf in user.friends){
					if(uf.friend==idFriend){
						hasFriend = true;
						break;
					}
				}
				
				if (hasFriend) {
					resp=1;
				}else{
					resp=0;
				}
			}else{
				resp=1;				
			}
		}else if(action==1){
			if (friend != null && (idFriend != user.id)) {
				bool hasFriend = false;
				foreach(UserFriend uf in user.friends){
					if(uf.friend==idFriend){
						hasFriend = true;
						break;
					}
				}
				if  (!hasFriend) {
					try{
						UserFriend uf = new UserFriend();
						uf.idParentUser = user.id;
						uf.friend = idFriend;
						uf.isActive = true;
						user.friends.Add(uf);
						usrrep.update(user);
						uf = new UserFriend();
						uf.idParentUser = idFriend;
						uf.friend = user.id;
						uf.isActive = Convert.ToBoolean(active);
						friend.friends.Add(uf);
						usrrep.update(friend);					
						
						UriBuilder ubuilder = Utils.getBaseUrl(Request.Url.ToString(),1);
						try
						{				
							MailMsg mtemplate = mailrep.getByName("user-mail-check-friend", lang.currentLangCode, true);
							ListDictionary replacements = new ListDictionary();
							
							StringBuilder newsContent = new StringBuilder();
							newsContent.Append("<h2>").Append(lang.getTranslated("frontend.confirm_friend.mail.label.intro_checkfriend")).Append("</h2>").Append("<br/><br/>");
							newsContent.Append("<div style=\"float:left;padding-right:10px;\">");
							
							bool usrHasAvatar = false;
							string avatarPath = "";
							
							UserAttachment avatar = UserService.getUserAvatar(user);
							if(avatar != null){
							  usrHasAvatar = true;
							  avatarPath = ubuilder.ToString()+"public/upload/files/user/"+avatar.filePath+avatar.fileName;
							}
							
							if (usrHasAvatar) {
							  newsContent.Append("<img class=\"imgAvatarUserOn\" align=\"top\" width=\"50\" src=\"").Append(avatarPath).Append("\" />");
							}else{
							  newsContent.Append("<img class=\"imgAvatarUserOn\" align=\"top\" width=\"50\" src=\"").Append(ubuilder.ToString()).Append("common/img/unkow-user.jpg\" />");
							}
							newsContent.Append("</div>");
							newsContent.Append("<div style=\"padding-bottom:15px;\"><i>").Append(user.username).Append("</i></div>");
							newsContent.Append("<p align=\"center\">");	
							newsContent.Append(lang.getTranslated("frontend.confirm_friend.mail.label.friend_askadd"));
							newsContent.Append("</p>");
							newsContent.Append("<hr><br/><br/><a href=\"").Append(ubuilder.ToString()).Append("area_user/account.aspx\">").Append(lang.getTranslated("backend.confirm_comment.mail.label.confirm_friend")).Append("</a><br/><br/>");
							
							replacements.Add("mail_receiver",mailFriend);				
							replacements.Add("<%content%>",newsContent.ToString());						
							MailService.prepareAndSend(mtemplate.name, lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, ubuilder.ToString());				
							resp=0;	
						}catch(Exception ex){
							//Response.Write(ex.Message);
							throw;
						}					
					}catch(Exception ex){
						resp=1;
					}
				}
			}
		}else if(action==2){
			if (friend != null && (idFriend != user.id)) {
				bool hasFriend = false;
				foreach(UserFriend uf in user.friends){
					if(uf.friend==idFriend){
						hasFriend = true;
						break;
					}
				}
				bool hasFriend2 = false;
				foreach(UserFriend uf in friend.friends){
					if(uf.friend==user.id && uf.isActive){
						hasFriend2 = true;
						break;
					}
				}
				if (hasFriend && hasFriend2) {
					resp=0;
				}else{
					resp=1;
				}
			}else{
				resp=1;				
			}		
		}
	}
	Response.Write(resp);
}
</script>