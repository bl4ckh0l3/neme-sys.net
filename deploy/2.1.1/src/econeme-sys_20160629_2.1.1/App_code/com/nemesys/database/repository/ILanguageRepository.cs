using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ILanguageRepository : IRepository<Language>
	{		
		void insert(Language value);
		
		void update(Language value);
		
		void delete(Language value);
		
		Language getById(int id);
		
		void saveCompleteLanguage(Language language, IList<User> usersToUpdate);

		IList<AvailableLanguage> getAvailableLanguageList();

		IList<Language> getLanguageList();
		
		IList<Language> getLanguageList(bool cached);

		IList<Language> findActive();

		IList<Language> findActive(bool cached);
		
		Language getByLabel(string label);
		
		Language getByLabel(string label, bool cached);
		
		IList<Language> find(int pageIndex, int pageSize,out long totalCount);
	}
}