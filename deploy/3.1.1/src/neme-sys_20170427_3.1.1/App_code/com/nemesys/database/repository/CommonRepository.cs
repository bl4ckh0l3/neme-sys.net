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
	public class CommonRepository : ICommonRepository
	{		
		public IList<SystemFieldsType> getSystemFieldsType()
		{
			IList<SystemFieldsType> results = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from SystemFieldsType order by description asc");
				results = q.List<SystemFieldsType>();
				NHibernateHelper.closeSession();
			}			
			return results;		
		}
		
		public IList<SystemFieldsTypeContent> getSystemFieldsTypeContent()
		{
			IList<SystemFieldsTypeContent> results = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from SystemFieldsTypeContent order by description asc");
				results = q.List<SystemFieldsTypeContent>();
				NHibernateHelper.closeSession();
			}			
			return results;		
		}		
	}
}