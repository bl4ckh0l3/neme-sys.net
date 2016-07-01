<%@ Page Language="C#" AutoEventWireup="true" Debug="true"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Web.UI" %>
<%@ import Namespace="System.Web.UI.WebControls" %>
<%//@ import Namespace="it.sella.testecomm" %>
<%@ import Namespace="it.sella.ecomms2s" %>
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
	
	//Response.Write("a:" + Request["a"] + "<br />b:" + Request["b"] + "<br />");
	
	if(!String.IsNullOrEmpty(Request["b"]) && !String.IsNullOrEmpty(Request["a"])){
		try{
			bool verified = false;  
			FOrder order = null;
			int paymentModule = -1;
			string transactionId = "";	
			string reflang = "";
			string mailLangCode = lang.currentLangCode;	
			
			string Shop_Login = Request["a"];
			string EncString = Request["b"];
			if (EncString != null && Shop_Login != null)
			{
				//Response.Write("a:" + Shop_Login + "<br />b:" + EncString + "<br />");
			
				WSCryptDecrypt objDecrypt = new WSCryptDecrypt();
				string XMLOut = objDecrypt.Decrypt(Shop_Login, EncString).OuterXml;
				XmlDocument XMLReturn = new XmlDocument();
				XMLReturn.LoadXml(XMLOut.ToLower());
				XmlNode ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/errorcode");
				string ErrorCode = ThisNode.InnerText;
				ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/errordescription");
				string ErrorDesc = ThisNode.InnerText;
				ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/authorizationcode");
				
				//Response.Write("Shop:" + Shop_Login + "<br />");
				
				if (ErrorCode == "0")
				{
					string AuthCode = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/banktransactionid");
					transactionId = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/amount");
					string Amount = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/shoptransactionid");
					string ShopTrxID = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/transactionresult");
					string TrxResut = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/buyer/buyername");
					string BuyerName = ThisNode.InnerText;
					ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/buyer/buyeremail");
					string BuyerEmail = ThisNode.InnerText;
					
					//Response.Write("ErrorCode:" + ErrorCode + "<br />ErrorDesc:" + ErrorDesc + "<br />TrxResult:" + TrxResut + "<br />BankTrxID:" + transactionId + "<br />AuthCode:" + AuthCode + "<br />Amount:" + Amount + "<br/>BuyerName:" + BuyerName + "<br />BuyerEmail:" + BuyerEmail + "<br />");
					//Response.Write("ShopTrxID:" + ShopTrxID + "<br />");					
					
					string reforderid = "";
					string refamount = "";
					string[] references = ShopTrxID.Split('|');
					if(references != null && references.Length>=3){
						reforderid = references[0];
						refamount = references[1];
						
						order = orderep.getByIdExtended(Convert.ToInt32(reforderid), true);
						
						if(references.Length==3){
							reflang = references[2];
							if(!String.IsNullOrEmpty(reflang)){
								mailLangCode = reflang;
							}
						}
					}
			
					if(order != null){  
						Payment payment = payrep.getById(order.paymentId);
						paymentModule =  payment.idModule;
						
						bool orderVerified = OrderService.isOrderVerified(order, reforderid, refamount);
						
						if (orderVerified){
							verified = true;   
						}else{
							verified = false;
						}	
						
						PaymentTransaction payTrans = new PaymentTransaction();
						payTrans.idOrder=order.id;
						payTrans.idModule = paymentModule;
						payTrans.idTransaction = transactionId;
						payTrans.insertDate = DateTime.Now;	
							
						// Step 1c: Process the response from PayPal.
						if(verified){
							if("ok".Equals(TrxResut.ToLower())){
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
							log1.msg = "sella: order verified: "+ order.id+" - status: "+TrxResut;
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
							log2.msg = "sella: order validation failed: "+ order.id+" - status: "+TrxResut;
							log2.type = "info";
							log2.date = DateTime.Now;
							lrep.write(log2);						
						}							
					}else{
						throw new Exception("sella: order validation failed: "+reforderid);
					}						
				}else {
					throw new Exception("sella: ErrorCode:" + ErrorCode + "<br />ErrorDesc:" + ErrorDesc + "<br />");
				}
			}else {
				throw new Exception("sella: order validation failed");
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
}
</script>