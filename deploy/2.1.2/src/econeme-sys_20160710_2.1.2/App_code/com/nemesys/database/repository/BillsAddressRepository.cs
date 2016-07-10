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
	public class BillsAddressRepository : IBillsAddressRepository
	{		
		public void insert(BillsAddress billsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(billsAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(BillsAddress billsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(billsAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("bills-address-"+billsAddress.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void delete(BillsAddress billsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(billsAddress);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("bills-address-"+billsAddress.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public BillsAddress getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public BillsAddress getByIdCached(int id, bool cached)
		{
			BillsAddress billsAddress = null;	
			
			if(cached)
			{
				billsAddress = (BillsAddress)HttpContext.Current.Cache.Get("bills-address-"+id);
				if(billsAddress != null){
					return billsAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				billsAddress = session.Get<BillsAddress>(id);	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(billsAddress != null){
					HttpContext.Current.Cache.Insert("bills-address-"+billsAddress.id, billsAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return billsAddress;
		}
		
		public BillsAddress getByUserId(int userId)
		{
			return getByUserIdCached(userId, false);
		}
		
		public BillsAddress getByUserIdCached(int userId, bool cached)
		{
			BillsAddress billsAddress = null;	
			
			if(cached)
			{
				billsAddress = (BillsAddress)HttpContext.Current.Cache.Get("bills-address-"+userId);
				if(billsAddress != null){
					return billsAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				billsAddress = session.CreateQuery("from BillsAddress where idUser=:idUser").SetInt32("idUser",userId).UniqueResult<BillsAddress>();	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(billsAddress != null){
					HttpContext.Current.Cache.Insert("bills-address-"+billsAddress.idUser, billsAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return billsAddress;
		}
	}
}