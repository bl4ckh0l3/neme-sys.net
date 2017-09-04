<%@ Language="C#" Debug="true"%>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="com.nemesys.model" %>
<%@ Import Namespace="com.nemesys.database.repository" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.Caching" %>

<html>
<head>
</head>
<body>
<%try{
	// start call shopping cart create
	RestClient client = new RestClient();
	client.EndPoint = @"https://wwwcie.ups.com/rest/Rate";
	client.Method = HttpVerb.POST;
	//client.Authenticator = new BasicAuthenticator("bl4ckh0l3", "$_uatos12976"); 
	client.PostData = "{'UPSSecurity': {'UsernameToken': {'Username': 'bl4ckh0l3','Password': '$_uatos12976'},'ServiceAccessToken': {'AccessLicenseNumber': '4D31063A140E945C'}},'RateRequest': {'Request': {'RequestOption': 'Rate','TransactionReference': {'CustomerContext': ''}},'Shipment': {'Shipper': {'Name': 'DickDick Shop','ShipperNumber': '9863X9','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},'ShipTo': {'Name': 'Jack Frost','Address': {'AddressLine': 'Via di arrivo, 10','City': 'Torino','StateProvinceCode': 'TO','PostalCode': '10121','CountryCode': 'IT'}},'ShipFrom': {'Name': 'DickDick Shop','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},'Service': {'Code': '11','Description': ''},'Package': [{'PackagingType': {'Code': '02','Description': 'my first package'},'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '10','Width': '15','Height': '5'},'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '70'}},{'PackagingType': {'Code': '02','Description': 'My second package'},'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '45','Width': '20','Height': '10'},'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '40'}}],'ShipmentRatingOptions': {'NegotiatedRatesIndicator': ''}}}}";
	string[] json = client.MakeRequest();	

	Response.Write("json response:<br><br>");
	Response.Write(json[0]+"<br>");
	Response.Write(json[1]+"<br>");
	Response.Write(json[2]+"<br>");
	
}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}%>
</body>
</html>