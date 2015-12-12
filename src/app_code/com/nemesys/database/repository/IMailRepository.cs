using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IMailRepository : IRepository<MailMsg>
	{		
		void insert(MailMsg value);
		
		void update(MailMsg value);
		
		void delete(MailMsg value);
		
		void saveCompleteMailMsg(MailMsg mail, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		MailMsg getById(int id);
		
		MailMsg getByName(string name, string langCode);
		
		MailMsg getByName(string name, string langCode, string active);

		bool mailAlreadyExists(string name, string langCode, int mailid);

		IList<MailMsg> findActive();
		
		IList<MailMsg> findByCategory(string name);
		
		IList<MailCategory> findCategories();
		
		IList<MailMsg> find(string active, string category, int pageIndex, int pageSize,out long totalCount);
	}
}