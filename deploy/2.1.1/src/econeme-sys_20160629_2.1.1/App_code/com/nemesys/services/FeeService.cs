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
	public class FeeService
	{
		protected static IFeeRepository feerep = RepositoryFactory.getInstance<IFeeRepository>("IFeeRepository");
	
		public static decimal getTaxableAmountByStrategy(Fee fee, decimal taxableAmount4Fee, int quantity, IList<FeeStrategyField> strategyFields)
		{
			decimal taxableAmount = 0;
			
			bool foundFeeConfigs = false;
			IList<FeeConfig> feeConfs = feerep.findFeeConfigsCached(fee.id, -1, true);
			if(feeConfs != null && feeConfs.Count>0){
				foundFeeConfigs = true;
			}
			
			
			int caseSwitch = fee.type;
			switch (caseSwitch)
			{
				// valore fisso
				case 1:
					taxableAmount = fee.amount;
					break;
				
				// imponibile ordine: valore percentuale
				case 2:
					taxableAmount = taxableAmount4Fee/100*fee.amount;
					break;
				
				// range imponibile ordine: valore fisso
				case 3:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							decimal tmpRF = fc.rateFrom;
							decimal tmpRT = fc.rateTo;
							if(taxableAmount4Fee>=tmpRF && taxableAmount4Fee<=tmpRT){
								taxableAmount =fc.value;
								break;
							}								
						}
					}
					break;
					
				// range imponibile ordine: valore percentuale
				case 4:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							decimal tmpRF = fc.rateFrom;
							decimal tmpRT = fc.rateTo;
							if(taxableAmount4Fee>=tmpRF && taxableAmount4Fee<=tmpRT){
								taxableAmount =taxableAmount4Fee/100*fc.value;
								break;
							}								
						}
					}
					break;
				
				// range quantit� ordine: valore fisso
				case 5:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							decimal tmpRF = fc.rateFrom;
							decimal tmpRT = fc.rateTo;
							if(quantity>=tmpRF && quantity<=tmpRT){
								taxableAmount =fc.value;
								break;
							}								
						}
					}					
					break;
				
				// range quantit� ordine incrementale: valore fisso
				case 6:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							int tmpRF = Convert.ToInt32(fc.rateFrom);
							if(tmpRF>quantity){break;}
							int tmpRT = Convert.ToInt32(fc.rateTo);
							if(tmpRT>quantity){tmpRT=quantity;}
							for(int counterR=tmpRF;counterR<=tmpRT;counterR++){
								if(quantity>=tmpRF && quantity<=tmpRT){
									taxableAmount =fc.value;
									break;
								}
								
								int caseOp = fc.operation;
								switch (caseSwitch)
								{
									// sum
									case 1:
										taxableAmount += fc.value;	
										break;
									// substraction
									case 2:
										taxableAmount -= fc.value;	
										break;
								}
							}							
						}
					}					
					break;
				
				// range field prodotto: valore fisso
				case 7:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							string tmpFD = fc.descProdField;
							decimal tmpRF = fc.rateFrom;
							decimal tmpRT = fc.rateTo;
		
							foreach(FeeStrategyField fsf in strategyFields){
								if(tmpFD.Equals(fsf.descField)){
									if(fsf.value>=tmpRF && fsf.value<=tmpRT){
										taxableAmount+=fc.value;
									}
								}
							}
						}	
					}
					break;
				
				// range field prodotto incrementale: valore fisso
				case 8:
					if(foundFeeConfigs){
						foreach(FeeConfig fc in feeConfs){
							string tmpFD = fc.descProdField;
							decimal tmpRF = fc.rateFrom;
							decimal tmpRT = fc.rateTo;
							decimal tmpTotVal = 0.00M;
							bool doNext = true;
		
							foreach(FeeStrategyField fsf in strategyFields){
								if(tmpFD.Equals(fsf.descField)){
									tmpTotVal+=fsf.value*fsf.quantity;
								}
							}
							
							if(tmpRF>tmpTotVal){ doNext = false;}
							if(doNext){
								if(tmpRT>tmpTotVal){ tmpRT=tmpTotVal;}
		
								for(int counterR=Convert.ToInt32(tmpRF);counterR<=Convert.ToInt32(tmpRT);counterR++){
									if(fc.operation==1){
										taxableAmount+=fc.value;
									}else if(fc.operation==2){
										taxableAmount-=fc.value;
									}
								}
							}
						}	
					}					
					break;
				
				default:
					taxableAmount = 0;
					break;
			}			
			
			return taxableAmount;			
		}
		
		public static decimal getSupplementAmount(decimal price, decimal supValue, int supType)
		{
			decimal result = 0.00M;
			
			if(supType==2){
				result = price * (supValue / 100);
			}else{
				result = supValue;
			}
			
			return result;
		}
	}
}