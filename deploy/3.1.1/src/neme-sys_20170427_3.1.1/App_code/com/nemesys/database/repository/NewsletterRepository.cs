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
	public class NewsletterRepository : INewsletterRepository
	{		
		public void insert(Newsletter newsletter)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				newsletter.modifyDate=DateTime.Now;
				session.Save(newsletter);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Newsletter newsletter)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				newsletter.modifyDate=DateTime.Now;	
				session.Update(newsletter);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Newsletter newsletter)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(newsletter);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
	
		public Newsletter getById(int id)
		{
			Newsletter element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Newsletter>(id);	
				NHibernateHelper.closeSession();
			}	
			return element;	
		}

		public IList<Newsletter> findActive()
		{
			IList<Newsletter> newsletters = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery("from Newsletter where isActive=1 order by description asc");
				newsletters =q.List<Newsletter>();
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return newsletters;			
		}
		
		public int findSubscribed(int idNewsletter)
		{	
			int totalCount = 0;			
			
			IList<UserNewsletter> unewsletters = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery("from UserNewsletter where newsletterId=:idNewsletter order by newsletterId asc").SetInt32("idNewsletter",idNewsletter);
				unewsletters =q.List<UserNewsletter>();
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			if(unewsletters != null && unewsletters.Count>0)
			{
				totalCount=unewsletters.Count;
			}
			
			return totalCount;
		}

		public IList<Newsletter> find(int pageIndex, int pageSize,out long totalCount)
		{		
			IList<Newsletter> newsletters = null;		
			totalCount = 0;	
			string strSQL = "from Newsletter order by description asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					newsletters = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return newsletters;
		}		
	
		protected IList<Newsletter> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Newsletter> records = new List<Newsletter>();	
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
						records.Add((Newsletter)tmp);
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