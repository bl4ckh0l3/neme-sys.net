<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected bool bolFoundLista = false;
protected IList<UserAttachment> attachments;
protected StringBuilder builder;
protected string basePath;
	
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(object sender, EventArgs e) 
{	
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/xml";
	Response.AddHeader("content-disposition", "attachment;  filename=photos.xml");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	IUserRepository userrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
	confservice = new ConfigurationService();

	//se il sito � offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		Response.Redirect(CommonService.getBaseUrl(Request.Url.ToString(),2).ToString());
	}
			
	basePath = CommonService.getBaseUrl(Request.Url.ToString(),2).ToString()+"public/upload/files/user/";
	
	try
	{		
		int userId = Convert.ToInt32(Request["userid"]);
		User user = userrep.getById(userId);
		if(user != null && user.attachments != null){
			attachments = user.attachments;					
			bolFoundLista = true;
		}
		
	}catch (Exception ex){
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		attachments = new List<UserAttachment>();						
		bolFoundLista = false;
	}
}	
</script>
<?xml version="1.0"?>
  <root> 
	<%
	if(bolFoundLista) {		
		foreach (UserAttachment attachment in attachments){
			if(!attachment.isAvatar){%>
			<item>			
			<id><![CDATA[<%=attachment.id%>]]></id>
			<userid><![CDATA[<%=attachment.idUser%>]]></userid>
			<filename><![CDATA[<%=attachment.fileName%>]]></filename>
			<filepath><![CDATA[<%=basePath+attachment.filePath+attachment.fileName%>]]></filepath>
			<content_type><![CDATA[<%=attachment.contentType%>]]></content_type>
			<file_dida><![CDATA[<%=attachment.fileDida%>]]></file_dida>
			<label><![CDATA[<%=attachment.fileLabel%>]]></label>
			<is_avatar><![CDATA[<%=attachment.isAvatar%>]]></is_avatar>
			<insert_date><![CDATA[<%=attachment.insertDate%>]]></insert_date>			
			</item>
			<%}		
		}
	}%>
  </root> 