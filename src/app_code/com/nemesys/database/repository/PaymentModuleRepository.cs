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
	public class PaymentModuleRepository : IPaymentModuleRepository
	{		
		public void insert(PaymentModule paymentModule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(paymentModule);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-payment-module"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public void update(PaymentModule paymentModule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(paymentModule);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-module-"+paymentModule.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment-module"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}	
		}
		
		public void delete(PaymentModule paymentModule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(paymentModule);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-module-"+paymentModule.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment-module"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public PaymentModule getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public PaymentModule getByIdCached(int id, bool cached)
		{
			PaymentModule paymentModule = null;	
			
			if(cached)
			{
				paymentModule = (PaymentModule)HttpContext.Current.Cache.Get("payment-module-"+id);
				if(paymentModule != null){
					return paymentModule;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				paymentModule = session.Get<PaymentModule>(id);	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(paymentModule == null){
					paymentModule = new PaymentModule();
					paymentModule.id=-1;
				}
				HttpContext.Current.Cache.Insert("payment-module-"+paymentModule.id, paymentModule, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return paymentModule;
		}
		
		public PaymentModule getByName(string name)
		{
			return getByNameCached(name, false);
		}
		
		public PaymentModule getByNameCached(string name, bool cached)
		{
			PaymentModule paymentModule = null;	
			
			if(cached)
			{
				paymentModule = (PaymentModule)HttpContext.Current.Cache.Get("payment-module-"+name);
				if(paymentModule != null){
					return paymentModule;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				paymentModule = session.CreateQuery("from PaymentModule where name= :name").SetString("name",name).UniqueResult<PaymentModule>();	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(paymentModule == null){
					paymentModule = new PaymentModule();
					paymentModule.id=-1;
					paymentModule.name=name;
				}
				HttpContext.Current.Cache.Insert("payment-module-"+paymentModule.name, paymentModule, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return paymentModule;
		}
		
		public IList<PaymentModule> find(int idModule, string name, bool cached)
		{
			IList<PaymentModule> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-payment-module")
			.Append("-").Append(idModule)
			.Append("-").Append(name);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<PaymentModule>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from PaymentModule where 1=1";
			
			if (idModule > 0){			
				strSQL += " and id=:idModule";
			}
			if(!String.IsNullOrEmpty(name)){
				strSQL += " and name= :name";
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (idModule > 0){
						q.SetInt32("idModule", Convert.ToInt32(idModule));
					}
					if(!String.IsNullOrEmpty(name)){
						q.SetString("name",name);	
					}
					results = q.List<PaymentModule>();
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
					results = new List<PaymentModule>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}
	
		public IList<IPaymentField> getPaymentModuleFields(int idModule, string keyword, string matchField, Nullable<bool> doMatch)
		{
			return getPaymentModuleFieldsCached(idModule, keyword, matchField, doMatch, false);
		}
	
		public IList<IPaymentField> getPaymentModuleFieldsCached(int idModule, string keyword, string matchField, Nullable<bool> doMatch, bool cached)
		{
			IList<IPaymentField> results = null;
			StringBuilder cacheKey = new StringBuilder("list-payment-module-field-").Append(idModule).Append("-").Append(matchField);
				
			if(cached)
			{
				results = (IList<IPaymentField>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from PaymentModuleField  where 1=1";
				if(idModule!=-1){
				sql += " and id_module= :idModule";
				}
				if(!String.IsNullOrEmpty(keyword)){
				sql += " and keyword= :keyword";
				}
				if(!String.IsNullOrEmpty(matchField)){
				sql += " and match_field= :match_field";
				}
				if(doMatch != null){
					if(Convert.ToBoolean(doMatch)){
						sql += " and match_field <>'' and not match_field IS NULL";
					}else{
						sql += " and (match_field ='' or match_field IS NULL)";
					}
				}
				sql += " order by match_field, keyword asc";
				IQuery q = session.CreateQuery(sql);
				if(idModule!=-1){
				q.SetInt32("idModule",idModule);	
				}
				if(!String.IsNullOrEmpty(keyword)){
				q.SetString("keyword",keyword);	
				}
				if(!String.IsNullOrEmpty(matchField)){
				q.SetString("matchField",matchField);	
				}
				results = q.List<IPaymentField>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<IPaymentField>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}	
	}
}