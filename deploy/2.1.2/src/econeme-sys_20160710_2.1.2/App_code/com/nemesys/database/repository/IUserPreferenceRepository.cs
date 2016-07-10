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
	public interface IUserPreferencesRepository
	{		
		void insert(Preference preference);
		
		void update(Preference preference);
		
		void delete(Preference preference);
		
		void deleteByUser(int userId);
		
		void deleteByFriend(int userId, int friendId);
		
		Preference getById(int id);

		IList<Preference> find(int userId, int friendId, int commentId, int commentType, Nullable<bool> active, Nullable<bool> boolExcludeComments, Nullable<bool> boolExcludeTypes);
		
		long getPositivePercentage(int userId);

		long countTotal(int userId, bool exclude);
		
		long countByType(int userId, int elementType);
	}
}