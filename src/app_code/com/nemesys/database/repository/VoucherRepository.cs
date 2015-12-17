using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.exception;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Web.Caching;

namespace com.nemesys.database.repository
{
	public class VoucherRepository : IVoucherRepository
	{		
		public void insert(VoucherCampaign voucherCampaign)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(voucherCampaign);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(VoucherCampaign voucherCampaign)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(voucherCampaign);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(VoucherCampaign voucherCampaign)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from VoucherCode where campaign=:campaign").SetInt32("campaign",voucherCampaign.id).ExecuteUpdate();
				session.Delete(voucherCampaign);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public VoucherCampaign getById(int id)
		{
			VoucherCampaign voucher = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				voucher = session.Get<VoucherCampaign>(id);					

				NHibernateHelper.closeSession();
			}
			
			return voucher;
		}	
		
		public VoucherCampaign getByLabel(string label)
		{
			VoucherCampaign voucher = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				voucher = session.CreateQuery("from VoucherCampaign where label=:label").SetString("label",label).UniqueResult<VoucherCampaign>();	
				NHibernateHelper.closeSession();
			}
			
			return voucher;			
		}

		public IList<VoucherCampaign> find(string type, int active)
		{
			IList<VoucherCampaign> results = null;

			string strSQL = "from VoucherCampaign where 1=1";
			
			if (!String.IsNullOrEmpty(type)){			
				List<string> ids = new List<string>();
				string[] trtype = type.Split(',');
				foreach(string r in trtype){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and type in({0})",string.Join(",",ids.ToArray()));}
			}
			
			if (active>-1){
				strSQL += " and active=:active";
			}
			strSQL += " order by type asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{	
				IQuery q = session.CreateQuery(strSQL);
				if (active>-1){
					q.SetBoolean("active", Convert.ToBoolean(active));
				}				
				
				results = q.List<VoucherCampaign>();
				NHibernateHelper.closeSession();
			}
						
			return results;		
		}			
		
		
		//************ MANAGE VOUCHER CODE ************
		public void insertVoucherCode(VoucherCode voucherCode)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(voucherCode);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateVoucherCode(VoucherCode voucherCode)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(voucherCode);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteVoucherCode(VoucherCode voucherCode)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Delete(voucherCode);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public void deleteVoucherCodeByCampaign(int voucherCampaign)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from VoucherCode where campaign=:campaign").SetInt32("campaign",voucherCampaign).ExecuteUpdate();
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public VoucherCode getVoucherCodeById(int id)
		{
			VoucherCode voucherCode = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				voucherCode = session.Get<VoucherCode>(id);					

				NHibernateHelper.closeSession();
			}
			
			return voucherCode;
		}	
		
		public VoucherCode getVoucherCodeByCode(string code)
		{
			VoucherCode voucherCode = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				voucherCode = session.CreateQuery("from VoucherCode where code=:code").SetString("code",code).UniqueResult<VoucherCode>();	
				NHibernateHelper.closeSession();
			}
			
			return voucherCode;			
		}
		
		public IList<VoucherCode> findVoucherCode(int voucherCampaign)
		{
			IList<VoucherCode> results = null;
			
			string strSQL = "from VoucherCode where campaign=:campaign order by id desc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				try
				{		
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("campaign",voucherCampaign);				
					results = q.List<VoucherCode>();
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				NHibernateHelper.closeSession();
			}
						
			return results;		
		}			
	}
}