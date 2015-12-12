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
	public interface ICommentRepository
	{		
		void insert(Comment comment);
		
		void update(Comment comment);
		
		void delete(Comment comment);
		
		void deleteByElement(int elementId, int elementType);
		
		Comment getById(int id);

		IList<Comment> find(int userId, int elementId, int elementType, string active);

		long countComments(int userId, int elementType, string active, bool doDistinct);
	}
}