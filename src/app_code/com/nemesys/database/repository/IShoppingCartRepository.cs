using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IShoppingCartRepository : IRepository<ShoppingCart>
	{		
		void insert(ShoppingCart shoppingCart);
		
		void update(ShoppingCart shoppingCart);
		
		void delete(ShoppingCart shoppingCart);
		
		void deleteByIdUser(int idUser);
		
		void saveCompleteShoppingCartItem(ShoppingCartProduct newitem, IList<ShoppingCartProductField> newScpfs);
		
		ShoppingCart getById(int id);
		
		ShoppingCart getByIdExtended(int id, bool withProducts);
		
		ShoppingCart getByIdUser(int idUser, string acceptDate, bool withProducts);
		
		bool hasShoppingCart(int idUser, string acceptDate);
		
		bool existShoppingCart(int idCart, string acceptDate);
				
		IList<ShoppingCart> find(bool withProducts);

		void addItem(ShoppingCartProduct shoppingCartProduct);

		void updateItem(ShoppingCartProduct shoppingCartProduct);
		
		void deleteItem(int idCart, int idProd, int prodCounter);
		
		void deleteItemByType(int idCart, int type);

		ShoppingCartProduct getItem(int idCart, int idProd, int prodCounter);
		
		bool existItem(int idCart, int idProd, int prodCounter);
		
		IDictionary<string,ShoppingCartProduct> getItems(int idCart, int idProd);
		
		int getMaxItemCounter(int idCart, int idProd);
		
		ShoppingCartProductField getItemField(int idCart, int idProd, int prodCounter, int idField, string value);
		
		IDictionary<int,IList<ShoppingCartProductField>> findItemFields(int idCart, int idProd, int prodCounter, int idField);
		
		void addItemField(ShoppingCartProductField shoppingCartProductField);
		
		void updateItemField(ShoppingCartProductField shoppingCartProductField);
		
		void deleteItemField(int idCart, int idProd, int prodCounter);
	}
}