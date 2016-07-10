using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ISearchRepository
	{				
		IList<FContent> search(string title, string summary, string description, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool doAnd, bool withAttach, bool withLang, bool withCats, bool withFields);
	}
}