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
using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;

public partial class _Detail : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected Product product;
	protected IList<Geolocalization> points;
	protected int numPage, modelPageNum;
	protected IList<int> matchCategories = null;
	protected IDictionary<string, IList<ProductAttachment>> attachmentsDictionary = null;
	protected IList<ProductAttachmentLabel> attachmentsLabel = null;
	protected IList<ProductField> productFields = null;
	protected ICurrencyRepository currrep;
	protected IProductRepository productrep;
	protected ILanguageRepository langrep;
	protected ICategoryRepository catrep;
	protected ITemplateRepository templrep;
	protected Currency defCurrency;
	protected Currency userCurrency;
	protected IList<Currency> currencyList;
	protected string hierarchy;
	protected string categoryid;
	protected string detailURL = "#";
	protected int orderBy;
	protected string shoppingcardURL = "";
	protected string currentBaseURL = "";

	protected decimal price;
	protected decimal prevprice;
	protected decimal discountperc;
	protected decimal usrdiscountperc;
	protected Supplement prodsup;
	protected string suppdesc;
	protected UserGroup ug;
	
	protected string search_text,checkin,checkout,adultsReq,childsReq,childAgesReq;
	protected int adults,childs,travellers,rooms;
	protected string[] childAgesArr;
	protected IList<ProductCalendarVO> calendarData;
	protected IDictionary<string,string> objListPairKeyValue;
	
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
		login.acceptedRoles = "";
		bool logged = login.checkedUser();
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");	
		langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ISupplementGroupRepository supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");
		IGeolocalizationRepository georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		IMultiLanguageRepository mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
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
		
		StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		string basePath = Request.Path.ToLower();
		string newLangCode = "";

		StringBuilder shoppingcardPath = new StringBuilder();
		shoppingcardPath.Append("public/templates/shopping-cart/checkout.aspx");
		
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
		shoppingcardURL = shoppingcardBuilder.ToString();

		currentBaseURL = new StringBuilder().Append(basePath.Substring(0,basePath.LastIndexOf("/")+1)).ToString();
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
		numPage = 1;
		string status = "1";
		orderBy = 1;
		modelPageNum = 1;
		hierarchy = (string)HttpContext.Current.Items["hierarchy"];
		categoryid = (string)HttpContext.Current.Items["categoryid"];
		attachmentsDictionary = new Dictionary<string, IList<ProductAttachment>>();
		productFields = new List<ProductField>();
		currencyList = new List<Currency>();
		points = new List<Geolocalization>();

		price = 0.00M;
		prevprice = 0.00M;
		discountperc = 0.00M;
		usrdiscountperc = 0.00M;
		ug = null;
		prodsup = null;
		suppdesc = "";
		
		objListPairKeyValue = new Dictionary<string,string>();
		objListPairKeyValue.Add("city","");
		objListPairKeyValue.Add("country","");
		objListPairKeyValue.Add("place_name","");
		calendarData = new List<ProductCalendarVO>();
		
		search_text = "";
		checkin = DateTime.Now.ToString("dd/MM/yyyy");
		checkout = DateTime.Now.AddDays(3).ToString("dd/MM/yyyy");
		adultsReq = "";
		childsReq = "";
		adults = 1;
		childs = 0;
		travellers = 0;
		rooms = 0;
		
		childAgesReq = "";
		childAgesArr=null;
		
		if(!String.IsNullOrEmpty(Request["search_text"]) && !String.IsNullOrEmpty(Request["checkin"]) && !String.IsNullOrEmpty(Request["checkout"]) && !String.IsNullOrEmpty(Request["adults"])){
			search_text  = Request["search_text"];	
			checkin      = Request["checkin"];
			checkout     = Request["checkout"];
			adultsReq    = Request["adults"];
			childsReq    = Request["childs"];
			childAgesReq = Request["childs_age"];
			
			Session["search_text"] = search_text;
			Session["checkin"] = checkin;
			Session["checkout"] = checkout;
			Session["adults"] = adultsReq;
			Session["childs"] = childsReq;
			Session["childs_age"] = childAgesReq;
			
			if(!String.IsNullOrEmpty(adultsReq)){
				adults = Convert.ToInt32(adultsReq);
				travellers+=adults;
			}
			if(!String.IsNullOrEmpty(childsReq)){
				childs = Convert.ToInt32(childsReq);
				travellers+=childs;
				
				//Response.Write("childAgesReq:"+childAgesReq+"<br>");
				if(!String.IsNullOrEmpty(childAgesReq)){
					childAgesArr = childAgesReq.Split(',');
				}
			}			
		}		
		
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
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
			
			try
			{			
				currencyList = currrep.findAll(true);
			}
			catch (Exception ex){
				currencyList = new List<Currency>();
			}
				
			if(!String.IsNullOrEmpty(Request["hierarchy"]))
			{
				hierarchy = Request["hierarchy"];
			}
			if(!String.IsNullOrEmpty(Request["categoryid"]))
			{
				categoryid = Request["categoryid"];
			}
					
			// tento di risolvere la categoria e il template in base ai parametri della request
			if(!String.IsNullOrEmpty(categoryid))
			{
				category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
				hierarchy = category.hierarchy;				
			}
			if(CategoryService.isCategoryNull(category))
			{	
				if(!String.IsNullOrEmpty(hierarchy))
				{
					category = catrep.getByHierarchyCached(hierarchy, true);	
				}			
			}	
			
			if(!CategoryService.isCategoryNull(category)){				
				setMetaCategory(category);
				if(category.idTemplate>0){
					template = templrep.getByIdCached(category.idTemplate,true);
				}
			}
										
			if(template == null)
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
				if(CategoryService.isCategoryNull(category) && template != null)
				{
					category = catrep.getByTemplateCached(template.id, Page.Request.RawUrl.ToString(), true);
					if(!CategoryService.isCategoryNull(category))
					{
						if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
							HttpContext.Current.Items["lang-code"] = newLangCode;
							lang.set();
						}	
						hierarchy = category.hierarchy;					
						setMetaCategory(category); 					
					}
				}
			}
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
							
			// tento il recupero del contenuto tramite id
			if(!String.IsNullOrEmpty(Request["productid"]))
			{
				product = productrep.getByIdCached(Convert.ToInt32(Request["productid"]), true);	
			}			

			// se non trovo nulla tento il recupero dalla categoria
			if(ProductService.isProductNull(product))
			{	
				if (!String.IsNullOrEmpty(lang.currentLangCode)) {
					matchLanguages = new List<int>();
					matchLanguages.Add(langrep.getByLabel(lang.currentLangCode).id);
				}
		
				if (!String.IsNullOrEmpty(Request["product_preview"])) {
					status = null;
				}
					
				if(!String.IsNullOrEmpty(Request["order_by"]))
				{
					orderBy = Convert.ToInt32(Request["order_by"]);	
				}
								
				try
				{			
					IList<Product> products = productrep.find(null, null, status, 0, "3", null, null, null, orderBy, matchCategories, matchLanguages, true, true, true, true, true, true, true);
					
					//Response.Write("products != null:"+ products!=null +"<br>");
					
					if(products != null){								
						foreach(Product c in products){
							product = c;
							break;      
						}					
					}	
				}
				catch (Exception ex){
					//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					throw;
				}
				
			}
		}catch (Exception ex){
			Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			product = null;
		}

		
		if(product != null){
			if(product.fields != null && product.fields.Count>0){	
				IDictionary<string,ProductField> fieldsDict = new Dictionary<string,ProductField>();							
				foreach(ProductField pf in product.fields){
					if(pf.enabled){
						fieldsDict[pf.description] = pf;
					}
				}
				
				foreach(string key in objListPairKeyValue.Keys){
					if(!fieldsDict.ContainsKey(key)){
						product=null;
						break;
					}
				}
				
				//Response.Write("fieldsDict.Count:"+ fieldsDict.Count+"<br>");
				//Response.Write("keepContent:"+ keepContent+"<br>");

				bool keepContent = false;
					
				if(product != null){
					foreach(ProductField subpf in fieldsDict.Values){
						//Response.Write("subpf:"+ subpf.ToString()+"<br>");
						
						if("city".Equals(subpf.description)){	
							string fval = subpf.value;	
							if(!String.IsNullOrEmpty(fval)){
								//Response.Write("city fval:"+ fval+"<br>");
								if(search_text.ToLower().Equals(fval.ToLower())){
									keepContent=true;
									break;
								}
								
								IList<ProductFieldTranslation> lpft = productrep.getProductFieldsTranslationCached(product.id, subpf.id, "value", null, null, true);
								if(lpft != null && lpft.Count>0){
									IList<string> values = new List<string>();
									foreach(ProductFieldTranslation k in lpft){
										//Response.Write("city ml fval:"+ k.value+"<br>");
										values.Add(k.value.ToLower());
									}
									
									if(values.Contains(search_text.ToLower())){
										keepContent=true;
										break;
									}
								}									
							}								
						}else if("country".Equals(subpf.description)){	
							string fval = subpf.value;	
							if(!String.IsNullOrEmpty(fval)){
								if (fval.LastIndexOf('_') > -1){
									fval = fval.Substring(0,fval.LastIndexOf('_'));
								}
								//Response.Write("country fval:"+ fval+"<br>");
								
								IList<MultiLanguage> mlCountries = mlangrep.find("portal.commons.select.option.country."+fval);
								
								if(mlCountries != null && mlCountries.Count>0){
									IList<string> values = new List<string>();
									foreach(MultiLanguage k in mlCountries){
										//Response.Write("country ml fval:"+ k.value+"<br>");
										values.Add(k.value.ToLower());
									}
									
									if(values.Contains(search_text.ToLower())){
										keepContent=true;
										break;
									}
								}									
							}
						}else if("place_name".Equals(subpf.description)){		
							string fval = subpf.value;	
							if(!String.IsNullOrEmpty(fval)){
								//Response.Write("place_name fval:"+ fval+"<br>");
								if(search_text.ToLower().Equals(fval.ToLower())){
									keepContent=true;
									break;
								}
								
								IList<ProductFieldTranslation> lpft = productrep.getProductFieldsTranslationCached(product.id, subpf.id, "value", null, null, true);
								if(lpft != null && lpft.Count>0){
									IList<string> values = new List<string>();
									foreach(ProductFieldTranslation k in lpft){
										//Response.Write("place_name ml fval:"+ k.value+"<br>");
										values.Add(k.value.ToLower());
									}
									
									if(values.Contains(search_text.ToLower())){
										keepContent=true;
										break;
									}
								}									
							}
						}
					}
				}
					
				if(!keepContent){
					product=null;
				}
			}else{
				product=null;
			}		
		}
		

		if(product != null){
			DateTime chkin = DateTime.ParseExact(checkin, "dd/MM/yyyy", null);
			DateTime chkout = DateTime.ParseExact(checkout, "dd/MM/yyyy", null);
			System.TimeSpan diffResult;
			
			int diffDays = Convert.ToInt32(chkout.Subtract(chkin).TotalDays);
			
			//Response.Write("chkin:"+ chkin.ToString()+"<br>");
			//Response.Write("chkout:"+ chkout.ToString()+"<br>");
			//Response.Write("diffDays:"+ diffDays+"<br>");
					
			if(product.calendar != null && product.calendar.Count>0){
				IDictionary<string, ProductCalendar> calD = new Dictionary<string, ProductCalendar>();
				foreach(ProductCalendar p in product.calendar){
					calD.Add(p.startDate.ToString("dd/MM/yyyy"),p);
					//Response.Write(calD[p.startDate.ToString("dd/MM/yyyy")].ToString()+"<br>");
				}
				
				int dayCounter = 0;
				IList<ProductCalendarVO> daysNum = new List<ProductCalendarVO>();
				for(int i=0;i<=diffDays;i++){
					DateTime countD = chkin.AddDays(i);
					//Response.Write("<br>countD:"+ countD.ToString("dd/MM/yyyy")+"<br>");
					
					ProductCalendar p = null;
					//Response.Write("founded: "+countD.ToString("dd/MM/yyyy")+" - "+founded+"<br>");
					if(calD.TryGetValue(countD.ToString("dd/MM/yyyy"), out p)
						 &&
						(
							//(travellers==1 && p.availability>0 && (p.unit-travellers<2)) || // un solo traveller e solo stanze singole o doppie (ad uso singola)
							//(p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) || //c'e almeno un posto e tutti stanno in una sola stanza e al massimo rimane solo un posto vuoto in una stanza
							(p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) //ci sono abbastanza camere per tutti e al massimo rimane solo un posto vuoto in una stanza
						)
					){
						dayCounter++;
						int tmprooms = travellers/p.unit;
						if(travellers%p.unit!=0){
							tmprooms+=1;
						}
						//Response.Write("tmprooms: "+tmprooms+"<br>");									
						daysNum.Add(new ProductCalendarVO(p, tmprooms));
					}
				}
						
				if(dayCounter<(diffDays+1)){
					product=null;
				}else{
					foreach(ProductCalendarVO tpc in daysNum){
						calendarData.Add(tpc);
					}
				}
			}else{
				product=null;
			}
		}		
		
		
		//gestisco attachment
		if(product != null)
		{
			if (!String.IsNullOrEmpty(lang.getTranslated(product.pageTitle))) {
				_pageTitle+= " " + lang.getTranslated(product.pageTitle);
			}else{
				if (!String.IsNullOrEmpty(product.pageTitle)) {
					_pageTitle+= " " + product.pageTitle;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(product.metaDescription))) {
				_metaDescription+= " " + lang.getTranslated(product.metaDescription);
			}else{
				if (!String.IsNullOrEmpty(product.metaDescription)) {
					_metaDescription+= " " + product.metaDescription;
				}
			}
			
			if (!String.IsNullOrEmpty(lang.getTranslated(product.metaKeyword))) {
				_metaKeyword+= " " + lang.getTranslated(product.metaKeyword);
			}else{
				if (!String.IsNullOrEmpty(product.metaKeyword)) {
					_metaKeyword+= " " + product.metaKeyword;
				}
			}
					
			bool langHasSubDomainActive = false;
			string langUrlSubdomain = "";
			Language language = langrep.getByLabel(lang.currentLangCode, true);
			if(!LanguageService.isLanguageNull(language))
			{	
				langHasSubDomainActive = language.subdomainActive;
				langUrlSubdomain = language.urlSubdomain;
			}
												
			cwwc1.elemId = product.id.ToString();
			string cwwc1Link = MenuService.resolvePageHrefUrl(Request.Url.Scheme+"://", modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
			if(cwwc1Link==null){
				cwwc1Link = "#";
			}
			cwwc1.from = cwwc1Link;
			cwwc1.hierarchy = hierarchy;
			cwwc1.categoryId = categoryid;	
			// set comment type
			cwwc1.elemType="2";
			
			cname.Text = productrep.getMainFieldTranslationCached(product.id, 1 , lang.currentLangCode, true,  product.name, true).value;
			csummary.Text = productrep.getMainFieldTranslationCached(product.id, 2 , lang.currentLangCode, true,  product.summary, true).value;
			cdescription.Text = productrep.getMainFieldTranslationCached(product.id, 3 , lang.currentLangCode, true,  product.description, true).value;
			
			if(product.attachments != null)
			{
				foreach(ProductAttachment ca in product.attachments)
				{				
					int label = ca.fileLabel;
					string alabel = "";
					foreach(ProductAttachmentLabel cal in attachmentsLabel)
					{
						if(cal.id==label)
						{
							alabel = cal.description;
							break;
						}
					}
					
					if(attachmentsDictionary.ContainsKey(alabel))
					{
						IList<ProductAttachment> items = null;
						if(attachmentsDictionary.TryGetValue(alabel, out items)){
							items.Add(ca);
							attachmentsDictionary[alabel] = items;
						}
					}
					else
					{
						IList<ProductAttachment> items = new List<ProductAttachment>();
						items.Add(ca);
						attachmentsDictionary[alabel] = items;
					}
				}
			}
			
			// gestisco i field per contenuto
			if(product.fields != null && product.fields.Count>0){
				productFields = product.fields;
			}

			//*************** verifico se esiste la geolocalizzazione per questo elemento
			IList<Geolocalization> tmpPoints = georep.findByElement(product.id, 2);
			if(tmpPoints != null && tmpPoints.Count>0){
				points = tmpPoints;
			}
			
			//********* gestisco il prezzo in base allo sconto,  alla currency e agli altri parametri (gruppo utente, tasse ecc)  *********
			
			string internationalCountryCode = "";
			string internationalStateRegionCode = "";
			bool userIsCompanyClient = false;

			if(logged){
				ug = usrrep.getUserGroup(login.userLogged);
				
				if(login.userLogged.discount != null && login.userLogged.discount >0){
					usrdiscountperc = login.userLogged.discount;
				}
				
				// TODO: recuperare se esiste lo shipping address ed il suo internationalCountryCode
				ShippingAddress shipaddr = shiprep.getByUserIdCached(login.userLogged.id, true);
				if(shipaddr != null){
					internationalCountryCode = shipaddr.country;
					internationalStateRegionCode = shipaddr.stateRegion;
					userIsCompanyClient = shipaddr.isCompanyClient;					
				}
			}
			

			foreach(ProductCalendarVO pc in calendarData){
				ProductCalendarEventData pced = JsonConvert.DeserializeObject<ProductCalendarEventData>(pc.calendar.content);
				string proom = pced.price["room"];
				string padult = pced.price["adult"];
				string childs_0_2 = pced.price["childs_0_2"];
				string childs_3_11 = pced.price["childs_3_11"];
				string childs_12_17 = pced.price["childs_12_17"];
				string pdiscount = pced.price["discount"];
				
				decimal subprice = 0.00M;
				
				decimal proddiscountperc = 0;
				if(!String.IsNullOrEmpty(pdiscount)){
					proddiscountperc = Convert.ToDecimal(pdiscount.Replace(".",","));
				}
				
				
				if(pced.price_type==1){
					decimal pcedadval = 0.00M;
					//Response.Write("padult before: "+padult+"<br>");
					pcedadval = Convert.ToDecimal(padult.Replace(".",","));
					//Response.Write("pcedadval after: "+pcedadval.ToString("###0.00")+"<br>");
					decimal adultPrice = adults*pcedadval;
					decimal childPrice = 0.00M;
					
					//Response.Write("adultPrice: "+adultPrice.ToString("###0.00")+"<br>");
					
					if(childs>0){
						if(childAgesArr.Length==childs){
							foreach(string s in childAgesArr){
								int t = Convert.ToInt32(s);
								if(t>-1&&t<3){
									childPrice+=Convert.ToDecimal(childs_0_2.Replace(".",","));
								}else if(t>2&&t<12){
									childPrice+=Convert.ToDecimal(childs_3_11.Replace(".",","));
								}else if(t>11&&t<18){
									childPrice+=Convert.ToDecimal(childs_12_17.Replace(".",","));
								}
							}
						}else{
							throw new Exception("Error calculating price");
						}
					}					
					
					//********* add the price for the empty bed (if any) as adult
					decimal emptyBedPrice = 0.00M;
					//Response.Write("emptyBedPrice - travellers: "+travellers+"<br>");
					//Response.Write("emptyBedPrice - pc.rooms: "+pc.rooms+"<br>");
					//Response.Write("emptyBedPrice - pc.calendar.unit: "+pc.calendar.unit+"<br>");
					int emptyCheck = (pc.rooms*pc.calendar.unit)-travellers;
					//Response.Write("emptyBedPrice - emptyCheck: "+emptyCheck+"<br>");
					if(emptyCheck>0){
						emptyBedPrice = emptyCheck*pcedadval;
					}
					//Response.Write("emptyBedPrice: "+emptyBedPrice.ToString("###0.00")+"<br>");
					subprice = adultPrice+childPrice+emptyBedPrice;	
					
					//Response.Write("childPrice: "+childPrice.ToString("###0.00")+"<br>");
					prevprice+=subprice;
					//Response.Write("prevprice: "+prevprice.ToString("###0.00")+"<br>");
				}else{
					decimal pcedroomval = Convert.ToDecimal(proom.Replace(".",","));
					subprice = pcedroomval*pc.rooms;
					
					prevprice+=subprice;							
				}
				
				// gestione sconto
				if(ug != null){
					discountperc = ProductService.getDiscountPercentage(ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
					price+= ProductService.getAmount(subprice, ug.margin, ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
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
						}
					}
					
					price+= ProductService.getDiscountedAmount(subprice, discountperc);
				}
				//Response.Write("price: "+price.ToString("###0.00")+"<br>");
				//Response.Write("partial discountperc: "+discountperc.ToString("###0.00")+"<br>");
			}
			
			//Calculate the real discount based on the (real price and original price) with the formula: 100-(price*100/prevprice)
			discountperc=100-(price*100/prevprice);
			//Response.Write("final discountperc: "+discountperc.ToString("###0.00")+"<br>");			
			
			
			// gestione supplements
			if(product.idSupplement != null && product.idSupplement >0){
				prodsup = suprep.getByIdCached(product.idSupplement, true);
			}
			
			if("1".Equals(confservice.get("enable_international_tax_option").value) && !String.IsNullOrEmpty(internationalCountryCode)){
				if(product.idSupplementGroup != null && product.idSupplementGroup >0){
					SupplementGroup psg =  supgrep.getByIdCached(product.idSupplementGroup, true);
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
				price += ProductService.getSupplementAmount(price, prodsup.value, prodsup.type);
				prevprice += ProductService.getSupplementAmount(prevprice, prodsup.value, prodsup.type);
				suppdesc = prodsup.description;
				string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
				if(!String.IsNullOrEmpty(suppdesctrans)){
					suppdesc = suppdesctrans;
				}
				if(!String.IsNullOrEmpty(suppdesc)){
					suppdesc = "&nbsp;("+suppdesc+")";
				}
			}
			
			// assing the real calculated price to manage sorting
			product.price=price;
					
			if(defCurrency != null && userCurrency != null){
				prevprice = currrep.convertCurrency(prevprice, defCurrency.currency, userCurrency.currency);
				price = currrep.convertCurrency(price, defCurrency.currency, userCurrency.currency);
			}			
		}
		
		// init menu frontend
		this.mf1.modelPageNum = this.modelPageNum;
		this.mf1.categoryid = categoryid;	
		this.mf1.hierarchy = hierarchy;	
		this.mf2.modelPageNum = this.modelPageNum;
		this.mf2.categoryid = categoryid;	
		this.mf2.hierarchy = hierarchy;	
		this.mf3.modelPageNum = this.modelPageNum;
		this.mf3.categoryid = categoryid;	
		this.mf3.hierarchy = hierarchy;
		//this.mf4.modelPageNum = this.modelPageNum;
		//this.mf4.categoryid = categoryid;	
		//this.mf4.hierarchy = hierarchy;
		this.mf5.modelPageNum = this.modelPageNum;
		this.mf5.categoryid = categoryid;	
		this.mf5.hierarchy = hierarchy;
	}
	
	private void setMetaCategory(Category category)
	{
		_pageTitle = lang.getTranslated("frontend.page.title");
		_metaDescription = "";
		_metaKeyword = "";
		matchCategories = new List<int>();
		matchCategories.Add(category.id);	
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.pageTitle))) {
			_pageTitle= " " + lang.getTranslated(category.pageTitle);
		}else{
			if (!String.IsNullOrEmpty(category.pageTitle)) {
				_pageTitle= " " + category.pageTitle;
			}
		} 
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaDescription))) {
			_metaDescription+= " " + lang.getTranslated(category.metaDescription);
		}else{
			if (!String.IsNullOrEmpty(category.metaDescription)) {
				_metaDescription+= " " + category.metaDescription;
			}
		}
		
		if (!String.IsNullOrEmpty(lang.getTranslated(category.metaKeyword))) {
			_metaKeyword+= " " + lang.getTranslated(category.metaKeyword);
		}else{
			if (!String.IsNullOrEmpty(category.metaKeyword)) {
				_metaKeyword+= " " + category.metaKeyword;
			}
		} 			
	}
}
