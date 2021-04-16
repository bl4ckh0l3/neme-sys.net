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
	public class CommentRepository : ICommentRepository
	{		
		public void insert(Comment comment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				comment.insertDate=DateTime.Now;
				session.Save(comment);		
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(Comment comment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(comment);				
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}	
		}
		
		public void delete(Comment comment)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from Preference where commentId=:commentId").SetInt32("commentId",comment.id).ExecuteUpdate();
				session.Delete(comment);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}					
		}
		
		public void deleteByElement(int elementId, int elementType)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from Preference where commentId in(select id from Comment where elementId=:elementId and elementType=:elementType)").SetInt32("elementId",elementId).SetInt32("elementType",elementType).ExecuteUpdate();
				session.CreateQuery("delete from Comment where elementId=:elementId and elementType=:elementType").SetInt32("elementId",elementId).SetInt32("elementType",elementType).ExecuteUpdate();				
				tx.Commit();
				NHibernateHelper.closeSession();
			}					
		}
		
		public Comment getById(int id)
		{
			Comment comment = null;	
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				comment = session.Get<Comment>(id);
				NHibernateHelper.closeSession();
			}
			
			return comment;
		}

		public IList<Comment> find(int userId, int elementId, int elementType, Nullable<bool> active)
		{
			IList<Comment> results = null;
			
			string strSQL = "from Comment where 1=1";
			
			if (userId>0){			
				strSQL += " and userId=:userId";
			}
			
			if (elementId>0){			
				strSQL += " and elementId=:elementId";
			}
			
			if (elementType!=0){			
				strSQL += " and elementType=:elementType";
			}
			
			if (active != null){
				strSQL += " and active=:active";
			}
			
			strSQL +=" order by insertDate desc";					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (userId>0){
						q.SetInt32("userId", userId);
					}
					if (elementId>0){
						q.SetInt32("elementId", elementId);
					}
					if (elementType!=0){
						q.SetInt32("elementType", elementType);
					}
					if (active != null){
						q.SetBoolean("active", Convert.ToBoolean(active));
					}
					results = q.List<Comment>();
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

		public long countComments(int userId, int elementType, Nullable<bool> active, bool doDistinct)
		{
			long result = 0;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sqlPortion = "*";
				if(doDistinct){
					sqlPortion = "distinct(id_element)";					
				}
				
				string strSQLCount = "SELECT count("+sqlPortion+") as count FROM COMMENT WHERE id_user=:userId";
				if (elementType!=0){			
					strSQLCount += " and element_type=:elementType";
				}
				
				if (active != null){
					strSQLCount += " and active=:active";
				}				
				
				IQuery qCount = session.CreateSQLQuery(strSQLCount).AddScalar("count", NHibernateUtil.Int64);
				qCount.SetInt32("userId",userId);
				if (elementType!=0){
					qCount.SetInt32("elementType", elementType);
				}
				if (active != null){
					qCount.SetBoolean("active", Convert.ToBoolean(active));
				}
				result = qCount.UniqueResult<long>();
				NHibernateHelper.closeSession();
			}
			return result;	
		}
	}
}