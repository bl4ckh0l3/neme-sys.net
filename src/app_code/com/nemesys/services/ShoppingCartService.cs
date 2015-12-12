using System;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Collections;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class ShoppingCartService
	{
		protected static IProductRepository prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		protected static IShoppingCartRepository shoprep = RepositoryFactory.getInstance<IShoppingCartRepository>("IShoppingCartRepository");

		
		public static bool delCart(int cartId)
		{
			bool carryOn = false;
			try
			{
				ShoppingCart sc = shoprep.getById(cartId);
				shoprep.delete(sc);	
				carryOn = true;
			}
			catch(Exception ex)
			{
				throw;
			}	
			
			return carryOn;
		}	
				
		public static bool delCartByIdUser(int idUser)
		{
			bool carryOn = false;
			try
			{
				shoprep.deleteByIdUser(idUser);	
				carryOn = true;
			}
			catch(Exception ex)
			{
				throw;
			}	
			
			return carryOn;
		}
		
		public static bool delItem(int cartId, int itemId, int itemCounter)
		{
			bool carryOn = false;
			try
			{
				shoprep.deleteItem(cartId, itemId, itemCounter);
				carryOn = true;
			}
			catch(Exception ex)
			{
				throw;
			}	
			
			return carryOn;
		}	
		
		public static bool addItem(User user, int sessionID, string acceptDate, IDictionary<int,IList<string>> requestFields, HttpFileCollection MyFileCollection, int idProduct, int quantity, int maxProdQty, string resetQtyByCart, int idAds, string langcode, string defLangCode)
		{
			bool carryOn = false;
			ShoppingCart shoppingCart = null;
				
			if(user != null){
				shoppingCart = shoprep.getByIdUser(sessionID, acceptDate, true);
				if(shoppingCart != null){
					shoppingCart.idUser=user.id;
					shoprep.update(shoppingCart);
				}else{
					shoppingCart = shoprep.getByIdUser(user.id, acceptDate, true);
				}
				
				if(shoppingCart != null){
					carryOn = true;
				}
			}else{
				shoppingCart = shoprep.getByIdUser(sessionID, acceptDate, true);
				if(shoppingCart != null){		
					carryOn = true;
				}			
			}			
			
			if(!carryOn){
				shoppingCart = new ShoppingCart();
				
				try{
					if(user != null){
						shoppingCart.idUser=user.id;
					}else{
						shoppingCart.idUser=sessionID;
					}
					
					shoprep.insert(shoppingCart);
					carryOn = true;
				}catch(Exception ex){
					throw;
				}
			}
			
			ShoppingCartProduct newitem = null;	
			IList<ShoppingCartProductField> newScpfs = new List<ShoppingCartProductField>();
			bool findItem = false;

			try{
				if(shoppingCart.products != null && shoppingCart.products.Count>0)
				{
					foreach(KeyValuePair<string, ShoppingCartProduct> scps in shoppingCart.products)
					{
						
						//Response.Write("<br>scps.Key: "+scps.Key+"<br>scps.Value.idCart: "+scps.Value.idCart+"<br>scps.Value.idProduct: "+scps.Value.idProduct+"<br>scps.Value.productCounter: "+scps.Value.productCounter+"<br>scps.Value.productName: "+scps.Value.productName+"<br>");
						
						if(scps.Key.StartsWith(idProduct.ToString()+"|"))
						{	
							newitem = scps.Value;
							bool foundMatch = true;	
							
							if(newitem.idAds != idAds){
								foundMatch = false;
							}
							
							if(foundMatch && requestFields != null && requestFields.Count>0){
								foreach(int idf in requestFields.Keys)
								{
									IList<string> values = requestFields[idf];
									foreach(string v in values)
									{
										/*string tmp = v;
										if(v.IndexOf("/")>=0 || v.IndexOf("\\")>=0){
											tmp = Path.GetFileName(v);
										}*/
										ShoppingCartProductField founded = shoprep.getItemField(newitem.idCart, newitem.idProduct, newitem.productCounter, idf, v);
										if(founded != null){
											//Response.Write("founded: "+founded.ToString()+"<br>");
											newScpfs.Add(founded);
										}else{
											newScpfs = new List<ShoppingCartProductField>();
											foundMatch = false;
											break;
										}
									}
									
									//Response.Write("foundMatch: "+foundMatch+"<br>");
									
									if(!foundMatch){
										break;
									}
								}
							}
							
							if(!foundMatch){
								findItem = false;
							}else{
								IList<ShoppingCartProductField> existScpf = null;
								IDictionary<int,IList<ShoppingCartProductField>> existScpfl = shoprep.findItemFields(newitem.idCart, newitem.idProduct, newitem.productCounter, -1);
								if(existScpfl != null && existScpfl.Count>0){
									existScpf = existScpfl[newitem.productCounter];
								}
								
								foreach(ShoppingCartProductField f in newScpfs){
									int finalQuantity = quantity+f.productQuantity;
									
									if(!String.IsNullOrEmpty(resetQtyByCart) && "1".Equals(resetQtyByCart)){
										finalQuantity = quantity;
									}
									
									if(maxProdQty > -1 && finalQuantity>maxProdQty){
										throw new System.InvalidOperationException(MultiLanguageService.translate("frontend.template_prodotto.js.alert.exceed_qta_prod", langcode, defLangCode));
									}										
	
									//Response.Write("f.productQuantity before: "+f.productQuantity+"<br>");	
									f.productQuantity=finalQuantity;
									
									if(existScpf != null && existScpf.Count>0){
										//Response.Write("existScpf.Count: "+existScpf.Count+"<br>");
										foreach(ShoppingCartProductField ft in existScpf){
											//Response.Write("ft in existScpf: "+ft.ToString()+"<br>");
											if(ft.Equals(f)){
												//Response.Write("f.Equals(ft): <br>f: "+f.ToString()+"<br>ft: "+ft.ToString()+"<br>");	
												existScpf.Remove(ft);
												break;
											}
										}
									}	
									
									
									
									//Response.Write("f.productQuantity after: "+f.productQuantity+"<br>");							
								}
								
								if(existScpf != null && existScpf.Count>0){
									//Response.Write("existScpf.Count: "+existScpf.Count+"<br>");
									foreach(ShoppingCartProductField ft in existScpf){
										newScpfs.Add(ft);
									}
								}
									
								if(!String.IsNullOrEmpty(resetQtyByCart) && "1".Equals(resetQtyByCart)){
									newitem.productQuantity = quantity;
								}else{
									newitem.productQuantity+=quantity;
								}	
								
								findItem = true;
								break;
							}
						}
					}
				}				
				
				//Response.Write("findItem: "+findItem+"<br>");	
									
				if(!findItem)
				{	
					Product prod = prodrep.getByIdCached(idProduct, true);
					newitem = new ShoppingCartProduct();				
					newitem.idCart = shoppingCart.id;
					newitem.idProduct = idProduct;
					newitem.productCounter = shoprep.getMaxItemCounter(shoppingCart.id, idProduct)+1;
					newitem.productQuantity = quantity;
					newitem.productType = prod.prodType;
					newitem.productName = prod.name;
					newitem.idAds = idAds;
					
					if(requestFields != null && requestFields.Count>0){
						foreach(int idf in requestFields.Keys)
						{
							IList<string> values = requestFields[idf];
							foreach(string v in values)
							{
								ProductField pf = prodrep.getProductFieldByIdCached(idf, true);							
								
								ShoppingCartProductField newf = new ShoppingCartProductField();			
								newf.idCart = newitem.idCart;
								newf.idProduct = newitem.idProduct;
								newf.productCounter = newitem.productCounter;
								newf.idField = idf;
								newf.fieldType = pf.type;
								newf.value = v;
								newf.productQuantity = quantity;
								newf.description = pf.description;
		
								if(newf.fieldType==8){
									string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+newitem.idCart); 
									if (!Directory.Exists(dirName))
									{
										Directory.CreateDirectory(dirName);
									}
									
									if(MyFileCollection != null && MyFileCollection.Count>0){
										for(int k = 0; k<MyFileCollection.Keys.Count;k++)
										{	
											HttpPostedFile tmp = MyFileCollection[k];
											string name = Path.GetFileName(tmp.FileName);
											if(!String.IsNullOrEmpty(name) && name==v)
											{
												OrderService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+newitem.idCart+"/"+name));
												break;					
											}
										}
									}
								}
								
								newScpfs.Add(newf);
							}
						}
					}
				}
				
				shoprep.saveCompleteShoppingCartItem(newitem, newScpfs);			
				carryOn = true;
			}catch(Exception ex){
				throw;
			}			
			
			return carryOn;
		}
	}
}