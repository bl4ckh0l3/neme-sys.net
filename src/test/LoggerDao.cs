using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;


public class LoggerDao
{	

	public Dictionary getListaLogs(tipo, dta_from, dta_to)
	{
		int DD, MM, YY, HH, MIN, SS;	
		string strSQL = "SELECT * FROM logs";
		
		if ((String.IsNullOrEmpty(tipo)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to))){
			strSQL = "SELECT * FROM logs";
		}else{
			strSQL = strSQL + " WHERE";
			if (!String.IsNullOrEmpty(tipo)){ strSQL = strSQL + " AND type=?";}
			if (!String.IsNullOrEmpty(dta_from)){
				DateTime df = Convert.ToDateTime(dta_from)
				DD = df.Day;
				MM = df.Month;
				YY = df.Year;
				HH = 00;
				MIN = 00;
				SS = 00;				
				dta_from = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;

				strSQL = strSQL + " AND date_event >=?";
			}
			
			if (!String.IsNullOrEmpty(dta_to)){ 
				DateTime dt = Convert.ToDateTime(dta_from)
				DD = dt.Day;
				MM = dt.Month;
				YY = dt.Year;
				HH = 23;
				MIN = 59;
				SS = 59;
				dta_to = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;
				
				strSQL = strSQL + " AND date_event <=?";
			}			
		}
		
		strSQL = strSQL + " ORDER BY date_event DESC;";
		strSQL = strSQL.Replace("WHERE AND", "WHERE");
		strSQL = strSQL.Trim();

		try
		{
			OdbcConnection conn = DBConnectionManager.getDBConnection();	    
			OdbcCommand command = new OdbcCommand(strSQL, conn);
			
			if ((String.IsNullOrEmpty(tipo)) && (String.IsNullOrEmpty(dta_from)) && (String.IsNullOrEmpty(dta_to))){
			}else{
				if (!String.IsNullOrEmpty(tipo)){ command.Parameters.Add("type", OdbcType.VarChar).Value = tipo;}
				if (!String.IsNullOrEmpty(dta_from)){ command.Parameters.Add("date_event", OdbcType.DateTime).Value = dta_from;}
				if (!String.IsNullOrEmpty(dta_to)){ command.Parameters.Add("date_event", OdbcType.DateTime).Value = dta_to;}		
			}
			OdbcDataReader reader = command.ExecuteReader(CommandBehavior.CloseConnection);	
				
			if (reader.HasRows)
			{
				Dictionary<int, string> logs = new Dictionary<int, string>();
				while (reader.Read())
				{
					// Create a new log
					Logger logger = new Logger();
					logger.setLogID(reader["id"])
					logger.setLogMsg(reader["msg"])
					logger.setLogUsr(reader["usr"])	
					logger.setLogTipo(reader["type"])	
					logger.setLogData(reader["date_event"])

					logs.Add(logger);
				}
				return logs;
			}
		}
		catch(Exception ex)
		{
			return null;
		}		
	}
	

	/*public void write(strMsg, usr, tipo)
	{
		on error resume next
		Dim objDB, strSQL, objRS, objConn
		Dim dta_ins, DD, MM, YY, HH, MIN, SS
		
		dta_ins = Now()
		strSQL = "INSERT INTO logs(msg, usr, type, date_event) VALUES(?,?,?,?);"
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()	
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		objCommand.Parameters.Append objCommand.CreateParameter(,201,1,-1,strMsg)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,50,usr)
		objCommand.Parameters.Append objCommand.CreateParameter(,200,1,15,tipo)
		objCommand.Parameters.Append objCommand.CreateParameter(,135,1,,dta_ins)
		objCommand.Execute()
		Set objCommand = Nothing
		Set objDB = Nothing
		
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
	}		
	
	public void deleteLogs(tipo, dta_from, dta_to)
	{
		on error resume next
		Dim objDB, strSQL, objRS, objConn, objDict
		Dim DD, MM, YY, HH, MIN, SS		
		
		strSQL = "DELETE FROM logs"
		
		if ((isNull(tipo) OR tipo="") AND (isNull(dta_from) OR dta_from="") AND (isNull(dta_to) OR dta_to="")) then
			strSQL = "DELETE FROM logs;"
		else
			strSQL = strSQL & " WHERE"
			
			if not(isNull(tipo)) AND tipo<>"" then strSQL = strSQL & " AND type=?"
			'il passaggio seguente è da verificare con query secca di test su DB
			if not(isNull(dta_from)) AND dta_from<>"" then 		
				DD = DatePart("d", dta_from)
				MM = DatePart("m", dta_from)
				YY = DatePart("yyyy", dta_from)
				HH = 00
				MIN = 00
				SS = 00
				dta_from = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS

				strSQL = strSQL & " AND date_event >=?"
			end if

			if not(isNull(dta_to)) AND dta_to<>"" then 
				DD = DatePart("d", dta_to)
				MM = DatePart("m", dta_to)
				YY = DatePart("yyyy", dta_to)
				HH = 23
				MIN = 59
				SS = 59
				dta_to = YY&"-"&MM&"-"&DD&" "&HH&":"&MIN&":"&SS
				
				strSQL = strSQL & " AND date_event <=?"
			end if
		end if
		
		strSQL = Replace(strSQL, "WHERE AND", "WHERE", 1, -1, 1)
		strSQL = Trim(strSQL)

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		Dim objCommand
		Set objCommand = Server.CreateObject("ADODB.Command")
		objCommand.ActiveConnection = objConn
		objCommand.CommandType=1
		objCommand.CommandText = strSQL
		if ((isNull(tipo) OR tipo="") AND (isNull(dta_from) OR dta_from="") AND (isNull(dta_to) OR dta_to="")) then
		else
			if not(isNull(tipo)) AND tipo<>"" then objCommand.Parameters.Append objCommand.CreateParameter(,200,1,15,tipo)
			if not(isNull(dta_from)) AND dta_from<>"" then objCommand.Parameters.Append objCommand.CreateParameter(,135,1,,dta_from)
			if not(isNull(dta_to)) AND dta_to<>"" then objCommand.Parameters.Append objCommand.CreateParameter(,135,1,,dta_to)			
		end if
		objCommand.Execute()
		Set objCommand = Nothing
		Set objDB = Nothing
 
		if Err.number <> 0 then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if		
	}*/		
}