using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using NHibernate;
using NHibernate.Criterion;

public partial class _Country : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected int itemsXpage, numPage;
	protected string cssClass;	
	protected IList<Language> languages;
	protected Country country;
	protected IMultiLanguageRepository mlangrep;
	protected IGeolocalizationRepository georep;
	protected int pregeoloc_el_id;
			
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
		cssClass="LCT";		
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		int id = -1;
		ICountryRepository catrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
		country = new Country();		
		country.id = -1;
		pregeoloc_el_id=-1;
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();		
			
		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1"){
			try{
				country = catrep.getById(Convert.ToInt32(Request["id"]));
				pregeoloc_el_id=country.id;
			}catch (Exception ex){
				country = new Country();		
				country.id = -1;
			}			
		}else{			
			pregeoloc_el_id=(int)Guids.createGuidMax18Len(7)*(-1);	
		}
		this.gl1.idElem=pregeoloc_el_id;

		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}	

		//******** INSERISCO NUOVA COUNTRY / MODIFICO ESISTENTE				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;		
			try
			{						
				string countryCode = Request["country_code"];
				string countryDescription = Request["country_description"];
				string stateRegionCode = Request["state_region_code"];	
				string stateRegionDescription = Request["state_region_description"];	
				bool active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));	
				string useFor = Request["use_for"];
				IList<Geolocalization> listOfPoints = new List<Geolocalization>();
				
				country.countryCode = countryCode;
				country.countryDescription = countryDescription;
				country.stateRegionCode = stateRegionCode;
				country.stateRegionDescription = stateRegionDescription;
				country.active = active;
				country.useFor = useFor;
				
				//Response.Write("country:"+country.ToString()+"<br>");

				// ************** AGGIUNGO TUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione, meta_xxx ecc
				
				IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
				IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
				MultiLanguage ml;
				if(languages!=null){
					foreach (Language x in languages){
						//*** insert country_description
						ml = mlangrep.find("portal.commons.select.option.country."+country.countryCode, x.label);
						if(ml != null){
							ml.value = Request["country_description_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "portal.commons.select.option.country."+country.countryCode;
							ml.langCode = x.label;
							ml.value = Request["country_description_"+x.label];			
							if(!String.IsNullOrEmpty(ml.value)){		
								newtranslactions.Add(ml);
							}
						}
						//*** insert state_region_description
						ml = mlangrep.find("portal.commons.select.option.country."+country.stateRegionCode, x.label);
						if(ml != null){
							ml.value = Request["state_region_description_"+x.label];	
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "portal.commons.select.option.country."+country.stateRegionCode;
							ml.langCode = x.label;
							ml.value = Request["state_region_description_"+x.label];
							if(!String.IsNullOrEmpty(ml.value)){					
								newtranslactions.Add(ml);
							}
						}
					}
				}
				
				if(!String.IsNullOrEmpty(Request["pregeoloc_el_id"]) && Convert.ToInt32(Request["pregeoloc_el_id"])!=country.id)
				{
					listOfPoints = georep.findByElement(Convert.ToInt32(Request["pregeoloc_el_id"]), 3);
				}			

				try
				{
					catrep.saveCompleteCountry(country, listOfPoints, newtranslactions, updtranslactions, deltranslactions);					
				
					pregeoloc_el_id=country.id;
					this.gl1.idElem=pregeoloc_el_id;
					
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
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));
				carryOn = false;
			}	
			
			if(carryOn){
				Response.Redirect("/backoffice/countries/countrylist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}								
		}	
	}
}