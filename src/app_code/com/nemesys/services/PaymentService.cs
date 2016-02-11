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
using System.Globalization;
using System.Xml;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class PaymentService
	{
		protected static IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		protected static IPaymentModuleRepository paymodrep = RepositoryFactory.getInstance<IPaymentModuleRepository>("IPaymentModuleRepository");
		protected static IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		
		
		public static decimal getCommissionAmount(decimal price, decimal commission, int type)
		{
			decimal result = 0.00M;
			
			if(type==1){
				result = price * (commission / 100);
			}else{
				result = commission;
			}
			
			return result;
		}
		
		/*
		public static string setCheckout(FOrder order)
		{
			StringBuilder result = new StringBuilder();
					
			try{			
				Payment payment = payrep.getById(order.paymentId);
				
				if(payment != null){
					IList<IPaymentField> payFields = payrep.getPaymentFields(payment.id, payment.idModule, null, null, null);
					
					if(payFields != null && payFields.Count>0){
				
						IDictionary<string,string> parameters = new Dictionary<string,string>();
				
						string externalURL = "";
						
						foreach(IPaymentField f in payFields){
							if(CommonKeywords.getUniqueKeyExtURLPayment().Equals(f.keyword)){
								externalURL = f.value;	
							}else if(CommonKeywords.getUniqueKeyOrderIdPayment().Equals(f.matchField)){
								parameters.Add(f.keyword,order.id.ToString());
							}else if(CommonKeywords.getUniqueKeyOrderAmountPayment().Equals(f.matchField)){
								parameters.Add(f.keyword,order.amount.ToString("0.00").Replace(",","."));
							}else{
								parameters.Add(f.keyword,f.value);
							}
						}
						
						result.Append("<form method=\"post\" name=\"checkout_redirect\" action=\"").Append(externalURL).Append("\">");
						
						foreach(KeyValuePair<string, string> par in parameters){
							result.Append("<input type=\"hidden\" name=\"").Append(par.Key).Append("\" value=\"").Append(par.Value).Append("\">");
						}
						
						result.Append("</form>");
					}
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write(ex.Message+"<br>");
			}
			
			return result.ToString();			
		}
		*/
		
		public static IDictionary<string,string> setCheckout(FOrder order)
		{
			IDictionary<string,string> results = new Dictionary<string,string>();
					
			try{			
				Payment payment = payrep.getById(order.paymentId);
				
				if(payment != null){
					IList<IPaymentField> payFields = payrep.getPaymentFields(payment.id, payment.idModule, null, null, null);
					
					if(payFields != null && payFields.Count>0){
						foreach(IPaymentField f in payFields){
							results.Add(f.keyword,f.value);
						}
					}
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write(ex.Message+"<br>");
			}
			
			return results;			
		}
		
		public static string getCheckoutModulePage(int paymentId)
		{
			string page = "";	
			
			try{			
				Payment payment = payrep.getByIdCached(paymentId,true);
				
				if(payment != null && payment.idModule>0){
					PaymentModule module = paymodrep.getByIdCached(payment.idModule,true);
					if(module != null){
						page = module.name;
					}
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write(ex.Message+"<br>");
			}			
			
			return page;
		}
	}
}