<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.model" %>

<script runat="server">
ITemplateRepository trep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");

protected Template template;
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		
		/*template = trep.getByUrlRewrite("/first-custom-template/");
		if(template!=null){
			Response.Write("template: " + template.ToString()+"<br>");
		}*/
		
		ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		//Template test = temprep.getById(1);
		//temprep.update(test);
		string newLangCode = "";
		string resolvedPath = TemplateService.resolveVirtualPath("/IT/base-aspx/list.aspx", out newLangCode);
		Response.Write("resolvedPath:"+resolvedPath+" -newLangCode:"+newLangCode+"<br>");
		
		string resolvedPath2 = TemplateService.resolveVirtualPath("/it/base-aspx/list.aspx", out newLangCode);
		Response.Write("resolvedPath2:"+resolvedPath2+" -newLangCode:"+newLangCode+"<br>");
		
		string resolvedPath3 = TemplateService.resolveVirtualPath("/base-aspx/list.aspx", out newLangCode);
		Response.Write("resolvedPath3:"+resolvedPath3+" -newLangCode:"+newLangCode+"<br>");
		
		string resolvedPath4 = TemplateService.resolveVirtualPath("/it/homepage.aspx", out newLangCode);
		Response.Write("resolvedPath4:"+resolvedPath4+" -newLangCode:"+newLangCode+"<br>");
		
		string resolvedPath5 = TemplateService.resolveVirtualPath("/it/homepage", out newLangCode);
		Response.Write("resolvedPath5:"+resolvedPath5+" -newLangCode:"+newLangCode+"<br>");
		
	}
	    catch (Exception ex)
	{
	     Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>
<html>
<head>
</head>
<body>
    <h2>Template Report </h2>
    
    <%	
	
	%>
</body>
</html>