using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IVoucherRepository : IRepository<VoucherCampaign>
	{		
		void insert(VoucherCampaign voucherCampaign);	
		void update(VoucherCampaign voucherCampaign);	
		void delete(VoucherCampaign voucherCampaign);
		
		VoucherCampaign getById(int id);
		VoucherCampaign getByLabel(string label);
		
		IList<VoucherCampaign> find(string type, int active);
		
		void insertVoucherCode(VoucherCode voucherCode);
		void updateVoucherCode(VoucherCode voucherCode);
		void deleteVoucherCode(VoucherCode voucherCode);
		void deleteVoucherCodeByCampaign(int voucherCampaign);
		
		VoucherCode getVoucherCodeById(int id);
		VoucherCode getVoucherCodeByCode(string code);
		
		IList<VoucherCode> findVoucherCode(int voucherCampaign);
		
		int countVoucherCodeByCampaign(int voucherCampaign, int userId);
		
		IList<string> getAllVoucherCodes();
	}
}