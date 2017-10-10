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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	

	IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	string productId = Request["productid"];
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	Product newproduct = null;
	
	try
	{		
		Product original = prodrep.getById(Convert.ToInt32(productId));
		newproduct = prodrep.clone(original);
		
		//copio i file associati
		if(original.attachments != null && original.attachments.Count>0){
			CommonService.directoryCopy(HttpContext.Current.Server.MapPath("~/public/upload/files/products/"+original.id), HttpContext.Current.Server.MapPath("~/public/upload/files/products/"+newproduct.id), true);
		}
		
		// rimuovo la cache
		
	}
	catch(Exception ex)
	{
		url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
	}

	Response.Redirect("/backoffice/products/insertproduct.aspx?id="+newproduct.id+"&cssClass="+Request["cssClass"]);		
	
}
</script>