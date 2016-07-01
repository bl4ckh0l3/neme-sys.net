using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IBillsAddressRepository : IRepository<BillsAddress>
	{		
		void insert(BillsAddress billsAddress);		
		void update(BillsAddress billsAddress);		
		void delete(BillsAddress billsAddress);
		
		BillsAddress getById(int id);
		BillsAddress getByIdCached(int id, bool cached);
		
		BillsAddress getByUserId(int userId);
		BillsAddress getByUserIdCached(int userId, bool cached);
	}
}