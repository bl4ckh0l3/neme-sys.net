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
    public partial class MarkExpressCheckout : System.Web.UI.Page
    {
       
        protected void Page_Load(object sender, EventArgs e)
        {
            Session["ExpressCheckoutMethod"] = "MarkExpressCheckout";

            //Get the query string parameters
            string item_name = Request.QueryString["item_name"];
            ITEM_NAME.Value = item_name;
            string item_id = Request.QueryString["item_id"];
            ITEM_ID.Value = item_id;
            string item_desc = Request.QueryString["item_desc"];
            ITEM_DESC.Value = item_desc;
            string item_quantity = Request.QueryString["item_quantity"];
            ITEM_QUANTITY.Value = item_quantity;
            string item_amount = Request.QueryString["item_amount"];
            ITEM_AMOUNT.Value = item_amount;
            string tax_amount = Request.QueryString["tax_amount"];
            TAX_AMOUNT.Value = tax_amount;
            string shipping_amount = Request.QueryString["shipping_amount"];
            SHIPPING_AMOUNT.Value = shipping_amount;
            string handling_amount = Request.QueryString["handling_amount"];
            HANDLING_AMOUNT.Value = handling_amount;
            string shipping_discount_amount = Request.QueryString["shipping_discount_amount"];
            SHIPPING_DISCOUNT_AMOUNT.Value = shipping_discount_amount;
            string insurance_amount = Request.QueryString["insurance_amount"];
            INSURANCE_AMOUNT.Value = insurance_amount;
            string total_amount = Request.QueryString["total_amount"];
            TOTAL_AMOUNT.Value = total_amount;
            string currency_code = Request.QueryString["currency_code"];
            CURRENCY_CODE.Value = currency_code;
            string payment_type = Request.QueryString["payment_type"];
            PAYMENT_TYPE.Value = payment_type;
        }
          
    }
}