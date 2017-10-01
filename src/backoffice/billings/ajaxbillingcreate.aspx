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

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
		
	IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	IBillingRepository billingrep = RepositoryFactory.getInstance<IBillingRepository>("IBillingRepository");
	Logger log;
	StringBuilder builder;
	
	try
	{
		int idOrder = Convert.ToInt32(Request["id_order"]);
		
		FOrder order = orderep.getByIdExtended(idOrder, true);
		
		// retrieve BillingData
		BillingData billingData = billingrep.getBillingData();	
		
		// create Billing
		Billing billing = new Billing();
		billing.idParentOrder = order.id;		
		billing.orderAmount	= order.amount;		
		billing.orderDate =	order.insertDate;		
		billing.name = billingData.name;				
		billing.cfiscvat = billingData.cfiscvat;			
		billing.address	= billingData.address;			
		billing.city = billingData.city;				
		billing.zipCode = billingData.zipCode;				
		billing.country	= billingData.country;			
		billing.stateRegion = billingData.stateRegion;			
		billing.phone = billingData.phone;			
		billing.fax = billingData.fax;			
		billing.description = billingData.description;		
		billing.insertDate = DateTime.Now;			
		billing.lastUpdate = DateTime.Now;			
		billing.idRegisteredBilling = 0;	
		billing.registeredDate = DateTime.Now;		
		
		billingrep.insert(billing);

		Response.Write(billing.id);
		Response.StatusCode = 200;
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