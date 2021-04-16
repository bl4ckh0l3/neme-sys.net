using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Reflection;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Text;
using System.Xml;
using System.IO;
using System.Web.Caching;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.services;

namespace com.nemesys.database.repository
{
	public class RepositoryFactory
	{
		private static readonly object _Padlock = new object();
		private static IDictionary<string, object> mappingSet = new  Dictionary<string, object>();
		private static RepositoryService reposervice = new RepositoryService();
		private static Assembly assembly = Assembly.Load("App_Code");
		private const string CACHE_PREFIX = "RepositoryInstance:";
	
		static RepositoryFactory()
		{		
			createMapping();	
		}
		
		public static T getInstance<T>(string beanName)
		{			
			//se l'attibuto singleton è false creo e ritorno una nuova istanza ogni richiesta
			try
			{
				RepositoryMapping rm = reposervice.get(beanName);
				if(!String.IsNullOrEmpty(rm.singleton) && !Convert.ToBoolean(rm.singleton)){
					return (T)getNew(beanName);
					//System.Web.HttpContext.Current.Response.Write("rm.singleton -->"+beanName+": ");
				}
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: TRY CASCADE
			}			

			object instance = null;			
			// recupero istanza dalla cache
			if(HttpContext.Current.Cache.Get(CACHE_PREFIX+beanName) != null)
			{
				instance = (T)HttpContext.Current.Cache.Get(CACHE_PREFIX+beanName);
				return (T)instance;
			}
			
			mappingSet.TryGetValue(beanName, out instance);				
			if(instance != null){
				HttpContext.Current.Cache.Insert(CACHE_PREFIX+beanName, instance, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				return (T)instance;
			}
			
			instance = getNew(beanName);

			if(instance != null){
				lock (_Padlock)
				{
					mappingSet[beanName] = instance;
				}			
				HttpContext.Current.Cache.Insert(CACHE_PREFIX+beanName, instance, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return (T)instance;
			//System.Web.HttpContext.Current.Response.Write("classMapping: "+classMapping.ToString()+"<br>");	
		}
		
		static void createMapping()
		{			
			IList<RepositoryMapping> mappings = reposervice.getAllRepositoryMappings();
			foreach(RepositoryMapping r in mappings)
			{
				if(!String.IsNullOrEmpty(r.lazy) && Convert.ToBoolean(r.lazy)){continue;}
				
				lock (_Padlock)
				{					
				mappingSet.Add(r.key,assembly.CreateInstance(r.value));
				}			
			}		
		}
		
		static object getNew(string beanName)
		{					
			return assembly.CreateInstance(reposervice.get(beanName).value);		
		}	
	}
}