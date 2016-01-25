using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.exception;
using com.nemesys.database.repository;
using com.nemesys.services;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _InsertOrder : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected int orderid;
	protected int orderUserId;
	protected string paymentTypeDesc;
	protected bool paymentDone;
	protected decimal paymentCommissions;
	protected decimal orderAmount;
	protected IList<OrderBusinessRule> orderRules;
	protected IList<OrderBusinessRule> productRules;
	protected string pdone;
	protected string downNotified;
	protected FOrder order;
	protected IList<OrderFee> ofees;
	protected IDictionary<int,string> orderStatus;
	protected User user;
	protected IList<User> users;
	protected bool hasShipAddress;
	protected bool hasBillsAddress;
	protected OrderShippingAddress oshipaddr;
	protected ShippingAddress shipaddr;
	protected OrderBillsAddress obillsaddr;
	protected BillsAddress billsaddr;
	protected string paymentTrans;
	protected UriBuilder builder;
	protected string orderFees;
	protected string orderRulesDesc;
	protected string cssClass;
	protected string orderNotes;
	protected int oStatus;
	protected ConfigurationService confservice;
	protected IProductRepository productrep;
	protected IContentRepository contrep;
	protected IAdsRepository adsrep;
	protected IOrderRepository orderep;	
	protected ISupplementRepository suprep;
	protected ISupplementGroupRepository supgrep;
	protected IShoppingCartRepository shoprep;
	protected ICountryRepository countryrep;
	protected IList<Product> products;
	protected IList<Category> categories;
	protected ShoppingCart shoppingCart;
	protected int cartid;	
	protected bool bolFoundLista = false;
	protected IDictionary<int, IList<object>> orderRulesData;
	protected IDictionary<string, IList<object>> prodsData;
	protected IDictionary<int, IList<object>> billsData;
	protected IDictionary<int, IList<object>> paysData;
	protected IList<FeeStrategyField> Scpf4Bills;
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
	protected int paymentId;
	protected IList<Payment> paymentMethods;
	
	protected UserGroup ug;
	protected string internationalCountryCode = "";
	protected string internationalStateRegionCode = "";
	protected bool userIsCompanyClient = false;
	
	protected string titlef;
	protected string keywordf;
	protected string typef;
	protected int categoryf;
	
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
		cssClass="LO";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		
		IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		IPaymentModuleRepository paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
		IPaymentTransactionRepository paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
		orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
		productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository"); 
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");
		countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
		IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
		confservice = new ConfigurationService();
		
		order = null;
		user = null;
		orderid = -1;
		cartid = -1;
		orderUserId = -1;
		paymentTypeDesc = "";
		paymentDone = false;
		paymentCommissions = 0.00M;
		orderAmount = 0.00M;
		hasShipAddress = false;
		hasBillsAddress = false;
		oshipaddr = null;
		shipaddr = null;
		obillsaddr = null;
		billsaddr = null;
		pdone = "";
		downNotified = "";
		orderRules = null;
		productRules = null;
		orderStatus = OrderService.getOrderStatus();
		paymentTrans = "";
		builder = null;
		orderFees = "";
		orderRulesDesc = "";
		IList<int> matchCategories = null;
		IList<int> matchLanguages = null;
		paymentId = -1;
		paymentMethods = null;
		orderNotes = "";
		oStatus = 1;
		
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
		
		titlef = "";
		keywordf = "";
		categoryf = 0;
		typef = "0,1";
		
		builder = new UriBuilder(Request.Url);
		builder.Scheme = "http";
		builder.Port = -1;
		builder.Path="";
		builder.Query="";
		
		StringBuilder errorUrl = new StringBuilder("/backoffice/include/error.aspx?error_code=");

		UriBuilder orderMailBuilder = new UriBuilder(Request.Url);
		orderMailBuilder.Scheme = "http";
		orderMailBuilder.Port = -1;
		orderMailBuilder.Path="";
		orderMailBuilder.Query="";
		
		if (!String.IsNullOrEmpty(Request["titlef"])) {
			titlef = Request["titlef"];
		}

		if (!String.IsNullOrEmpty(Request["typef"])) {
			typef = Request["typef"];
		}else{
			typef = "0,1";
		}
		
		if (!String.IsNullOrEmpty(Request["keywordf"])) {
			keywordf = Request["keywordf"];
		}
		
		if (!String.IsNullOrEmpty(Request["categoryf"]) && Request["categoryf"]!="0") {
			categoryf = Convert.ToInt32(Request["categoryf"]);
			matchCategories = new List<int>();
			matchCategories.Add(categoryf);
		}	
			
		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
		}		

		try{				
			users = usrrep.find(null, "3", "true", null, "false", 1, false, false, false, false, false, false);
		}catch (Exception ex){
			users = new List<User>();
		}

		try{			
			categories = catrep.getCategoryList();	
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}		
		
		try{
			products = productrep.find(titlef,keywordf, "1", 0, typef, null, null, null, 1, matchCategories, matchLanguages, false, false, false, true, false, false);
		}catch (Exception ex){
			products = new List<Product>();
		}		
		
		if(!String.IsNullOrEmpty(Request["id"])){
			orderid = Convert.ToInt32(Request["id"]);
		}
		
		try{
			fees = feerep.find(null, -1, "0,2", true);    	
		}catch (Exception ex){
			//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			fees = new List<Fee>();
		}	
		
		//********** VERIFICO SE ESISTE UNA CAMPAGNA VOUCHER ATTIVA E SE E' STATO INSERITO UN VOUCHER E IN TAL CASO CERCO UNA RULE DI TIPO VOUCHER
		
		businessRules = brulerep.find("3", 1);
		if(businessRules != null && businessRules.Count>0){
			activeVoucherCampaign = true;
			//*** recupero il voucher_code dalla request o dalla session
			if(!String.IsNullOrEmpty(Request["voucher_code"])){
				voucher_code = Request["voucher_code"];
			}
				
			if (!String.IsNullOrEmpty(voucher_code)){
				voucherCode = VoucherService.validateVoucherCode(voucher_code, out voucherCampaign);
				if (voucherCode != null){
					hasOrderRule = true;
					if(voucherCampaign.excludeProdRule){
						voucherExcludeProdRule = true;
					}
				}else{
					voucherMessage = lang.getTranslated("portal.commons.voucher.message.error_invalid");
					voucher_code = "";
					hasOrderRule = false;
				}
			}
		}
		//Response.Write("hasOrderRule: "+hasOrderRule+"<br>");	
		
		
		if(orderid>0){
			try{
				order = orderep.getByIdExtended(orderid, true);				
				user = usrrep.getById(order.userId);	
				ug = usrrep.getUserGroup(user);
				
				bool hasOldOrderRule = false;
				
				paymentDone = order.paymentDone;
				paymentCommissions = order.paymentCommission;
				orderAmount = order.amount;
	
				pdone = lang.getTranslated("portal.commons.no");
				if(paymentDone){
					pdone = lang.getTranslated("portal.commons.yes");
				}	
	
				downNotified = lang.getTranslated("portal.commons.no");
				if(order.downloadNotified){
					downNotified = lang.getTranslated("portal.commons.yes");
				}		
				
				paymentId = order.paymentId;
				Payment payment = payrep.getByIdCached(paymentId, false);
				if(payment != null){
					paymentTypeDesc = payment.description;
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+payment.description))){
						paymentTypeDesc = lang.getTranslated("backend.payment.description.label."+payment.description);
					}
				}
	
				//****** MANAGE ORDER FEES			
				ofees = orderep.findFeesByOrderId(orderid);
				
				oshipaddr = orderep.getOrderShippingAddressCached(orderid, true);
				if(oshipaddr != null){
					hasShipAddress = true;
					shipaddr = OrderService.OrderShipAddress2ShippingAddress(oshipaddr);
					
					internationalCountryCode = oshipaddr.country;
					internationalStateRegionCode = oshipaddr.stateRegion;
					userIsCompanyClient = oshipaddr.isCompanyClient;
				}
				
				obillsaddr = orderep.getOrderBillsAddressCached(orderid, true);
				if(obillsaddr != null){
					hasBillsAddress = true;
					billsaddr = OrderService.OrderBillsAddress2BillsAddress(obillsaddr);
				}
				
				orderRules = orderep.findOrderBusinessRule(orderid, false);
				if(orderRules != null && orderRules.Count>0){
					hasOldOrderRule = true;
				}else{
					orderRules = new List<OrderBusinessRule>();
				}
				
				productRules = orderep.findOrderBusinessRule(orderid, true);
				if(productRules != null && productRules.Count>0){
					bolHasProdRule = true;
				}
	
				//****** MANAGE PAYMENT TRANSACTION (ONLY FOR ADMIN EMAIL)
				IList<PaymentTransaction> transactions = paytransrep.find(order.id, -1, null, null, false);
				foreach(PaymentTransaction q in transactions){
					paymentTrans+="<strong>ID:</strong> "+q.idTransaction+";&nbsp;";
					paymentTrans+="<strong>STATUS:</strong> "+q.status+";&nbsp;";
					if(q.notified){
						paymentTrans+="<strong>NOTIFIED:</strong> "+lang.getTranslated("backend.commons.no")+";<br/>";
					}else{
						paymentTrans+="<strong>NOTIFIED:</strong> "+lang.getTranslated("backend.commons.yes")+";<br/>";
					}
				}
				
				if(order.products != null && order.products.Count>0){
					if (bolHasProdRule){
						//*** cerco le business rule basate sui prodotti e prodotti correlati
						productBusinessRules = new List<BusinessRule>();
						//productBusinessRules = brulerep.find("6,7,8,9,10", 1);
						
						foreach(OrderBusinessRule obr in productRules){
							BusinessRule b = new BusinessRule();
							b.id=obr.ruleId;
							b.ruleType=obr.ruleType;
							b.label=obr.label;
							productBusinessRules.Add(b);	
						}
						
						if(productBusinessRules.Count>0){
							bolHasProdRule = true;
						}else{
							bolHasProdRule = false;
						}
					}
					
					IDictionary<int,Product> uniqueProducts = new Dictionary<int,Product>();
					
					//*** PREPARE PRODUCT BUSINESS RULES
					foreach(OrderProduct op in order.products.Values){
						if(!uniqueProducts.ContainsKey(op.idProduct)){
							Product c = productrep.getByIdCached(op.idProduct, false);
							uniqueProducts.Add(op.idProduct,c);
							
							BusinessRuleProductVO vo = new BusinessRuleProductVO();
							vo.productId = op.idProduct;
							vo.productCounter = op.productCounter;
							vo.quantity = op.productQuantity;
							vo.price = op.taxable;
							productsVO[op.idProduct] = vo;
						}else{
							productsVO[op.idProduct].quantity+=op.productQuantity;
						}
					}

					//*** CALCULATE PRODUCT BUSINESS RULES
					foreach(OrderProduct op in order.products.Values){
						if(bolHasProdRule){
							foreach(BusinessRule b in productBusinessRules){
								BusinessRuleService.hasStrategyByProduct(b, op.idProduct, productsVO);
							} 
						}	
					}					
					
					foreach(OrderProduct op in order.products.Values){
						Product c = uniqueProducts[op.idProduct];
						
						totalMarginAmount+=op.margin;
						totalDiscountAmount+=op.discount;
						
						IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
						if(opfs != null && opfs.Count>0){
							IList<string> descs = new List<string>();
							if(op.productType==0){
								foreach(OrderProductField opf in opfs){
									// controllo che il ProductField non sia editabile da BO
									//Response.Write("<br>"+scpf.ToString());
									bool isValidField = false;
									foreach(ProductField pf in c.fields){
										//Response.Write("<br>"+pf.ToString());
										if(pf.id==opf.idField){
											if(!pf.editable && (pf.typeContent==3 || pf.typeContent==4)){
												isValidField = true;
												break;
											}
										}
									}
									if(isValidField && !descs.Contains(opf.description)){
										FeeStrategyField fsf = new FeeStrategyField();
										fsf.descField = opf.description;
										fsf.quantity = opf.productQuantity;
										fsf.value = Convert.ToDecimal(opf.value);
										Scpf4Bills.Add(fsf);	
										descs.Add(opf.description);
									}
								}	
							}
						}						
						
						//************ se il prodotto non e' di tipo scaricabile e non ci sono regole di esclusione bills, 
						//************ aggiorno l'imponibile su cui verranno calcolate le spese di spedizione
						if (op.productType==0 && !productsVO[op.idProduct].excludeBills){
							totalAmount4Bills+=op.taxable;
							totalCartQuantity+=op.productQuantity;
							applyBills = true;
						}					
						
						totalCartAmount+=op.amount;
					}
					
					totalProductAmount=totalCartAmount;
				}						
			
				//****** MANAGE ORDER RULES
				//Response.Write("hasOldOrderRule: "+hasOldOrderRule+"<br>");
				if(hasOldOrderRule){
					IList<OrderBusinessRule> toBeRemoved = new List<OrderBusinessRule>();
					foreach(OrderBusinessRule x in orderRules){	
						//Response.Write("OrderBusinessRule: "+x.ToString()+"<br>");
						//Response.Write("voucherCode != null: "+(voucherCode != null)+"<br>");
						bool hasVoucherAmount = false;
						if(x.ruleType==3 && voucherCode != null && hasOrderRule){
							foreach(BusinessRule or in businessRules){
								//Response.Write("BusinessRule: "+or.ToString()+"<br>");
								if(or.ruleType==3){
									decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, totalProductAmount, voucherCampaign);
									if(foundAmount!=0){
										toBeRemoved.Add(x);
										hasVoucherAmount = true;
									}
									break;
								}
							}
						}							
						if(!hasVoucherAmount){
							totalCartAmount+=x.value;
							
							IList<object> ordElements = new List<object>();
							ordElements.Add(x.value);
							ordElements.Add(x.label);	
							
							orderRulesData.Add(x.ruleId, ordElements); 
						}
					}
					
					foreach(OrderBusinessRule r in toBeRemoved){
						orderRules.Remove(r);
					}
					
					if(orderRulesData.Count>0){
						hasOrderRule = true;
					}
				}
				
				//Response.Write("voucherCode != null: "+(voucherCode != null)+"<br>");
				//Response.Write("businessRules != null: "+(businessRules != null)+"<br>");
				if(voucherCode != null && businessRules != null && businessRules.Count>0){
					//Response.Write("businessRules.Count: "+businessRules.Count+"<br>");
					foreach(BusinessRule or in businessRules){
						//Response.Write("BusinessRule: "+or.ToString()+"<br>");
						if(or.ruleType==3){
							decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, totalProductAmount, voucherCampaign);
							//Response.Write("foundAmount: "+foundAmount+"<br>");
							if(foundAmount!=0){
								OrderBusinessRule foundBr = new OrderBusinessRule();
								foundBr.ruleId=or.id;
								foundBr.orderId=order.id;
								foundBr.productId=0;
								foundBr.productCounter=0;
								foundBr.ruleType=or.ruleType;
								foundBr.label=or.label;
								foundBr.value=foundAmount;
									
								IList<object> ordElements = new List<object>();
								ordElements.Add(foundAmount);
								ordElements.Add(or.label);	
								
								orderRulesData.Add(or.id, ordElements); 
								orderRules.Add(foundBr);
								
								totalCartAmount+=foundAmount;
								//Response.Write("foundBr: "+foundBr.ToString()+"<br>");
							}			
							break;
						}
					}
				}
								
				
				orderNotes = order.notes;
				oStatus = order.status;
			}catch(Exception ex){
				StringBuilder builderErr = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builderErr.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);			
			}
		}else{
			//********* NEW ORDER
			if(!String.IsNullOrEmpty(Request["userid"])){
				orderUserId = Convert.ToInt32(Request["userid"]);
				if(orderUserId>0){
					user = usrrep.getById(orderUserId);
				}
			}	
			
			if(user != null){		
				ug = usrrep.getUserGroup(user);
				
				if(user.discount != null && user.discount >0){
					usrdiscountperc = user.discount;
				}
				
				shipaddr = shiprep.getByUserIdCached(user.id, true);
		
				if(shipaddr != null){
					//Response.Write("shipaddr:<br>"+shipaddr.ToString());
					internationalCountryCode = shipaddr.country;
					internationalStateRegionCode = shipaddr.stateRegion;
					userIsCompanyClient = shipaddr.isCompanyClient;	
				}
		
				billsaddr = billsrep.getByUserIdCached(user.id, true);
			}	
			
			if(!String.IsNullOrEmpty(Request["cartid"])){
				cartid = Convert.ToInt32(Request["cartid"]);
				if(cartid>0){
					shoppingCart = shoprep.getByIdExtended(cartid, true);
				}
			}			
							
			//*** verifico se esiste una rule primo ordine e se l'utente ne possiede i requisiti
			if(user != null){
				if (!hasOrderRule){ 
					if(orderep.countByIdUser(user.id)==0){
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
			
			try
			{
				if(shoppingCart != null && shoppingCart.products != null && shoppingCart.products.Count>0){				
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
							Product c = productrep.getByIdCached(scp.idProduct, false);
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
								if(user != null && usrdiscountperc>0){
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
							prodsup = suprep.getByIdCached(c.idSupplement, false);
						}
						
						if("1".Equals(confservice.get("enable_international_tax_option").value) && !String.IsNullOrEmpty(internationalCountryCode)){
							if(c.idSupplementGroup != null && c.idSupplementGroup >0){
								SupplementGroup psg =  supgrep.getByIdCached(c.idSupplementGroup, false);
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
									prodsup = suprep.getByIdCached(idSup, false);
								}
							}
								
							if(ug != null && ug.supplementGroup != null && ug.supplementGroup >0){
								SupplementGroup usg =  supgrep.getByIdCached(ug.supplementGroup, false);
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
									prodsup = suprep.getByIdCached(idSup, false);
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

								IList<object> ordElements = new List<object>();
								ordElements.Add(foundAmount);
								ordElements.Add(or.label);	
								
								orderRulesData.Add(or.id, ordElements);  
							}
						}
					}					
				}
			}
			catch (Exception ex){
				//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				bolFoundLista = false;
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
					string redirectUrl = Request.Url.AbsolutePath+"?";
					redirectUrl+=Request.Url.Query;
					redirectUrl+="&id="+orderid+"&cartid="+cartid+"&voucher_code="+Request["voucher_code"]+"&userid="+orderUserId+"&cssClass="+cssClass+"&titlef="+titlef+"&keywordf="+keywordf+"&typef="+typef+"&categoryf="+categoryf;				
					redirectUrl+="&payment_method="+Request["payment_method"];
					if(fees != null && fees.Count>0){
						foreach(Fee f in fees){
							string billsReq = Request[f.feeGroup];
							if(!String.IsNullOrEmpty(billsReq)){
								redirectUrl+="&"+f.feeGroup+"="+billsReq;
							}							
						}
					}
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
					
					if(shoppingCart==null || cartid==-1){
						DateTime insertDate = DateTime.Now;
						string shopcartcufoff = confservice.get("day_carrello_is_valid").value;
						if(!String.IsNullOrEmpty(shopcartcufoff)){
							insertDate = DateTime.Now.AddDays(-Convert.ToInt32(shopcartcufoff)-1);
						}
		
						shoppingCart = new ShoppingCart();
						shoppingCart.idUser=user.id;
						shoppingCart.lastUpdate = insertDate;
						shoprep.insert4Order(shoppingCart);
						cartid = shoppingCart.id;
					}
					
					executed = ShoppingCartService.addItem(user, cartid, Math.Abs(Session.SessionID.GetHashCode()), null, requestFields, MyFileCollection, idProduct, quantity, maxProdQty, resetQtyByCart, idAds, lang.currentLangCode, lang.defaultLangCode);
				}
				catch(Exception ex)
				{
					//Response.Write("An error occured: " + ex.Message);
					errorUrl.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
					executed = false;
				}
					
				if(executed){
					string redirectUrl = Request.Url.AbsolutePath+"?";
					redirectUrl+=Request.Url.Query;
					redirectUrl+="&id="+orderid+"&cartid="+cartid+"&voucher_code="+Request["voucher_code"]+"&userid="+orderUserId+"&cssClass="+cssClass+"&titlef="+titlef+"&keywordf="+keywordf+"&typef="+typef+"&categoryf="+categoryf;
					redirectUrl+="&payment_method="+Request["payment_method"];		
					if(fees != null && fees.Count>0){
						foreach(Fee f in fees){
							string billsReq = Request[f.feeGroup];
							if(!String.IsNullOrEmpty(billsReq)){
								redirectUrl+="&"+f.feeGroup+"="+billsReq;
							}							
						}
					}
					Response.Redirect(redirectUrl);
				}else{
					Response.Redirect(errorUrl.ToString());
				}			
			}			
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

			
		if(shipaddr == null){
				shipaddr = new ShippingAddress();
				shipaddr.id=-1;
		}
		
		if(billsaddr == null){
				billsaddr = new BillsAddress();
				billsaddr.id=-1;
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
					
		//******************** GESTIONE SPESE ACCESSORIE
		if(orderid>0 && paymentDone){
			/*
			TODO: da completare 
			
			if(ofees != null && ofees.Count>0){
				isChecked = false;
				foreach(OrderFee of in ofees){
					if(of.idFee==f.id){
						isChecked = true;
						break;
					}
				}
			}*/			
		}else if((orderid<0 || !paymentDone) && applyBills && fees != null && fees.Count>0){
			foreach(Fee f in fees){
				decimal billImp = 0.00M;
				decimal billSup = 0.00M;
				Supplement feesup = null;
				
				billImp = FeeService.getTaxableAmountByStrategy(f, totalAmount4Bills, totalCartQuantity, Scpf4Bills);
				
				// gestione supplements
				if(f.idSupplement != null && f.idSupplement >0){
					feesup = suprep.getByIdCached(f.idSupplement, false);
				}
				
				if("1".Equals(confservice.get("enable_international_tax_option").value) && !String.IsNullOrEmpty(internationalCountryCode)){
					if(f.supplementGroup != null && f.supplementGroup >0){
						SupplementGroup psg =  supgrep.getByIdCached(f.supplementGroup, false);
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
							feesup = suprep.getByIdCached(idSup, false);
						}
					}
						
					if(ug != null && ug.supplementGroup != null && ug.supplementGroup >0){
						SupplementGroup usg =  supgrep.getByIdCached(ug.supplementGroup, false);
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
							feesup = suprep.getByIdCached(idSup, false);
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
					// verifico se la fee corrente e' in request o associato all'ordine corrente
					string billsReq = Request[f.feeGroup];
					if(!String.IsNullOrEmpty(billsReq)){
						isChecked = false;
						string[] splitBills = billsReq.Split(',');
						foreach(string val in splitBills){
							if(val.Trim().Equals(f.id.ToString())){
								isChecked = true;
								break;
							}
						}
					}else{
						if(ofees != null && ofees.Count>0){
							isChecked = false;
							foreach(OrderFee of in ofees){
								if(of.idFee==f.id){
									isChecked = true;
									break;
								}
							}
						}						
					}
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
				PaymentModule pm = paymodrep.getByIdCached(p.idModule, false);
				if(pm != null){
					logo = pm.icon;
				}
				
				// verifico se la fee corrente e' in request
				string payReq = Request["payment_method"];
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
				}else{
					if(paymentId>-1){
						isChecked = false;
						if(paymentId==p.id){
							isChecked = true;
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
			totalCartAmount=0.00M;;
		}
		
		
		//*************************** PROCESS ORDER  ***************************
		
		if("process".Equals(Request["operation"])){
			FOrder newOrder = new FOrder();
			bool isNewOrder = true;
			bool orderCompleted = true;
			int finalOrderId=-1;
			bool externalGateway = false;
			bool orderPagamDone = Convert.ToBoolean(Convert.ToInt32(Request["payment_done"]));
			string error_msg ="";
			IList<OrderProduct> ops = new List<OrderProduct>();
			
			try{
				if(order != null && order.id>-1){
					isNewOrder = false;
					finalOrderId = order.id;;
				}
				
				decimal finalOrderAmount=0.00M;
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
				
				
				if(isNewOrder){
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
						op.idOrder=finalOrderId;
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
									opad.idOrder=finalOrderId;
									opad.idParentProduct=op.idProduct;
									opad.idDownFile=pad.id;
									opad.userId=user.id;
									opad.maxDownload=product.maxDownload;
									opad.downloadCounter=0;
									if(orderPagamDone){
										opad.active=true;
									}else{
										opad.active=false;
									}
									if(orderPagamDone && product.maxDownloadTime>-1){
										opad.expireDate=DateTime.Now.AddMinutes(Convert.ToDouble(product.maxDownloadTime));
									}else{
										opad.expireDate=Convert.ToDateTime("9999-12-31 23:59:59");
									}
									opad.downloadDate = Convert.ToDateTime("9999-12-31 23:59:59");
									opads.Add(opad);
								}
							}
						}
						
						if(fscpf != null && fscpf.Count>0){
							foreach(ShoppingCartProductField scpf in fscpf){
								OrderProductField opf = new OrderProductField();
								opf.idOrder=finalOrderId;
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
						finalOrderAmount+=op.amount;
					}
				}else{
					foreach(OrderProduct op in order.products.Values){
						orderTaxable+=op.taxable;
						orderSupplements+=op.supplement;
						
						if(!order.downloadNotified && op.productType==1){
							
							IList<OrderProductAttachmentDownload> attachments = orderep.getAttachmentDownload(order.id, op.idProduct);
							if(attachments != null && attachments.Count>0){
								Product c = productrep.getByIdCached(op.idProduct, false);
								
								foreach(OrderProductAttachmentDownload d in attachments){	
									if(orderPagamDone){
										d.active=true;
									}
									if(orderPagamDone && c.maxDownloadTime>-1){
										d.expireDate=DateTime.Now.AddMinutes(Convert.ToDouble(c.maxDownloadTime));
									}
									opads.Add(d);
								}
							}
						}						
					}
				}
		
					
				//*******************  SE ESISTONO DELLE RULES PER ORDINE LE APLICO AL TOTALE CARRELLO PRIMA DI PROSEGUIRE CON GLI ALTRI CALCOLI
				//Response.Write("hasOrderRule: "+hasOrderRule+"<br>");
				if(hasOrderRule){
					if(isNewOrder){
						decimal orderRuleAmount = 0.00M;
						decimal tmpFinalOrderAmount = finalOrderAmount;
						foreach(BusinessRule or in businessRules){
							decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, tmpFinalOrderAmount, voucherCampaign);
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
							finalOrderAmount+=orderRuleAmount;
						}
					}else{
						//Response.Write("orderRules != null: "+orderRules != null+"<br>");
						if(orderRules != null && orderRules.Count>0){
							//Response.Write("orderRules.Count: "+orderRules.Count+"<br>");
							decimal tmpFinalOrderAmount = finalOrderAmount;
							foreach(OrderBusinessRule x in orderRules){
								decimal orderRuleAmount = 0.00M;
								//Response.Write("OrderBusinessRule: "+x.ToString()+"<br>");
								if(x.ruleType==3 && voucherCode != null){
									foreach(BusinessRule or in businessRules){
										//Response.Write("BusinessRule: "+or.ToString()+"<br>");
										if(or.ruleType==3){
											decimal foundAmount = BusinessRuleService.getOrderAmountByStrategy(or, tmpFinalOrderAmount, voucherCampaign);
											//Response.Write("foundAmount: "+foundAmount+"- tmpFinalOrderAmount: "+tmpFinalOrderAmount+"<br>");
											if(foundAmount!=0){
												OrderVoucher ov = new OrderVoucher();
												ov.voucherId = voucherCode.campaign;
												ov.voucherCode = voucherCode.code;
												ov.voucherAmount = foundAmount;
												ovs.Add(ov);
												
												voucherCodeId = voucherCode.id;
												
												orderRuleAmount = foundAmount;
												
												x.value = foundAmount;
											}											
											break;
										}
									}
								}else{
									orderRuleAmount = x.value;
								}
								obrs.Add(x);
									
								finalOrderAmount+=orderRuleAmount;
							}
						}						
					}
				}
				
				if(isNewOrder){
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
						of.idOrder=finalOrderId;
						of.idFee=f.id;	
						of.amount=billImp+billSup;
						of.taxable=billImp;
						of.supplement=billSup;	
						of.feeDesc=f.description;
						ofs.Add(of);
						
						orderTaxable+=of.taxable;
						orderSupplements+=of.supplement;
						finalOrderAmount+=of.amount;							
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
						orderPaymentCommission=PaymentService.getCommissionAmount(finalOrderAmount, p.commission, p.commissionType);
						finalOrderAmount+=orderPaymentCommission;
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
				if(finalOrderAmount<0){
					finalOrderAmount=0.00M;
					orderTaxable=0.00M;
					orderSupplements=0.00M;
				}
					
				//******************* CREO IL NUOVO ORDINE
				if(isNewOrder){
					newOrder.id = -1;
					newOrder.userId = user.id;
					newOrder.guid=Guids.createOrderGuid();
					newOrder.notes=Request["order_notes"];
					newOrder.status=Convert.ToInt32(Request["status"]);
					newOrder.amount=finalOrderAmount;
					newOrder.taxable=orderTaxable;
					newOrder.supplement=orderSupplements;
					newOrder.paymentId=selectedPayment;
					newOrder.paymentCommission=orderPaymentCommission;
					newOrder.paymentDone=orderPagamDone;
					newOrder.downloadNotified=false;
					newOrder.noRegistration=false;
					newOrder.mailSent=false;
					newOrder.adsEnabled=false;
				}else{
					newOrder = order;
					newOrder.notes=Request["order_notes"];
					newOrder.status=Convert.ToInt32(Request["status"]);
					newOrder.amount=finalOrderAmount;
					newOrder.taxable=orderTaxable;
					newOrder.supplement=orderSupplements;
					newOrder.paymentId=selectedPayment;
					newOrder.paymentCommission=orderPaymentCommission;
					newOrder.paymentDone=orderPagamDone;				
				}
				
				
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
				if(isNewOrder){
					//******************* COPIO I FILE UPLOADATI DAGLI UTENTI CON IL CARRELLO NELL ORDINE
					OrderService.directoryCopy(HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+shoppingCart.id), HttpContext.Current.Server.MapPath("~/public/upload/files/orders/"+finalOrderId), true, false);
					OrderService.deleteDirectory(HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+shoppingCart.id));
					
					//******************* INVIO MAIL DI PRODOTTO ESAURITO SE NECESSARIO
					foreach(OrderProduct op in ops){
						Product p = productrep.getByIdCached(op.idProduct, false);
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
				}
				
				//******************* CANCELLO IL CARRELLO
				if(shoppingCart != null){
					shoprep.delete(shoppingCart);
				}
				
				//******************* GESTIONE CHECKOUT SU GATEWAY ESTERNI IN BASE AL METODO DI PAGAMENTO SELEZIONATO
				if(externalGateway && !orderPagamDone){
					// TODO implementare checkout si gateway esterno
				}else{
					if(orderPagamDone){
						//***** send confirm order email
						if(!newOrder.mailSent){
							bool mailSent = OrderService.sendConfirmOrderMail(finalOrderId, lang.currentLangCode, lang.defaultLangCode, orderMailBuilder.ToString());
						}
						
						//***** send confirm order email
						if(!newOrder.downloadNotified){
							//***** send download order email
							bool mailDownSent = OrderService.sendDownloadOrderMail(finalOrderId, lang.currentLangCode, lang.defaultLangCode, orderMailBuilder.ToString());
						}
						
						//***** enable ads
						if(!newOrder.adsEnabled){
							bool adsEnabled = OrderService.activateAds(finalOrderId, lang.currentLangCode, lang.defaultLangCode);
						}
					}
						
					Response.Redirect("/backoffice/orders/orderconfirmed.aspx?cssClass=LO&orderid="+finalOrderId);
				}
			}else{
				string redirectUrl = Request.Url.AbsolutePath+"?";
				redirectUrl+=Request.Url.Query;
				redirectUrl+="&id="+orderid+"&cartid="+cartid+"&voucher_code="+Request["voucher_code"]+"&userid="+orderUserId+"&cssClass="+cssClass+"&titlef="+titlef+"&keywordf="+keywordf+"&typef="+typef+"&categoryf="+categoryf+"&error=1&error_msg="+error_msg;				
				redirectUrl+="&payment_method="+Request["payment_method"];
				if(fees != null && fees.Count>0){
					foreach(Fee f in fees){
						string billsReq = Request[f.feeGroup];
						if(!String.IsNullOrEmpty(billsReq)){
							redirectUrl+="&"+f.feeGroup+"="+billsReq;
						}							
					}
				}
				Response.Redirect(redirectUrl);				
			}
		}		
	}
}