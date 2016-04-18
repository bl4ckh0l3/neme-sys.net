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
    // The DoExpressCheckoutPayment API operation completes an Express Checkout transaction.
    public partial class DoExpressCheckoutPayment : System.Web.UI.Page
    {
        public readonly static string BNCode;
        // # Static constructor for configuration setting
        static DoExpressCheckoutPayment()
        {
        // Load the log4net configuration settings from Web.config or App.config
        log4net.Config.XmlConfigurator.Configure();

        //Load values from web.config (configuration file)
        var config = GetConfig();
        BNCode = config["SBN_CODE"];
        }
        
        // Logs output statements, errors, debug info to a text file
        private static ILog logger = LogManager.GetLogger(typeof(DoExpressCheckoutPayment));
        // Create the configuration map that contains mode and other optional configuration details.
        public static Dictionary<string, string> GetConfig()
        {
            return PayPal.Manager.ConfigManager.Instance.GetProperties();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            HttpContext CurrContext = HttpContext.Current;

            // Create the DoExpressCheckoutPaymentResponseType object
            DoExpressCheckoutPaymentResponseType responseDoExpressCheckoutPaymentResponseType = new DoExpressCheckoutPaymentResponseType();
            try
            {
                // Create the DoExpressCheckoutPaymentReq object
                DoExpressCheckoutPaymentReq doExpressCheckoutPayment = new DoExpressCheckoutPaymentReq();
                DoExpressCheckoutPaymentRequestDetailsType doExpressCheckoutPaymentRequestDetails = new DoExpressCheckoutPaymentRequestDetailsType();
                // The timestamped token value that was returned in the
                // `SetExpressCheckout` response and passed in the
                // `GetExpressCheckoutDetails` request.
                doExpressCheckoutPaymentRequestDetails.Token = (string)(Session["EcToken"]);
                // Unique paypal buyer account identification number as returned in
                // `GetExpressCheckoutDetails` Response
                doExpressCheckoutPaymentRequestDetails.PayerID = (string)(Session["PayerId"]);

                // # Payment Information
                // list of information about the payment
                List<PaymentDetailsType> paymentDetailsList = new List<PaymentDetailsType>();
                // information about the payment
                PaymentDetailsType paymentDetails = new PaymentDetailsType();
                CurrencyCodeType currency_code_type = (CurrencyCodeType)(Session["currency_code_type"]);
                PaymentActionCodeType payment_action_type = (PaymentActionCodeType)(Session["payment_action_type"]);
                //Pass the order total amount which was already set in session
                string total_amount = (string)(Session["Total_Amount"]);
                BasicAmountType orderTotal = new BasicAmountType(currency_code_type, total_amount);
                paymentDetails.OrderTotal = orderTotal;
                paymentDetails.PaymentAction = payment_action_type;

                //BN codes to track all transactions
                paymentDetails.ButtonSource = BNCode;

                // Unique identifier for the merchant. 
                SellerDetailsType sellerDetails = new SellerDetailsType();
                sellerDetails.PayPalAccountID = (string)(Session["SellerEmail"]);
                paymentDetails.SellerDetails = sellerDetails;

                paymentDetailsList.Add(paymentDetails);
                doExpressCheckoutPaymentRequestDetails.PaymentDetails = paymentDetailsList;

                DoExpressCheckoutPaymentRequestType doExpressCheckoutPaymentRequest = new DoExpressCheckoutPaymentRequestType(doExpressCheckoutPaymentRequestDetails);
                doExpressCheckoutPayment.DoExpressCheckoutPaymentRequest = doExpressCheckoutPaymentRequest;
                // Create the service wrapper object to make the API call
                PayPalAPIInterfaceServiceService service = new PayPalAPIInterfaceServiceService();
                // # API call
                // Invoke the DoExpressCheckoutPayment method in service wrapper object
                responseDoExpressCheckoutPaymentResponseType = service.DoExpressCheckoutPayment(doExpressCheckoutPayment);
                if (responseDoExpressCheckoutPaymentResponseType != null)
                {

                    // Response envelope acknowledgement
                    string acknowledgement = "DoExpressCheckoutPayment API Operation - ";
                    acknowledgement += responseDoExpressCheckoutPaymentResponseType.Ack.ToString();
                    logger.Info(acknowledgement + "\n");
                    System.Diagnostics.Debug.WriteLine(acknowledgement + "\n");
                    // # Success values
                    if (responseDoExpressCheckoutPaymentResponseType.Ack.ToString().Trim().ToUpper().Equals("SUCCESS"))
                    {
                        // Transaction identification number of the transaction that was
                        // created.
                        // This field is only returned after a successful transaction
                        // for DoExpressCheckout has occurred.
                        if (responseDoExpressCheckoutPaymentResponseType.DoExpressCheckoutPaymentResponseDetails.PaymentInfo != null)
                        {
                            IEnumerator<PaymentInfoType> paymentInfoIterator = responseDoExpressCheckoutPaymentResponseType.DoExpressCheckoutPaymentResponseDetails.PaymentInfo.GetEnumerator();
                            while (paymentInfoIterator.MoveNext())
                            {
                                PaymentInfoType paymentInfo = paymentInfoIterator.Current;
                                logger.Info("Transaction ID : " + paymentInfo.TransactionID + "\n");

                                Session["Transaction_Id"] = paymentInfo.TransactionID;
                                Session["Transaction_Type"] = paymentInfo.TransactionType;
                                Session["Payment_Status"] = paymentInfo.PaymentStatus;
                                Session["Payment_Type"] = paymentInfo.PaymentType;
                                Session["Payment_Total_Amount"] = paymentInfo.GrossAmount.value;
                                
                                System.Diagnostics.Debug.WriteLine("Transaction ID : " + paymentInfo.TransactionID + "\n");
                            }
                        }
                    }
                    // # Error Values
                    else
                    {
                        List<ErrorType> errorMessages = responseDoExpressCheckoutPaymentResponseType.Errors;
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
                // Log the exception message
                logger.Debug("Error Message : " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Error Message : " + ex.Message);
            }
        }
    }
}