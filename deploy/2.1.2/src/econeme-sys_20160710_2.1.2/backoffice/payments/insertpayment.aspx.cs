using System;
using System.Data;
using System.Web.UI;
using System.Text;
using System.Text.RegularExpressions;
using com.nemesys.model;
using com.nemesys.database.repository;
using System.Collections;
using System.Collections.Generic;

public partial class _Payment : Page 
{
	public ASP.BoMultiLanguageControl lang;
	public ASP.UserLoginControl login;
	protected string cssClass;	
	protected IList<Language> languages;
	protected IList<PaymentModule> paymentModule;
	protected Payment payment;
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
		cssClass="LPT";	
		login.acceptedRoles = "1,2";
		if(!login.checkedUser()){
			Response.Redirect("~/login.aspx?error_code=002");
		}	
		IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		IPaymentModuleRepository paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
		ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		mlangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");
		payment = new Payment();		
		payment.id = -1;
		payment.fields = new List<IPaymentField>();
		StringBuilder url = new StringBuilder("/error.aspx?error_code=");		
		Logger log = new Logger();
		paymentModule = new List<PaymentModule>();

		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				payment = payrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				payment = new Payment();		
				payment.id = -1;
				payment.fields = new List<IPaymentField>();
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
			paymentModule = paymodrep.find(-1, null, false);	
			if(paymentModule == null){				
				paymentModule = new List<PaymentModule>();						
			}
		}catch (Exception ex){
			paymentModule = new List<PaymentModule>();
		}	
			
		//******** INSERISCO NUOVA CURRENCY / MODIFICO ESISTENTE
		if("insert".Equals(Request["operation"]))
		{
			bool carryOn = true;				
			try
			{				
				string description = Request["description"];
				string paymentData = Request["paymentData"];
				decimal commission = Convert.ToDecimal(Request["commission"]);	
				int commissionType = Convert.ToInt32(Request["commissionType"]);	
				bool isActive = Convert.ToBoolean(Convert.ToInt32(Request["isActive"]));	
				int applyTo = Convert.ToInt32(Request["applyTo"]);	
				int paymentType = Convert.ToInt32(Request["paymentType"]);
				bool hasExternalUrl = Convert.ToBoolean(Convert.ToInt32(Request["hasExternalUrl"]));
				int idModule = Convert.ToInt32(Request["idModule"]);
				
				payment.description = description;
				payment.paymentData = paymentData;
				payment.commission = commission;
				payment.commissionType = commissionType;
				payment.isActive = isActive;
				payment.applyTo = applyTo;
				payment.paymentType = paymentType;
				payment.hasExternalUrl = hasExternalUrl;
				payment.idModule = idModule;

				
				try{		
					IList<IPaymentField> paymentFieldsModule = paymodrep.getPaymentModuleFields(payment.idModule, null, null, null);
					if(paymentFieldsModule != null && paymentFieldsModule.Count>0 && payment.hasExternalUrl){	
						payment.fields.Clear();						
						foreach(IPaymentField pfm in paymentFieldsModule)
						{
							IPaymentField fd = new PaymentField();
							fd.idModule = pfm.idModule;
							fd.keyword = pfm.keyword;
							fd.value = Request["fieldname_"+pfm.keyword];
							fd.matchField = pfm.matchField;
							payment.fields.Add(fd);
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
						ml = mlangrep.find("backend.payment.description.label."+payment.description, x.label);
						if(ml != null){
							ml.value = Request["description_"+x.label];							
							if(!String.IsNullOrEmpty(ml.value)){
								updtranslactions.Add(ml);
							}else{
								deltranslactions.Add(ml);									
							}
						}else{
							ml = new MultiLanguage();
							ml.keyword = "backend.payment.description.label."+payment.description;
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
					payrep.saveCompletePayment(payment, newtranslactions, updtranslactions, deltranslactions);

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
				Response.Redirect("/backoffice/payments/paymentlist.aspx?cssClass="+Request["cssClass"]);
			}else{
				Response.Redirect(url.ToString());
			}										
		}
	}
}