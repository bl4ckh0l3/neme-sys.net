using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
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
	public class FeeRepository : IFeeRepository
	{		
		public void insert(Fee fee)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				IList<FeeConfig> newFC = new List<FeeConfig>();	
				if(fee.configs != null && fee.configs.Count>0)
				{
					foreach(FeeConfig k in fee.configs){	
						FeeConfig nfc = new FeeConfig();	
						nfc.id=k.id;
						nfc.idFee=k.idFee;
						nfc.descProdField=k.descProdField;
						nfc.rateFrom=k.rateFrom;
						nfc.rateTo=k.rateTo;
						nfc.operation=k.operation;	
						nfc.value=k.value;					
						newFC.Add(nfc);
					}
					fee.configs.Clear();							
				}			
				
				session.Save(fee);			
				
				List<string> ids = new List<string>();
				if(newFC != null && newFC.Count>0){
					foreach(FeeConfig fc in newFC){
						ids.Add(fc.idFee.ToString());
					}
					session.CreateQuery(string.Format("delete from FeeConfig where idFee in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
						
					foreach(FeeConfig k in newFC){
						k.idFee = fee.id;
						session.Save(k);
					}					
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void update(Fee fee)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<FeeConfig> newFC = new List<FeeConfig>();	
				if(fee.configs != null && fee.configs.Count>0)
				{
					foreach(FeeConfig k in fee.configs){	
						FeeConfig nfc = new FeeConfig();	
						nfc.id=k.id;
						nfc.idFee=k.idFee;
						nfc.descProdField=k.descProdField;
						nfc.rateFrom=k.rateFrom;
						nfc.rateTo=k.rateTo;
						nfc.operation=k.operation;	
						nfc.value=k.value;					
						newFC.Add(nfc);
					}
					fee.configs.Clear();							
				}			
				
				session.Update(fee);	
								
				session.CreateQuery("delete from FeeConfig where idFee=:idFee").SetInt32("idFee",fee.id).ExecuteUpdate();				

				if(newFC != null && newFC.Count>0){						
					foreach(FeeConfig k in newFC){
						k.idFee = fee.id;
						session.Save(k);
					}					
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fee-"+fee.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void delete(Fee fee)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(fee.configs != null && fee.configs.Count>0)
				{
					session.CreateQuery("delete from FeeConfig where idFee=:idFee").SetInt32("idFee",fee.id).ExecuteUpdate();
					fee.configs.Clear();						
				}		
				session.Delete(fee);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fee-"+fee.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}

		public void saveCompleteFee(Fee fee, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					IList<FeeConfig> newFC = new List<FeeConfig>();	
					List<string> ids = new List<string>();
					
					if(fee.id != -1){	
						if(fee.configs != null && fee.configs.Count>0)
						{
							foreach(FeeConfig k in fee.configs){	
								FeeConfig nfc = new FeeConfig();	
								nfc.id=k.id;
								nfc.idFee=k.idFee;
								nfc.descProdField=k.descProdField;
								nfc.rateFrom=k.rateFrom;
								nfc.rateTo=k.rateTo;
								nfc.operation=k.operation;	
								nfc.value=k.value;					
								newFC.Add(nfc);
							}
							fee.configs.Clear();							
						}
						
						session.Update(fee);								
						session.CreateQuery("delete from FeeConfig where idFee=:idFee").SetInt32("idFee",fee.id).ExecuteUpdate();				

						if(newFC != null && newFC.Count>0){						
							foreach(FeeConfig k in newFC){
								k.idFee = fee.id;
								session.Save(k);
							}					
						}						
					}else{			
						if(fee.configs != null && fee.configs.Count>0)
						{
							foreach(FeeConfig k in fee.configs){	
								FeeConfig nfc = new FeeConfig();	
								nfc.idFee=k.idFee;
								nfc.descProdField=k.descProdField;
								nfc.rateFrom=k.rateFrom;
								nfc.rateTo=k.rateTo;
								nfc.operation=k.operation;	
								nfc.value=k.value;					
								newFC.Add(nfc);
							}
							fee.configs.Clear();							
						}
						
						session.Save(fee);		
				
						if(newFC != null && newFC.Count>0){
							foreach(FeeConfig fc in newFC){
								ids.Add(fc.idFee.ToString());
							}
							session.CreateQuery(string.Format("delete from FeeConfig where idFee in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
								
							foreach(FeeConfig k in newFC){
								k.idFee = fee.id;
								session.Save(k);
							}					
						}
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
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fee-"+fee.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public Fee getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public Fee getByIdCached(int id, bool cached)
		{
			Fee fee = null;	
			
			if(cached)
			{
				fee = (Fee)HttpContext.Current.Cache.Get("fee-"+id);
				if(fee != null){
					return fee;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				fee = session.Get<Fee>(id);			

				fee.configs = session.CreateCriteria(typeof(FeeConfig))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idFee", fee.id))
				.AddOrder(Order.Asc("descProdField"))
				.AddOrder(Order.Asc("rateFrom"))
				.AddOrder(Order.Asc("rateTo"))
				.List<FeeConfig>();						

				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(fee == null){
					fee = new Fee();
					fee.id=-1;
				}
				HttpContext.Current.Cache.Insert("fee-"+fee.id, fee, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return fee;
		}
		
		public IList<Fee> find(string description, int type, string applyTo, bool cached)
		{
			IList<Fee> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-fee")
			.Append("-").Append(description)
			.Append("-").Append(type)
			.Append("-").Append(applyTo);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<Fee>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from Fee where 1=1";
			
			if(!String.IsNullOrEmpty(description)){
				strSQL += " and description= :description";
			}
			
			if(type > 0){
				strSQL += " and type= :type";
			}
	
			if (!String.IsNullOrEmpty(applyTo)){				
				List<string> ids = new List<string>();
				string[] applies = applyTo.Split(',');
				foreach(string r in applies){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and applyTo in({0})",string.Join(",",ids.ToArray()));}		
			}


			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL+"<br>");					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if(!String.IsNullOrEmpty(description)){
						q.SetString("description",description);	
					}			
					if(type > 0){
						q.SetInt32("type",type);
					}
					results = q.List<Fee>();

					if(results != null){
						foreach(Fee sg in results){
							sg.configs = session.CreateCriteria(typeof(FeeConfig))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idFee", sg.id))
							.AddOrder(Order.Asc("descProdField"))
							.AddOrder(Order.Asc("rateFrom"))
							.AddOrder(Order.Asc("rateTo"))
							.List<FeeConfig>();									
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(results == null){
					results = new List<Fee>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}
		
	
		public IList<FeeConfig> findFeeConfigs(int idFee, int descProdField)
		{
			return findFeeConfigsCached(idFee, descProdField, false);
		}
	
		public IList<FeeConfig> findFeeConfigsCached(int idFee, int descProdField, bool cached)
		{
			IList<FeeConfig> results = null;
			StringBuilder cacheKey = new StringBuilder("list-fee-config-").Append(idFee).Append("-").Append(descProdField);
						
			if(cached)
			{
				results = (IList<FeeConfig>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from FeeConfig  where 1=1";
				if(idFee!=-1){
					sql += " and id_fee= :idFee";
				}
				if(descProdField!=-1){
					sql += " and desc_prod_field= :descProdField";
				}
				sql += " order by desc_prod_field, rate_from, rate_to asc";
				IQuery q = session.CreateQuery(sql);
				if(idFee!=-1){
					q.SetInt32("idFee",idFee);	
				}
				if(descProdField!=-1){
					q.SetInt32("descProdField",descProdField);	
				}
				results = q.List<FeeConfig>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<FeeConfig>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}

		public FeeConfig getFeeConfigById(int id)
		{			
			return getFeeConfigByIdCached(id, false);
		}

		public FeeConfig getFeeConfigByIdCached(int id, bool cached)
		{
			FeeConfig feeConfig = null;		
			
			if(cached)
			{
				feeConfig = (FeeConfig)HttpContext.Current.Cache.Get("fee-config-"+id);
				if(feeConfig != null){
					return feeConfig;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				feeConfig = session.Get<FeeConfig>(id);
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(feeConfig == null){
					feeConfig = new FeeConfig();
					feeConfig.id=-1;
				}
				HttpContext.Current.Cache.Insert("fee-config-"+feeConfig.id, feeConfig, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return feeConfig;
		}
		
		public void insertFeeConfig(FeeConfig feeConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(feeConfig);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fee-config-"+feeConfig.id))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void updateFeeConfig(FeeConfig feeConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(feeConfig);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 				
				if(cacheKey.Contains("fee-config-"+feeConfig.id))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void deleteFeeConfig(FeeConfig feeConfig)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(feeConfig);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fee-config-"+feeConfig.id))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public void deleteFeeConfigByIdFee(int idFee)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.CreateQuery("delete from FeeConfig where idFee=:id").SetInt32("id",idFee).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fee"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fee-config"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}		
	}
}