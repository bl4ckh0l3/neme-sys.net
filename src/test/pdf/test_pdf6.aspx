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
<%@ import Namespace="PdfSharp" %>
<%@ import Namespace="PdfSharp.Drawing" %>
<%@ import Namespace="PdfSharp.Pdf" %>
<%@ import Namespace="PdfSharp.Pdf.IO" %>

<script runat="server">		

protected void Page_Load(Object sender, EventArgs e)
{
	try{
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.pdf");
	

		// Create a new PDF document
		PdfDocument document = new PdfDocument();
		document.Info.Title = "Created with PDFsharp";
		
		// Create an empty page
		PdfPage page = document.AddPage();
		
		// Get an XGraphics object for drawing
		XGraphics gfx = XGraphics.FromPdfPage(page);
		
		// Create a font
		XFont font = new XFont("Verdana", 20, XFontStyle.BoldItalic);
		
		// Draw the text
		gfx.DrawString("Hello, World!", font, XBrushes.Black,
		new XRect(0, 0, page.Width, page.Height),
		XStringFormats.Center);
		
		// Save the document...
		const string filename = "HelloWorld.pdf";
		document.Save(filename);
		// ...and start a viewer.
		Process.Start(filename);		
		
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