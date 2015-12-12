<%@ Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="com.nemesys.model" %>
<%@ Import Namespace="com.nemesys.services" %>
<%@ Import Namespace="com.nemesys.database.repository" %>

<html>
<head>
</head>
<body>
<%
try{
IList<Geolocalization> objListaPoint = new List<Geolocalization>();

Geolocalization objLoc1 = new Geolocalization();	
objLoc1.latitude=25.774252M;
objLoc1.longitude=-80.190262M;	
Geolocalization objLoc2 = new Geolocalization();	
objLoc2.latitude=18.466465M;
objLoc2.longitude=-66.118292M;	
Geolocalization objLoc3 = new Geolocalization();	
objLoc3.latitude=32.321384M;
objLoc3.longitude=-64.75737M;	
Geolocalization objLoc4 = new Geolocalization();	
objLoc4.latitude=25.774252M;
objLoc4.longitude=-80.190262M;	
objListaPoint.Add(objLoc1);
objListaPoint.Add(objLoc2);	
objListaPoint.Add(objLoc3);
objListaPoint.Add(objLoc4);

Geolocalization pointCheck = new Geolocalization();
pointCheck.latitude=26.980829M;
pointCheck.longitude=-70.052491M;

Geolocalization pointCheck2 = new Geolocalization();
pointCheck2.latitude=25.774252M;
pointCheck2.longitude=-80.190262M;

Geolocalization pointCheck3 = new Geolocalization();
pointCheck3.latitude=32.268555M;
pointCheck3.longitude=-59.088135M;

Geolocalization pointCheck4 = new Geolocalization();
pointCheck4.latitude=29.190533M;
pointCheck4.longitude=-69.920655M;


//'************************************** check on circle
Geolocalization pointCenterCircle = new Geolocalization();
pointCenterCircle.latitude=25.774252M;
pointCenterCircle.longitude=-80.190262M;

Geolocalization pointCheckCircle = new Geolocalization();
pointCheckCircle.latitude=32.268555M;
pointCheckCircle.longitude=-59.088135M;

Geolocalization pointCheckCircle2 = new Geolocalization();
pointCheckCircle2.latitude=25.799891M;
pointCheckCircle2.longitude=-80.291748M;

Geolocalization pointCheckCircle3 = new Geolocalization();
pointCheckCircle3.latitude=18.466465M;
pointCheckCircle3.longitude=-66.118292M;

double radius = 2000000; //' 2000 km

Response.Write("objLocBase.isPointInPolygon(): "+ GeolocalizationService.isPointInPolygon(pointCheck, objListaPoint)+"<br>");
Response.Write("objLocBase.isPointInPolygon(): "+ GeolocalizationService.isPointInPolygon(pointCheck2, objListaPoint)+"<br>");
Response.Write("objLocBase.isPointInPolygon(): "+ GeolocalizationService.isPointInPolygon(pointCheck3, objListaPoint)+"<br>");
Response.Write("objLocBase.isPointInPolygon(): "+ GeolocalizationService.isPointInPolygon(pointCheck4, objListaPoint)+"<br>");

Response.Write("objLocBase.IsPointInCircle(): "+ GeolocalizationService.isPointInCircleOnEarthSurface(pointCheckCircle, pointCenterCircle, radius)+"<br>");
Response.Write("objLocBase.IsPointInCircle(): "+ GeolocalizationService.isPointInCircleOnEarthSurface(pointCheckCircle2, pointCenterCircle, radius)+"<br>");
Response.Write("objLocBase.IsPointInCircle(): "+ GeolocalizationService.isPointInCircleOnEarthSurface(pointCheckCircle3, pointCenterCircle, radius)+"<br>");
}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}

%>
</body>
</html>