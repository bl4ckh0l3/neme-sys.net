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
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.jpg");
	
		// create the HTML to Image converter
		HtmlToImage htmlToImageConverter = new HtmlToImage();
		
		// set browser width
		htmlToImageConverter.BrowserWidth = int.Parse("1200");
		
		// set browser height if specified, otherwise use the default
		//if (textBoxBrowserHeight.Text.Length > 0)
		//	htmlToImageConverter.BrowserHeight = int.Parse(textBoxBrowserHeight.Text);
		
		// set HTML Load timeout
		htmlToImageConverter.HtmlLoadedTimeout = int.Parse("120");
		
		// set whether the resulted image is transparent (has effect only when the output format is PNG)
		//htmlToImageConverter.TransparentImage = (dropDownListImageFormat.SelectedValue == "PNG") ? checkBoxTransparentImage.Checked : false;
		htmlToImageConverter.TransparentImage = false;
		
		// set triggering mode; for WaitTime mode set the wait time before convert
		//switch (dropDownListTriggeringMode.SelectedValue)
		//{
		//	case "Auto":
		//		htmlToImageConverter.TriggerMode = ConversionTriggerMode.Auto;
		//		break;
		//	case "WaitTime":
		//		htmlToImageConverter.TriggerMode = ConversionTriggerMode.WaitTime;
		//		htmlToImageConverter.WaitBeforeConvert = int.Parse(textBoxWaitTime.Text);
		//		break;
		//	case "Manual":
		//		htmlToImageConverter.TriggerMode = ConversionTriggerMode.Manual;
		//		break;
		//	default:
				htmlToImageConverter.TriggerMode = ConversionTriggerMode.Auto;
		//		break;
		//}
		
		// convert to image
		System.Drawing.Image imageObject = null;
		//string imageFormatName = dropDownListImageFormat.SelectedValue.ToLower();
		string imageFormatName = "jpg";
		string imageFileName = String.Format("HtmlToImage.{0}", imageFormatName);
		
		//if (radioButtonConvertUrl.Checked)
		//{
			// convert URL
		//	string url = textBoxUrl.Text;
		
		//	imageObject = htmlToImageConverter.ConvertUrlToImage(url)[0];
		//}
		//else
		//{
			// convert HTML code
			string htmlCode = "<h1>my first image</h1>";
			string baseUrl = "";//textBoxBaseUrl.Text;
		
			imageObject = htmlToImageConverter.ConvertHtmlToImage(htmlCode, baseUrl)[0];
		//}
		
		// get the image buffer in the selected image format
		byte[] imageBuffer = GetImageBuffer(imageObject);
		
		// the image object rturned by converter can be disposed
		imageObject.Dispose();
		
		// inform the browser about the binary data format
		string mimeType = imageFormatName == "jpg" ? "jpeg" : imageFormatName;
		HttpContext.Current.Response.AddHeader("Content-Type", "image/" + mimeType);
		
		// let the browser know how to open the image and the image name
		HttpContext.Current.Response.AddHeader("Content-Disposition",
					String.Format("attachment; filename={0}; size={1}", fileName, imageBuffer.Length.ToString()));
		
		// write the image buffer to HTTP response
		HttpContext.Current.Response.BinaryWrite(imageBuffer);
		
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