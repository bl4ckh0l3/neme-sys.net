using System;
using System.Data;
using System.Web.UI;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;

public partial class _BillingList : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected bool bolFoundBillData = false;	
	protected int itemsXpage, numPage;
	protected int fromBilling, toBilling;
	protected string cssClass;
	protected IList<Billing> billings;
	protected BillingData billingData;
	protected IBillingRepository billingrep;
	protected ICountryRepository countryrep;
	protected IList<Country> countries;
	protected IList<Country> stateRegions;
	protected string internationalCountryCode = "";
	protected string internationalStateRegionCode = "";
	
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
		cssClass="LB";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		
		StringBuilder errorUrl = new StringBuilder("/backoffice/include/error.aspx?error_code=");
		
		billingrep = RepositoryFactory.getInstance<IBillingRepository>("IBillingRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		
		billingData = new BillingData();
		
		if (!String.IsNullOrEmpty(Request["items"])) {
			Session["billingItems"] = Convert.ToInt32(Request["items"]);
			itemsXpage = (int)Session["billingItems"];
		}else{
			if (Session["billingItems"] != null) {
				itemsXpage = (int)Session["billingItems"];
			}else{
				Session["billingItems"] = 20;
				itemsXpage = (int)Session["billingItems"];
			}
		}

		if (!String.IsNullOrEmpty(Request["page"])) {
			Session["billingPage"] = Convert.ToInt32(Request["page"]);
			numPage = (int)Session["billingPage"];
		}else{
			if (Session["billingPage"] != null) {
				numPage = (int)Session["billingPage"];
			}else{
				Session["billingPage"]= 1;
				numPage = (int)Session["billingPage"];
			}
		}


		if(!String.IsNullOrEmpty(Request["resetMenu"]) && Request["resetMenu"] == "1") 
		{
			Session["billingPage"] = 1;
			numPage = (int)Session["billingPage"];
		}	
		
		
		try
		{
			billingData = billingrep.getBillingData();	
			if(billingData != null){
				internationalCountryCode = billingData.country;
				internationalStateRegionCode = billingData.stateRegion;
				bolFoundBillData = true;
			}
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			billingData = new BillingData();
			bolFoundBillData = false;
		}
		
		
		try{				
			countries = countryrep.findAllCountries("2,3");		
			if(countries == null){				
				countries = new List<Country>();						
			}
		}catch (Exception ex){
			countries = new List<Country>();
		}
		try{				
			stateRegions = countryrep.findStateRegionByCountry(internationalCountryCode,"2,3");	
			if(stateRegions == null){				
				stateRegions = new List<Country>();						
			}
		}catch (Exception ex){
			stateRegions = new List<Country>();
		}		
		
		
		try
		{
			billings = billingrep.findAll();
			if(billings != null && billings.Count>0){				
				bolFoundLista = true;
			}	
		}
		catch (Exception ex)
		{
			//Response.Write("An error occured: " + ex.Message);
			billings = new List<Billing>();
			bolFoundLista = false;
		}

		int iIndex = billings.Count;
		fromBilling = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toBilling = iIndex - diff;
			
		if(itemsXpage>0){_totalPages = iIndex/itemsXpage;}
		if(_totalPages < 1) {
			_totalPages = 1;
		}else if(billings.Count % itemsXpage != 0 &&  (_totalPages * itemsXpage) < iIndex) {
			_totalPages = _totalPages +1;	
		}	
		
		
		//*************************** INSERT BILLING DATA  ***************************
		
		//Response.Write("operation: "+Request["operation"]);
		
		if("insert".Equals(Request["operation"]))
		{
			bool executed = false;
			//Response.Write("<br>executed: "+executed);
			try
			{
				billingData = new BillingData();
				billingData.name = Request["bills_name"];
				billingData.cfiscvat = Request["bills_cfiscvat"];
				billingData.address = Request["bills_address"];
				billingData.city = Request["bills_city"];
				billingData.zipCode = Request["bills_zip_code"];
				billingData.country = Request["bills_country"];
				billingData.stateRegion = Request["bills_state_region"];  
			
				//Response.Write("<br>billingData: "+billingData.ToString());
				
				billingrep.saveBillingData(billingData);
				executed = true;
			}
			catch(Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);
				errorUrl.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				executed = false;
			}
				
			//Response.Write("<br>executed post: "+executed);
				
			if(executed){
				Response.Redirect("/backoffice/billings/billinglist.aspx?cssClass=LB&resetMenu=1");
			}else{
				Response.Redirect(errorUrl.ToString());
			}			
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
	}
}