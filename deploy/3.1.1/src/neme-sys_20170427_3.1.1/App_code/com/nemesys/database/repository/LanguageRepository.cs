using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using System.IO;
using System.Web.Caching;
using com.nemesys.model;
using com.nemesys.database;

namespace com.nemesys.database.repository
{
	public class LanguageRepository : ILanguageRepository
	{	
		//private IList<AvailableLanguage> availableLanguages = null;
	
		public void insert(Language language)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(language);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("language-"+language.label);
			HttpContext.Current.Cache.Remove("list-language");				
			HttpContext.Current.Cache.Remove("list-active-language");
		}
		
		public void update(Language language)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(language);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("language-"+language.label);
			HttpContext.Current.Cache.Remove("list-language");				
			HttpContext.Current.Cache.Remove("list-active-language");
		}
		
		public void delete(Language language)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.CreateQuery("delete from UserLanguage where idLanguage = :idLanguage").SetInt32("idLanguage",language.id).ExecuteUpdate();			
				session.Delete(language);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("language-"+language.label);
			HttpContext.Current.Cache.Remove("list-language");				
			HttpContext.Current.Cache.Remove("list-active-language");
		}

		public void saveCompleteLanguage(Language language, IList<User> usersToUpdate)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(language.id != -1){
						session.Update(language);
					}else{
						session.Save(language);
					}	
					// ************** PERSISTO LINGUE X UTENTI					
					if(usersToUpdate != null && usersToUpdate.Count>0){						
						foreach (User u in usersToUpdate){
							if(u.languages != null)
							{
								IList<UserLanguage> newULangs = new List<UserLanguage>();
								foreach (UserLanguage k in u.languages)
								{
									UserLanguage nut = new UserLanguage();
									nut.idLanguage = k.idLanguage;
									if(k.idLanguage == -1){
										nut.idLanguage = language.id;
									}
									nut.idParentUser = k.idParentUser;						
									newULangs.Add(nut);
								}
								u.modifyDate = DateTime.Now;
								u.languages.Clear();
								session.Update(u);
													
								string sql = "delete from UserLanguage where idParentUser = :idParentUser";
								session.CreateQuery(sql).SetInt32("idParentUser",u.id).ExecuteUpdate();			
								if(newULangs != null && newULangs.Count>0)
								{						
									foreach(UserLanguage ut in newULangs){
										session.Save(ut);
									}
								}
							}
						}
					}						
					
					tx.Commit();
					NHibernateHelper.closeSession();		
				}catch(Exception exx){
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}
			HttpContext.Current.Cache.Remove("language-"+language.label);	
			HttpContext.Current.Cache.Remove("list-language");				
			HttpContext.Current.Cache.Remove("list-active-language");
		}
	
		public IList<AvailableLanguage> getAvailableLanguageList()
		{
			IList<AvailableLanguage> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{			
				IQuery q = session.CreateQuery("from AvailableLanguage as availableLanguage order by description");
				results = q.List<AvailableLanguage>();
				NHibernateHelper.closeSession();
			}		
			return results;	
		}
	
		public IList<Language> getLanguageList()
		{
			return getLanguageList(false);
		}
	
		public IList<Language> getLanguageList(bool cached)
		{
			IList<Language> results = null;
			if(cached)
			{
				results = (IList<Language>)HttpContext.Current.Cache.Get("list-language");
				if(results != null){
					return results;
				}
			}
			using (ISession session = NHibernateHelper.getCurrentSession())
			{		
				IQuery q = session.CreateQuery("from Language as language order by description");
				results = q.List<Language>();
				NHibernateHelper.closeSession();
			}	
			if(cached)
			{
				if(results == null){
					results = new List<Language>();
				}
				HttpContext.Current.Cache.Insert("list-language", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}	
			return results;	
		}
	
		public IList<Language> findActive()
		{
			return findActive(false);
		}
			
		public IList<Language> findActive(bool cached)
		{
			IList<Language> results = null;
			
			if(cached)
			{
				results = (IList<Language>)HttpContext.Current.Cache.Get("list-active-language");
				if(results != null){
					return results;
				}
			}			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{			
				IQuery q = session.CreateQuery("from Language as language where langActive=1 order by description");
				results = q.List<Language>();
				NHibernateHelper.closeSession();
			}
			if(cached)
			{
				if(results == null){
					results = new List<Language>();
				}
				HttpContext.Current.Cache.Insert("list-active-language", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}			
			return results;	
		}

		public Language getByLabel(string label)
		{
			return getByLabel(label, false);
		}
		
		public Language getByLabel(string label, bool cached)
		{
			Language result = null;
			if(cached)
			{
				result = (Language)HttpContext.Current.Cache.Get("language-"+label);
				if(result != null){
					return result;
				}
			}			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{		
				IQuery q = session.CreateQuery("from Language as language where label= :label order by description");
				q.SetString("label",label);
				result = q.UniqueResult<Language>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new Language();
					result.id=-1;
				}
				HttpContext.Current.Cache.Insert("language-"+result.label, result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}			
			return result;			
		}
	
		public Language getById(int id)
		{	
			Language element = null;				
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Language>(id);	
				NHibernateHelper.closeSession();
			}
			return element;		
		}

		public IList<Language> find(int pageIndex, int pageSize,out long totalCount)
		{		
			IList<Language> languages = null;		
			totalCount = 0;	
			string strSQL = "from Language order by description";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					languages = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
					//System.Web.HttpContext.Current.Response.Write("languages.Count: " + languages.GetType()+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			return languages;
		}
	
		protected IList<Language> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Language> records = new List<Language>();	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				IList recordstmp = (IList)results[0];
				//System.Web.HttpContext.Current.Response.Write("pageIndex: " + pageIndex + " - pageSize:"+pageSize+"<br>");
				//System.Web.HttpContext.Current.Response.Write("query: " + query +"<br>");
				//System.Web.HttpContext.Current.Response.Write("queryCount: " + queryCount +"<br>");
				totalCount = (long)((IList)results[1])[0];
				//System.Web.HttpContext.Current.Response.Write("records.Count: " + records.Count + " - totalCount:"+totalCount+"<br>");

				if(recordstmp != null)
				{
					foreach(Object tmp in recordstmp)
					{
						records.Add((Language)tmp);
					}
				}
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: RETURN NULL
			}
			return records;
		}		
	}
}