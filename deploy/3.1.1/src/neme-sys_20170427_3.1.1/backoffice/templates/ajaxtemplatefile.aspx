<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.UserLoginControl login;
protected void Page_Init(Object sender, EventArgs e)
{
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	string content = Request["content"];
	string operation = Request["command"];
	string path = Request["filepath"];
	string fileid = Request["fileid"];

	try
	{		
		switch (operation)
		{
			case "loadfile":
				string lines;
				using (StreamReader sr = new StreamReader(Server.MapPath(path))) 
				{						
					lines = sr.ReadToEnd();
				}
				Response.Write(lines);
				break;
			case "savefile":
				using (StreamWriter sw = new StreamWriter(Server.MapPath(path))) 
				{						
					sw.Write(content);
				}
				break;
			case "deletefile":
				TemplatePage tp;
				if(!String.IsNullOrEmpty(fileid)){
					tp = temprep.getPageById(Convert.ToInt32(fileid));
					if(tp!=null)
					{	
						temprep.deleteTemplatePage(tp);
						File.Delete(Server.MapPath(path));
					}
				}				
				break;
			default:			    
				break;
		}
	}
	catch(Exception ex)
	{
		Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
}
</script>