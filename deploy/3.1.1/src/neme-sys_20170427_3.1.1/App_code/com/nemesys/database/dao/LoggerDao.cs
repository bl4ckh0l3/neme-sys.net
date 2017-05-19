using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;
using com.nemesys.model;

namespace com.nemesys.database.dao
{
	public class LoggerDao
	{	

		public static Dictionary<int, Logger> find(string type, string dta_from, string dta_to)
		{
			Dictionary<int, Logger> logs = new Dictionary<int, Logger>();
			
			int DD, MM, YY, HH, MIN, SS;	
			string strSQL = "SELECT * FROM LOG";
			
			if ((String.IsNullOrEmpty(type)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to)))
			{
				strSQL = "SELECT * FROM LOG";
			}
			else
			{
				strSQL = strSQL + " WHERE";
				if (!String.IsNullOrEmpty(type)){ strSQL = strSQL + " AND type=?type";}
				if (!String.IsNullOrEmpty(dta_from))
				{
					DateTime df = Convert.ToDateTime(dta_from);
					DD = df.Day;
					MM = df.Month;
					YY = df.Year;
					HH = 00;
					MIN = 00;
					SS = 00;				
					dta_from = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;

					strSQL = strSQL + " AND date_event >=?date_event";
				}
				
				if (!String.IsNullOrEmpty(dta_to))
				{ 
					DateTime dt = Convert.ToDateTime(dta_from);
					DD = dt.Day;
					MM = dt.Month;
					YY = dt.Year;
					HH = 23;
					MIN = 59;
					SS = 59;
					dta_to = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;
					
					strSQL = strSQL + " AND date_event <=?date_event";
				}			
			}
			
			strSQL = strSQL + " ORDER BY date_event DESC;";
			strSQL = strSQL.Replace("WHERE AND", "WHERE");
			strSQL = strSQL.Trim();
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: "+strSQL+"<br>");

			try
			{
				MySqlConnection conn = DBConnectionManager.getDBConnection();	    
				MySqlCommand command = new MySqlCommand(strSQL, conn);
				
				if ((String.IsNullOrEmpty(type)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to)))
				{
				}
				else
				{
					if (!String.IsNullOrEmpty(type)){ command.Parameters.AddWithValue("?type", type);}
					if (!String.IsNullOrEmpty(dta_from)){ command.Parameters.AddWithValue("?date_event", dta_from);}
					if (!String.IsNullOrEmpty(dta_to)){ command.Parameters.AddWithValue("?date_event", dta_to);}		
				}
				MySqlDataReader reader = command.ExecuteReader(CommandBehavior.CloseConnection);	
				
				if (reader.HasRows)
				{
					while (reader.Read())
					{					
						// Create a new log
						Logger logger = new Logger();
						int id = Convert.ToInt32(reader["id"].ToString());
						logger.id=id;
						logger.msg=reader["msg"].ToString();
						logger.usr=reader["usr"].ToString();
						logger.type=reader["type"].ToString();
						logger.date=Convert.ToDateTime(reader["date_event"].ToString());

						logs.Add(id,logger);
					}
				}
				reader.Close(); 
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("Exception: "+ex.Message+"<br>");
				logs = new Dictionary<int, Logger>();
			}
			return logs;		
		}
		

		public static void write(string strMsg, string usr, string type)
		{			
			string strSQL = "INSERT INTO LOG(msg, usr, type, date_event) VALUES(?msg,?usr,?type,?date_event);";
				
			try
			{
				MySqlConnection conn = DBConnectionManager.getDBConnection();	    
				MySqlCommand command = new MySqlCommand(strSQL, conn);
				
				command.Parameters.AddWithValue("?msg", strMsg);
				command.Parameters.AddWithValue("?usr", usr);
				command.Parameters.AddWithValue("?type", type);
				command.Parameters.AddWithValue("?date_event", DateTime.Now);		
				command.ExecuteNonQuery();
				conn.Close();
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("Exception: "+ex.Message+"<br>");
				throw ex;
			}
		}		
		
		public static void delete(string type, string dta_from, string dta_to)
		{
			int DD, MM, YY, HH, MIN, SS;			
			
			string strSQL = "DELETE FROM LOG";
						
			if ((String.IsNullOrEmpty(type)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to)))
			{
				strSQL = "DELETE FROM logs;";
			}
			else
			{
				strSQL = strSQL + " WHERE";
				if (!String.IsNullOrEmpty(type)){ strSQL = strSQL + " AND type=?type";}
				if (!String.IsNullOrEmpty(dta_from))
				{
					DateTime df = Convert.ToDateTime(dta_from);
					DD = df.Day;
					MM = df.Month;
					YY = df.Year;
					HH = 00;
					MIN = 00;
					SS = 00;				
					dta_from = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;

					strSQL = strSQL + " AND date_event >=?date_event";
				}
				
				if (!String.IsNullOrEmpty(dta_to))
				{ 
					DateTime dt = Convert.ToDateTime(dta_from);
					DD = dt.Day;
					MM = dt.Month;
					YY = dt.Year;
					HH = 23;
					MIN = 59;
					SS = 59;
					dta_to = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;
					
					strSQL = strSQL + " AND date_event <=?date_event";
				}			
			}
			
			strSQL = strSQL.Replace("WHERE AND", "WHERE");
			strSQL = strSQL.Trim();	

			try
			{
				MySqlConnection conn = DBConnectionManager.getDBConnection();	    
				MySqlCommand command = new MySqlCommand(strSQL, conn);
				
				if ((String.IsNullOrEmpty(type)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to)))
				{
				}
				else
				{
					if (!String.IsNullOrEmpty(type)){ command.Parameters.AddWithValue("?type", type);}
					if (!String.IsNullOrEmpty(dta_from)){ command.Parameters.AddWithValue("?date_event", dta_from);}
					if (!String.IsNullOrEmpty(dta_to)){ command.Parameters.AddWithValue("?date_event", dta_to);}		
				}
				command.ExecuteNonQuery();
				conn.Close();
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("Exception: "+ex.Message+"<br>");
				throw ex;
			}		
		}		
	}
}