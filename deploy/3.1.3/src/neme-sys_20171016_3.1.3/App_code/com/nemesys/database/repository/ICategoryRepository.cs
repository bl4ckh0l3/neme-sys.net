using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ICategoryRepository : IRepository<Category>
	{		
		void insert(Category value);
		
		void update(Category value);
		
		void delete(Category value);
		
		void saveCompleteCategory(Category category, IList<User> usersToUpdate, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		Category getById(int id);
		
		Category getByIdCached(int id, bool cached);
		
		IList<Category> getCategoryList();
		
		IList<Category> getCategoryListCached(bool cached);

		IList<Category> findActive();
		
		IList<Category> findActiveCached(bool cached);

		Category getByDescription(string description);
		
		Category getByHierarchy(string hierarchy);
		
		Category getByHierarchyCached(string hierarchy, bool cached);
		
		Category getByTemplate(int templateId, string virtualPath);
		
		Category getByTemplateCached(int  templateId, string virtualPath, bool cached);
		
		bool categoryAlreadyExists(string hierarchy, string description, int catid);
		
		IList<Category> find(int menu, Nullable<bool> active);
		
		IList<Category> findCached(int menu, Nullable<bool> active, bool cached);
		
		Category findFirstSubCategoryWithElements(Category category);
		
		Category findFirstSubCategoryWithElementsCached(Category category, bool cached);
		
		Category findFirstCategory();
		
		Category findFirstCategoryCached(bool cached);
		
		Category findFirstChildCategory(Category category);
		
		Category findFirstChildCategoryCached(Category category, bool cached);
		
		IList<Category> find(string hierarchyOrDescription, int pageIndex, int pageSize,out long totalCount);
	}
}