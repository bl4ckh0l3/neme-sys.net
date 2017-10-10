<%@ Page Language="C#" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="PdfFileWriter" %>
<%@ import Namespace="System.Diagnostics" %>
<%@ import Namespace="System.Drawing" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="com.nemesys.model" %>

<script runat="server">		
private PdfDocument		Document;
private PdfPage			Page;
private PdfContents		Contents;
private PdfFont			NormalFont;
private PdfFont			TableTitleFont;


protected void Page_Load(Object sender, EventArgs e)
{
	try{
		string fileName = HttpContext.Current.Server.MapPath("~/public/upload/files/billings/test.pdf");
	
		// Create empty document
		// Arguments: page width: 8.5”, page height: 11”, Unit of measure: inches
		// Return value: PdfDocument main class
		Document = new PdfDocument(PaperType.Letter, false, UnitOfMeasure.Inch, fileName);

		// Debug property
		// By default it is set to false. Use it for debugging only.
		// If this flag is set, PDF objects will not be compressed, font and images will be replaced
		// by text place holder. You can view the file with a text editor but you cannot open it with PDF reader.
		Document.Debug = true;

		// define font resource
		NormalFont = PdfFont.CreatePdfFont(Document, "Arial", FontStyle.Regular, true);
		TableTitleFont = PdfFont.CreatePdfFont(Document, "Times New Roman", FontStyle.Bold, true);

		// book list table
		//CreateBookList();

		// stock price table
		CreateStockTable();

		// textbox overflow example
		TestOverflow();

		// argument: PDF file name
		Document.CreateFile();

		// start default PDF reader and display the file
		//Process Proc = new Process();
	    //Proc.StartInfo = new ProcessStartInfo(fileName);
	    //Proc.Start();

		// exit
		return;					
		
	}catch (Exception ex){
	     Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
}

	public void CreateStockTable()
		{
		const Int32 ColDate = 0;
		const Int32 ColOpen = 1;
		const Int32 ColHigh = 2;
		const Int32 ColLow = 3;
		const Int32 ColClose = 4;
		const Int32 ColVolume = 5;

		// Add new page
		Page = new PdfPage(Document);

		// Add contents to page
		Contents = new PdfContents(Page);

		// create stock table
		PdfTable StockTable = new PdfTable(Page, Contents, NormalFont, 9.0);

		// divide columns width in proportion to following values
		StockTable.SetColumnWidth(1.2, 1.0, 1.0, 1.0, 1.0, 1.2);

		// set all borders
		StockTable.Borders.SetAllBorders(0.012, Color.DarkGray, 0.0025, Color.DarkGray);

		// make some changes to default header style
		StockTable.DefaultHeaderStyle.Alignment = ContentAlignment.BottomRight;

		// create private style for header first column
		StockTable.Header[ColDate].Style = StockTable.HeaderStyle;
		StockTable.Header[ColDate].Style.Alignment = ContentAlignment.MiddleLeft;

		StockTable.Header[ColDate].Value = "Date";
		StockTable.Header[ColOpen].Value = "Open";
		StockTable.Header[ColHigh].Value = "High";
		StockTable.Header[ColLow].Value = "Low";
		StockTable.Header[ColClose].Value = "Close";
		StockTable.Header[ColVolume].Value = "Volume";

		// make some changes to default cell style
		StockTable.DefaultCellStyle.Alignment = ContentAlignment.MiddleRight;
		StockTable.DefaultCellStyle.Format = "#,##0.00";

		// create private style for date column
		StockTable.Cell[ColDate].Style = StockTable.CellStyle;
		StockTable.Cell[ColDate].Style.Alignment = ContentAlignment.MiddleLeft;
		StockTable.Cell[ColDate].Style.Format = null;

		// create private styles for volumn column
		PdfTableStyle GoingUpStyle = StockTable.CellStyle;
		GoingUpStyle.BackgroundColor = Color.LightGreen;
		GoingUpStyle.Format = "#,##0";
		PdfTableStyle GoingDownStyle = StockTable.CellStyle;
		GoingDownStyle.BackgroundColor = Color.LightPink;
		GoingDownStyle.Format = "#,##0";

		StockTable.Close();

		// exit
		return;
		}
		
	public void TestOverflow()
		{
		// Add new page
		Page = new PdfPage(Document);

		// Add contents to page
		Contents = new PdfContents(Page);

		// create table
		PdfTable Table = new PdfTable(Page, Contents, NormalFont, 9.0);

		// Commit
		Table.CommitToPdfFile = true;
		Table.CommitGCCollectFreq = 1;

		// divide columns width in proportion to following values
		Table.SetColumnWidth(1.0, 2.75, 2.75);

		Table.Header[0].Value = "Column 1";
		Table.Header[1].Value = "Column 2";
		Table.Header[2].Value = "Column 3";

		Table.Cell[1].Style = Table.CellStyle;
		Table.Cell[1].Style.MultiLineText = true;
		Table.Cell[1].Style.TextBoxPageBreakLines = 4;

		Table.Cell[2].Style = Table.CellStyle;
		Table.Cell[2].Style.MultiLineText = true;
		Table.Cell[2].Style.TextBoxPageBreakLines = 8;

		Int32[] Lines1 = {40, 90, 20};
		Int32[] Lines2 = {20, 50, 70};

		for(Int32 Row = 0; Row < 3; Row++)
			{
			Table.Cell[0].Value = String.Format("Row {0}", Row + 1);

			StringBuilder Text1 = new StringBuilder();
			for(Int32 Line = 0; Line < Lines1[Row % 3]; Line++) Text1.AppendFormat("Line {0}\r\n", Line + 1);
			Table.Cell[1].Value = Text1.ToString();

			StringBuilder Text2 = new StringBuilder();
			for(Int32 Line = 0; Line < Lines2[Row % 3]; Line++) Text2.AppendFormat("Line {0}\r\n", Line + 1);
			Table.Cell[2].Value = Text2.ToString();

			Table.DrawRow();

			// DEBUG
			//Trace.Write(String.Format("Total Memory: {0}", GC.GetTotalMemory(false)));
			}

		Table.Close();

		// exit
		return;
		}
</script>
<html>
<head>
</head>
<body>

</body>
</html>