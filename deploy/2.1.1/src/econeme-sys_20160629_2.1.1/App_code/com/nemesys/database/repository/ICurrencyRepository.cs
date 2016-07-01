using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface ICurrencyRepository : IRepository<Currency>
	{		
		void insert(Currency value);
		
		void update(Currency value);
		
		void delete(Currency value);
		
		void saveCompleteCurrency(Currency currency, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		Currency getById(int id);

		Currency findDefault();

		Currency getByCurrency(string currency);
		
		IList<Currency> findAll(Nullable<bool> active);
		
		IList<Currency> find(string currency, Nullable<bool> active, int pageIndex, int pageSize,out long totalCount);
		
		decimal convertCurrency(decimal amount, string currencyFrom, string currencyTo);
	}
}