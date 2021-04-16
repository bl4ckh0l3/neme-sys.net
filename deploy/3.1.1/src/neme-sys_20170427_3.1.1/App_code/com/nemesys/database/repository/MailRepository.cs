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
	public class MailRepository : IMailRepository
	{	
		//private IList<AvailableLanguage> availableLanguages = null;
	
		public void insert(MailMsg mail)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				//try
				//{
					mail.modifyDate=DateTime.Now;		
					session.Save(mail);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(MailMsg mail)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				//try
				//{	
					mail.modifyDate=DateTime.Now;				
					session.Update(mail);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(MailMsg mail)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(mail);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void saveCompleteMailMsg(MailMsg mail, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					mail.modifyDate=DateTime.Now;
					if(mail.id != -1){
						session.Update(mail);
					}else{
						session.Save(mail);
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
					//Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;	
				}
			}			
		}
	
		public MailMsg getById(int id)
		{
			MailMsg element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<MailMsg>(id);
				NHibernateHelper.closeSession();
			}	
			return element;	
		}

		public MailMsg getByName(string name, string langCode)
		{
			return getByName(name, langCode, true);
		}
		
		public MailMsg getByName(string name, string langCode, Nullable<bool> active)
		{
			MailMsg result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				//System.Web.HttpContext.Current.Response.Write("<b>start: getByName</b><br>");
				string strSQL = "from MailMsg where name=:name";			
				if (!String.IsNullOrEmpty(langCode)){			
					strSQL += " and langCode=:langCode";
				}			
				if (active != null){			
					strSQL += " and isActive=:active";
				}		
				IQuery q = session.CreateQuery(strSQL);
				q.SetString("name",name);
				if (!String.IsNullOrEmpty(langCode)){			
					q.SetString("langCode",langCode);
				}	
				if (active != null){			
					q.SetBoolean("active",Convert.ToBoolean(active));
				}
				try
				{	
					result = q.UniqueResult<MailMsg>();
				}catch(Exception ex){result=null;}
				//************ eseguo il cascade sul default senza lingua se non ho ottenuto risultati
				if(result==null && !String.IsNullOrEmpty(langCode))
				{
					strSQL = "from MailMsg where name=:name";			
					if (active != null){			
						strSQL += " and isActive=:active";
					}	
					q = session.CreateQuery(strSQL);
					q.SetString("name",name);	
					if (active != null){			
						q.SetBoolean("active",Convert.ToBoolean(active));
					}
					try
					{	
					result = q.UniqueResult<MailMsg>();
					}catch(Exception ex){result=null;}
				}
				
				NHibernateHelper.closeSession();
				//System.Web.HttpContext.Current.Response.Write("<b>result</b>:"+result.ToString()+"<br>");
			}			
			return result;
		}
	
		public IList<MailMsg> findByCategory(string name)
		{
			IList<MailMsg> results = null;		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{					
				IQuery q = session.CreateQuery("from MailMsg where mailCategory=:name order by mailCategory, name asc");
				q.SetString("name",name);				
				results = q.List<MailMsg>();
				NHibernateHelper.closeSession();	
			}				
			return results;
		}
				
		public bool mailAlreadyExists(string name, string langCode, int mailid)
		{			
			bool exist = false;
			IList<MailMsg> mails = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from MailMsg where name= :name and langCode=:langCode and id != :mailid");
				q.SetString("name",name);	
				q.SetString("langCode",langCode);	
				q.SetInt32("mailid",mailid);	
				mails = q.List<MailMsg>();
				NHibernateHelper.closeSession();					
			}				
			if(mails!=null && mails.Count >0)
			{
				exist=true;
			}			
			return exist;							
		}
	
		public IList<MailMsg> findActive()
		{
			IList<MailMsg> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from MailMsg as mail where active=1 order by mail.mailCategory, name asc";				
				IQuery q = session.CreateQuery(strSQL);
				results = q.List<MailMsg>();
				NHibernateHelper.closeSession();
			}
			return results;	
		}
	
		public IList<MailCategory> findCategories()
		{
			IList names = null;
			IList<MailCategory> results = null;					
			string strSQL = "select distinct mail_category from MAIL where not isnull(mail_category) order by mail_category asc";			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL+"<br>");
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("mail_category", NHibernateUtil.String);				
				names = q.List();
				//System.Web.HttpContext.Current.Response.Write("results!=null: " + results!=null +"<br>");				
				NHibernateHelper.closeSession();
			}				
			if(names!=null)
			{
				results = new List<MailCategory>();
				foreach(string x in names)
				{					
					results.Add(new MailCategory(x));
				}
			}
			return results;	
		}

		public IList<MailMsg> find(Nullable<bool> active, string category, int pageIndex, int pageSize,out long totalCount)
		{		
			IList<MailMsg> mails = null;		
			totalCount = 0;
			
			string strSQL = "from MailMsg where 1=1 ";
			if (active != null){			
				strSQL += " and active=:active";
			}	
			if (!String.IsNullOrEmpty(category)){			
				strSQL += " and mailCategory=:category";
			}		
			strSQL +=" order by mailCategory, name asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (active != null){
						q.SetBoolean("active", Convert.ToBoolean(active));
						qCount.SetBoolean("active", Convert.ToBoolean(active));
					}	
					if (!String.IsNullOrEmpty(category)){			
						q.SetString("category", category);
						qCount.SetString("category", category);
					}
					mails = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
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
			return mails;
		}
	
		protected IList<MailMsg> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<MailMsg> records = new List<MailMsg>();	
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
						records.Add((MailMsg)tmp);
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