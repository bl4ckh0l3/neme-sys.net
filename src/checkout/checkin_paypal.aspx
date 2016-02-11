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
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.UserLoginControl login;	

protected void Page_Init(Object sender, EventArgs e)
{
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	

	login.acceptedRoles = "1,2,3";
	bool logged = login.checkedUser();
	
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IPaymentTransactionRepository paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	
	string apiVersion = "65.0";
	
	if(!String.IsNullOrEmpty(Request["TOKEN"])){
		string token = Request["TOKEN"];
		string user = "";
		string pwd = "";
		string signature = "";
		string endpointURL = "";
		string currency = "";
		string finalOrderId = "";
		
		bool carryOn = false;
		bool verified = false;  
		FOrder order = null;
		int paymentModule = -1;
		string transactionId = "";

		try{
			IList<IPaymentField> payFields = payrep.getPaymentFieldsCached(-1, -1, null, null, null, true);
			if(payFields != null && payFields.Count>0){
				foreach(IPaymentField f in payFields){
					if("USER".Equals(f.keyword)){
						user = f.value;	
					}else if("PWD".Equals(f.keyword)){
						pwd = f.value;
					}else if("SIGNATURE".Equals(f.keyword)){
						signature = f.value;
					}else if("ENDPOINT_URL".Equals(f.keyword)){
						endpointURL = f.value;
					}else if("PAYMENTREQUEST_0_CURRENCYCODE".Equals(f.keyword)){
						currency = f.value;
					}				
				}
			}
			
			if(!String.IsNullOrEmpty(endpointURL)){
				
				StringBuilder postData = new StringBuilder();
				postData.Append("USER").Append("=").Append(HttpUtility.UrlEncode(user))
				.Append("&").Append("PWD").Append("=").Append(HttpUtility.UrlEncode(pwd))
				.Append("&").Append("SIGNATURE").Append("=").Append(HttpUtility.UrlEncode(signature))
				.Append("&").Append("VERSION").Append("=").Append(HttpUtility.UrlEncode(apiVersion))	
				.Append("&").Append("METHOD").Append("=").Append(HttpUtility.UrlEncode("GetExpressCheckoutDetails"))	
				.Append("&").Append("TOKEN").Append("=").Append(HttpUtility.UrlEncode(token));	
				
				string result="";
		
				ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
				HttpWebRequest request = (HttpWebRequest)WebRequest.Create(endpointURL);	
				request.Method = "POST";	
				//request.Timeout = 10000;		
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
				token = "";
				
				bool found = true;
				found = found && postValues.TryGetValue("ACK", out strAck);
				found = found && postValues.TryGetValue("TOKEN", out token);
				
				if(found){
					strAck = HttpUtility.UrlDecode(strAck).ToLower();
					if (!String.IsNullOrEmpty(strAck) && (strAck == "success" || strAck == "successwithwarning")){
						
						string payerId = "";
						postValues.TryGetValue("PAYERID", out payerId);
						payerId = HttpUtility.UrlDecode(payerId);
						
						string custom = "";
						string reforderid = "";
						string refguid = "";
						string refamount = "";
						postValues.TryGetValue("CUSTOM", out custom);
						custom = HttpUtility.UrlDecode(custom);				
						string[] references = Utils.decodeFrom64(custom).Split('|');
						if(references != null && references.Length>=3){
							reforderid = references[0];
							refguid = references[1];
							refamount = references[2];
							
							order = orderep.getByIdExtended(Convert.ToInt32(reforderid), true);
						}
				
						if(order != null){
							UriBuilder orderUri = new UriBuilder(Request.Url);
							orderUri.Port = -1;
							orderUri.Path="";
							orderUri.Query="";							
							string notifyURL = orderUri.ToString()+"checkout/notify.aspx";

							postData = new StringBuilder();
							postData.Append("USER").Append("=").Append(HttpUtility.UrlEncode(user))
							.Append("&").Append("PWD").Append("=").Append(HttpUtility.UrlEncode(pwd))
							.Append("&").Append("SIGNATURE").Append("=").Append(HttpUtility.UrlEncode(signature))
							.Append("&").Append("VERSION").Append("=").Append(HttpUtility.UrlEncode(apiVersion))	
							.Append("&").Append("METHOD").Append("=").Append(HttpUtility.UrlEncode("DoExpressCheckoutPayment"))	
							.Append("&").Append("TOKEN").Append("=").Append(HttpUtility.UrlEncode(token))
							.Append("&").Append("PAYERID").Append("=").Append(HttpUtility.UrlEncode(payerId))
							.Append("&").Append("PAYMENTREQUEST_0_PAYMENTACTION").Append("=").Append(HttpUtility.UrlEncode("Sale"))
							.Append("&").Append("PAYMENTREQUEST_0_NOTIFYURL").Append("=").Append(HttpUtility.UrlEncode(notifyURL))
							.Append("&").Append("PAYMENTREQUEST_0_AMT").Append("=").Append(HttpUtility.UrlEncode(order.amount.ToString("0.00").Replace(",",".")))
							.Append("&").Append("PAYMENTREQUEST_0_CURRENCYCODE").Append("=").Append(HttpUtility.UrlEncode(currency))
							.Append("&").Append("PAYMENTREQUEST_0_CUSTOM").Append("=").Append(HttpUtility.UrlEncode(custom));
							
							ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
							request = (HttpWebRequest)WebRequest.Create(endpointURL);	
							request.Method = "POST";	
							//request.Timeout = 5000;		
							byteArray = Encoding.UTF8.GetBytes (postData.ToString());
							request.ContentType = "application/x-www-form-urlencoded";
							request.ContentLength = byteArray.Length;
							dataStream = request.GetRequestStream();
							dataStream.Write (byteArray, 0, byteArray.Length);
							dataStream.Close();
							
							using (WebResponse myWebResponse = request.GetResponse())
							{			
								Stream ReceiveStream = myWebResponse.GetResponseStream();							
								Encoding encode = System.Text.Encoding.GetEncoding("utf-8");						
								StreamReader readStream = new StreamReader( ReceiveStream, encode );					
								result = readStream.ReadToEnd();	
							}         
							
							postValues = new Dictionary<string,string>();
							
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
							
							strAck = "";
							token = "";
							
							found = true;
							found = found && postValues.TryGetValue("ACK", out strAck);
							found = found && postValues.TryGetValue("TOKEN", out token);
				
							if(found){   
								finalOrderId = order.id.ToString(); 
								Payment payment = payrep.getById(order.paymentId);
								paymentModule =  payment.idModule;
								postValues.TryGetValue("PAYMENTINFO_0_TRANSACTIONID", out transactionId);
								carryOn = true; 
								
								bool orderVerified = OrderService.isOrderVerified(order, reforderid, refguid, refamount);
								
								strAck = HttpUtility.UrlDecode(strAck).ToLower();
								if (!String.IsNullOrEmpty(strAck) && (strAck == "success" || strAck == "successwithwarning") && orderVerified){
									verified = true;   
								}else{
									verified = false;
								}
							}
						}
					}
				}	
			}
		}catch(Exception ex){
			carryOn = false;
			//Response.Write(ex.Message);
			lrep.write(new Logger("ex.Message: "+ex.Message,"system","error",DateTime.Now));
		}

		lrep.write(new Logger("carryOn: "+carryOn,"system","debug",DateTime.Now));
			
		if(carryOn){
			PaymentTransaction payTrans = new PaymentTransaction();
			payTrans.idOrder=order.id;
			payTrans.idModule = paymentModule;
			payTrans.idTransaction = transactionId;
			payTrans.notified = false;	
			payTrans.insertDate = DateTime.Now;			
			
			if(verified){
				order.paymentDone=true;
				payTrans.status = CommonKeywords.getSuccessKey();			
				paytransrep.savePaymentTransaction(order, payTrans);
			}else{
				order.paymentDone=false;
				payTrans.status = CommonKeywords.getFailedKey();
				paytransrep.savePaymentTransaction(order, payTrans);
			}
			
			if(logged && (login.userLogged.role.isEditor() || login.userLogged.role.isAdmin())){
				Response.Redirect("/backoffice/orders/orderconfirmed.aspx?cssClass=LO&orderid="+finalOrderId);
			}else{
				Response.Redirect("/public/templates/shopping-cart/orderconfirmed.aspx?orderid="+finalOrderId);
			}
		}else{
			Response.Redirect("/error.aspx?error_code=043");
		}
	}
}
</script>