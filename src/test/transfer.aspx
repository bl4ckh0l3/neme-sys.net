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
		
		BasicAuthenticator auth = new BasicAuthenticator();
		//auth.user = "LM2";
		//auth.password = "14b0d25af44a7fd9114227f471f87f2d";

		// start call shopping cart create
		RestClient client = new RestClient();
		client.Authenticator = auth;
		client.Headers = new Dictionary<string,string>();
		client.Headers.Add("X-TripGo-Key","14b0d25af44a7fd9114227f471f87f2d");
		
		/*
		client.EndPoint = @"http://10.223.2.212:8081/checkout-api/api/v1/cart"; bfc-checkoutapi01
		client.Method = HttpVerb.POST;
		client.PostData = "{\"idMac\": \""+idMac+"\",\"idRequest\": "+idRequest+",\"userInfo\": {\"ip\": \"192.168.1.1\",\"uid\": null,\"userAgent\": null},\"passengerInformation\": {\"adults\": 1,\"infants\": 0,\"children\": 0},\"businessProfileId\": \"VIASKYSCANNERUK\",\"userCurrency\": \"EUR\"}";
		*/
		
		//client.EndPoint = @"https://connect.holidaytaxis.com/products/search/from/IATA/MAD/to/GEO/40.4098,-3.694/travelling/2016-12-22T09:55:00/returning/2016-12-24T15:30:00/adults/2/children/0/infants/0";
		client.EndPoint = @"https://api.tripgo.com/v1/routing.json?from=(-33.859,151.207)&to=(-33.891,151.209)&modes[]=pt_pub&v=11&locale=en";
		client.Method = HttpVerb.GET;
		
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