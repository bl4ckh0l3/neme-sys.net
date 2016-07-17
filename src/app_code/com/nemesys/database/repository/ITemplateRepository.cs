using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ITemplateRepository : IRepository<Template>
	{		
		void insert(Template template);
		
		void update(Template template);
		
		void delete(Template template);
		
		void clone(Template template, string newdir);
		
		Template getById(int id);
		
		Template getByIdCached(int id, bool cached);
				
		TemplateVO getByUrlRewrite(string urlRewrite);
		
		TemplateVO getByUrlRewriteCached(string urlRewrite, bool cached);
		
		Template getByDirectory(string directory);
		
		Template getByDirectoryCached(string directory, bool cached);
		
		IList<Template> getTemplateList();
		
		IList<Template> find(int pageIndex, int pageSize,out long totalCount);		
		
		TemplatePage getPageById(int id);
		
		TemplatePage getPageByIdCached(int id, bool cached);
		
		IList<TemplatePage> getTemplatePages(int templateId);	
		
		TemplatePage findByPriority(int templateId, int priority);
		
		void deleteTemplatePage(TemplatePage page);
		
		void updateTemplatePage(TemplatePage page);
		
		int findMaxPriority(int templateId);
		
		int findMaxPriority(Template template);
	}
}