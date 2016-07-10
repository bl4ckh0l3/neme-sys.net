<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;

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
	login.acceptedRoles = "1,2";
	bool logged = login.checkedUser();
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	IUserPreferencesRepository preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	int resp = 0;
	
	if(logged){		
		try
		{
			if("unlock" == Request["operation"]){
				Comment comment = commentrep.getById(Convert.ToInt32(Request["id_comment"]));
				comment.active=true;
				commentrep.update(comment);
				resp = 1;
			}
			if("delete" == Request["operation"]){
				Comment comment = commentrep.getById(Convert.ToInt32(Request["id_comment"]));
				commentrep.delete(comment);
				resp = 1;
			}
			if("deleteall" == Request["operation"]){
				int id_element = Convert.ToInt32(Request["id_element"]);
				int element_type = Convert.ToInt32(Request["element_type"]);
				commentrep.deleteByElement(id_element,element_type);
				resp = 1;
			}
			if("insert" == Request["operation"]){
				int id_element = Convert.ToInt32(Request["id_element"]);
				int element_type = Convert.ToInt32(Request["element_type"]);
				int comment_type = Convert.ToInt32(Request["comment_type"]);
				string message = Request["message"];
				int active = Convert.ToInt32(Request["active"]);
		
				Comment comment = new Comment();
				comment.message = message;
				comment.elementId = id_element;
				comment.elementType = element_type;
				comment.voteType = comment_type;
				comment.userId = login.userLogged.id;
				comment.active = Convert.ToBoolean(active);
				comment.insertDate = DateTime.Now;		
				commentrep.insert(comment);
				resp = 1;
			}
			if("unlockvote" == Request["operation"]){
				Preference preference = preferencerep.getById(Convert.ToInt32(Request["id_comment"]));
				preference.active=true;
				preferencerep.update(preference);
				resp = 1;
			}
			if("deletevote" == Request["operation"]){
				Preference preference = preferencerep.getById(Convert.ToInt32(Request["id_comment"]));
				preferencerep.delete(preference);
				resp = 1;
			}
		}
		catch(Exception ex)
		{
			resp = 0;
		}
	}

	Response.Write(resp);
}
</script>