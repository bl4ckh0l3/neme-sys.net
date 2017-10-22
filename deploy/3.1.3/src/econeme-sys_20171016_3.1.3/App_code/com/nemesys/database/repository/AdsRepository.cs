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
	public class AdsRepository : IAdsRepository
	{		
		public void insert(Ads ads)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				IList<AdsPromotion> promotionCopy = new List<AdsPromotion>();
				if(ads.promotions != null && ads.promotions.Count>0)
				{
					foreach(AdsPromotion k in ads.promotions){					
						AdsPromotion p = new AdsPromotion();	
						p.adsId = k.adsId;
						p.elementId=k.elementId;
						p.elementCode=k.elementCode;
						p.active=k.active;
						promotionCopy.Add(p);
					}
					ads.promotions.Clear();							
				}				
				
				ads.insertDate=DateTime.Now;
				session.Save(ads);	

				if(promotionCopy != null && promotionCopy.Count>0)
				{							
					foreach(AdsPromotion k in promotionCopy){
						k.adsId = ads.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Ads ads)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				IList<AdsPromotion> promotionCopy = new List<AdsPromotion>();
				if(ads.promotions != null && ads.promotions.Count>0)
				{
					foreach(AdsPromotion k in ads.promotions){					
						AdsPromotion p = new AdsPromotion();	
						p.adsId = k.adsId;
						p.elementId=k.elementId;
						p.elementCode=k.elementCode;
						p.active=k.active;
						promotionCopy.Add(p);
					}
					ads.promotions.Clear();							
				}
				
				ads.insertDate=DateTime.Now;
				session.Update(ads);

				if(promotionCopy != null && promotionCopy.Count>0)
				{							
					foreach(AdsPromotion k in promotionCopy){

						/*string strSQL = "select count(*) as counter from ADS_PROMOTION where id_ads=:idAds and id_element=:idElement";
						int count = session.CreateSQLQuery(strSQL).AddScalar("counter", NHibernateUtil.Int32)
						.SetInt32("idAds",k.adsId)
						.SetInt32("idElement",k.elementId)				
						.UniqueResult<int>();	
						
						if(count>0){*/
							//session.CreateQuery("DELETE FROM AdsPromotion WHERE adsId=:adsId and elementId=:idElement").SetInt32("adsId", k.adsId).SetInt32("idElement", k.elementId).ExecuteUpdate();
							//k.insertDate=DateTime.Now;
							//session.Save(k);	
						/*}else{
							session.Save(k);
						}*/
						
						AdsPromotion q = session.CreateQuery("from AdsPromotion where adsId=:adsId and elementId=:idElement")
						.SetInt32("adsId", k.adsId)
						.SetInt32("idElement", k.elementId)
						.UniqueResult<AdsPromotion>();
	
						if(q != null){
							q.elementCode=k.elementCode;
							q.active=k.active;							
							q.insertDate=DateTime.Now;
							session.Update(q);
						}else{
							k.insertDate=DateTime.Now;
							session.Save(k);
						}						
						
					}
				}			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Ads ads)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("DELETE FROM AdsPromotion WHERE adsId=:adsId").SetInt32("adsId", ads.id).ExecuteUpdate();
				session.Delete(ads);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}		
		
		public Ads getById(int id)
		{
			Ads ads = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					ads = session.Get<Ads>(id);		

					ads.promotions = session.CreateCriteria(typeof(AdsPromotion))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("adsId", ads.id))
					.List<AdsPromotion>();	
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return ads;
		}

		public Ads getByIdElement(int idElement, int idUser)
		{
			Ads result = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{	
					string strSQL = "from Ads where elementId=:idElement";
					if (idUser>0){			
						strSQL += " and userId=:idUser";
					}					
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("idElement",idElement);
					if (idUser>0){
						q.SetInt32("idUser",idUser);
					}
					result = q.UniqueResult<Ads>();

					if(result != null){
						result.promotions = session.CreateCriteria(typeof(AdsPromotion))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("adsId", result.id))
						.List<AdsPromotion>();	
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
			
			return result;			
		}
				
		public IList<Ads> find(int adsType, decimal priceFrom, decimal priceTo, string dateFrom, string dateTo, string title, IList<int> matchCategories, IList<int> matchLanguages)
		{
			IList<FContent> contents = null;
			List<string> idsCat = new List<string>();
			List<string> idsLang = new List<string>();
			
			// first check on categories and languages
			if (matchCategories != null && matchCategories.Count > 0){
				foreach(int c in matchCategories){
					idsCat.Add(c.ToString());
				}						
			}
			if (matchLanguages != null && matchLanguages.Count > 0){
				foreach(int c in matchLanguages){
					idsLang.Add(c.ToString());
				}						
			}
			
			string strSQL = "from FContent where status=1";

			// check on categories and languages
			if(idsCat.Count>0){strSQL+=string.Format(" and id in(select idParent from ContentCategory where idCategory in({0}))",string.Join(",",idsCat.ToArray()));}
			if(idsLang.Count>0){strSQL+=string.Format(" and id in(select idParentContent from ContentLanguage where idLanguage in({0}))",string.Join(",",idsLang.ToArray()));}
			
			if (!String.IsNullOrEmpty(title)){			
				strSQL += " and title like:title";
			}	
			strSQL +=" order by insertDate desc";
			
			
			
			IList<Ads> results = null;
			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (!String.IsNullOrEmpty(title)){
						q.SetString("title", String.Format("%{0}%", title));
					}					
					contents = q.List<FContent>();

					if(contents != null && contents.Count>0){
						List<string> ids = new List<string>();
						
						foreach(FContent c in contents){	
							ids.Add(c.id.ToString());
						}
						
						string strSQL2 = "from Ads where ";
						strSQL2+=string.Format(" elementId in({0})",string.Join(",",ids.ToArray()));
						
						if (adsType>-1){			
							strSQL2 += " and type=:type";
						}		
						if (priceFrom>0){			
							strSQL2 += " and price>=:priceFrom";
						}
						if (priceTo>0){			
							strSQL2 += " and price<=:priceTo";
						}
						if (!String.IsNullOrEmpty(dateFrom)){
							strSQL2 += " and insertDate >=:dateFrom";
						}
						if (!String.IsNullOrEmpty(dateTo)){
							strSQL2 += " and insertDate <=:dateTo";
						}
						
						q = session.CreateQuery(strSQL2);
						if (adsType>-1){
							q.SetInt32("type", adsType);
						}
						if (priceFrom>0){
							q.SetDecimal("priceFrom", priceFrom);
						}
						if (priceTo>0){
							q.SetDecimal("priceTo", priceTo);
						}
						if (!String.IsNullOrEmpty(dateFrom)){
							q.SetDateTime("dateFrom", Convert.ToDateTime(dateFrom));
						}
						if (!String.IsNullOrEmpty(dateTo)){
							q.SetDateTime("dateTo", Convert.ToDateTime(dateTo));
						}
						results = q.List<Ads>();
						
						if(results != null && results.Count>0){
							foreach(Ads ads in results){
								ads.promotions = session.CreateCriteria(typeof(AdsPromotion))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("adsId", ads.id))
								.List<AdsPromotion>();								
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
						
			return results;			
		}
		
		public void activatePromotion(int idAds, int idElement)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				session.CreateQuery("update AdsPromotion set active=1, insertDate=:insertDate where adsId=:idAds and elementId=:idElement")
				.SetDateTime("insertDate",DateTime.Now)
				.SetInt32("idAds",idAds)
				.SetInt32("idElement",idElement)
				.ExecuteUpdate();				
				
				NHibernateHelper.closeSession();
			}	
		}
	}
}