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
	public class BusinessRuleRepository : IBusinessRuleRepository
	{		
		public void insert(BusinessRule businessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(businessRule);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(BusinessRule businessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(businessRule);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(BusinessRule businessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from BusinessRuleConfig where ruleId=:ruleId").SetInt32("ruleId",businessRule.id).ExecuteUpdate();
				session.Delete(businessRule);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public void saveCompleteRule(BusinessRule businessRule, IList<BusinessRuleConfig> configs, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(businessRule.id != -1){
						session.Update(businessRule);								
						session.CreateQuery("delete from BusinessRuleConfig where ruleId=:ruleId").SetInt32("ruleId",businessRule.id).ExecuteUpdate();				

						if(configs != null && configs.Count>0){						
							foreach(BusinessRuleConfig k in configs){
								k.ruleId = businessRule.id;
								session.Save(k);
							}					
						}						
					}else{			
						session.Save(businessRule);		
				
						if(configs != null && configs.Count>0){
							foreach(BusinessRuleConfig k in configs){
								k.ruleId = businessRule.id;
								session.Save(k);
							}				
						}
					}
						
					// ************** AGGIUNGO TGUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI label
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
		
		public BusinessRule getById(int id)
		{
			BusinessRule businessRule = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				businessRule = session.Get<BusinessRule>(id);					

				NHibernateHelper.closeSession();
			}
			
			return businessRule;
		}	

		public IList<BusinessRule> find(string type, int active)
		{
			IList<BusinessRule> results = null;

			string strSQL = "from BusinessRule where 1=1";
			
			if (!String.IsNullOrEmpty(type)){			
				List<string> ids = new List<string>();
				string[] trtype = type.Split(',');
				foreach(string r in trtype){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and ruleType in({0})",string.Join(",",ids.ToArray()));}
			}
			
			if (active>-1){
				strSQL += " and active=:active";
			}
			strSQL += " order by ruleType asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{	
				IQuery q = session.CreateQuery(strSQL);
				if (active>-1){
					q.SetBoolean("active", Convert.ToBoolean(active));
				}				
				
				results = q.List<BusinessRule>();
				NHibernateHelper.closeSession();
			}
						
			return results;		
		}		
		
		//************ MANAGE BUSINESS STRATEGY CONFIG ************
		public void insertBusinessRuleConfig(BusinessRuleConfig businessRuleConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(businessRuleConfig);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateBusinessRuleConfig(BusinessRuleConfig businessRuleConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(businessRuleConfig);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteBusinessRuleConfig(BusinessRuleConfig businessRuleConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Delete(businessRuleConfig);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public void deleteBusinessRuleConfigByRule(int idRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from BusinessRuleConfig where ruleId=:ruleId").SetInt32("ruleId",idRule).ExecuteUpdate();
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public BusinessRuleConfig getBusinessRuleConfigById(int id)
		{
			BusinessRuleConfig businessRuleConfig = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				businessRuleConfig = session.Get<BusinessRuleConfig>(id);					

				NHibernateHelper.closeSession();
			}
			
			return businessRuleConfig;
		}
		
		public IList<BusinessRuleConfig> findBusinessRuleConfig(int ruleId, int productId)
		{
			IList<BusinessRuleConfig> results = null;
			
			string strSQL = "from BusinessRuleConfig where ruleId=:ruleId";
			if (productId>-1){
				strSQL += " and productId=:prodId";
			}
			strSQL += " order by ruleId, productId, rateFrom, rateTo asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				try
				{		
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("ruleId",ruleId);
					if (productId>-1){
						q.SetInt32("prodId",productId);
					}				
					
					results = q.List<BusinessRuleConfig>();
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