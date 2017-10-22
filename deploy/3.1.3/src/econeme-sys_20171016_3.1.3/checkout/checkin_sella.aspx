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
	
	string secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
	
	if(!String.IsNullOrEmpty(Request["b"]) && !String.IsNullOrEmpty(Request["a"])){
		bool carryOn = false;
		bool verified = false;  
		FOrder order = null;
		int paymentModule = -1;
		string finalOrderId = "";
		string transactionId = "";

		try{
			string Shop_Login = Request["a"];
			string EncString = Request["b"];
			if (EncString != null && Shop_Login != null)
			{
				//Response.Write("a:" + Shop_Login + "<br />b:" + EncString + "<br />");
			
				WSCryptDecrypt objDecrypt = new WSCryptDecrypt();
				string XMLOut = objDecrypt.Decrypt(Shop_Login, EncString).OuterXml;
				XmlDocument XMLReturn = new XmlDocument();
				XMLReturn.LoadXml(XMLOut.ToLower());
				//Response.Write("Shop:" + Shop_Login + "<br />");
				XmlNode ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/errorcode");
				string ErrorCode = ThisNode.InnerText;
				ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/errordescription");
				string ErrorDesc = ThisNode.InnerText;
				ThisNode = XMLReturn.SelectSingleNode("/gestpaycryptdecrypt/authorizationcode");
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
					}
			
					if(order != null){  
						finalOrderId = order.id.ToString(); 
						Payment payment = payrep.getById(order.paymentId);
						paymentModule =  payment.idModule;
						carryOn = true; 
						
						bool orderVerified = OrderService.isOrderVerified(order, reforderid, refamount);
						
						if (orderVerified && "ok".Equals(TrxResut.ToLower())){
							verified = true;   
						}else{
							verified = false;
						}
						
						//Response.Write("order:" + order.ToString() + "<br />verified: "+ verified+"<br />");
					}						
				}
				else {
					throw new Exception("ErrorCode:" + ErrorCode + "<br />ErrorDesc:" + ErrorDesc + "<br />");
				}
				
				//Response.Write("ErrorCode:" + ErrorCode + "<br />ErrorDesc:" + ErrorDesc + "<br />");
			}
		}catch(Exception ex){
			carryOn = false;
			//Response.Write(ex.Message);
			lrep.write(new Logger("ex.Message: "+ex.Message,"system","error",DateTime.Now));
		}
			
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
				Response.Redirect(secureURL+"backoffice/orders/orderconfirmed.aspx?cssClass=LO&orderid="+finalOrderId);
			}else{
				Response.Redirect(secureURL+"public/templates/shopping-cart/orderconfirmed.aspx?orderid="+finalOrderId);
			}
		}else{
			Response.Redirect(secureURL+"error.aspx?error_code=043");
		}
	}else{
		Response.Redirect(secureURL+"error.aspx?error_code=043");
	}
}
</script>