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
	public class UserPreferencesRepository : IUserPreferencesRepository
	{		
		public void insert(Preference preference)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				preference.insertDate=DateTime.Now;
				session.Save(preference);		
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Preference preference)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(preference);				
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}	
		}
		
		public void delete(Preference preference)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Delete(preference);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}					
		}
		
		public void deleteByUser(int userId)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from Preference where userId=:userId").SetInt32("userId",userId).ExecuteUpdate();				
				tx.Commit();
				NHibernateHelper.closeSession();
			}					
		}
		
		public void deleteByFriend(int userId, int friendId)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from Preference where userId=:userId and friendId=:friendId").SetInt32("userId",userId).SetInt32("friendId",friendId).ExecuteUpdate();				
				tx.Commit();
				NHibernateHelper.closeSession();
			}					
		}
		
		public Preference getById(int id)
		{
			Preference preference = null;	
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				preference = session.Get<Preference>(id);
				NHibernateHelper.closeSession();
			}
			
			return preference;
		}

		public IList<Preference> find(int userId, int friendId, int commentId, int commentType, Nullable<bool> active, Nullable<bool> boolExcludeComments, Nullable<bool> boolExcludeTypes)
		{
			IList<Preference> results = null;
			
			string strSQL = "from Preference where 1=1";
			
			if (userId>0){			
				strSQL += " and userId=:userId";
			}
			
			if (friendId>0){			
				strSQL += " and friendId=:friendId";
			}
			
			if (commentId>0){			
				strSQL += " and commentId=:commentId";
			}
			
			if (commentType>0){			
				strSQL += " and commentType=:commentType";
			}
			
			if(boolExcludeComments != null) {
				if(Convert.ToBoolean(boolExcludeComments)){
					strSQL += " and (ISNULL(commentId) or commentId<=0)";
				}else{
					strSQL += " and (NOT ISNULL(commentId) and commentId>0)";
				}
			}		
			
			if(boolExcludeTypes != null) {
				if(Convert.ToBoolean(boolExcludeTypes)){
					strSQL += " and (ISNULL(type) or type=0)";
				}else{
					strSQL += " and (NOT ISNULL(type) and type!=0)";
				}
			}
			
			if(active != null) {
				if(Convert.ToBoolean(active)){
					strSQL += " and active=1";
				}else{
					strSQL += " and active=0";
				}
			}			
			
			strSQL +=" order by insertDate desc, commentId desc";					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (userId>0){
						q.SetInt32("userId", userId);
					}
					if (friendId>0){
						q.SetInt32("friendId", friendId);
					}
					if (commentId>0){
						q.SetInt32("commentId", commentId);
					}
					if (commentType>0){
						q.SetInt32("commentType", commentType);
					}
					results = q.List<Preference>();
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

		public long getPositivePercentage(int userId)
		{
			long result = 0;
			long resultTotal = 0;
			long resultPositive = 0;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				string strSQLTotal = "SELECT count(`type`) as count FROM USER_PREFERENCES WHERE id_friend=:userId and `type` != 0";				
				IQuery qCount = session.CreateSQLQuery(strSQLTotal).AddScalar("count", NHibernateUtil.Int64);
				qCount.SetInt32("userId",userId);
				resultTotal = qCount.UniqueResult<long>();
				
				string strSQLType = "SELECT count(`type`) as count FROM USER_PREFERENCES WHERE id_friend=:userId and `type`=1";				
				qCount = session.CreateSQLQuery(strSQLType).AddScalar("count", NHibernateUtil.Int64);
				qCount.SetInt32("userId",userId);
				resultPositive = qCount.UniqueResult<long>();				
				
				NHibernateHelper.closeSession();
			}
			
			if(resultTotal > 0)
			{
				result = resultPositive * 100 / resultTotal;
			}			
			
			return result;	
		}

		public long countTotal(int userId, bool exlude)
		{
			long result = 0;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				string strSQLCount = "SELECT count(`type`) as count FROM USER_PREFERENCES WHERE id_friend=:userId";
				if (exlude){			
					strSQLCount += " and `type` != 0";
				}				
				
				IQuery qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64);
				qCount.SetInt32("userId",userId);
				result = qCount.UniqueResult<long>();
				NHibernateHelper.closeSession();
			}
			return result;	
		}

		public long countByType(int userId, int type)
		{
			int result = 0;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				string strSQLCount = "SELECT count(`type`) as count FROM USER_PREFERENCES WHERE id_friend=:userId and `type`=:type";			
				
				IQuery qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64);
				qCount.SetInt32("userId",userId);
				qCount.SetInt32("type",type);
				result = qCount.UniqueResult<int>();
				NHibernateHelper.closeSession();
			}
			return result;	
		}
	}
}