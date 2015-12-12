<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.model" %>

<script runat="server">
protected Template template;
protected void Page_Load(Object sender, EventArgs e)
{
	try
	{
		/*string root = System.Web.HttpContext.Current.Server.MapPath("/public/layout/addson/");	
		string[] dirs = Directory.GetDirectories(@root, "*.*");
		Response.Write("The number of directories starting with p is "+dirs.Length);
		foreach (string dir in dirs) 
		{
		Response.Write(dir+"<br>");
		}*/
		
		
		IDictionary<string, string> elementsMap = new Dictionary<string, string>();
		string treeRoot = "/public/layout/addson/";
		generateTree(treeRoot, elementsMap);		
		
		Response.Write("elementsMap.Count:"+elementsMap.Count+"<br>");
		
		foreach(string elem in elementsMap.Keys)
		{
			Response.Write("elem key:"+elem+" - value:"+elementsMap[elem]+"<br>");
		}
		
		
		//cancello la directory fisica del template
		string tpath = HttpContext.Current.Server.MapPath("~/public/templates/aaaaaa");
		Response.Write("tpath:"+tpath+"<br>");
		if(Directory.Exists(tpath)) 
		{
			Response.Write("before delete :"+tpath+"<br>");
			Directory.Delete(tpath, true);
		}			

	}
	catch (Exception ex)
	{
		Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
}

private void generateTree(string path, IDictionary<string, string> elementsMap)
{
	string vDir = path;
	string root = System.Web.HttpContext.Current.Server.MapPath(vDir);
	System.IO.DirectoryInfo dirInfo = new DirectoryInfo(root);
	System.IO.DirectoryInfo[] dirInfos = dirInfo.GetDirectories("*.*");
	System.IO.FileInfo[] fileNames = dirInfo.GetFiles("*.*");
	
	foreach (System.IO.DirectoryInfo d in dirInfos)
	{
		string fpath = vDir + d.Name + "/";
		generateTree(fpath, elementsMap);
	}

	foreach (System.IO.FileInfo fi in fileNames)
	{
		elementsMap.Add(fi.Name, vDir);
	}
}
</script>
<html>
<head>
</head>
<body>
    <h2>Template Report </h2>
    
    <%	
	
	%>
</body>
</html>