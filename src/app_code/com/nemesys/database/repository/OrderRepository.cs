using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using com.nemesys.exception;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using System.Web.Caching;

namespace com.nemesys.database.repository
{
	public class OrderRepository : IOrderRepository
	{		
		public void insert(FOrder order)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{						
				order.lastUpdate=DateTime.Now;
				session.Save(order);	
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(FOrder order)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				order.lastUpdate=DateTime.Now;
				session.Update(order);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(FOrder order)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from OrderProduct where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderProductField where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderProductAttachmentDownload where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderFee where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderBillsAddress where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderShippingAddress where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderBusinessRule where orderId=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.CreateQuery("delete from OrderVoucher where orderId=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
				session.Delete(order);
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}				
		}
		
		public FOrder getById(int id)
		{
			FOrder order = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				order = session.Get<FOrder>(id);					

				NHibernateHelper.closeSession();
			}
			
			return order;
		}		
		
		public FOrder getByIdExtended(int id, bool withItems)
		{
			FOrder order = null;
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					order = session.Get<FOrder>(id);	
					
					if(order != null && withItems){
						IList<OrderProduct> items = session.CreateCriteria(typeof(OrderProduct))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idOrder", order.id))
						.AddOrder(Order.Asc("idProduct"))
						.AddOrder(Order.Asc("productCounter"))
						.List<OrderProduct>();
					
						if(items != null && items.Count>0)
						{
							IDictionary<string,OrderProduct> iproducts = new Dictionary<string,OrderProduct>();
							
							foreach(OrderProduct scp in items)
							{
								if(!iproducts.ContainsKey(scp.idProduct+"|"+scp.productCounter)){
									iproducts.Add(scp.idProduct+"|"+scp.productCounter, scp);
								}							
							}
							
							order.products = iproducts;
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
			
			return order;
		}

		public IList<FOrder> getByIdUser(int idUser, bool withItems)
		{
			IList<FOrder> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					string strSQL = "from FOrder where userId=:idUser";
					strSQL += " order by lastUpdate desc";
					
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("idUser",idUser);
					results = q.List<FOrder>();

					if(results != null && results.Count>0){
						foreach(FOrder sc in results){			
							if(withItems){	
								IList<OrderProduct> items = session.CreateCriteria(typeof(OrderProduct))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idOrder", sc.id))
								.AddOrder(Order.Asc("idProduct"))
								.AddOrder(Order.Asc("productCounter"))
								.List<OrderProduct>();
							
								if(items != null && items.Count>0)
								{
									IDictionary<string,OrderProduct> iproducts = new Dictionary<string,OrderProduct>();
									
									foreach(OrderProduct scp in items)
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
		
		public int countByIdUser(int idUser)
		{
			int count = 0;
			
			string strSQL = "SELECT count(*) as counter FROM ORDERS WHERE id_user=:idUser";

			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery qCount = session.CreateSQLQuery(strSQL).AddScalar("counter", NHibernateUtil.Int32);
				qCount.SetInt32("idUser",idUser);			
				count = qCount.UniqueResult<int>();	
				
				NHibernateHelper.closeSession();
			}
			
			return count;
		}
				
		public IList<FOrder> find(string guid, int idUser, string dateFrom, string dateTo, string status, int paymentType, string paymentDone, int orderBy, bool withItems)
		{
			IList<FOrder> results = null;
			
			string strSQL = "from FOrder where 1=1";
			
			if (!String.IsNullOrEmpty(guid)){			
				strSQL += " and guid=:guid";
			}
			
			if (idUser > 0){			
				strSQL += " and userId=:userId";
			}

			if (!String.IsNullOrEmpty(dateFrom)){
				strSQL += " and insertDate >= :dateFrom";
			}

			if (!String.IsNullOrEmpty(dateTo)){
				strSQL += " and insertDate <= :dateTo";
			}
			
			if (!String.IsNullOrEmpty(status)){			
				List<string> ids = new List<string>();
				string[] tstatus = status.Split(',');
				foreach(string r in tstatus){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and status in({0})",string.Join(",",ids.ToArray()));}
			}
			
			if (paymentType > 0){			
				strSQL += " and paymentId=:paymentId";
			}
			
			if (!String.IsNullOrEmpty(paymentDone)){			
				strSQL += " and paymentDone=:paymentDone";
			}
			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by userId asc";
				break;
			    case 2:
				strSQL +=" order by userId desc";
				break;
			    case 3:
				strSQL +=" order by insertDate asc";
				break;
			    case 4:
				strSQL +=" order by insertDate desc";
				break;
			    case 5:
				strSQL +=" order by status asc";
				break;
			    case 6:
				strSQL +=" order by status desc";
				break;
			    case 7:
				strSQL +=" order by amount asc";
				break;
			    case 8:
				strSQL +=" order by amount desc";
				break;
			    case 9:
				strSQL +=" order by paymentId asc";
				break;
			    case 10:
				strSQL +=" order by paymentId desc";
				break;
			    case 11:
				strSQL +=" order by paymentDone asc";
				break;
			    case 12:
				strSQL +=" order by paymentDonec desc";
				break;
			    default:
				strSQL +=" order by id desc";
				break;
			}
			
			//System.Web.HttpContext.Current.Response.Write(strSQL);
			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (!String.IsNullOrEmpty(guid)){
						q.SetString("guid", guid);
					}
					if (idUser > 0){
						q.SetInt32("userId", Convert.ToInt32(idUser));
					}
					if (!String.IsNullOrEmpty(dateFrom)){
						q.SetDateTime("dateFrom", Convert.ToDateTime(dateFrom));
					}
					if (!String.IsNullOrEmpty(dateTo)){
						q.SetDateTime("dateTo", Convert.ToDateTime(dateTo));
					}
					if (paymentType > 0){
						q.SetInt32("paymentId", Convert.ToInt32(paymentType));
					}
					if (!String.IsNullOrEmpty(paymentDone)){
						q.SetBoolean("paymentDone", Convert.ToBoolean(Convert.ToInt32(paymentDone)));
					}					
					
					results = q.List<FOrder>();

					if(results != null && results.Count>0){
						foreach(FOrder sc in results){			
							if(withItems){	
								IList<OrderProduct> items = session.CreateCriteria(typeof(OrderProduct))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idOrder", sc.id))
								.AddOrder(Order.Asc("idProduct"))
								.AddOrder(Order.Asc("productCounter"))
								.List<OrderProduct>();
							
								if(items != null && items.Count>0)
								{
									IDictionary<string,OrderProduct> iproducts = new Dictionary<string,OrderProduct>();
									
									foreach(OrderProduct scp in items)
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
	
		public IList<OrderFee> findFeesByOrderId(int idOrder)
		{
			IList<OrderFee> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				try
				{
					string strSQL = "from OrderFee where idOrder=:idOrder";
					strSQL += " order by feeDesc asc";
					
					IQuery q = session.CreateQuery(strSQL);
					q.SetInt32("idOrder",idOrder);
					results = q.List<OrderFee>();
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

		public IList<OrderProductField> findItemFields(int idOrder, int idProd, int prodCounter)
		{
			IList<OrderProductField> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{	
					IQuery q = session.CreateQuery("from OrderProductField where idOrder=:idOrder and idProduct=:idProduct and productCounter=:prodCounter order by description asc");
					q.SetInt32("idOrder",idOrder);
					q.SetInt32("idProduct",idProd);			
					q.SetInt32("prodCounter",prodCounter);	
					results = q.List<OrderProductField>();					
				
				NHibernateHelper.closeSession();					
			}
			
			return results;
		}	
		
		public IList<OrderProductAttachmentDownload> getAttachmentDownload(int idOrder, int idProd)
		{
			IList<OrderProductAttachmentDownload> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	
				try
				{
					results = session.CreateQuery("from OrderProductAttachmentDownload where idOrder=:orderId and idParentProduct=:productId")
					.SetInt32("orderId",idOrder)
					.SetInt32("productId",idProd)			
					.List<OrderProductAttachmentDownload>();				
				}
				catch(Exception ex)
				{
					System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}			
				
				tx.Commit();	
				NHibernateHelper.closeSession();					
			}
			
			return results;			
		}
		
		public void updateAttachmentDownload(OrderProductAttachmentDownload opad)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				session.Update(opad);			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
		}
		
		public void saveCompleteOrder(FOrder order, IList<OrderProduct> ops, IList<OrderProductField> opfs, IList<OrderProductAttachmentDownload> opads, IList<OrderFee> ofs, BillsAddress billsAddress, OrderBillsAddress orderBillsAddress, ShippingAddress shippingAddress, OrderShippingAddress orderShippingAddress, IList<OrderBusinessRule> obrs, IList<OrderVoucher> ovs, int voucherCodeId)
		{
			IDictionary<int,int> productQtyCheck = new Dictionary<int,int>();
			IDictionary<string,int> productFieldsQtyCheck = new Dictionary<string,int>();
			
			IDictionary<int,int> productQtyToUpdate = new Dictionary<int,int>();
			IDictionary<string,int> productFieldsQtyToUpdate = new Dictionary<string,int>();
			IDictionary<string,int> productFieldsRelQtyToUpdate = new Dictionary<string,int>();
			
			foreach(OrderProduct op in ops){
				int pqty = 0;
				bool foundpqty = productQtyCheck.TryGetValue(op.idProduct, out pqty);
				if(foundpqty){
					pqty+=op.productQuantity;
					productQtyCheck[op.idProduct]=pqty;
				}else{
					productQtyCheck.Add(op.idProduct, op.productQuantity);
				}
			}
			
			foreach(OrderProductField opf in opfs){
				if(opf.fieldType==3 || opf.fieldType==4 || opf.fieldType==5 || opf.fieldType==6){
					int pfqty = 0;
					//HttpContext.Current.Response.Write("OrderProductField: " + opf.ToString()+"<br>");
					string key = new StringBuilder().Append(opf.idProduct).Append("|").Append(opf.idField).Append("|").Append(opf.value).ToString();
					//HttpContext.Current.Response.Write("key: " + key+"<br>");
					bool foundpfqty = productFieldsQtyCheck.TryGetValue(key, out pfqty);
					if(foundpfqty){
						pfqty+=opf.productQuantity;
						productFieldsQtyCheck[key]=pfqty;
					}else{
						productFieldsQtyCheck.Add(key, opf.productQuantity);
					}
				}
			}
			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(order.id != -1){
						session.CreateQuery("delete from OrderFee where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
						session.CreateQuery("delete from OrderBillsAddress where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
						session.CreateQuery("delete from OrderShippingAddress where idOrder=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
						session.CreateQuery("delete from OrderBusinessRule where orderId=:idOrder and productId<=0").SetInt32("idOrder",order.id).ExecuteUpdate();
						session.CreateQuery("delete from BillsAddress where idUser=:idUser").SetInt32("idUser",order.userId).ExecuteUpdate();
						session.CreateQuery("delete from ShippingAddress where idUser=:idUser").SetInt32("idUser",order.userId).ExecuteUpdate();
						
						if(ovs != null && ovs.Count>0){
							session.CreateQuery("delete from OrderVoucher where orderId=:idOrder").SetInt32("idOrder",order.id).ExecuteUpdate();
						}
						
						order.lastUpdate=DateTime.Now;
						session.Update(order);	
						
						foreach(OrderProductAttachmentDownload opad in opads){
							session.Update(opad);
						}
						
						foreach(OrderFee of in ofs){
							of.idOrder=order.id;
							session.Save(of);
						}
						
						billsAddress.idUser=order.userId;
						session.Save(billsAddress);
						
						shippingAddress.idUser=order.userId;
						session.Save(shippingAddress);
						
						orderBillsAddress.idOrder=order.id;
						orderShippingAddress.idOrder=order.id;
						
						session.Save(orderBillsAddress);
						session.Save(orderShippingAddress);	
						
						//*** save modified order business rule
						foreach(OrderBusinessRule obr in obrs){
							if(obr.productId<=0){
								obr.orderId=order.id;
								session.Save(obr);
							}
						}

						if(ovs != null && ovs.Count>0){
							foreach(OrderVoucher ov in ovs){
								ov.orderId=order.id;
								ov.insertDate=DateTime.Now;
								session.Save(ov);
							}	
						}
						
						if(voucherCodeId>0){
							VoucherCode savedVC = session.Get<VoucherCode>(voucherCodeId);
							session.CreateQuery("update VoucherCode set usageCounter=:usageCounter where id=:id")
							.SetInt32("usageCounter",savedVC.usageCounter+1)
							.SetInt32("id",savedVC.id)
							.ExecuteUpdate();
						}						
					}else{
						foreach(KeyValuePair<int, int> pqc in productQtyCheck)
						{
							IQuery qpCount = session.CreateSQLQuery("select count(*) as counter from PRODUCT where id=:idProd").AddScalar("counter", NHibernateUtil.Int32);
							qpCount.SetInt32("idProd",pqc.Key);
							int count = qpCount.UniqueResult<int>();
							IQuery qpCount2 = session.CreateSQLQuery("select quantity from PRODUCT where id=:idProd").AddScalar("quantity", NHibernateUtil.Int32);
							qpCount2.SetInt32("idProd",pqc.Key);
							int result = qpCount2.UniqueResult<int>();							
							
							if(count>0)
							{
								if(result > -1 && result-pqc.Value<0)
								{
									string prodName= "";
									foreach(OrderProduct op in ops){
										if(op.idProduct==pqc.Key){
											prodName=op.productName;
											break;
										}
									}
									throw new QuantityException(prodName+" ("+(result-pqc.Value)+")");// Product quantity exceed
								}else{
									productQtyToUpdate.Add(pqc.Key, result-pqc.Value);							
								}
							}
						}
						
						foreach(KeyValuePair<string, int> pfqc in productFieldsQtyCheck)
						{
							string[] keyEl = pfqc.Key.Split('|');
							int idp = Convert.ToInt32(keyEl[0]);
							int idf = Convert.ToInt32(keyEl[1]);
							string vf = keyEl[2];
							//HttpContext.Current.Response.Write("idp: " + idp);
							//HttpContext.Current.Response.Write(" - idf: " + idf);
							//HttpContext.Current.Response.Write(" - vf: " + vf+"<br>");

							IQuery qpfCount = session.CreateSQLQuery("select count(*) as counter from PRODUCT_FIELDS_VALUES LEFT JOIN PRODUCT_FIELDS on PRODUCT_FIELDS_VALUES.id_parent_field=PRODUCT_FIELDS.id LEFT JOIN PRODUCT on PRODUCT_FIELDS.id_parent_product=PRODUCT.id where PRODUCT_FIELDS.id_parent_product=:idProduct and PRODUCT_FIELDS_VALUES.id_parent_field=:idField and PRODUCT_FIELDS_VALUES.value=:value and PRODUCT.quantity>-1").AddScalar("counter", NHibernateUtil.Int32);
							qpfCount.SetInt32("idProduct",idp);
							qpfCount.SetInt32("idField",idf);
							qpfCount.SetString("value",vf);
							int count2 = qpfCount.UniqueResult<int>();
							IQuery qpfCount2 = session.CreateSQLQuery("select quantity from PRODUCT_FIELDS_VALUES where id_parent_field=:idField and value=:value").AddScalar("quantity", NHibernateUtil.Int32);
							qpfCount2.SetInt32("idField",idf);
							qpfCount2.SetString("value",vf);
							int result = qpfCount2.UniqueResult<int>();	
									
							//HttpContext.Current.Response.Write("pf count:"+count2+" - result: " + result+"<br>");						
							
							if(count2>0)
							{
								if(result-pfqc.Value<0)
								{
									string prodName= "";
									foreach(OrderProduct op in ops){
										if(op.idProduct==idp){
											prodName=op.productName;
											break;	
										}
									}
									string prodfName= "";
									foreach(OrderProductField opf in opfs){
										if(opf.idField==idf){
											prodfName=opf.description;
											break;
										}
									}	
									throw new QuantityException(prodName+" - "+prodfName+": "+vf+" ("+(result-pfqc.Value)+")");//Product field quantity exceed
								}else{
									productFieldsQtyToUpdate.Add(pfqc.Key, result-pfqc.Value);							
								}
							}
							
							// check on prod rel fields
							foreach(KeyValuePair<string, int> pfrqc in productFieldsQtyCheck)
							{
								string[] keyREl = pfrqc.Key.Split('|');
								int idfr = Convert.ToInt32(keyREl[1]);
								string vfr = keyREl[2];
								//HttpContext.Current.Response.Write("idfr: " + idfr);
								//HttpContext.Current.Response.Write(" - vfr: " + vfr+"<br>");
							
								if(!(idf+vf).Equals(idfr+vfr))
								{
									IQuery qpfrCount = session.CreateSQLQuery("select count(*) as counter from PRODUCT_FIELDS_REL_VALUES LEFT JOIN PRODUCT on PRODUCT_FIELDS_REL_VALUES.id_product=PRODUCT.id where id_product=:idProduct and id_field=:idField and field_val=:value and id_field_rel=:idRelField and field_rel_val=:relValue and PRODUCT.quantity>-1").AddScalar("counter", NHibernateUtil.Int32);
									qpfrCount.SetInt32("idProduct",idp);
									qpfrCount.SetInt32("idField",idf);
									qpfrCount.SetString("value",vf);
									qpfrCount.SetInt32("idRelField",idfr);
									qpfrCount.SetString("relValue",vfr);
									int count3 = qpfrCount.UniqueResult<int>();
									IQuery qpfrCoun2 = session.CreateSQLQuery("select quantity from PRODUCT_FIELDS_REL_VALUES where id_product=:idProduct and id_field=:idField and field_val=:value and id_field_rel=:idRelField and field_rel_val=:relValue").AddScalar("quantity", NHibernateUtil.Int32);
									qpfrCoun2.SetInt32("idProduct",idp);
									qpfrCoun2.SetInt32("idField",idf);
									qpfrCoun2.SetString("value",vf);
									qpfrCoun2.SetInt32("idRelField",idfr);
									qpfrCoun2.SetString("relValue",vfr);
									int resultRel = qpfrCoun2.UniqueResult<int>();	
									
									//HttpContext.Current.Response.Write("pfr count:"+count3+" - resultRel: " + resultRel+"<br>");
							
									if(count3>0)
									{
										if(resultRel-pfrqc.Value<0)
										{	
											string prodName= "";
											foreach(OrderProduct op in ops){
												if(op.idProduct==idp){
													prodName=op.productName;
													break;	
												}
											}
											string prodfName= "";
											foreach(OrderProductField opf in opfs){
												if(opf.idField==idf){
													prodfName=opf.description;
													break;
												}
											}
											string prodfrName= "";
											foreach(OrderProductField opf in opfs){
												if(opf.idField==idfr){
													prodfrName=opf.description;
													break;
												}
											}
											throw new QuantityException(prodName+" - "+prodfName+": "+vf+" - "+prodfrName+": "+vfr+" ("+(resultRel-pfrqc.Value)+")");// Product field rel quantity exceed
										}else{
											productFieldsRelQtyToUpdate.Add(pfqc.Key+"|"+idfr+"|"+vfr, resultRel-pfrqc.Value);							
										}				
									}
								}
							}
							
						}
						
						session.CreateQuery("delete from BillsAddress where idUser=:idUser").SetInt32("idUser",order.userId).ExecuteUpdate();
						session.CreateQuery("delete from ShippingAddress where idUser=:idUser").SetInt32("idUser",order.userId).ExecuteUpdate();				
						
						order.insertDate=DateTime.Now;
						order.lastUpdate=DateTime.Now;
						session.Save(order);
						
						foreach(OrderProduct op in ops){
							op.idOrder=order.id;
							session.Save(op);
						}
						
						foreach(OrderProductField opf in opfs){
							opf.idOrder=order.id;
							session.Save(opf);
						}
						
						foreach(OrderProductAttachmentDownload opad in opads){
							opad.idOrder=order.id;
							opad.insertDate=DateTime.Now;
							session.Save(opad);
						}
						
						foreach(OrderFee of in ofs){
							of.idOrder=order.id;
							session.Save(of);
						}
						
						billsAddress.idUser=order.userId;
						session.Save(billsAddress);
						
						shippingAddress.idUser=order.userId;
						session.Save(shippingAddress);
						
						orderBillsAddress.idOrder=order.id;
						orderShippingAddress.idOrder=order.id;
						
						session.Save(orderBillsAddress);
						session.Save(orderShippingAddress);
					
						foreach(OrderBusinessRule obr in obrs){
							obr.orderId=order.id;
							session.Save(obr);
						}	
						
						foreach(OrderVoucher ov in ovs){
							ov.orderId=order.id;
							ov.insertDate=DateTime.Now;
							session.Save(ov);
						}	
						
						if(voucherCodeId>0){
							VoucherCode savedVC = session.Get<VoucherCode>(voucherCodeId);
							//savedVC.usageCounter+=1;
							//session.Update(savedVC);
							session.CreateQuery("update VoucherCode set usageCounter=:usageCounter where id=:id")
							.SetInt32("usageCounter",savedVC.usageCounter+1)
							.SetInt32("id",savedVC.id)
							.ExecuteUpdate();
						}
						
						
						foreach(KeyValuePair<int, int> pqc in productQtyCheck)
						{			
							int pqty = 0;
							bool foundp = productQtyToUpdate.TryGetValue(pqc.Key, out pqty);
							if(foundp){
								string sqlquery = "update Product set quantity=:quantity";
								if(pqty==0){
									sqlquery+=" ,status=0 ";
								}
								sqlquery+=" where id=:id and quantity >-1";
								
								session.CreateQuery(sqlquery)
								.SetInt32("quantity",pqty)
								.SetInt32("id",pqc.Key)
								.ExecuteUpdate();
							}
						}
						
						foreach(KeyValuePair<string, int> pfqc in productFieldsQtyCheck)
						{	
							string[] keyEl = pfqc.Key.Split('|');
							int idp = Convert.ToInt32(keyEl[0]);
							int idf = Convert.ToInt32(keyEl[1]);
							string vf = keyEl[2];
							
							int pfqty = 0;
							bool foundpf = productFieldsQtyToUpdate.TryGetValue(pfqc.Key, out pfqty);
							if(foundpf){
								session.CreateQuery("update ProductFieldsValue set quantity=:quantity where idParentField=:idField and value=:value")
								.SetInt32("quantity",pfqty)
								.SetInt32("idField",idf)
								.SetString("value",vf)
								.ExecuteUpdate();
							}
							
							foreach(KeyValuePair<string, int> pfrqc in productFieldsQtyCheck)
							{
								string[] keyREl = pfrqc.Key.Split('|');
								int idfr = Convert.ToInt32(keyREl[1]);
								string vfr = keyREl[2];
							
								if(!(idf+vf).Equals(idfr+vfr))
								{
									int pfrqty = 0;
									bool foundpfr = productFieldsRelQtyToUpdate.TryGetValue(pfqc.Key+"|"+idfr+"|"+vfr, out pfrqty);
									if(foundpfr){
										session.CreateQuery("update ProductFieldsRelValue set quantity=:quantity where idProduct=:idProduct and idParentField=:idField and fieldValue=:value and idParentRelField=:idRelField and fieldRelValue=:relValue")
										.SetInt32("quantity",pfrqty)
										.SetInt32("idProduct",idp)
										.SetInt32("idField",idf)
										.SetString("value",vf)
										.SetInt32("idRelField",idfr)
										.SetString("relValue",vfr)
										.ExecuteUpdate();	
									}
								}
							}							
						}
					}	
					tx.Commit();
					NHibernateHelper.closeSession();
					
					//rimuovo cache		
					IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
					while (CacheEnum.MoveNext())
					{		  
						string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
						if(cacheKey.Contains("fproduct-"))
						{ 
							HttpContext.Current.Cache.Remove(cacheKey);
						}
						else if(cacheKey.Contains("list-field-fproduct-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						} 
						else if(cacheKey.Contains("list-fproduct"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						} 
						else if(cacheKey.Contains("field-fproduct-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						}   
						else if(cacheKey.Contains("field-value-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						}  
						else if(cacheKey.Contains("list-field-values-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						} 
						else if(cacheKey.Contains("list-field-name-values-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						} 
						else if(cacheKey.Contains("order-shipping-address-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						}  
						else if(cacheKey.Contains("order-bills-address-"))
						{
							HttpContext.Current.Cache.Remove(cacheKey);
						}   
					}	
				}catch(Exception exx){
					//HttpContext.Current.Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}			
		}	
		

		//************ MANAGE ORDER SHIPPING ADDRESS  ************
		public void insertOrderShippingAddress(OrderShippingAddress orderShippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(orderShippingAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateOrderShippingAddress(OrderShippingAddress orderShippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(orderShippingAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("order-shipping-address-"+orderShippingAddress.idOrder))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void deleteOrderShippingAddress(OrderShippingAddress orderShippingAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(orderShippingAddress);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("order-shipping-address-"+orderShippingAddress.idOrder))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public OrderShippingAddress getOrderShippingAddress(int orderId)
		{
			return getOrderShippingAddressCached(orderId, false);
		}
		
		public OrderShippingAddress getOrderShippingAddressCached(int orderId, bool cached)
		{
			OrderShippingAddress orderShippingAddress = null;	
			
			if(cached)
			{
				orderShippingAddress = (OrderShippingAddress)HttpContext.Current.Cache.Get("order-shipping-address-"+orderId);
				if(orderShippingAddress != null){
					return orderShippingAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				orderShippingAddress = session.CreateQuery("from OrderShippingAddress where idOrder=:idOrder").SetInt32("idOrder",orderId).UniqueResult<OrderShippingAddress>();	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(orderShippingAddress != null){
					HttpContext.Current.Cache.Insert("order-shipping-address-"+orderShippingAddress.idOrder, orderShippingAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return orderShippingAddress;
		}	
		

		//************ MANAGE ORDER BILLS ADDRESS  ************
		public void insertOrderBillsAddress(OrderBillsAddress orderBillsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(orderBillsAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateOrderBillsAddress(OrderBillsAddress orderBillsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Update(orderBillsAddress);				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("order-bills-address-"+orderBillsAddress.idOrder))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}	
		}
		
		public void deleteOrderBillsAddress(OrderBillsAddress orderBillsAddress)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{		
				session.Delete(orderBillsAddress);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("order-bills-address-"+orderBillsAddress.idOrder))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}					
		}
		
		public OrderBillsAddress getOrderBillsAddress(int orderId)
		{
			return getOrderBillsAddressCached(orderId, false);
		}
		
		public OrderBillsAddress getOrderBillsAddressCached(int orderId, bool cached)
		{
			OrderBillsAddress orderBillsAddress = null;	
			
			if(cached)
			{
				orderBillsAddress = (OrderBillsAddress)HttpContext.Current.Cache.Get("order-bills-address-"+orderId);
				if(orderBillsAddress != null){
					return orderBillsAddress;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				orderBillsAddress = session.CreateQuery("from OrderBillsAddress where idOrder=:idOrder").SetInt32("idOrder",orderId).UniqueResult<OrderBillsAddress>();	
				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(orderBillsAddress != null){
					HttpContext.Current.Cache.Insert("order-bills-address-"+orderBillsAddress.idOrder, orderBillsAddress, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
				}
			}
			
			return orderBillsAddress;
		}
		
		//************ MANAGE ORDER BUSINESS STRATEGY  ************
		public IList<OrderBusinessRule> findOrderBusinessRule(int idOrder, bool withItems)
		{
			IList<OrderBusinessRule> results = null;
			
			string strSQL = "from OrderBusinessRule where orderId=:idOrder";
			if(!withItems){
				strSQL+=" and productId<=0";
			}else{
				strSQL+=" and productId>0";
			}
			strSQL+=" order by label asc";
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{	
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idOrder",idOrder);
				results = q.List<OrderBusinessRule>();				
				
				NHibernateHelper.closeSession();					
			}
			
			return results;			
		}
		
		public void insertOrderBusinessRule(OrderBusinessRule orderBusinessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				session.Save(orderBusinessRule);	
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateOrderBusinessRule(OrderBusinessRule orderBusinessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				session.Update(orderBusinessRule);	
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteOrderBusinessRule(OrderBusinessRule orderBusinessRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{		
				session.Delete(orderBusinessRule);	
				NHibernateHelper.closeSession();
			}					
		}		
		
		public void deleteOrderBusinessRuleByOrder(int idOrder)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())	
			{
				session.CreateQuery("delete from OrderBusinessRule where orderId=:idOrder").SetInt32("idOrder",idOrder).ExecuteUpdate();
				NHibernateHelper.closeSession();
			}					
		}	
		
		public void deleteOrderBusinessRuleByOrderAndItem(int idOrder, int idItem)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())	
			{
				session.CreateQuery("delete from OrderBusinessRule where orderId=:idOrder and productId=:idProd").SetInt32("idOrder",idOrder).SetInt32("idProd",idItem).ExecuteUpdate();
				NHibernateHelper.closeSession();
			}					
		}	
		
		public void deleteOrderBusinessRuleByOrderAndRule(int idOrder, int idRule)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())	
			{
				session.CreateQuery("delete from OrderBusinessRule where orderId=:idOrder and ruleType=:type").SetInt32("idOrder",idOrder).SetInt32("type",idRule).ExecuteUpdate();
				NHibernateHelper.closeSession();
			}					
		}

		//************ MANAGE ORDER VOUCHER  ************
		public OrderVoucher getOrderVoucher(int idOrder)
		{
			OrderVoucher orderVoucher = null;	
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				orderVoucher = session.CreateQuery("from OrderVoucher where idOrder=:idOrder").SetInt32("idOrder",idOrder).UniqueResult<OrderVoucher>();	
				NHibernateHelper.closeSession();
			}
			
			return orderVoucher;			
		}
		
		public void insertOrderVoucher(OrderVoucher orderVoucher)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				session.Save(orderVoucher);	
				NHibernateHelper.closeSession();
			}
		}
		
		public void updateOrderVoucher(OrderVoucher orderVoucher)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				session.Update(orderVoucher);	
				NHibernateHelper.closeSession();
			}
		}		
		
		public void deleteOrderVoucherByOrder(int idOrder)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())	
			{
				session.CreateQuery("delete from OrderVoucher where orderId=:idOrder").SetInt32("idOrder",idOrder).ExecuteUpdate();
				NHibernateHelper.closeSession();
			}					
		}
	}
}