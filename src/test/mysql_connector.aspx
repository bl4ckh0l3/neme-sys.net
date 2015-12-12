<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>

<script runat="server">
Dictionary<int, Logger> logs;

protected void Page_Load(Object sender, EventArgs e)
{
        /*string CommandText = "select * from logs";

	try
	{
	    OdbcConnection conn = DBConnectionManager.getDBConnection();	    
	    OdbcCommand myCommand = new OdbcCommand(CommandText, conn);
	    
		DataGrid1.DataSource = myCommand.ExecuteReader(CommandBehavior.CloseConnection);
		DataGrid1.DataBind();
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message);
	}

	try
	{	    
		logs = LoggerDao.getLogsList(null,null,null);
		
		Response.Write(logs.Count+"<br>");
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message);
	}*/
	
		MySqlConnection	conn;
		MySqlCommand	cmd;

		conn = new MySqlConnection("server=62.149.150.77;uid=Sql198279;pwd=a34d7876;database=Sql198279_1");
		/*try 
		{
			conn.Open();

			string sql = "select * from logs";
			cmd = new MySqlCommand(sql, conn);
			cmd.ExecuteNonQuery();

			conn.Close();
		}
		catch (Exception ex) 
		{
			MessageBox.Show("Exception: " + ex.Message);
		}*/
		
		if(conn .State != ConnectionState.Open)
		try
		{
		  conn .Open();
		}
		catch (MySqlException ex)
		{
		  throw (ex);
		}

}
</script>
<html>
<head>
</head>
<body style="FONT-FAMILY: arial">
    <h2>Simple Data Report 
    </h2>
    <hr size="1" />
    
    <%
	/*foreach (Logger k in logs.Values)
	{
		Response.Write(k.getMsg()+"<br>");
	} */  
    %>
</body>
</html>