using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.services;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;

public partial class _UserField : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected bool bolFoundLista = false;	
	protected string cssClass;
	protected IList<Language> languages;
	protected IUserRepository usrrep;	
	protected IMultiLanguageRepository mlangrep;
	protected UserField field;
	protected IList<UserFieldsValue> fieldValues;
	protected IList<string> fieldGroupNames;
	protected IList<SystemFieldsType> systemFieldsType;
	protected IList<SystemFieldsTypeContent> systemFieldsTypeContent;
	protected string country_opt_text;
	protected string state_region_opt_text;
	
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
		cssClass="LCE";	
		login.acceptedRoles = "1";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		ConfigurationService confservice = new ConfigurationService();

		field = new UserField();	
		field.id = -1;
		fieldGroupNames = new List<string>();
		systemFieldsType = new List<SystemFieldsType>();
		systemFieldsTypeContent = new List<SystemFieldsTypeContent>();	
		fieldValues = new List<UserFieldsValue>();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();

		// recupero elementi della pagina necessari
		country_opt_text = "country";
		state_region_opt_text = "state/region";		
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.country"))){
			country_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.country");
		}
		if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.user_field.type_content.label.state_region"))){
			state_region_opt_text = lang.getTranslated("portal.commons.user_field.type_content.label.state_region");
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
			fieldGroupNames = usrrep.findFieldGroupNames();		
			if(fieldGroupNames == null){				
				fieldGroupNames = new List<string>();						
			}
		}catch (Exception ex){
			fieldGroupNames = new List<string>();
		}
		try{				
			systemFieldsType = commonrep.getSystemFieldsType();		
			if(systemFieldsType == null){				
				systemFieldsType = new List<SystemFieldsType>();						
			}
		}catch (Exception ex){
			systemFieldsType = new List<SystemFieldsType>();
		}
		try{				
			systemFieldsTypeContent = commonrep.getSystemFieldsTypeContent();		
			if(systemFieldsTypeContent == null){				
				systemFieldsTypeContent = new List<SystemFieldsTypeContent>();						
			}
		}catch (Exception ex){
			systemFieldsTypeContent = new List<SystemFieldsTypeContent>();
		}

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{	
			try{
				field = usrrep.getUserFieldById(Convert.ToInt32(Request["id"]));
				fieldValues = usrrep.getUserFieldValues(field.id);
			}catch (Exception ex){
				field = new UserField();		
				field.id = -1;	
				fieldValues = new List<UserFieldsValue>();
			}	
		}
				
		//******** INSERISCO NUOVO UTENTE / MODIFICO ESISTENTE				
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;	
			try
			{
				field.description = Request["description"];

				// verify field non already exists
				if((field.id==-1 || (field.id!=-1 && field.description != Request["description"])) && usrrep.userFieldAlreadyExists(field.description))
				{				
					url.Append("042");
					carryOn = false;						
				}				

				if(carryOn)
				{				
					field.groupDescription = Request["id_group"];
					field.type = Convert.ToInt32(Request["id_type"]);
					field.typeContent = Convert.ToInt32(Request["id_type_content"]);
					int tmpsort = 0;
					if(!String.IsNullOrEmpty(Request["sorting"])){tmpsort = Convert.ToInt32(Request["sorting"]);}
					field.sorting = tmpsort;
					bool tmpreq = false;
					if(!String.IsNullOrEmpty(Request["required"])){tmpreq = Convert.ToBoolean(Convert.ToInt32(Request["required"]));}
					field.required = tmpreq;
					bool tmpenabled = false;
					if(!String.IsNullOrEmpty(Request["enabled"])){tmpenabled = Convert.ToBoolean(Convert.ToInt32(Request["enabled"]));}
					field.enabled = tmpenabled;
					int tmpmlen = -1;
					if(!String.IsNullOrEmpty(Request["max_lenght"])){tmpmlen = Convert.ToInt32(Request["max_lenght"]);}
					field.maxLenght = tmpmlen;
					int tmpufor = 1;
					if(!String.IsNullOrEmpty(Request["use_for"])){tmpufor = Convert.ToInt32(Request["use_for"]);}
					field.useFor = tmpufor;	
					
					// PREPARO LE LISTE DI CHIAVI MULTILINGUA DA INSERIRE/AGGIORNARE IN TRANSAZIONE
					IList<MultiLanguage> newtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> updtranslactions = new List<MultiLanguage>();
					IList<MultiLanguage> deltranslactions = new List<MultiLanguage>();
					MultiLanguage ml;
					if(languages!=null){
						foreach (Language x in languages){
							//*** insert description
							ml = mlangrep.find("backend.utenti.detail.table.label.description_"+field.description, x.label);
							if(ml != null){
								ml.value = Request["description_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.utenti.detail.table.label.description_"+field.description;
								ml.langCode = x.label;
								ml.value = Request["description_"+x.label];
								if(!String.IsNullOrEmpty(ml.value)){					
									newtranslactions.Add(ml);
								}
							}
							//*** insert group description
							ml = mlangrep.find("backend.utenti.detail.table.label.id_group_"+field.groupDescription, x.label);
							if(ml != null){
								ml.value = Request["id_group_"+x.label];	
								if(!String.IsNullOrEmpty(ml.value)){
									updtranslactions.Add(ml);
								}else{
									deltranslactions.Add(ml);									
								}
							}else{
								ml = new MultiLanguage();
								ml.keyword = "backend.utenti.detail.table.label.id_group_"+field.groupDescription;
								ml.langCode = x.label;
								ml.value = Request["id_group_"+x.label];
								if(!String.IsNullOrEmpty(ml.value)){					
									newtranslactions.Add(ml);
								}
							}							
						}
					}
									
					IList<UserFieldsValue> newFieldValues = new List<UserFieldsValue>();
					
					if((field.type==3 || field.type==4 || field.type==5 || field.type==6) && (field.typeContent != 7) && (field.typeContent != 8))
					{
						if(!String.IsNullOrEmpty(Request["list_user_fields_values"]))
						{
							string[] pfv = Regex.Split(Request["list_user_fields_values"],"##");							
							if(pfv!=null){
								int counter = 1;
								foreach (string item in pfv){
									UserFieldsValue ufv = new UserFieldsValue();
									ufv.idParentField = field.id;
									ufv.value = item;
									ufv.sorting = counter;
									newFieldValues.Add(ufv);
									counter++;
								}						
							}					
						}
						
						if(!String.IsNullOrEmpty(Request["list_user_fields_ml_values"]))
						{
							string[] pfv = Regex.Split(Request["list_user_fields_ml_values"],"##");							
							if(pfv!=null){							
								foreach (string item in pfv){
									string originalValue = "";
									string currValue = "";
									string langV = "";
									string[] pfv2 = item.Split('|');
									if(pfv2!=null){
										originalValue = pfv2[0];
										string[] pfv3 = pfv2[1].Split('=');
										if(pfv3!=null){
											langV = pfv3[0];
											currValue = pfv3[1];
										}
									}
									
									ml = mlangrep.find("backend.utenti.detail.table.label.field_values_"+field.description+"_"+originalValue, langV);
									if(ml != null){
										ml.value = currValue;	
										if(!String.IsNullOrEmpty(ml.value)){
											updtranslactions.Add(ml);
										}else{
											deltranslactions.Add(ml);									
										}
									}else{
										ml = new MultiLanguage();
										ml.keyword = "backend.utenti.detail.table.label.field_values_"+field.description+"_"+originalValue;
										ml.langCode = langV;
										ml.value = currValue;
										if(!String.IsNullOrEmpty(ml.value)){					
											newtranslactions.Add(ml);
										}
									}
								}						
							}							
						}
					}
					
					try
					{
						usrrep.saveCompleteUserField(field, newFieldValues, newtranslactions, updtranslactions, deltranslactions);
			
						foreach(MultiLanguage value in updtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in deltranslactions){
							MultiLanguageRepository.cleanCache(value);
						}		
						foreach(MultiLanguage value in newtranslactions){
							MultiLanguageRepository.cleanCache(value);
						}
						
						log.usr= login.userLogged.username;
						log.msg = "save user field: "+field.ToString();
						log.type = "info";
						log.date = DateTime.Now;
						lrep.write(log);
					}
					catch(Exception ex)
					{
						throw;					
					}										
				}	
			}
			catch (Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;
			}		
			
			if(carryOn){
				Response.Redirect("/backoffice/users/userlist.aspx?showtab=usrfield&cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}								
		}
	}
}