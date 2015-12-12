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
	public class CountryRepository : ICountryRepository
	{		
		public void insert(Country country)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				//try
				//{		
					session.Save(country);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Country country)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				//try
				//{		
					session.Update(country);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Country country)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.CreateQuery("DELETE FROM Geolocalization WHERE idElement=:idElement").SetInt32("idElement", country.id).ExecuteUpdate();	
				session.Delete(country);						
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
	
		public Country getById(int id)
		{					
			Country element = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Country>(id);	
				NHibernateHelper.closeSession();
			}	
			return element;	
		}

		public void saveCompleteCountry(Country country, IList<Geolocalization> listOfPoints, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				try{
					if(country.id != -1){
						session.Update(country);
					}else{
						session.Save(country);
					}

					//*
					//* aggiorno le localizzazioni se sono state inserite prima di salvare il contenuto
					//*
					foreach(Geolocalization q in listOfPoints)
					{
						q.idElement=country.id;
						session.Update(q);
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
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;	
				}
			}	
		}
	
		public IList<Country> findAllCountries(string useFor)
		{
			IList<Country> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Country where active=1 and (ISNULL(state_region_code) or state_region_code='')";				
				if (!String.IsNullOrEmpty(useFor)){			
					//strSQL += " and useFor IN(:useFor)";
					List<string> ids = new List<string>();
					string[] tuseFor = useFor.Split(',');
					foreach(string r in tuseFor){
						ids.Add(r);
					}						
					if(ids.Count>0){strSQL+=string.Format(" and useFor in({0})",string.Join(",",ids.ToArray()));}	
				}
				strSQL +=" order by countryDescription asc";		
				IQuery q = session.CreateQuery(strSQL);
				results = q.List<Country>();
				NHibernateHelper.closeSession();
			}	
			return results;	
		}
	
		public IList<Country> findAllStateRegion(string useFor)
		{
			IList<Country> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Country where active=1 and (not isnull(state_region_code) and state_region_code<>'')";				
				if (!String.IsNullOrEmpty(useFor)){			
					List<string> ids = new List<string>();
					string[] tuseFor = useFor.Split(',');
					foreach(string r in tuseFor){
						ids.Add(r);
					}						
					if(ids.Count>0){strSQL+=string.Format(" and useFor in({0})",string.Join(",",ids.ToArray()));}	
				}
				strSQL +=" order by countryDescription, state_region_description asc";		
				IQuery q = session.CreateQuery(strSQL);
				results = q.List<Country>();
				NHibernateHelper.closeSession();
			}
			return results;		
		}
	
		public IList<Country> findStateRegionByCountry(string countryCode, string useFor)
		{
			IList<Country> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Country where active=1 and (not isnull(state_region_code) and state_region_code<>'')";				
				if (!String.IsNullOrEmpty(countryCode)){			
					strSQL += " and country_code =:countryCode";
				}				
				if (!String.IsNullOrEmpty(useFor)){			
					List<string> ids = new List<string>();
					string[] tuseFor = useFor.Split(',');
					foreach(string r in tuseFor){
						ids.Add(r);
					}						
					if(ids.Count>0){strSQL+=string.Format(" and useFor in({0})",string.Join(",",ids.ToArray()));}	
				}
				strSQL +=" order by countryDescription, state_region_description asc";		
				IQuery q = session.CreateQuery(strSQL);
				if (!String.IsNullOrEmpty(countryCode)){	
					q.SetString("countryCode", countryCode);
				}
				results = q.List<Country>();
				NHibernateHelper.closeSession();
			}	
			return results;	
		}

		public IList<Country> find(string active, string useFor, string searchKey, int pageIndex, int pageSize,out long totalCount)
		{		
			IList<Country> countries = null;		
			totalCount = 0;	
			string strSQL = "from Country where 1=1";
			if (!String.IsNullOrEmpty(active)){			
				strSQL += " and active=:active";
			}
			if (!String.IsNullOrEmpty(useFor)){			
				//strSQL += " and useFor IN(:useFor)";
				List<string> ids = new List<string>();
				string[] tuseFor = useFor.Split(',');
				foreach(string r in tuseFor){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and useFor in({0})",string.Join(",",ids.ToArray()));}	
			}
			if (!String.IsNullOrEmpty(searchKey)){			
				strSQL += " and ((countryCode like :countryCode  or countryDescription like :countryDescription)";
				strSQL += " or (stateRegionCode like :stateRegionCode  or stateRegionDescription like :stateRegionDescription))";
			}			
			strSQL +=" order by countryDescription, stateRegionDescription asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (!String.IsNullOrEmpty(active)){
						q.SetBoolean("active", Convert.ToBoolean(active));
						qCount.SetBoolean("active", Convert.ToBoolean(active));
					}
					if (!String.IsNullOrEmpty(searchKey)){			
						q.SetString("countryCode", String.Format("%{0}%", searchKey));
						q.SetString("countryDescription", String.Format("%{0}%", searchKey));
						qCount.SetString("countryCode", String.Format("%{0}%", searchKey));
						qCount.SetString("countryDescription", String.Format("%{0}%", searchKey));
			
						q.SetString("stateRegionCode", String.Format("%{0}%", searchKey));
						q.SetString("stateRegionDescription", String.Format("%{0}%", searchKey));
						qCount.SetString("stateRegionCode", String.Format("%{0}%", searchKey));
						qCount.SetString("stateRegionDescription", String.Format("%{0}%", searchKey));
					}
					countries = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
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

			return countries;
		}
	
		protected IList<Country> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Country> records = new List<Country>();	
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
						records.Add((Country)tmp);
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