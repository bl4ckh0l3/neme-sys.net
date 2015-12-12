using System;
using System.Data;
using System.Data.Odbc;

public class DBConnectionManager
{
	private static string connectionString = @"driver={MySQL ODBC 3.51 Driver};server=62.149.150.77;database=Sql198279_1;uid=Sql198279;pwd=a34d7876;port=3306;";

	public static OdbcConnection getDBConnection()
	{
		OdbcConnection connection = null;
		try
		{			
			connection = new OdbcConnection();
			connection.ConnectionString = connectionString;
			connection.Open();
		}
		    catch (Exception ex)
		{
			throw new Exception("Connection string was not set incorrectly: " + ex.Message);
		}
			
		return connection;
	}		
}