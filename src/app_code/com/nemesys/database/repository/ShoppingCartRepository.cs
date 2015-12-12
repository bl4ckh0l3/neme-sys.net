using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Web.Caching;

namespace com.nemesys.database.repository
{
	public class ShoppingCartRepository : IShoppingCartRepository
	{		
		public void insert(ShoppingCart shoppingCart)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				shoppingCart.lastUpdate=DateTime.Now;
				session.Save(shoppingCart);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(ShoppingCart shoppingCart)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				shoppingCart.lastUpdate=DateTime.Now;
				session.Update(shoppingCart);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(ShoppingCart shoppingCart)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ShoppingCartProductField where idCart=:idCart").SetInt32("idCart",shoppingCart.id).ExecuteUpdate();
				session.CreateQuery("delete FROM ShoppingCartProduct WHERE idCart=:idCart").SetInt32("idCart", shoppingCart.id).ExecuteUpdate();	
				session.Delete(shoppingCart);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public void deleteByIdUser(int idUser)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList cartIds = session.CreateSQLQuery("select id from SHOPPING_CART where id_user=:idUser")
				.AddScalar("id", NHibernateUtil.Int32)
				.SetInt32("idUser",idUser)		
				.List();				
				
				List<string> ids = new List<string>();
				if(cartIds != null && cartIds.Count>0){
					foreach(int cid in cartIds){
						ids.Add(cid.ToString());
					}
					session.CreateQuery(string.Format("delete from ShoppingCartProductField where idCart in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
					session.CreateQuery(string.Format("delete from ShoppingCartProduct where idCart in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
				}				
				
				session.CreateQuery("delete from ShoppingCart where idUser=:idUser").SetInt32("idUser",idUser).ExecuteUpdate();
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}		
		
		public ShoppingCart getById(int id)
		{
			ShoppingCart shoppingCart = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				shoppingCart = session.Get<ShoppingCart>(id);					

				NHibernateHelper.closeSession();
			}
			
			return shoppingCart;
		}

		public void saveCompleteShoppingCartItem(ShoppingCartProduct newitem, IList<ShoppingCartProductField> newScpfs)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					
					session.CreateQuery("delete from ShoppingCartProductField where idCart=:idCart and idProduct=:idProduct and productCounter=:productCounter")
					.SetInt32("idCart",newitem.idCart)
					.SetInt32("idProduct",newitem.idProduct)
					.SetInt32("productCounter",newitem.productCounter)
					.ExecuteUpdate();
					
					session.CreateQuery("delete FROM ShoppingCartProduct WHERE idCart=:idCart and idProduct=:idProduct and productCounter=:productCounter")
					.SetInt32("idCart",newitem.idCart)
					.SetInt32("idProduct",newitem.idProduct)
					.SetInt32("productCounter",newitem.productCounter)
					.ExecuteUpdate();						
					
					session.Save(newitem);

					if(newScpfs != null && newScpfs.Count>0)
					{							
						foreach(ShoppingCartProductField scpf in newScpfs){
							session.Save(scpf);
						}
					}
					
					tx.Commit();
					NHibernateHelper.closeSession();
				}catch(Exception exx){
					//Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}
		}		
		
		public ShoppingCart getByIdExtended(int id, bool withProducts)
		{
			ShoppingCart shoppingCart = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					shoppingCart = session.Get<ShoppingCart>(id);	
					
					if(shoppingCart != null && withProducts){
						IList<ShoppingCartProduct> items = session.CreateCriteria(typeof(ShoppingCartProduct))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idCart", shoppingCart.id))
						.AddOrder(Order.Asc("idProduct"))
						.AddOrder(Order.Asc("productCounter"))
						.List<ShoppingCartProduct>();
					
						if(items != null && items.Count>0)
						{
							IDictionary<string,ShoppingCartProduct> iproducts = new Dictionary<string,ShoppingCartProduct>();
							
							foreach(ShoppingCartProduct scp in items)
							{
								if(!iproducts.ContainsKey(scp.idProduct+"|"+scp.productCounter)){
									iproducts.Add(scp.idProduct+"|"+scp.productCounter, scp);
								}							
							}
							
							shoppingCart.products = iproducts;
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return shoppingCart;
		}

		public ShoppingCart getByIdUser(int idUser, string acceptDate, bool withProducts)
		{
			ShoppingCart result = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					string strSQL = "from ShoppingCart where idUser=:idUser";
	
					if (!String.IsNullOrEmpty(acceptDate)){
						strSQL += " and lastUpdate >= :lastUpdate";
					}
					strSQL += " order by lastUpdate desc";
					
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("idUser",idUser);	
	
					if (!String.IsNullOrEmpty(acceptDate)){
						q.SetDateTime("lastUpdate", Convert.ToDateTime(acceptDate));
					}
					q.SetMaxResults(1);
					
					result = q.UniqueResult<ShoppingCart>();
					
					if(result != null && withProducts){
						IList<ShoppingCartProduct> items = session.CreateCriteria(typeof(ShoppingCartProduct))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idCart", result.id))
						.AddOrder(Order.Asc("idProduct"))
						.AddOrder(Order.Asc("productCounter"))
						.List<ShoppingCartProduct>();
					
						if(items != null && items.Count>0)
						{
							IDictionary<string,ShoppingCartProduct> iproducts = new Dictionary<string,ShoppingCartProduct>();
							
							foreach(ShoppingCartProduct scp in items)
							{
								if(!iproducts.ContainsKey(scp.idProduct+"|"+scp.productCounter)){
									iproducts.Add(scp.idProduct+"|"+scp.productCounter, scp);
								}							
							}
							
							result.products = iproducts;
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				
				tx.Commit();			
				NHibernateHelper.closeSession();					
			}
			
			return result;			
		}
		
		public bool hasShoppingCart(int idUser, string acceptDate)
		{
			bool exist = false;
			ShoppingCart result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCart where idUser=:idUser";

				if (!String.IsNullOrEmpty(acceptDate)){
					strSQL += " and lastUpdate >= :lastUpdate";
				}
				strSQL += " order by lastUpdate desc";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idUser",idUser);	

				if (!String.IsNullOrEmpty(acceptDate)){
					q.SetDateTime("lastUpdate", Convert.ToDateTime(acceptDate));
				}
				q.SetMaxResults(1);
				
				result = q.UniqueResult<ShoppingCart>();			
				
				NHibernateHelper.closeSession();					
			}	
			
			if(result!=null)
			{
				exist=true;
			}			
			return exist;			
		}
		
		public bool existShoppingCart(int idCart, string acceptDate)
		{
			bool exist = false;
			ShoppingCart result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCart where id=:idCart";

				if (!String.IsNullOrEmpty(acceptDate)){
					strSQL += " and lastUpdate >= :lastUpdate";
				}
				strSQL += " order by lastUpdate desc";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);	

				if (!String.IsNullOrEmpty(acceptDate)){
					q.SetDateTime("lastUpdate", Convert.ToDateTime(acceptDate));
				}
				q.SetMaxResults(1);
				
				result = q.UniqueResult<ShoppingCart>();			
				
				NHibernateHelper.closeSession();					
			}	
			
			if(result!=null)
			{
				exist=true;
			}			
			return exist;			
		}
				
		public IList<ShoppingCart> find(bool withProducts)
		{
			IList<ShoppingCart> results = null;
			
			string strSQL = "from ShoppingCart order by lastUpdate desc";				
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					results = q.List<ShoppingCart>();

					if(results != null && results.Count>0){
						foreach(ShoppingCart sc in results){			
							if(withProducts){	
								IList<ShoppingCartProduct> items = session.CreateCriteria(typeof(ShoppingCartProduct))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idCart", sc.id))
								.AddOrder(Order.Asc("idProduct"))
								.AddOrder(Order.Asc("productCounter"))
								.List<ShoppingCartProduct>();
							
								if(items != null && items.Count>0)
								{
									IDictionary<string,ShoppingCartProduct> iproducts = new Dictionary<string,ShoppingCartProduct>();
									
									foreach(ShoppingCartProduct scp in items)
									{
										if(!iproducts.ContainsKey(scp.idProduct+"|"+scp.productCounter)){
											iproducts.Add(scp.idProduct+"|"+scp.productCounter, scp);
										}							
									}
									
									sc.products = iproducts;
								}
								
							}						
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
						
			return results;		
		}
		
		public void addItem(ShoppingCartProduct shoppingCartProduct)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(shoppingCartProduct);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateItem(ShoppingCartProduct shoppingCartProduct)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(shoppingCartProduct);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteItem(int idCart, int idProd, int prodCounter)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ShoppingCartProductField where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter")
				.SetInt32("idCart",idCart)
				.SetInt32("idProduct",idProd)
				.SetInt32("prodCounter",prodCounter)
				.ExecuteUpdate();
				
				session.CreateQuery("delete from ShoppingCartProduct where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter")
				.SetInt32("idCart",idCart)
				.SetInt32("idProduct",idProd)
				.SetInt32("prodCounter",prodCounter)
				.ExecuteUpdate();	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}	
		
		public void deleteItemByType(int idCart, int type)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{

				string strSQL = "DELETE FROM SHOPPING_CART_PRODUCT_FIELD WHERE id_cart=:idCart and id_prod IN(SELECT id_prod FROM SHOPPING_CART_PRODUCT WHERE id_cart=:idCart2 and prod_type=:productType)";
				session.CreateSQLQuery(strSQL)
				.SetInt32("idCart",idCart)
				.SetInt32("idCart2",idCart)
				.SetInt32("productType",type)
				.ExecuteUpdate();
				
				session.CreateQuery("delete from ShoppingCartProduct where idCart=:idCart and productType=:productType")
				.SetInt32("idCart",idCart)
				.SetInt32("productType",type)
				.ExecuteUpdate();								
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public ShoppingCartProduct getItem(int idCart, int idProd, int prodCounter)
		{
			ShoppingCartProduct result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCartProduct where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);
				q.SetInt32("idProduct",idProd);
				q.SetInt32("prodCounter",prodCounter);				
				
				result = q.UniqueResult<ShoppingCartProduct>();				
				
				NHibernateHelper.closeSession();					
			}	
			return result;			
		}
		
		public bool existItem(int idCart, int idProd, int prodCounter)
		{
			bool exist = false;
			ShoppingCartProduct result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCartProduct where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);
				q.SetInt32("idProduct",idProd);
				q.SetInt32("prodCounter",prodCounter);				
				
				result = q.UniqueResult<ShoppingCartProduct>();			
				
				NHibernateHelper.closeSession();					
			}	
			
			if(result!=null)
			{
				exist=true;
			}			
			return exist;			
		}		
		
		public IDictionary<string,ShoppingCartProduct> getItems(int idCart, int idProd)
		{
			IList<ShoppingCartProduct> items = null;
			IDictionary<string,ShoppingCartProduct> results = null;	
			
			string strSQL = "from ShoppingCartProduct where idCart=:idCart and idProduct=:idProduct order by idProduct, productCounter asc";
				
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);
				q.SetInt32("idProduct",idProd);			
				items = q.List<ShoppingCartProduct>();				
				NHibernateHelper.closeSession();					
			}
	
			if(items!=null)
			{
				results = new Dictionary<string,ShoppingCartProduct>();
				
				foreach(ShoppingCartProduct x in items)
				{
					if(!results.ContainsKey(x.idProduct+"|"+x.productCounter)){
						results.Add(x.idProduct+"|"+x.productCounter, x);
					}
				}
			}	
			return results;				
		}	
				
		public int getMaxItemCounter(int idCart, int idProd)
		{
			int result = -1;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				string strSQL = "select count(*) as counter from SHOPPING_CART_PRODUCT where id_cart=:idCart and id_prod=:idProduct";
				IQuery qCount = session.CreateSQLQuery(strSQL).AddScalar("counter", NHibernateUtil.Int32);
				qCount.SetInt32("idCart",idCart);
				qCount.SetInt32("idProduct",idProd);				
				int count = qCount.UniqueResult<int>();	
				
				if(count>0){
					string strSQL2 = "select max(prod_counter) as max from SHOPPING_CART_PRODUCT where id_cart=:idCart and id_prod=:idProduct";
					IQuery qCount2 = session.CreateSQLQuery(strSQL2).AddScalar("max", NHibernateUtil.Int32);
					qCount2.SetInt32("idCart",idCart);
					qCount2.SetInt32("idProduct",idProd);				
					result = qCount2.UniqueResult<int>();				
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();					
			}	
			return result;			
		}	
		
		public ShoppingCartProductField getItemField(int idCart, int idProd, int prodCounter, int idField, string value)
		{
			ShoppingCartProductField result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCartProductField where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter and idField=:idField and value=:value";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);
				q.SetInt32("idProduct",idProd);
				q.SetInt32("prodCounter",prodCounter);	
				q.SetInt32("idField",idField);			
				q.SetString("value",value);			
				
				result = q.UniqueResult<ShoppingCartProductField>();				
				
				NHibernateHelper.closeSession();					
			}	
			return result;				
		}
		
		public IDictionary<int,IList<ShoppingCartProductField>> findItemFields(int idCart, int idProd, int prodCounter, int idField)
		{
			IDictionary<int,IList<ShoppingCartProductField>> results = null;
			IList<ShoppingCartProductField> items = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string strSQL = "from ShoppingCartProductField where idCart=:idCart and idProduct=:idProduct";

				if (prodCounter != null && prodCounter>-1){
					strSQL += " and productCounter=:prodCounter";
				}

				if (idField != null && idField>-1){
					strSQL += " and idField=:idField";
				}
				
				strSQL+=" order by productCounter asc";
				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idCart",idCart);
				q.SetInt32("idProduct",idProd);			
				if (prodCounter != null && prodCounter>-1){
					q.SetInt32("prodCounter",prodCounter);	
				}		
				if (idField != null && idField>-1){
					q.SetInt32("idField",idField);	
				}
				
				items = q.List<ShoppingCartProductField>();				
				
				NHibernateHelper.closeSession();					
			}			
			
			if(items != null && items.Count>0)
			{
				results = new Dictionary<int,IList<ShoppingCartProductField>>();
				
				foreach(ShoppingCartProductField x in items)
				{
					if(!results.ContainsKey(x.productCounter)){
						IList<ShoppingCartProductField> fields = new List<ShoppingCartProductField>();
						fields.Add(x);
						results.Add(x.productCounter, fields);
					}else{
						IList<ShoppingCartProductField> fields;
						if (results.TryGetValue(x.productCounter, out fields))
						{
							fields.Add(x);
							results[x.productCounter] = fields;
						}						
					}
				}				
			}
			
			return results;
		}
		
		public void addItemField(ShoppingCartProductField shoppingCartProductField)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				session.Save(shoppingCartProductField);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateItemField(ShoppingCartProductField shoppingCartProductField)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(shoppingCartProductField);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteItemField(int idCart, int idProd, int prodCounter)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				session.CreateQuery("delete from ShoppingCartProductField where idCart=:idCart and idProduct=:idProduct and productCounter=:prodCounter")
				.SetInt32("idCart",idCart)
				.SetInt32("idProduct",idProd)
				.SetInt32("prodCounter",prodCounter)
				.ExecuteUpdate();	
				NHibernateHelper.closeSession();
			}				
		}
	}
}