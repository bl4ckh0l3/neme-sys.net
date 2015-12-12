<%@ Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>
<%//@ Import Namespace="System.Web.Script.Serialization" %>
<%@ Import Namespace="com.nemesys.model" %>
<%@ Import Namespace="com.nemesys.database.repository" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Web.Caching" %>

<html>
<head>
</head>
<body>
<%
try{

	//AvailableLanguage avl = new AvailableLanguage();
	//avl.keyword = "IT";
	//avl.description = "italian";
	//product.Price = 3.99M;
	//product.Sizes = new string[] { "Small", "Medium", "Large" };
	
	//string json = JsonConvert.SerializeObject(avl);
	//{
	//  "Name": "Apple",
	//  "Expiry": new Date(1230422400000),
	//  "Price": 3.99,
	//  "Sizes": [
	//    "Small",
	//    "Medium",
	//    "Large"
	//  ]
	//}
	
	//AvailableLanguage deserializedProduct = JsonConvert.DeserializeObject<AvailableLanguage>(json);
	//Response.Write(deserializedProduct.ToString());
	
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	IList<FContent> contents2 = contentrep.find(null,null,null,0,null,null,1,null,null,false,false,false,true);

	IDictionaryEnumerator CacheEnum = Cache.GetEnumerator();
	while (CacheEnum.MoveNext())
	{		  
		string cacheKey = Server.HtmlEncode(CacheEnum.Key.ToString()); 
		if(cacheKey.Contains("list-fcontent"))
		{ 
			Response.Write("<br>"+cacheKey+"<br>");
		}  
	}
	
	foreach(FContent c in contents2){
		Response.Write("<br>"+c.ToString()+"<br>");
	}

}catch(Exception ex){
	Response.Write("An error occured: " + ex.Message);
}

//Response.Write("<br><br>new mode whit guid class:<br>"+Guids.generateStandardGuid());

//Response.Write("<br><br>other new mode whit guid class and time:<br>"+Guids.generateComb());

%>
</body>
</html>