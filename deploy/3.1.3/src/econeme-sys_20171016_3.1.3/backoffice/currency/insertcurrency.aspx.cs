using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _Currency : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected IList<Language> languages;
	protected Currency currency;
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
		cssClass="LCY";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		ICurrencyRepository currrep = RepositoryFactory.getInstance<ICurrencyRepository>("ICurrencyRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		currency = new Currency();		
		currency.id = -1;
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				currency = currrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				currency = new Currency();		
				currency.id = -1;
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
			
		//******** INSERISCO NUOVA CURRENCY / MODIFICO ESISTENTE
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;				
			try
			{				
				string description = Request["description"];
				decimal rate = Convert.ToDecimal(Request["rate"]);		
				bool active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));	
				bool is_default = Convert.ToBoolean(Request["is_default"]);				
				DateTime refer_date = Convert.ToDateTime(Request["refer_date"]);
				
				currency.currency = description;
				currency.rate = rate;
				currency.active = active;
				currency.isDefault = is_default;
				currency.referDate = refer_date;
				currency.insertDate = DateTime.Now;

				// ************** AGGIUNGO TUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione ecc				
				IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
				MultiLanguage ml;
				if(languages!=null){
					foreach (Language x in languages){
						//*** insert description
						ml = mlangrep.find("backend.currency.keyword.label."+currency.currency, x.label);
						if(ml != null){
							ml.value = Request["description_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.currency.keyword.label."+currency.currency;
							ml.langCode = x.label;
							ml.value = Request["description_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){					
								newtranslactions.Add(ml);
							}
						}
					}
				}

				try
				{
					currrep.saveCompleteCurrency(currency, newtranslactions, updtranslactions, deltranslactions);

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
				Response.Redirect("/backoffice/currency/currencylist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}										
		}
	}
}