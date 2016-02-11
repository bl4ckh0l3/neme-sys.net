using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using log4net;
namespace ExpressCheckout
{
    public partial class Index : System.Web.UI.Page
    {

        static Index()
        {
            // Load the log4net configuration settings from Web.config or App.config
            log4net.Config.XmlConfigurator.Configure();
        }

        // Logs output statements, errors, debug info to a text file
        private static ILog logger = LogManager.GetLogger(typeof(Index));
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
        }
    }
}