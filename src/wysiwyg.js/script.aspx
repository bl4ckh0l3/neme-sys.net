<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	HttpFileCollection MyFileCollection = Request.Files;
	HttpPostedFile MyFile;							
	MyFile = MyFileCollection[0];						
	string fileName = Path.GetFileName(MyFile.FileName);
	
	if(!String.IsNullOrEmpty(fileName))
	{
		TemplateService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/wysiwyg_editor/"+MyFile.FileName));
	}	
}
</script>