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
	}
}