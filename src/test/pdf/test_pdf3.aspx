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
<%@ import Namespace="HiQPdf" %>


<script runat="server">		

protected void Page_Load(Object sender, EventArgs e)
{
	try{
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.pdf");
	
		// create the HTML to PDF converter
		HtmlToPdf htmlToPdfConverter = new HtmlToPdf();

		// set browser width
		htmlToPdfConverter.BrowserWidth = int.Parse("1200");

		// set browser height if specified, otherwise use the default
		//if (textBoxBrowserHeight.Text.Length > 0)
		//	htmlToPdfConverter.BrowserHeight = int.Parse(textBoxBrowserHeight.Text);

		// set HTML Load timeout
		htmlToPdfConverter.HtmlLoadedTimeout = int.Parse("120");

		// set PDF page size and orientation
		htmlToPdfConverter.Document.PageSize = PdfPageSize.A4;
		htmlToPdfConverter.Document.PageOrientation = PdfPageOrientation.Portrait;

		// set PDF page margins
		htmlToPdfConverter.Document.Margins = new PdfMargins(0);

		// set a wait time before starting the conversion
		htmlToPdfConverter.WaitBeforeConvert = int.Parse("2");

		// convert HTML to PDF
		byte[] pdfBuffer = null;

		//if (radioButtonConvertUrl.Checked)
		//{
			// convert URL to a PDF memory buffer
			//string url = "https://www.google.com";

			//pdfBuffer = htmlToPdfConverter.ConvertUrlToMemory(url);
		//}
		//else
		//{
			// convert HTML code
			string htmlCode = "</br></br>Please enter the HTML code to convert and the base URL to access the external images, scripts and css having relative URLs in the HTML code to convert.";
			string baseUrl = "";

			// convert HTML code to a PDF memory buffer
			pdfBuffer = htmlToPdfConverter.ConvertHtmlToMemory(htmlCode, baseUrl);
		//}

		// inform the browser about the binary data format
		HttpContext.Current.Response.AddHeader("Content-Type", "application/pdf");

		bool checkBoxOpenInline = false;
		
		// let the browser know how to open the PDF document, attachment or inline, and the file name
		HttpContext.Current.Response.AddHeader("Content-Disposition", String.Format("{0}; filename=HtmlToPdf.pdf; size={1}",
			checkBoxOpenInline ? "inline" : "attachment", pdfBuffer.Length.ToString()));

		// write the PDF buffer to HTTP response
		HttpContext.Current.Response.BinaryWrite(pdfBuffer);

		// call End() method of HTTP response to stop ASP.NET page processing
		HttpContext.Current.Response.End();				
		
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