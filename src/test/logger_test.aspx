<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.database" %>
<%@ import Namespace="com.nemesys.database.dao" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.model" %>

<%@ import Namespace="NHibernate" %>
<%@ import Namespace="NHibernate.Cfg" %>

<script runat="server">
IDictionary<int, Logger> logs;

ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
public string testex;

protected void Page_Load(Object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	
	testex = "Рубцы являются следствием ответной";
	/*
	try
	{	    
		logs = lrep.find(null,"25/03/2013",null);
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message);
	}

	try
	{

		Logger log = new Logger();
		log.usr= "system";
		log.msg = "test logger nhibernate";
		log.type = "debug";
		log.date = DateTime.Now;

		lrep.write(log);
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	*/	
}
</script>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body>
    <h2>Logger Report </h2>
    
    <%
	//foreach (Logger k in logs.Values)
	//{
		//Response.Write(k.date+" - " +k.type+" - " +k.msg+"<br>");
	//} 

	LoggerDao.write(testex, "system","debug");	

	//LoggerDao.delete("info", "25/03/2013",null);	
    %>
</body>
</html>