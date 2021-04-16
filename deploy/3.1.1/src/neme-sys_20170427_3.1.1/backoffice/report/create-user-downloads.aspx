<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
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
	Response.Clear();				
	Response.ContentType = "text/csv";
	Response.AddHeader("content-disposition", "attachment;  filename=csv_user_downloads.csv");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	StringBuilder result = new StringBuilder();
	IList<UserDownload> downloads;


	try{			
		downloads = usrrep.getUserDownloads();	
		if(downloads == null){				
			downloads = new List<UserDownload>();						
		}
	}catch (Exception ex){
		downloads = new List<UserDownload>();
	}
		
	try
	{		
		//CREATE CSV HEADER
		result.Append(lang.getTranslated("backend.downloaded_file.table.header.fileid").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.usr").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.host").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.usrinfo").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.filename").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.filetype").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.filepath").ToUpper()).Append(",")
		.Append(lang.getTranslated("backend.downloaded_file.table.header.downdate").ToUpper()).Append(System.Environment.NewLine);
		
		//APPEND CSV ROWS
		if(downloads != null && downloads.Count>0){
			foreach(UserDownload ud in downloads){
				result.Append("\"").Append(ud.idFile).Append("\",")
				.Append("\"").Append(ud.user).Append("\",")
				.Append("\"").Append(ud.userHost).Append("\",")
				.Append("\"").Append(ud.userInfo).Append("\",")
				.Append("\"").Append(ud.fileName).Append("\",")
				.Append("\"").Append(ud.contentType).Append("\",")
				.Append("\"").Append(ud.filePath).Append("\",")
				.Append("\"").Append(ud.downloadDate.ToString("dd/MM/yyyy HH:mm")).Append("\"").Append(System.Environment.NewLine);
			}
		}
	}
	catch (Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
		
	Response.Write(result.ToString());
	Response.End();
}
</script>