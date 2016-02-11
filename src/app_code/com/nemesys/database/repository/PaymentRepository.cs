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
	public class PaymentRepository : IPaymentRepository
	{		
		public void insert(Payment payment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				IList<IPaymentField> newPaymentField = new List<IPaymentField>();	
				if(payment.fields != null && payment.fields.Count>0)
				{
					foreach(IPaymentField k in payment.fields){	
						IPaymentField npf = new PaymentField();	
						npf.id=k.id;
						npf.idPayment=k.idPayment;
						npf.idModule=k.idModule;
						npf.keyword=k.keyword;
						npf.value=k.value;
						npf.matchField=k.matchField;					
						newPaymentField.Add(npf);
					}
					payment.fields.Clear();							
				}			
				
				session.Save(payment);			
				
				List<string> ids = new List<string>();
				if(newPaymentField != null && newPaymentField.Count>0){
					foreach(IPaymentField pcid in newPaymentField){
						ids.Add(pcid.idPayment.ToString());
					}
					session.CreateQuery(string.Format("delete from PaymentField where idPayment in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
						
					foreach(IPaymentField k in newPaymentField){
						k.idPayment = payment.id;
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
				if(cacheKey.Contains("list-payment"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-payment-field"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void update(Payment payment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<IPaymentField> newPaymentField = new List<IPaymentField>();		
				if(payment.fields != null && payment.fields.Count>0)
				{
					foreach(IPaymentField k in payment.fields){	
						IPaymentField npf = new PaymentField();	
						npf.id=k.id;
						npf.idPayment=k.idPayment;
						npf.idModule=k.idModule;
						npf.keyword=k.keyword;
						npf.value=k.value;
						npf.matchField=k.matchField;					
						newPaymentField.Add(npf);
					}
					payment.fields.Clear();							
				}			
				
				session.Update(payment);	
								
				session.CreateQuery("delete from PaymentField where idPayment=:idPayment").SetInt32("idPayment",payment.id).ExecuteUpdate();	

				if(newPaymentField != null && newPaymentField.Count>0)
				{					
					foreach(IPaymentField k in newPaymentField){
						k.idPayment = payment.id;
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
				if(cacheKey.Contains("payment-"+payment.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("payment-field-"+payment.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-payment-field"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}	
		}
		
		public void delete(Payment payment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(payment.fields != null && payment.fields.Count>0)
				{
					session.CreateQuery("delete from PaymentField where idPayment=:idPayment").SetInt32("idPayment",payment.id).ExecuteUpdate();
					payment.fields.Clear();						
				}		
				session.Delete(payment);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("payment-"+payment.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("payment-field-"+payment.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-payment-field"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}					
		}
		
		public Payment getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public Payment getByIdCached(int id, bool cached)
		{
			Payment payment = null;	
			
			if(cached)
			{
				payment = (Payment)HttpContext.Current.Cache.Get("payment-"+id);
				if(payment != null){
					return payment;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				payment = session.Get<Payment>(id);			

				payment.fields = session.CreateCriteria(typeof(PaymentField))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idPayment", payment.id))
				.AddOrder(Order.Asc("matchField"))
				.List<IPaymentField>();						

				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(payment == null){
					payment = new Payment();
					payment.id=-1;
				}
				HttpContext.Current.Cache.Insert("payment-"+payment.id, payment, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return payment;
		}

		public void saveCompletePayment(Payment payment, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					IList<IPaymentField> newPaymentField = new List<IPaymentField>();				
					if(payment.fields != null)
					{
						if(payment.fields.Count>0 && payment.hasExternalUrl)
						{
							foreach(IPaymentField pfm in payment.fields){	
								IPaymentField fd = new PaymentField();
								fd.id = pfm.id;
								fd.idModule = pfm.idModule;
								fd.keyword = pfm.keyword;
								fd.value = pfm.value;
								fd.matchField = pfm.matchField;
								newPaymentField.Add(fd);
							}
						}
						payment.fields.Clear();							
					}					
					
					if(payment.id != -1){
						session.Update(payment);	
						session.CreateQuery("delete from PaymentField where idPayment=:idPayment").SetInt32("idPayment",payment.id).ExecuteUpdate();						
					}else{
						session.Save(payment);
					}
					
					if(newPaymentField != null && newPaymentField.Count>0)
					{					
						foreach(IPaymentField k in newPaymentField){
							k.idPayment = payment.id;
							session.Save(k);
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
				if(cacheKey.Contains("payment-"+payment.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-payment"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("payment-field-"+payment.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-payment-field"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public IList<Payment> find(int idModule, int paymentType, string isActive, string applyTo, bool withFields, bool cached)
		{
			IList<Payment> results = null;
			
			StringBuilder cacheKey = new StringBuilder("list-payment")
			.Append("-").Append(idModule)
			.Append("-").Append(paymentType)
			.Append("-").Append(isActive)
			.Append("-").Append(applyTo);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<Payment>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from Payment where 1=1";
			
			if (idModule > 0){			
				strSQL += " and idModule=:idModule";
			}
			
			if (paymentType > 0){			
				strSQL += " and paymentType=:paymentType";
			}
			if(!String.IsNullOrEmpty(isActive)){
				strSQL += " and isActive= :isActive";
			}
			
			if (!String.IsNullOrEmpty(applyTo)){	
				List<string> ids = new List<string>();
				string[] tapplyTo = applyTo.Split(',');
				foreach(string r in tapplyTo){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and applyTo in({0})",string.Join(",",ids.ToArray()));}
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (idModule > 0){
						q.SetInt32("idModule", Convert.ToInt32(idModule));
					}
					if (paymentType > 0){
						q.SetInt32("paymentType", Convert.ToInt32(paymentType));
					}
					if(!String.IsNullOrEmpty(isActive)){
						q.SetBoolean("isActive",Convert.ToBoolean(isActive));	
					}
					results = q.List<Payment>();

					if(results != null){
						foreach(Payment payment in results){		
							if(withFields){
								payment.fields = session.CreateCriteria(typeof(PaymentField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idPayment", payment.id))
								.AddOrder(Order.Asc("matchField"))
								.List<IPaymentField>();	
							}								
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
					results = new List<Payment>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}
		
		
		/*CONTENT FIELDS METHODS*/
	
		public IPaymentField getPaymentFieldById(int idField)
		{
			return getPaymentFieldByIdCached(idField, false);
		}
	
		public IPaymentField getPaymentFieldByIdCached(int idField, bool cached)
		{
			PaymentField result = null;
			StringBuilder cacheKey = new StringBuilder("payment-field-").Append(idField);
				
			if(cached)
			{
				result = (PaymentField)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(result != null){
					return result;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				result = session.Get<PaymentField>(idField);
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new PaymentField();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return result;		
		}
	
		public IList<IPaymentField> getPaymentFields(int idPayment, int idModule, string keyword, string matchField, string doMatch)
		{
			return getPaymentFieldsCached(idPayment, idModule, keyword, matchField, doMatch, false);
		}
	
		public IList<IPaymentField> getPaymentFieldsCached(int idPayment, int idModule, string keyword, string matchField, string doMatch, bool cached)
		{
			IList<IPaymentField> results = null;
			StringBuilder cacheKey = new StringBuilder("list-payment-field-").Append(idPayment).Append("-").Append(idModule).Append("-").Append(matchField);
						
			if(cached)
			{
				results = (IList<IPaymentField>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from PaymentField  where 1=1";
				if(idPayment!=-1){
				sql += " and id_payment= :idPayment";
				}
				if(idModule!=-1){
				sql += " and id_module= :idModule";
				}
				if(!String.IsNullOrEmpty(keyword)){
				sql += " and keyword= :keyword";
				}
				if(!String.IsNullOrEmpty(matchField)){
				sql += " and match_field= :match_field";
				}
				if(!String.IsNullOrEmpty(doMatch)){
					if(Convert.ToBoolean(doMatch)){
						sql += " and match_field <>'' and not match_field IS NULL";
					}else{
						sql += " and (match_field ='' or match_field IS NULL)";
					}
				}
				sql += " order by match_field, keyword asc";
				IQuery q = session.CreateQuery(sql);
				if(idPayment!=-1){
				q.SetInt32("idPayment",idPayment);	
				}
				if(idModule!=-1){
				q.SetInt32("idModule",idModule);	
				}
				if(!String.IsNullOrEmpty(keyword)){
				q.SetString("keyword",keyword);	
				}
				if(!String.IsNullOrEmpty(matchField)){
				q.SetString("matchField",matchField);	
				}
				results = q.List<IPaymentField>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<IPaymentField>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}		
	}
}