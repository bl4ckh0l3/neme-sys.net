<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
protected IList<Payment> paymentMethods = null;	
protected int payment_method =  -1;
protected decimal totale_carrello = 0.0M;
protected decimal tot_and_spese = 0.00M;
protected IPaymentRepository payrep;
protected IPaymentModuleRepository paymodrep;

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
	login.acceptedRoles = "1";
	bool logged = login.checkedUser();
		
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
	Logger log = new Logger();
	StringBuilder errorMsg = new StringBuilder();
	
	if(login.checkedUser()){
		try
		{		
			totale_carrello = Convert.ToDecimal(Request["totale_carrello"]);
			tot_and_spese = Convert.ToDecimal(Request["tot_and_spese"]);
			if(!String.IsNullOrEmpty(Request["payment_method"])){
				payment_method =  Convert.ToInt32(Request["payment_method"]);
			}
	
			int paymentType = -1;
			if(tot_and_spese<=0){
				paymentType = 0;
			}
						
			paymentMethods = payrep.find(-1, paymentType, true, "0,2", true, true);
			
		}
		catch(Exception ex)
		{
			errorMsg.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
			log = new Logger(errorMsg.ToString(),"system","error",DateTime.Now);		
			lrep.write(log);
		}
	}
}
</script>

<%if(paymentMethods != null && paymentMethods.Count>0){
	bool paymentSelected = false;	%>
	<ul style="list-style:none;padding-left:5px;padding-top:0px;margin:0px;">
	<%foreach(Payment p in paymentMethods){
		bool isChecked = false;
		if(p.id == payment_method){
			isChecked = true;
			paymentSelected = true;
		}
		
		string logo = "";
		PaymentModule pm = paymodrep.getByIdCached(p.idModule, true);
		if(pm != null){
			logo = pm.icon;
		}
		
		string pdesc = p.description;
		if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+p.description))){
			pdesc = lang.getTranslated("backend.payment.description.label."+p.description);
		}%>
		<li><input type="radio" name="payment_method" value="<%=p.id%>" <%if(isChecked){Response.Write(" checked='checked'");}%> onclick="javascript:calculatePaymentCommission('<%=totale_carrello%>',<%=p.id%>,'1','1');">&nbsp;<%=pdesc%>&nbsp;<%=logo%></li>
		<script language="Javascript">
		listPaymentMethods.put("<%=p.id%>","<%=p.commission+"|"+p.commissionType%>");	
		</script>
	<%}%>
	</ul>
	<%if(!paymentSelected) {%>
		<script language="Javascript">
		$(".payment_commission").empty();
		$(".payment_commission").append('0,00');
		</script>
	<%}
}%>	