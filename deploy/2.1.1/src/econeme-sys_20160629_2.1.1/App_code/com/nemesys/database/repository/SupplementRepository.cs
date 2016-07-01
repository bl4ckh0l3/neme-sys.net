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
	public class SupplementRepository : ISupplementRepository
	{		
		public void insert(Supplement supplement)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(supplement);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-supplement"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public void update(Supplement supplement)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(supplement);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("supplement-"+supplement.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-supplement"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void delete(Supplement supplement)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(supplement);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("supplement-"+supplement.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public Supplement getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public Supplement getByIdCached(int id, bool cached)
		{
			Supplement supplement = null;	
			
			if(cached)
			{
				supplement = (Supplement)HttpContext.Current.Cache.Get("supplement-"+id);
				if(supplement != null){
					return supplement;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				supplement = session.Get<Supplement>(id);	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(supplement == null){
					supplement = new Supplement();
					supplement.id=-1;
				}
				HttpContext.Current.Cache.Insert("supplement-"+supplement.id, supplement, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return supplement;
		}

		public void saveCompleteSupplement(Supplement supplement, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{					
					if(supplement.id != -1){
						session.Update(supplement);							
					}else{
						session.Save(supplement);
					}
						
					// ************** AGGIUNGO TGUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione, meta_xxx ecc
					foreach (MultiLanguage mu in deltranslactions){
						session.Delete(mu);
					}
					foreach (MultiLanguage mu in updtranslactions){
						session.SaveOrUpdate(mu);
					}
					foreach (MultiLanguage mi in newtranslactions){
						session.Save(mi);
					}
					tx.Commit();
					NHibernateHelper.closeSession();
				}catch(Exception exx){
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;	
				}
			}
		}
		
		public IList<Supplement> find(string description, int type, bool cached)
		{
			IList<Supplement> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-supplement")
			.Append("-").Append(description)
			.Append("-").Append(type);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<Supplement>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from Supplement where 1=1";
			
			if(!String.IsNullOrEmpty(description)){
				strSQL += " and description= :description";
			}			
			if (type > 0){			
				strSQL += " and type=:type";
			}
			strSQL += " order by description asc";
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if(!String.IsNullOrEmpty(description)){
						q.SetString("description",description);	
					}
					if (type > 0){
						q.SetInt32("type", Convert.ToInt32(type));
					}
					results = q.List<Supplement>();
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
					results = new List<Supplement>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}	
	}
}