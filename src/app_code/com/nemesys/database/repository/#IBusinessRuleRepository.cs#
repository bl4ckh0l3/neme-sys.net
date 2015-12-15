using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IBusinessRuleRepository : IRepository<BusinessRule>
	{		
		void insert(BusinessRule businessRule);
		
		void update(BusinessRule businessRule);
		
		void delete(BusinessRule businessRule);
		
		BusinessRule getById(int id);
		
		IList<BusinessRule> find(string type, int active);
		
		void insertBusinessRuleConfig(BusinessRuleConfig businessRuleConfig);
		void updateBusinessRuleConfig(BusinessRuleConfig businessRuleConfig);
		void deleteBusinessRuleConfig(BusinessRuleConfig businessRuleConfig);
		void deleteBusinessRuleConfigByRule(int idRule);
		
		BusinessRuleConfig getBusinessRuleConfigById(int id);
		IList<BusinessRuleConfig> findBusinessRuleConfig(int ruleId, int productId);
	}
}