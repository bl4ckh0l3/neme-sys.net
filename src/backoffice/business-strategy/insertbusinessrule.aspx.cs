using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _BusinessRule : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected bool hasVoucherCampaign = false;	
	protected bool hasProducts = false;
	protected IList<Category> categories;		
	protected IList<Language> languages;
	//protected IList<VoucherCampaign> voucherCampaign;
	protected IList<Product> products;
	protected BusinessRule brule;
	protected IList<BusinessRuleConfig> bruleconfigs;
	protected IMultiLanguageRepository mlangrep;
	protected bool showOneTwo = false;
	protected bool showFourFive=false;
	
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
		cssClass="LM";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		
		brule = new BusinessRule();		
		brule.id = -1;
		bruleconfigs = new List<BusinessRuleConfig>();
		//voucherCampaign = null;
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		IList<BusinessRule> brules = new List<BusinessRule>();
		IDictionary<int, int> orderRulesMap = new Dictionary<int, int>();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				brule = brulerep.getById(Convert.ToInt32(Request["id"]));
				bruleconfigs = brulerep.findBusinessRuleConfig(Convert.ToInt32(Request["id"]),-1);
			}catch (Exception ex){
				brule = new BusinessRule();		
				brule.id = -1;
				bruleconfigs = new List<BusinessRuleConfig>();
			}	
		}
		
		try{
			//voucherCampaign = voucherrep.findCampaign();
			//if(voucherCampaign != null && voucherCampaign.Count>0){
				//hasVoucherCampaign = true;
			//}
		}catch (Exception ex){
			hasVoucherCampaign = false;
		}
		
		try{
			products = prodrep.find("","","",-1,"","",null,null,-1,null,null,false,false,true,false,false,false);
			if(products != null && products.Count>0){
				hasProducts = true;
			}
		}catch (Exception ex){
			hasProducts = false;
		}		
		try{				
			categories = catrep.findActive();
			if(categories == null){				
				categories = new List<Category>();						
			}
		}catch (Exception ex){
			categories = new List<Category>();
		}
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		
		try{			
			brules = brulerep.find("1,2,4,5", 1);	
			if(brules == null){				
				brules = new List<BusinessRule>();
				orderRulesMap = new Dictionary<int, int>();
			}
			foreach(BusinessRule br in brules){
				orderRulesMap[br.ruleType] = br.id;
			}
		}catch (Exception ex){
			brules = new List<BusinessRule>();
			orderRulesMap = new Dictionary<int, int>();
		}

		if(!orderRulesMap.ContainsKey(1) && !orderRulesMap.ContainsKey(2)){
			showOneTwo = true;
		}
		if(orderRulesMap.ContainsKey(1) && orderRulesMap[1]==brule.id){
			showOneTwo=true;
		}
		if(orderRulesMap.ContainsKey(2) && orderRulesMap[2]==brule.id){
			showOneTwo=true;
		}

		if(!orderRulesMap.ContainsKey(4) && !orderRulesMap.ContainsKey(5)){
			showFourFive = true;
		}
		if(orderRulesMap.ContainsKey(4) && orderRulesMap[4]==brule.id){
			showFourFive=true;
		}
		if(orderRulesMap.ContainsKey(5) && orderRulesMap[5]==brule.id){
			showFourFive=true;
		}
			
		
		//******** INSERISCO NUOVA CURRENCY / MODIFICO ESISTENTE
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;				
			try
			{	
				int type = Convert.ToInt32(Request["rule_type"]);	
				string label = Request["label"];
				string description = Request["description"];
				int voucherId = -1;
				if(!String.IsNullOrEmpty(Request["voucher_id"])){
					voucherId = Convert.ToInt32(Request["voucher_id"]);
				}
				bool active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));
				string rulesStrategyCounter = Request["rules_strategy_counter"];
				
				brule.label = label;
				brule.description = description;
				brule.ruleType = type;
				brule.active = active;
				brule.voucherId = voucherId;
				
				IList<BusinessRuleConfig> saveConfigs = new List<BusinessRuleConfig>();
				
				try{			
					if(!String.IsNullOrEmpty(rulesStrategyCounter)){							
						string[] arrConfigList = rulesStrategyCounter.Split(',');							
						
						foreach (string xConfig in arrConfigList){
							
							int tmpProdId = !String.IsNullOrEmpty(Request["id_prod_orig"+xConfig]) && (type==6 || type==7 || type==8 || type==9 || type==10) ? Convert.ToInt32(Request["id_prod_orig"+xConfig]) : -1;
							decimal tmpRateFrom = !String.IsNullOrEmpty(Request["rate_from"+xConfig]) ? Convert.ToDecimal(Request["rate_from"+xConfig]) : 0;
							decimal tmpRateTo = !String.IsNullOrEmpty(Request["rate_to"+xConfig]) ? Convert.ToDecimal(Request["rate_to"+xConfig]) : 0;
							int tmpProdRefId = !String.IsNullOrEmpty(Request["id_prod_ref"+xConfig]) && (type==6 || type==7 || type==8 || type==9 || type==10) ? Convert.ToInt32(Request["id_prod_ref"+xConfig]) : -1;
							decimal tmpRateRefFrom = !String.IsNullOrEmpty(Request["rate_from_ref"+xConfig]) && (type==8 || type==9) ? Convert.ToDecimal(Request["rate_from_ref"+xConfig]) : 0;
							decimal tmpRateRefTo = !String.IsNullOrEmpty(Request["rate_to_ref"+xConfig]) && (type==8 || type==9) ? Convert.ToDecimal(Request["rate_to_ref"+xConfig]) : 0;
							int tmpOperation = !String.IsNullOrEmpty(Request["operation"+xConfig]) ? Convert.ToInt32(Request["operation"+xConfig]) : 0;
							int tmpApplyTo = !String.IsNullOrEmpty(Request["applyto"+xConfig]) && (type==6 || type==7 || type==8 || type==9 || type==10) ? Convert.ToInt32(Request["applyto"+xConfig]) : 0;
							int tmpApply4Qty = !String.IsNullOrEmpty(Request["apply_4_qta"+xConfig]) && type!=3 && type!=10 && (type==6 || type==7 || type==8 || type==9 || type==10) ? Convert.ToInt32(Request["apply_4_qta"+xConfig]) : 0;
							decimal tmpValue = !String.IsNullOrEmpty(Request["valore"+xConfig]) && type!=3 && type!=10 ? Convert.ToDecimal(Request["valore"+xConfig]) : 0;
												
							BusinessRuleConfig brc = new BusinessRuleConfig();
							brc.id=-1;
							brc.ruleId = brule.id;								
							brc.productId = tmpProdId;
							brc.productRefId = tmpProdRefId;
							brc.rateFrom = tmpRateFrom;
							brc.rateTo = tmpRateTo;
							brc.rateRefFrom = tmpRateRefFrom;
							brc.rateRefTo = tmpRateRefTo;
							brc.operation = tmpOperation;
							brc.applyTo = tmpApplyTo;
							brc.applyToQuantity = tmpApply4Qty;
							brc.value = tmpValue;
							
							saveConfigs.Add(brc);								
						}				
					}
				}catch (Exception ex){
					carryOn = false;
					//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				}						
					
				
				// ************** AGGIUNGO TUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI label				
				IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
				MultiLanguage ml;
				if(languages!=null){
					foreach (Language x in languages){
						//*** insert label
						ml = mlangrep.find("backend.businessrule.label.label."+brule.label, x.label);
						if(ml != null){
							ml.value = Request["label_"+x.label];							
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.businessrule.label.label."+brule.label;
							ml.langCode = x.label;
							ml.value = Request["label_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){					
								newtranslactions.Add(ml);
							}
						}
					}
				}
				try
				{
					brulerep.saveCompleteRule(brule, saveConfigs, newtranslactions, updtranslactions, deltranslactions);

					foreach(MultiLanguage value in updtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in deltranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in newtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}
				}
				catch(Exception ex)
				{
					throw new Exception(ex.Message);					
				}					
			}catch (Exception ex){
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));	
				carryOn = false;
			}
			
			if(carryOn){
				Response.Redirect("/backoffice/business-strategy/strategylist.aspx?showtab=businessrulelist&cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}										
		}
	}
}