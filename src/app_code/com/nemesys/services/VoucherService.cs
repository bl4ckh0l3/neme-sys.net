using System;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Collections;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class VoucherService
	{
		protected static IVoucherRepository vrep = RepositoryFactory.getInstance<IVoucherRepository>("IVoucherRepository");
		protected static ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		protected static IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
	
		public static VoucherCode validateVoucherCode(string code, out VoucherCampaign voucherCampaign)
		{
			VoucherCode voucherCode = null;
			voucherCampaign = null;
			
			VoucherCode vc = vrep.getVoucherCodeByCode(code);
			
			if(vc != null){
				voucherCampaign = vrep.getById(vc.campaign);
				
				int caseSwitch = voucherCampaign.type;
				
				switch (caseSwitch)
				{							
					// 0=one shot
					case 0:
						if(vc.usageCounter==0){
							voucherCode = vc;
						}
						break;
						
					// 1=per x volte
					case 1:
						if(vc.usageCounter<voucherCampaign.maxUsage || voucherCampaign.maxUsage==-1){
							voucherCode = vc;
						}
						break;
					
					// 2=one shot entro il periodo specificato
					case 2:
						bool inTime2 = (DateTime.Compare(DateTime.Now, voucherCampaign.enableDate)>=0 && DateTime.Compare(DateTime.Now, voucherCampaign.expireDate)<=0);
						
						if(vc.usageCounter==0 && inTime2){
							voucherCode = vc;
						}			
						break;
					
					// 3=per x volte entro il periodo specificato
					case 3:
						bool inTime3 = (DateTime.Compare(DateTime.Now, voucherCampaign.enableDate)>=0 && DateTime.Compare(DateTime.Now, voucherCampaign.expireDate)<=0);
						
						if((vc.usageCounter<voucherCampaign.maxUsage || voucherCampaign.maxUsage==-1) && inTime3){
							voucherCode = vc;
						}				
						break;
					
					// 4=gift (come one shot ma con id_utente che ha fatto il regalo associato al voucher)
					case 4:
						if(vc.usageCounter==0 && vc.userId>0){
							voucherCode = vc;
						}			
						break;
					
					default:
						voucherCode = null;
						break;
				}				
			}
						
			return voucherCode;			
		}

		
		public static bool sendVoucherMail(VoucherCampaign campaign, VoucherCode voucher, string refUserName, string email, string langcode, string defLangCode, string url)
		{
			bool mailVoucherSent = false;

			try{		
					ListDictionary replacementsUser = new ListDictionary();
					StringBuilder userMessage = new StringBuilder();
					replacementsUser.Add("mail_receiver",email);
					
					string maxUsage = MultiLanguageService.translate("backend.voucher.label.unlimited", langcode, defLangCode);
					if(campaign.maxUsage>0){
						maxUsage = campaign.maxUsage.ToString();
					}
					
					string aDate = campaign.enableDate.ToString("dd/MM/yyyy HH:mm");
					if("31/12/9999 23:59".Equals(aDate)){
						aDate = "";
					}					

					string eDate = campaign.expireDate.ToString("dd/MM/yyyy HH:mm");
					if("31/12/9999 23:59".Equals(eDate)){
						eDate = "";
					}
				
					//start user message
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.intro", langcode, defLangCode)).Append("<br/><br/>");	
					if(!String.IsNullOrEmpty(refUserName)){
						userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.username_ref", langcode, defLangCode)).Append(":&nbsp;<b>").Append(refUserName).Append("</b><br/><br/>");	
					}
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.voucher_code", langcode, defLangCode)).Append(":&nbsp;<b>").Append(voucher.code).Append("</b><br/><br/>");
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.value", langcode, defLangCode)).Append(":&nbsp;&euro;&nbsp;<b>").Append(campaign.voucherAmount.ToString("#,###0.00")).Append("</b><br/><br/>");	
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.max_usage", langcode, defLangCode)).Append(":&nbsp;<b>").Append(maxUsage).Append("</b><br/><br/>");		
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.enable_date", langcode, defLangCode)).Append(":&nbsp;<b>").Append(aDate).Append("</b><br/><br/>");		
					userMessage.Append(MultiLanguageService.translate("backend.voucher.mail.label.expire_date", langcode, defLangCode)).Append(":&nbsp;<b>").Append(eDate).Append("</b><br/>");						
					
					replacementsUser.Add("<%content%>",HttpUtility.HtmlDecode(userMessage.ToString()));
					
					MailService.prepareAndSend("voucher-confirmed", langcode, defLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, url);
				
					mailVoucherSent = true;	
			}catch(Exception ex){
				StringBuilder builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);
				
				mailVoucherSent = false;
			}
			
			return mailVoucherSent;
		}	
	}
}