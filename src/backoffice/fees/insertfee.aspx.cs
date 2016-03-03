using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _Fee : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected bool bolFoundLista = false;
	protected bool bolFoundSup = false;	
	protected bool bolFoundSupG = false;	
	protected bool bolFoundProdF = false;		
	protected IList<Language> languages;
	protected Fee fee;
	protected IList<Fee> fees;
	protected IList<Supplement> supplements;	
	protected IList<SupplementGroup> supplementGroups;
	protected IList<ProductField> productFields;
	protected IMultiLanguageRepository mlangrep;
	
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
		cssClass="LSP";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");
		ISupplementGroupRepository supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
		IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		
		fee = new Fee();		
		fee.id = -1;
		fee.configs = new List<FeeConfig>();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				fee = feerep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				fee = new Fee();		
				fee.id = -1;
				fee.configs = new List<FeeConfig>();
			}	
		}
					
		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		try{
			fees = feerep.find(null, -1, null, false);
			if(fees != null){				
				bolFoundLista = true;			
			}	    	
		}catch (Exception ex){
			//Response.Write("bolFoundLista Exception:"+ex.Message+"<br>");
			fees = new List<Fee>();
			bolFoundLista = false;
		}
		try{
			supplements = suprep.find(null,-1,false);			
			if(supplements != null && supplements.Count>0){				
				bolFoundSup = true;		
			}			    	
		}catch (Exception ex){
			//Response.Write("bolFoundSup Exception:"+ex.Message+"<br>");
			supplements = new List<Supplement>();
			//Response.Write(ex.Message);
			bolFoundSup = false;
		}		
		try{
			supplementGroups = supgrep.find(null, false);
			if(supplementGroups != null && supplementGroups.Count>0){				
				bolFoundSupG = true;				
			}    	
		}catch (Exception ex){
			//Response.Write("bolFoundSupG Exception:"+ex.Message+"<br>");
			supplementGroups = new List<SupplementGroup>();
			bolFoundSupG = false;
		}		
		try{
			IList<ProductField> productFieldsTmp = prodrep.getProductFields(-1, true, false);
			IList<string> descs = new List<string>();
			//Response.Write("productFieldsTmp.Count: "+productFieldsTmp.Count);
			if(productFieldsTmp != null && productFieldsTmp.Count>0){				
				bolFoundProdF = true;
				productFields = new List<ProductField>();
				foreach(ProductField pft in productFieldsTmp){
					//Response.Write("pft.description: "+pft.description+"<br>");
					if(!descs.Contains(pft.description)){
						if(pft.typeContent==3 || pft.typeContent==4){
							productFields.Add(pft);	
						}
						descs.Add(pft.description);
					}
				}
			}	
		}catch (Exception ex){
			//Response.Write("bolFoundProdF Exception:"+ex.Message+"<br>");
			productFields = new List<ProductField>();
			bolFoundProdF = false;
		}	
		
		//******** INSERISCO NUOVA CURRENCY / MODIFICO ESISTENTE
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;				
			try
			{				
				string description = Request["descrizione"];
				decimal amount = Convert.ToDecimal(Request["valore"]);	
				int type = Convert.ToInt32(Request["tipo_valore"]);	
				int idSupplement = Convert.ToInt32(Request["id_tassa_applicata"]);
				int supplementGroup = Convert.ToInt32(Request["taxs_group"]);
				int applyTo = Convert.ToInt32(Request["apply_to"]);	
				bool autoactive = Convert.ToBoolean(Convert.ToInt32(Request["autoactive"]));
				bool multiply = Convert.ToBoolean(Convert.ToInt32(Request["multiply"]));
				bool required = Convert.ToBoolean(Convert.ToInt32(Request["required"]));
				string feeGroup = Request["group"];
				int typeView = Convert.ToInt32(Request["type_view"]);
				string billsStrategyCounter = Request["bills_strategy_counter"];
				
				fee.description = description;
				fee.amount = amount;
				fee.type = type;
				fee.idSupplement = idSupplement;
				fee.supplementGroup = supplementGroup;
				fee.applyTo = applyTo;
				fee.autoactive = autoactive;
				fee.multiply = multiply;
				fee.required = required;
				fee.feeGroup = feeGroup;
				fee.typeView = typeView;
				
				try{			
					fee.configs.Clear();	
					
					if(fee.type>2){
						if(!String.IsNullOrEmpty(billsStrategyCounter)){							
							string[] arrFieldList = billsStrategyCounter.Split(',');							
							
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
					
				}catch (Exception ex){}						
					
				
				// ************** AGGIUNGO TUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione ecc				
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

				try
				{
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
				Response.Redirect("/backoffice/fees/feelist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}										
		}
	}
}