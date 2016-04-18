using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ExpressCheckout
{
    public partial class Response : System.Web.UI.Page
    {
        protected string APIErrorMessage { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                this.APIErrorMessage = this.GetFromContext("APIErrorMessage");
             }
            apierror.Text = this.APIErrorMessage;
        }
        private string GetFromContext(string key)
        {
            if (HttpContext.Current.Items.Contains(key))
            {
                return HttpContext.Current.Items[key] as string;
            }
            return null;
        }
    }
}