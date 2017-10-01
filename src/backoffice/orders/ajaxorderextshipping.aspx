<%@ Page Language="C#" Debug="true" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ import Namespace="Newtonsoft.Json.Linq" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected IList<OrderProductAttachmentDownload> attachments;
protected bool hasAttach;
protected IProductRepository prodrep;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
		
	prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IBillingRepository billingrep = RepositoryFactory.getInstance<IBillingRepository>("IBillingRepository");
	IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
	Logger log;
	StringBuilder builder;
	IList<Product> shippableProducts = new List<Product>();
	ShippingAddress shipaddr = null;
	
	UriBuilder orderMailBuilder = new UriBuilder(Request.Url);
	orderMailBuilder.Scheme = "http";
	orderMailBuilder.Port = -1;
	orderMailBuilder.Path="";
	orderMailBuilder.Query="";	
		
	try
	{
		int idOrder = Convert.ToInt32(Request["id_order"]);
		int provider = Convert.ToInt32(Request["provider"]);
		int idFee = Convert.ToInt32(Request["id_fee"]);
		
		FOrder order = orderep.getByIdExtended(idOrder, true);
		
		// retrieve BillingData
		BillingData billingData = billingrep.getBillingData();	
		
		//retrieve shipping address
		OrderShippingAddress oshipaddr = orderep.getOrderShippingAddressCached(idOrder, true);
		if(oshipaddr != null){
			shipaddr = OrderService.OrderShipAddress2ShippingAddress(oshipaddr);
		};

		//adding all products
		foreach(OrderProduct op in order.products.Values){
			Product c = prodrep.getByIdCached(op.idProduct, true);
			if(c.prodType==0){
				for(int x=1;x<=op.productQuantity;x++){
					shippableProducts.Add(c);
				}
			}								
		}		
		
		//retrieve the fee
		Fee f = feerep.getByIdCached(idFee, true);
				
		
		if(provider==1){
			//UPS integration
			UPSFee extProvider = FeeService.getUPSShip(f.extParams, shippableProducts, shipaddr, billingData);
			
			if(extProvider != null && extProvider.success){
				JObject o = JObject.Parse(extProvider.extResponse);
				
				//Response.Write("extProvider.extResponse: "+extProvider.extResponse+"<br><br>");

				//save gif label				
				if(o!=null && o.HasValues){
					string labelBase64 = o.SelectToken("ShipmentResponse.ShipmentResults.PackageResults[0].ShippingLabel.GraphicImage").ToString();
					
					//Response.Write("labelBase64: "+labelBase64+"<br><br>");
					
					string basePath = "~/public/upload/files/orders/"+idOrder;

					if (!Directory.Exists(HttpContext.Current.Server.MapPath(basePath)))
					{
						Directory.CreateDirectory(HttpContext.Current.Server.MapPath(basePath));
					}					
					
					string filePath = HttpContext.Current.Server.MapPath(basePath+"/shipping_label.gif");
					
					if(File.Exists(@filePath)){
						File.Delete(@filePath);
					}
					
					//Response.Write("filePath: "+filePath+"<br><br>");
				
					Utils.SaveImageFrom64(labelBase64, filePath);
					
					// retrieve TrackingNumber
					string trackingNumber = (string)o.SelectToken("ShipmentResponse.ShipmentResults.PackageResults[0].TrackingNumber");
					
					//Response.Write("trackingNumber: "+trackingNumber+"<br><br>");
					
					// send email to the customer with the tracking id and the label gif image and update OrderFee
					bool mailSent = OrderService.sendShippingOrderMail(idOrder, idFee, trackingNumber, lang.currentLangCode, lang.defaultLangCode, orderMailBuilder.ToString());		

					//Response.Write("mailSent: "+mailSent+"<br><br>");
					
					if(mailSent){
						OrderFee orderFee = orderep.getFeeById(idOrder, idFee);
						orderFee.shippingEnabled = true;
						orderFee.shippingResponse = extProvider.extResponse;
						orderep.updateOrderFee(orderFee);		
					}else{
						throw new Exception("error while sending mail to the user for external UPS courier shipping");
					}
				}
				
			}else{
				throw new Exception("error while activating external UPS courier shipping");
			}	
		}else if(provider==2){
			//DHL integration
			
		}
	}
	catch(Exception ex)
	{
		builder = new StringBuilder("Exception: ")
		.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
		//log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
		//lrep.write(log);
		//Response.Write(builder.ToString());
		Response.StatusCode = 400;
	}
}
</script>