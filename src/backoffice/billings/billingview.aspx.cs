using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;

public partial class _BillingView : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected int orderid;
	protected int billingid;
	protected string paymentType;
	protected bool paymentDone;
	protected decimal billsAmount;
	protected decimal paymentCommissions;
	protected decimal orderAmount;
	protected decimal taxableAmount;
	protected decimal taxAmount;
	protected bool hasOrderRule;
	protected bool hasProductRule;
	protected IList<OrderBusinessRule> orderRules;
	protected IList<OrderBusinessRule> productRules;
	protected string pdone;
	protected string downNotified;
	protected string mailSent;
	protected string adsEnabled;
	protected FOrder order;
	protected Billing billing;
	protected IDictionary<int,string> orderStatus;
	protected User user;
	protected IList<UserField> usrfields;
	protected bool hasShipAddress;
	protected bool hasBillsAddress;
	protected OrderShippingAddress oshipaddr;
	protected OrderBillsAddress obillsaddr;
	protected string paymentTrans;
	protected UriBuilder builder;
	protected string orderFees;
	protected string orderRulesDesc;
	protected string cssClass;
	protected ConfigurationService confservice;
	protected IProductRepository productrep;
	protected IContentRepository contrep;
	protected IAdsRepository adsrep;
	protected IOrderRepository orderep;
	protected string companyLogo;
	protected bool hasInvoicePdf;
	
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="LB";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		IPaymentTransactionRepository paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
		orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
		IBillingRepository billingrep = RepositoryFactory.getInstance<IBillingRepository>("IBillingRepository");
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository"); 
		confservice = new ConfigurationService();
		
		billing = null;
		order = null;
		user = null;
		billingid = -1;
		orderid = -1;
		paymentType = "";
		paymentDone = false;
		billsAmount = 0.00M;
		paymentCommissions = 0.00M;
		taxableAmount =  0.00M;
		taxAmount =  0.00M;
		orderAmount = 0.00M;
		hasShipAddress = false;
		hasBillsAddress = false;
		oshipaddr = null;
		obillsaddr = null;
		hasOrderRule = false;
		hasProductRule = false;
		pdone = "";
		downNotified = "";
		mailSent = "";
		adsEnabled = "";
		orderRules = null;
		productRules = null;
		orderStatus = OrderService.getOrderStatus();
		paymentTrans = "";
		builder = null;
		orderFees = "";
		orderRulesDesc = "";
		companyLogo = "";
		hasInvoicePdf = false;
	
		if(!String.IsNullOrEmpty(Request["id"])){
			try{	
				List<string> usesFor = new List<string>();
				usesFor.Add("2");
				usesFor.Add("3");			
				usrfields = usrrep.getUserFields(true,usesFor, null);
			}catch (Exception ex){
				usrfields = new List<UserField>();
			}	
		
			try{
				billingid = Convert.ToInt32(Request["id"]);
				billing = billingrep.getById(billingid);
				
				BillingData billingData = billingrep.getBillingData();
				
				if(billingData != null && !String.IsNullOrEmpty(billingData.filePath)){
					companyLogo = "/public/upload/files/billing_data/"+billingData.filePath;
				}
				
				orderid = billing.idParentOrder;
				order = orderep.getByIdExtended(orderid, true);
				
				user = usrrep.getById(order.userId);

					
				string filePath = Server.MapPath("~/public/upload/files/billings/invoice_"+billingid+"_"+orderid+".pdf");	
				
				if(File.Exists(@filePath)){
					hasInvoicePdf = true;
				}				
				
				
				builder = new UriBuilder(Request.Url);
				builder.Scheme = "http";
				builder.Port = -1;
				builder.Path="";
				builder.Query="";				
				
				paymentDone = order.paymentDone;
				paymentCommissions = order.paymentCommission;
				orderAmount = order.amount;
	
				pdone = lang.getTranslated("portal.commons.no");
				if(paymentDone){
					pdone = lang.getTranslated("portal.commons.yes");
				}			
				
				int paymentId = order.paymentId;
				Payment payment = payrep.getByIdCached(paymentId, true);
				if(payment != null){
					paymentType = payment.description;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+payment.description))){
						paymentType = lang.getTranslated("backend.payment.description.label."+payment.description);
					}
				}
	
				//****** MANAGE ORDER FEES			
				IList<OrderFee> fees = orderep.findFeesByOrderId(orderid);
				if(fees != null && fees.Count>0){
					foreach(OrderFee f in fees){
						billsAmount+=f.amount;
						
						string label = f.feeDesc;
						if(!String.IsNullOrEmpty(lang.getTranslated("backend.fee.description.label."+f.feeDesc))){
							label = lang.getTranslated("backend.fee.description.label."+f.feeDesc);
						}
						orderFees+=label+"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"+f.amount.ToString("#,###0.00")+"<br/>";
					}
				}
				
				oshipaddr = orderep.getOrderShippingAddressCached(orderid, true);
				if(oshipaddr != null){
					hasShipAddress = true;
				}
				
				obillsaddr = orderep.getOrderBillsAddressCached(orderid, true);
				if(obillsaddr != null){
					hasBillsAddress = true;
				}
				
				orderRules = orderep.findOrderBusinessRule(orderid, false);
				if(orderRules != null && orderRules.Count>0){
					hasOrderRule = true;
				}
				
				productRules = orderep.findOrderBusinessRule(orderid, true);
				if(productRules != null && productRules.Count>0){
					hasProductRule = true;
				}
			}catch(Exception ex){
				StringBuilder builderErr = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builderErr.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);			
			}
		}			
	}
}