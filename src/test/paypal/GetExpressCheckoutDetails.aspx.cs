using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PayPal.PayPalAPIInterfaceService;
using PayPal.PayPalAPIInterfaceService.Model;
using log4net;

namespace ExpressCheckout
{
    // The GetExpressCheckoutDetails API operation obtains information about an Express Checkout transaction
    public partial class GetExpressCheckoutDetails : System.Web.UI.Page
    {
        static GetExpressCheckoutDetails()
        {
        // Load the log4net configuration settings from Web.config or App.config
        log4net.Config.XmlConfigurator.Configure();
        }

        // Logs output statements, errors, debug info to a text file
        private static ILog logger = LogManager.GetLogger(typeof(GetExpressCheckoutDetails));

        protected void Page_Load(object sender, EventArgs e)
        {
            HttpContext CurrContext = HttpContext.Current;
           
            // Create the GetExpressCheckoutDetailsResponseType object
            GetExpressCheckoutDetailsResponseType responseGetExpressCheckoutDetailsResponseType = new GetExpressCheckoutDetailsResponseType();
            try
            {
                // Create the GetExpressCheckoutDetailsReq object
                GetExpressCheckoutDetailsReq getExpressCheckoutDetails = new GetExpressCheckoutDetailsReq();
                // A timestamped token, the value of which was returned by `SetExpressCheckout` API response
                string EcToken = (string)(Session["EcToken"]);
                GetExpressCheckoutDetailsRequestType getExpressCheckoutDetailsRequest = new GetExpressCheckoutDetailsRequestType(EcToken);
                getExpressCheckoutDetails.GetExpressCheckoutDetailsRequest = getExpressCheckoutDetailsRequest;
                // Create the service wrapper object to make the API call
                PayPalAPIInterfaceServiceService service = new PayPalAPIInterfaceServiceService();
                // # API call
                // Invoke the GetExpressCheckoutDetails method in service wrapper object
                responseGetExpressCheckoutDetailsResponseType = service.GetExpressCheckoutDetails(getExpressCheckoutDetails);
                if (responseGetExpressCheckoutDetailsResponseType != null)
                {
                    // Response envelope acknowledgement
                    string acknowledgement = "GetExpressCheckoutDetails API Operation - ";
                    acknowledgement += responseGetExpressCheckoutDetailsResponseType.Ack.ToString();
                    logger.Info(acknowledgement + "\n");
                    System.Diagnostics.Debug.WriteLine(acknowledgement + "\n");
                    // # Success values
                    if (responseGetExpressCheckoutDetailsResponseType.Ack.ToString().Trim().ToUpper().Equals("SUCCESS"))
                    {
                        // Unique PayPal Customer Account identification number. This
                        // value will be null unless you authorize the payment by
                        // redirecting to PayPal after `SetExpressCheckout` call.
                        string PayerId = responseGetExpressCheckoutDetailsResponseType.GetExpressCheckoutDetailsResponseDetails.PayerInfo.PayerID;
                        // Store PayerId in session to be used in DoExpressCheckout API operation
                        Session["PayerId"] = PayerId;
                       
                        List<PaymentDetailsType> paymentDetails = responseGetExpressCheckoutDetailsResponseType.GetExpressCheckoutDetailsResponseDetails.PaymentDetails;
                        foreach(PaymentDetailsType paymentdetail in paymentDetails)
                        {
                            AddressType ShippingAddress = paymentdetail.ShipToAddress;
                            if (ShippingAddress != null)
                            {
                                Session["Address_Name"] = ShippingAddress.Name;
                                Session["Address_Street"] = ShippingAddress.Street1 + " "+ ShippingAddress.Street2 ;
                                Session["Address_CityName"] = ShippingAddress.CityName;
                                Session["Address_StateOrProvince"] = ShippingAddress.StateOrProvince;
                                Session["Address_CountryName"] = ShippingAddress.CountryName;
                                Session["Address_PostalCode"] = ShippingAddress.PostalCode;
                            }
                            Session["Currency_Code"] = paymentdetail.OrderTotal.currencyID;
                            Session["Order_Total"] = paymentdetail.OrderTotal.value;
                            Session["Shipping_Total"] = paymentdetail.ShippingTotal.value;
                            List<PaymentDetailsItemType> itemList = paymentdetail.PaymentDetailsItem;
                            foreach (PaymentDetailsItemType item in itemList)
                            {
                                Session["Product_Quantity"] = item.Quantity;
                                Session["Product_Name"] = item.Name;
                                
                            }
                        }
                    }
                    // # Error Values
                    else
                    {
                        List<ErrorType> errorMessages = responseGetExpressCheckoutDetailsResponseType.Errors;
                        string errorMessage = "";
                        foreach (ErrorType error in errorMessages)
                        {
                            logger.Debug("API Error Message : " + error.LongMessage);
                            System.Diagnostics.Debug.WriteLine("API Error Message : " + error.LongMessage + "\n");
                            errorMessage = errorMessage + error.LongMessage;                           
                        }
                        //Redirect to error page in case of any API errors
                        CurrContext.Items.Add("APIErrorMessage", errorMessage);
                        Server.Transfer("~/Response.aspx");
                    }
                }
                //Redirect to DoExpressCheckoutPayment.aspx page if the method chosen is MarkExpressCheckout
                //The buyer need not review the shipping address and shipping method as it's already provided
                string ecMethod = (string)(Session["ExpressCheckoutMethod"]);
                if (ecMethod.Equals("MarkExpressCheckout"))
                {
                    Response.Redirect("DoExpressCheckoutPayment.aspx");
                }

            }
            // # Exception log
            catch (System.Exception ex)
            {
                // Log the exception message
                logger.Debug("Error Message : " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Error Message : " + ex.Message);
            }

        }

        // After reviewing the shipping address and selecting the shipping method, 
        // redirect to make DoExpressCheckout API operation
        protected void callDoExpressCheckout(object sender, EventArgs e)
        {
            //Get shippping rate
            // Calculate new order total based on shipping method selected
            string shipping_rate = Request.Form["shipping_method"].ToString();
            string total_amount = (string)(Session["Order_Total"]);
            string shipping_amount = (string)(Session["Shipping_Total"]);
            Double total_rate = Convert.ToDouble(total_amount);
            Double old_shipping_rate = Convert.ToDouble(shipping_amount);
            Double new_shipping_rate = Convert.ToDouble(shipping_rate);
            Double new_total_rate = total_rate - old_shipping_rate + new_shipping_rate;
            Session["Total_Amount"] = new_total_rate.ToString();
            Response.Redirect("DoExpressCheckoutPayment.aspx");
        }
    }
}