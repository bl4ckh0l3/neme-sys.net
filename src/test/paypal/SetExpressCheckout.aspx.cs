using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PayPal.PayPalAPIInterfaceService;
using PayPal.PayPalAPIInterfaceService.Model;
using log4net;

// The SetExpressCheckout API operation initiates an Express Checkout transaction.
namespace ExpressCheckout
{
    public partial class SetExpressCheckout : System.Web.UI.Page
    {
        public readonly static string ReturnUrl;
        public readonly static string CancelUrl;
        public readonly static string LogoUrl;
        public readonly static string SellerEmail;
        public readonly static string RedirectUrl;

        static SetExpressCheckout()
        {
        // Load the log4net configuration settings from Web.config or App.config
        log4net.Config.XmlConfigurator.Configure();

        //Load values from web.config (configuration file)
        var config = GetConfig();
        ReturnUrl = config["ReturnUrl"];
        CancelUrl = config["CancelUrl"];
        LogoUrl = config["LogoUrl"];
        SellerEmail = config["SellerEmail"];
        RedirectUrl = config["RedirectUrl"];
        }

        // Logs output statements, errors, debug info to a text file
        private static ILog logger = LogManager.GetLogger(typeof(SetExpressCheckout));

        // Create the configuration map that contains mode and other optional configuration details.
        public static Dictionary<string, string> GetConfig()
        {
            return PayPal.Manager.ConfigManager.Instance.GetProperties();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            HttpContext CurrContext = HttpContext.Current;
            
            // Create the SetExpressCheckoutResponseType object
            SetExpressCheckoutResponseType responseSetExpressCheckoutResponseType = new SetExpressCheckoutResponseType();
            try
            {
                // Check if the EC methos is shorcut or mark
                string ecMethod = "";
                if (Request.QueryString["ExpressCheckoutMethod"] != null)
                {
                    ecMethod = Request.QueryString["ExpressCheckoutMethod"];
                }
                else if ((string)(Session["ExpressCheckoutMethod"]) !=null)
                {
                    ecMethod = (string)(Session["ExpressCheckoutMethod"]);
                }
                string item_name = "";
                string item_id = "";
                string item_desc = "";
                string item_quantity = "";
                string item_amount = "";
                string tax_amount = "";
                string shipping_amount = "";
                string handling_amount = "";
                string shipping_discount_amount = "";
                string insurance_amount = "";
                string total_amount = "";
                string currency_code = "";
                string payment_type = "";

                // From Marck EC Page
                string shipping_rate = "";
                string first_name = "";
                string last_name = "";
                string street1 = "";
                string street2 = "";
                string city = "";
                string state = "";
                string postal_code = "";
                string country = "";
                string phone = "";
                Double new_total_rate = 0.00;
                AddressType shipToAddress = new AddressType();
                if (ecMethod != null && ecMethod == "ShorcutExpressCheckout")
                {
                    // Get parameters from index page (shorcut express checkout)
                    item_name = Request.Form["item_name"];
                    item_id = Request.Form["item_id"];
                    item_desc = Request.Form["item_desc"];
                    item_quantity = Request.Form["item_quantity"];
                    item_amount = Request.Form["item_amount"];
                    tax_amount = Request.Form["tax_amount"];
                    shipping_amount = Request.Form["shipping_amount"];
                    handling_amount = Request.Form["handling_amount"];
                    shipping_discount_amount = Request.Form["shipping_discount_amount"];
                    insurance_amount = Request.Form["insurance_amount"];
                    total_amount = Request.Form["total_amount"];
                    currency_code = Request.Form["currency_code_type"];
                    payment_type = Request.Form["payment_type"];
                    Session["Total_Amount"] = total_amount;
                }
                else if (ecMethod != null && ecMethod == "MarkExpressCheckout")
                {
                    // Get parameters from mark ec page 
                    shipping_rate = Request.Form["shipping_method"].ToString();

                    item_name = Request.Form["item_name"];
                    item_id = Request.Form["item_id"];
                    item_desc = Request.Form["item_desc"];
                    item_quantity = Request.Form["item_quantity"];
                    item_amount = Request.Form["item_amount"];
                    tax_amount = Request.Form["tax_amount"];
                    shipping_amount = Request.Form["shipping_amount"];
                    handling_amount = Request.Form["handling_amount"];
                    shipping_discount_amount = Request.Form["shipping_discount_amount"];
                    insurance_amount = Request.Form["insurance_amount"];
                    total_amount = Request.Form["total_amount"];
                    currency_code = Request.Form["currency_code"];
                    payment_type = Request.Form["payment_type"];

                    first_name = Request.Form["FIRST_NAME"];
                    last_name = Request.Form["LAST_NAME"];
                    street1 = Request.Form["STREET_1"];
                    street2 = Request.Form["STREET_2"];
                    city = Request.Form["CITY"];
                    state = Request.Form["STATE"];
                    postal_code = Request.Form["POSTAL_CODE"];
                    country = Request.Form["COUNTRY"];
                    phone = Request.Form["PHONE"];

                    // Set the details of new shipping address                  
                    shipToAddress.Name = first_name + " " + last_name;
                    shipToAddress.Street1 = street1;
                    if (!street2.Equals(""))
                    {
                        shipToAddress.Street2 = street2;
                    }
                    shipToAddress.CityName = city;
                    shipToAddress.StateOrProvince = state;
                    string countrycode = country;
                    CountryCodeType countryCodeType = (CountryCodeType)Enum.Parse(typeof(CountryCodeType), countrycode, true);
                    shipToAddress.Country = countryCodeType;
                    shipToAddress.PostalCode = postal_code;
                    if (!phone.Equals(""))
                    {
                        shipToAddress.Phone = phone;
                    }
                    
                     Double total_rate = Convert.ToDouble(total_amount);
                     Double old_shipping_rate = Convert.ToDouble(shipping_amount);
                     Double new_shipping_rate = Convert.ToDouble(shipping_rate);

                     // Calculate new order total based on shipping method selected
                     new_total_rate = total_rate - old_shipping_rate + new_shipping_rate;
                     Session["Total_Amount"] = new_total_rate.ToString();
                     total_amount = new_total_rate.ToString();
                     shipping_amount = new_shipping_rate.ToString();
                }
             
                Session["SellerEmail"] = SellerEmail; 
                CurrencyCodeType currencyCode_Type = (CurrencyCodeType)Enum.Parse(typeof(CurrencyCodeType), currency_code, true);
                Session["currency_code_type"] = currencyCode_Type;
                PaymentActionCodeType payment_ActionCode_Type = (PaymentActionCodeType)Enum.Parse(typeof(PaymentActionCodeType), payment_type, true);
                Session["payment_action_type"] = payment_ActionCode_Type;
                // SetExpressCheckoutRequestDetailsType object
                SetExpressCheckoutRequestDetailsType setExpressCheckoutRequestDetails = new SetExpressCheckoutRequestDetailsType();
                // (Required) URL to which the buyer's browser is returned after choosing to pay with PayPal.
                setExpressCheckoutRequestDetails.ReturnURL = ReturnUrl;
                //(Required) URL to which the buyer is returned if the buyer does not approve the use of PayPal to pay you
                setExpressCheckoutRequestDetails.CancelURL = CancelUrl;
                // A URL to your logo image. Use a valid graphics format, such as .gif, .jpg, or .png
                setExpressCheckoutRequestDetails.cppLogoImage = LogoUrl;
                // To display the border in your principal identifying color, set the "cppCartBorderColor" parameter to the 6-digit hexadecimal value of that color
               // setExpressCheckoutRequestDetails.cppCartBorderColor = "0000CD";

               Response.Write("ReturnUrl: "+ReturnUrl);
               
                //Item details
                PaymentDetailsItemType itemDetails = new PaymentDetailsItemType();
                itemDetails.Name = item_name;
                itemDetails.Amount = new BasicAmountType(currencyCode_Type, item_amount);
                itemDetails.Quantity = Convert.ToInt32(item_quantity);
                itemDetails.Description = item_desc;
                itemDetails.Number = item_id;

                //Add more items if necessary by using the class 'PaymentDetailsItemType'

                // Payment Information
                List<PaymentDetailsType> paymentDetailsList = new List<PaymentDetailsType>();

                PaymentDetailsType paymentDetails = new PaymentDetailsType();
                paymentDetails.PaymentAction = payment_ActionCode_Type;
                paymentDetails.ItemTotal = new BasicAmountType(currencyCode_Type, item_amount);//item amount
                paymentDetails.TaxTotal = new BasicAmountType(currencyCode_Type, tax_amount); //tax amount;
                paymentDetails.ShippingTotal = new BasicAmountType(currencyCode_Type, shipping_amount); //shipping amount
                paymentDetails.HandlingTotal = new BasicAmountType(currencyCode_Type, handling_amount); //handling amount
                paymentDetails.ShippingDiscount = new BasicAmountType(currencyCode_Type, shipping_discount_amount); //shipping discount
                paymentDetails.InsuranceTotal = new BasicAmountType(currencyCode_Type, insurance_amount); //insurance amount
                paymentDetails.OrderTotal = new BasicAmountType(currencyCode_Type, total_amount); // order total amount
               
                paymentDetails.PaymentDetailsItem.Add(itemDetails);

                // Unique identifier for the merchant. 
                SellerDetailsType sellerDetails = new SellerDetailsType();
                sellerDetails.PayPalAccountID = SellerEmail;
                paymentDetails.SellerDetails = sellerDetails;

                if (ecMethod != null && ecMethod == "MarkExpressCheckout")
                {
                    paymentDetails.ShipToAddress = shipToAddress;
                }
                paymentDetailsList.Add(paymentDetails);
                setExpressCheckoutRequestDetails.PaymentDetails = paymentDetailsList;

                // Collect Shipping details if MARK express checkout
 
                SetExpressCheckoutReq setExpressCheckout = new SetExpressCheckoutReq();
                SetExpressCheckoutRequestType setExpressCheckoutRequest = new SetExpressCheckoutRequestType(setExpressCheckoutRequestDetails);
                setExpressCheckout.SetExpressCheckoutRequest = setExpressCheckoutRequest;

                // Create the service wrapper object to make the API call
                PayPalAPIInterfaceServiceService service = new PayPalAPIInterfaceServiceService();

                // API call
                // Invoke the SetExpressCheckout method in service wrapper object
                responseSetExpressCheckoutResponseType = service.SetExpressCheckout(setExpressCheckout);

                if (responseSetExpressCheckoutResponseType != null)
                {
                    // Response envelope acknowledgement
                    string acknowledgement = "SetExpressCheckout API Operation - ";
                    acknowledgement += responseSetExpressCheckoutResponseType.Ack.ToString();
                    logger.Debug(acknowledgement + "\n");
                    System.Diagnostics.Debug.WriteLine(acknowledgement + "\n");
                    // # Success values
                    if (responseSetExpressCheckoutResponseType.Ack.ToString().Trim().ToUpper().Equals("SUCCESS"))
                    {
                        // # Redirecting to PayPal for authorization
                        // Once you get the "Success" response, needs to authorise the
                        // transaction by making buyer to login into PayPal. For that,
                        // need to construct redirect url using EC token from response.
                        // Express Checkout Token
                        string EcToken = responseSetExpressCheckoutResponseType.Token;
                        logger.Info("Express Checkout Token : " + EcToken + "\n");
                        System.Diagnostics.Debug.WriteLine("Express Checkout Token : " + EcToken + "\n");
                        // Store the express checkout token in session to be used in GetExpressCheckoutDetails & DoExpressCheckout API operations
                        Session["EcToken"] = EcToken;
                        Response.Redirect(RedirectUrl + HttpUtility.UrlEncode(EcToken), false);
                       // Server.Execute(RedirectUrl + EcToken);
                    }
                    // # Error Values
                    else
                    {
                        List<ErrorType> errorMessages = responseSetExpressCheckoutResponseType.Errors;
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
            }
            catch (System.Exception ex)
            {
            	Response.Write(ex.Message);
                // Log the exception message
                logger.Debug("Error Message : " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Error Message : " + ex.Message);
            }
         }
    }
}