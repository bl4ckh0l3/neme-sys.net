<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>

<html>
<head>
</head>
<body style="FONT-FAMILY: arial">
<script runat="server">
protected void Page_Load(Object sender, EventArgs e)
{
	MySqlConnection conn;
	MySqlCommand myCommand;
	MySqlDataReader myReader;
	
	try
	{
		string myConnectionString;

		//myConnectionString = @"driver={MySQL ODBC 3.51 Driver};server=62.149.150.77;database=Sql198279_1;uid=Sql198279;pwd=a34d7876;port=3306;";
		myConnectionString = "server=62.149.150.77;database=Sql198279_1;user=Sql198279;port=3306;password=a34d7876;pooling=true";
		conn = new MySqlConnection(myConnectionString);	    
		conn.Open();

		string sql = "select * from logs";
		myCommand = new MySqlCommand(sql, conn);
		myReader = myCommand.ExecuteReader();

		
Response.Write("typeof(myCommand): "+myCommand.GetType().Name+"<br>");
Response.Write("typeof(myReader): "+myReader.GetType().Name+"<br>");

		while (myReader.Read()) 
		{ 
		Response.Write(myReader.GetInt32(0) + ", " + myReader.GetString(1)+"<br>"); 
		} 
		myReader.Close(); 
		conn.Close(); 
	}
	catch (Exception ex)
	{
		//throw (ex);
		Response.Write(ex.Message+"<br>");
	}
	/*finally 
	{ 
		// always call Close when done reading. 
		myReader.Close(); 
		// always call Close when done reading. 
		conn.Close(); 
	}*/ 	
}
</script>
</body>
</html>