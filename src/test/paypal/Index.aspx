<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Index.aspx.cs" %>

<!DOCTYPE HTML>
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
             <img src="img/logo.jpg"/>Checkout with PayPal Demo</h2>
      </div>
      <div class="row-fluid">
   <div class="span5">
            <!--Form containing item parameters and seller credentials needed for SetExpressCheckout Call-->
            <form class="form" runat="server" id="ExpressCheckoutForm" action="SetExpressCheckout.aspx?ExpressCheckoutMethod=ShorcutExpressCheckout">
               <div class="row-fluid">
                  <div class="span6 inner-span">
                        <!--Demo Product details -->
                        <table>
                        <tr><h3>Starbucks Caffe Verona Coffee</h3></tr>
                        <tr><img src="img/starbucks_caffe_verona_coffee.png" width="300" height="250"/></tr>
                        <tr><td><p class="lead"> Buyer Credentials:</p></td></tr>
                        <tr><td>Email-id:&nbsp;&nbsp;&nbsp;<input type="text" id="buyer_email" name="buyer_email" readonly></input> </td></tr>
                        <tr><td>Password:<input type="text" id="buyer_password" name="buyer_password" readonly></input></td></tr>
                        </table>
                  </div>
                  <div class="span6 inner-span">
                        <p class="lead"> Item Specifications:</p>
                        <table>
                        <tr><td>Item Name:</td><td><asp:TextBox runat="server" id="ITEM_NAME" Text="Starbucks Caffe Verona Coffee"/></td></tr>
                        <tr><td>Item ID: </td><td><asp:TextBox runat="server" id="ITEM_ID" Text="51QW9" /></td></tr>
                        <tr><td>Description:</td><td><asp:TextBox runat="server" id="ITEM_DESC" Text="High quality coffee" /></td></tr>
                        <tr><td>Quantity:</td><td><asp:TextBox runat="server" id="ITEM_QUANTITY" Text="1" ReadOnly="true" /></td></tr>
                        <tr><td>Price:</td><td><asp:TextBox runat="server" id="ITEM_AMOUNT" Text="10.00" ReadOnly="true" /></td></tr>
                        <tr><td>Tax:</td><td><asp:TextBox runat="server" id="TAX_AMOUNT" Text="2.00" ReadOnly="true" /></td></tr>
                        <tr><td>Shipping Amount:</td><td><asp:TextBox runat="server" id="SHIPPING_AMOUNT" Text="5.00" ReadOnly="true" /></td></tr>
                        <tr><td>Handling Amount:</td><td><asp:TextBox runat="server" id="HANDLING_AMOUNT" Text="1.00" ReadOnly="true" /></td></tr>
                        <tr><td>Shipping Discount:</td><td><asp:TextBox runat="server" id="SHIPPING_DISCOUNT_AMOUNT" Text="-3.00" ReadOnly="true" /></td></tr>
                        <tr><td>Insurance Amount:</td><td><asp:TextBox runat="server" id="INSURANCE_AMOUNT" Text="2.00" ReadOnly="true" /></td></tr>
                        <tr><td>Total Amount:</td><td><asp:TextBox runat="server" id="TOTAL_AMOUNT" Text="17.00" ReadOnly="true" /></td></tr>
                        <tr><td></td></tr>
                        <tr><td>Currency Code:</td><td>
                            <asp:DropDownList id="CURRENCY_CODE_TYPE" runat="server">
                            <asp:ListItem>AUD</asp:ListItem>
                            <asp:ListItem>BRL</asp:ListItem>
                            <asp:ListItem>CAD</asp:ListItem>
                            <asp:ListItem>CZK</asp:ListItem>
                            <asp:ListItem>DKK</asp:ListItem>
                            <asp:ListItem>EUR</asp:ListItem>
                            <asp:ListItem>HKD</asp:ListItem>
                            <asp:ListItem>MYR</asp:ListItem>
                            <asp:ListItem>MXN</asp:ListItem>
                            <asp:ListItem>NOK</asp:ListItem>
                            <asp:ListItem>NZD</asp:ListItem>
                            <asp:ListItem>PHP</asp:ListItem>
                            <asp:ListItem>PLN</asp:ListItem>
                            <asp:ListItem>GBP</asp:ListItem>
                            <asp:ListItem>RUB</asp:ListItem>
                            <asp:ListItem>SGD</asp:ListItem>
                            <asp:ListItem>SEK</asp:ListItem>
                            <asp:ListItem>CHF</asp:ListItem>
                            <asp:ListItem>THB</asp:ListItem>
                            <asp:ListItem Selected="True">USD</asp:ListItem>
                            </asp:DropDownList>
                            <br></td></tr>
                        <tr><td>Payment Type: </td><td>
                            <asp:DropDownList id="PAYMENT_TYPE" runat="server">
                            <asp:ListItem>Sale</asp:ListItem>
                            <asp:ListItem>Authorization</asp:ListItem>
                            <asp:ListItem>Order</asp:ListItem>
                            </asp:DropDownList>       
                            <br></td></tr>
                        <tr>
                            <td colspan="2">
                                <div id="myContainer"></div>
                            </td>
                        </tr>
						<tr><td> -- OR -- </td></tr>
						<tr><td>
                            <input type="submit" id="mark_ec" class="btn btn-primary btn-large" value="Proceed to Checkout" name="checkout" />
                            </td></tr>
                        </table>
                  </div>
               </div>
            </form>
   </div>
   <div class="span2">
   </div>
  <div class="span5">
      <div class="row-fluid">
         <div class="span12 inner-span">
               <h4> README: </h4>
               <h5>BEFORE YOU GET STARTED:</h5>
               This code sample shows the new checkout flow called In-Context checkout experience. You need to meet the <a href="https://developer.paypal.com/webapps/developer/docs/classic/limited-release/express-checkout/enable/#eligibility-review" target="_blank">eligibility criteria </a> to determine whether your integration will be a good candidate for In-Context checkout experience option. Please refer to the <a href="https://developer.paypal.com/webapps/developer/docs/classic/limited-release/express-checkout/enable/#eligibility-review" target="_blank">eligibility criteria </a>. <br>If you are eligible for In-Context checkout based on the eligibility requirements, please refer to the <a href="#incontext">'In-Context Checkout integration steps'</a> below. But, if you are not eligible, please refer to the <a href="#expresscheckout">'Express Checkout integration steps'</a> below.
               <br>
               <h5> PRE-READ: </h5>
               <p>
                  1) Click on ‘Checkout with PayPal’ button and see the experience.
                  <br>
                  2) If you get any Firewall warning, add rule to the Firewall to allow incoming connections for your application.
                  <br>
                  3) Checkout with PayPal using a buyer sandbox account provided on this page. And you're done!
                  <br>
                  4) The sample code uses default sandbox credentials which are set in web.config. You can create your own credentials by creating PayPal Seller and Buyer accounts on Sandbox  <i><a href="https://developer.paypal.com/webapps/developer/applications/accounts/create" target="_blank">here</a></i>.
                  <br>
                  5) Make following changes in web.config:<br>
                  - If using your own Sandbox seller account, update SellerEmail, apiUsername, apiPassword and apiSignature values with your sandbox credentials<br>
                  <br>
                  </p>
               <h4 id="incontext"> In-Context Checkout integration steps: </h4>
               1) Copy the files and folders under 'ExpressCheckout' package to the same location where you have your shopping cart page.
               <br>
               2) Copy the below  &lt;form&gt; .. &lt;/form&gt; to your shopping cart page.
               <br><br>
   <pre><code>&lt;form id="myContainer" action="SetExpressCheckout.aspx" method="POST"&gt;
      &lt;input type="hidden" name="PAYMENTREQUEST_0_AMT" value="10.00"&gt;&lt;/input&gt;
      &lt;input type="hidden" name="currencyCodeType" value="USD"&gt;&lt;/input&gt;
      &lt;input type="hidden" name="paymentType" value="Sale"&gt;&lt;/input&gt;
      <i>&lt;!--Pass additional input parameters based on your shopping cart. For complete list of all the parameters <a href="https://developer.paypal.com/webapps/developer/docs/classic/api/merchant/SetExpressCheckout_API_Operation_NVP/" target=_blank>click here</a></i> --&gt;
&lt;/form&gt;</code></pre><br>
               3) Include the following script on your shopping cart page:
               <br><br>
   <pre><code>&lt;script type="text/javascript"&gt;
 window.paypalCheckoutReady = function () {
     paypal.checkout.setup('Your merchant email id', {
         container: 'myContainer', //{String|HTMLElement|Array} where you want the PayPal button to reside
         environment: 'sandbox' //or 'production' depending on your environment
     });
 };
 &lt;/script&gt;
 &lt;script src="//www.paypalobjects.com/api/checkout.js" async&gt;&lt;/script&gt;</code></pre><br>
               4) Open your browser and navigate to your Shopping cart page. Click on 'Checkout with PayPal' button and complete the flow.<br>
               5) Read more details on Express Checkout API <a href="https://developer.paypal.com/webapps/developer/docs/classic/products/#ec" target=_blank>here</a>
             <br><br>
             <h4 id="expresscheckout"> Express Checkout integration steps: </h4>
            1) Copy the files and folders under 'Checkout' package to the same location where you have your shopping cart page.
                           <br>
            2) Copy the below  &lt;form&gt; .. &lt;/form&gt; to your shopping cart page.
                           <br><br>
   <pre><code>&lt;form action="SetExpressCheckout.aspx" method="POST"&gt;
  &lt;input type="hidden" name="PAYMENTREQUEST_0_AMT" value="10.00"&gt;&lt;/input&gt;
  &lt;input type="hidden" name="currencyCodeType" value="USD"&gt;&lt;/input&gt;
  &lt;input type="hidden" name="paymentType" value="Sale"&gt;&lt;/input&gt;
  <i>&lt;!--Pass additional input parameters based on your shopping cart. For complete list of all the parameters <a href="https://developer.paypal.com/webapps/developer/docs/classic/api/merchant/SetExpressCheckout_API_Operation_NVP/" target=_blank>click here</a></i> --&gt;
  &lt;input type="image" src="https://www.paypalobjects.com/webstatic/en_US/i/buttons/checkout-logo-large.png" alt="Check out with PayPal"&gt;&lt;/input&gt;
&lt;/form&gt;</code></pre>
            3) In web.config, uncomment the Express Checkout 'RedirectUrl'  URLs for Sandbox and comment out the In-Context Express Checkout 'RedirectUrl' for Sandbox.
            Do the same for the 'Live' URLs.<br>
            4) Open your browser and navigate to your Shopping cart page. Click on 'Checkout with PayPal' button and complete the flow.<br>
            5) Read more details on Express Checkout API <a href="https://developer.paypal.com/webapps/developer/docs/classic/products/#ec" target=_blank>here</a>

         </div>
      </div>
   </div>
   <div class="span1">
   </div>
   <!--Script to dynamically choose a seller and buyer account to render on index page-->
   <script type="text/javascript">
       function getRandomNumberInRange(min, max) {
           return Math.floor(Math.random() * (max - min) + min);
       }


       var buyerCredentials = [{ "email": "ron@hogwarts.com", "password": "qwer1234" },
                         { "email": "sallyjones1234@gmail.com", "password": "p@ssword1234" },
                         { "email": "joe@boe.com", "password": "123456789" },
                         { "email": "hermione@hogwarts.com", "password": "123456789" },
                         { "email": "lunalovegood@hogwarts.com", "password": "123456789" },
                         { "email": "ginnyweasley@hogwarts.com", "password": "123456789" },
                         { "email": "bellaswan@awesome.com", "password": "qwer1234" },
                         { "email": "edwardcullen@gmail.com", "password": "qwer1234" }];
       var randomBuyer = getRandomNumberInRange(0, buyerCredentials.length);

       document.getElementById("buyer_email").value = buyerCredentials[randomBuyer].email;
       document.getElementById("buyer_password").value = buyerCredentials[randomBuyer].password;


   </script>    
          			</div> <!-- Row-Fluid ends here -->
		</div>  <!--Container-Fluid ends here -->
		<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
		<script src="https://code.jquery.com/jquery.js"></script>
		<!-- Include all compiled plugins (below), or include individual files as needed -->
		<script src="js/bootstrap.min.js"></script>
        
   <script type="text/javascript">
       window.paypalCheckoutReady = function () {
           paypal.checkout.setup('supersandy@gmail.com', {
               container: 'myContainer',
               environment: 'sandbox'
           });
       }
   </script>
      <script src="//www.paypalobjects.com/api/checkout.js" async></script>
      <script type="text/javascript">
          $(document).ready(function () {
              $("#mark_ec").click(function (event) {
                  event.preventDefault();
                  var item_name = $("#<%= ITEM_NAME.ClientID %>").val();
                  var item_id = $("#<%= ITEM_ID.ClientID %>").val();
                  var item_desc = $("#<%= ITEM_DESC.ClientID %>").val();
                  var item_quantity = $("#<%= ITEM_QUANTITY.ClientID %>").val();
                  var item_amount = $("#<%= ITEM_AMOUNT.ClientID %>").val();
                  var tax_amount = $("#<%= TAX_AMOUNT.ClientID %>").val();
                  var shipping_amount = $("#<%= SHIPPING_AMOUNT.ClientID %>").val();
                  var handling_amount = $("#<%= HANDLING_AMOUNT.ClientID %>").val();
                  var shipping_discount_amount = $("#<%= SHIPPING_DISCOUNT_AMOUNT.ClientID %>").val();
                  var insurance_amount = $("#<%= INSURANCE_AMOUNT.ClientID %>").val();
                  var total_amount = $("#<%= TOTAL_AMOUNT.ClientID %>").val();
                  var currency_code = $("#<%= CURRENCY_CODE_TYPE.ClientID %>").val();
                  var payment_type = $("#<%= PAYMENT_TYPE.ClientID %>").val();
                  window.location.replace("MarkExpressCheckout.aspx?item_name=" + item_name
                                                    + "&item_id=" + item_id
                                                    + "&item_desc=" + item_desc
                                                    + "&item_quantity=" + item_quantity
                                                    + "&item_amount=" + item_amount
                                                    + "&tax_amount=" + tax_amount
                                                    + "&shipping_amount=" + shipping_amount
                                                    + "&handling_amount=" + handling_amount
                                                    + "&shipping_discount_amount=" + shipping_discount_amount
                                                    + "&insurance_amount=" + insurance_amount
                                                    + "&total_amount=" + total_amount
                                                    + "&currency_code=" + currency_code
                                                    + "&payment_type=" + payment_type);
                   });
          });
          </script>
	</body>                       