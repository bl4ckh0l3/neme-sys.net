<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="iTextSharp.text" %>
<%@ import Namespace="iTextSharp.text.pdf" %>

<script runat="server">		

protected void Page_Load(Object sender, EventArgs e)
{
	try{
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.pdf");
	
		using(System.IO.MemoryStream memoryStream = new System.IO.MemoryStream())   
		{  
			Document document = new Document(PageSize.A4, 10, 10, 10, 10);  
	  
			PdfWriter writer = PdfWriter.GetInstance(document, memoryStream);  
			document.Open();  
	  
			Chunk chunk = new Chunk("This is from chunk. ");  
			document.Add(chunk);  
	  
			Phrase phrase = new Phrase("This is from Phrase.");  
			document.Add(phrase);  
	  
			Paragraph para = new Paragraph("This is from paragraph.");  
			document.Add(para);  
	  
			string text = "you are successfully created PDF file.";  
			Paragraph paragraph = new Paragraph();  
			paragraph.SpacingBefore = 10;  
			paragraph.SpacingAfter = 10;  
			paragraph.Alignment = Element.ALIGN_LEFT;  
			//paragraph.Font = FontFactory.GetFont(FontFactory.HELVETICA, 12f, BaseColor.GREEN);  
			paragraph.Add(text);  
			document.Add(paragraph);  
	  
			document.Close();  
			byte[] bytes = memoryStream.ToArray();  
			memoryStream.Close();  
			Response.Clear();  
			Response.ContentType = "application/pdf";  
	  
			string pdfName = "User";  
			Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName);  
			Response.ContentType = "application/pdf";  
			Response.Buffer = true;  
			Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);  
			Response.BinaryWrite(bytes);  
			Response.End();  
			Response.Close();  
		} 				
		
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