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
		
		public void registerBilling(Billing billing)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				IQuery qpCount = session.CreateSQLQuery("select MAX(id_registered_billing) as registernum from BILLING").AddScalar("registernum", NHibernateUtil.Int32);
				int result = qpCount.UniqueResult<int>();	
				
				billing.idRegisteredBilling = result+1;
				billing.registeredDate = DateTime.Now;
				
				session.Update(billing);	
				tx.Commit();
				NHibernateHelper.closeSession();
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
			string strSQL = "from Billing order by registeredDate desc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);	
				try
				{
					billings = q.List<Billing>();
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

		public Billing find(int orderId)
		{		
			Billing billing = null;		
			string strSQL = "from Billing where idParentOrder=:orderId";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					q.SetInt32("orderId", Convert.ToInt32(orderId));
					billing = q.UniqueResult<Billing>();
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
					billing = null;
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
			return billing;
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