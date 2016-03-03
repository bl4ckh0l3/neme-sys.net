using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _VoucherView : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundUsers = false;
	protected int itemsXpage, numPage;
	protected int fromVoucher, toVoucher;
	protected string cssClass;	
	protected IList<VoucherCode> voucherCodes;
	protected VoucherCampaign campaign;
	protected int totalCounterCode;
	protected IList<User> users;
	protected IUserRepository usrrep;
	
	private int _totalPages;	
	public int totalPages {
		get { return _totalPages; }
	}
	
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
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
					
		Logger log = new Logger();
		totalCounterCode = 0;

		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["voucherCodeItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["voucherCodeItems"];
		}else{
			if (Session["voucherCodeItems"] != null) {
				itemsXpage = (int)Session["voucherCodeItems"];
			}else{
				Session["voucherCodeItems"] = 20;
				itemsXpage = (int)Session["voucherCodeItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["voucherCodePage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["voucherCodePage"];
		}else{
			if (Session["voucherCodePage"] != null) {
				numPage = (int)Session["voucherCodePage"];
			}else{
				Session["voucherCodePage"]= 1;
				numPage = (int)Session["voucherCodePage"];
			}
		}		
		
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

		try{
			totalCounterCode = voucherep.countVoucherCodeByCampaign(campaign.id, -1);	    	
		}catch (Exception ex){
			totalCounterCode = 0;
		}

		try{
			users = usrrep.find(null, "3", true, null, false, -1, false, false, false, false, false,false);	
			if(users!=null && users.Count>0){
				bolFoundUsers = true;
			}
		}catch (Exception ex){
			bolFoundUsers = false;
			users = new List<User>();
		}		
		
		
		//***** SE SI TRATTA DI UPDATE DELETE O MULTI RECUPERO I PARAMETRI ED ESEGUO OPERAZIONI	
		try{
			voucherCodes = voucherep.findVoucherCode(campaign.id);
			if(voucherCodes != null){				
				bolFoundLista = true;			
			}	    	
		}catch (Exception ex){
			//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			voucherCodes = new List<VoucherCode>();
			bolFoundLista = false;
		}
	
		int iIndex = voucherCodes.Count;
		fromVoucher = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toVoucher = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(voucherCodes.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
			_totalPages = _totalPages +1;	
		}
			
		this.pg1.totalPages = this.totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	
			
		this.pg2.totalPages = this.totalPages;
		this.pg2.defaultLangCode = lang.defaultLangCode;
		this.pg2.currentPage = this.numPage;
		this.pg2.pageForward = Request.Url.AbsolutePath;
		this.pg2.parameters = "items="+itemsXpage+"&cssClass="+cssClass;	

		//******** INSERISCO NUOVO VOUCHER CODE
		if("delete".Equals(Request["operation"]))
		{
			string error_message = "";
			VoucherCode voucher = null;
			int id_campaign = -1;
			
			bool carryOn = true;				
			try
			{
				int id_voucher = Convert.ToInt32(Request["voucher_code"]);
				id_campaign = Convert.ToInt32(Request["id_voucher"]);
				voucher = voucherep.getVoucherCodeById(id_voucher);
				voucherep.deleteVoucherCode(voucher);
			}catch (Exception ex){
				error_message = lang.getTranslated("backend.voucher.label.error_delete_code");
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/vouchers/viewvoucher.aspx?cssClass="+Request["cssClass"]+"&id="+id_campaign);
			}else{
				Response.Redirect("/backoffice/vouchers/viewvoucher.aspx?cssClass="+Request["cssClass"]+"&id="+id_campaign+"&error_message="+error_message);
			}					
		}
		
		//******** INSERISCO NUOVO VOUCHER CODE
		if("insert".Equals(Request["operation"]))
		{
			string error_message = "";	
			VoucherCode voucher = null;
			int id_voucher = -1;
			
			bool carryOn = true;				
			try
			{	
									
				id_voucher = Convert.ToInt32(Request["id_voucher"]);  
				int id_user_ref = -1;
				if(!String.IsNullOrEmpty(Request["id_user_ref"])){
					id_user_ref = Convert.ToInt32(Request["id_user_ref"]);   
				}
				
				VoucherCampaign referral = voucherep.getById(id_voucher);
				int generatedCounter = voucherep.countVoucherCodeByCampaign(id_voucher, id_user_ref);
				
				if(generatedCounter<referral.maxGeneration || referral.maxGeneration==-1){
					IList<string> existsVoucherCodes = voucherep.getAllVoucherCodes();
					
					string code = "";
					
					bool ahead = true;
					while(ahead) 
					{ 
						code = Guids.createVoucherCodeGuid();
						if (!existsVoucherCodes.Contains(code)) 
						{ 
							ahead=false;
						} 
					} 								
					
					voucher = new VoucherCode();
					voucher.id=-1;
					voucher.code=code;
					voucher.campaign=id_voucher;
					voucher.usageCounter=0;
					voucher.userId=id_user_ref;
					voucher.insertDate=DateTime.Now;
	
					voucherep.insertVoucherCode(voucher);
				}else{
					error_message = lang.getTranslated("backend.voucher.label.error_generate_max_code");
					carryOn = false;	
				}
			}catch (Exception ex){
				error_message = lang.getTranslated("backend.voucher.label.error_generate_code");
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/vouchers/viewvoucher.aspx?cssClass="+Request["cssClass"]+"&id="+id_voucher+"&id_new_code="+voucher.code);
			}else{
				Response.Redirect("/backoffice/vouchers/viewvoucher.aspx?cssClass="+Request["cssClass"]+"&id="+id_voucher+"&error_message="+error_message);
			}										
		}		
	}
}