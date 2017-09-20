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
using System.Globalization;
using com.nemesys.model;
using com.nemesys.database.repository;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

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
		
		public static UPSFee getUPSRate(string extParams, IList<Product> products, ShippingAddress shipToAddr, BillingData billingData)
		{
			UPSFee result = null;
			
			try{
				// set credentials parameters
				string endpoint = "";
				string username = "";
				string password = "";
				string licenceNumber = "";
				string shipperNumber = "";
				StringBuilder postData = new StringBuilder();

				NumberFormatInfo nfi = new NumberFormatInfo();
				nfi.NumberDecimalSeparator = ".";				
				
				Dictionary<string, string> values = JsonConvert.DeserializeObject<Dictionary<string, string>>(extParams);
				string tmpval = "";	
				
				if(values.TryGetValue("endpoint", out tmpval)){
					endpoint = tmpval; 
				}	
				if(values.TryGetValue("username", out tmpval)){
					username = tmpval; 
				}
				if(values.TryGetValue("password", out tmpval)){
					password = tmpval; 
				}
				if(values.TryGetValue("access_number", out tmpval)){
					licenceNumber = tmpval; 
				}
				if(values.TryGetValue("shipper_number", out tmpval)){
					shipperNumber = tmpval; 
				}										
				
				// set json request
				postData.Append("{'UPSSecurity': {'UsernameToken': {'Username': '")
				.Append(username)
				.Append("','Password': '")
				.Append(password)
				.Append("'},'ServiceAccessToken': {'AccessLicenseNumber': '")
				.Append(licenceNumber)
				.Append("'}},'RateRequest': {'Request': {'RequestOption': 'Rate','TransactionReference': {'CustomerContext': ''}},")
				.Append("'Shipment': {'Shipper': {'Name': '")
				.Append(billingData.name)
				.Append("','ShipperNumber': '")
				.Append(shipperNumber)
				.Append("','Address': {'AddressLine': '")
				.Append(billingData.address)
				.Append("','City': '")
				.Append(billingData.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(billingData.zipCode)
				.Append("','CountryCode': '")
				.Append(billingData.country)
				.Append("'}},")
				.Append("'ShipTo': {'Name': '")
				.Append(shipToAddr.name)
				.Append(" ")
				.Append(shipToAddr.surname)
				.Append("','Address': {'AddressLine': '")
				.Append(shipToAddr.address)
				.Append("','City': '")
				.Append(shipToAddr.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(shipToAddr.zipCode)
				.Append("','CountryCode': '")
				.Append(shipToAddr.country)
				.Append("'}},")
				.Append("'ShipFrom': {'Name': '")
				.Append(billingData.name)
				.Append("','Address': {'AddressLine': '")
				.Append(billingData.address)
				.Append("','City': '")
				.Append(billingData.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(billingData.zipCode)
				.Append("','CountryCode': '")
				.Append(billingData.country)
				.Append("'}},")
				.Append("'Service': {'Code': '11','Description': ''},")
				.Append("'Package': [");
				
				int counter = 1;
				foreach(Product p in products){
					postData.Append("{'PackagingType': {'Code': '02','Description': '").Append(p.name).Append("'},")
					.Append("'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '")
					.Append(p.length.ToString("0.00",nfi))
					.Append("','Width': '")
					.Append(p.width.ToString("0.00",nfi))
					.Append("','Height': '")
					.Append(p.height.ToString("0.00",nfi))
					.Append("'},")
					.Append("'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '")
					.Append(p.weight.ToString("0.00",nfi))
					.Append("'}}");
					if(counter<products.Count){
						postData.Append(",");
					}
					counter++;
				}		
				
				postData.Append("],")
				.Append("'ShipmentRatingOptions': {'NegotiatedRatesIndicator': ''}}}}");
				
				//HttpContext.Current.Response.Write("<br>postData: "+postData.ToString()+"<br><br>");
				
				RestClient client = new RestClient();
				client.EndPoint = @endpoint+"Rate";
				client.Method = HttpVerb.POST;
				client.PostData = postData.ToString();
				string[] json = client.MakeRequest();	
			
				//HttpContext.Current.Response.Write("json response:<br><br>");
				//HttpContext.Current.Response.Write(json[0]+"<br>");
				//HttpContext.Current.Response.Write(json[1]+"<br>");
				//HttpContext.Current.Response.Write(json[2]+"<br>");

				JObject o = JObject.Parse(json[0]);
				
				//HttpContext.Current.Response.Write("JObject:<br>"+o+"<br>");
				
				if(o!=null && o.HasValues){
					string code = o.SelectToken("RateResponse.Response.ResponseStatus.Code").ToString();
					
					//HttpContext.Current.Response.Write("code:<br>"+code+"<br>");
					
					if("1".Equals(code)){
						decimal amount = (decimal)o.SelectToken("RateResponse.RatedShipment.TotalCharges.MonetaryValue");
						string currency = (string)o.SelectToken("RateResponse.RatedShipment.TotalCharges.CurrencyCode");
						//HttpContext.Current.Response.Write("amount:<br>"+amount+"<br>");
						
						result = new UPSFee();
						result.extResponse=json[0];
						result.amount=amount;
						result.currency=currency;
						result.success=true;
					}
				}
				
				/*
				{'UPSSecurity': {'UsernameToken': {'Username': 'bl4ckh0l3','Password': '$_uatos12976'},'ServiceAccessToken': {'AccessLicenseNumber': '4D31063A140E945C'}},
				'RateRequest': {'Request': {'RequestOption': 'Rate','TransactionReference': {'CustomerContext': ''}},
				'Shipment': {'Shipper': {'Name': 'DickDick Shop','ShipperNumber': '9863X9','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},
				'ShipTo': {'Name': 'Jack Frost','Address': {'AddressLine': 'Via di arrivo, 10','City': 'Torino','StateProvinceCode': 'TO','PostalCode': '10121','CountryCode': 'IT'}},
				'ShipFrom': {'Name': 'DickDick Shop','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},
				'Service': {'Code': '11','Description': ''},
				'Package': [
					{'PackagingType': {'Code': '02','Description': 'my first package'},
					'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '10','Width': '15','Height': '5'},
					'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '70'}
					},
					{'PackagingType': {'Code': '02','Description': 'My second package'},
					'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '45','Width': '20','Height': '10'},
					'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '40'}
					}
				],
				'ShipmentRatingOptions': {'NegotiatedRatesIndicator': ''}}}}
				*/
			}catch(Exception ex){
				//HttpContext.Current.Response.Write("An error occured: " + ex.Message);
				result = null;
			}			
			
			return result;
		}
		
		public static UPSFee getUPSShip(string extParams, IList<Product> products, ShippingAddress shipToAddr, BillingData billingData)
		{
			UPSFee result = null;
						
			try{
				// set credentials parameters
				string endpoint = "";
				string username = "";
				string password = "";
				string licenceNumber = "";
				string shipperNumber = "";
				StringBuilder postData = new StringBuilder();

				NumberFormatInfo nfi = new NumberFormatInfo();
				nfi.NumberDecimalSeparator = ".";				
				
				Dictionary<string, string> values = JsonConvert.DeserializeObject<Dictionary<string, string>>(extParams);
				string tmpval = "";	
				
				if(values.TryGetValue("endpoint", out tmpval)){
					endpoint = tmpval; 
				}	
				if(values.TryGetValue("username", out tmpval)){
					username = tmpval; 
				}
				if(values.TryGetValue("password", out tmpval)){
					password = tmpval; 
				}
				if(values.TryGetValue("access_number", out tmpval)){
					licenceNumber = tmpval; 
				}
				if(values.TryGetValue("shipper_number", out tmpval)){
					shipperNumber = tmpval; 
				}										
				
				// set json request
				postData.Append("{'UPSSecurity': {'UsernameToken': {'Username': '")
				.Append(username)
				.Append("','Password': '")
				.Append(password)
				.Append("'},'ServiceAccessToken': {'AccessLicenseNumber': '")
				.Append(licenceNumber)
				.Append("'}},'ShipmentRequest': {'Request': {'RequestOption': 'validate','TransactionReference': {'CustomerContext': ''}},")
				.Append("'Shipment': {'Description': '','Shipper': {'Name': '")
				.Append(billingData.name)
				.Append("','AttentionName': '','TaxIdentificationNumber': '','Phone': {'Number': '")
				.Append(billingData.phone)
				.Append("','Extension': '1'},")
				.Append("'ShipperNumber': '")
				.Append(shipperNumber)
				.Append("','FaxNumber': '','Address': {'AddressLine': '")
				.Append(billingData.address)
				.Append("','City': '")
				.Append(billingData.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(billingData.zipCode)
				.Append("','CountryCode': '")
				.Append(billingData.country)
				.Append("'}},")
				.Append("'ShipTo': {'Name': '")
				.Append(shipToAddr.name)
				.Append(" ")
				.Append(shipToAddr.surname)
				.Append("','Address': {'AddressLine': '")
				.Append(shipToAddr.address)
				.Append("','City': '")
				.Append(shipToAddr.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(shipToAddr.zipCode)
				.Append("','CountryCode': '")
				.Append(shipToAddr.country)
				.Append("'}},")
				.Append("'ShipFrom': {'Name': '")
				.Append(billingData.name)
				.Append("','Address': {'AddressLine': '")
				.Append(billingData.address)
				.Append("','City': '")
				.Append(billingData.city)
				.Append("','StateProvinceCode': '','PostalCode': '")
				.Append(billingData.zipCode)
				.Append("','CountryCode': '")
				.Append(billingData.country)
				.Append("'}},")
				.Append("'PaymentInformation': {'ShipmentCharge': {'Type': '01','BillShipper': {'AccountNumber': '")
				.Append(shipperNumber)
				.Append("'}}},")
				.Append("'Service': {'Code': '11','Description': ''},")
				.Append("'Package': [");
				
				int counter = 1;
				foreach(Product p in products){
					postData.Append("{'Description': '','Packaging': {'Code': '02','Description': '").Append(p.name).Append("'},")
					.Append("'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'Centimeter '},'Length': '")
					.Append(p.length.ToString("0.00",nfi))
					.Append("','Width': '")
					.Append(p.width.ToString("0.00",nfi))
					.Append("','Height': '")
					.Append(p.height.ToString("0.00",nfi))
					.Append("'},")
					.Append("'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '")
					.Append(p.weight.ToString("0.00",nfi))
					.Append("'}}");
					if(counter<products.Count){
						postData.Append(",");
					}
					counter++;
				}		
				
				postData.Append("],")
				.Append("'LabelSpecification': {'LabelImageFormat': {'Code': 'GIF','Description': 'GIF'},'HTTPUserAgent': 'Mozilla/4.5'}}}}");
				
				//HttpContext.Current.Response.Write("<br>postData: "+postData.ToString()+"<br><br>");
				
				RestClient client = new RestClient();
				client.EndPoint = @endpoint+"Ship";
				client.Method = HttpVerb.POST;
				client.PostData = postData.ToString();
				string[] json = client.MakeRequest();	
			
				//HttpContext.Current.Response.Write("json response:<br><br>");
				//HttpContext.Current.Response.Write(json[0]+"<br>");
				//HttpContext.Current.Response.Write(json[1]+"<br>");
				//HttpContext.Current.Response.Write(json[2]+"<br>");

				JObject o = JObject.Parse(json[0]);
				
				//HttpContext.Current.Response.Write("JObject:<br>"+o+"<br>");
				
				if(o!=null && o.HasValues){
					string code = o.SelectToken("ShipmentResponse.Response.ResponseStatus.Code").ToString();
					
					//HttpContext.Current.Response.Write("code:<br>"+code+"<br>");
					
					if("1".Equals(code)){
						decimal amount = (decimal)o.SelectToken("ShipmentResponse.ShipmentResults.ShipmentCharges.TotalCharges.MonetaryValue");
						string currency = (string)o.SelectToken("ShipmentResponse.ShipmentResults.ShipmentCharges.TotalCharges.CurrencyCode");
						//HttpContext.Current.Response.Write("amount:<br>"+amount+"<br>");
						
						result = new UPSFee();
						result.extResponse=json[0];
						result.amount=amount;
						result.currency=currency;
						result.success=true;
					}
				}
				
			
			/*
			{'UPSSecurity': {'UsernameToken': {'Username': 'bl4ckh0l3','Password': '$_uatos12976'},'ServiceAccessToken': {'AccessLicenseNumber': '4D31063A140E945C'}},
			'ShipmentRequest': {'Request': {'RequestOption': 'validate','TransactionReference': {'CustomerContext': ''}},
			'Shipment': {'Description': '','Shipper': {'Name': 'DickDick Shop','AttentionName': '','TaxIdentificationNumber': '123456','Phone': {'Number': '1234567890','Extension': '1'},'ShipperNumber': '0F95V3','FaxNumber': '1234567890','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},
			'ShipTo': {'Name': 'Jack Frost','AttentionName': '','Phone': {'Number': '1234567890'},'Address': {'AddressLine': 'Via di arrivo, 10','City': 'Torino','StateProvinceCode': 'TO','PostalCode': '10121','CountryCode': 'IT'}},
			'ShipFrom': {'Name': 'DickDick Shop','AttentionName': '','Phone': {'Number': '1234567890'},'FaxNumber': '1234567890','Address': {'AddressLine': 'Via napoli, 45','City': 'Milano','StateProvinceCode': 'MI','PostalCode': '20121','CountryCode': 'IT'}},
			'PaymentInformation': {'ShipmentCharge': {'Type': '01','BillShipper': {'AccountNumber': '0F95V3'}}},
			'Service': {'Code': '11','Description': ''},
			'Package': [
				{'Description': '','Packaging': {'Code': '02','Description': 'my first package'},'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'centimeter'},'Length': '10','Width': '15','Height': '5'},'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '70'}},
				{'Description': '','Packaging': {'Code': '02','Description': 'my second package'},'Dimensions': {'UnitOfMeasurement': {'Code': 'CM','Description': 'centimeter'},'Length': '45','Width': '20','Height': '10'},'PackageWeight': {'UnitOfMeasurement': {'Code': 'KGS','Description': 'kilos'},'Weight': '40'}}
			],
			'LabelSpecification': {'LabelImageFormat': {'Code': 'GIF','Description': 'GIF'},'HTTPUserAgent': 'Mozilla/4.5'}}}}			
			*/
			}catch(Exception ex){
				//HttpContext.Current.Response.Write("An error occured: " + ex.Message);
				result = null;
			}
			
			return result;
		}
	}
}