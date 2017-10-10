<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="System.Web.UI.WebControls" %>
<%@ import Namespace="IronPdf" %>


<script runat="server">		

protected void Page_Load(Object sender, EventArgs e)
{
	try{
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.pdf");
	
		IronPdf.HtmlToPdf Renderer = new IronPdf.HtmlToPdf();
		
		// Render an HTML document or snippet as a string     
		//Renderer.RenderHtmlAsPdf("<h1>Hello World</h1>").SaveAs(fileName);		
		
	}catch (Exception ex){
	     Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
}
</script>
<html>
<head>
</head>
<body>

</body>
</html>