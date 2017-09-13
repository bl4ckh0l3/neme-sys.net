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
	public class BillingRepository : IBillingRepository
	{		
		public void insert(Billing billing)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(billing);		
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Billing billing)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				session.Update(billing);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Billing billing)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(billing);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}

		public void saveCompleteBilling(Billing billing, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(billing.id != -1){
						session.Update(billing);	
					}else{
						session.Save(billing);
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
	
		public Billing getById(int id)
		{
			Billing element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Billing>(id);
				NHibernateHelper.closeSession();
			}	
			return element;	
		}

		public IList<Billing> findAll()
		{		
			IList<Billing> billings = null;		
			string strSQL = "from Billing order by insertDate desc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);	
				try
				{
					billings = q.List<Billing>();
					//System.Web.HttpContext.Current.Response.Write("currencies.Count: " + currencies.Count+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					billings = new List<Billing>();
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return billings;
		}

		public IList<Billing> find(int orderId)
		{		
			IList<Billing> billings = null;		
			string strSQL = "from Billing where orderId=:orderId order by insertDate desc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					q.SetInt32("orderId", Convert.ToInt32(orderId));
					billings = q.List<Billing>();
					//System.Web.HttpContext.Current.Response.Write("currencies.Count: " + currencies.Count+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
					billings = null;
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return billings;
		}	
		
		public void insertBillingData(BillingData value)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(value);		
				tx.Commit();
				NHibernateHelper.closeSession();
			}		
		}
		
		public void updateBillingData(BillingData value)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				session.Update(value);
				tx.Commit();
				NHibernateHelper.closeSession();
			}		
		}
		
		public void deleteBillingData(BillingData value)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(value);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}		
		}	
		
		public void saveBillingData(BillingData value)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from BillingData").ExecuteUpdate();
				session.Save(value);		
				tx.Commit();
				NHibernateHelper.closeSession();
			}		
		}
			
		public BillingData getBillingData()
		{
			BillingData result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{		
				IQuery q = session.CreateQuery("from BillingData");
				result = q.UniqueResult<BillingData>();
				NHibernateHelper.closeSession();
			}	
			return result;
		}	
	}
}