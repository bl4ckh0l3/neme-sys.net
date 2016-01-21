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
	public class OrderService
	{	
		protected static IUserRepository usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");	
		protected static IPaymentRepository payrep = RepositoryFactory.getInstance<IPaymentRepository>("IPaymentRepository");
		protected static IPaymentTransactionRepository paytransrep = RepositoryFactory.getInstance<IPaymentTransactionRepository>("IPaymentTransactionRepository");
		protected static IOrderRepository orderep = RepositoryFactory.getInstance<IOrderRepository>("IOrderRepository");
		protected static ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		protected static IShippingAddressRepository shiprep = RepositoryFactory.getInstance<IShippingAddressRepository>("IShippingAddressRepository");
		protected static IBillsAddressRepository billsrep = RepositoryFactory.getInstance<IBillsAddressRepository>("IBillsAddressRepository");
		protected static IProductRepository productrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
		protected static IContentRepository contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
		protected static IAdsRepository adsrep = RepositoryFactory.getInstance<IAdsRepository>("IAdsRepository"); 
		protected static ConfigurationService confservice = new ConfigurationService();		
		
		public static void directoryCopy(string sourceDirName, string destDirName, bool copySubDirs, bool errorIfDirNotExists)
		{                                
			if(Directory.Exists(sourceDirName)){
				DirectoryInfo dir = new DirectoryInfo(sourceDirName);
				DirectoryInfo[] dirs = dir.GetDirectories();
		
				if (!Directory.Exists(destDirName))
				{
					Directory.CreateDirectory(destDirName);
				}
		
				FileInfo[] files = dir.GetFiles();
				foreach (FileInfo file in files)
				{
					string temppath = Path.Combine(destDirName, file.Name);
					file.CopyTo(temppath, false);
				}
		
				if (copySubDirs)
				{
					foreach (DirectoryInfo subdir in dirs)
					{
						string temppath = Path.Combine(destDirName, subdir.Name);
						directoryCopy(subdir.FullName, temppath, copySubDirs, errorIfDirNotExists);
					}
				}
			}else{
				if(errorIfDirNotExists){
					throw new DirectoryNotFoundException("Source directory does not exist or could not be found: "+ sourceDirName);
				}				
			}
		}
		
		public static void SaveStreamToFile(Stream stream, string filename)
		{  
		   using(Stream destination = File.Create(filename))
			  Write(stream, destination);
		}
		
		//Typically I implement this Write method as a Stream extension method. 
		//The framework handles buffering.		
		static void Write(Stream from, Stream to)
		{
		   for(int a = from.ReadByte(); a != -1; a = from.ReadByte())
			  to.WriteByte( (byte) a );
		}
		
		public static bool deleteDirectory(string directory)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				if(Directory.Exists(directory)) 
				{
					Directory.Delete(directory, true);
					deleted = true;
				}
			}catch(Exception ex)
			{
				deleted = false;
			}

			return deleted;			
		}
		
		public static IDictionary<int,string> getOrderStatus()
		{
			IDictionary<int,string> status = new Dictionary<int,string>();
			status.Add(1,"added");
			status.Add(2,"execution");
			status.Add(3,"processed");
			status.Add(4,"rejected");
			
			return status;
		}
		
		public static ShippingAddress OrderShipAddress2ShippingAddress(OrderShippingAddress orderShippingAddress)
		{
			ShippingAddress ship = new ShippingAddress();
			ship.id=-1;
			ship.idUser=-1;
			ship.name=orderShippingAddress.name;
			ship.surname=orderShippingAddress.surname;
			ship.cfiscvat=orderShippingAddress.cfiscvat;
			ship.address=orderShippingAddress.address;
			ship.city=orderShippingAddress.city;
			ship.zipCode=orderShippingAddress.zipCode;
			ship.country=orderShippingAddress.country;
			ship.stateRegion=orderShippingAddress.stateRegion;
			ship.isCompanyClient=orderShippingAddress.isCompanyClient;
			
			return ship;
		}
		
		public static OrderShippingAddress shipAddress2OrderShippingAddress(ShippingAddress shippingAddress)
		{
			OrderShippingAddress oship = new OrderShippingAddress();
			oship.idOrder=-1;
			oship.name=shippingAddress.name;
			oship.surname=shippingAddress.surname;
			oship.cfiscvat=shippingAddress.cfiscvat;
			oship.address=shippingAddress.address;
			oship.city=shippingAddress.city;
			oship.zipCode=shippingAddress.zipCode;
			oship.country=shippingAddress.country;
			oship.stateRegion=shippingAddress.stateRegion;
			oship.isCompanyClient=shippingAddress.isCompanyClient;
			
			return oship;
		}
		
		public static BillsAddress OrderBillsAddress2BillsAddress(OrderBillsAddress orderBillsAddress)
		{
			BillsAddress bills = new BillsAddress();
			bills.id=-1;
			bills.idUser=-1;
			bills.name=orderBillsAddress.name;
			bills.surname=orderBillsAddress.surname;
			bills.cfiscvat=orderBillsAddress.cfiscvat;
			bills.address=orderBillsAddress.address;
			bills.city=orderBillsAddress.city;
			bills.zipCode=orderBillsAddress.zipCode;
			bills.country=orderBillsAddress.country;
			bills.stateRegion=orderBillsAddress.stateRegion;
			
			return bills;
		}
		
		public static OrderBillsAddress billsAddress2OrderBillsAddress(BillsAddress billsAddress)
		{
			OrderBillsAddress obills = new OrderBillsAddress();
			obills.idOrder=-1;
			obills.name=billsAddress.name;
			obills.surname=billsAddress.surname;
			obills.cfiscvat=billsAddress.cfiscvat;
			obills.address=billsAddress.address;
			obills.city=billsAddress.city;
			obills.zipCode=billsAddress.zipCode;
			obills.country=billsAddress.country;
			obills.stateRegion=billsAddress.stateRegion;
			
			return obills;
		}
		
		public static bool canDownloadAttachment(OrderProductAttachmentDownload opad){
			bool download = false;
			
			download = 	opad.active &&
						("9999-12-31".Equals(opad.expireDate.ToString("dd/MM/yyyy")) || DateTime.Compare(opad.expireDate, DateTime.Now)>=0) &&
						(opad.maxDownload == -1 || opad.downloadCounter <= opad.maxDownload);
			
			return download;
		}
		
		public static bool sendConfirmOrderMail(int orderId, string langcode, string defLangCode, string url)
		{
			bool mailSent = false;
			
			string paymentType = "";
			bool paymentDone = false;
			decimal billsAmount = 0.00M;
			decimal paymentCommissions = 0.00M;
			decimal orderAmount = 0.00M;
			bool hasShipAddress = false;
			bool hasBillsAddress = false;
			bool hasOrderRule = false;
			bool hasProductRule = false;
			string pdone = "";
			IList<OrderBusinessRule> orderRules = null;
			IList<OrderBusinessRule> productRules = null;
			IDictionary<int,string> statusOrder = OrderService.getOrderStatus();
			IList<UserField> usrfields;
				
			try{	
				List<string> usesFor = new List<string>();
				usesFor.Add("2");
				usesFor.Add("3");			
				usrfields = usrrep.getUserFields("true",usesFor);
			}catch (Exception ex){
				usrfields = new List<UserField>();
			}	
		
			try{
				FOrder order = orderep.getByIdExtended(orderId, true);
				
				User user = usrrep.getById(order.userId);
				
				paymentDone = order.paymentDone;
				paymentCommissions = order.paymentCommission;
				orderAmount = order.amount;
	
				pdone = MultiLanguageService.translate("portal.commons.no", langcode, defLangCode);
				if(paymentDone){
					pdone = MultiLanguageService.translate("portal.commons.yes", langcode, defLangCode);
				}			
				
				int paymentId = order.paymentId;
				Payment payment = payrep.getByIdCached(paymentId, true);
				if(payment != null){
					paymentType = payment.description;
					if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.payment.description.label."+payment.description, langcode, defLangCode))){
						paymentType = MultiLanguageService.translate("backend.payment.description.label."+payment.description, langcode, defLangCode);
					}
					if(!String.IsNullOrEmpty(payment.paymentData)){
					paymentType+="<br/>"+payment.paymentData+"<br/>";
					}
				}
				
				IList<OrderFee> fees = orderep.findFeesByOrderId(order.id);
				if(fees != null && fees.Count>0){
					foreach(OrderFee f in fees){
						billsAmount+=f.amount;
					}
				}
				
				OrderShippingAddress oshipaddr = orderep.getOrderShippingAddressCached(order.id, true);
				if(oshipaddr != null){
					hasShipAddress = true;
				}
				
				OrderBillsAddress obillsaddr = orderep.getOrderBillsAddressCached(order.id, true);
				if(obillsaddr != null){
					hasBillsAddress = true;
				}
				
				orderRules = orderep.findOrderBusinessRule(order.id, false);
				if(orderRules != null && orderRules.Count>0){
					hasOrderRule = true;
				}
				
				productRules = orderep.findOrderBusinessRule(order.id, true);
				if(productRules != null && productRules.Count>0){
					hasProductRule = true;
				}
				
				ListDictionary replacementsUser = new ListDictionary();
				ListDictionary replacementsAdmin = new ListDictionary();
				StringBuilder userMessage = new StringBuilder();
				StringBuilder adminMessage = new StringBuilder();	
				replacementsUser.Add("mail_receiver",user.email);	
				
				//start user message
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.id_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.guid_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.order_client", langcode, defLangCode)).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
				.Append(MultiLanguageService.translate("frontend.registration.manage.label.email", langcode, defLangCode)).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");		
				
				//start admin message
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.id_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.guid_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.order_client", langcode, defLangCode)).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
				.Append(MultiLanguageService.translate("frontend.registration.manage.label.email", langcode, defLangCode)).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");								
					
				if(order.noRegistration && "1".Equals(confservice.get("show_user_field_on_direct_buy").value) && user.fields != null && user.fields.Count>0 && usrfields != null && usrfields.Count>0){							
					foreach(UserFieldsMatch f in user.fields){
						string label = "";
						string value = "";
						foreach(UserField uf in usrfields){
							if(uf.id==f.idParentField){
								label = uf.description;
								value = f.value;
								if(uf.typeContent==7 || uf.typeContent==8){
									if(!String.IsNullOrEmpty(MultiLanguageService.translate("portal.commons.select.option.country."+f.value, langcode, defLangCode))){
										value = MultiLanguageService.translate("portal.commons.select.option.country."+f.value, langcode, defLangCode);
									}
								}
								if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value, langcode, defLangCode))){
									label = MultiLanguageService.translate("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value, langcode, defLangCode);
								}
								break;
							}										
						}
						userMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");
						adminMessage.Append(label).Append(":&nbsp;<b>").Append(value).Append("</b><br/><br/>");								
					}
				}
				
				//****** MANAGE SHIPPING ADDRESS
				if(hasShipAddress){
					string shipInfo = "";
					string userLabelIsCompanyClient = "";
					if(oshipaddr.isCompanyClient){
						userLabelIsCompanyClient = MultiLanguageService.translate("frontend.utenti.detail.table.label.is_company", langcode, defLangCode);
					}else{
						userLabelIsCompanyClient = MultiLanguageService.translate("frontend.utenti.detail.table.label.is_private", langcode, defLangCode);
					}								
					
					shipInfo = oshipaddr.name + " " + oshipaddr.surname + " ("+userLabelIsCompanyClient+") - " + oshipaddr.cfiscvat + " - " +oshipaddr.address +" - "+oshipaddr.city+" ("+oshipaddr.zipCode+") - "+MultiLanguageService.translate("portal.commons.select.option.country."+oshipaddr.country, langcode, defLangCode)+" - "+MultiLanguageService.translate("portal.commons.select.option.country."+oshipaddr.stateRegion, langcode, defLangCode);
						
					userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.shipping_address", langcode, defLangCode)).Append(":&nbsp;<b>").Append(shipInfo).Append("</b><br/><br/>");
					adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.shipping_address", langcode, defLangCode)).Append(":&nbsp;<b>").Append(shipInfo).Append("</b><br/><br/>");	
				}	
				
				//****** MANAGE BILLS ADDRESS
				if(hasBillsAddress){
					string billsInfo = obillsaddr.name + " " + obillsaddr.surname + " - " + obillsaddr.cfiscvat + " - " +obillsaddr.address +" - "+obillsaddr.city+" ("+obillsaddr.zipCode+") - "+MultiLanguageService.translate("portal.commons.select.option.country."+obillsaddr.country, langcode, defLangCode)+" - "+MultiLanguageService.translate("portal.commons.select.option.country."+obillsaddr.stateRegion, langcode, defLangCode);
									
					userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.bills_address", langcode, defLangCode)).Append(":&nbsp;<b>").Append(billsInfo).Append("</b><br/><br/>");
					adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.bills_address", langcode, defLangCode)).Append(":&nbsp;<b>").Append(billsInfo).Append("</b><br/><br/>");					
				}
	
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.dta_insert_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.dta_insert_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");				
	
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.attached_prods", langcode, defLangCode)).Append("<br/>");		
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.attached_prods", langcode, defLangCode)).Append("<br/>");			
				
				StringBuilder orderProducts = new StringBuilder();
				orderProducts.Append("<table border=0 align=top cellpadding=3 cellspacing=0 style=\"border:1px solid #C9C9C9;\">")						
				.Append("<tr>")
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.view.table.header.nome_prod", langcode, defLangCode)).Append("</th>")
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.view.table.header.sommario_prod", langcode, defLangCode)).Append("</th>")
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.view.table.header.totale_prod", langcode, defLangCode)).Append("</th>")
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.view.table.header.totale_tax", langcode, defLangCode)).Append("</th>")
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.view.table.header.qta_prod", langcode, defLangCode)).Append("</th>")	
				.Append("<th style=\"border:1px solid #C9C9C9;\">").Append(MultiLanguageService.translate("backend.ordini.detail.table.label.fields_prod", langcode, defLangCode)).Append("</th>")				
				.Append("</tr>");
				
				if(order.products != null && order.products.Count>0){
					foreach(OrderProduct op in order.products.Values){
						Product prod = productrep.getByIdCached(op.idProduct, true);
						IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
					
						string adsRefTitle = "";
						if(op.idAds != null && op.idAds>-1){
							Ads a = adsrep.getById(op.idAds);
							if(a != null){
								FContent f = contrep.getByIdCached(a.elementId, true);
								if(f != null){
									adsRefTitle = "<br/><b>"+MultiLanguageService.translate("frontend.carrello.table.label.ads_title", langcode, defLangCode)+"</b>&nbsp;"+f.title;
								}
							}
						}
						
						//****** MANAGE SUPPLEMENT DESCRIPTION
						string suppdesc = op.supplementDesc;
						string suppdesctrans = MultiLanguageService.translate("backend.supplement.description.label."+suppdesc, langcode, defLangCode);
						if(!String.IsNullOrEmpty(suppdesctrans)){
							suppdesc = suppdesctrans;
						}
						suppdesc = "&nbsp;("+suppdesc+")";	
	
						string opmargin = "";
						if(op.margin > 0){
							opmargin = "<li>"+MultiLanguageService.translate("frontend.carrello.table.label.commissioni", langcode, defLangCode)+":&nbsp;&euro;&nbsp;"+op.margin.ToString("#,###0.00")+"</li>";
						}
						
						string opdiscPerc = "";
						if (op.discountPerc > 0) {
							decimal discountValue = 0-op.discount;
							opdiscPerc ="<li>"+MultiLanguageService.translate("frontend.carrello.table.label.sconto_applicato", langcode, defLangCode)+"&nbsp;"+op.discountPerc.ToString("#,###0.##")+"%:&nbsp;&euro;&nbsp;"+discountValue.ToString("#,###0.00")+"</li>";
						}					
						
						//****** MANAGE ORDER RULES FOR PRODUCT
						string orderProdRules = "";
						if (hasProductRule){
							foreach(OrderBusinessRule w in productRules){
								int tmpIdProd = w.productId;
								int tmpCounterProd = w.productCounter;
								if(tmpIdProd==op.idProduct && tmpCounterProd==op.productCounter){
									string tmpLabel = w.label;                 
									decimal tmpAmountRule = w.value;
									orderProdRules+="<li>";
									if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.businessrule.label.label."+tmpLabel, langcode, defLangCode))){
										orderProdRules+=MultiLanguageService.translate("backend.businessrule.label.label."+tmpLabel, langcode, defLangCode);
									}else{
										orderProdRules+=tmpLabel;
									}
									if(tmpAmountRule!=0){
										orderProdRules+=":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00");
									}
									orderProdRules+="</li>";
								}
							}
						}	
						
						//****** MANAGE FIELDS FOR PRODUCT
						string productFields = "";
						if(opfs != null && opfs.Count>0){
							foreach(OrderProductField opf in opfs){
								string flabel = MultiLanguageService.translate("backend.prodotti.detail.table.label.field_description_"+opf.description+"_"+prod.keyword, langcode, defLangCode);
								if(String.IsNullOrEmpty(flabel)){
									flabel = opf.description;
								}
								
								if(opf.fieldType==8){
									productFields+=flabel+":&nbsp;<a target='_blank' href='"+url+"public/upload/files/orders/"+opf.idOrder+"/"+opf.value+"'>"+opf.value+"</a><br/>";
								}else{
									productFields+=flabel+":&nbsp;"+opf.value+"<br/>";
								}
							}
						}				
					
						orderProducts.Append("<tr>")
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
							.Append(productrep.getMainFieldTranslationCached(op.idProduct, 1 , langcode, true,  op.productName, true).value)
							.Append(adsRefTitle)
						.Append("</td>")
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(productrep.getMainFieldTranslationCached(op.idProduct, 2 , langcode, true,  prod.summary, true).value).Append("</td>")
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
							.Append("&euro;&nbsp;")
							.Append(op.taxable.ToString("#,###0.00"))
							.Append("<ul style=padding:0px;>")
							.Append(opmargin)
							.Append(opdiscPerc)
							.Append(orderProdRules)
							.Append("</ul>")
						.Append("</td>")
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
							.Append("&euro;&nbsp;")
							.Append(op.supplement.ToString("#,###0.00"))
							.Append(suppdesc)
						.Append("</td>")
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(op.productQuantity).Append("</td>")	
						.Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">")
							.Append(productFields)
						.Append("</td>")					
						.Append("</tr>");
					}  
				}
				orderProducts.Append("</table>");
	
	
				userMessage.Append(orderProducts.ToString()).Append("<br/><br/>");		
				adminMessage.Append(orderProducts.ToString()).Append("<br/><br/>");	
				
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.tipo_pagam_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(paymentType).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.pagam_order_done", langcode, defLangCode)).Append(":&nbsp;<b>").Append(pdone).Append("</b><br/><br/>");
	
				//****** MANAGE PAYMENT TRANSACTION (ONLY FOR ADMIN EMAIL)
				string paymentTrans = "";
				IList<PaymentTransaction> transactions = paytransrep.find(order.id, -1, null, null, false);
				foreach(PaymentTransaction q in transactions){
					paymentTrans+="<strong>ID:</strong> "+q.idTransaction+";&nbsp;";
					paymentTrans+="<strong>STATUS:</strong> "+q.status+";&nbsp;";
					if(q.notified){
						paymentTrans+="<strong>NOTIFIED:</strong> "+MultiLanguageService.translate("backend.commons.no", langcode, defLangCode)+";<br/>";
					}else{
						paymentTrans+="<strong>NOTIFIED:</strong> "+MultiLanguageService.translate("backend.commons.yes", langcode, defLangCode)+";<br/>";
					}
				}
				
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.tipo_pagam_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(paymentType).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.pagam_order_done", langcode, defLangCode)).Append(":&nbsp;<b>").Append(pdone).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.list_transaction_order", langcode, defLangCode)).Append(":&nbsp;<b>")
					.Append(paymentTrans)
				.Append("</b><br/><br/>");			
	
				//****** MANAGE ORDER STATUS
				string orderStatus = "";
				if(order.status==1){
					orderStatus = statusOrder[order.status];
					if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode))){
						orderStatus = MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode);
					}
				}else if(order.status==2){
					orderStatus = statusOrder[order.status];
					if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode))){
						orderStatus = MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode);
					}
				}else if(order.status==3){
					orderStatus = statusOrder[order.status];
					if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode))){
						orderStatus = MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode);
					}
				}else if(order.status==4){
					orderStatus = statusOrder[order.status];
					if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode))){
						orderStatus = MultiLanguageService.translate("backend.ordini.view.table.label."+orderStatus, langcode, defLangCode);
					}
				}		
	
				//****** MANAGE ORDER FEES
				string orderFees = "";
				if(fees != null && fees.Count>0){
					foreach(OrderFee f in fees){
						string label = f.feeDesc;
						if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.fee.description.label."+f.feeDesc, langcode, defLangCode))){
							label = MultiLanguageService.translate("backend.fee.description.label."+f.feeDesc, langcode, defLangCode);
						}
						orderFees+=label+"&nbsp;&nbsp;&nbsp;&euro;&nbsp;"+f.amount.ToString("#,###0.00")+"<br/>";
					}
				}			
				
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.stato_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(orderStatus).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.spese_spediz_order", langcode, defLangCode)).Append(":&nbsp;<br/><b>").Append(orderFees).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.payment_commission", langcode, defLangCode)).Append(":&nbsp;<b>&euro;&nbsp;").Append(paymentCommissions.ToString("#,###0.00")).Append("</b><br/><br/>");
				
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.stato_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(orderStatus).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.spese_spediz_order", langcode, defLangCode)).Append(":&nbsp;<br/><b>").Append(orderFees).Append("</b><br/><br/>")
				.Append(MultiLanguageService.translate("backend.ordini.view.table.label.payment_commission", langcode, defLangCode)).Append(":&nbsp;<b>&euro;&nbsp;").Append(paymentCommissions.ToString("#,###0.00")).Append("</b><br/><br/>");	
	
				//****** MANAGE ORDER RULES
				string orderRulesDesc = "";
				if(hasOrderRule){
					foreach(OrderBusinessRule x in orderRules){
						if(!String.IsNullOrEmpty(MultiLanguageService.translate("backend.businessrule.label.label."+x.label, langcode, defLangCode))){ 
							orderRulesDesc+=MultiLanguageService.translate("backend.businessrule.label.label."+x.label, langcode, defLangCode);
						}else{
							orderRulesDesc+=x.label;
						}
						orderRulesDesc+="&nbsp;&nbsp;&nbsp;<b>&euro;&nbsp;"+x.value.ToString("#,###0.00")+"</b><br/>";
					}
					orderRulesDesc+="<br/>";
					
					userMessage.Append(orderRulesDesc);
					adminMessage.Append("<b>").Append(MultiLanguageService.translate("backend.ordini.view.table.label.business_rules", langcode, defLangCode)).Append(":</b><br/>").Append(orderRulesDesc);
				}
				
				userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.totale_order", langcode, defLangCode)).Append(":&nbsp;<b>&euro;&nbsp;").Append(orderAmount.ToString("#,###0.00")).Append("</b><br/><br/>");
				adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.totale_order", langcode, defLangCode)).Append(":&nbsp;<b>&euro;&nbsp;").Append(orderAmount.ToString("#,###0.00")).Append("</b><br/><br/>");
				
			
				replacementsUser.Add("<%content%>",HttpUtility.HtmlDecode(userMessage.ToString()));
				replacementsAdmin.Add("<%content%>",HttpUtility.HtmlDecode(adminMessage.ToString()));
				
				MailService.prepareAndSend("order-confirmed", langcode, defLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, url);
				MailService.prepareAndSend("order-confirmed", langcode, defLangCode, "backend.mails.detail.table.label.subject_", replacementsAdmin, null, url);	
				
				order.mailSent=true;
				orderep.update(order);
				
				mailSent = true;
			}catch(Exception ex){
				StringBuilder builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);
				
				mailSent = false;
			}
			
			return mailSent;
		}

		
		public static bool sendDownloadOrderMail(int orderId, string langcode, string defLangCode, string url)
		{
			bool mailDownSent = false;

			try{
				FOrder order = orderep.getByIdExtended(orderId, true);
				
				User user = usrrep.getById(order.userId);
				
				bool hasDownAttach = false;
				
				if(order.products != null && order.products.Count>0){			
					ListDictionary replacementsUser = new ListDictionary();
					ListDictionary replacementsAdmin = new ListDictionary();
					StringBuilder userMessage = new StringBuilder();
					StringBuilder adminMessage = new StringBuilder();	
					replacementsUser.Add("mail_receiver",user.email);	
					
					//start user message
					userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.id_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
					.Append(MultiLanguageService.translate("backend.ordini.view.table.label.guid_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
					.Append(MultiLanguageService.translate("backend.ordini.view.table.label.order_client", langcode, defLangCode)).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
					.Append(MultiLanguageService.translate("frontend.registration.manage.label.email", langcode, defLangCode)).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");		
					
					//start admin message
					adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.id_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.id).Append("</b><br/><br/>")
					.Append(MultiLanguageService.translate("backend.ordini.view.table.label.guid_ordine", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.guid).Append("</b><br/><br/>")
					.Append(MultiLanguageService.translate("backend.ordini.view.table.label.order_client", langcode, defLangCode)).Append("&nbsp;-&nbsp;ID:&nbsp;<b>").Append(user.username).Append("</b>&nbsp;-&nbsp;")
					.Append(MultiLanguageService.translate("frontend.registration.manage.label.email", langcode, defLangCode)).Append(":&nbsp;<b>").Append(user.email).Append("</b><br/><br/>");					
						
					userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.dta_insert_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");
					adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.dta_insert_order", langcode, defLangCode)).Append(":&nbsp;<b>").Append(order.insertDate.ToString("dd/MM/yyyy HH:mm")).Append("</b><br/><br/>");				
		
					userMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.attached_prods", langcode, defLangCode)).Append("<br/>");		
					adminMessage.Append(MultiLanguageService.translate("backend.ordini.view.table.label.attached_prods", langcode, defLangCode)).Append("<br/>");					
					
					
					userMessage.Append("<table border=0 align=top cellpadding=3 cellspacing=0 style=\"border:1px solid #C9C9C9;\">");
					adminMessage.Append("<table border=0 align=top cellpadding=3 cellspacing=0 style=\"border:1px solid #C9C9C9;\">");
	
					foreach(OrderProduct op in order.products.Values){
						if(op.productType==1){
							IList<OrderProductAttachmentDownload> attachments = orderep.getAttachmentDownload(order.id, op.idProduct);
							if(attachments != null && attachments.Count>0){
								userMessage.Append("<tr>").Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(productrep.getMainFieldTranslationCached(op.idProduct, 1 , langcode, true,  op.productName, true).value).Append("</td>").Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">");
								adminMessage.Append("<tr>").Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">").Append(productrep.getMainFieldTranslationCached(op.idProduct, 1 , langcode, true,  op.productName, true).value).Append("</td>").Append("<td style=\"border:1px solid #C9C9C9;vertical-align:top;\">");
									
								foreach(OrderProductAttachmentDownload d in attachments){
									// check if is still valid download
									if(d.active){
										ProductAttachmentDownload down =  productrep.getProductAttachmentDownloadById(d.idDownFile);
										if(down != null){
											//orderProducts.Append(productFields)
											userMessage.Append("&nbsp;&nbsp;<a href='").Append(url).Append("common/include/download-order-attach.aspx?orderid="+order.id+"&attachid="+d.id+"'>").Append(down.fileName).Append("</a><br/>");
											adminMessage.Append("&nbsp;&nbsp;").Append(down.fileName).Append("<br/>");
											hasDownAttach = true;
										}
									}
								}
								
								userMessage.Append("</td>").Append("</tr>");
								adminMessage.Append("</td>").Append("</tr>");
							}
						}
					}
					userMessage.Append("</table>");
					adminMessage.Append("</table>");						
					
					if(hasDownAttach){
						replacementsUser.Add("<%content%>",HttpUtility.HtmlDecode(userMessage.ToString()));
						replacementsAdmin.Add("<%content%>",HttpUtility.HtmlDecode(adminMessage.ToString()));
						
						MailService.prepareAndSend("order-down-confirmed", langcode, defLangCode, "backend.mails.detail.table.label.subject_", replacementsUser, null, url);
						MailService.prepareAndSend("order-down-confirmed", langcode, defLangCode, "backend.mails.detail.table.label.subject_", replacementsAdmin, null, url);	
					
						order.downloadNotified=true;
						orderep.update(order);	
					
						mailDownSent = true;				
					}			
				}
			}catch(Exception ex){
				StringBuilder builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);
				
				mailDownSent = false;
			}
			
			return mailDownSent;
		}
		
		public static bool activateAds(int orderId, string langcode, string defLangCode)
		{
			bool adsActivated = false;

			try{
				FOrder order = orderep.getByIdExtended(orderId, true);		
				
				if(order.products != null && order.products.Count>0){	
					bool hasAds = false;
					
					foreach(OrderProduct op in order.products.Values){
						if(op.productType==2 && op.idAds>-1){	
							adsrep.activatePromotion(op.idAds, op.idProduct);
							hasAds = true;
						}
					}				
					
					if(hasAds){
						order.adsEnabled=true;
						orderep.update(order);
						
						adsActivated = true;
					}
				}
			}catch(Exception ex){
				StringBuilder builder = new StringBuilder("Exception: ")
				.Append("An error occured: ").Append(ex.Message).Append("<br><br><br>").Append(ex.StackTrace);
				Logger log = new Logger(builder.ToString(),"system","error",DateTime.Now);		
				lrep.write(log);
				
				adsActivated = false;
			}
			
			return adsActivated;			
		}
	}
}