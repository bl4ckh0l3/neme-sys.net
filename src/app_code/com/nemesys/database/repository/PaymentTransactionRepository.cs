using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Web.Caching;

namespace com.nemesys.database.repository
{
	public class PaymentTransactionRepository : IPaymentTransactionRepository
	{		
		public void insert(PaymentTransaction paymentTransaction)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(paymentTransaction);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-payment-transaction"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public void update(PaymentTransaction paymentTransaction)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(paymentTransaction);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-transaction-"+paymentTransaction.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment-transaction"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}	
		}
		
		public void delete(PaymentTransaction paymentTransaction)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(paymentTransaction);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-transaction-"+paymentTransaction.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment-transaction"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public void savePaymentTransaction(FOrder order, PaymentTransaction paymentTransaction)
		{
			IList<OrderProductAttachmentDownload> toUpdate = new List<OrderProductAttachmentDownload>();
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				//session.Save(new Logger("order: "+order.ToString(),"system","debug",DateTime.Now));
				
				if(order.paymentDone && paymentTransaction.notified){
					//session.Save(new Logger("order.products != null: "+(order.products != null),"system","debug",DateTime.Now));
					
					if(order.products != null && order.products.Count>0){
						//session.Save(new Logger("order.products.Count: "+order.products.Count,"system","debug",DateTime.Now));
						foreach(OrderProduct op in order.products.Values){
							//session.Save(new Logger("OrderProduct: "+op.ToString(),"system","debug",DateTime.Now));
							if(op.productType==1){
								IList<OrderProductAttachmentDownload> attachments = session.CreateQuery("from OrderProductAttachmentDownload where idOrder=:orderId and idParentProduct=:productId")
								.SetInt32("orderId",order.id)
								.SetInt32("productId",op.idProduct)			
								.List<OrderProductAttachmentDownload>();							
								
								//session.Save(new Logger("attachments.Count: "+attachments.Count,"system","debug",DateTime.Now));
								
								if(attachments != null && attachments.Count>0){
									foreach(OrderProductAttachmentDownload d in attachments){
										toUpdate.Add(d);
									}
								}
							}
						}						
					}
				}
				
				session.Save(paymentTransaction);
				session.Update(order);							
					
				//session.Save(new Logger("toUpdate.Count: "+toUpdate.Count,"system","debug",DateTime.Now));
				
				if(toUpdate != null && toUpdate.Count>0){
					foreach(OrderProductAttachmentDownload d in toUpdate){
						d.active=true;
						//session.Save(new Logger("OrderProductAttachmentDownload activated: "+d.ToString(),"system","debug",DateTime.Now));
						session.Update(d);
					}
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}	
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-transaction-"+paymentTransaction.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment-transaction"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}		
		}
		
		public PaymentTransaction getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public PaymentTransaction getByIdCached(int id, bool cached)
		{
			PaymentTransaction paymentTransaction = null;	
			
			if(cached)
			{
				paymentTransaction = (PaymentTransaction)HttpContext.Current.Cache.Get("payment-transaction-"+id);
				if(paymentTransaction != null){
					return paymentTransaction;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				paymentTransaction = session.Get<PaymentTransaction>(id);	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(paymentTransaction == null){
					paymentTransaction = new PaymentTransaction();
					paymentTransaction.id=-1;
				}
				HttpContext.Current.Cache.Insert("payment-transaction-"+paymentTransaction.id, paymentTransaction, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return paymentTransaction;
		}
		
		public IList<PaymentTransaction> find(int idOrder, int idModule, string idTransaction, string notified, bool cached)
		{
			IList<PaymentTransaction> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-payment-transaction")
			.Append("-").Append(idOrder)
			.Append("-").Append(idModule)
			.Append("-").Append(idTransaction)
			.Append("-").Append(notified);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<PaymentTransaction>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from PaymentTransaction where 1=1";
			
			if (idOrder > 0){			
				strSQL += " and idOrder=:idOrder";
			}			
			if (idModule > 0){			
				strSQL += " and idModule=:idModule";
			}			
			if (!String.IsNullOrEmpty(idTransaction)){			
				strSQL += " and idTransaction=:idTransaction";
			}
			if(!String.IsNullOrEmpty(notified)){
				if(Convert.ToBoolean(notified)){
					strSQL += " and notified=:notified and status=:status";
				}else{
					strSQL += " and notified=:notified";
				}
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (idOrder > 0){
						q.SetInt32("idOrder", Convert.ToInt32(idOrder));
					}
					if (idModule > 0){
						q.SetInt32("idModule", Convert.ToInt32(idModule));
					}
					if(!String.IsNullOrEmpty(idTransaction)){
						q.SetString("idTransaction", idTransaction);
					}
					if(!String.IsNullOrEmpty(notified)){
						if(Convert.ToBoolean(notified)){		
							q.SetBoolean("notified", Convert.ToBoolean(notified));
							q.SetString("status", CommonKeywords.getSuccessKey());
						}else{	
							q.SetBoolean("notified", Convert.ToBoolean(notified));
						}
					}
					
					results = q.List<PaymentTransaction>();
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(results == null){
					results = new List<PaymentTransaction>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}	
		
		public bool isPaymentTransactionNotified(PaymentTransaction paymentTransaction)
		{
			return paymentTransaction.idOrder>0 && !String.IsNullOrEmpty(paymentTransaction.idTransaction) && paymentTransaction.notified && CommonKeywords.getSuccessKey().Equals(paymentTransaction.status);
		}
		
		public bool hasPaymentTransactionNotified(int idOrder)
		{
			bool notified = false;
			IList<PaymentTransaction> results = null;
			
			string strSQL = "from PaymentTransaction where 1=1";
			
			if (idOrder > 0){			
				strSQL += " and idOrder=:idOrder";
			}
			strSQL += " and notified=:notified and status=:status";
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (idOrder > 0){
						q.SetInt32("idOrder", Convert.ToInt32(idOrder));
					}
					q.SetBoolean("notified", true);
					q.SetString("status", CommonKeywords.getSuccessKey());
					results = q.List<PaymentTransaction>();
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			if(results != null && results.Count>0){
				notified = true;
			}
						
			return notified;	
		}
	}
}