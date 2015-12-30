using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ILoggerRepository : IRepository<Logger>
	{
		void insert(Logger values);
		
		void update(Logger values);
		
		void delete(Logger values);
		
		Logger getById(int id);
		
		void write(Logger logger);
		
		void deleteBy(string type, string dta_from, string dta_to);

		IDictionary<int, Logger> find(string type, string dta_from, string dta_to, int pageIndex, int pageSize, out long totalCount);
		
		IList<Logger> getAll();
	}
}