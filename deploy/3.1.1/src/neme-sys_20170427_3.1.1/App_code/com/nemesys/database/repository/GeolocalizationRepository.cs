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
	public class GeolocalizationRepository : IGeolocalizationRepository
	{		
		public void insert(Geolocalization point)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				//try
				//{		
					session.Save(point);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Geolocalization point)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				//try
				//{		
					session.Update(point);			
				//}
				//catch(Exception ex)
				//{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				//}	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(Geolocalization point)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Delete(point);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
	
		public Geolocalization getById(int id)
		{		
			Geolocalization element = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Geolocalization>(id);	
				NHibernateHelper.closeSession();
			}	
			return element;	
		}
	
		public IList<Geolocalization> findByElement(int idElement, int type)
		{
			IList<Geolocalization> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from Geolocalization where idElement=:idElement and type=:type");	
				q.SetInt32("idElement", idElement);		
				q.SetInt32("type", type);
				results = q.List<Geolocalization>();
				NHibernateHelper.closeSession();
			}
			return results;		
		}	
	}
}