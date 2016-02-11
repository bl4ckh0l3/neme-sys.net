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
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	
	if(!String.IsNullOrEmpty(Request["custom"])){
		FOrder order = orderep.getById(Convert.ToInt32(Request["custom"]));
		
		if(order != null){
			//checkoutForm = PaymentService.setCheckout(order);
			
			Payment payment = payrep.getById(order.paymentId);
			
			string tkid = Request["txn_id"];
			string atid = "";
			
			string externalURL = "";
			
			if(payment != null){
				IList<IPaymentField> payFields = payrep.getPaymentFields(payment.id, payment.idModule, null, null, null);
				
				if(payFields != null && payFields.Count>0){
					
					foreach(IPaymentField f in payFields){
						if(CommonKeywords.getUniqueKeyExtURLPayment().Equals(f.keyword)){
							externalURL = f.value;	
						}else if("at".Equals(f.keyword)){
							atid = f.value;
						}
					}
					
					string strResponse = "";
					
					/*
					string query = "cmd=_notify-synch&tx="+tkid+"&at="+atid;
					
					// Create the request back
					string url = externalURL+"?"+query;
					HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
					
					// Set values for the request back
					req.Method = "POST";
					req.ContentType = "application/x-www-form-urlencoded";
					req.ContentLength = query.Length;
					
					// Write the request back IPN strings
					StreamWriter stOut = new StreamWriter(req.GetRequestStream(), System.Text.Encoding.ASCII);
					stOut.Write(query);
					stOut.Close();
					
					// Do the request to PayPal and get the response
					StreamReader stIn = new StreamReader(req.GetResponse().GetResponseStream());
					strResponse = stIn.ReadToEnd();
					stIn.Close();
					*/
					

					NameValueCollection outgoingQueryString = HttpUtility.ParseQueryString(String.Empty);
					outgoingQueryString.Add("cmd","_notify-synch");
					outgoingQueryString.Add("tx", tkid);
					outgoingQueryString.Add("at", atid);
					string postData = outgoingQueryString.ToString();
					Response.Write("postData: "+postData+"<br>");

					ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
					HttpWebRequest request = (HttpWebRequest)WebRequest.Create(externalURL);	
					request.Method = "POST";	
					request.Timeout = 5000;		
					byte[] byteArray = Encoding.UTF8.GetBytes (postData);
					request.ContentType = "application/x-www-form-urlencoded";
					request.ContentLength = byteArray.Length;
					Stream dataStream = request.GetRequestStream();
					dataStream.Write (byteArray, 0, byteArray.Length);
					dataStream.Close();
					//WebResponse response = request.GetResponse ();
					
					using (WebResponse myWebResponse = request.GetResponse())
					{			
						// Obtain a 'Stream' object associated with the response object.
						Stream ReceiveStream = myWebResponse.GetResponseStream();							
						Encoding encode = System.Text.Encoding.GetEncoding("utf-8");						
						// Pipe the stream to a higher level stream reader with the required encoding format. 
						StreamReader readStream = new StreamReader( ReceiveStream, encode );					
						strResponse = readStream.ReadToEnd();	
					}
					
					/*
					using (WebClient client = new WebClient())
					{               
						using (Stream stream = client.OpenRead(externalURL))
						using (StreamReader reader = new StreamReader(stream))
						{
							strResponse = reader.ReadToEnd();
						}
					}
					*/

					/*
					using(WebClient client = new WebClient())
					{
						NameValueCollection outgoingQueryString = HttpUtility.ParseQueryString(String.Empty);
						outgoingQueryString.Add("cmd","_notify-synch");
						outgoingQueryString.Add("tx", tkid);
						outgoingQueryString.Add("at", atid);
						byte[] responsebytes = client.UploadValues(externalURL, "POST", outgoingQueryString);
						strResponse = Encoding.UTF8.GetString(responsebytes);
					}
					*/
					
					Response.Write("strResponse: "+strResponse);
				}
			}			
			
		}
	}
	
	Response.Write("QUERY parameters: "+Request.Url.Query+"<BR><BR>");
	
	foreach (string key in Request.Form.AllKeys)
	{
		Response.Write("key:"+key+" - value: "+Request.Form[key]+"<BR>");
	}
}
</script>
