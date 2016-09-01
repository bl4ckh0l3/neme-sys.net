<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="Newtonsoft.Json" %>

<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		string idRequest = "1000000197343";
		string idMac = "v011954028996";

		// start call shopping cart create
		RestClient client = new RestClient();
		client.EndPoint = @"http://10.223.2.212:8081/checkout-api/api/v1/cart"; bfc-checkoutapi01
		client.Method = HttpVerb.POST;
		client.PostData = "{\"idMac\": \""+idMac+"\",\"idRequest\": "+idRequest+",\"userInfo\": {\"ip\": \"192.168.1.1\",\"uid\": null,\"userAgent\": null},\"passengerInformation\": {\"adults\": 1,\"infants\": 0,\"children\": 0},\"businessProfileId\": \"VIASKYSCANNERUK\",\"userCurrency\": \"EUR\"}";
		string[] json = client.MakeRequest();	
		
		Response.Write(json[0]+"<br><br>"+json[1]+"<br><br>"+json[2]);
		
		Dictionary<string, string> fieldValues = JsonConvert.DeserializeObject<Dictionary<string, string>>(json[1]);

		string loc = null;
		bool foundel = fieldValues.TryGetValue("Location", out loc);		
		if(foundel){
			client.EndPoint = loc;
			client.Method = HttpVerb.GET;
			json = client.MakeRequest();
			Response.Write(json[0]+"<br><br>"+json[1]+"<br><br>"+json[2]);
		}
		
	}
	    catch (Exception ex)
	{
	    Response.Write("<br>An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}
</script>
<html>
<head>
</head>
<body>
</body>
</html>