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
	public class ShippingAddressRepository : IShippingAddressRepository
	{		
		public void insert(ShippingAddress shippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(shippingAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(ShippingAddress shippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(shippingAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("shipping-address-"+shippingAddress.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void delete(ShippingAddress shippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(shippingAddress);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("shipping-address-"+shippingAddress.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public ShippingAddress getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public ShippingAddress getByIdCached(int id, bool cached)
		{
			ShippingAddress shippingAddress = null;	
			
			if(cached)
			{
				shippingAddress = (ShippingAddress)HttpContext.Current.Cache.Get("shipping-address-"+id);
				if(shippingAddress != null){
					return shippingAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				shippingAddress = session.Get<ShippingAddress>(id);	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(shippingAddress != null){
					HttpContext.Current.Cache.Insert("shipping-address-"+shippingAddress.id, shippingAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return shippingAddress;
		}
		
		public ShippingAddress getByUserId(int userId)
		{
			return getByUserIdCached(userId, false);
		}
		
		public ShippingAddress getByUserIdCached(int userId, bool cached)
		{
			ShippingAddress shippingAddress = null;	
			
			if(cached)
			{
				shippingAddress = (ShippingAddress)HttpContext.Current.Cache.Get("shipping-address-"+userId);
				if(shippingAddress != null){
					return shippingAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				shippingAddress = session.CreateQuery("from ShippingAddress where idUser=:idUser").SetInt32("idUser",userId).UniqueResult<ShippingAddress>();	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(shippingAddress != null){
					HttpContext.Current.Cache.Insert("shipping-address-"+shippingAddress.idUser, shippingAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return shippingAddress;
		}
	}
}