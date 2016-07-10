using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IShippingAddressRepository : IRepository<ShippingAddress>
	{		
		void insert(ShippingAddress shippingAddress);		
		void update(ShippingAddress shippingAddress);		
		void delete(ShippingAddress shippingAddress);
		
		ShippingAddress getById(int id);
		ShippingAddress getByIdCached(int id, bool cached);
		
		ShippingAddress getByUserId(int userId);
		ShippingAddress getByUserIdCached(int userId, bool cached);
	}
}