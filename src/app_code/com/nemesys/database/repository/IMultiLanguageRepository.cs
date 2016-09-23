using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IMultiLanguageRepository : IRepository<MultiLanguage>
	{		
		void insert(MultiLanguage values);
		
		void update(MultiLanguage values);
		
		void delete(MultiLanguage values);
				
		void insert(IList<MultiLanguage> values);
		
		void update(IList<MultiLanguage> values);
		
		void delete(IList<MultiLanguage> values);
		
		MultiLanguage getById(int id);
		
		string translate(string keyword, string currentLangCode, string defaultLangCode);
		
		string convertLocaleCode(string code);		
		
		string convertErrorCode(string code);	
		
		string convertMessageCode(string code);	

		MultiLanguage find(string keyword, string langCode);
		
		IList<MultiLanguage> find(string keyword);
		
		IDictionary<string, MultiLanguage> find(string find_key_value, int pageIndex, int pageSize, int langSize, out IList<string> distinctKeys, out long totalCount);
		
	}
}