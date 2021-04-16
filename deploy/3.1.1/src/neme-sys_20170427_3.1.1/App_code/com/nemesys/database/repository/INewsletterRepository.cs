using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface INewsletterRepository : IRepository<Newsletter>
	{		
		void insert(Newsletter value);
		
		void update(Newsletter value);
		
		void delete(Newsletter value);
		
		Newsletter getById(int id);
		
		IList<Newsletter> findActive();
		
		IList<Newsletter> find(int pageIndex, int pageSize,out long totalCount);
		
		int findSubscribed(int idNewsletter);
	}
}