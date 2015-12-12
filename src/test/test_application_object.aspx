<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.IO.Compression" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Text" %>

<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	//response.write(new Uri("http://www.blackholenet.com/public/conf/nemesi_config.xml").AbsolutePath)
	//string a = HttpContext.Current.Server.MapPath("~/App_Data");


	Response.Write("Version: "+System.Environment.Version.ToString()+"<br>");
	Response.Write("Version: "+HttpContext.Current.Server.MapPath("~/App_Data")+"<br>");

	try
	{	    


		// Open an existing zip file for reading
		ZipStorer zip = ZipStorer.Open(HttpContext.Current.Server.MapPath("~/App_Data/header.zip"), FileAccess.Read);

		// Read the central directory collection
		List<ZipStorer.ZipFileEntry> dir = zip.ReadCentralDir();

		// Look for the desired file
		foreach (ZipStorer.ZipFileEntry entry in dir)
		{
		    //if (Path.GetFileName(entry.FilenameInZip) == "sample.jpg")
		    //{
			// File found, extract it
			zip.ExtractFile(entry, HttpContext.Current.Server.MapPath("~/App_Data/header/"+entry.FilenameInZip));
			//break;
		    //}
		    //Response.Write("filename: "+entry.FilenameInZip+"<br>");
		}
		zip.Close();


	}
	catch (Exception ex)
	{
		Response.Write("An error occured: " + ex.Message);
	}
}
</script>