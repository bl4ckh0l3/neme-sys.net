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
				
				try{			
					/*
					fee.configs.Clear();	
					
					if(fee.type>2){
						if(!String.IsNullOrEmpty(rulesStrategyCounter)){							
							string[] arrFieldList = rulesStrategyCounter.Split(',');							
							
							foreach (string xField in arrFieldList){
								string tmpDescProdField = !String.IsNullOrEmpty(Request["id_prod_field"+xField]) ? Request["id_prod_field"+xField] : "";
								int tmpOperation = !String.IsNullOrEmpty(Request["operation"+xField]) ? Convert.ToInt32(Request["operation"+xField]) : 0;
								
								if(fee.type !=7 && fee.type !=8){
									tmpDescProdField = "";
								}
								if(fee.type !=6 && fee.type !=8){
									tmpOperation = -1;
								}
								
								FeeConfig fct = new FeeConfig();
								fct.id=-1;
								fct.idFee = fee.id;								
								fct.rateFrom=!String.IsNullOrEmpty(Request["rate_from"+xField]) ? Convert.ToDecimal(Request["rate_from"+xField]) : -1;
								fct.rateTo=!String.IsNullOrEmpty(Request["rate_to"+xField]) ? Convert.ToDecimal(Request["rate_to"+xField]) : -1;
								fct.value=!String.IsNullOrEmpty(Request["valore"+xField]) ? Convert.ToDecimal(Request["valore"+xField]) : -1;									
								fct.descProdField=tmpDescProdField;
								fct.operation=tmpOperation;		
								
								fee.configs.Add(fct);								
							}				
						}	
					}					
					*/
				}catch (Exception ex){}						
					
				
				// ************** AGGIUNGO TUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione ecc				
				/*
				IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
				MultiLanguage ml;
				if(languages!=null){
					foreach (Language x in languages){
						//*** insert description
						ml = mlangrep.find("backend.fee.description.label."+fee.description, x.label);
						if(ml != null){
							ml.value = Request["description_"+x.label];							
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.fee.description.label."+fee.description;
							ml.langCode = x.label;
							ml.value = Request["description_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){					
								newtranslactions.Add(ml);
							}
						}
						
						//*** insert group
						ml = mlangrep.find("backend.fee.group.label."+fee.feeGroup, x.label);
						if(ml != null){
							ml.value = Request["group_"+x.label];							
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.fee.group.label."+fee.feeGroup;
							ml.langCode = x.label;
							ml.value = Request["group_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){					
								newtranslactions.Add(ml);
							}
						}
					}
				}
				*/
				try
				{
					/*
					feerep.saveCompleteFee(fee, newtranslactions, updtranslactions, deltranslactions);

					foreach(MultiLanguage value in updtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in deltranslactions){
						MultiLanguageRepository.cleanCache(value);
					}		
					foreach(MultiLanguage value in newtranslactions){
						MultiLanguageRepository.cleanCache(value);
					}
					*/
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