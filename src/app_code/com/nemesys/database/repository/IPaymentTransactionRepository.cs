using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IPaymentTransactionRepository : IRepository<PaymentTransaction>
	{		
		void insert(PaymentTransaction paymentTransaction);		
		void update(PaymentTransaction paymentTransaction);		
		void delete(PaymentTransaction paymentTransaction);
		
		void savePaymentTransaction(FOrder order, PaymentTransaction paymentTransaction);
		
		PaymentTransaction getById(int id);
		PaymentTransaction getByIdCached(int id, bool cached);
				
		IList<PaymentTransaction> find(int idOrder, int idModule, string idTransaction, Nullable<bool> notified, bool cached);
		
		bool isPaymentTransactionNotified(PaymentTransaction paymentTransaction);
		
		bool hasPaymentTransactionNotified(int idOrder);
	}
}