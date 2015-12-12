<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Odbc" %>
<script runat="server">

protected void Page_Load(Object sender, EventArgs e)
{
	OdbcConnection conn;
	string myConnectionString;

        myConnectionString = @"driver={MySQL ODBC 3.51 Driver};server=62.149.150.77;database=Sql198279_1;uid=Sql198279;pwd=a34d7876;port=3306;";
        string CommandText = "select * from logs";

	try
	{
	    conn = new OdbcConnection();
	    conn.ConnectionString = myConnectionString;
	    
	    OdbcCommand myCommand = new OdbcCommand(CommandText, conn);
	    
	    conn.Open();
	    
		DataGrid1.DataSource = myCommand.ExecuteReader(CommandBehavior.CloseConnection);
		DataGrid1.DataBind();
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
    <form runat="server">
        <asp:datagrid id="DataGrid1" runat="server" CellSpacing="1" GridLines="None" CellPadding="3" BackColor="White" ForeColor="Black" EnableViewState="False">
            <HeaderStyle font-bold="True" forecolor="white" backcolor="#4A3C8C"></HeaderStyle>
            <ItemStyle backcolor="#DEDFDE"></ItemStyle>
        </asp:datagrid>
    </form>
</body>
</html>