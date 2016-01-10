using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using System.Runtime.Remoting;
using System.Reflection;
using System.Net.Mail;
using System.Net.Mime;
using System.Net;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using NHibernate;
using NHibernate.Criterion;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using com.nemesys.services;

public partial class _FeAds : Page 
{
	public ASP.MultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected FContent content;
	protected Ads ads;
	protected IList<Product> products;
	protected IDictionary<int, IList<string>> prodsData;
	protected IMultiLanguageRepository mlangrep;
	protected IContentRepository contrep;
	protected IProductRepository productrep;
	protected ICurrencyRepository currrep;
	protected ISupplementRepository suprep;
	protected ISupplementGroupRepository supgrep;
	protected IAdsRepository adsrep;
	protected UriBuilder ubuilder = null;
	protected string shoppingcardURL = "";
	protected Currency defCurrency;
	protected bool bolFoundLista = false;
	protected UserGroup ug;
			
	protected void Page_Init(Object sender, EventArgs e)
	{
	    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
	}

	protected void Page_Load(Object sender, EventArgs e)
	{
		lang.set();
		Response.Charset="UTF-8";
		Session.CodePage  = 65001;	
		cssClass="LN";	
		login.acceptedRoles = "3";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository");
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");	
		currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");
		supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		ConfigurationService confservice = new ConfigurationService();

		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		content = null;
		ads = new Ads();
		ads.id=-1;
		ads.price=0.00M;
		ads.type=0;
		prodsData = new Dictionary<int, IList<string>>();
		IList<int> matchLanguages = null;
		ug = null;
		decimal usrdiscountperc = 0.00M;	
		string internationalCountryCode = "";
		string internationalStateRegionCode = "";
		bool userIsCompanyClient = false;

		ug = usrrep.getUserGroup(login.userLogged);
		
		if(login.userLogged.discount != null && login.userLogged.discount >0){
			usrdiscountperc = login.userLogged.discount;
		}
			
		ShippingAddress shipaddr = shiprep.getByUserIdCached(login.userLogged.id, true);
		if(shipaddr != null){
			internationalCountryCode = shipaddr.country;
			internationalStateRegionCode = shipaddr.stateRegion;
			userIsCompanyClient = shipaddr.isCompanyClient;					
		}
			
		// recupero elementi della pagina necessari
		ubuilder = new UriBuilder(Request.Url);
		ubuilder.Scheme = "http";
		ubuilder.Port = -1;
		ubuilder.Path="";
		ubuilder.Query = "";

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
		
		bool carryOn;
		if(!String.IsNullOrEmpty(Request["contentid"]) && Request["contentid"]!= "-1")
		{
			carryOn = true;	
			try{
				content = contrep.getById(Convert.ToInt32(Request["contentid"]));
				ads = adsrep.getByIdElement(content.id, login.userLogged.id);
				if(ads==null){
					ads = new Ads();
					ads.id=-1;	
					ads.price=0.00M;
					ads.type=0;				
				}
				
				defCurrency = currrep.findDefault();
			}catch (Exception ex){
				carryOn = false;
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
			}	
		}else{
			carryOn = false;
		}
	
		if(!carryOn){
			Response.Redirect(url.ToString());
		}

		try
		{			
			products = productrep.find(null, null, "1", 0, "2", null, null, null, 1, null, null, false, false, false, false, false, true);
			
			if(products != null && products.Count>0){				
				bolFoundLista = true;	
				
				foreach(Product c in products){				
					decimal discountperc = 0.00M;
					decimal price = c.price;
					decimal prevprice = price;
					Supplement prodsup = null;	
					string suppdesc = "";
					string bolSkipPromotion = "0";
					string dateBuyPromotion = "";
					
					decimal proddiscountperc = 0;
					if(c.discount != null && c.discount >0){
						proddiscountperc = c.discount;
					}

					if(ads.promotions != null && ads.promotions.Count>0){
						foreach(AdsPromotion k in ads.promotions){
							if(c.id==k.elementId && k.active){
								bolSkipPromotion = "1";
								dateBuyPromotion = k.insertDate.ToString("dd/MM/yyyy HH:mm");
								break;
							}
						}
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
							if(usrdiscountperc>0){
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
						suppdesc = "&nbsp;("+suppdesc+")";
					}
					
					if(defCurrency != null){
						prevprice = currrep.convertCurrency(prevprice, defCurrency.currency, defCurrency.currency);
						price = currrep.convertCurrency(price, defCurrency.currency, defCurrency.currency);
					}
					
					
					IList<string> prodElements = new List<string>();
					prodElements.Add(prevprice.ToString("###0.00"));
					prodElements.Add(price.ToString("###0.00"));
					prodElements.Add(discountperc.ToString("###0.##"));
					prodElements.Add(suppdesc);
					prodElements.Add(bolSkipPromotion);
					prodElements.Add(dateBuyPromotion);
					
					prodsData.Add(c.id, prodElements);    
				}					
			}	
		}
		catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			products = new List<Product>();
		}
		
		
		//******** INSERISCO NUOVO ADS / MODIFICO ESISTENTE			
		if("insert".Equals(Request["operation"]))
		{	
			carryOn = true;	
			string redirectURL = "/area_user/ads/contentlist.aspx?cssClass="+Request["cssClass"];
			try
			{	
				int adsType = Convert.ToInt32(Request["ads_type"]);
				string phone = Request["phone"];
				decimal price = 0.00M;
				if(!String.IsNullOrEmpty(Request["price"])){
					price = Convert.ToDecimal(Request["price"]);
				}
				
				try
				{
					ads.elementId = content.id;
					ads.type = adsType;
					ads.phone = phone;
					ads.price = price;
					ads.userId=login.userLogged.id;

					IList<AdsPromotion> promotionals = new List<AdsPromotion>();
					
					string currvalue = Request["promotional"];	
					if(!String.IsNullOrEmpty(currvalue)){
						IList<string> values = new List<string>();
						string[] fvalues = currvalue.Split(',');
						if(fvalues != null && fvalues.Length>0){
							if(ads.promotions == null){
								ads.promotions = new List<AdsPromotion>();
							}
							foreach(string fv in fvalues){
								string[] promos = fv.Split('|');
								AdsPromotion p = new AdsPromotion();
								p.adsId = ads.id;
								p.elementId=Convert.ToInt32(promos[0]);
								p.elementCode=promos[1];
								p.active=false;								
								ads.promotions.Add(p);
								
								promotionals.Add(p);
							}
						}
					}	
					
					
					if(ads.id==-1){
						adsrep.insert(ads);
					}else{
						adsrep.update(ads);	
					}
					
					log.usr= login.userLogged.username;
					log.msg = "save ads: "+ads.ToString();
					log.type = "info";
					log.date = DateTime.Now;
					lrep.write(log);	
					
					// if exists promotion will be added to the shopping cart
					if(promotionals != null && promotionals.Count>0){
						string acceptDate = "";
						string shopcartcufoff = confservice.get("day_carrello_is_valid").value;
						if(!String.IsNullOrEmpty(shopcartcufoff)){
							acceptDate = DateTime.Now.AddDays(-Convert.ToInt32(shopcartcufoff)).ToString("dd/MM/yyyy");
						}						
						
						foreach(AdsPromotion k in promotionals){
							/*
							HttpWebRequest request = (HttpWebRequest)WebRequest.Create(shoppingcardURL);
							request.Method = "POST";						

							NameValueCollection outgoingQueryString = HttpUtility.ParseQueryString(String.Empty);
							outgoingQueryString.Add("productid",k.elementId.ToString());
							outgoingQueryString.Add("quantity", "1");
							outgoingQueryString.Add("max_prod_qta", "-1");
							outgoingQueryString.Add("reset_qta", "1");
							string postData = outgoingQueryString.ToString();
							Response.Write("postData: "+postData+"<br>");
							
							byte[] byteArray = Encoding.UTF8.GetBytes (postData);
							request.ContentType = "application/x-www-form-urlencoded";
							request.ContentLength = byteArray.Length;
							Stream dataStream = request.GetRequestStream();
							dataStream.Write (byteArray, 0, byteArray.Length);
							dataStream.Close();
							WebResponse response = request.GetResponse ();
							*/
							
							ShoppingCartService.addItem(login.userLogged, -1, Math.Abs(Session.SessionID.GetHashCode()), acceptDate, null, null, k.elementId, 1, -1, "1", ads.id, lang.currentLangCode, lang.defaultLangCode);
						}
						redirectURL = shoppingcardURL;
					}
					
				}
				catch(Exception ex)
				{
					throw;	
				}		
			}
			catch (Exception ex)
			{
				//Response.Write("An error occured: " + ex.Message);		
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				//Response.Redirect(url.ToString(),false);	
				//HttpContext.Current.ApplicationInstance.CompleteRequest();
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect(redirectURL);
			}else{
				Response.Redirect(url.ToString());
			}								
		}
		
		if("delete".Equals(Request["operation"]))
		{
			carryOn = true;
			try
			{
				adsrep.delete(ads);
				
				log.usr= login.userLogged.username;
				log.msg = "delete ads: "+ads.ToString();
				log.type = "info";
				log.date = DateTime.Now;
				lrep.write(log);	
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
				//Response.Write("An error occured: " + ex.Message);
			}
				
			if(carryOn){
				Response.Redirect("/area_user/ads/contentlist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}		
		}
		
		// init menu frontend
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";				
	}
}