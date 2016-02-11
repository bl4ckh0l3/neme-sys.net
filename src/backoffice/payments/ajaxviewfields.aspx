<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected PaymentModule paymentModule;
protected IList<IPaymentField> paymentFields;
protected bool hasFields;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		

	ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
	IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
	IPaymentModuleRepository paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	hasFields = false;
	bool hasPayment = false;
	int idPayment = Convert.ToInt32(Request["idPayment"]);
	int idModule = Convert.ToInt32(Request["idModule"]);

	try
	{		
		paymentModule = paymodrep.getById(idModule);
		if(idPayment != -1){
			paymentFields = payrep.getPaymentFields(idPayment, idModule, null, null, null);
			if(paymentFields == null || paymentFields.Count==0){
				paymentFields = paymodrep.getPaymentModuleFields(idModule, null, null, null);
			}
		}else{		
			paymentFields = paymodrep.getPaymentModuleFields(idModule, null, null, null);
		}
		
		if(paymentFields != null && paymentFields.Count>0){hasFields = true;}
	}
	catch(Exception ex)
	{
		Response.Write(ex.Message);
		paymentModule=null;
		paymentFields=null;
	}	
}
</script>


<link rel="stylesheet" href="/backoffice/css/jquery-ui-latest.custom.css" type="text/css">
<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui-latest.custom.min.js"></script>
<%if(paymentModule!=null){%>
	<br/><br/><span class="labelFormTitle"><%=lang.getTranslated("backend.payment.detail.table.field.label.list_intro")%>:</span><br/><br/>
	
	<div id="matchPaymentField" align="left" style="float:top;">
	<div align="left" style="float:top;width:200px;">				
	<span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.field.label.value")%></span>
	</div>
	<%
	foreach(IPaymentField paymentField in paymentFields){
		string payTmpCss = "formFieldTXT";
		string paytmpreadonly = "";
		string paytmpval = paymentField.value;
		string paytmplabel = paymentField.keyword;
		if(!String.IsNullOrEmpty(paymentField.matchField)){
			payTmpCss = "formFieldTXTReadOnly";
			paytmpreadonly = "readonly=\"true\"";
			paytmpval = paymentField.matchField;
		}%>
		<div align="left" style="float:top">				
		<input type="text" name="fieldname_<%=paymentField.keyword%>" value="<%=paytmpval%>" class="<%=payTmpCss%>" <%=paytmpreadonly%>>
		&nbsp;<span class="labelFormThin"><%=lang.getTranslated("backend.payment.detail.table.field.label.match")%>:&nbsp;</span><%=paytmplabel%>
		</div>		
	<%}%>
	</div>	
<%}%>