<%@ Language="C#" Debug="true"%>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="com.nemesys.model" %>
<%@ Import Namespace="com.nemesys.database.repository" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.Caching" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>

<html>
<head>
</head>
<body>
<%try{
	
	JObject o = JObject.Parse(@"{ 'RateResponse': { 'Response': { 'ResponseStatus': { 'Code': '1', 'Description': 'Success' }, 'Alert': [ { 'Code': '110971', 'Description': 'Your invoice may vary from the displayed reference rates' }, { 'Code': '120900', 'Description': 'User Id and Shipper Number combination is not qualified to receive negotiated rates' } ], 'TransactionReference': { 'CustomerContext': '' } }, 'RatedShipment': { 'Service': { 'Code': '11', 'Description': '' }, 'RatedShipmentAlert': [ { 'Code': '120900', 'Description': 'User Id and Shipper Number combination is not qualified to receive negotiated rates.' }, { 'Code': '110971', 'Description': 'Your invoice may vary from the displayed reference rates' } ], 'BillingWeight': { 'UnitOfMeasurement': { 'Code': 'KGS', 'Description': 'Kilograms' }, 'Weight': '4.0' }, 'TransportationCharges': { 'CurrencyCode': 'EUR', 'MonetaryValue': '11.25' }, 'ServiceOptionsCharges': { 'CurrencyCode': 'EUR', 'MonetaryValue': '0.00' }, 'TotalCharges': { 'CurrencyCode': 'EUR', 'MonetaryValue': '11.25' }, 'NegotiatedRateCharges': { 'TotalCharge': { 'CurrencyCode': 'EUR', 'MonetaryValue': '11.14' } }, 'RatedPackage': { 'Weight': '4.0' } } } }");
	
	Response.Write("JObject:<br>"+o+"<br>");
	
	Response.Write("<br>code: "+o.SelectToken("RateResponse.Response.ResponseStatus.Code")+"<br>");

	Response.Write("<br>amount: "+o.SelectToken("RateResponse.RatedShipment.TotalCharges.MonetaryValue")+"<br>");
	
	
	
	//string code = o.SelectToken("RateResponse[*].Response[*].ResponseStatus[*].Code").ToString();
	//Response.Write("<br>code: "+code+"<br>");
	
	
	/*if(o.HasValues){
		//Response.Write("first:<br>"+o.First+"<br>");
		JToken t = o["RateResponse"];
		Response.Write("t:<br>"+t+"<br>");
		//JToken t1 = t["Response"];
		//Response.Write("t1:<br>"+t1+"<br>");
		JToken t2 = t["ResponseStatus"];
		Response.Write("t2:<br>"+t2+"<br>");
	}*/
	
	//Response.Write("ResponseStatus:<br>"+o.GetValue("ResponseStatus")+"<br>");
	
	//JToken status = null;
	
	/*
	if(o.TryGetValue("ResponseStatus",out status)){
		string code = status["Code"].ToString();
		Response.Write("code: "+code+"<br>");
	}
	*/
}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}%>
</body>
</html>