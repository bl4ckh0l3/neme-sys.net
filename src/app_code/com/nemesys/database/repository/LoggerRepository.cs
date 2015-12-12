using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using NHibernate;
using NHibernate.Criterion;

namespace com.nemesys.database.repository
{
	public class LoggerRepository : ILoggerRepository
	{
		public void insert(Logger logger)
		{
			write(logger);
		}
		
		public void write(Logger logger)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(logger);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Logger logger)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Update(logger);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}		

		public void delete(Logger logger)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Delete(logger);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}	
	
		public Logger getById(int id)
		{
			Logger element = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Logger>(id);			
				NHibernateHelper.closeSession();
			}
			return element;		
		}	

		public void deleteBy(string type, string dta_from, string dta_to)
		{
			int DD, MM, YY, HH, MIN, SS;
			string strSQL = "delete from Logger as logs where 1=1";
			
			if (!String.IsNullOrEmpty(type)){ strSQL = strSQL + " and type= :type";}
			if (!String.IsNullOrEmpty(dta_from)){
				DateTime df = Convert.ToDateTime(dta_from);
				DD = df.Day;
				MM = df.Month;
				YY = df.Year;
				HH = 00;
				MIN = 00;
				SS = 00;				
				dta_from = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;
				strSQL = strSQL + " and date >= :dta_from";
			}			
			if (!String.IsNullOrEmpty(dta_to)){ 
				DateTime dt = Convert.ToDateTime(dta_to);
				DD = dt.Day;
				MM = dt.Month;
				YY = dt.Year;
				HH = 23;
				MIN = 59;
				SS = 59;
				dta_to = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;				
				strSQL = strSQL + " and date <=:dta_to";
			}	
			strSQL = strSQL.Trim();			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);

				if (!String.IsNullOrEmpty(type)){ q.SetString("type",type);}
				if (!String.IsNullOrEmpty(dta_from)){ q.SetDateTime("dta_from", Convert.ToDateTime(dta_from));}
				if (!String.IsNullOrEmpty(dta_to)){ q.SetDateTime("dta_to", Convert.ToDateTime(dta_to));}				

				q.ExecuteUpdate();
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}		
		
		
		public IDictionary<int, Logger> find(string type, string dta_from, string dta_to, int pageIndex, int pageSize,out long totalCount)
		{		
			IDictionary<int, Logger> logs = new Dictionary<int, Logger>();

			int DD, MM, YY, HH, MIN, SS;
			
			string strSQL = "from Logger as logs where 1=1";			
			if (!String.IsNullOrEmpty(type)){ strSQL = strSQL + " and type= :type";}
			if (!String.IsNullOrEmpty(dta_from)){
				DateTime df = Convert.ToDateTime(dta_from);
				DD = df.Day;
				MM = df.Month;
				YY = df.Year;
				HH = 00;
				MIN = 00;
				SS = 00;				
				dta_from = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;
				strSQL = strSQL + " and date >= :dta_from";
			}			
			if (!String.IsNullOrEmpty(dta_to)){ 
				DateTime dt = Convert.ToDateTime(dta_to);
				DD = dt.Day;
				MM = dt.Month;
				YY = dt.Year;
				HH = 23;
				MIN = 59;
				SS = 59;
				dta_to = YY+"-"+MM+"-"+DD+" "+HH+":"+MIN+":"+SS;				
				strSQL = strSQL + " and date <=:dta_to";
			}	
			
			strSQL = strSQL + " order by logs.date desc";
			strSQL = strSQL.Trim();		
			//System.Web.HttpContext.Current.Response.Write("strSQL:"+strSQL+" - :"+dta_from+" - dta_to:"+dta_to+"<br>");			
			
			IList logss = null; 
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);
				//ICriteria q = session.CreateCriteria(typeof(Logger));			
				//q.AddOrder( Order.Desc("date"));

				if (!String.IsNullOrEmpty(type)){ q.SetString("type",type);qCount.SetString("type",type);/*q.Add(Expression.Eq("type", type));*/}
				if (!String.IsNullOrEmpty(dta_from)){ q.SetDateTime("dta_from", Convert.ToDateTime(dta_from));qCount.SetDateTime("dta_from", Convert.ToDateTime(dta_from));/*q.Add(Expression.Ge("date", Convert.ToDateTime(dta_from)));*/}
				if (!String.IsNullOrEmpty(dta_to)){ q.SetDateTime("dta_to", Convert.ToDateTime(dta_to));qCount.SetDateTime("dta_to", Convert.ToDateTime(dta_to));/*q.Add(Expression.Lt("date", Convert.ToDateTime(dta_to)));*/}			

				logss = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
				//logss = getByCriteria(q,session,pageIndex,pageSize,out totalCount);

				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			foreach (Logger k in logss)
			{
				logs.Add(k.id,k);
			} 			

			return logs;
		}		
		/*
		protected IList<Logger> getByCriteria(
			ICriteria criteria, 
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			ICriteria recordsCriteria = CriteriaTransformer.Clone(criteria);		
			// Paging.
			//System.Web.HttpContext.Current.Response.Write("SetFirstResult:"+(((pageIndex * pageSize) - pageSize))+" - pageSize:"+pageSize+"<br>");
			recordsCriteria.SetFirstResult(((pageIndex * pageSize) - pageSize));
			recordsCriteria.SetMaxResults(pageSize);		
			// Count criteria.
			ICriteria countCriteria = CriteriaTransformer.TransformToRowCount(criteria);
	
			// Perform multi criteria to get both results and count in one trip to the database.
			IMultiCriteria multiCriteria = session.CreateMultiCriteria();
			multiCriteria.Add(recordsCriteria);
			multiCriteria.Add(countCriteria);
			IList multiResult = multiCriteria.List();
	
			IList untypedRecords = multiResult[0] as IList;
			List<Logger> records = new List<Logger>();
			if (untypedRecords != null)
			{
				foreach (Logger obj in untypedRecords)
				{
					records.Add(obj);
				}
			}
			else
			{
				records = new List<Logger>();
			}
	
			totalCount = Convert.ToInt64(((IList)multiResult[1])[0]);
	
			return records;
		}		
		*/
		protected IList getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList records = null;	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				records = (IList)results[0];
				totalCount = (long)((IList)results[1])[0];
				//System.Web.HttpContext.Current.Response.Write("<br>records.Count:"+records.Count);
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			/*
			System.Web.HttpContext.Current.Response.Write("<br>query:"+query);	
			System.Web.HttpContext.Current.Response.Write("<br>queryCount:"+queryCount);	
			System.Web.HttpContext.Current.Response.Write("<br>pageIndex:"+pageIndex+" - pageSize:"+pageSize);	
			System.Web.HttpContext.Current.Response.Write("<br>results==null:"+(results==null));	
			System.Web.HttpContext.Current.Response.Write("<br>results[0]:"+results[0]);
			System.Web.HttpContext.Current.Response.Write("<br>records.Count:"+records.Count);	
			System.Web.HttpContext.Current.Response.Write("<br>totalCount:"+totalCount);	
			System.Web.HttpContext.Current.Response.Write("<br>records.GetType:"+records.GetType());
			System.Web.HttpContext.Current.Response.Write("<br>records[0].ToString():"+records[0].ToString());
			*/
			return records;
		}
	}
}