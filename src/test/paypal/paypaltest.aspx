<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>

<%
Session["payment_amt"] = "12.00";
string PaymentOption="PayPal";

string retMsg = "";
string token = "";
string finalPaymentAmount = "";
string payerId = "";
string shippingAddress = "";

Response.Write("Request.Url: "+Request.Url+"<br><br>");

UriBuilder orderMailBuilder = new UriBuilder(Request.Url);
//orderMailBuilder.Scheme = "http";
orderMailBuilder.Port = -1;
orderMailBuilder.Path="";
orderMailBuilder.Query="";

Response.Write("UriBuilder: "+orderMailBuilder.ToString()+"<br><br>");


if (PaymentOption == "PayPal" && !String.IsNullOrEmpty(Request["token"]))
{
    NVPAPICaller test = new NVPAPICaller();

    token = Request["token"];

    bool ret = test.GetShippingDetails( token, ref payerId, ref shippingAddress, ref retMsg );
    if (ret)
    {
        Session["payerId"] = payerId;
        Response.Write ( shippingAddress );  
        
        Response.Write ("<br><br>ORDER ID: "+ retMsg +"<br><br>");  
        
    }
    else
    {
        Response.Redirect("APIError.aspx?" + retMsg);
    }
}

if (PaymentOption == "PayPal" && !String.IsNullOrEmpty(Request["token"]))
{
    NVPAPICaller test = new NVPAPICaller();

    NVPCodec decoder = new NVPCodec();

    token = Request["token"];
    payerId = Request["PayerID"];
    finalPaymentAmount = Session["payment_amt"].ToString();

    bool ret = test.ConfirmPayment( finalPaymentAmount, token, payerId, ref decoder, ref retMsg );
    if (ret)
    {
		// Unique transaction ID of the payment. Note:  If the PaymentAction of the request was Authorization or Order, this value is your AuthorizationID for use with the Authorization & Capture APIs. 
        string transactionId	= decoder["PAYMENTINFO_0_TRANSACTIONID"]; 

        // The type of transaction Possible values: l  cart l  express-checkout 
		string transactionType = decoder["PAYMENTINFO_0_TRANSACTIONTYPE"]; 

        // Indicates whether the payment is instant or delayed. Possible values: l  none l  echeck l  instant 
		string paymentType		= decoder["PAYMENTINFO_0_PAYMENTTYPE"]; 

        // Time/date stamp of payment
		string orderTime 		= decoder["PAYMENTINFO_0_ORDERTIME"]; 

        // The final amount charged, including any shipping and taxes from your Merchant Profile.
		string amt				= decoder["PAYMENTINFO_0_AMT"];

        // A three-character currency code for one of the currencies listed in PayPay-Supported Transactional Currencies. Default: USD.    
		string currencyCode	= decoder["PAYMENTINFO_0_CURRENCYCODE"];
 
        // PayPal fee amount charged for the transaction    
		string feeAmt			= decoder["PAYMENTINFO_0_FEEAMT"]; 

        // Amount deposited in your PayPal account after a currency conversion.    
		string settleAmt		= decoder["PAYMENTINFO_0_SETTLEAMT"]; 

        // Tax charged on the transaction.    
		string taxAmt			= decoder["PAYMENTINFO_0_TAXAMT"];

        //' Exchange rate if a currency conversion occurred. Relevant only if your are billing in their non-primary currency. If 
		string exchangeRate	= decoder["PAYMENTINFO_0_EXCHANGERATE"];
		
		
		
		Response.Write("QUERY parameters: "+Request.Url.Query+"<BR><BR>");
		
		foreach (string key in Request.Form.AllKeys)
		{
			Response.Write("key:"+key+" - value: "+Request.Form[key]+"<BR>");
		}		
    }
    else
    {
        Response.Redirect("APIError.aspx?" + retMsg);
    }
}
%>
<!DOCTYPE HTML>
<head>

  </head>
  <body>
<form action='expresscheckout.aspx' METHOD='POST'>
<input type='image' name='submit' src='https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif' border='0' align='top' alt='Check out with PayPal'/>
</form>
	</body> 
	</html>