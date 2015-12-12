<%@ Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="com.nemesys.model" %>

<html>
<head>
</head>
<body>
<%
try{
int value10 = Guids.createGuidMax10Len(17);
long value18 = Guids.createGuidMax18Len(18);
string valuestr1 = Guids.createGuidRandomLen(20);
string valuestr2 = Guids.createGuidRandomLen(16);
string valuestr3 = Guids.createGuidRandomLen(33);
string testrnd1 = Guids.getUniqueKey(27);
string testrnd2 = Guids.createOrderGuid();
string testrnd3 = Guids.createUserGuid();
string testrnd4 = Guids.createPasswordGuid();
string testrnd5 = Guids.createVoucherCodeGuid();
Response.Write("value10: "+value10+"<br>");
Response.Write("value18: "+value18+"<br>");
Response.Write("valuestr1: "+valuestr1+"<br>");
Response.Write("valuestr2: "+valuestr2+"<br>");
Response.Write("valuestr3: "+valuestr3+"<br>");
Response.Write("testrnd1: "+testrnd1+"<br>");
Response.Write("testrnd2: "+testrnd2+"<br>");
Response.Write("testrnd3: "+testrnd3+"<br>");
Response.Write("testrnd4: "+testrnd4+"<br>");
Response.Write("testrnd5: "+testrnd5+"<br>");


}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}

Response.Write("<br><br>new mode whit guid class:<br>"+Guids.generateStandardGuid());

Response.Write("<br><br>other new mode whit guid class and time:<br>"+Guids.generateComb());

%>
</body>
</html>