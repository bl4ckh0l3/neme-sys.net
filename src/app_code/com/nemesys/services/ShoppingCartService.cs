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
		
		public static bool addItem(User user, int cartId, int sessionID, string acceptDate, IDictionary<int,IList<string>> requestFields, IDictionary<string,string> requestCalendar, HttpFileCollection MyFileCollection, int idProduct, int quantity, int maxProdQty, string resetQtyByCart, int idAds, string langcode, string defLangCode)
		{
			bool carryOn = false;
			ShoppingCart shoppingCart = null;
			
			if(cartId>-1){
				shoppingCart = shoprep.getByIdExtended(cartId, true);
				if(shoppingCart != null){		
					carryOn = true;
				}
			}else if(user != null){
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
			IList<ShoppingCartProductCalendar> newScpcal = new List<ShoppingCartProductCalendar>();
			IList<ProductCalendar> calendars = null;
			bool findItem = false;

			try{
				if(shoppingCart.products != null && shoppingCart.products.Count>0)
				{
					foreach(KeyValuePair<string, ShoppingCartProduct> scps in shoppingCart.products)
					{
						
						//System.Web.HttpContext.Current.Response.Write("<br>scps.Key: "+scps.Key+"<br>scps.Value.idCart: "+scps.Value.idCart+"<br>scps.Value.idProduct: "+scps.Value.idProduct+"<br>scps.Value.productCounter: "+scps.Value.productCounter+"<br>scps.Value.productName: "+scps.Value.productName+"<br>");
						
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
										ShoppingCartProductField founded = shoprep.getItemField(newitem.idCart, newitem.idProduct, newitem.productCounter, idf, v);
										if(founded != null){
											//System.Web.HttpContext.Current.Response.Write("founded: "+founded.ToString()+"<br>");
											newScpfs.Add(founded);
										}else{
											foundMatch = false;
											break;
										}
									}
									
									//System.Web.HttpContext.Current.Response.Write("foundMatch: "+foundMatch+"<br>");
									
									if(!foundMatch){
										break;
									}
								}
							}
							
							DateTime chkin = DateTime.Now;
							DateTime chkout = DateTime.Now;							
							int diffDays = 0;
							
							if(foundMatch && requestCalendar != null && requestCalendar.Count>0){
								chkin = DateTime.ParseExact(requestCalendar["checkin"], "dd/MM/yyyy", null);
								chkout = DateTime.ParseExact(requestCalendar["checkout"], "dd/MM/yyyy", null);
								diffDays = Convert.ToInt32(chkout.Subtract(chkin).TotalDays);		
								
								for(int i=0;i<=diffDays;i++){
									DateTime countD = chkin.AddDays(i);
									ShoppingCartProductCalendar tmpCal = shoprep.getItemCalendar(newitem.idCart, newitem.idProduct, newitem.productCounter, countD.ToString("dd/MM/yyyy"));
									if(tmpCal != null){
										//System.Web.HttpContext.Current.Response.Write("founded cal: "+tmpCal.ToString()+"<br>");
										newScpcal.Add(tmpCal);
									}else{
										foundMatch = false;
										break;
									}									
								}
							}
							
							if(!foundMatch){
								findItem = false;
								newScpfs = new List<ShoppingCartProductField>();
								newScpcal = new List<ShoppingCartProductCalendar>();
							}else{
								IList<ShoppingCartProductField> existScpf = null;
								IDictionary<int,IList<ShoppingCartProductField>> existScpfl = shoprep.findItemFields(newitem.idCart, newitem.idProduct, newitem.productCounter, -1);
								if(existScpfl != null && existScpfl.Count>0){
									existScpf = existScpfl[newitem.productCounter];
								}
									
								if(requestCalendar != null && requestCalendar.Count>0 && newScpcal.Count>0){
									int fAdults = 0;
									int fChildren = 0;
									string fchildrenAge = "";
									int travellers = 0;		
									
									int finalRooms = 0;
									int counter = 0;
									
									calendars = prodrep.getProductCalendarsCached(newitem.idProduct, true);
									
									if(calendars != null && calendars.Count>0){
										IDictionary<string, ProductCalendar> calD = new Dictionary<string, ProductCalendar>();
										foreach(ProductCalendar p in calendars){
											calD.Add(p.startDate.ToString("dd/MM/yyyy"),p);
											//Response.Write(calD[p.startDate.ToString("dd/MM/yyyy")].ToString()+"<br>");
										}
										
										foreach(ShoppingCartProductCalendar sp in newScpcal){
											if(!String.IsNullOrEmpty(resetQtyByCart) && "1".Equals(resetQtyByCart)){
												fAdults = Convert.ToInt32(requestCalendar["adults"]);
												fChildren = Convert.ToInt32(requestCalendar["childs"]);
												fchildrenAge = requestCalendar["childsAge"];
											}else{
												fAdults = sp.adults + Convert.ToInt32(requestCalendar["adults"]);
												fChildren = sp.children + Convert.ToInt32(requestCalendar["childs"]);
												fchildrenAge = sp.childrenAge + "," + requestCalendar["childsAge"];
											}
											travellers = fAdults+fChildren;	
									
											ProductCalendar p = null;
											
											if(calD.TryGetValue(sp.date.ToString("dd/MM/yyyy"), out p)
												 &&
												(
													//(travellers==1 && p.availability>0 && (p.unit-travellers<2)) || // un solo traveller e solo stanze singole o doppie (ad uso singola)
													//(p.availability>0 && p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) || //c'e almeno un posto e tutti stanno in una sola stanza e al massimo rimane solo un posto vuoto in una stanza
													(p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) //ci sono abbastanza camere per tutti e al massimo rimane solo un posto vuoto in una stanza
												)
											){
												int tmprooms = travellers/p.unit;
												if(travellers%p.unit!=0){
													tmprooms+=1;
												}
												sp.adults = fAdults;
												sp.children = fChildren;
												sp.childrenAge = fchildrenAge;
												sp.rooms = tmprooms;
												finalRooms+=tmprooms;
												counter++;
												//Response.Write("tmprooms: "+tmprooms+"<br>");	
											}else{
												throw new System.InvalidOperationException(MultiLanguageService.translate("frontend.template_prodotto.js.alert.exceed_qta_prod", langcode, defLangCode));
											}
										}
									}else{
										throw new System.InvalidOperationException(MultiLanguageService.translate("frontend.template_prodotto.js.alert.exceed_qta_prod", langcode, defLangCode));
									}
									
									if(finalRooms>0){
										finalRooms=finalRooms/counter;
									}
									
									
									foreach(ShoppingCartProductField f in newScpfs){
										f.productQuantity=finalRooms;
										
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
											ft.productQuantity=finalRooms;
											newScpfs.Add(ft);
										}
									}
										
									newitem.productQuantity = finalRooms;									
								}else{
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
								}
									
								findItem = true;
								break;
							}
						}
					}
				}				
				
				//System.Web.HttpContext.Current.Response.Write("findItem: "+findItem+"<br>");	
									
				if(!findItem)
				{	
					Product prod = prodrep.getByIdCached(idProduct, true);    
					int newPcounter = shoprep.getMaxItemCounter(shoppingCart.id, idProduct)+1;   

					if(requestCalendar != null && requestCalendar.Count>0){
						quantity = 0;	

						int fAdults = Convert.ToInt32(requestCalendar["adults"]);
						int fChildren = Convert.ToInt32(requestCalendar["childs"]);
						string fchildrenAge = requestCalendar["childsAge"];
						int travellers = fAdults+fChildren;								
						int finalRooms = 0;
						int counter = 0;
									
						if(prod.calendar != null && prod.calendar.Count>0){
							IDictionary<string, ProductCalendar> calD = new Dictionary<string, ProductCalendar>();
							foreach(ProductCalendar p in prod.calendar){
								calD.Add(p.startDate.ToString("dd/MM/yyyy"),p);
							}
							
							DateTime chkinNew = DateTime.ParseExact(requestCalendar["checkin"], "dd/MM/yyyy", null);
							DateTime chkoutNew = DateTime.ParseExact(requestCalendar["checkout"], "dd/MM/yyyy", null);
							int diffDaysNew = Convert.ToInt32(chkoutNew.Subtract(chkinNew).TotalDays);		
							
							for(int i=0;i<=diffDaysNew;i++){
								DateTime countD = chkinNew.AddDays(i);
								//System.Web.HttpContext.Current.Response.Write("countD: "+ countD.ToString("dd/MM/yyyy")+"<br>");
								
								ProductCalendar p = null;
								
								if(calD.TryGetValue(countD.ToString("dd/MM/yyyy"), out p)
									 &&
									(
										(p.availability*p.unit>=travellers && ((travellers%p.unit==0) || (p.unit-(travellers%p.unit))<2)) //ci sono abbastanza camere per tutti e al massimo rimane solo un posto vuoto in una stanza
									)
								){
									int tmprooms = travellers/p.unit;
									if(travellers%p.unit!=0){
										tmprooms+=1;
									}
								
									ShoppingCartProductCalendar newCal = new ShoppingCartProductCalendar();
									newCal.idCart = shoppingCart.id;
									newCal.idProduct = idProduct;
									newCal.productCounter = newPcounter;
									newCal.date = countD;						
									newCal.adults = fAdults;
									newCal.children = fChildren;
									newCal.rooms = tmprooms;
									newCal.childrenAge = fchildrenAge;	
									newCal.searchText = requestCalendar["search_text"];		
									newScpcal.Add(newCal);	
									
									//System.Web.HttpContext.Current.Response.Write("newCal: "+newCal.ToString()+"<br>");
									
									finalRooms+=tmprooms;
									counter++;
								}else{
									throw new System.InvalidOperationException(MultiLanguageService.translate("frontend.template_prodotto.js.alert.exceed_qta_prod", langcode, defLangCode));
								}	
							}						
						}else{
							throw new System.InvalidOperationException(MultiLanguageService.translate("frontend.template_prodotto.js.alert.exceed_qta_prod", langcode, defLangCode));
						}									
						
						if(finalRooms>0){
							quantity=finalRooms/counter;
						}
					}
							
					newitem = new ShoppingCartProduct();				
					newitem.idCart = shoppingCart.id;
					newitem.idProduct = idProduct;
					newitem.productCounter = newPcounter;
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
								newf.productCounter = newPcounter;
								newf.idField = idf;
								newf.fieldType = pf.type;
								newf.value = v;
								newf.productQuantity = quantity;
								newf.description = pf.description;
								
								//System.Web.HttpContext.Current.Response.Write("newf: "+newf.ToString()+"<br>");
		
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
												if(Utils.isValidExtension(Path.GetExtension(name))){
													OrderService.SaveStreamToFile(tmp.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/shoppingcarts/"+newitem.idCart+"/"+name));							
													break;
												}else{
													throw new Exception("022");
												}													
											}
										}
									}
								}
								
								newScpfs.Add(newf);
							}
						}
					}
				}
				
				shoprep.saveCompleteShoppingCartItem(newitem, newScpfs, newScpcal);			
				carryOn = true;
			}catch(Exception ex){
				throw;
			}			
			
			return carryOn;
		}
	}
}