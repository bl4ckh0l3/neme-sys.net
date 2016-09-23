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

public partial class _List : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected bool bolFoundLista = false;
	protected bool bolHasDetailLink = false;
	protected List<Product> products;
	protected IList<Geolocalization> points;	
	protected IProductRepository productrep;
	protected ICurrencyRepository currrep;
	protected ISupplementRepository suprep;
	protected ISupplementGroupRepository supgrep;
	protected Currency defCurrency;
	protected Currency userCurrency;
	protected IList<Currency> currencyList;
	protected int numPage, itemsXpage, orderBy, modelPageNum;
	protected int fromProduct, toProduct;
	protected IList<int> matchCategories = null;
	protected IList<ProductAttachmentLabel> attachmentsLabel = null;
	protected string status;
	protected string hierarchy;
	protected string categoryid;
	protected string detailURL = "#";
	protected string shoppingcardURL = "";
	protected string currentBaseURL = "";
	protected string currentURL = "#";
	protected UserGroup ug;
	protected string internationalCountryCode = "";
	protected string internationalStateRegionCode = "";
	protected bool userIsCompanyClient = false;
	protected bool logged;
	protected IDictionary<int, IList<string>> prodsData;
	protected IDictionary<string,string> objListPairKeyValue;
	protected bool bolHasFilterSearchActive;
	protected string search_text,checkin,checkout,adultsReq,childsReq,childAgesReq;
	protected int adults,childs,travellers;
	protected string[] childAgesArr;
	protected IDictionary<int, IList<ProductCalendar>> calendarData;
	
	private int _totalCPages;	
	public int totalCPages {
		get { return _totalCPages; }
	}
	
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
		logged = login.checkedUser();
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");	
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
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
		products = new List<Product>();
		numPage = 1;
		status = "1";
		itemsXpage = 20;
		orderBy = 1;
		modelPageNum = 1;
		currencyList = new List<Currency>();
		ug = null;
		decimal usrdiscountperc = 0.00M;	
		internationalCountryCode = "";
		internationalStateRegionCode = "";
		userIsCompanyClient = false;
		prodsData = new Dictionary<int, IList<string>>();
		points = new List<Geolocalization>();
		objListPairKeyValue = new Dictionary<string,string>();
		objListPairKeyValue.Add("city","");
		objListPairKeyValue.Add("country","");
		objListPairKeyValue.Add("place_name","");
		bolHasFilterSearchActive = false;
		calendarData = new Dictionary<int, IList<ProductCalendar>>();
		
		search_text = "";
		checkin = DateTime.Now.ToString("dd/MM/yyyy");
		checkout = DateTime.Now.AddDays(3).ToString("dd/MM/yyyy");
		adultsReq = "";
		childsReq = "";
		adults = 1;
		childs = 0;
		travellers = 0;
		childAgesReq = "";
		childAgesArr=null;
		
		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}
		if (!String.IsNullOrEmpty(Request["product_preview"])) {
			status = null;
		}
		
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
				}			
			}

			//Response.Write("category:"+category.ToString()+"<br>");			
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
			
			if(template != null){
				itemsXpage = template.elemXpage;
				orderBy = template.orderBy;
				bool langHasSubDomainActive = false;
				string langUrlSubdomain = "";
				Language language = langrep.getByLabel(lang.currentLangCode, true);
				if(!LanguageService.isLanguageNull(language))
				{	
					langHasSubDomainActive = language.subdomainActive;
					langUrlSubdomain = language.urlSubdomain;
				}								
				
				currentURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
				detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum+1, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
				//Response.Write("2 detailURL:"+detailURL+"<br>");	
				if(currentURL==null){
					currentURL = "#";
				}
				if(detailURL==null){
					detailURL = "#";
				}
				bolHasDetailLink = true;				
			}
			
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolHasDetailLink = false;
		}
	
		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
		}
	
		if(!String.IsNullOrEmpty(Request["order_by"])){
			orderBy = Convert.ToInt32(Request["order_by"]);	
		}
		
		if(!String.IsNullOrEmpty(Request["reset_search"])){
			bolHasFilterSearchActive = false;
			search_text  = null;	
			checkin      = DateTime.Now.ToString("dd/MM/yyyy");
			checkout     = DateTime.Now.AddDays(3).ToString("dd/MM/yyyy");
			adultsReq    = null;
			childsReq    = null;
			childAgesReq = null;
			
			Session["search_text"] = search_text;
			Session["checkin"] = checkin;
			Session["checkout"] = checkout;
			Session["adults"] = adultsReq;
			Session["childs"] = childsReq;
			Session["childs_age"] = childAgesReq;
		}else{
			if(!String.IsNullOrEmpty(Request["search_text"]) && !String.IsNullOrEmpty(Request["checkin"]) && !String.IsNullOrEmpty(Request["checkout"]) && !String.IsNullOrEmpty(Request["adults"])){
				bolHasFilterSearchActive = true;
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
			}
			
			if(!bolHasFilterSearchActive && !String.IsNullOrEmpty((string)Session["search_text"]) && !String.IsNullOrEmpty((string)Session["checkin"]) && !String.IsNullOrEmpty((string)Session["checkout"]) && !String.IsNullOrEmpty((string)Session["adults"])){
				bolHasFilterSearchActive = true;
				search_text  = (string)Session["search_text"];	
				checkin      = (string)Session["checkin"];
				checkout     = (string)Session["checkout"];
				adultsReq    = (string)Session["adults"];
				childsReq    = (string)Session["childs"];		
				childAgesReq = (string)Session["childs_age"];	
			}
			
			
			if(bolHasFilterSearchActive){
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
		}
			
		//Response.Write("bolHasFilterSearchActive:"+ bolHasFilterSearchActive+"<br>");
		
		try
		{	
			IList<Product> searchres = null;
			if(bolHasFilterSearchActive){
				searchres = productrep.find(null, null, status, 0, "3", null, null, null, orderBy, matchCategories, matchLanguages, true, true, true, true, true, true, true);
			}
			
			if(searchres != null && searchres.Count>0){
				products = new List<Product>(searchres);
				
				bool keepContent = true;
				IDictionary<int,Product> keeped = new Dictionary<int,Product>();
				
				foreach(Product p in products){
					keeped.Add(p.id, p);
				}
				
				//Response.Write("products.Count:"+ products.Count+"<br>");
				
				foreach(Product p in products){
					keepContent=true;
					
					if(p.fields != null && p.fields.Count>0){	
						IDictionary<string,ProductField> fieldsDict = new Dictionary<string,ProductField>();							
						foreach(ProductField pf in p.fields){
							if(pf.enabled){
								fieldsDict[pf.description] = pf;
							}
						}
						
						foreach(string key in objListPairKeyValue.Keys){
							if(!fieldsDict.ContainsKey(key)){
								keepContent=false;
								keeped.Remove(p.id);
								break;
							}
						}
						
						//Response.Write("fieldsDict.Count:"+ fieldsDict.Count+"<br>");
						//Response.Write("keepContent:"+ keepContent+"<br>");
						
						if(keepContent){
							keepContent=false;
							
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
										
										IList<ProductFieldTranslation> lpft = productrep.getProductFieldsTranslationCached(p.id, subpf.id, "value", null, null, true);
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
										
										IList<ProductFieldTranslation> lpft = productrep.getProductFieldsTranslationCached(p.id, subpf.id, "value", null, null, true);
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
							keeped.Remove(p.id);
						}
					}else{
						keeped.Remove(p.id);
					}
				}
				

				if(keeped.Count>0 && bolHasFilterSearchActive){
					//Response.Write("keeped.Count:"+ keeped.Count+"<br>");		
					products = new List<Product>(keeped.Values);

					DateTime chkin = DateTime.ParseExact(checkin, "dd/MM/yyyy", null);
					DateTime chkout = DateTime.ParseExact(checkout, "dd/MM/yyyy", null);
					System.TimeSpan diffResult;
					
					int diffDays = Convert.ToInt32(chkout.Subtract(chkin).TotalDays);
					
					//Response.Write("chkin:"+ chkin.ToString()+"<br>");
					//Response.Write("chkout:"+ chkout.ToString()+"<br>");
					//Response.Write("diffDays:"+ diffDays+"<br>");
							
					foreach(Product c in products){	
						if(c.calendar != null && c.calendar.Count>0){
							IDictionary<string, ProductCalendar> calD = new Dictionary<string, ProductCalendar>();
							foreach(ProductCalendar p in c.calendar){
								calD.Add(p.startDate.ToString("dd/MM/yyyy"),p);
								//Response.Write(calD[p.startDate.ToString("dd/MM/yyyy")].ToString()+"<br>");
							}
							
							int dayCounter = 0;
							IList<ProductCalendar> daysNum = new List<ProductCalendar>();
							for(int i=0;i<=diffDays;i++){
								DateTime countD = chkin.AddDays(i);
								//Response.Write("<br>countD:"+ countD.ToString("dd/MM/yyyy")+"<br>");
								
								//TO REMOVE: molto inefficiente come algoritmo di ricerca, non ciclare su ogni elemento calendar di ogni prod
								/*foreach(ProductCalendar p in c.calendar){
									//Response.Write("<br>ProductCalendar:"+ p.ToString()+"<br>");
									//Response.Write("travellers:"+ travellers+"<br>");
									//Response.Write("p.availability*p.unit:"+ (p.availability*p.unit)+"<br>");
									//Response.Write("travellers/p.unit:"+ (travellers/p.unit)+"<br>");
									//Response.Write("travellers%p.unit:"+ (travellers%p.unit)+"<br>");
									//Response.Write("p.unit-(travellers%p.unit):"+ (p.unit-(travellers%p.unit))+"<br>");
									//Response.Write("countD.Date.CompareTo(p.startDate.Date):"+ countD.Date.CompareTo(p.startDate.Date)+"<br>");	
									//Response.Write("travellers==1 && p.availability>0 && (p.unit-travellers<2):"+ (travellers==1 && p.availability>0 && (p.unit-travellers<2))+"<br>");	
									//Response.Write("p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2):"+ (p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2))+"<br>");
									//Response.Write("p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2):"+ (p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2))+"<br>");
									
									if(
										countD.Date.CompareTo(p.startDate.Date)==0 &&
										(
											(travellers==1 && p.availability>0 && (p.unit-travellers<2)) || // un solo traveller e solo stanze singole o doppie (ad uso singola)
											(p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) || //c'e almeno un posto e tutti stanno in una sola stanza e al massimo rimane solo un posto vuoto in una stanza
											(p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) //ci sono abbastanza camere per tutti e al massimo rimane solo un posto vuoto in una stanza
										)
									){
										dayCounter++;
										daysNum.Add(p);
										break;
									}
								}*/	
								
								ProductCalendar p = null;
								//Response.Write("founded: "+countD.ToString("dd/MM/yyyy")+" - "+founded+"<br>");
								if(calD.TryGetValue(countD.ToString("dd/MM/yyyy"), out p)
									 &&
									(
										(travellers==1 && p.availability>0 && (p.unit-travellers<2)) || // un solo traveller e solo stanze singole o doppie (ad uso singola)
										(p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) || //c'e almeno un posto e tutti stanno in una sola stanza e al massimo rimane solo un posto vuoto in una stanza
										(p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) //ci sono abbastanza camere per tutti e al massimo rimane solo un posto vuoto in una stanza
									)
								){
									dayCounter++;
									daysNum.Add(p);
								}
							}
									
							if(dayCounter<(diffDays+1)){
								keeped.Remove(c.id);
							}else{
								calendarData.Add(c.id,daysNum);
							}
						}else{
							keeped.Remove(c.id);
						}
						//Response.Write("calendarData.Count:"+calendarData.Count+"<br>");
					}
					
					// clico per test, da cancellare finito il template
					//foreach (KeyValuePair<int, IList<ProductCalendar>> pair in calendarData)
					//{
					//	Response.Write("key:"+pair.Key+"<br>");
					//	foreach(ProductCalendar pc in pair.Value){
					//		Response.Write(pc.ToString()+"<br>");	
					//	}
					//}	
					
					if(keeped.Count>0){
						bolFoundLista = true;
						products = new List<Product>(keeped.Values);
					}
				}else{		
					bolFoundLista = false;
					products = new List<Product>();
					points = new List<Geolocalization>();
				}				
				
				foreach(Product c in products){	
					Supplement prodsup = null;	
					string suppdesc = "";			
					decimal discountperc = 0.00M;
					//decimal price = c.price;// sostituire con la formula corretta in base al numero e tipo di travellers, con il calcolo in base all'eta e allo sconto del giorno e per i differenti giorni
					decimal price = 0.00M;
					decimal prevprice = 0.00M;
					foreach(ProductCalendar pc in calendarData[c.id]){
						ProductCalendarEventData pced = JsonConvert.DeserializeObject<ProductCalendarEventData>(pc.content);
						string padult = pced.price["adult"];
						string childs_0_2 = pced.price["childs_0_2"];
						string childs_3_11 = pced.price["childs_3_11"];
						string childs_12_17 = pced.price["childs_12_17"];
						string pdiscount = pced.price["discount"];
		
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
						
						//Response.Write("childPrice: "+childPrice.ToString("###0.00")+"<br>");
						prevprice+=adultPrice+childPrice;
						//Response.Write("prevprice: "+prevprice.ToString("###0.00")+"<br>");
						
						decimal proddiscountperc = 0;
						if(!String.IsNullOrEmpty(pdiscount)){
							proddiscountperc = Convert.ToDecimal(pdiscount.Replace(".",","));
						}
						
						// gestione sconto
						if(ug != null){
							discountperc = ProductService.getDiscountPercentage(ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
							price+= ProductService.getAmount(adultPrice+childPrice, ug.margin, ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
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
							
							price+= ProductService.getDiscountedAmount(adultPrice+childPrice, discountperc);
						}
						//Response.Write("price: "+price.ToString("###0.00")+"<br>");
						//Response.Write("partial discountperc: "+discountperc.ToString("###0.00")+"<br>");
					}
					
					//Calculate the real discount based on the (real price and original price) with the formula: 100-(price*100/prevprice)
					discountperc=100-(price*100/prevprice);
					//Response.Write("final discountperc: "+discountperc.ToString("###0.00")+"<br>");
					
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
					c.price=price;
					
					if(defCurrency != null && userCurrency != null){
						prevprice = currrep.convertCurrency(prevprice, defCurrency.currency, userCurrency.currency);
						price = currrep.convertCurrency(price, defCurrency.currency, userCurrency.currency);
					}
					
					
					IList<string> prodElements = new List<string>();
					prodElements.Add(prevprice.ToString("###0.00"));
					prodElements.Add(price.ToString("###0.00"));
					prodElements.Add(discountperc.ToString("###0.##"));
					prodElements.Add(suppdesc);
					
					prodsData.Add(c.id, prodElements);
					
					if (!String.IsNullOrEmpty(lang.getTranslated(c.metaDescription))) {
						_metaDescription+= " " + lang.getTranslated(c.metaDescription);
					}else{
						if (!String.IsNullOrEmpty(c.metaDescription)) {
							_metaDescription+= " " + c.metaDescription;
						}
					}
					
					if (!String.IsNullOrEmpty(lang.getTranslated(c.metaKeyword))) {
						_metaKeyword+= " " + lang.getTranslated(c.metaKeyword);
					}else{
						if (!String.IsNullOrEmpty(c.metaKeyword)) {
							_metaKeyword+= " " + c.metaKeyword;
						}
					} 

					//*************** verifico se esiste la geolocalizzazione per questo elemento
					IList<Geolocalization> tmpPoints = georep.findByElement(c.id, 2);
					if(tmpPoints != null && tmpPoints.Count>0){
						foreach(Geolocalization g in tmpPoints){
							points.Add(g);
						}
					}     
				}
				if(orderBy==11 || orderBy==12){
					products.Sort(
						delegate(Product p1, Product p2)
						{
							if(orderBy==11){
								return p1.price.CompareTo(p2.price);
							}else{
								return p2.price.CompareTo(p1.price);
							}
						}
					);
				}
			}	
		}
		catch (Exception ex){
			Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			products = new List<Product>();
			points = new List<Geolocalization>();
		}

		int iIndex = products.Count;
		fromProduct = ((this.numPage * itemsXpage) - itemsXpage);
		int diff = (iIndex - ((this.numPage * itemsXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toProduct = iIndex - diff;
		
		//Response.Write("<br>iIndex:"+ iIndex +"<br>");
		//Response.Write("diff:"+ diff +"<br>");
		//Response.Write("this.numPage:"+ this.numPage  +"<br>");
		//Response.Write("itemsXpage:"+ itemsXpage +"<br>");
			
		if(itemsXpage>0){_totalCPages = iIndex/itemsXpage;}
		if(_totalCPages < 1) {
			_totalCPages = 1;
		}else if(iIndex % itemsXpage != 0 &&  (_totalCPages * itemsXpage) < iIndex) {
			_totalCPages = _totalCPages +1;	
		}
			
		this.pg1.totalPages = this._totalCPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = this.numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;
		this.pg1.parameters = "items="+itemsXpage;	
		
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
