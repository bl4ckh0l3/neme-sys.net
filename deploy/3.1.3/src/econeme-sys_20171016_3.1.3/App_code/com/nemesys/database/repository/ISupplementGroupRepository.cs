using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ISupplementGroupRepository : IRepository<SupplementGroup>
	{		
		void insert(SupplementGroup supplementGroup);		
		void update(SupplementGroup supplementGroup);		
		void delete(SupplementGroup supplementGroup);
		
		SupplementGroup getById(int id);
		SupplementGroup getByIdCached(int id, bool cached);
				
		IList<SupplementGroup> find(string description, bool cached);
		
		IList<SupplementGroupValue> findSupplementGroupValues(int idGroup, string countryCode, string stateRegionCode);
		IList<SupplementGroupValue> findSupplementGroupValuesCached(int idGroup, string countryCode, string stateRegionCode, bool cached);
		
		IList<SupplementGroup> getSupplementGroups();
		
		SupplementGroupValue getGroupValueById(int id);
		void insertGroupValue(SupplementGroupValue supplementGroupValue);
		void updateGroupValue(SupplementGroupValue supplementGroupValue);
		void deleteGroupValue(SupplementGroupValue supplementGroupValue);
	}
}