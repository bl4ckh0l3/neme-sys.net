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
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.UserLoginControl login;
public ASP.BoMultiLanguageControl lang;
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
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	string newdirectory = Request["new_dir_template"];
	string templateid = Request["id_template"];
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
	bool carryOn = true;
	
	try
	{
		Template testExist = temprep.getByDirectory(newdirectory);
		if(testExist!=null)
		{				
			url.Append(Regex.Replace(lang.getTranslated("backend.templates.lista.button.label.directory_already_exists"), @"\t|\n|\r", " "));
			carryOn = false;				
		}	
		
		if(carryOn){	
			Template original = temprep.getById(Convert.ToInt32(templateid));
			temprep.clone(original, newdirectory);
			
			//copio i file associati
			CommonService.directoryCopy(HttpContext.Current.Server.MapPath("~/public/templates/"+original.directory), HttpContext.Current.Server.MapPath("~/public/templates/"+newdirectory), true, false);
		}
	}
	catch(Exception ex)
	{
		url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
		carryOn = false;
	}

	if(carryOn){
		Response.Redirect("/backoffice/templates/templatelist.aspx?cssClass="+Request["cssClass"]);
	}else{
		Response.Redirect(url.ToString());
	}		
	
}
</script>
%>