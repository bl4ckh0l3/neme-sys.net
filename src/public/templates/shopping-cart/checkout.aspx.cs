using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using com.nemesys.model;
using com.nemesys.database.repository;
using com.nemesys.services;
using com.nemesys.exception;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _Checkout : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected IProductRepository productrep;
	protected ICurrencyRepository currrep;
	protected ISupplementRepository suprep;
	protected ISupplementGroupRepository supgrep;
	protected IShoppingCartRepository shoprep;
	protected ICountryRepository countryrep;
	protected IContentRepository contrep;
	protected Currency defCurrency;
	protected Currency userCurrency;
	protected IList<Currency> currencyList;
	protected string currency;
	protected IList<int> matchCategories = null;
	protected IList<ProductAttachmentLabel> attachmentsLabel = null;
	protected string hierarchy;
	protected string categoryid;
	protected string backURL = "#";
	protected string shoppingcardURL = "";
	protected string currentBaseURL = "";
	protected bool bolFoundLista = false;
	protected UserGroup ug;
	protected string internationalCountryCode = "";
	protected string internationalStateRegionCode = "";
	protected bool userIsCompanyClient = false;
	protected bool logged;
	protected IDictionary<int, IList<object>> orderRulesData;
	protected IDictionary<string, IList<object>> prodsData;
	protected IDictionary<int, IList<object>> billsData;
	protected IDictionary<int, IList<object>> paysData;
	protected IList<FeeStrategyField> Scpf4Bills;
	protected ShoppingCart shoppingCart;	
	protected ShippingAddress shipaddr = null;	
	protected BillsAddress billsaddr = null;
	protected bool hasShipAddress = false;
	protected bool hasBillsAddress = false;
	protected IList<UserField> usrfields;
	protected bool bolFoundFields;
	protected string noRegEmail = "";
	protected decimal totalAmount4Bills;
	protected decimal totalBillsAmount;
	protected decimal totalAutomaticBillsAmount;
	protected decimal totalProductAmount;
	protected decimal totalCartAmount;
	protected decimal totalCartAmountAndBillsAmount;
	protected decimal totalCartAmountAndAutoBillsAmount;
	protected decimal totalMarginAmount;
	protected decimal totalDiscountAmount;
	protected decimal totalPaymentAmount;
	protected int totalCartQuantity;
	protected bool applyBills = false;
	protected bool hasOrderRule = false;
	protected bool bolHasProdRule = false;
	protected IList<Fee> fees;
	protected IList<Country> countries;
	protected IList<Country> stateRegions;
	protected IList<BusinessRule> businessRules;
	protected IList<BusinessRule> productBusinessRules;
	protected IDictionary<int,BusinessRuleProductVO> productsVO;
	protected VoucherCampaign voucherCampaign;
	protected VoucherCode voucherCode;
	protected bool voucherExcludeProdRule;
	protected string voucher_code = "";
	protected string voucherMessage = "";
	protected bool activeVoucherCampaign;
	
	private string _pageTitle;	
	public string pageTitle {
		get { return _pageTitle; }
	}
	
	private string _metaDescription;	
	public string metaDescription {
		get { return _metaDescription; }
	}
	
	private string _metaKeyword;	
	public string metaKeyword {
		get { return _metaKeyword; }
	}
			
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}
		
	protected void Page_Load(object sender, EventArgs e) 
	{	
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;
		_pageTitle = lang.getTranslated("frontend.page.title");
		_metaDescription = "";
		_metaKeyword = "";
		login.acceptedRoles = "";
		logged = login.checkedUser();
		bool carryOn = false;
		contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");
		IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
		currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");
		IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		IPaymentModuleRepository paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository"); 
		IAdsRepository adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository"); 
		IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
		confservice = new ConfigurationService();

		//se il sito � offline rimando a pagina default
		if ("1".Equals(confservice.get("go_offline").value)) 
		{
			UriBuilder defRedirect = new UriBuilder(Request.Url);
			defRedirect.Port = -1;	
			defRedirect.Path = "";			
			defRedirect.Query = "";
			Response.Redirect(defRedirect.ToString());
		}
		
		StringBuilder errorUrl = new StringBuilder("/error.aspx?error_code=");

		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";

		StringBuilder shoppingcardPath = new StringBuilder();
		/*if(confservice.get("url_with_langcode_prefix").value=="1")
		{	
			shoppingcardPath.Append(lang.currentLangCode.ToLower()).Append("/");
		}*/
		shoppingcardPath.Append("public/templates/shopping-cart/checkout");
		if(confservice.get("url_rewrite_file_ext").value=="1")
		{	
			shoppingcardPath.Append(".aspx");
		}
		
		UriBuilder shoppingcardBuilder = new UriBuilder(Request.Url);
		if(confservice.get("use_https").value=="1")
		{	
			shoppingcardBuilder.Scheme = "https";
		}
		else
		{
			shoppingcardBuilder.Scheme = "http";
		}
		shoppingcardBuilder.Port = -1;	
		shoppingcardBuilder.Path = shoppingcardPath.ToString();	
		shoppingcardBuilder.Query = "";
		shoppingcardURL = shoppingcardBuilder.ToString();

		currentBaseURL = new StringBuilder().Append(basePath.Substring(0,basePath.LastIndexOf("/")+1)).ToString();
	
		UriBuilder orderMailBuilder = new UriBuilder(Request.Url);
		orderMailBuilder.Scheme = "http";
		orderMailBuilder.Port = -1;
		orderMailBuilder.Path="";
		orderMailBuilder.Query="";		
		
		currencyList = new List<Currency>();
		currency = "";
		ug = null;
		decimal usrdiscountperc = 0.00M;
		internationalCountryCode = "";
		internationalStateRegionCode = "";
		userIsCompanyClient = false;
		prodsData = new Dictionary<string, IList<object>>();
		orderRulesData = new Dictionary<int, IList<object>>();
		billsData = new Dictionary<int, IList<object>>();
		paysData = new Dictionary<int, IList<object>>();
		shoppingCart = null;
		string acceptDate = "";
		voucherExcludeProdRule = false;
		activeVoucherCampaign = false;
		totalAmount4Bills=0.00M;
		totalBillsAmount=0.00M;
		totalAutomaticBillsAmount=0.00M;
		totalProductAmount=0.00M;
		totalCartAmount=0.00M;
		totalCartAmountAndBillsAmount=0.00M;
		totalCartAmountAndAutoBillsAmount=0.00M;
		totalCartQuantity=0;
		totalMarginAmount=0.00M;
		totalDiscountAmount=0.00M;
		totalPaymentAmount=0.00M;
		Scpf4Bills = new List<FeeStrategyField>();
		businessRules = null;
		productBusinessRules = null;
		voucherCampaign = null;
		voucherCode = null;
		productsVO = new Dictionary<int,BusinessRuleProductVO>();
	
		string shopcartcufoff = confservice.get("day_carrello_is_valid").value;
		if(!String.IsNullOrEmpty(shopcartcufoff)){
			acceptDate = DateTime.Now.AddDays(-Convert.ToInt32(shopcartcufoff)).ToString("dd/MM/yyyy");
		}

		noRegEmail = Request["noreg_email"];
		
		//Response.Write("acceptDate: "+acceptDate+"<br>");		
		//Response.Write("logged: "+logged+"<br>");
		
		
		if(logged){
			if(!login.userLogged.role.isGuest()){
				Response.Redirect(errorUrl.Append("034").ToString());
			}else{
				shoppingCart = shoprep.getByIdUser(Math.Abs(Session.SessionID.GetHashCode()), acceptDate, true);
				if(shoppingCart != null){
					shoppingCart.idUser=login.userLogged.id;
					shoprep.update(shoppingCart);
				}else{
					//Response.Write("login.userLogged.id: "+login.userLogged.id+"<br>");
					shoppingCart = shoprep.getByIdUser(login.userLogged.id, acceptDate, true);
					//Response.Write("shoppingCart != null: "+(shoppingCart != null)+"<br>");
				}
				
				if(shoppingCart != null){		
					ug = usrrep.getUserGroup(login.userLogged);
					
					if(login.userLogged.discount != null && login.userLogged.discount >0){
						usrdiscountperc = login.userLogged.discount;
					}
					
					shipaddr = shiprep.getByUserIdCached(login.userLogged.id, true);
			
					if(shipaddr != null){
						//Response.Write("shipaddr:<br>"+shipaddr.ToString());
						internationalCountryCode = shipaddr.country;
						internationalStateRegionCode = shipaddr.stateRegion;
						userIsCompanyClient = shipaddr.isCompanyClient;	
						Session["shipaddr"] = shipaddr;
					}
			
					billsaddr = billsrep.getByUserIdCached(login.userLogged.id, true);
					if(billsaddr != null){
						Session["billsaddr"] = billsaddr;
					}
								
					carryOn = true;
				}
			}
		}else{
			shoppingCart = shoprep.getByIdUser(Math.Abs(Session.SessionID.GetHashCode()), acceptDate, true);
			if(shoppingCart != null){		
				carryOn = true;
			}			
		}
		

		//*************************** DELETE CART  ***************************
		
		if("delcart".Equals(Request["operation"]))
		{
			bool executed = false;
			try
			{
				executed = ShoppingCartService.delCart(Convert.ToInt32(Request["cart_to_delete"]));
			}
			catch(Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);
				errorUrl.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				executed = false;
			}
				
			if(executed){
				Response.Redirect(currentBaseURL+"cartdeleted.aspx");
			}else{
				Response.Redirect(errorUrl.ToString());
			}			
		}		
		

		//*************************** DELETE ITEM  ***************************
		
		if("delitem".Equals(Request["operation"]))
		{
			bool executed = false;
			try
			{
				executed = ShoppingCartService.delItem(Convert.ToInt32(Request["cartid"]), Convert.ToInt32(Request["productid"]), Convert.ToInt32(Request["counter_prod"]));
			}
			catch(Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);
				errorUrl.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				executed = false;
			}
				
			if(executed){
				string redirectUrl = "";
				UriBuilder delItemBuilder = new UriBuilder(Request.Url);
				if(confservice.get("use_https").value=="1"){	
					delItemBuilder.Scheme = "https";
				}else{
					delItemBuilder.Scheme = "http";
				}
				delItemBuilder.Port = -1;	
				redirectUrl=delItemBuilder.ToString();
				if(String.IsNullOrEmpty(delItemBuilder.Query)){
					redirectUrl+="?";
				}
				redirectUrl+="&hierarchy="+Request["hierarchy"]+"&id_ads="+Request["id_ads"]+"&voucher_code="+Request["voucher_code"];
				Response.Redirect(redirectUrl);
			}else{
				Response.Redirect(errorUrl.ToString());
			}			
		}


		//*************************** ADD ITEM  ***************************
		
		if("additem".Equals(Request["operation"]))
		{
			bool executed = false;
			
			try
			{	
				HttpFileCollection MyFileCollection;			
				MyFileCollection = Request.Files;
				
				int idProduct = Convert.ToInt32(Request["productid"]);
				int quantity = Convert.ToInt32(Request["quantity"]);
				int maxProdQty = Convert.ToInt32(Request["max_prod_qta"]);
				string resetQtyByCart = Request["reset_qta"];
				int idAds = -1;
				User userItem = null;
				if(logged){
					userItem = login.userLogged;
				}
	
				if(maxProdQty>-1 && quantity>maxProdQty){
					throw new System.InvalidOperationException(lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod"));
				}
				
				IDictionary<int,IList<string>> requestFields = new Dictionary<int,IList<string>>();

				foreach (string key in Request.Form.AllKeys)
				{
					if(key.StartsWith("product_field_"))
					{
						string fieldid = key.Substring(key.LastIndexOf('_')+1);
						string currvalue = Request.Form[key];	
						if(!String.IsNullOrEmpty(currvalue)){
							IList<string> values = new List<string>();
							string[] fvalues = currvalue.Split(',');
							foreach(string fv in fvalues){
								values.Add(fv.Trim());
							}
							requestFields.Add(Convert.ToInt32(fieldid), values);
						}						
					}
				}				

				foreach (string key in Request.Files.AllKeys)
				{
					if(key.StartsWith("product_field_"))
					{
						string fieldid = key.Substring(key.LastIndexOf('_')+1);
						string currvalue = Path.GetFileName(Request.Files[key].FileName);	
						if(!String.IsNullOrEmpty(currvalue)){
							IList<string> values = new List<string>();
							values.Add(currvalue);
							requestFields.Add(Convert.ToInt32(fieldid), values);
						}						
					}
				}
				
				executed = ShoppingCartService.addItem(userItem, -1, Math.Abs(Session.SessionID.GetHashCode()), acceptDate, requestFields, MyFileCollection, idProduct, quantity, maxProdQty, resetQtyByCart, idAds, lang.currentLangCode, lang.defaultLangCode);
			}
			catch(Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);
				errorUrl.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				executed = false;
			}
				
			if(executed){
				string redirectUrl = "";
				UriBuilder delItemBuilder = new UriBuilder(Request.Url);
				if(confservice.get("use_https").value=="1"){	
					delItemBuilder.Scheme = "https";
				}else{
					delItemBuilder.Scheme = "http";
				}
				delItemBuilder.Port = -1;	
				redirectUrl=delItemBuilder.ToString();
				if(String.IsNullOrEmpty(delItemBuilder.Query)){
					redirectUrl+="?";
				}
				redirectUrl+="&hierarchy="+Request["hierarchy"]+"&id_ads="+Request["id_ads"]+"&voucher_code="+Request["voucher_code"];
				Response.Redirect(redirectUrl);
			}else{
				Response.Redirect(errorUrl.ToString());
			}			
		}
		
		
		if(carryOn){
			//********** VERIFICO SE ESISTE UNA CAMPAGNA VOUCHER ATTIVA E SE E' STATO INSERITO UN VOUCHER E IN TAL CASO CERCO UNA RULE DI TIPO VOUCHER
			
			businessRules = brulerep.find("3", 1);
			if(businessRules != null && businessRules.Count>0){
				activeVoucherCampaign = true;
				//*** recupero il voucher_code dalla request o dalla session
				if("1".Equals(Request["voucher_delete"])){
					Session["voucher_code"] = "";
				}
				if(!String.IsNullOrEmpty(Request["voucher_code"])){
					Session["voucher_code"] = Request["voucher_code"];
				}
				voucher_code = (string)Session["voucher_code"];
					
				if (!String.IsNullOrEmpty(voucher_code)){
					voucherCode = VoucherService.validateVoucherCode(voucher_code, out voucherCampaign);
					if (voucherCode != null){
						hasOrderRule = true;
						if(voucherCampaign.excludeProdRule){
							voucherExcludeProdRule = true;
						}
					}else{
						voucherMessage = lang.getTranslated("portal.commons.voucher.message.error_invalid");
						Session["voucher_code"]="";
						voucher_code = (string)Session["voucher_code"];
						hasOrderRule = false;
					}
				}
			}
			//Response.Write("hasOrderRule: "+hasOrderRule+"<br>");				
					
			if(logged){			
				//*** verifico se esiste una rule primo ordine e se l'utente ne possiede i requisiti
				if (!hasOrderRule){ 
					if(orderep.countByIdUser(login.userLogged.id)==0){
						businessRules = brulerep.find("4,5", 1);
						if(businessRules != null && businessRules.Count>0){
							hasOrderRule = true;
						}
					}
				}	
			}
			
			//********** SE NON ESISTE GIA' UNA RULE PRIMO ORDINE, CERCO TUTTE LE RULE PER ORDINE ATTIVE
			if (!hasOrderRule){
				businessRules = brulerep.find("1,2", 1);
				if(businessRules != null && businessRules.Count>0){
					hasOrderRule = true;
				}
			}

			try{
				List<string> usesFor = new List<string>();
				usesFor.Add("2");
				usesFor.Add("3");				
				usrfields = usrrep.getUserFields("true",usesFor);
				if(usrfields != null && usrfields.Count>0){
					bolFoundFields = true;
				}else{				
					bolFoundFields = false;					
				}
			}catch (Exception ex){
				usrfields = new List<UserField>();
				bolFoundFields = false;	
			}		

			
			if(Session["shipaddr"] != null){
				shipaddr = (ShippingAddress)Session["shipaddr"];
			}
			
			if(Session["billsaddr"] != null){
				billsaddr = (BillsAddress)Session["billsaddr"];
			}		
			
			if(shipaddr == null){
					shipaddr = new ShippingAddress();
					shipaddr.id=-1;
					Session["shipaddr"] = null;
			}
			
			if(billsaddr == null){
					billsaddr = new BillsAddress();
					billsaddr.id=-1;
					Session["billsaddr"] = null;
			}			
			
			bool hasShipReqVal = false;
			if(!String.IsNullOrEmpty(Request["ship_name"])){shipaddr.name=Request["ship_name"];hasShipReqVal = true;}   
			if(!String.IsNullOrEmpty(Request["ship_surname"])){shipaddr.surname=Request["ship_surname"];hasShipReqVal = true;}
			if(!String.IsNullOrEmpty(Request["ship_cfiscvat"])){shipaddr.cfiscvat=Request["ship_cfiscvat"];hasShipReqVal = true;}
			if(!String.IsNullOrEmpty(Request["ship_address"])){shipaddr.address=Request["ship_address"];hasShipReqVal = true;}
			if(!String.IsNullOrEmpty(Request["ship_city"])){shipaddr.city=Request["ship_city"];hasShipReqVal = true;}
			if(!String.IsNullOrEmpty(Request["ship_zip_code"])){shipaddr.zipCode=Request["ship_zip_code"];hasShipReqVal = true;}
			if(!String.IsNullOrEmpty(Request["ship_country"])){
				internationalCountryCode = Request["ship_country"];
				shipaddr.country=internationalCountryCode;
				hasShipReqVal = true;
			}
			if(!String.IsNullOrEmpty(Request["ship_state_region"])){
				internationalStateRegionCode = Request["ship_state_region"];
				shipaddr.stateRegion=internationalStateRegionCode; 
				hasShipReqVal = true;
			}			
			userIsCompanyClient = false;
			if(!String.IsNullOrEmpty(Request["ship_is_company_client"])){
				userIsCompanyClient = Convert.ToBoolean(Convert.ToInt32(Request["ship_is_company_client"]));
				shipaddr.isCompanyClient=userIsCompanyClient;   
				hasShipReqVal = true;
			}
			
			bool hasBillsReqVal = false;
			if(!String.IsNullOrEmpty(Request["bills_name"])){billsaddr.name=Request["bills_name"];hasBillsReqVal = true;}				
			if(!String.IsNullOrEmpty(Request["bills_surname"])){billsaddr.surname=Request["bills_surname"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_cfiscvat"])){billsaddr.cfiscvat=Request["bills_cfiscvat"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_address"])){billsaddr.address=Request["bills_address"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_city"])){billsaddr.city=Request["bills_city"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_zip_code"])){billsaddr.zipCode=Request["bills_zip_code"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_country"])){billsaddr.country=Request["bills_country"];hasBillsReqVal = true;}	
			if(!String.IsNullOrEmpty(Request["bills_state_region"])){billsaddr.stateRegion=Request["bills_state_region"];hasBillsReqVal = true;}	

			
			if(hasShipReqVal){Session["shipaddr"] = shipaddr;}
			if(hasBillsReqVal){Session["billsaddr"] = billsaddr;}
			
			if(
				!String.IsNullOrEmpty(shipaddr.name) &&
				!String.IsNullOrEmpty(shipaddr.surname) &&
				!String.IsNullOrEmpty(shipaddr.cfiscvat) &&
				!String.IsNullOrEmpty(shipaddr.address) &&
				!String.IsNullOrEmpty(shipaddr.city) &&
				!String.IsNullOrEmpty(shipaddr.zipCode) &&
				!String.IsNullOrEmpty(shipaddr.country)
			){
				hasShipAddress = true;
			}else{
				hasShipAddress = false;	
			}
			
			if(
				!String.IsNullOrEmpty(billsaddr.name) &&
				!String.IsNullOrEmpty(billsaddr.surname) &&
				!String.IsNullOrEmpty(billsaddr.cfiscvat) &&
				!String.IsNullOrEmpty(billsaddr.address) &&
				!String.IsNullOrEmpty(billsaddr.city) &&
				!String.IsNullOrEmpty(billsaddr.zipCode) &&
				!String.IsNullOrEmpty(billsaddr.country)
			){
				hasBillsAddress = true;
			}else{
				hasBillsAddress = false;	
			}
			
			//Response.Write("<br>hasShipReqVal: "+hasShipReqVal);
			//Response.Write("<br>hasShipAddress: "+hasShipAddress);
			//Response.Write("<br>shipaddr:<br>"+shipaddr.ToString());
						

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
				defCurrency = currrep.findDefault();
				string tmpuserCurrency = "";
				if (!String.IsNullOrEmpty(Request["currency"])) {
					Session["currency"] = Request["currency"];
					tmpuserCurrency = (string)Session["currency"];
				}else{
					if (Session["currency"] != null) {
						tmpuserCurrency = (string)Session["currency"];
					}else{
						Session["currency"] = defCurrency.currency;
						tmpuserCurrency = (string)Session["currency"];
					}
				}
				userCurrency =  currrep.getByCurrency(tmpuserCurrency);
				currencyList = currrep.findAll("true");
				
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]))) {
					currency = lang.getTranslated("backend.currency.symbol.label."+Session["currency"]);
				}else{
					currency = (string)Session["currency"];
				}				
			}
			catch (Exception ex){
				currencyList = new List<Currency>();
				currency = "";
			}	
				
			
			try{				
				attachmentsLabel = productrep.getProductAttachmentLabelCached(true);		
				if(attachmentsLabel == null){				
					attachmentsLabel = new List<ProductAttachmentLabel>();						
				}
			}catch (Exception ex){
				attachmentsLabel = new List<ProductAttachmentLabel>();
			}
			
			try
			{	
		
				Category category = null;
				Template template = null;
		
				// tento di risolvere la categoria e il template in base ai parametri della request
				if(!String.IsNullOrEmpty(Request["categoryid"]))
				{
					category = catrep.getByIdCached(Convert.ToInt32(Request["categoryid"]), true);
					hierarchy = category.hierarchy;				
				}
				if(CategoryService.isCategoryNull(category))
				{	
					if(!String.IsNullOrEmpty(Request["hierarchy"]))
					{
						hierarchy = Request["hierarchy"];
						category = catrep.getByHierarchyCached(hierarchy, true);	
					}else
					{
						category = catrep.findFirstCategoryCached(true);
						hierarchy = category.hierarchy;							
					}			
				}
	
				//Response.Write("category:"+category.ToString()+"<br>");			
				
				if(!CategoryService.isCategoryNull(category)){							
					
					// recupero l'id template corretto in base alla lingua
					int templateId = category.idTemplate;
					foreach(CategoryTemplate ct in category.templates)
					{
						if(ct.langCode==lang.currentLangCode)
						{
							templateId = ct.templateId;
							break;
						}	
					}
					if(templateId>0){
						template = templrep.getByIdCached(templateId,true);
					}
					if(template != null)
					{
						//Response.Write("template:"+template.ToString()+"<br>");
						
						bool langHasSubDomainActive = false;
						string langUrlSubdomain = "";
						Language language = langrep.getByLabel(lang.currentLangCode, true);	
						
						string currentPath = basePath.Replace("/public/templates/","");
						currentPath = currentPath.Replace(lang.currentLangCode+"/","");
						//Response.Write("-currentPath:"+currentPath+"<br>");
						//Response.Write("-language:"+language.ToString()+"<br>");
						foreach(TemplatePage tp in template.pages){
							if(tp.priority==1){
								string templatePath = tp.filePath+tp.fileName;
								string urlRewritePath = tp.urlRewrite;
								//Response.Write("-templatePath:"+templatePath+"<br>-urlRewritePath:"+urlRewritePath+"<br>");
								int modelPageNum = tp.priority;
								//Response.Write("-modelPageNum:"+modelPageNum+"<br>");
								
								if(language != null)
								{	
									langHasSubDomainActive = language.subdomainActive;
									langUrlSubdomain = language.urlSubdomain;
								}								
								
								backURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
								//Response.Write("-backURL:"+backURL+"<br>");	
								break;
							}
						}
					}
				}	
			}catch (Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				backURL = "#";
			}
							
			try
			{
				if(shoppingCart.products != null && shoppingCart.products.Count>0){				
					bolFoundLista = true;	
					
					if (!voucherExcludeProdRule){
						//*** cerco le business rule basate sui prodotti e prodotti correlati
						productBusinessRules = brulerep.find("6,7,8,9,10", 1);
						if(productBusinessRules != null && productBusinessRules.Count>0){
							bolHasProdRule = true;
						}
					}	
					
					IDictionary<int,Product> uniqueProducts = new Dictionary<int,Product>();
					
					//*** PREPARE PRODUCT BUSINESS RULES
					foreach(ShoppingCartProduct scp in shoppingCart.products.Values){
						if(!uniqueProducts.ContainsKey(scp.idProduct)){
							Product c = productrep.getByIdCached(scp.idProduct, true);
							uniqueProducts.Add(scp.idProduct,c);
							
							BusinessRuleProductVO vo = new BusinessRuleProductVO();
							vo.productId = scp.idProduct;
							vo.productCounter = scp.productCounter;
							vo.quantity = scp.productQuantity;
							vo.price = c.price;
							productsVO[scp.idProduct] = vo;
						}else{
							productsVO[scp.idProduct].quantity+=scp.productQuantity;
						}
					}

					//*** CALCULATE PRODUCT BUSINESS RULES
					foreach(ShoppingCartProduct scp in shoppingCart.products.Values){
						if(bolHasProdRule){
							foreach(BusinessRule b in productBusinessRules){
								BusinessRuleService.hasStrategyByProduct(b, scp.idProduct, productsVO);
							} 
						}	
					}
					
					foreach(ShoppingCartProduct scp in shoppingCart.products.Values){	
						Product c = uniqueProducts[scp.idProduct];
						decimal discountperc = 0.00M;
						decimal price = c.price;
						decimal margin = 0.00M;
						decimal discount = 0.00M;
						decimal supplement = 0.00M;
						decimal amount = 0.00M;
						Supplement prodsup = null;	
						string suppdesc = "";
						string suppdescorig = "";
						string detailURL = "#";
						int modelPageNum = 1;
						string detailHierarchy = "";
						string adsRefTitle = "";
						if(scp.idAds != null && scp.idAds>-1){
							Ads a = adsrep.getById(scp.idAds);
							if(a != null){
								FContent f = contrep.getByIdCached(a.elementId, true);
								if(f != null){
									adsRefTitle = f.title;
								}
							}
						}
						
						//retrieve the first category available
						Category innerCategory = null;
						Template innerTemplate = null;
						if(c.categories != null && c.categories.Count>0){
							innerCategory = catrep.getByIdCached(c.categories[0].idCategory, true);
							detailHierarchy = innerCategory.hierarchy;
						}					
						
						if(!CategoryService.isCategoryNull(innerCategory)){				
							
							// recupero l'id template corretto in base alla lingua
							int templateId = innerCategory.idTemplate;
							foreach(CategoryTemplate ct in innerCategory.templates)
							{
								if(ct.langCode==lang.currentLangCode)
								{
									templateId = ct.templateId;
									break;
								}	
							}
							if(templateId>0){
								innerTemplate = templrep.getByIdCached(templateId,true);
							}
							if(innerTemplate != null)
							{				
								bool langHasSubDomainActive = false;
								string langUrlSubdomain = "";
								Language language = langrep.getByLabel(lang.currentLangCode, true);	
								
								string currentPath = basePath.Replace("/public/templates/","");
								currentPath = currentPath.Replace(lang.currentLangCode+"/","");
								
								modelPageNum = TemplateService.getMaxPriority(innerTemplate.pages);
								
								foreach(TemplatePage tp in innerTemplate.pages){
									if(tp.priority==modelPageNum){
										string templatePath = tp.filePath+tp.fileName;
										string urlRewritePath = tp.urlRewrite;
									
										modelPageNum = tp.priority;
										
										if(language != null)
										{	
											langHasSubDomainActive = language.subdomainActive;
											langUrlSubdomain = language.urlSubdomain;
										}								
										
										detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, innerCategory, innerTemplate, true);
										//Response.Write("detailURL:"+detailURL+"<br>");
										break;
									}
								}
							}
						}						
						
						
						decimal proddiscountperc = 0;
						if(c.discount != null && c.discount >0){
							proddiscountperc = c.discount;
						}
						
						// gestione sconto
						if(ug != null){
							price = price*scp.productQuantity;
							discountperc = ProductService.getDiscountPercentage(ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
							margin = ProductService.getMarginAmount(price, ug.margin);
							totalMarginAmount+=margin;
							discount = ProductService.getDiscountAmount(price, ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
							totalDiscountAmount+=discount;
							price = ProductService.getAmount(price, ug.margin, ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
						}else{
							if("1".Equals(confservice.get("manage_sconti").value)){// sconto prodotto + sconto cliente
								discountperc = proddiscountperc+usrdiscountperc;
							}else if("2".Equals(confservice.get("manage_sconti").value)){// solo sconto prodotto
								discountperc = proddiscountperc;
							}else{// solo sconto cliente
								if(logged && usrdiscountperc>0){
									discountperc = usrdiscountperc;
								}else{
									discountperc = proddiscountperc;
								};
							}
							
							price = price*scp.productQuantity;
							discount = ProductService.getDiscountedValue(price, discountperc);
							totalDiscountAmount+=discount;
							price-= discount;
						}


						//*** se esistono delle business rules attive sui prodotti e prodotti correlati cerco le configurazioni specifiche per ogni prodotto 
						//*** e applico il risultato all'imponibile prodotto
						if(bolHasProdRule){
							foreach(BusinessRule b in productBusinessRules){
								bool hasPrules = false;
								BusinessRuleProductVO prule = null;
								if(productsVO.TryGetValue(scp.idProduct, out prule)){
									if(/*prule.productCounter==scp.productCounter && */prule.rulesInfo != null && prule.rulesInfo.Count>0){
										hasPrules = true;
									}
								}
								
								decimal ruleAmount = 0.00M;
								
								if(hasPrules){
									IList<object> ir = null;
									bool hasRuleInfo = prule.rulesInfo.TryGetValue(b.id, out ir);
									
									if(hasRuleInfo){
										ruleAmount = Convert.ToDecimal(ir[0]);
									}
								}
								price+=ruleAmount;
							} 
						}					
												
						//*** se dopo l'applicazione degli sconti e delle business rule per prodotto l'imponibile e' inferiore a 0, elimino la componente negativa
						if(price<0){
							price=0.00M;;
						}
						
						// gestione supplements
						if(c.idSupplement != null && c.idSupplement >0){
							prodsup = suprep.getByIdCached(c.idSupplement, true);
						}
						
						if("1".Equals(confservice.get("enable_international_tax_option").value) && !String.IsNullOrEmpty(internationalCountryCode)){
							if(c.idSupplementGroup != null && c.idSupplementGroup >0){
								SupplementGroup psg =  supgrep.getByIdCached(c.idSupplementGroup, true);
								IList<SupplementGroupValue> psgvalues = psg.values;
								int idSup = 0;
								foreach(SupplementGroupValue sgv in psgvalues){
									if(internationalCountryCode.Equals(sgv.countryCode)){
										if(String.IsNullOrEmpty(internationalStateRegionCode) && String.IsNullOrEmpty(sgv.stateRegionCode)){
											if(userIsCompanyClient && sgv.excludeCalculation){
												suppdesc = "&nbsp;("+lang.getTranslated("frontend.prodotti.label.tax_excluded")+")";
												idSup = 0;
											}else{
												idSup = sgv.idFee;
											}
											break;
										}
										
										if(!String.IsNullOrEmpty(internationalStateRegionCode) && internationalStateRegionCode.Equals(sgv.stateRegionCode)){
											if(userIsCompanyClient && sgv.excludeCalculation){
												suppdesc = "&nbsp;("+lang.getTranslated("frontend.prodotti.label.tax_excluded")+")";
												idSup = 0;
											}else{
												idSup = sgv.idFee;
											}
											break;
										}
									}
								}
								
								if(idSup != null && idSup>0){
									prodsup = suprep.getByIdCached(idSup, true);
								}
							}
								
							if(ug != null && ug.supplementGroup != null && ug.supplementGroup >0){
								SupplementGroup usg =  supgrep.getByIdCached(ug.supplementGroup, true);
								IList<SupplementGroupValue> usgvalues = usg.values;
								int idSup = 0;
								foreach(SupplementGroupValue sgv in usgvalues){
									if(internationalCountryCode.Equals(sgv.countryCode)){
										if(String.IsNullOrEmpty(internationalStateRegionCode) && String.IsNullOrEmpty(sgv.stateRegionCode)){
											if(userIsCompanyClient && sgv.excludeCalculation){
												suppdesc = "&nbsp;("+lang.getTranslated("frontend.prodotti.label.tax_excluded")+")";
												idSup = 0;
											}else{
												idSup = sgv.idFee;
											}
											break;
										}
										
										if(!String.IsNullOrEmpty(internationalStateRegionCode) && internationalStateRegionCode.Equals(sgv.stateRegionCode)){
											if(userIsCompanyClient && sgv.excludeCalculation){
												suppdesc = "&nbsp;("+lang.getTranslated("frontend.prodotti.label.tax_excluded")+")";
												idSup = 0;
											}else{
												idSup = sgv.idFee;
											}
											break;
										}
									}
								}
								
								if(idSup != null && idSup>0){
									prodsup = suprep.getByIdCached(idSup, true);
								}
							}
						}
						
						if(prodsup != null){
							supplement = ProductService.getSupplementAmount(price, prodsup.value, prodsup.type);
							suppdescorig = prodsup.description;
							suppdesc = prodsup.description;
							string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
							if(!String.IsNullOrEmpty(suppdesctrans)){
								suppdesc = suppdesctrans;
							}
							suppdesc = "&nbsp;("+suppdesc+")";
						}
						
						amount = price+supplement;
						
						decimal convertedAmount = amount;
						decimal convertedMargin = margin;
						if(defCurrency != null && userCurrency != null){
							convertedAmount = currrep.convertCurrency(convertedAmount, defCurrency.currency, userCurrency.currency);
							convertedMargin = currrep.convertCurrency(convertedMargin, defCurrency.currency, userCurrency.currency);
						}
						
						IList<object> prodElements = new List<object>();
						prodElements.Add(price);
						prodElements.Add(convertedMargin);	
						prodElements.Add(supplement);
						prodElements.Add(convertedAmount);
						prodElements.Add(discountperc);
						prodElements.Add(suppdesc);
						prodElements.Add(c);
						prodElements.Add(scp);
						prodElements.Add(detailURL);
						prodElements.Add(modelPageNum);
						prodElements.Add(detailHierarchy);
						
						IDictionary<int,IList<ShoppingCartProductField>> foundedScpfl = shoprep.findItemFields(shoppingCart.id, scp.idProduct, scp.productCounter, -1);
						if(foundedScpfl != null && foundedScpfl.Count>0){
							IList<ShoppingCartProductField> tmpl = foundedScpfl[scp.productCounter];
							
							IList<string> descs = new List<string>();
							if(scp.productType==0){
								foreach(ShoppingCartProductField scpf in tmpl){
									// controllo che il ProductField non sia editabile da BO
									//Response.Write("<br>"+scpf.ToString());
									bool isValidField = false;
									foreach(ProductField pf in c.fields){
										//Response.Write("<br>"+pf.ToString());
										if(pf.id==scpf.idField){
											if(!pf.editable && (pf.typeContent==3 || pf.typeContent==4)){
												isValidField = true;
												break;
											}
										}
									}
									if(isValidField && !descs.Contains(scpf.description)){
										FeeStrategyField fsf = new FeeStrategyField();
										fsf.descField = scpf.description;
										fsf.quantity = scpf.productQuantity;
										fsf.value = Convert.ToDecimal(scpf.value);
										Scpf4Bills.Add(fsf);	
										descs.Add(scpf.description);
									}
								}	
							}
							
							prodElements.Add(tmpl);
						}else{
							prodElements.Add(null);
						}	
						prodElements.Add(suppdescorig);	
						prodElements.Add(adsRefTitle);	
						prodElements.Add(discount);	
						prodElements.Add(margin);
						
						prodsData.Add(scp.idProduct+"|"+scp.productCounter, prodElements);     

						//************ se il prodotto non e' di tipo scaricabile e non ci sono regole di esclusione bills, 
						//************ aggiorno l'imponibile su cui verranno calcolate le spese di spedizione
						if (scp.productType==0 && !productsVO[scp.idProduct].excludeBills){
							totalAmount4Bills+=price;
							totalCartQuantity+=scp.productQuantity;
							applyBills = true;
						}					
						
						totalCartAmount+=amount;
					}
					
					totalProductAmount=totalCartAmount;

					//*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI		
					if(hasOrderRule){
						foreach(BusinessRule or in businessRules){
							decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, totalProductAmount, voucherCampaign);
							if(foundAmount!=0){
								totalCartAmount+=foundAmount;
								if(defCurrency != null && userCurrency != null){
									foundAmount = currrep.convertCurrency(foundAmount, defCurrency.currency, userCurrency.currency);
								}

								IList<object> ordElements = new List<object>();
								ordElements.Add(foundAmount);
								ordElements.Add(or.label);	
								
								orderRulesData.Add(or.id, ordElements);  
							}
						}
					}
					
					//******************** GESTIONE SPESE ACCESSORIE
					
					try{
						fees = feerep.find(null, -1, "0,2", true);    	
					}catch (Exception ex){
						//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
						fees = new List<Fee>();
					}
					
					if(applyBills && fees != null && fees.Count>0){
						foreach(Fee f in fees){
							decimal billImp = 0.00M;
							decimal billSup = 0.00M;
							Supplement feesup = null;
							
							billImp = FeeService.getTaxableAmountByStrategy(f, totalAmount4Bills, totalCartQuantity, Scpf4Bills);
							
							// gestione supplements
							if(f.idSupplement != null && f.idSupplement >0){
								feesup = suprep.getByIdCached(f.idSupplement, true);
							}
							
							if("1".Equals(confservice.get("enable_international_tax_option").value) && !String.IsNullOrEmpty(internationalCountryCode)){
								if(f.supplementGroup != null && f.supplementGroup >0){
									SupplementGroup psg =  supgrep.getByIdCached(f.supplementGroup, true);
									IList<SupplementGroupValue> psgvalues = psg.values;
									int idSup = 0;
									foreach(SupplementGroupValue sgv in psgvalues){
										if(internationalCountryCode.Equals(sgv.countryCode)){
											if(String.IsNullOrEmpty(internationalStateRegionCode) && String.IsNullOrEmpty(sgv.stateRegionCode)){
												if(userIsCompanyClient && sgv.excludeCalculation){
													idSup = 0;
												}else{
													idSup = sgv.idFee;
												}
												break;
											}
											
											if(!String.IsNullOrEmpty(internationalStateRegionCode) && internationalStateRegionCode.Equals(sgv.stateRegionCode)){
												if(userIsCompanyClient && sgv.excludeCalculation){
													idSup = 0;
												}else{
													idSup = sgv.idFee;
												}
												break;
											}
										}
									}
									
									if(idSup != null && idSup>0){
										feesup = suprep.getByIdCached(idSup, true);
									}
								}
									
								if(ug != null && ug.supplementGroup != null && ug.supplementGroup >0){
									SupplementGroup usg =  supgrep.getByIdCached(ug.supplementGroup, true);
									IList<SupplementGroupValue> usgvalues = usg.values;
									int idSup = 0;
									foreach(SupplementGroupValue sgv in usgvalues){
										if(internationalCountryCode.Equals(sgv.countryCode)){
											if(String.IsNullOrEmpty(internationalStateRegionCode) && String.IsNullOrEmpty(sgv.stateRegionCode)){
												if(userIsCompanyClient && sgv.excludeCalculation){
													idSup = 0;
												}else{
													idSup = sgv.idFee;
												}
												break;
											}
											
											if(!String.IsNullOrEmpty(internationalStateRegionCode) && internationalStateRegionCode.Equals(sgv.stateRegionCode)){
												if(userIsCompanyClient && sgv.excludeCalculation){
													idSup = 0;
												}else{
													idSup = sgv.idFee;
												}
												break;
											}
										}
									}
									
									if(idSup != null && idSup>0){
										feesup = suprep.getByIdCached(idSup, true);
									}
								}
							}
							
							if(feesup != null){
								billSup = FeeService.getSupplementAmount(billImp, feesup.value, feesup.type);
							}	
							
							bool isChecked = false;
							decimal billAmount = billImp+billSup;
							
							if(f.autoactive){
								totalBillsAmount+=billAmount;
								totalAutomaticBillsAmount+=billAmount;	
							}else{
								// verifico se la fee corrente e' in sessione
								string billsReq = (string)Session[f.feeGroup];
								//Response.Write("Session billsReq: "+billsReq+"<br>");
								if(!String.IsNullOrEmpty(billsReq)){
									string[] splitBills = billsReq.Split(',');
									foreach(string val in splitBills){
										if(val.Trim().Equals(f.id.ToString())){
											isChecked = true;
											break;
										}
									}
								}
								
								// verifico se la fee corrente e' in request
								billsReq = Request[f.feeGroup];
								//Response.Write("Request billsReq: "+billsReq+"<br>");
								if(!String.IsNullOrEmpty(billsReq)){
									isChecked = false;
									string[] splitBills = billsReq.Split(',');
									foreach(string val in splitBills){
										if(val.Trim().Equals(f.id.ToString())){
											isChecked = true;
											break;
										}
									}
								}
							}
							
							if(defCurrency != null && userCurrency != null){
								billAmount = currrep.convertCurrency(billAmount, defCurrency.currency, userCurrency.currency);
							}
							
							string billGdesc = f.feeGroup;
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.fee.group.label."+f.feeGroup))){
								billGdesc = lang.getTranslated("backend.fee.group.label."+f.feeGroup);
							}
							string billDesc = f.description;
							if(!String.IsNullOrEmpty(lang.getTranslated("backend.fee.description.label."+f.description))){
								billDesc = lang.getTranslated("backend.fee.description.label."+f.description);
							}
							
							
							IList<object> billElements = new List<object>();
							billElements.Add(billImp);
							billElements.Add(billSup);	
							billElements.Add(billAmount);
							billElements.Add(f);
							billElements.Add(billGdesc);
							billElements.Add(billDesc);
							billElements.Add(isChecked);
							
							billsData.Add(f.id, billElements); 
						}
						
											
					}
					
					//******************** GESTIONE METODI DI PAGAMENTO
					IList<Payment> paymentMethods = null;
					int paymentType = -1;
					if(totalCartAmount+totalBillsAmount<=0){
						paymentType = 0;
					}
					
					try{
						paymentMethods = payrep.find(-1, paymentType, "true", "0,2", true, true);  
					}catch (Exception ex){
						//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
						paymentMethods = new List<Payment>();
					}
					
					if(paymentMethods != null && paymentMethods.Count>0){
						//Response.Write("paymentMethods.Count: "+paymentMethods.Count+"<br>");
						foreach(Payment p in paymentMethods){
							string logo = "";
							bool isChecked = false;
							PaymentModule pm = paymodrep.getByIdCached(p.idModule, true);
							if(pm != null){
								logo = pm.icon;
							}
							
							// verifico se la fee corrente e' in sessione
							string payReq = (string)Session["payment_method"];
							//Response.Write("Session payReq: "+payReq+"<br>");
							if(!String.IsNullOrEmpty(payReq)){
								string[] splitPays = payReq.Split(',');
								foreach(string val in splitPays){
									if(val.Trim().Equals(p.id.ToString())){
										isChecked = true;
										break;
									}
								}
							}
							
							// verifico se la fee corrente e' in request
							payReq = Request["payment_method"];
							//Response.Write("Request payReq: "+payReq+"<br>");
							if(!String.IsNullOrEmpty(payReq)){
								isChecked = false;
								string[] splitPays = payReq.Split(',');
								foreach(string val in splitPays){
									if(val.Trim().Equals(p.id.ToString())){
										isChecked = true;
										break;
									}
								}
							}

							IList<object> payElements = new List<object>();
							payElements.Add(p);
							payElements.Add(logo);
							payElements.Add(isChecked);
							
							paysData.Add(p.id, payElements); 
							
							if(isChecked){
								totalPaymentAmount = PaymentService.getCommissionAmount(totalCartAmount+totalBillsAmount, p.commission, p.commissionType);
							}
						}
					}		
					

					totalCartAmountAndBillsAmount=totalCartAmount+totalBillsAmount;
					totalCartAmountAndAutoBillsAmount=totalCartAmount+totalAutomaticBillsAmount;	
					
					//*** se dopo l'applicazione degli sconti e delle business rule per ordine il totale e' inferiore a 0, elimino la componente negativa
					if(totalCartAmount<0){
						totalCartAmount=0.00M;
					}					
					
					if(defCurrency != null && userCurrency != null){
						totalMarginAmount = currrep.convertCurrency(totalMarginAmount, defCurrency.currency, userCurrency.currency);
						totalDiscountAmount = currrep.convertCurrency(totalDiscountAmount, defCurrency.currency, userCurrency.currency);
						totalProductAmount = currrep.convertCurrency(totalProductAmount, defCurrency.currency, userCurrency.currency);
						totalPaymentAmount = currrep.convertCurrency(totalPaymentAmount, defCurrency.currency, userCurrency.currency);
					}	
				}
			}
			catch (Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				bolFoundLista = false;
			}

			if(bolFoundLista && "process".Equals(Request["operation"])){
				FOrder newOrder = new FOrder();
				bool orderCompleted = true;
				int finalOrderId=-1;
				bool externalGateway = false;
				string error_msg ="";
				IList<OrderProduct> ops = new List<OrderProduct>();
				
				try{
					int userId = -1;
					bool noRegistration = true;
					if(!logged){
						if("1".Equals(Request["buy_noreg"])){
							User user = new User();	
							user.id = -1;
							user.username = Math.Abs(Session.SessionID.GetHashCode())+Guids.generateComb();
							user.password = usrrep.getMd5Hash(Session.SessionID);
							user.role=new UserRole((int)UserRole.Roles.GUEST);	
							user.languages = new List<UserLanguage>();	
							user.categories = new List<UserCategory>();	
							user.newsletters = new List<UserNewsletter>();
							user.isActive = false;
							user.isPublicProfile = false;
							user.email = noRegEmail;
							user.discount = 0.00M;	
							user.boComments = "";	
							user.privacyAccept = true;	
							user.hasNewsletter = false;
							user.isAutomaticUser = true;
							user.userGroup = -1;	
							user.fields = new List<UserFieldsMatch>(); 	
							
							UserGroup nug = usrrep.getDefaultUserGroup();
							if(nug != null){
								user.userGroup = nug.id;
							}
							
							user.fields.Clear();
							foreach(string key in Request.Form.Keys){
								if(key.StartsWith("user_field_")){
									string value = Request.Form[key];
									string fieldid = key.Substring(key.LastIndexOf('_')+1);						
									//Response.Write("key:"+key+" -startswith: "+key.StartsWith("user_field_")+" -fieldid: "+ fieldid + " -value:"+value+" -userid:"+user.id+"<br>");
									
									UserFieldsMatch nufm = new UserFieldsMatch();	
									nufm.idParentField=Convert.ToInt32(fieldid);
									nufm.idParentUser = user.id;
									nufm.value = value;
									user.fields.Add(nufm);		
								}							
							}	
							
							usrrep.insert(user);
							userId = user.id;
						}else{
							Response.Redirect("/login.aspx?from=shopcard");
						}
					}else{
						userId = login.userLogged.id;
						noRegistration = false;
					}
					
			
					decimal orderAmount=0.00M;
					decimal orderTaxable=0.00M;
					decimal orderSupplements=0.00M;
					int selectedPayment=-1;
					decimal orderPaymentCommission=0.00M;
					
					IList<OrderProductField> opfs =  new List<OrderProductField>();
					IList<OrderProductAttachmentDownload> opads =  new List<OrderProductAttachmentDownload>();
					IList<OrderFee> ofs =  new List<OrderFee>();
					IList<OrderBusinessRule> obrs =  new List<OrderBusinessRule>();
					IList<OrderVoucher> ovs =  new List<OrderVoucher>();
					int voucherCodeId = -1;
					
					
					//******************* CREO LA LISTA DI PRODOTTI E FIELDS PER ORDINE
					foreach(string key in prodsData.Keys){
						IList<object> pelements = null;
						bool foundpel = prodsData.TryGetValue(key, out pelements);
						decimal price = 0.00M;
						decimal supplement = 0.00M;
						decimal discPerc = 0.00M;
						decimal discount = 0.00M;
						decimal margin = 0.00M;
						string suppdesc = "";
						Product product = null;
						ShoppingCartProduct scp = null;
						IList<ShoppingCartProductField> fscpf = null;
						
						if(foundpel){
							price = Convert.ToDecimal(pelements[0]);
							supplement = Convert.ToDecimal(pelements[2]);
							discPerc = Convert.ToDecimal(pelements[4]);
							product = (Product)pelements[6];
							scp = (ShoppingCartProduct)pelements[7];
							if(pelements[11] != null){
								fscpf = (IList<ShoppingCartProductField>)pelements[11];
							}
							suppdesc = Convert.ToString(pelements[12]);
							discount = Convert.ToDecimal(pelements[14]);
							margin = Convert.ToDecimal(pelements[15]);
						}
					
						OrderProduct op = new OrderProduct();
						op.idOrder=-1;
						op.idProduct=scp.idProduct;
						op.productCounter=scp.productCounter;
						op.productQuantity=scp.productQuantity;
						op.productType=scp.productType;
						op.productName=scp.productName;
						op.amount=price+supplement;
						op.taxable=price;
						op.supplement=supplement;
						op.discountPerc=discPerc;
						op.discount=discount;
						op.margin=margin;
						op.supplementDesc=suppdesc;	
						op.idAds = scp.idAds;
						ops.Add(op);
						
						if(op.productType==1){
							IList<ProductAttachmentDownload> prodDownFiles = productrep.getProductAttachmentDownloads(op.idProduct);
							if(prodDownFiles != null && prodDownFiles.Count>0){
								foreach(ProductAttachmentDownload pad in prodDownFiles){
									OrderProductAttachmentDownload opad = new OrderProductAttachmentDownload();
									opad.id=-1;
									opad.idOrder=-1;
									opad.idParentProduct=op.idProduct;
									opad.idDownFile=pad.id;
									opad.userId=userId;
									opad.active=false;
									opad.maxDownload=product.maxDownload;
									opad.downloadCounter=0;
									if(product.maxDownloadTime>-1){
										opad.expireDate=DateTime.Now.AddMinutes(Convert.ToDouble(product.maxDownloadTime));
									}
									opads.Add(opad);
								}
							}
						}
						
						if(fscpf != null && fscpf.Count>0){
							foreach(ShoppingCartProductField scpf in fscpf){
								OrderProductField opf = new OrderProductField();
								opf.idOrder=-1;
								opf.idProduct=scpf.idProduct;
								opf.productCounter=scpf.productCounter;
								opf.idField=scpf.idField;
								opf.fieldType=scpf.fieldType;
								opf.value=scpf.value;
								opf.productQuantity=scpf.productQuantity;
								opf.description=scpf.description;
								opfs.Add(opf);
							}
						}
						
						orderTaxable+=op.taxable;
						orderSupplements+=op.supplement;
						orderAmount+=op.amount;
					}
			
						
					//*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
					if(hasOrderRule){
						decimal orderRuleAmount = 0.00M;
						foreach(BusinessRule or in businessRules){
							decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, orderAmount, voucherCampaign);
							if(foundAmount!=0){
								orderRuleAmount+=foundAmount;

								OrderBusinessRule obr = new OrderBusinessRule();
								obr.ruleId = or.id;
								obr.ruleType = or.ruleType;
								obr.label = or.label;
								obr.value = foundAmount;
								obrs.Add(obr); 
								
								if(or.ruleType==3 && voucherCode != null){					
									OrderVoucher ov = new OrderVoucher();
									ov.voucherId = voucherCode.campaign;
									ov.voucherCode = voucherCode.code;
									ov.voucherAmount = foundAmount;
									ovs.Add(ov);
									
									voucherCodeId = voucherCode.id;
								}
							}
						}
						orderAmount+=orderRuleAmount;
					}
					
					if(bolHasProdRule){
						foreach(BusinessRuleProductVO brvo in productsVO.Values){
							foreach(int brid in brvo.rulesInfo.Keys){
								IList<object> brval = brvo.rulesInfo[brid];
								int brtype = -1;
								foreach(BusinessRule b in productBusinessRules){
									if(b.id==brid){
										brtype=b.ruleType;
										break;
									}
								}
								
								OrderBusinessRule obr = new OrderBusinessRule();
								obr.ruleId = brid;
								obr.ruleType = brtype;
								obr.value = Convert.ToDecimal(brval[0]);
								obr.label = Convert.ToString(brval[1]);
								obr.productId = brvo.productId;
								obr.productCounter = brvo.productCounter;
								obrs.Add(obr);	
							}
						}
					}					
					
					
					//******************* CREO LA LISTA DI SPESE PER ORDINE
					foreach(int key in billsData.Keys){
						IList<object> belements = null;
						bool foundbel = billsData.TryGetValue(key, out belements);
						decimal billImp = 0.00M;
						decimal billSup = 0.00M;
						Fee f = null;
						bool isChecked = false;
						
						if(foundbel){
							billImp = Convert.ToDecimal(belements[0]);
							billSup = Convert.ToDecimal(belements[1]);
							f = (Fee)belements[3];
							isChecked = Convert.ToBoolean(belements[6]);
						}
						
						if(f.autoactive || isChecked){
							OrderFee of = new OrderFee();
							of.idOrder=-1;
							of.idFee=f.id;	
							of.amount=billImp+billSup;
							of.taxable=billImp;
							of.supplement=billSup;	
							of.feeDesc=f.description;
							ofs.Add(of);
							
							orderTaxable+=of.taxable;
							orderSupplements+=of.supplement;
							orderAmount+=of.amount;							
						}
					}
						
					
					//******************* CREO IL METODO DI PAGAMENTO PER ORDINE
					foreach(int key in paysData.Keys){
						IList<object> pelements = null;
						bool foundpel = paysData.TryGetValue(key, out pelements);
						Payment p = null;
						bool isChecked = false;	
						string pdesc = "";
						
						if(foundpel){
							p = (Payment)pelements[0];
							isChecked = Convert.ToBoolean(pelements[2]);	
							pdesc = p.description;
						}
						
						if(isChecked){
							selectedPayment=p.id;
							orderPaymentCommission=PaymentService.getCommissionAmount(orderAmount, p.commission, p.commissionType);
							orderAmount+=orderPaymentCommission;
							if(p.hasExternalUrl){
								externalGateway = true;
							}
							break;
						}
					}

					
					//******************* CREO LO SHIP E BILLS ADDRESS PER ORDINE
					ShippingAddress userShipaddr = null;	
					OrderShippingAddress orderShipaddr = null;	
					BillsAddress userBillsaddr = null;	
					OrderBillsAddress orderBillsaddr = null;					
					
					if(hasShipAddress){
						userShipaddr = shipaddr;
						userShipaddr.name=Request["ship_name"];
						userShipaddr.surname=Request["ship_surname"];
						userShipaddr.cfiscvat=Request["ship_cfiscvat"];
						userShipaddr.address=Request["ship_address"];
						userShipaddr.city=Request["ship_city"];
						userShipaddr.zipCode=Request["ship_zip_code"];
						userShipaddr.country=Request["ship_country"];
						userShipaddr.stateRegion=Request["ship_state_region"];
						userShipaddr.isCompanyClient=Convert.ToBoolean(Convert.ToInt32(Request["ship_is_company_client"]));
						orderShipaddr = OrderService.shipAddress2OrderShippingAddress(userShipaddr);
					}
					
					if(hasBillsAddress){
						userBillsaddr = billsaddr;
						userBillsaddr.name=Request["bills_name"];							
						userBillsaddr.surname=Request["bills_surname"];			
						userBillsaddr.cfiscvat=Request["bills_cfiscvat"];		
						userBillsaddr.address=Request["bills_address"];			
						userBillsaddr.city=Request["bills_city"];				
						userBillsaddr.zipCode=Request["bills_zip_code"];		
						userBillsaddr.country=Request["bills_country"];			
						userBillsaddr.stateRegion=Request["bills_state_region"];
						orderBillsaddr = OrderService.billsAddress2OrderBillsAddress(userBillsaddr);
					}
					
									
					//*** se il totale e' inferiore a 0, elimino la componente negativa
					if(orderAmount<0){
						orderAmount=0.00M;
						orderTaxable=0.00M;
						orderSupplements=0.00M;
					}
					
					//******************* CREO IL NUOVO ORDINE
					newOrder.id = -1;
					newOrder.userId = userId;
					newOrder.guid=Guids.createOrderGuid();
					newOrder.notes="";
					newOrder.status=1;
					newOrder.amount=orderAmount;
					newOrder.taxable=orderTaxable;
					newOrder.supplement=orderSupplements;
					newOrder.paymentId=selectedPayment;
					newOrder.paymentCommission=orderPaymentCommission;
					newOrder.paymentDone=false;
					newOrder.downloadNotified=false;
					newOrder.noRegistration=noRegistration;
					
					
					//******************* SALVO ORDINE COMPLETO (VERIFICO SE LE QUANTITA DEI PRODOTTI E FIELDS CORRISPONDONO E AGGIORNO LE QUANTITA DI OGNI PRODOTTO E FIELDS)
					orderep.saveCompleteOrder(newOrder, ops, opfs, opads, ofs, userBillsaddr, orderBillsaddr, userShipaddr, orderShipaddr, obrs, ovs, voucherCodeId);
					finalOrderId=newOrder.id;
				}catch(QuantityException ex){
					orderCompleted = false;
					//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					error_msg=HttpUtility.UrlEncode(lang.getTranslated("frontend.carrello.table.label.error_wrong_qta")+"&nbsp;"+Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				}catch(Exception ex){
					orderCompleted = false;
					//Response.Write("Generic error: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					error_msg=lang.getTranslated("frontend.carrello.table.label.error_generic");
				}
				
				
				if(orderCompleted){			
					//******************* COPIO I FILE UPLOADATI DAGLI UTENTI CON IL CARRELLO NELL ORDINE
					OrderService.directoryCopy(HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+shoppingCart.id), HttpContext.Current.Server.MapPath("~/public/upload/files/orders/"+finalOrderId), true, false);
					OrderService.deleteDirectory(HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+shoppingCart.id));
					
					//******************* INVIO MAIL DI PRODOTTO ESAURITO SE NECESSARIO
					foreach(OrderProduct op in ops){
						Product p = productrep.getByIdCached(op.idProduct, true);
						if(p.quantity==0 && p.status==0){
							try{
								UriBuilder mbuilder = new UriBuilder(Request.Url);
								mbuilder.Scheme = "http";
								mbuilder.Port = -1;
								mbuilder.Path="";
								ListDictionary replacements = new ListDictionary();
								StringBuilder message = new StringBuilder();
								
								//start message
								message.Append(lang.getTranslated("backend.prodotti.view.table.label.product_inactive")).Append(":<br/><br/>")
								.Append(lang.getTranslated("backend.prodotti.view.table.label.cod_prod")).Append(":&nbsp;<b>").Append(p.keyword).Append("</b><br/><br/>")
								.Append(lang.getTranslated("backend.prodotti.view.table.label.nome_prod")).Append(":&nbsp;<b>").Append(p.name).Append("</b><br/><br/>")
								.Append(lang.getTranslated("backend.prodotti.detail.table.label.stato_prodotto")).Append(":&nbsp;<b>").Append(lang.getTranslated("backend.product.lista.label.status_inactive")).Append("</b><br/><br/>")
								.Append(lang.getTranslated("backend.prodotti.view.table.label.qta_prod")).Append(":&nbsp;<b>").Append(p.quantity).Append("</b><br/><br/>");									
								
								replacements.Add("<%content%>",Server.HtmlDecode(message.ToString()));
								
								MailService.prepareAndSend("product-unavailable", lang.currentLangCode, lang.defaultLangCode, "backend.mails.detail.table.label.subject_", replacements, null, mbuilder.ToString());								
							}catch(Exception ex){
								Logger log = new Logger();
								log.usr= "system";
								log.msg = "Error send mail for unavailable product : "+p.name+"<br><br>"+ex.Message+"<br><br>"+ex.StackTrace;
								log.type = "error";
								log.date = DateTime.Now;
								lrep.write(log);								
							}
						}
					}
					
					//******************* CANCELLO IL CARRELLO
					shoprep.delete(shoppingCart);

					//***** ripulisco la sessione dal voucher
					Session["voucher_code"] = "";
						
					//******************* GESTIONE CHECKOUT SU GATEWAY ESTERNI IN BASE AL METODO DI PAGAMENTO SELEZIONATO
					if(externalGateway){
						// TODO implementare checkout si gateway esterno
					}else{
						//***** send confirm order email
						bool mailSent = OrderService.sendConfirmOrderMail(finalOrderId, lang.currentLangCode, lang.defaultLangCode, orderMailBuilder.ToString());
						
						Response.Redirect(currentBaseURL+"orderconfirmed.aspx?orderid="+finalOrderId);
					}
				}else{
					string redirectUrl = "";
					UriBuilder delItemBuilder = new UriBuilder(Request.Url);
					if(confservice.get("use_https").value=="1"){	
						delItemBuilder.Scheme = "https";
					}else{
						delItemBuilder.Scheme = "http";
					}
					delItemBuilder.Port = -1;	
					redirectUrl=delItemBuilder.ToString();
					if(String.IsNullOrEmpty(delItemBuilder.Query)){
						redirectUrl+="?";
					}
					redirectUrl+="&hierarchy="+Request["hierarchy"]+"&id_ads="+Request["id_ads"]+"&voucher_code="+Request["voucher_code"]+"&error=1&error_msg="+error_msg;
					Response.Redirect(redirectUrl);
				}
			}			
			
			// init menu frontend
			this.mf1.categoryid = categoryid;
			this.mf2.categoryid = categoryid;
			this.mf5.categoryid = categoryid;
		}else{
			Response.Redirect(errorUrl.Append("034").ToString());
		}
	}
}
