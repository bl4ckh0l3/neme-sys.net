<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Response.aspx.cs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
		  <meta charset="utf-8" />
		  <meta name="viewport" content="width=device-width, initial-scale=1">
		  <title>PayPal Demo Portal</title>
		  <!--Including Bootstrap style files-->
		  <link href="css/bootstrap.min.css" rel="stylesheet">
		  <link href="css/bootstrap-responsive.min.css" rel="stylesheet">
	  </head>
<body>
    <div class="container-fluid">
		  <div class="well">
			 <h2 class="text-center"> <img src="img/logo.jpg"/>Checkout with PayPal Demo</h2>
		  </div>
		  <div class="row-fluid">
    <form id="ErrorForm" runat="server">
        <h4 class="text-center">Sorry! An unexpected error occured.</h4>
    <table class="text-center" style="border-collapse: collapse" align="center" cellspacing="5" width="85%">
            <tr>
                <td>
                    <b><u>API Error Message:</u></b> <asp:Label ID="apierror" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <br />
                    <a href="Index.aspx">Back</a>
                </td>
            </tr>
        </table>
    </form>
              </div>
        </div>
</body>
</html>
