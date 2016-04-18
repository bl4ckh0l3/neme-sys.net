<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DoExpressCheckoutPayment.aspx.cs" %>
<!DOCTYPE html>
<html>
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
         <h2 class="text-center">
             <img src="img/logo.jpg">Checkout with PayPal Demo</h2>
      </div>
      <div class="row-fluid">
          <span class="span4">
    		</span>
    		<span class="span5">
    			<div class="hero-unit">
                
                    <!-- Display the Transaction Details-->
                     <h3>Your Order Has Been Processed!</h3>
                    <h5> Thanks for shopping with us online! Please find the details below.</h5>
                    <h4><u>Shipping Details</u></h4>
                     <%=Session["Address_Name"]%> <br />
                
                    <%=Session["Address_Street"]%> <br />
                
                    <%=Session["Address_CityName"]%> <br />
                
                    <%=Session["Address_StateOrProvince"]%> <br />
                
                    <%=Session["Address_CountryName"]%> <br />
               
                    <%=Session["Address_PostalCode"]%>
                    <h4><u>Transaction Details</u></h4>
                    <table border="1">
                        <tr>
                            <td>
                                Transaction ID:
                            </td>
                            <td>
                                 <%=Session["Transaction_Id"]%><br />
                            </td>
                           </tr>
                        <tr> 
                            <td>
                                Transaction Type:
                            </td>
                            <td>
                                 <%=Session["Transaction_Type"]%>
                            </td>
                           </tr>
                        <tr>  
                            <td>
                                Payment Total Amount:
                            </td>
                            <td>
                                 <%=Session["Payment_Total_Amount"]%>
                            </td>
                            </tr>
                        <tr> 
                            <td>
                                Currency Code:
                            </td>
                            <td>
                                 <%=Session["Currency_Code"]%>
                            </td>
                            </tr>
                        <tr> 
                            <td>
                                Payment Status:
                            </td>
                            <td>
                                  <%=Session["Payment_Status"]%>
                            </td>
                            </tr>
                        <tr> 
                            <td>
                                Payment Type:
                            </td>
                            <td>
                                  <%=Session["Payment_Type"]%>
                            </td>
                        </tr>
                    </table>
                <br />
          <h4> Click <a href='Index.aspx'>here </a> to return to Home Page</h4>
                    </div>
                </span>
                    
    		
    		<span class="span3">
    		</span>
          	 <!-- Row-Fluid ends here -->
		</div> 
          </div> <!--Container-Fluid ends here -->
		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://code.jquery.com/jquery.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="js/bootstrap.min.js"></script>
	</body>
</html>