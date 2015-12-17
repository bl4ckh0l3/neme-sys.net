using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IOrderRepository : IRepository<FOrder>
	{		
		void insert(FOrder order);
		
		void update(FOrder order);
		
		void delete(FOrder order);
		
		void saveCompleteOrder(FOrder order, IList<OrderProduct> ops, IList<OrderProductField> opfs, IList<OrderProductAttachmentDownload> opads, IList<OrderFee> ofs, BillsAddress billsAddress, OrderBillsAddress orderBillsAddress, ShippingAddress shippingAddress, OrderShippingAddress orderShippingAddress, IList<OrderBusinessRule> obrs, IList<OrderVoucher> ovs, int voucherCodeId);
		
		FOrder getById(int id);
		
		FOrder getById(int id, bool withItems);
		
		IList<FOrder> getByIdUser(int idUser, bool withItems);
		
		int countByIdUser(int idUser);
				
		IList<FOrder> find(bool withItems);
		
		IList<OrderFee> findFeesByOrderId(int idOrder);
		
		IList<OrderProductField> findItemFields(int idOrder, int idProd, int prodCounter);
		
		void insertOrderShippingAddress(OrderShippingAddress orderShippingAddress);
		void updateOrderShippingAddress(OrderShippingAddress orderShippingAddress);
		void deleteOrderShippingAddress(OrderShippingAddress orderShippingAddress);
		
		OrderShippingAddress getOrderShippingAddress(int orderId);
		OrderShippingAddress getOrderShippingAddressCached(int orderId, bool cached);
		
		void insertOrderBillsAddress(OrderBillsAddress orderBillsAddress);
		void updateOrderBillsAddress(OrderBillsAddress orderBillsAddress);
		void deleteOrderBillsAddress(OrderBillsAddress orderBillsAddress);
		
		OrderBillsAddress getOrderBillsAddress(int orderId);
		OrderBillsAddress getOrderBillsAddressCached(int orderId, bool cached);	
		
		IList<OrderBusinessRule> findOrderBusinessRule(int idOrder, bool withItems);
		
		void insertOrderBusinessRule(OrderBusinessRule orderBusinessRule);
		void updateOrderBusinessRule(OrderBusinessRule orderBusinessRule);
		void deleteOrderBusinessRule(OrderBusinessRule orderBusinessRule);
		void deleteOrderBusinessRuleByOrder(int idOrder);
		void deleteOrderBusinessRuleByOrderAndItem(int idOrder, int idItem);
		void deleteOrderBusinessRuleByOrderAndRule(int idOrder, int idRule);
		
		OrderVoucher getOrderVoucher(int idOrder);
		
		void insertOrderVoucher(OrderVoucher orderVoucher);
		void updateOrderVoucher(OrderVoucher orderVoucher);
		void deleteOrderVoucherByOrder(int idOrder);
	}
}