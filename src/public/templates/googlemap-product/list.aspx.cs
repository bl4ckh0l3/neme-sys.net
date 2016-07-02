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

public partial class _List : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected bool bolFoundLista = false;
	protected bool bolHasDetailLink = false;
	protected IList<Product> products;
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
	protected UserGroup ug;
	protected string internationalCountryCode = "";
	protected string internationalStateRegionCode = "";
	protected bool userIsCompanyClient = false;
	protected bool logged;
	protected IDictionary<int, IList<string>> prodsData;
	
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
		shoppingcardURL = shoppingcardBuilder.ToString();

		currentBaseURL = new StringBuilder().Append(basePath.Substring(0,basePath.LastIndexOf("/")+1)).ToString();
		
		Category category = null;
		Template template = null;	
		IList<int> matchLanguages = null;
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
					
					itemsXpage = template.elemXpage;
					orderBy = template.orderBy;
					bool langHasSubDomainActive = false;
					string langUrlSubdomain = "";
					Language language = langrep.getByLabel(lang.currentLangCode, true);	
					
					string currentPath = basePath.Replace("/public/templates/","");
					currentPath = currentPath.Replace(lang.currentLangCode+"/","");
					//Response.Write("language:"+language.ToString()+"<br>");
					foreach(TemplatePage tp in template.pages){
						if(tp.priority>0){
							string templatePath = tp.filePath+tp.fileName;
							string urlRewritePath = tp.urlRewrite;
							//Response.Write("templatePath:"+templatePath+" -urlRewritePath:"+urlRewritePath+"<br>");
							if(currentPath == templatePath || currentPath == urlRewritePath){
								modelPageNum = tp.priority;
								//Response.Write("modelPageNum:"+modelPageNum+"<br>"
								
								if(language != null)
								{	
									langHasSubDomainActive = language.subdomainActive;
									langUrlSubdomain = language.urlSubdomain;
								}								
								
								detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum+1, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
								//Response.Write("detailURL:"+detailURL+"<br>");	
								bolHasDetailLink = true;
								break;
							}
						}
					}
				}
			}	
			
			// if category still null try to resolve category by url
			if(CategoryService.isCategoryNull(category))
			{
				template = TemplateService.resolveTemplateByVirtualPath(basePath, out newLangCode);
				if(template != null)
				{
					itemsXpage = template.elemXpage;
					orderBy = template.orderBy;
					category = catrep.getByTemplateCached(template.id, true);
					if(!CategoryService.isCategoryNull(category))
					{
						if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
							HttpContext.Current.Items["lang-code"] = newLangCode;
							lang.set();
						}	
						hierarchy = category.hierarchy;					
						setMetaCategory(category); 
						bool langHasSubDomainActive = false;
						string langUrlSubdomain = "";
						Language language = langrep.getByLabel(lang.currentLangCode, true);
						if(!LanguageService.isLanguageNull(language))
						{	
							langHasSubDomainActive = language.subdomainActive;
							langUrlSubdomain = language.urlSubdomain;
						}								
						
						detailURL = MenuService.resolvePageHrefUrl(builder.ToString(), modelPageNum+1, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
						//Response.Write("2 detailURL:"+detailURL+"<br>");	
						bolHasDetailLink = true;						
					}
				}
			}
			if(!CategoryService.isCategoryNull(category))
			{
				categoryid = category.id.ToString();
			}
		}catch (Exception ex){
			Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			bolHasDetailLink = false;
		}
	
		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
		}
	
		if(!String.IsNullOrEmpty(Request["order_by"])){
			orderBy = Convert.ToInt32(Request["order_by"]);	
		}
						
		try
		{			
			products = productrep.find(null, null, status, 0, "0,1", null, null, null, orderBy, matchCategories, matchLanguages, true, true, true, true, true, true);
			
			if(products != null && products.Count>0){				
				bolFoundLista = true;	
				
				foreach(Product c in products){				
					decimal discountperc = 0.00M;
					decimal price = c.price;
					decimal prevprice = price;
					Supplement prodsup = null;	
					string suppdesc = "";
					
					decimal proddiscountperc = 0;
					if(c.discount != null && c.discount >0){
						proddiscountperc = c.discount;
					}
					
					// gestione sconto
					if(ug != null){
						discountperc = ProductService.getDiscountPercentage(ug.discount, proddiscountperc, usrdiscountperc, ug.applyProdDiscount, ug.applyUserDiscount);
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
						
						price = ProductService.getDiscountedAmount(price, discountperc);
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
			}	
		}
		catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
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
