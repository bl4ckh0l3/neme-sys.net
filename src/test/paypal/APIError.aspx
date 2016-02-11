<%@ Page Language="c#" AutoEventWireup="false" CodeFile="APIError.aspx.cs" Inherits="APIError" %>
<HTML>
	<HEAD>
		<title>PayPal - Error Page</title>
	</HEAD>
	<body>
		
		<TABLE class="api" id="Table1">
			<TR>
				<TD class="field"></TD>
				<TD><%=Request.QueryString.Get("ErrorCode")%></TD>
			</TR>
			
			<TR>
				<TD class="field"></TD>
				<TD><%=Request.QueryString.Get("Desc")%></TD>
			</TR>
			
			<TR>
				<TD class="field"></TD>
				<TD><%=Request.QueryString.Get("Desc2")%></TD>
			</TR>

		</TABLE>
	</body>
</HTML>
