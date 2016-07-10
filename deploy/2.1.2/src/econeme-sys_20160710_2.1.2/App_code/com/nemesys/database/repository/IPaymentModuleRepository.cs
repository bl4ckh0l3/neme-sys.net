using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IPaymentModuleRepository : IRepository<PaymentModule>
	{		
		void insert(PaymentModule paymentModule);		
		void update(PaymentModule paymentModule);		
		void delete(PaymentModule paymentModule);
		
		PaymentModule getById(int id);
		PaymentModule getByIdCached(int id, bool cached);
		
		PaymentModule getByName(string name);
		PaymentModule getByNameCached(string name, bool cached);
				
		IList<PaymentModule> find(int idModule, string name, bool cached);
		
		IList<IPaymentField> getPaymentModuleFields(int idModule, string keyword, string matchField, Nullable<bool> doMatch);
		IList<IPaymentField> getPaymentModuleFieldsCached(int idModule, string keyword, string matchField, Nullable<bool> doMatch, bool cached);
	}
}