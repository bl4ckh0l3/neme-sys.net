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
	public class BusinessRuleService
	{
		protected static IBusinessRuleRepository brulerep = RepositoryFactory.getInstance<IBusinessRuleRepository>("IBusinessRuleRepository");
	
		public static decimal getOrderAmountByStrategy(BusinessRule rule, decimal orderAmount, VoucherCampaign voucher)
		{
			decimal strategyAmount = 0;
			
			bool foundRuleConfigs = false;
			IList<BusinessRuleConfig> ruleConfs = brulerep.findBusinessRuleConfig(rule.id, -1);
			if(ruleConfs != null && ruleConfs.Count>0){
				foundRuleConfigs = true;
			}
			
			
			int caseSwitch = rule.ruleType;
			switch (caseSwitch)
			{
				// totale ordine: valore fisso
				case 1: case 4:
					if(foundRuleConfigs){
						foreach(BusinessRuleConfig rc in ruleConfs){
							decimal tmpRF = rc.rateFrom;
							decimal tmpRT = rc.rateTo;
							if(orderAmount>=tmpRF && orderAmount<=tmpRT){
								switch (rc.operation)
								{
									case 1:
										strategyAmount+=rc.value;
										break;
									case 2:
										strategyAmount-=rc.value;
										break;
								}
								break;
							}								
						}
					}
					break;
					
				// totale ordine: valore percentuale
				case 2: case 5:
					if(foundRuleConfigs){
						foreach(BusinessRuleConfig rc in ruleConfs){
							decimal tmpRF = rc.rateFrom;
							decimal tmpRT = rc.rateTo;
							if(orderAmount>=tmpRF && orderAmount<=tmpRT){
								switch (rc.operation)
								{
									case 1:
										strategyAmount+=orderAmount/100*rc.value;
										break;
									case 2:
										strategyAmount-=orderAmount/100*rc.value;
										break;
								}
								break;
							}								
						}
					}
					break;
				
				// voucher rule: valore fisso
				case 3:
					if(foundRuleConfigs){
						foreach(BusinessRuleConfig rc in ruleConfs){
							decimal tmpRF = rc.rateFrom;
							decimal tmpRT = rc.rateTo;
							if(orderAmount>=tmpRF && orderAmount<=tmpRT && voucher != null && voucher.id==rule.voucherId){
								switch (voucher.operation)
								{
									case 0:
										strategyAmount-=orderAmount/100*voucher.voucherAmount;
										break;
									case 1:
										strategyAmount-=voucher.voucherAmount;		
										break;						
								}
								break;
							}								
						}
					}				
					break;
				
				default:
					strategyAmount = 0;
					break;
			}			
			
			return strategyAmount;			
		}

	
		public static bool hasStrategyByProduct(BusinessRule rule, int productId, IDictionary<int, BusinessRuleProductVO> productsVO)
		{
			bool hasStrategy = false;
			
			bool foundRuleConfigs = false;
			IList<BusinessRuleConfig> ruleConfs = brulerep.findBusinessRuleConfig(rule.id, productId);
			if(ruleConfs != null && ruleConfs.Count>0){
				foundRuleConfigs = true;
			}
			
			
			int caseSwitch = rule.ruleType;
			switch (caseSwitch)
			{
				// Regola importo fisso su quantità prodotto
				case 6:
					if(foundRuleConfigs){
						bool foundApplied = false;
						BusinessRuleProductVO prule = null;
						if(productsVO.TryGetValue(productId, out prule)){
							if(prule.rulesApplied != null){
								bool founded = false;
								if(prule.rulesApplied.TryGetValue(rule.id, out founded) && founded){
									foundApplied = true;
								}
							}
						}
						
						if(!foundApplied && prule != null){
							int tmpMaxQtadisp = prule.quantity;
							
							foreach(BusinessRuleConfig brc in ruleConfs){
								decimal tmpRF = brc.rateFrom;
								decimal tmpRT = brc.rateTo;
								int tmpApply4Qta = brc.applyToQuantity;
								
								if(tmpApply4Qta>tmpMaxQtadisp){
									tmpApply4Qta = tmpMaxQtadisp;
								}
								
								if(tmpMaxQtadisp>=tmpRF && tmpMaxQtadisp<=tmpRT){
									decimal foundAmount = 0.00M;
									decimal tmpOpValue = brc.value*tmpApply4Qta;
									
									IList<object> infoValues = null;
									bool foundInfoValues = prule.rulesInfo.TryGetValue(rule.id, out infoValues);
									if(!foundInfoValues){
										infoValues = new List<object>();
									}
									
									switch (brc.operation)
									{
										case 1:
											foundAmount+=tmpOpValue;
											infoValues.Add(foundAmount);
											infoValues.Add(rule.label);
											break;
										case 2:
											foundAmount-=tmpOpValue;
											infoValues.Add(foundAmount);
											infoValues.Add(rule.label);
											break;
									}
									
									prule.rulesInfo[rule.id] = infoValues;
									prule.rulesApplied[rule.id] = true;
									productsVO[productId] = prule;
									hasStrategy = true;
									break;
								}
							}
						}
					}
					break;
				
				// Regola importo percentuale su quantità prodotto
				case 7:
					if(foundRuleConfigs){
						bool foundApplied = false;
						BusinessRuleProductVO prule = null;
						if(productsVO.TryGetValue(productId, out prule)){
							if(prule.rulesApplied != null){
								bool founded = false;
								if(prule.rulesApplied.TryGetValue(rule.id, out founded) && founded){
									foundApplied = true;
								}
							}
						}
						
						if(!foundApplied && prule != null){
							int tmpMaxQtadisp = prule.quantity;
							decimal tmpImpProd = prule.price;
							
							foreach(BusinessRuleConfig brc in ruleConfs){
								decimal tmpRF = brc.rateFrom;
								decimal tmpRT = brc.rateTo;
								int tmpApply4Qta = brc.applyToQuantity;
								
								if(tmpApply4Qta>tmpMaxQtadisp){
									tmpApply4Qta = tmpMaxQtadisp;
								}
								
								if(tmpMaxQtadisp>=tmpRF && tmpMaxQtadisp<=tmpRT){
									decimal foundAmount = 0.00M;
									decimal tmpOpValue =tmpImpProd/100*(brc.value*tmpApply4Qta);
									
									IList<object> infoValues = null;
									bool foundInfoValues = prule.rulesInfo.TryGetValue(rule.id, out infoValues);
									if(!foundInfoValues){
										infoValues = new List<object>();
									}
									
									switch (brc.operation)
									{
										case 1:
											foundAmount+=tmpOpValue;
											infoValues.Add(foundAmount);
											infoValues.Add(rule.label);
											break;
										case 2:
											foundAmount-=tmpOpValue;
											infoValues.Add(foundAmount);
											infoValues.Add(rule.label);
											break;
									}
									
									prule.rulesInfo[rule.id] = infoValues;
									prule.rulesApplied[rule.id] = true;
									productsVO[productId] = prule;
									hasStrategy = true;
									break;
								}
							}
						}
					}					
					break;
				
				// Regola importo fisso su prodotto correlato
				case 8:
					if(foundRuleConfigs){
						bool foundApplied = false;
						BusinessRuleProductVO prule = null;
						if(productsVO.TryGetValue(productId, out prule)){
							if(prule.rulesApplied != null){
								bool founded = false;
								if(prule.rulesApplied.TryGetValue(rule.id, out founded) && founded){
									foundApplied = true;
								}
							}
						}
						
						if(!foundApplied && prule != null){
							int tmpMaxQtadisp = prule.quantity;
							decimal tmpImpProd = prule.price;
							
							foreach(BusinessRuleConfig brc in ruleConfs){
								int idProdRef = brc.productRefId;
								
								if(!productsVO.ContainsKey(idProdRef)){
									hasStrategy = false;
									break;
								}
								
								
								int tmpMaxRefQtadisp = productsVO[idProdRef].quantity;
								decimal tmpImpRefProd = productsVO[idProdRef].price;
								decimal tmpRF = brc.rateFrom;
								decimal tmpRT = brc.rateTo;
								decimal tmpRFref = brc.rateRefFrom;
								decimal tmpRTref = brc.rateRefTo;
								int tmpApplyTo = brc.applyTo;
								int tmpApply4Qta = brc.applyToQuantity;
								
								if(tmpMaxQtadisp>=tmpRF && tmpMaxQtadisp<=tmpRT){
									if(tmpMaxRefQtadisp>=tmpRFref && tmpMaxRefQtadisp<=tmpRTref){
										if(tmpApplyTo==1){
											if(tmpApply4Qta>tmpMaxQtadisp){
												tmpApply4Qta = tmpMaxQtadisp;
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue = brc.value*tmpApply4Qta;
											
											IList<object> infoValues = null;
											bool foundInfoValues = prule.rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											prule.rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==2){
											if(tmpApply4Qta>tmpMaxRefQtadisp){
												tmpApply4Qta = tmpMaxRefQtadisp;
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue = brc.value*tmpApply4Qta;
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[idProdRef].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[idProdRef].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==3){
											int tmpIdProdtoUse = -1;
											if(tmpImpProd>tmpImpRefProd){ 
												tmpIdProdtoUse = idProdRef;
												if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4Qta = tmpMaxRefQtadisp;}
											}else{
												tmpIdProdtoUse = productId;
												if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4Qta = tmpMaxQtadisp;}
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue = brc.value*tmpApply4Qta;
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[tmpIdProdtoUse].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[tmpIdProdtoUse].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==4){
											int tmpIdProdtoUse = -1;
											if(tmpImpProd>tmpImpRefProd){ 
												tmpIdProdtoUse = productId;
												if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4Qta = tmpMaxQtadisp;}
											}else{
												tmpIdProdtoUse = idProdRef;
												if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4Qta = tmpMaxRefQtadisp;}
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue = brc.value*tmpApply4Qta;
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[tmpIdProdtoUse].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[tmpIdProdtoUse].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==5){
											int tmpApply4QtaOrig=tmpApply4Qta;
											int tmpApply4QtaRef=tmpApply4Qta;
											if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4QtaOrig = tmpMaxQtadisp;}
											if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4QtaRef = tmpMaxRefQtadisp;}
										
											decimal foundAmountO = 0.00M;
											decimal foundAmountR = 0.00M;
											decimal tmpOpValueO = brc.value*tmpApply4QtaOrig;
											decimal tmpOpValueR = brc.value*tmpApply4QtaRef;
											
											IList<object> infoValuesO = null;
											IList<object> infoValuesR = null;
											bool foundInfoValuesO = prule.rulesInfo.TryGetValue(rule.id, out infoValuesO);
											bool foundInfoValuesR = productsVO[idProdRef].rulesInfo.TryGetValue(rule.id, out infoValuesR);
											if(!foundInfoValuesO){
												infoValuesO = new List<object>();
											}
											if(!foundInfoValuesR){
												infoValuesR = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmountO+=tmpOpValueO;
													infoValuesO.Add(foundAmountO);
													infoValuesO.Add(rule.label);
													foundAmountR+=tmpOpValueR;
													infoValuesR.Add(foundAmountR);
													infoValuesR.Add(rule.label);
													break;
												case 2:
													foundAmountO-=tmpOpValueO;
													infoValuesO.Add(foundAmountO);
													infoValuesO.Add(rule.label);
													foundAmountR-=tmpOpValueR;
													infoValuesR.Add(foundAmountR);
													infoValuesR.Add(rule.label);
													break;
											}
											
											prule.rulesInfo[rule.id] = infoValuesO;
											productsVO[idProdRef].rulesInfo[rule.id] = infoValuesR;
											
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}
									}
								}
							}
						}
					}					
					break;
				
				// Regola importo percentuale su prodotto correlato
				case 9:
					if(foundRuleConfigs){
						bool foundApplied = false;
						BusinessRuleProductVO prule = null;
						if(productsVO.TryGetValue(productId, out prule)){
							if(prule.rulesApplied != null){
								bool founded = false;
								if(prule.rulesApplied.TryGetValue(rule.id, out founded) && founded){
									foundApplied = true;
								}
							}
						}
						
						if(!foundApplied && prule != null){
							int tmpMaxQtadisp = prule.quantity;
							decimal tmpImpProd = prule.price;
							
							foreach(BusinessRuleConfig brc in ruleConfs){
								int idProdRef = brc.productRefId;
								
								if(!productsVO.ContainsKey(idProdRef)){
									hasStrategy = false;
									break;
								}
								
								
								int tmpMaxRefQtadisp = productsVO[idProdRef].quantity;
								decimal tmpImpRefProd = productsVO[idProdRef].price;
								decimal tmpRF = brc.rateFrom;
								decimal tmpRT = brc.rateTo;
								decimal tmpRFref = brc.rateRefFrom;
								decimal tmpRTref = brc.rateRefTo;
								int tmpApplyTo = brc.applyTo;
								int tmpApply4Qta = brc.applyToQuantity;
								
								if(tmpMaxQtadisp>=tmpRF && tmpMaxQtadisp<=tmpRT){
									if(tmpMaxRefQtadisp>=tmpRFref && tmpMaxRefQtadisp<=tmpRTref){
										if(tmpApplyTo==1){
											if(tmpApply4Qta>tmpMaxQtadisp){
												tmpApply4Qta = tmpMaxQtadisp;
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue =tmpImpProd/100*(brc.value*tmpApply4Qta);
											
											IList<object> infoValues = null;
											bool foundInfoValues = prule.rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											prule.rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==2){
											if(tmpApply4Qta>tmpMaxRefQtadisp){
												tmpApply4Qta = tmpMaxRefQtadisp;
											}
										
											decimal foundAmount = 0.00M;
											decimal tmpOpValue =tmpImpRefProd/100*(brc.value*tmpApply4Qta);
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[idProdRef].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[idProdRef].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==3){
											int tmpIdProdtoUse = -1;
											decimal tmpOpValue = 0.00M;
											if(tmpImpProd>tmpImpRefProd){ 
												tmpIdProdtoUse = idProdRef;
												if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4Qta = tmpMaxRefQtadisp;}
												tmpOpValue =tmpImpRefProd/100*(brc.value*tmpApply4Qta);
											}else{
												tmpIdProdtoUse = productId;
												if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4Qta = tmpMaxQtadisp;}
												tmpOpValue =tmpImpProd/100*(brc.value*tmpApply4Qta);
											}
										
											decimal foundAmount = 0.00M;
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[tmpIdProdtoUse].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[tmpIdProdtoUse].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==4){
											int tmpIdProdtoUse = -1;
											decimal tmpOpValue = 0.00M;
											if(tmpImpProd>tmpImpRefProd){ 
												tmpIdProdtoUse = productId;
												if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4Qta = tmpMaxQtadisp;}
												tmpOpValue =tmpImpProd/100*(brc.value*tmpApply4Qta);
											}else{
												tmpIdProdtoUse = idProdRef;
												if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4Qta = tmpMaxRefQtadisp;}
												tmpOpValue =tmpImpRefProd/100*(brc.value*tmpApply4Qta);
											}
										
											decimal foundAmount = 0.00M;
											
											IList<object> infoValues = null;
											bool foundInfoValues = productsVO[tmpIdProdtoUse].rulesInfo.TryGetValue(rule.id, out infoValues);
											if(!foundInfoValues){
												infoValues = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmount+=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
												case 2:
													foundAmount-=tmpOpValue;
													infoValues.Add(foundAmount);
													infoValues.Add(rule.label);
													break;
											}
											
											productsVO[tmpIdProdtoUse].rulesInfo[rule.id] = infoValues;
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}else if(tmpApplyTo==5){
											int tmpApply4QtaOrig=tmpApply4Qta;
											int tmpApply4QtaRef=tmpApply4Qta;
											if(tmpApply4Qta>tmpMaxQtadisp){tmpApply4QtaOrig = tmpMaxQtadisp;}
											if(tmpApply4Qta>tmpMaxRefQtadisp){tmpApply4QtaRef = tmpMaxRefQtadisp;}
										
											decimal foundAmountO = 0.00M;
											decimal foundAmountR = 0.00M;
											decimal tmpOpValueO =tmpImpProd/100*(brc.value*tmpApply4QtaOrig);
											decimal tmpOpValueR =tmpImpRefProd/100*(brc.value*tmpApply4QtaRef);
											
											IList<object> infoValuesO = null;
											IList<object> infoValuesR = null;
											bool foundInfoValuesO = prule.rulesInfo.TryGetValue(rule.id, out infoValuesO);
											bool foundInfoValuesR = productsVO[idProdRef].rulesInfo.TryGetValue(rule.id, out infoValuesR);
											if(!foundInfoValuesO){
												infoValuesO = new List<object>();
											}
											if(!foundInfoValuesR){
												infoValuesR = new List<object>();
											}
											
											switch (brc.operation)
											{
												case 1:
													foundAmountO+=tmpOpValueO;
													infoValuesO.Add(foundAmountO);
													infoValuesO.Add(rule.label);
													foundAmountR+=tmpOpValueR;
													infoValuesR.Add(foundAmountR);
													infoValuesR.Add(rule.label);
													break;
												case 2:
													foundAmountO-=tmpOpValueO;
													infoValuesO.Add(foundAmountO);
													infoValuesO.Add(rule.label);
													foundAmountR-=tmpOpValueR;
													infoValuesR.Add(foundAmountR);
													infoValuesR.Add(rule.label);
													break;
											}
											
											prule.rulesInfo[rule.id] = infoValuesO;
											productsVO[idProdRef].rulesInfo[rule.id] = infoValuesR;
											
											prule.rulesApplied[rule.id] = true;
											productsVO[productId] = prule;
											hasStrategy = true;
											break;
										}
									}
								}
							}
						}
					}
					break;
				
				// Regola esclusione spese accessorie su quantità prodotto 
				case 10:
					if(foundRuleConfigs){
						bool foundApplied = false;
						BusinessRuleProductVO prule = null;
						if(productsVO.TryGetValue(productId, out prule)){
							if(prule.rulesApplied != null){
								bool founded = false;
								if(prule.rulesApplied.TryGetValue(rule.id, out founded) && founded){
									foundApplied = true;
								}
							}
						}
						
						if(!foundApplied && prule != null){
							int tmpMaxQtadisp = prule.quantity;
							
							foreach(BusinessRuleConfig brc in ruleConfs){
								decimal tmpRF = brc.rateFrom;
								decimal tmpRT = brc.rateTo;
								int tmpApply4Qta = brc.applyToQuantity;
								
								if(tmpMaxQtadisp>=tmpRF && tmpMaxQtadisp<=tmpRT){
									prule.excludeBills = true;
									
									IList<object> infoValues = null;
									bool foundInfoValues = prule.rulesInfo.TryGetValue(rule.id, out infoValues);
									if(!foundInfoValues){
										infoValues = new List<object>();
									}
									infoValues.Add(0.00M);
									infoValues.Add(rule.label);
									
									prule.rulesInfo[rule.id] = infoValues;
									prule.rulesApplied[rule.id] = true;
									productsVO[productId] = prule;
									hasStrategy = true;
									break;
								}
							}
						}
					}					
					break;
				
				default:
					hasStrategy = false;
					break;
			}			
			
			return hasStrategy;			
		}	
	}
}