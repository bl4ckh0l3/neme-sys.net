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
	public class SupplementGroupRepository : ISupplementGroupRepository
	{		
		public void insert(SupplementGroup supplementGroup)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				IList<SupplementGroupValue> newSGV = new List<SupplementGroupValue>();	
				if(supplementGroup.values != null && supplementGroup.values.Count>0)
				{
					foreach(SupplementGroupValue k in supplementGroup.values){	
						SupplementGroupValue nsgv = new SupplementGroupValue();	
						nsgv.id=k.id;
						nsgv.idGroup=k.idGroup;
						nsgv.countryCode=k.countryCode;
						nsgv.stateRegionCode=k.stateRegionCode;
						nsgv.idFee=k.idFee;
						nsgv.excludeCalculation=k.excludeCalculation;					
						newSGV.Add(nsgv);
					}
					supplementGroup.values.Clear();							
				}			
				
				session.Save(supplementGroup);			
				
				List<string> ids = new List<string>();
				if(newSGV != null && newSGV.Count>0){
					foreach(SupplementGroupValue pcid in newSGV){
						ids.Add(pcid.idGroup.ToString());
					}
					session.CreateQuery(string.Format("delete from SupplementGroupValue where idGroup in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
						
					foreach(SupplementGroupValue k in newSGV){
						k.idGroup = supplementGroup.id;
						session.Save(k);
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
				if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void update(SupplementGroup supplementGroup)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<SupplementGroupValue> newSGV = new List<SupplementGroupValue>();		
				if(supplementGroup.values != null && supplementGroup.values.Count>0)
				{
					foreach(SupplementGroupValue k in supplementGroup.values){	
						SupplementGroupValue nsgv = new SupplementGroupValue();
						nsgv.id=k.id;	
						nsgv.idGroup=k.idGroup;
						nsgv.countryCode=k.countryCode;
						nsgv.stateRegionCode=k.stateRegionCode;
						nsgv.idFee=k.idFee;
						nsgv.excludeCalculation=k.excludeCalculation;					
						newSGV.Add(nsgv);
					}
					supplementGroup.values.Clear();						
				}			
				
				session.Update(supplementGroup);	
								
				session.CreateQuery("delete from SupplementGroupValue where idGroup=:idGroup").SetInt32("idGroup",supplementGroup.id).ExecuteUpdate();	

				if(newSGV != null && newSGV.Count>0)
				{					
					foreach(SupplementGroupValue k in newSGV){
						k.idGroup = supplementGroup.id;
						session.Save(k);
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
				if(cacheKey.Contains("supplement-group-"+supplementGroup.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void delete(SupplementGroup supplementGroup)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(supplementGroup.values != null && supplementGroup.values.Count>0)
				{
					session.CreateQuery("delete from SupplementGroupValue where idGroup=:idGroup").SetInt32("idGroup",supplementGroup.id).ExecuteUpdate();
					supplementGroup.values.Clear();						
				}		
				session.Delete(supplementGroup);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("supplement-group-"+supplementGroup.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public SupplementGroup getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public SupplementGroup getByIdCached(int id, bool cached)
		{
			SupplementGroup supplementGroup = null;	
			
			if(cached)
			{
				supplementGroup = (SupplementGroup)HttpContext.Current.Cache.Get("supplement-group-"+id);
				if(supplementGroup != null){
					return supplementGroup;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				supplementGroup = session.Get<SupplementGroup>(id);			

				supplementGroup.values = session.CreateCriteria(typeof(SupplementGroupValue))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idGroup", supplementGroup.id))
				.AddOrder(Order.Asc("countryCode"))
				.List<SupplementGroupValue>();						

				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(supplementGroup == null){
					supplementGroup = new SupplementGroup();
					supplementGroup.id=-1;
				}
				HttpContext.Current.Cache.Insert("supplement-group-"+supplementGroup.id, supplementGroup, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return supplementGroup;
		}

		public IList<SupplementGroup> getSupplementGroups()
		{
			IList<SupplementGroup> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from SupplementGroup order by description asc");
				results = q.List<SupplementGroup>();
				NHibernateHelper.closeSession();
			}
			
			//System.Web.HttpContext.Current.Response.Write("results.Count: " + results.Count);
			
			return results;			
		}
		
		public IList<SupplementGroup> find(string description, bool cached)
		{
			IList<SupplementGroup> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-supplement-group")
			.Append("-").Append(description);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<SupplementGroup>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from SupplementGroup where 1=1";
			
			if(!String.IsNullOrEmpty(description)){
				strSQL += " and description= :description";
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
					results = q.List<SupplementGroup>();

					if(results != null){
						foreach(SupplementGroup sg in results){
							sg.values = session.CreateCriteria(typeof(SupplementGroupValue))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idGroup", sg.id))
							.AddOrder(Order.Asc("countryCode"))
							.List<SupplementGroupValue>();									
						}
					}
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
					results = new List<SupplementGroup>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}
		
	
		public IList<SupplementGroupValue> findSupplementGroupValues(int idGroup, string countryCode, string stateRegionCode)
		{
			return findSupplementGroupValuesCached(idGroup, countryCode, stateRegionCode, false);
		}
	
		public IList<SupplementGroupValue> findSupplementGroupValuesCached(int idGroup, string countryCode, string stateRegionCode, bool cached)
		{
			IList<SupplementGroupValue> results = null;
			StringBuilder cacheKey = new StringBuilder("list-supplement-group-value-").Append(idGroup).Append("-").Append(countryCode).Append("-").Append(stateRegionCode);
						
			if(cached)
			{
				results = (IList<SupplementGroupValue>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from SupplementGroupValue  where 1=1";
				if(idGroup!=-1){
				sql += " and id_group= :idGroup";
				}
				if(!String.IsNullOrEmpty(countryCode)){
				sql += " and country_code= :countryCode";
				}
				if(!String.IsNullOrEmpty(stateRegionCode)){
				sql += " and state_region_code= :stateRegionCode";
				}
				sql += " order by country_code, state_region_code asc";
				IQuery q = session.CreateQuery(sql);
				if(idGroup!=-1){
				q.SetInt32("idGroup",idGroup);	
				}
				if(!String.IsNullOrEmpty(countryCode)){
				q.SetString("countryCode",countryCode);	
				}
				if(!String.IsNullOrEmpty(stateRegionCode)){
				q.SetString("stateRegionCode",stateRegionCode);	
				}
				results = q.List<SupplementGroupValue>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<SupplementGroupValue>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}

		public SupplementGroupValue getGroupValueById(int id)
		{
			SupplementGroupValue supplementGroupV = null;	
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				supplementGroupV = session.Get<SupplementGroupValue>(id);
				NHibernateHelper.closeSession();
			}
			
			return supplementGroupV;
		}
		
		public void insertGroupValue(SupplementGroupValue supplementGroupValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(supplementGroupValue);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void updateGroupValue(SupplementGroupValue supplementGroupValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(supplementGroupValue);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void deleteGroupValue(SupplementGroupValue supplementGroupValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(supplementGroupValue);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-supplement-group"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-supplement-group-value"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}		
	}
}