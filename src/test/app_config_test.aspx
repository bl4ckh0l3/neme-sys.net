<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.model" %>

<script runat="server">
//IDictionary<int, Logger> configs;
IList<Config> configs;
		
protected void Page_Load(Object sender, EventArgs e)
{
	ConfigurationService confservice = new ConfigurationService();
	try
	{	
		configs = confservice.getAllConfigurations();
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}

	//try
	//{

		//Config config = new Config("confirm_registration","2","backend.config.lista.table.description.confirm_registration","0","configuration_reg","0,1,2");
		Config config = confservice.get("confirm_registration");
		Response.Write("config: " + config.toString());
	/*}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}*/

	
}
</script>
<html>
<head>
</head>
<body>
    <h2>Config Report </h2>
    
    <%
	foreach (Config k in configs)
	{
		Response.Write(k.toString()+"<br>");
	} 

	//LoggerDao.write("test logger asp.net", "system","debug");	

	//LoggerDao.delete("info", "25/03/2013",null);	
    %>
</body>
</html>