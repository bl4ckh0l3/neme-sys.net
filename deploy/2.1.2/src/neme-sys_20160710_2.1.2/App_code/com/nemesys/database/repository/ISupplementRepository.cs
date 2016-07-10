using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ISupplementRepository : IRepository<Supplement>
	{		
		void insert(Supplement supplement);		
		void update(Supplement supplement);		
		void delete(Supplement supplement);
		
		Supplement getById(int id);
		Supplement getByIdCached(int id, bool cached);
		
		void saveCompleteSupplement(Supplement supplement, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
				
		IList<Supplement> find(string description, int type, bool cached);
	}
}