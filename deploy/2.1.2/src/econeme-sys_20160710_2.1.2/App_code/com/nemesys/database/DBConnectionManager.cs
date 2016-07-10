using System;
using System.Data;
using MySql.Data.MySqlClient;
using com.nemesys.model;
using com.nemesys.services;

namespace com.nemesys.database
{
	public class DBConnectionManager
	{
		private static ConfigurationService configService = new ConfigurationService();
		
		private static string connectionString = configService.get("dbconn").value;

		public static MySqlConnection getDBConnection()
		{
			MySqlConnection connection = null;
			try
			{			
				connection = new MySqlConnection();
				connection.ConnectionString = connectionString;
				connection.Open();
			}
			    catch (Exception ex)
			{
				throw new Exception("Connection string was not set incorrectly: " + ex.Message);
			}
				
			return connection;
		}

		public static string getConnectionString()
		{
			return connectionString;
		}

		public static void setConnectionString(string newConnString)
		{
			connectionString = newConnString;
		}
	}
}