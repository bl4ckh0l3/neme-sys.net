<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="com.nemesys.database.dao" %>
<%@ Import Namespace="com.nemesys.model" %>
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
	}*/

	try
	{	    
		logs = LoggerDao.getLogsList(null,null,null);
		
		Response.Write(logs.Count+"<br>");
	}
	    catch (Exception ex)
	{
	    Response.Write("An error occured: " + ex.Message);
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
    <!--<form runat="server">
        <asp:datagrid id="DataGrid1" runat="server" CellSpacing="1" GridLines="None" CellPadding="3" BackColor="White" ForeColor="Black" EnableViewState="False">
            <HeaderStyle font-bold="True" forecolor="white" backcolor="#4A3C8C"></HeaderStyle>
            <ItemStyle backcolor="#DEDFDE"></ItemStyle>
        </asp:datagrid>
    </form>-->
    
    <%
	foreach (Logger k in logs.Values)
	{
		Response.Write(k.getMsg()+"<br>");
	}   
    %>
</body>
</html>