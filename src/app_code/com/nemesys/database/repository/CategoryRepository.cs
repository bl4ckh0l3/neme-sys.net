using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using System.IO;
using System.Web.Caching;
using com.nemesys.model;
using com.nemesys.database;

namespace com.nemesys.database.repository
{
	public class CategoryRepository : ICategoryRepository
	{	
		//private IList<AvailableLanguage> availableLanguages = null;
	
		public void insert(Category category)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<CategoryTemplate> newTemplates = new List<CategoryTemplate>();
				if(category.templates != null && category.templates.Count>0)
				{
					foreach(CategoryTemplate ct in category.templates){
						CategoryTemplate nct = new CategoryTemplate();
						nct.templateId = ct.templateId;
						nct.langCode = ct.langCode;								
						newTemplates.Add(nct);
					}
					category.templates.Clear();							
				}
				session.Save(category);

				if(newTemplates != null && newTemplates.Count>0)
				{							
					foreach(CategoryTemplate ct in newTemplates){
						ct.categoryId = category.id;
						session.Save(ct);
					}
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString());  
				if(cacheKey.Contains("category-template"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-first"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-first-child"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-category"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-category-active"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-category-params"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void update(Category category)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				IList<CategoryTemplate> newTemplates = new List<CategoryTemplate>();
				if(category.templates != null && category.templates.Count>0)
				{
					foreach(CategoryTemplate ct in category.templates){
						CategoryTemplate nct = new CategoryTemplate();
						nct.categoryId = ct.categoryId;
						nct.templateId = ct.templateId;
						nct.langCode = ct.langCode;								
						newTemplates.Add(nct);
					}
					category.templates.Clear();							
				}
				session.Update(category);	
																		
				string sql = "delete from CategoryTemplate where categoryId = :categoryId";
				session.CreateQuery(sql).SetInt32("categoryId",category.id).ExecuteUpdate();
					
				if(newTemplates != null && newTemplates.Count>0)
				{							
					foreach(CategoryTemplate ct in newTemplates){
						session.Save(ct);
					}
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("category-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("category-hierarchy-"+category.hierarchy))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("category-first-sub-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("category-first-child-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}	
				else if(cacheKey.Contains("category-template"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-first"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 							
				else if(cacheKey.Contains("list-category"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-category-active"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-category-params"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public void delete(Category category)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(category.templates != null && category.templates.Count>0)
				{
					session.CreateQuery("delete from CategoryTemplate where categoryId = :categoryId").SetInt32("categoryId",category.id).ExecuteUpdate();
					category.templates.Clear();						
				}	
				session.CreateQuery("delete from UserCategory where idCategory = :idCategory").SetInt32("idCategory",category.id).ExecuteUpdate();				
				session.Delete(category);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("category-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-hierarchy-"+category.hierarchy))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("category-first-sub-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("category-first-child-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}	
				else if(cacheKey.Contains("category-template"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-first"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 							
				else if(cacheKey.Contains("list-category"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-category-active"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-category-params"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
			}
		}

		public void saveCompleteCategory(Category category, IList<User> usersToUpdate, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(category.id != -1){	
						IList<CategoryTemplate> newTemplates = new List<CategoryTemplate>();
						//List<string> ids1 = new List<string>();
						if(category.templates != null && category.templates.Count>0)
						{
							foreach(CategoryTemplate ct in category.templates){
								CategoryTemplate nct = new CategoryTemplate();
								nct.categoryId = ct.categoryId;
								nct.templateId = ct.templateId;
								nct.langCode = ct.langCode;								
								newTemplates.Add(nct);
								//ids1.Add(ct.templateId.ToString());
							}
							category.templates.Clear();							
						}
						session.Update(category);	
																				
						string sql = "delete from CategoryTemplate where categoryId = :categoryId";
						//if(ids1.Count>0){sql+=string.Format(" and templateId not in ({0})",string.Join(",",ids1.ToArray()));}
						session.CreateQuery(sql).SetInt32("categoryId",category.id).ExecuteUpdate();
							
						if(newTemplates != null && newTemplates.Count>0)
						{							
							foreach(CategoryTemplate ct in newTemplates){
								session.Save(ct);
							}
						}
					}else{
						IList<CategoryTemplate> newTemplates = new List<CategoryTemplate>();
						if(category.templates != null && category.templates.Count>0)
						{
							foreach(CategoryTemplate ct in category.templates){
								CategoryTemplate nct = new CategoryTemplate();
								nct.templateId = ct.templateId;
								nct.langCode = ct.langCode;								
								newTemplates.Add(nct);
							}
							category.templates.Clear();							
						}
						session.Save(category);

						if(newTemplates != null && newTemplates.Count>0)
						{							
							foreach(CategoryTemplate ct in newTemplates){
								ct.categoryId = category.id;
								session.Save(ct);
							}
						}
					}						
					// ************** PERSISTO CATEGORIE X UTENTI
					if(usersToUpdate != null && usersToUpdate.Count>0){						
						foreach (User u in usersToUpdate){
							if(u.categories != null)
							{
								IList<UserCategory> newUCats = new List<UserCategory>();
								foreach (UserCategory k in u.categories)
								{
									UserCategory nut = new UserCategory();
									nut.idCategory = k.idCategory;
									if(k.idCategory == -1){
										nut.idCategory = category.id;
									}
									nut.idParentUser = k.idParentUser;						
									newUCats.Add(nut);
								}
								u.modifyDate = DateTime.Now;
								u.categories.Clear();
								session.Update(u);
													
								string sql = "delete from UserCategory where idParentUser = :idParentUser";
								session.CreateQuery(sql).SetInt32("idParentUser",u.id).ExecuteUpdate();			
								//session.Flush();
								if(newUCats != null && newUCats.Count>0)
								{						
									foreach(UserCategory ut in newUCats){
										session.Save(ut);
									}
								}
							}
						}
					}											
					// ************** AGGIUNGO TGUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione, meta_xxx ecc
					foreach (MultiLanguage mu in deltranslactions){
						session.Delete(mu);
					}
					foreach (MultiLanguage mu in updtranslactions){
						session.SaveOrUpdate(mu);
					}
					foreach (MultiLanguage mi in newtranslactions){
						session.Save(mi);
					}
					tx.Commit();
					NHibernateHelper.closeSession();
				}catch(Exception exx){
					//Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("category-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-hierarchy-"+category.hierarchy))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}				 
				else if(cacheKey.Contains("category-first-sub-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("category-first-child-"+category.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}	
				else if(cacheKey.Contains("category-template"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("category-first"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 							
				else if(cacheKey.Contains("list-category"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-category-active"))
				{ 	
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-category-params"))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
	
		public IList<Category> getCategoryList()
		{
			return getCategoryListCached(false);
		}
	
		public IList<Category> getCategoryListCached(bool cached)
		{
			IList<Category> results = null;
			
			if(cached)
			{
				results = (IList<Category>)HttpContext.Current.Cache.Get("list-category");
				if(results != null){
					return results;
				}
			}	
						
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from Category order by  cast(hierarchy as double) asc");
				results = q.List<Category>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<Category>();
				}
				HttpContext.Current.Cache.Insert("list-category", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}
	
		public IList<Category> findActive()
		{
			return findActiveCached(false);
		}
	
		public IList<Category> findActiveCached(bool cached)
		{
			IList<Category> results = null;
			
			if(cached)
			{
				results = (IList<Category>)HttpContext.Current.Cache.Get("list-category-active");
				if(results != null){
					return results;
				}
			}	
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{			
				IQuery q = session.CreateQuery("from Category where visible=1 order by  cast(hierarchy as double) asc");
				results = q.List<Category>();
				if(results != null && results.Count>0)
				{
					foreach(Category c in results)
					{
						c.templates = session.CreateCriteria(typeof(CategoryTemplate))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("categoryId", c.id))
						.List<CategoryTemplate>();							
					}
				}
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<Category>();
				}
				HttpContext.Current.Cache.Insert("list-category-active", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
				
			return results;
		}

		public Category getByDescription(string description)
		{
			Category result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				IQuery q = session.CreateQuery("from Category where description= :description");
				q.SetString("description",description);
				result = q.UniqueResult<Category>();
				
				IList<CategoryTemplate> results = new List<CategoryTemplate>();
				q = session.CreateQuery("from CategoryTemplate  where categoryId=:categoryId");
				q.SetInt32("categoryId",result.id);
				results = q.List<CategoryTemplate>();
				if(results != null && results.Count>0){
					result.templates = results;
				}			
				NHibernateHelper.closeSession();
			}
			return result;			
		}

		public Category getByHierarchy(string hierarchy)
		{
			return getByHierarchyCached(hierarchy, false);
		}
		
		public Category getByHierarchyCached(string hierarchy, bool cached)
		{
			Category result = null;
			
			if(cached)
			{
				result = (Category)HttpContext.Current.Cache.Get("category-hierarchy-"+hierarchy);
				if(result != null){
					return result;
				}
			}	
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from Category where hierarchy= :hierarchy");
				q.SetString("hierarchy",hierarchy);
				result = q.UniqueResult<Category>();
				result.templates = session.CreateCriteria(typeof(CategoryTemplate))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("categoryId", result.id))
				.List<CategoryTemplate>();				
				NHibernateHelper.closeSession();
			}	
			
			if(cached)
			{
				if(result == null){
					result = new Category();
					result.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-hierarchy-"+hierarchy, result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
				
			return result;	
		}

		public Category getByTemplate(int  templateId)
		{
			return getByTemplateCached(templateId, false);
		}

		public Category getByTemplateCached(int  templateId, bool cached)
		{
			Category result = null;
			
			if(cached)
			{
				result = (Category)HttpContext.Current.Cache.Get("category-template-"+templateId);
				if(result != null){
					return result;
				}
			}	
			
			IList<Category> categories = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from Category where idTemplate=:templateId");
				q.SetInt32("templateId",templateId);
				categories = q.List<Category>();
				
				if(categories!=null && categories.Count>0)
				{
					result = categories[0];
					if(result != null)
					{
						result.templates = session.CreateCriteria(typeof(CategoryTemplate))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("categoryId", result.id))
						.List<CategoryTemplate>();	
					}				
				}
				else
				{
					q = session.CreateQuery("from Category where id in(select templateId from CategoryTemplate where templateId=:templateId)");
					q.SetInt32("templateId",templateId);
					IList<Category> results = q.List<Category>();

					if(results != null && results.Count>0)
					{
						result = results[0];
						if(result != null)
						{
							result.templates = session.CreateCriteria(typeof(CategoryTemplate))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("categoryId", result.id))
							.List<CategoryTemplate>();	
						}
					}
				}
					
				NHibernateHelper.closeSession();
			}		
			
			if(cached)
			{
				if(result == null){
					result = new Category();
					result.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-template-"+templateId, result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return result;	
		}
	
		public Category getById(int id)
		{		
			return getByIdCached(id, false);
		}
	
		public Category getByIdCached(int id, bool cached)
		{		
			Category element = null;	

			if(cached)
			{
				element = (Category)HttpContext.Current.Cache.Get("category-"+id);
				if(element != null){
					return element;
				}
			}			
					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				element = session.Get<Category>(id);	
				element.templates = session.CreateCriteria(typeof(CategoryTemplate))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("categoryId", element.id))
				.List<CategoryTemplate>();		
				NHibernateHelper.closeSession();
			}	
			
			if(cached)
			{
				if(element == null){
					element = new Category();
					element.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-"+id, element, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
				
			return element;
		}

		public bool categoryAlreadyExists(string hierarchy, string description, int catid)
		{
			bool exist = false;
			IList<Category> categories = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from Category where (hierarchy= :hierarchy or description=:description) and id != :catid");
				q.SetString("hierarchy",hierarchy);	
				q.SetString("description",description);	
				q.SetInt32("catid",catid);	
				categories = q.List<Category>();
				NHibernateHelper.closeSession();					
			}				
			if(categories!=null && categories.Count >0)
			{
				exist=true;
			}			
			return exist;		
		}
	
		public IList<Category> find(int menu, Nullable<bool> active)
		{
			return findCached(menu, active, false);
		}
	
		public IList<Category> findCached(int menu, Nullable<bool> active, bool cached)
		{
			IList<Category> results = null;
			StringBuilder cacheKey = null;
			
			if(cached)
			{
				cacheKey = new StringBuilder("list-category-params-").Append(menu).Append("-").Append(active);
				results = (IList<Category>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Category where 1=1";
				if (menu>0){			
					strSQL += " and numMenu=:menu";
				}
				if (active != null){			
					strSQL += " and visible=:visible";
				}			
				strSQL +=" order by cast(hierarchy as double) asc";				
				
				IQuery q = session.CreateQuery(strSQL);
				if (menu>0){			
					q.SetInt32("menu",menu);
				}
				if (active != null){			
					q.SetBoolean("visible",Convert.ToBoolean(active));
				}
				results = q.List<Category>();
				if(results != null && results.Count>0)
				{
					foreach(Category c in results)
					{
						c.templates = session.CreateCriteria(typeof(CategoryTemplate))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("categoryId", c.id))
						.List<CategoryTemplate>();							
					}
				}				
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(results == null){
					results = new List<Category>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;
		}	

		public Category findFirstCategory()
		{
			return findFirstCategoryCached(false);
		}		

		public Category findFirstCategoryCached(bool cached)
		{
			Category founded = null;

			if(cached)
			{
				founded = (Category)HttpContext.Current.Cache.Get("category-first");
				if(founded != null){
					return founded;
				}
			}
			
			IList<Category> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Category order by cast(hierarchy as double) asc";			
				IQuery q = session.CreateQuery(strSQL);	
				results = q.List<Category>();			
				if(results != null){
					foreach(Category cat in results)
					{
						founded = cat;
						if(founded != null)
						{
							founded.templates = session.CreateCriteria(typeof(CategoryTemplate))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("categoryId", founded.id))
							.List<CategoryTemplate>();	
						}
						break;
					}
				}				
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(founded == null){
					founded = new Category();
					founded.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-first", founded, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return founded;			
		}
	
		public Category findFirstSubCategoryWithElements(Category category)
		{
			return findFirstSubCategoryWithElementsCached(category, false);
		}
	
		public Category findFirstSubCategoryWithElementsCached(Category category, bool cached)
		{
			Category founded = null;

			if(cached)
			{
				founded = (Category)HttpContext.Current.Cache.Get("category-first-sub-"+category.id);
				if(founded != null){
					return founded;
				}
			}
			
			IList<Category> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Category where hierarchy like:hierarchy order by cast(hierarchy as double) asc";			
				IQuery q = session.CreateQuery(strSQL);	
				q.SetString("hierarchy", String.Format("{0}.%", category.hierarchy));
				results = q.List<Category>();
				if(results != null){
					foreach(Category cat in results)
					{
						if(cat.hasElements){
							founded = cat;
							if(founded != null)
							{
								founded.templates = session.CreateCriteria(typeof(CategoryTemplate))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("categoryId", founded.id))
								.List<CategoryTemplate>();	
							}
							break;
						}
					}
				}
				NHibernateHelper.closeSession();
			}			

			if(cached)
			{
				if(founded == null){
					founded = new Category();
					founded.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-first-sub-"+category.id, founded, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return founded;
		}		

		public Category findFirstChildCategory(Category category)
		{
			return findFirstChildCategoryCached(category, false);
		}	

		public Category findFirstChildCategoryCached(Category category, bool cached)
		{
			Category founded = null;

			if(cached)
			{
				founded = (Category)HttpContext.Current.Cache.Get("category-first-child-"+category.id);
				if(founded != null){
					return founded;
				}
			}
			
			IList<Category> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from Category where hierarchy like:hierarchy order by cast(hierarchy as double) asc";			
				//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL+"<br>");
				IQuery q = session.CreateQuery(strSQL);	
				q.SetString("hierarchy", String.Format("{0}.%", category.hierarchy));
				results = q.List<Category>();
				if(results != null){
					foreach(Category cat in results)
					{
						founded = cat;
						if(founded != null)
						{
							founded.templates = session.CreateCriteria(typeof(CategoryTemplate))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("categoryId", founded.id))
							.List<CategoryTemplate>();	
						}
						break;
					}
				}
				NHibernateHelper.closeSession();
			}
			
			//System.Web.HttpContext.Current.Response.Write("results != null: " + results != null +"<br>");
			

			if(cached)
			{
				if(founded == null){
					founded = new Category();
					founded.id=-1;
				}
				HttpContext.Current.Cache.Insert("category-first-child-"+category.id, founded, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return founded;			
		}

		public IList<Category> find(string hierarchyOrDescription, int pageIndex, int pageSize,out long totalCount)
		{		
			IList<Category> categories = null;		
			totalCount = 0;	
			string strSQL = "from Category where 1=1";
			if (!String.IsNullOrEmpty(hierarchyOrDescription)){			
				strSQL += " and (hierarchy like :hierarchy  or description like :description)";
			}			
			strSQL +=" order by cast(hierarchy as double) asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (!String.IsNullOrEmpty(hierarchyOrDescription)){
						q.SetString("hierarchy", String.Format("%{0}%", hierarchyOrDescription));
						q.SetString("description", String.Format("%{0}%", hierarchyOrDescription));
						qCount.SetString("hierarchy", String.Format("%{0}%", hierarchyOrDescription));
						qCount.SetString("description", String.Format("%{0}%", hierarchyOrDescription));
					}
					categories = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
					if(categories != null){
						foreach(Category category in categories){							
							category.templates = session.CreateCriteria(typeof(CategoryTemplate))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("categoryId", category.id))
							.List<CategoryTemplate>();	
						}
					}
					//System.Web.HttpContext.Current.Response.Write("languages.Count: " + languages.GetType()+"<br>");
				}
				catch(Exception ex)
				{
					System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return categories;
		}
	
		protected IList<Category> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Category> records = new List<Category>();	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				IList recordstmp = (IList)results[0];
				//System.Web.HttpContext.Current.Response.Write("pageIndex: " + pageIndex + " - pageSize:"+pageSize+"<br>");
				//System.Web.HttpContext.Current.Response.Write("query: " + query +"<br>");
				//System.Web.HttpContext.Current.Response.Write("queryCount: " + queryCount +"<br>");
				totalCount = (long)((IList)results[1])[0];
				//System.Web.HttpContext.Current.Response.Write("records.Count: " + records.Count + " - totalCount:"+totalCount+"<br>");

				if(recordstmp != null)
				{
					foreach(Object tmp in recordstmp)
					{
						records.Add((Category)tmp);
					}
				}
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: RETURN NULL
			}
			return records;
		}		
	}
}