<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
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
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IPaymentTransactionRepository paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");

	try{	
		if(!String.IsNullOrEmpty(Request["custom"])){
			FOrder order = null;
		
			string custom = Request["custom"];
			string reforderid = "";
			//string refguid = "";
			string refamount = "";
			string reflang = "";
			string mailLangCode = lang.currentLangCode;
			custom = HttpUtility.UrlDecode(custom);				
			custom = CommonService.decodeFrom64(custom);
			string[] references = custom.Split('|');
			if(references != null && references.Length>=3){
				reforderid = references[0];
				//refguid = references[1];
				refamount = references[1];//2 if guid is eanbled 
				
				order = orderep.getByIdExtended(Convert.ToInt32(reforderid), true);
				
				if(references.Length==3){
					reflang = references[2];
					if(!String.IsNullOrEmpty(reflang)){
						mailLangCode = reflang;
					}
				}
			}		
			
			if(order != null){
				IDictionary<string,string> checkoutValues = PaymentService.setCheckout(order);
				string externalURL = "";
				bool found = checkoutValues.TryGetValue("EXTERNAL_URL", out externalURL);				
				
				if(found){
					string paymentStatus = Request["payment_status"].ToLower();
					string transactionId = Request["txn_id"];
					int paymentModule =  payrep.getById(order.paymentId).idModule;
								
					string formPostData = "cmd = _notify-validate";
		
					foreach (String postKey in Request.Form.AllKeys){
						string postValue = Request.Form[postKey].Replace("\"", "'");
						postValue = System.Web.HttpUtility.UrlEncode(postValue);
						postValue = postValue.Replace("%2f", "/");
						formPostData += string.Format("&{0}={1}", postKey, postValue);
					}
					
					// Step 1b: POST the data back to PayPal.
					string response = "";
					ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
					HttpWebRequest request = (HttpWebRequest)WebRequest.Create(externalURL);	
					request.Method = "POST";	
					//request.Timeout = 5000;		
					byte[] byteArray = Encoding.UTF8.GetBytes (formPostData);
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
						response = readStream.ReadToEnd();	
					} 					
	
					PaymentTransaction payTrans = new PaymentTransaction();
					payTrans.idOrder=order.id;
					payTrans.idModule = paymentModule;
					payTrans.idTransaction = transactionId;
					payTrans.insertDate = DateTime.Now;	
						
					// Step 1c: Process the response from PayPal.
					if("VERIFIED".Equals(response) && OrderService.isOrderVerified(order, reforderid/*, refguid*/, refamount)){
						if("completed".Equals(paymentStatus)){
							order.paymentDone=true;
							payTrans.notified = true;	
							payTrans.status = CommonKeywords.getSuccessKey();			
							paytransrep.savePaymentTransaction(order, payTrans);		

							UriBuilder orderMailBuilder = new UriBuilder(Request.Url);
							orderMailBuilder.Port = -1;
							orderMailBuilder.Path="";
							orderMailBuilder.Query="";							
							
							//***** send confirm order email
							if(!order.mailSent){
								bool mailSent = OrderService.sendConfirmOrderMail(order.id, mailLangCode, lang.defaultLangCode, orderMailBuilder.ToString());
							}
							
							//***** send confirm order email
							if(!order.downloadNotified){
								//***** send download order email
								bool mailDownSent = OrderService.sendDownloadOrderMail(order.id, mailLangCode, lang.defaultLangCode, orderMailBuilder.ToString());
							}
							
							//***** enable ads
							if(!order.adsEnabled){
								bool adsEnabled = OrderService.activateAds(order.id, mailLangCode, lang.defaultLangCode);
							}										
						}else{
							order.paymentDone=false;
							payTrans.notified = false;	
							payTrans.status = CommonKeywords.getPendingKey();			
							paytransrep.savePaymentTransaction(order, payTrans);
						}
						
						Logger log1 = new Logger();
						log1.usr= "system";
						log1.msg = "paypal: order verified: "+ order.id+" - response: "+response+" - status: "+paymentStatus;
						log1.type = "info";
						log1.date = DateTime.Now;
						lrep.write(log1);		
					}else{
						order.paymentDone=false;
						order.status=4;
						payTrans.notified = false;	
						payTrans.status = CommonKeywords.getFailedKey();
						paytransrep.savePaymentTransaction(order, payTrans);						
					
						Logger log2 = new Logger();
						log2.usr= "system";
						log2.msg = "paypal: order validation failed: "+ order.id+" - response: "+response+" - status: "+paymentStatus;
						log2.type = "info";
						log2.date = DateTime.Now;
						lrep.write(log2);						
					}
				}else{
					throw new Exception("paypal: external url not found");
				}
			}else{
				throw new Exception("paypal: order validation failed: "+reforderid);
			}
		}else{
			throw new Exception("paypal: order validation failed");
		}	
	}catch(Exception ex){
		Logger log = new Logger();
		log.usr= "system";
		log.msg = ex.Message;
		log.type = "error";
		log.date = DateTime.Now;
		lrep.write(log);
	}	
}
</script>