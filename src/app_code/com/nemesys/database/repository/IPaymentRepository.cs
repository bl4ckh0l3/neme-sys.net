using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IPaymentRepository : IRepository<Payment>
	{		
		void insert(Payment payment);		
		void update(Payment payment);		
		void delete(Payment payment);
		
		Payment getById(int id);
		Payment getByIdCached(int id, bool cached);
		
		void saveCompletePayment(Payment Payment, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
				
		IList<Payment> find(int idModule, int paymentType, string isActive, string applyTo, bool withFields, bool cached);
		
		IList<IPaymentField> getPaymentFields(int idPayment, int idModule, string keyword, string matchField, string doMatch);
		IList<IPaymentField> getPaymentFieldsCached(int idPayment, int idModule, string keyword, string matchField, string doMatch, bool cached);
		
		IPaymentField getPaymentFieldById(int idField);		
		IPaymentField getPaymentFieldByIdCached(int idField, bool cached);
	}
}