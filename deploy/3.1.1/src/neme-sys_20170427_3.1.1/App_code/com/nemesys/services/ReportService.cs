using System;
using System.Text;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using System.Web.Caching;
using System.Xml;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
//using OfficeOpenXml;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
//using OfficeOpenXml.Style;
using System.Drawing;
using System.Text;

namespace com.nemesys.services
{
	/*public class ReportService
	{		
		public static void UserReportExcel(IList<User> users)
		{
			using (ExcelPackage pck = new ExcelPackage())
			{
				//Create the worksheet
				ExcelWorksheet ws = pck.Workbook.Worksheets.Add("Demo");

				//Load the datatable into the sheet, starting from cell A1. Print the column names on row 1
				//ws.Cells["A1"].LoadFromDataTable(tbl, true);

				//Format the header for column 1-3
				using (ExcelRange rng = ws.Cells["A1:C1"])
				{
					rng.Style.Font.Bold = true;
					//rng.Style.Fill.PatternType = ExcelFillStyle.Solid;                      //Set Pattern for the background to Solid
					rng.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(79, 129, 189));  //Set color to dark blue
					rng.Style.Font.Color.SetColor(Color.White);
				}

				//Example how to Format Column 1 as numeric 
				//using (ExcelRange col = ws.Cells[2, 1, 2 + tbl.Rows.Count, 1])
				//{
				//	col.Style.Numberformat.Format = "#,##0.00";
				//	col.Style.HorizontalAlignment = ExcelHorizontalAlignment.Right;
				//}

				//Write it back to the client
				Response.Clear();
				Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
				Response.AddHeader("content-disposition", "attachment;  filename=ExcelDemo.xlsx");
				Response.BinaryWrite(pck.GetAsByteArray());
				Response.End();
			}
		}
	}*/
	
	

	/*public class CsvRow : List<string>
	{
		public string LineText { get; set; }
	}

	public class CsvFileWriter
	{
		public void WriteRow(CsvRow row)
		{
			StringBuilder builder = new StringBuilder();
			bool firstColumn = true;
			foreach (string value in row)
			{
				// Add separator if this isn't the first value
				if (!firstColumn)
					builder.Append(',');
				// Implement special handling for values that contain comma or quote
				// Enclose in quotes and double up any double quotes
				if (value.IndexOfAny(new char[] { '"', ',' }) != -1)
					builder.AppendFormat("\"{0}\"", value.Replace("\"", "\"\""));
				else
					builder.Append(value);
				
				firstColumn = false;
			}
			row.LineText = builder.ToString();
			WriteLine(row.LineText);
		}
	}

	public class CsvFileReader
	{
		public bool ReadRow(CsvRow row)
		{
			row.LineText = ReadLine();
			if (String.IsNullOrEmpty(row.LineText))
				return false;

			int pos = 0;
			int rows = 0;

			while (pos < row.LineText.Length)
			{
				string value;

				// Special handling for quoted field
				if (row.LineText[pos] == '"')
				{
					// Skip initial quote
					pos++;

					// Parse quoted value
					int start = pos;
					while (pos < row.LineText.Length)
					{
						// Test for quote character
						if (row.LineText[pos] == '"')
						{
							// Found one
							pos++;

							// If two quotes together, keep one
							// Otherwise, indicates end of value
							if (pos >= row.LineText.Length || row.LineText[pos] != '"')
							{
								pos--;
								break;
							}
						}
						pos++;
					}
					value = row.LineText.Substring(start, pos - start);
					value = value.Replace("\"\"", "\"");
				}
				else
				{
					// Parse unquoted value
					int start = pos;
					while (pos < row.LineText.Length && row.LineText[pos] != ',')
						pos++;
					value = row.LineText.Substring(start, pos - start);
				}

				// Add field to list
				if (rows < row.Count)
					row[rows] = value;
				else
					row.Add(value);
				rows++;

				// Eat up to and including next comma
				while (pos < row.LineText.Length && row.LineText[pos] != ',')
					pos++;
				if (pos < row.LineText.Length)
					pos++;
			}
			
			// Delete any unused items
			while (row.Count > rows)
				row.RemoveAt(rows);

			// Return true if any columns read
			return (row.Count > 0);
		}
	}*/	
}