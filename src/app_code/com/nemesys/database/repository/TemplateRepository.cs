using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
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
	public class TemplateRepository : ITemplateRepository
	{		
		public void insert(Template template)
		{
			bool carryOn = true;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery qCount;				
				List<string> urls = new List<string>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage value in template.pages){
						if(!String.IsNullOrEmpty(value.urlRewrite)){
						urls.Add("'"+value.urlRewrite+"'");
						}
					}	
				}	
								
				if(urls.Count>0){
					string strSQLCount = "select count(DISTINCT id) as count from TEMPLATE_PAGES where 1=1";
					strSQLCount+=string.Format(" and url_rewrite in ({0})",string.Join(",",urls.ToArray()));
					qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64);
					long counter = qCount.UniqueResult<long>();
					
					if(counter>0)
					{
						tx.Rollback();
						NHibernateHelper.closeSession();
						carryOn = false;
						throw new Exception("one of specified url rewrite already exists!");
					}
				}

				IList<TemplatePage> newTemplatePages = new List<TemplatePage>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage k in template.pages){
						TemplatePage ntp = new TemplatePage();
						//ntp.templateId = k.templateId
						ntp.filePath = k.filePath;
						ntp.fileName = k.fileName;
						ntp.urlRewrite = k.urlRewrite;
						ntp.priority = k.priority;							
						newTemplatePages.Add(ntp);
					}
					template.pages.Clear();							
				}
				
				template.modifyDate=DateTime.Now;
				session.Save(template);

				if(newTemplatePages != null && newTemplatePages.Count>0)
				{							
					foreach(TemplatePage k in newTemplatePages){
						k.templateId = template.id;
						session.Save(k);
					}
				}

				
				if(carryOn){
					tx.Commit();
				}
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Template template)
		{
			bool carryOn = true;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery qCount;				
				List<string> urls = new List<string>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage value in template.pages){
						if(!String.IsNullOrEmpty(value.urlRewrite)){
						urls.Add("'"+value.urlRewrite+"'");
						}
					}	
				}	
								
				if(urls.Count>0){
					string strSQLCount = "select count(DISTINCT id) as count from TEMPLATE_PAGES where templateid!=:templateid";
					strSQLCount+=string.Format(" and url_rewrite in ({0})",string.Join(",",urls.ToArray()));
					qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64).SetInt32("templateid",template.id);
					long counter = qCount.UniqueResult<long>();
					
					if(counter>0)
					{
						tx.Rollback();
						NHibernateHelper.closeSession();
						carryOn = false;
						throw new Exception("one of specified url rewrite already exists!");
					}
				}	

				IList<TemplatePage> newTemplatePages = new List<TemplatePage>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage k in template.pages){
						TemplatePage ntp = new TemplatePage();
						ntp.templateId = k.templateId;						
						ntp.filePath = k.filePath;
						ntp.fileName = k.fileName;
						ntp.urlRewrite = k.urlRewrite;
						ntp.priority = k.priority;						
						newTemplatePages.Add(ntp);
					}
					template.pages.Clear();							
				}
				
				template.modifyDate = DateTime.Now;
				session.Update(template);	
																		
				session.CreateQuery("delete from TemplatePage where templateId = :templateId").SetInt32("templateId",template.id).ExecuteUpdate();
					
				if(newTemplatePages != null && newTemplatePages.Count>0)
				{							
					foreach(TemplatePage k in newTemplatePages){
						k.templateId = template.id;
						session.Save(k);
					}
				}
				
				if(carryOn){
					tx.Commit();
				}
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("template-"+template.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("template-directory-"+template.directory))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("template-urlrewrite-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("templatepage-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void delete(Template template)
		{
			try{
				using (ISession session = NHibernateHelper.getCurrentSession())
				using (ITransaction tx = session.BeginTransaction())
				{
					if(template.pages != null && template.pages.Count>0)
					{
						session.CreateQuery("delete from TemplatePage where templateId = :templateId").SetInt32("templateId",template.id).ExecuteUpdate();
						template.pages.Clear();						
					}
					session.CreateQuery("update Category set idTemplate=-1 where idTemplate=:templateId").SetInt32("templateId",template.id).ExecuteUpdate();
					session.CreateQuery("delete from CategoryTemplate where templateId = :templateId").SetInt32("templateId",template.id).ExecuteUpdate();								
					session.Delete(template);	
					tx.Commit();
					NHibernateHelper.closeSession();
				}
			
				//rimuovo cache		
				IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
				while (CacheEnum.MoveNext())
				{		  
					string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
					if(cacheKey.Contains("template-"+template.id))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					}				 
					else if(cacheKey.Contains("template-directory-"+template.directory))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					}				 
					else if(cacheKey.Contains("template-urlrewrite-"))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					} 
					else if(cacheKey.Contains("category-"))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					} 							
					else if(cacheKey.Contains("list-category"))
					{ 	
						HttpContext.Current.Cache.Remove(cacheKey);
					} 				 
					else if(cacheKey.Contains("templatepage-"))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					}
				}
				
				//cancello la directory fisica del template
				//string tpath = HttpContext.Current.Server.MapPath("~/public/templates/"+template.directory);
				//if(Directory.Exists(tpath)) 
				//{
					//Directory.Delete(tpath, true);
				//}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}			
		}		
		
		public void clone(Template template, string newdir)
		{
			bool carryOn = true;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery qCount;				
				List<string> urls = new List<string>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage value in template.pages){
						if(!String.IsNullOrEmpty(value.urlRewrite)){
						urls.Add("'"+value.urlRewrite+"'");
						}
					}	
				}	
								
				if(urls.Count>0){
					string strSQLCount = "select count(DISTINCT id) as count from TEMPLATE_PAGES where templateid!=:templateid";
					strSQLCount+=string.Format(" and url_rewrite in ({0})",string.Join(",",urls.ToArray()));
					qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64).SetInt32("templateid",template.id);
					long counter = qCount.UniqueResult<long>();
					
					if(counter>0)
					{
						tx.Rollback();
						NHibernateHelper.closeSession();
						carryOn = false;
						throw new Exception("one of specified url rewrite already exists!");
					}
				}				

				Template newtemplate = new Template();
				newtemplate.directory = newdir;
				newtemplate.description = newdir;
				newtemplate.isBase = template.isBase;
				newtemplate.elemXpage = template.elemXpage;
				newtemplate.orderBy = template.orderBy;
				newtemplate.pages = new List<TemplatePage>();

				IList<TemplatePage> newTemplatePages = new List<TemplatePage>();
				if(template.pages != null && template.pages.Count>0)
				{
					foreach(TemplatePage k in template.pages){
						TemplatePage ntp = new TemplatePage();					
						ntp.filePath=k.filePath.Replace(template.directory,newdir);
						ntp.fileName = k.fileName;
						ntp.urlRewrite = "";
						ntp.priority = k.priority;						
						newTemplatePages.Add(ntp);
					}
					newtemplate.pages.Clear();							
				}

				newtemplate.modifyDate=DateTime.Now;
				session.Save(newtemplate);
				//System.Web.HttpContext.Current.Response.Write("<br>after save template: " + template.ToString()+"<br>");	
				
				if(newTemplatePages != null && newTemplatePages.Count>0)
				{							
					foreach(TemplatePage k in newTemplatePages){
						k.templateId = newtemplate.id;
						session.Save(k);
					}
				}
				
				if(carryOn){
					tx.Commit();
				}
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("template-urlrewrite-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("templatepage-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public Template getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public Template getByIdCached(int id, bool cached)
		{	
			Template template = null;	

			if(cached)
			{
				template = (Template)HttpContext.Current.Cache.Get("template-"+id);				
				if(template != null){
					return template;
				}
			}
						
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				template = session.Get<Template>(id);
				if(template != null){				
					template.pages = session.CreateCriteria(typeof(TemplatePage))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("templateId", template.id))
					.AddOrder(Order.Asc("priority"))
					.List<TemplatePage>();
				}
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(template == null){
					template = new Template();
					template.id=-1;
				}
				HttpContext.Current.Cache.Insert("template-"+template.id, template, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return template;
		}	

		public TemplatePage getByUrlRewrite(string urlRewrite)
		{
			return getByUrlRewriteCached(urlRewrite, false);
		}

		public TemplatePage getByUrlRewriteCached(string urlRewrite, bool cached)
		{
			TemplatePage tp = null;

			if(cached)
			{
				tp = (TemplatePage)HttpContext.Current.Cache.Get("template-urlrewrite-"+Utils.encodeTo64(urlRewrite));
				if(tp != null){
					return tp;
				}
			}
						
			if(!String.IsNullOrEmpty(urlRewrite)){
				using (ISession session = NHibernateHelper.getCurrentSession())
				{
					string strSQL = "select {t.*} from TEMPLATE_PAGES {t} where {t}.id IN(select templatepageid from CATEGORY_TEMPLATES where url_rewrite= :urlRewrite)";
					//System.Web.HttpContext.Current.Response.Write("<b>strSQL: </b>"+strSQL+"<br>");
					
					IQuery q = session.CreateSQLQuery(strSQL).AddEntity ("t", typeof(TemplatePage));
					q.SetString("urlRewrite",urlRewrite);	
					tp = q.UniqueResult<TemplatePage>();
					
					if(tp==null){				
						strSQL = "select {t.*} from TEMPLATE_PAGES {t} where url_rewrite= :urlRewrite";
						//System.Web.HttpContext.Current.Response.Write("<b>strSQL: </b>"+strSQL+"<br>");
						q = session.CreateSQLQuery(strSQL).AddEntity ("t", typeof(TemplatePage));
						q.SetString("urlRewrite",urlRewrite);	
						tp = q.UniqueResult<TemplatePage>();
					}
					
					NHibernateHelper.closeSession();					
				}	
			}
			
			if(cached)
			{
				if(tp == null){
					tp = new TemplatePage();
					tp.id=-1;
				}
				HttpContext.Current.Cache.Insert("template-urlrewrite-"+Utils.encodeTo64(urlRewrite), tp, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return tp;		
		}

		public Template getByDirectory(string directory)
		{
			return getByDirectoryCached(directory, false);
		}
		
		public Template getByDirectoryCached(string directory, bool cached)
		{
			Template result = null;

			if(cached)
			{
				result = (Template)HttpContext.Current.Cache.Get("template-directory-"+Utils.encodeTo64(directory));
				if(result != null){
					return result;
				}
			}
			
			IList<Template> templates = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				IQuery q = session.CreateQuery("from Template where directory=:directory");
				q.SetString("directory",directory);	
				templates = q.List<Template>();
				
				if(templates!=null)
				{
					//System.Web.HttpContext.Current.Response.Write("templates.Count:"+templates.Count+"<br>");
					if(templates.Count!=1)
					{
						result = null;
					}else
					{
						foreach(Template t in templates){
							result = t;
							//System.Web.HttpContext.Current.Response.Write("t:"+t.ToString()+"<br>");
							result.pages = session.CreateCriteria(typeof(TemplatePage))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("templateId", result.id))
							.AddOrder(Order.Asc("priority"))
							.List<TemplatePage>();	
							break;
						}				
					}
				}
				else
				{
					result = null;	
				}
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new Template();
					result.id=-1;
				}
				HttpContext.Current.Cache.Insert("template-directory-"+Utils.encodeTo64(directory), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
								
			return result;
		}	
	
		public IList<Template> getTemplateList()
		{
			IList<Template> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Template order by  description asc";				
				IQuery q = session.CreateQuery(strSQL);					
				results = q.List<Template>();
				NHibernateHelper.closeSession();
			}			
			return results;	
		}

		public IList<Template> find(int pageIndex, int pageSize,out long totalCount)
		{
			IList<Template> templates = null;		
			totalCount = 0;	
			string strSQL = "from Template order by description asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					templates = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return templates;		
		}
	
		protected IList<Template> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Template> records = new List<Template>();	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				IList recordstmp = (IList)results[0];
				totalCount = (long)((IList)results[1])[0];

				if(recordstmp != null)
				{
					foreach(Object tmp in recordstmp)
					{
						records.Add((Template)tmp);
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
		
		public TemplatePage getPageById(int id)
		{			
			return getPageByIdCached(id, false);		
		}
		
		public TemplatePage getPageByIdCached(int id, bool cached)
		{	
			TemplatePage page = null;		

			if(cached)
			{
				page = (TemplatePage)HttpContext.Current.Cache.Get("templatepage-"+id);				
				if(page != null){
					return page;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				page = session.Get<TemplatePage>(id);
				NHibernateHelper.closeSession();
			}
			
			if(cached && page != null)
			{
				if(page == null){
					page = new TemplatePage();
					page.id=-1;
				}
				HttpContext.Current.Cache.Insert("templatepage-"+page.id, page, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return page;			
		}
		
		public TemplatePage findByPriority(int templateId, int priority)
		{
			TemplatePage page = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				IQuery q = session.CreateQuery("from TemplatePage where templateId=:templateId and priority=:priority");
				q.SetInt32("templateId",templateId);	
				q.SetInt32("priority",priority);
				page = q.UniqueResult<TemplatePage>();
				NHibernateHelper.closeSession();
			}		
			return page;
		}	

		public IList<TemplatePage> getTemplatePages(int templateId)
		{
			IList<TemplatePage> pages = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from TemplatePage where templateId= :templateId");
				q.SetInt32("templateId",templateId);	
				pages = q.List<TemplatePage>();
				NHibernateHelper.closeSession();					
			}	
			return pages;		
		}		

		public void deleteTemplatePage(TemplatePage page)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Delete(page);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//cancello il file fisico della template page
			//string tpath = HttpContext.Current.Server.MapPath(page.filePath+page.fileName);
			//if(File.Exists(tpath)) 
			//{
			//	File.Delete(tpath);
			//}		
		}

		public void updateTemplatePage(TemplatePage page)
		{
			bool carryOn = true;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery qCount;				
				List<string> urls = new List<string>();
				if(!String.IsNullOrEmpty(page.urlRewrite)){
				urls.Add("'"+page.urlRewrite+"'");
				}
								
				if(urls.Count>0){
					string strSQLCount = "select count(DISTINCT id) as count from TEMPLATE_PAGES where templateid!=:templateid";
					strSQLCount+=string.Format(" and url_rewrite in ({0})",string.Join(",",urls.ToArray()));
					qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64).SetInt32("templateid",page.templateId);
					long counter = qCount.UniqueResult<long>();
					
					if(counter>0)
					{
						tx.Rollback();
						NHibernateHelper.closeSession();
						carryOn = false;
						throw new Exception("one of specified url rewrite already exists!");
					}
				}			
							
				session.Update(page);	
				if(carryOn){
					tx.Commit();
				}
				NHibernateHelper.closeSession();
			}

			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("template-"+page.templateId))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("template-urlrewrite-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 							
				else if(cacheKey.Contains("list-category"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}			
		}
		
		public int findMaxPriority(int templateId)
		{	
			int maxPriority = 0;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{						
				string strSQLCount = "SELECT MAX(priority) AS priority FROM TEMPLATE_PAGES WHERE templateid=:templateid";						
				IQuery qCount = session.CreateSQLQuery(strSQLCount).AddScalar("priority", NHibernateUtil.Int64);
				qCount.SetInt32("templateid",templateId);
				maxPriority = (int)qCount.UniqueResult<long>();
				NHibernateHelper.closeSession();
			}
			return 	maxPriority;		
		}
		
		public int findMaxPriority(Template template)
		{
			int maxPriority = 0;					
			if(template.pages != null)
			{
				foreach(TemplatePage t in template.pages)
				{
					if(t.priority>maxPriority)
					{
						maxPriority=t.priority;
					}
				}
			}			
			return 	maxPriority;
		}
	}
}