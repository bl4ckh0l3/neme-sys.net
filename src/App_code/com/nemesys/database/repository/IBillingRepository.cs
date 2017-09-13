using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IBillingRepository : IRepository<Billing>
	{		
		void insert(Billing value);
		
		void update(Billing value);
		
		void delete(Billing value);
		
		void saveCompleteBilling(Billing billing, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		Billing getById(int id);
		
		IList<Billing> findAll();
		
		IList<Billing> find(int orderId);	
		
		void insertBillingData(BillingData value);
		
		void updateBillingData(BillingData value);
		
		void deleteBillingData(BillingData value);
		
		void saveBillingData(BillingData value);
		
		BillingData getBillingData();
	}
}