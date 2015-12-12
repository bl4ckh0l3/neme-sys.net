using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IFeeRepository : IRepository<Fee>
	{		
		void insert(Fee fee);		
		void update(Fee fee);		
		void delete(Fee fee);
		
		void saveCompleteFee(Fee fee, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		Fee getById(int id);
		Fee getByIdCached(int id, bool cached);
				
		IList<Fee> find(string description, int type, string applyTo, bool cached);
				
		void insertFeeConfig(FeeConfig feeConfig);
		void updateFeeConfig(FeeConfig feeConfig);
		void deleteFeeConfig(FeeConfig feeConfig);
		void deleteFeeConfigByIdFee(int idFee);
		
		FeeConfig getFeeConfigById(int id);
		FeeConfig getFeeConfigByIdCached(int id, bool cached);	
		
		IList<FeeConfig> findFeeConfigs(int idFee, int idProdField);		
		IList<FeeConfig> findFeeConfigsCached(int idFee, int idProdField, bool cached);
	}
}