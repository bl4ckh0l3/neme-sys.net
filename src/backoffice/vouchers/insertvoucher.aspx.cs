using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _Voucher : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected bool bolFoundLista = false;
	protected VoucherCampaign campaign;
	
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
		cssClass="LVC";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		IVoucherRepository voucherep = RepositoryFactory.getInstance<IVoucherRepository>("IVoucherRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		
		campaign = new VoucherCampaign();		
		campaign.id = -1;
		campaign.type = -1;
		campaign.active = false;
		campaign.voucherAmount = 0.00M;
		campaign.excludeProdRule = false;
		campaign.operation = 0;
		campaign.maxGeneration = -1;
		campaign.maxUsage = -1;
		campaign.enableDate = DateTime.ParseExact("31/12/9999 23.59", "dd/MM/yyyy HH.mm", null);
		campaign.expireDate = DateTime.ParseExact("31/12/9999 23.59", "dd/MM/yyyy HH.mm", null);
				
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				campaign = voucherep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				campaign = new VoucherCampaign();		
				campaign.id = -1;
				campaign.type = -1;
				campaign.active = false;
				campaign.voucherAmount = 0.00M;
				campaign.excludeProdRule = false;
				campaign.operation = 0;
				campaign.maxGeneration = -1;
				campaign.maxUsage = -1;
				campaign.enableDate = DateTime.ParseExact("31/12/9999 23.59", "dd/MM/yyyy HH.mm", null);
				campaign.expireDate = DateTime.ParseExact("31/12/9999 23.59", "dd/MM/yyyy HH.mm", null);
			}	
		}
		
		//******** INSERISCO NUOVO VOUCHER / MODIFICO ESISTENTE
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;				
			try
			{				
				string label = Request["label"];
				string description = Request["descrizione"];
				int type = Convert.ToInt32(Request["voucher_type"]);
				bool active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));
				decimal value = Convert.ToDecimal(Request["valore"]);
				int operation = Convert.ToInt32(Request["calculation"]);
				int maxGeneration = Convert.ToInt32(Request["max_generation"]);
				int maxUsage = Convert.ToInt32(Request["max_usage"]);
				DateTime enableDate = DateTime.ParseExact("31/12/9999 23.59.59", "dd/MM/yyyy HH.mm.ss", null);
				if(!String.IsNullOrEmpty(Request["enable_date"])){
					enableDate = DateTime.ParseExact(Request["enable_date"], "dd/MM/yyyy HH.mm", null);
				}
				DateTime expireDate = DateTime.ParseExact("31/12/9999 23.59.59", "dd/MM/yyyy HH.mm.ss", null);
				if(!String.IsNullOrEmpty(Request["expire_date"])){
					expireDate = DateTime.ParseExact(Request["expire_date"], "dd/MM/yyyy HH.mm", null);
				}
				bool excludeProdRule = Convert.ToBoolean(Convert.ToInt32(Request["exclude_prod_rule"]));							
				
				campaign.label = label;
				campaign.description = description;
				campaign.type = type;
				campaign.active = active;
				campaign.voucherAmount = value;
				campaign.excludeProdRule = excludeProdRule;
				campaign.operation = operation;
				campaign.maxGeneration = maxGeneration;
				campaign.maxUsage = maxUsage;
				campaign.enableDate = enableDate;
				campaign.expireDate = expireDate;

				if(campaign.id==-1){
					voucherep.insert(campaign);
				}else{
					voucherep.update(campaign);
				}					
			}catch (Exception ex){
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/vouchers/voucherlist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}										
		}
	}
}