<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GetExpressCheckoutDetails.aspx.cs" %>
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
         <h2 class="text-center">Checkout with PayPal Demo</h2>
      </div>
      <div class="row-fluid">
          <div class="span4">
             
	</div>
          <form runat="server" id="GetExpressCheckoutDetailsForm">
	<div class="span5">
         <h3>Order Confirmation</h3><br />
        <h4><u>Shipping Information</u></h4><br />
		<table border="1" style=""width:100%;">			
				<tr>
                    <th style="width:45%;">Billing & Delivery Address</th>
                    <th style="width:40%;">                      
                        Products
                    </th>
                    <th>                      
                        Sub-Total
                    </th>
                </tr>
            <tr><td>
                    <%=Session["Address_Name"]%> <br />
                
                    <%=Session["Address_Street"]%> <br />
                
                    <%=Session["Address_CityName"]%> <br />
                
                    <%=Session["Address_StateOrProvince"]%> <br />
                
                    <%=Session["Address_CountryName"]%> <br />
               
                    <%=Session["Address_PostalCode"]%>
                </td>
                <td>
                    <%=Session["Product_Quantity"]%> X  <%=Session["Product_Name"]%>
                </td>
                <td style="text-align: center;">
                    $<%=Session["Order_Total"]%> 
                </td>
            </tr>
            </table>
        <br />
        <table>
            <tr>
                <td><h4>Shipping Method</h4></td>
           
                <td>
                      <select name="shipping_method" ID="shipping_method" class="shipping_method" style="margin-left: 20px; margin-top: 10px; width: 250px;">
                        <option value="5">Select shipping method</option>
						<optgroup label="United Parcel Service" style="font-style:normal;">
						<option value="2">
						Worldwide Expedited - $2.00</option>
						<option value="3">
						Worldwide Express Saver - $3.00</option>
						</optgroup>
						<optgroup label="Flat Rate" style="font-style:normal;">
						<option value="5" selected>
						Flat Rate Fixed - $0.00</option>
						</optgroup>
                        </select>
                </td>
            </tr>
        </table>
        <br /><br />
              
         <asp:Button runat="server"  ID="pay_now_button" OnClick="callDoExpressCheckout" class="btn btn-primary btn-large" style="margin-left: 380px;" />     
           </form>
	
	</div>
	<div class="span3">
	</div>
			</div> <!-- Row-Fluid ends here -->
		 <!--Container-Fluid ends here -->
		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://code.jquery.com/jquery.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="js/bootstrap.min.js"></script>
	</body>
</html>

<script type="text/javascript">
    $(document).ready(function () {
        $("#pay_now_button").attr('value', 'Pay Now ($<%=Session["Order_Total"]%>)');
    });
    $(".shipping_method").change(function () {
        var value = $(this).val();
        var total = parseInt(<%=Session["Order_Total"]%>) - parseInt(<%=Session["Shipping_Total"]%>) + parseInt(value);
        $("#pay_now_button").attr('value', 'Pay Now ($'+total+'.00)');
    });
</script>