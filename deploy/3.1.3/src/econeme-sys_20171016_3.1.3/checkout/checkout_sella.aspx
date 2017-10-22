<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>

<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="System.Web.UI.WebControls" %>
<%//@ import Namespace="it.sella.testecomm" %>
<%@ import Namespace="it.sella.ecomms2s" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
	
protected void Page_Load(object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	ConfigurationService confservice = new ConfigurationService();
	
	bool carryOn = false;
	string ECURL = "";
	
	string secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
			
	if(!String.IsNullOrEmpty(Request["orderid"])){
		try{
			FOrder order = orderep.getById(Convert.ToInt32(Request["orderid"]));
			
			if(order != null){
				IDictionary<string,string> checkoutValues = PaymentService.setCheckout(order);
	
				string langCode = lang.currentLangCode;
				if(!String.IsNullOrEmpty(Request["useLang"])){
					langCode = Request["useLang"];
				}
				if(!String.IsNullOrEmpty(langCode)){
					langCode = "|"+langCode;
				}
				
				string shopLogin = "";
				string externalURL = "";
				string returnURL = secureURL+"checkout/checkin.aspx";
				string amount = order.amount.ToString("0.00").Replace(",",".");
				string shopTransactionId = order.id.ToString()+"|"+amount+langCode;
				string currency = "";
				
				bool found = true;
				
				found = found && checkoutValues.TryGetValue("shoplogin", out shopLogin);
				found = found && checkoutValues.TryGetValue("EXTERNAL_URL", out externalURL);
				found = found && checkoutValues.TryGetValue("currency", out currency);
	
				if(found){
					PaymentTypeDetail PaymentTDetail = new PaymentTypeDetail();
					ShippingDetails ShipDetails = new ShippingDetails();
					RedBillingInfo RedBilling = new RedBillingInfo();
					RedCustomerData RedCustomerData = new RedCustomerData();
					RedCustomerInfo RedCustomerInfo = new RedCustomerInfo();
					RedItems RedItem = new RedItems();
					RedShippingInfo RedShipping = new RedShippingInfo();
					ConselCustomerInfo ConselCustomer = new ConselCustomerInfo();
					string[] PaymentTypes = { "" };
					string[] RedCustomInfo = { "" };
		
					WSCryptDecrypt objCrypt = new WSCryptDecrypt();
					string XMLOUT = objCrypt.Encrypt(shopLogin, currency, amount, shopTransactionId, "", "", "", "", "", "", "", "", "", "", ShipDetails, PaymentTypes, PaymentTDetail, "", RedCustomerInfo, RedShipping, RedBilling, RedCustomerData, RedCustomInfo, RedItem, "", ConselCustomer, "").OuterXml;
					XmlDocument XmlReturn = new XmlDocument();
					XmlReturn.LoadXml(XMLOUT);
					XmlNode ThisNode = XmlReturn.SelectSingleNode("/GestPayCryptDecrypt/ErrorCode");
					string errorCode = ThisNode.InnerText;
					if (errorCode == "0")
					{
						XmlNode ThisNode2 = XmlReturn.SelectSingleNode("//GestPayCryptDecrypt/CryptDecryptString");
						string encryptedString = ThisNode2.InnerText;
						
						ECURL = externalURL+"?a="+HttpUtility.UrlEncode(shopLogin)+"&b="+encryptedString+"&c="+HttpUtility.UrlEncode(returnURL);
						
						carryOn = true;						
					}
					else { 
						//Put error handle code HERE
						ThisNode = XmlReturn.SelectSingleNode("/GestPayCryptDecrypt/ErrorDescription");
						throw new Exception(ThisNode.InnerText);
					}
				}
			}
		}catch(Exception ex){
			Logger log = new Logger();
			log.usr= "system";
			log.msg = ex.Message;
			log.type = "error";
			log.date = DateTime.Now;
			lrep.write(log);
			carryOn = false;
		}
		
		if(carryOn){
			Response.Redirect(ECURL);
		}else{
			Response.Redirect(secureURL+"error.aspx?error_code=043");
		}
	}
}
</script>