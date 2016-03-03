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
	public class CurrencyRepository : ICurrencyRepository
	{		
		public void insert(Currency currency)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				//try
				//{		
					session.Save(currency);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Currency currency)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				//try
				//{		
					session.Update(currency);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Currency currency)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(currency);	

				/*IList<UserLanguage> languages = session.CreateCriteria(typeof(UserLanguage))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idLanguage", language.id))
				.List<UserLanguage>();			
				if(languages != null)
				{
					foreach (UserLanguage k in languages)
					{
						session.Delete(k);
					} 
				}*/
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}

		public void saveCompleteCurrency(Currency currency, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(currency.id != -1){
						session.Update(currency);	
					}else{
						session.Save(currency);
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
			
		public Currency findDefault()
		{
			Currency result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{		
				IQuery q = session.CreateQuery("from Currency where isDefault=1");
				result = q.UniqueResult<Currency>();
				NHibernateHelper.closeSession();
			}	
			return result;
		}

		public Currency getByCurrency(string currency)
		{
			Currency result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{			
				IQuery q = session.CreateQuery("from Currency where currency= :currency");
				q.SetString("currency",currency);
				result = q.UniqueResult<Currency>();
				NHibernateHelper.closeSession();
			}		
			return result;	
		}
	
		public Currency getById(int id)
		{
			Currency element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Currency>(id);
				NHibernateHelper.closeSession();
			}	
			return element;	
		}
		
		public decimal convertCurrency(decimal amount, string currencyFrom, string currencyTo)
		{
			if(String.IsNullOrEmpty(currencyFrom) || String.IsNullOrEmpty(currencyTo)){
				return amount;
			}
				
			decimal result = 0.00M;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{	
				IQuery q = session.CreateSQLQuery("select c2.rate/c1.rate as rate from CURRENCY as c1 inner join CURRENCY as c2 where c1.currency=:currencyFrom and c2.currency=:currencyTo");
				q.SetString("currencyFrom",currencyFrom);
				q.SetString("currencyTo",currencyTo);
				result = q.UniqueResult<decimal>();
				NHibernateHelper.closeSession();
			}	
			result = amount*(result);			
			return result;
		}

		public IList<Currency> findAll(Nullable<bool> active)
		{		
			IList<Currency> currencies = null;		
			string strSQL = "from Currency where 1=1";			
			if (active != null){			
				strSQL += " and active=:active";
			}	
			strSQL +=" order by currency asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);	
				try
				{
					if (active != null){
						q.SetBoolean("active", Convert.ToBoolean(active));
					}
					currencies = q.List<Currency>();
					//System.Web.HttpContext.Current.Response.Write("currencies.Count: " + currencies.Count+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					currencies = new List<Currency>();
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return currencies;
		}

		public IList<Currency> find(string currency, Nullable<bool> active, int pageIndex, int pageSize,out long totalCount)
		{		
			IList<Currency> currencies = null;		
			totalCount = 0;	
			string strSQL = "from Currency where 1=1";
			if (!String.IsNullOrEmpty(currency)){			
				strSQL += " and currency=:currency";
			}			
			if (active != null){			
				strSQL += " and active=:active";
			}	
			strSQL +=" order by currency asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (!String.IsNullOrEmpty(currency)){
						q.SetString("currency", currency);
						qCount.SetString("currency", currency);
					}
					if (active != null){
						q.SetBoolean("active", Convert.ToBoolean(active));
						qCount.SetBoolean("active", Convert.ToBoolean(active));
					}
					currencies = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
					//System.Web.HttpContext.Current.Response.Write("currencies.Count: " + currencies.Count+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return currencies;
		}
	
		protected IList<Currency> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Currency> records = new List<Currency>();	
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
						records.Add((Currency)tmp);
					}
				}
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("getByQuery - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: RETURN NULL
			}
			return records;
		}		
	}
}