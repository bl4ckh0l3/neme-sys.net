<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
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
	
	//IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	ConfigurationService confservice = new ConfigurationService();
	
	string secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
	
	string apiVersion = "65.0";
	bool carryOn = false;
	string ECURL = "";
			
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
				
				string user = "";
				string pwd = "";
				string signature = "";
				string externalURL = "";
				string endpointURL = "";
				string returnURL = secureURL+"checkout/checkin.aspx";
				string cancelURL = secureURL+"checkout/checkin_failed.aspx";
				string amount = order.amount.ToString("0.00").Replace(",",".");
				string custom = order.id.ToString()+"|"+amount+langCode;
				custom = CommonService.encodeTo64(custom);
				string currency = "";
				
				bool found = true;
				
				found = found && checkoutValues.TryGetValue("USER", out user);
				found = found && checkoutValues.TryGetValue("PWD", out pwd);
				found = found && checkoutValues.TryGetValue("SIGNATURE", out signature);
				found = found && checkoutValues.TryGetValue("EXTERNAL_URL", out externalURL);
				found = found && checkoutValues.TryGetValue("ENDPOINT_URL", out endpointURL);
				found = found && checkoutValues.TryGetValue("PAYMENTREQUEST_0_CURRENCYCODE", out currency);
	
				if(found){
					StringBuilder postData = new StringBuilder();
					
					postData.Append("USER").Append("=").Append(HttpUtility.UrlEncode(user))
					.Append("&").Append("PWD").Append("=").Append(HttpUtility.UrlEncode(pwd))
					.Append("&").Append("SIGNATURE").Append("=").Append(HttpUtility.UrlEncode(signature))
					.Append("&").Append("VERSION").Append("=").Append(HttpUtility.UrlEncode(apiVersion))	
					.Append("&").Append("METHOD").Append("=").Append(HttpUtility.UrlEncode("SetExpressCheckout"))
					.Append("&").Append("PAYMENTREQUEST_0_PAYMENTACTION").Append("=").Append(HttpUtility.UrlEncode("Sale"))
					.Append("&").Append("NOSHIPPING").Append("=").Append(HttpUtility.UrlEncode("1"))	
					.Append("&").Append("RETURNURL").Append("=").Append(HttpUtility.UrlEncode(returnURL))
					.Append("&").Append("CANCELURL").Append("=").Append(HttpUtility.UrlEncode(cancelURL))
					.Append("&").Append("PAYMENTREQUEST_0_AMT").Append("=").Append(HttpUtility.UrlEncode(amount))
					.Append("&").Append("PAYMENTREQUEST_0_CURRENCYCODE").Append("=").Append(HttpUtility.UrlEncode(currency))
					.Append("&").Append("PAYMENTREQUEST_0_CUSTOM").Append("=").Append(HttpUtility.UrlEncode(custom));	
					
					//Response.Write("postData: " + postData.ToString()+"<br>");
					
					string result="";
			
					ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
					HttpWebRequest request = (HttpWebRequest)WebRequest.Create(endpointURL);	
					request.Method = "POST";	
					request.Timeout = 5000;		
					byte[] byteArray = Encoding.UTF8.GetBytes (postData.ToString());
					request.ContentType = "application/x-www-form-urlencoded";
					request.ContentLength = byteArray.Length;
					Stream dataStream = request.GetRequestStream();
					dataStream.Write (byteArray, 0, byteArray.Length);
					dataStream.Close();
					
					using (WebResponse myWebResponse = request.GetResponse())
					{			
						Stream ReceiveStream = myWebResponse.GetResponseStream();							
						Encoding encode = System.Text.Encoding.GetEncoding("utf-8");						
						StreamReader readStream = new StreamReader( ReceiveStream, encode );					
						result = readStream.ReadToEnd();	
					}         
					
					IDictionary<string,string> postValues = new Dictionary<string,string>();
					
					foreach (string nvp in result.Split('&'))
					{
						string[] tokens = nvp.Split('=');
						if (tokens.Length >= 2)
						{
							string name = HttpUtility.UrlDecode(tokens[0]);
							string value = HttpUtility.UrlDecode(tokens[1]);
							postValues.Add(name, value);
						}
					}
					
					string strAck = "";
					string token = "";
					
					found = true;
					found = found && postValues.TryGetValue("ACK", out strAck);
					found = found && postValues.TryGetValue("TOKEN", out token);
	
					if(found){
						strAck = HttpUtility.UrlDecode(strAck).ToLower();
						if (!String.IsNullOrEmpty(strAck) && (strAck == "success" || strAck == "successwithwarning")){
							ECURL = externalURL+"?cmd=_express-checkout" + "&token=" + HttpUtility.UrlDecode(token);
							
							carryOn = true;
						}
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