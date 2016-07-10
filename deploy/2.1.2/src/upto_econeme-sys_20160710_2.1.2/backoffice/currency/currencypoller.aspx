<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.Caching" %>
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
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	
	//UriBuilder builder = new UriBuilder(Request.Url.Scheme|"https", Request.Url.Host, Request.Url.Port, Request.Url.AbsolutePath);
	//builder.Fragment = "main";	
	//Response.Write("builder.Scheme:"+builder.Scheme.ToString()+"<br>");
	//Response.Write("builder.Host:"+builder.Host.ToString()+"<br>");
	//Response.Write("builder.Port:"+builder.Port.ToString()+"<br>");
	//Response.Write("builder.Path:"+builder.Path.ToString()+"<br>");
	//Response.Write("builder.Uri.AbsolutePath:"+builder.Uri.AbsolutePath+"<br>");
	//Response.Write("builder Complete:"+builder.ToString());
	
	//UriBuilder builder = new UriBuilder(Request.Url);
	//builder.Scheme = "http";
	//builder.Port = -1;
	//builder.Path = "default.aspx";
	//Response.Write("builder URI:"+builder.ToString());

	ICurrencyRepository currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");
	
	// Create a request for the URL. 
	WebRequest request = WebRequest.Create("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml");
	
	// If required by the server, set the credentials.
	//request.Credentials = CredentialCache.DefaultCredentials;
	
	// Get the response.
	WebResponse response = request.GetResponse();
	
	// Display the status.
	//Console.WriteLine (((HttpWebResponse)response).StatusDescription);
	
	// Get the stream containing content returned by the server.
	Stream dataStream = response.GetResponseStream();
	
	// Open the stream using a StreamReader for easy access.
	StreamReader reader = new StreamReader(dataStream);
	
	// Read the content.
	string responseFromServer = reader.ReadToEnd();
	
	// Display the content.
	//Console.WriteLine (responseFromServer);
	
	// Clean up the streams and the response.
	reader.Close();
	response.Close();

	int length = responseFromServer.LastIndexOf("</Cube>")-responseFromServer.IndexOf("<Cube>")+7;
	responseFromServer = responseFromServer.Substring(responseFromServer.IndexOf("<Cube>"), length);

	XmlDocument xml = new XmlDocument();
	xml.Load(new StringReader(responseFromServer));

	XmlNode node = xml.SelectSingleNode("/Cube/Cube");
	//System.Web.HttpContext.Current.Response.Write(node.Attributes.GetNamedItem("attr_server_name").Value+"<br>");
	string dta_refer = node.Attributes.GetNamedItem("time").Value;
	DateTime referDate = Convert.ToDateTime(dta_refer);
	DateTime insertDate = DateTime.Now;

	XmlNode xnList = xml.SelectSingleNode("/Cube/Cube");
	if (xnList.HasChildNodes)
	{
		for (int i=0; i<xnList.ChildNodes.Count; i++)
		{
			XmlNode inner = xnList.ChildNodes[i];
			
			string currency = inner.Attributes.GetNamedItem("currency").Value;
			decimal rate = Convert.ToDecimal(inner.Attributes.GetNamedItem("rate").Value.Replace(".",","));
	
			Currency entry = new Currency();
			entry.currency = currency;	
			entry.rate = rate;	 
			entry.referDate = referDate;
			entry.insertDate = insertDate;
			entry.active = false;
			entry.isDefault = false;
			
			try
			{
				Currency objCurrency = currrep.getByCurrency(currency);
				
				if(objCurrency != null) 
				{
					objCurrency.rate = entry.rate;
					objCurrency.referDate = entry.referDate;
					objCurrency.insertDate = entry.insertDate;
					currrep.update(objCurrency);
				}
				else
				{	
					currrep.insert(entry);
				}
			}catch(Exception ex){
				StringBuilder builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);	
				Logger log = new Logger(builder.ToString(), "system", "debug", DateTime.Now);			
				lrep.write(log);	
			}
		}
	}
	Response.Write("<currency_confirmed>currency modified</currency_confirmed>");
}
</script>