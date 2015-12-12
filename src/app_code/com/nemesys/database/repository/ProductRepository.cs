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
	public class ProductRepository : IProductRepository
	{		
		public void insert(Product product)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				IList<ProductAttachment> newProductAttachment = new List<ProductAttachment>();
				IList<ProductAttachmentDownload> newProductAttachmentDownload = new List<ProductAttachmentDownload>();
				IList<ProductLanguage> newProductLanguage = new List<ProductLanguage>();
				IList<ProductCategory> newProductCategory = new List<ProductCategory>();
				IList<ProductField> newProductField = new List<ProductField>();
				IList<ProductRelation> newProductRelation = new List<ProductRelation>();
				IDictionary<int,IList<ProductFieldsValue>> newProductFieldsValues = new Dictionary<int,IList<ProductFieldsValue>>();
				IDictionary<int,IList<ProductFieldsRelValue>> newProductFieldsRelValues = new Dictionary<int,IList<ProductFieldsRelValue>>();
				if(product.attachments != null && product.attachments.Count>0)
				{
					foreach(ProductAttachment k in product.attachments){					
						ProductAttachment nca = new ProductAttachment();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentProduct = k.idParentProduct;
						newProductAttachment.Add(nca);
					}
					product.attachments.Clear();							
				}
				if(product.dattachments != null && product.dattachments.Count>0)
				{
					foreach(ProductAttachmentDownload k in product.dattachments){					
						ProductAttachmentDownload nca = new ProductAttachmentDownload();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentProduct = k.idParentProduct;
						newProductAttachmentDownload.Add(nca);
					}
					product.dattachments.Clear();							
				}
				if(product.languages != null && product.languages.Count>0)
				{
					foreach(ProductLanguage k in product.languages){		
						ProductLanguage ncl = new ProductLanguage();	
						ncl.idLanguage=k.idLanguage;
						newProductLanguage.Add(ncl);
					}
					product.languages.Clear();							
				}
				if(product.categories != null && product.categories.Count>0)
				{
					foreach(ProductCategory k in product.categories){	
						ProductCategory ncc = new ProductCategory();	
						ncc.idCategory=k.idCategory;
						newProductCategory.Add(ncc);
					}
					product.categories.Clear();							
				}	
				if(product.fields != null && product.fields.Count>0)
				{
					foreach(ProductField k in product.fields){	
						ProductField ncf = new ProductField();	
						ncf.id=k.id;
						ncf.idParentProduct=k.idParentProduct;
						ncf.description=k.description;
						ncf.groupDescription=k.groupDescription;
						ncf.value=k.value;
						ncf.type=k.type;
						ncf.typeContent=k.typeContent;
						ncf.sorting=k.sorting;
						ncf.required=k.required;
						ncf.enabled=k.enabled;
						ncf.editable=k.editable;
						ncf.maxLenght=k.maxLenght;						
						newProductField.Add(ncf);
						
						//retrieve field values
						IList<ProductFieldsValue> fvalues = null;
						IQuery q = session.CreateQuery("from ProductFieldsValue where idParentField=:idParentField");	
						q.SetInt32("idParentField", k.id);
						fvalues = q.List<ProductFieldsValue>();						
						newProductFieldsValues.Add(k.id,fvalues);
						
						//retrieve field rel values
						IList<ProductFieldsRelValue> frvalues = null;
						IQuery qr = session.CreateQuery("from ProductFieldsRelValue where idParentField=:idParentField");	
						qr.SetInt32("idParentField", k.id);
						frvalues = qr.List<ProductFieldsRelValue>();
						newProductFieldsRelValues.Add(k.id,frvalues);
					}
					product.fields.Clear();							
				}
				if(product.relations != null && product.relations.Count>0)
				{
					foreach(ProductRelation k in product.relations){	
						ProductRelation ncr = new ProductRelation();	
						ncr.idProductRel=k.idProductRel;
						newProductRelation.Add(ncr);
					}
					product.relations.Clear();							
				}			
				
				product.insertDate=DateTime.Now;
				session.Save(product);			
				
				List<string> ids = new List<string>();
				if(newProductFieldsValues != null && newProductFieldsValues.Count>0){
					foreach(int fvpid in newProductFieldsValues.Keys){
						ids.Add(fvpid.ToString());
					}
					session.CreateQuery(string.Format("delete from ProductFieldsRelValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
					session.CreateQuery(string.Format("delete from ProductFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
				}

				ids = new List<string>();
				if(newProductField != null && newProductField.Count>0){
					foreach(ProductField pcid in newProductField){
						ids.Add(pcid.idParentProduct.ToString());
					}
					session.CreateQuery(string.Format("delete from ProductField where idParentProduct in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
				}

				if(newProductAttachment != null && newProductAttachment.Count>0)
				{							
					foreach(ProductAttachment k in newProductAttachment){
						if(k.idParentProduct == -1){
							k.filePath=product.id+"/";
						}	
						k.idParentProduct = product.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}

				if(newProductAttachmentDownload != null && newProductAttachmentDownload.Count>0)
				{							
					foreach(ProductAttachmentDownload k in newProductAttachmentDownload){
						if(k.idParentProduct == -1){
							k.filePath=product.id+"/";
						}	
						k.idParentProduct = product.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newProductLanguage != null && newProductLanguage.Count>0)
				{							
					foreach(ProductLanguage k in newProductLanguage){
						k.idParentProduct = product.id;
						session.Save(k);
					}
				}
				if(newProductCategory != null && newProductCategory.Count>0)
				{							
					foreach(ProductCategory k in newProductCategory){
						k.idParent = product.id;
						session.Save(k);
					}
				}
				if(newProductField != null && newProductField.Count>0)
				{
					IDictionary<int,int> fieldIds = new Dictionary<int,int>();
					
					foreach(ProductField k in newProductField){
						k.idParentProduct = product.id;
						IList<ProductFieldsValue> fnvalues = null;
						IList<ProductFieldsRelValue> frnvalues = null;		
						newProductFieldsValues.TryGetValue(k.id, out fnvalues);
						newProductFieldsRelValues.TryGetValue(k.id, out frnvalues);
						int oldid=k.id;
						fieldIds.Add(oldid,k.id);
						session.Save(k);
						fieldIds[oldid]=k.id;
				
						// add field values
						if(fnvalues != null){
							foreach(ProductFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
						
						// add field rel values
						if(frnvalues != null){
							foreach(ProductFieldsRelValue cfv in frnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ProductFieldsValue> lcfv in newProductFieldsValues.Values){
						if(lcfv != null){
							foreach(ProductFieldsValue cfv in lcfv){
								ProductFieldsValue ncfv = new ProductFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								ncfv.quantity=cfv.quantity;	
								//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}
					foreach(IList<ProductFieldsRelValue> lcfv in newProductFieldsRelValues.Values){
						if(lcfv != null){
							foreach(ProductFieldsRelValue cfv in lcfv){
								ProductFieldsRelValue ncfv = new ProductFieldsRelValue();
								ncfv.idProduct = cfv.idProduct;
								ncfv.idParentField = cfv.idParentField;
								ncfv.fieldValue = cfv.fieldValue;

								int newrefid = -1;		
								fieldIds.TryGetValue(cfv.idParentRelField, out newrefid);
								if(newrefid!=-1){
									ncfv.idParentRelField = newrefid;
								}
								ncfv.fieldRelValue = cfv.fieldRelValue;
								ncfv.fieldRelName = cfv.fieldRelName;
								ncfv.quantity=cfv.quantity;	
								//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}					
				}
				if(newProductRelation != null && newProductRelation.Count>0)
				{							
					foreach(ProductRelation k in newProductRelation){
						k.idParentProduct = product.id;
						session.Save(k);
					}
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}
		}
		
		public void update(Product product)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<ProductAttachment> newProductAttachment = new List<ProductAttachment>();
				IList<ProductAttachmentDownload> newProductAttachmentDownload = new List<ProductAttachmentDownload>();
				IList<ProductLanguage> newProductLanguage = new List<ProductLanguage>();
				IList<ProductCategory> newProductCategory = new List<ProductCategory>();
				IList<ProductField> newProductField = new List<ProductField>();
				IList<ProductRelation> newProductRelation = new List<ProductRelation>();
				IDictionary<int,IList<ProductFieldsValue>> newProductFieldsValues = new Dictionary<int,IList<ProductFieldsValue>>();
				IDictionary<int,IList<ProductFieldsRelValue>> newProductFieldsRelValues = new Dictionary<int,IList<ProductFieldsRelValue>>();
				if(product.attachments != null && product.attachments.Count>0)
				{
					foreach(ProductAttachment k in product.attachments){					
						ProductAttachment nca = new ProductAttachment();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentProduct = k.idParentProduct;	
						newProductAttachment.Add(nca);
					}
					product.attachments.Clear();							
				}
				if(product.dattachments != null && product.dattachments.Count>0)
				{
					foreach(ProductAttachmentDownload k in product.dattachments){					
						ProductAttachmentDownload nca = new ProductAttachmentDownload();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentProduct = k.idParentProduct;
						newProductAttachmentDownload.Add(nca);
					}
					product.dattachments.Clear();							
				}
				if(product.languages != null && product.languages.Count>0)
				{
					foreach(ProductLanguage k in product.languages){		
						ProductLanguage ncl = new ProductLanguage();	
						ncl.idLanguage=k.idLanguage;
						newProductLanguage.Add(ncl);
					}
					product.languages.Clear();							
				}
				if(product.categories != null && product.categories.Count>0)
				{
					foreach(ProductCategory k in product.categories){	
						ProductCategory ncc = new ProductCategory();	
						ncc.idCategory=k.idCategory;
						newProductCategory.Add(ncc);
					}
					product.categories.Clear();							
				}		
				if(product.fields != null && product.fields.Count>0)
				{
					foreach(ProductField k in product.fields){	
						ProductField ncf = new ProductField();	
						ncf.id=k.id;
						ncf.idParentProduct=k.idParentProduct;
						ncf.description=k.description;
						ncf.groupDescription=k.groupDescription;
						ncf.value=k.value;
						ncf.type=k.type;
						ncf.typeContent=k.typeContent;
						ncf.sorting=k.sorting;
						ncf.required=k.required;
						ncf.enabled=k.enabled;
						ncf.editable=k.editable;
						ncf.maxLenght=k.maxLenght;						
						newProductField.Add(ncf);
						
						//retrieve field values
						IList<ProductFieldsValue> fvalues = null;
						IQuery q = session.CreateQuery("from ProductFieldsValue where idParentField=:idParentField");	
						q.SetInt32("idParentField", k.id);
						fvalues = q.List<ProductFieldsValue>();						
						newProductFieldsValues.Add(k.id,fvalues);
						
						//retrieve field rel values
						IList<ProductFieldsRelValue> frvalues = null;
						IQuery qr = session.CreateQuery("from ProductFieldsRelValue where idParentField=:idParentField");	
						qr.SetInt32("idParentField", k.id);
						frvalues = qr.List<ProductFieldsRelValue>();
						newProductFieldsRelValues.Add(k.id,frvalues);
					}
					product.fields.Clear();							
				}
				if(product.relations != null && product.relations.Count>0)
				{
					foreach(ProductRelation k in product.relations){	
						ProductRelation ncr = new ProductRelation();	
						ncr.idProductRel=k.idProductRel;
						newProductRelation.Add(ncr);
					}
					product.relations.Clear();							
				}			
				
				session.Update(product);	
				
				session.CreateQuery("delete from ProductAttachment where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
				session.CreateQuery("delete from ProductLanguage where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
				session.CreateQuery("delete from ProductCategory where idParent=:idParent").SetInt32("idParent",product.id).ExecuteUpdate();
				List<string> ids = new List<string>();
				if(newProductFieldsValues != null && newProductFieldsValues.Count>0){
					foreach(int fvpid in newProductFieldsValues.Keys){
						ids.Add(fvpid.ToString());
					}
					session.CreateQuery(string.Format("delete from ProductFieldsRelValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
					session.CreateQuery(string.Format("delete from ProductFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();	
				}				
				session.CreateQuery("delete from ProductField where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();	
				session.CreateQuery("delete from ProductRelation where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
				
				if(newProductAttachment != null && newProductAttachment.Count>0)
				{							
					foreach(ProductAttachment k in newProductAttachment){
						if(k.idParentProduct == -1){
							k.filePath=product.id+"/";
						}	
						k.idParentProduct = product.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newProductAttachmentDownload != null && newProductAttachmentDownload.Count>0)
				{							
					foreach(ProductAttachmentDownload k in newProductAttachmentDownload){
						if(k.idParentProduct == -1){
							k.filePath=product.id+"/";
						}	
						k.idParentProduct = product.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newProductLanguage != null && newProductLanguage.Count>0)
				{							
					foreach(ProductLanguage k in newProductLanguage){
						k.idParentProduct = product.id;
						session.Save(k);
					}
				}
				if(newProductCategory != null && newProductCategory.Count>0)
				{							
					foreach(ProductCategory k in newProductCategory){
						k.idParent = product.id;
						session.Save(k);
					}
				}
				if(newProductField != null && newProductField.Count>0)
				{
					IDictionary<int,int> fieldIds = new Dictionary<int,int>();
					
					foreach(ProductField k in newProductField){
						k.idParentProduct = product.id;
						IList<ProductFieldsValue> fnvalues = null;
						IList<ProductFieldsRelValue> frnvalues = null;		
						newProductFieldsValues.TryGetValue(k.id, out fnvalues);
						newProductFieldsRelValues.TryGetValue(k.id, out frnvalues);
						int oldid=k.id;
						fieldIds.Add(oldid,k.id);
						session.Save(k);
						fieldIds[oldid]=k.id;
				
						// add field values
						if(fnvalues != null){
							foreach(ProductFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
				
						// add field rel values
						if(frnvalues != null){
							foreach(ProductFieldsRelValue cfv in frnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ProductFieldsValue> lcfv in newProductFieldsValues.Values){
						if(lcfv != null){
							foreach(ProductFieldsValue cfv in lcfv){
								ProductFieldsValue ncfv = new ProductFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								ncfv.quantity=cfv.quantity;	
								//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}
					foreach(IList<ProductFieldsRelValue> lcfv in newProductFieldsRelValues.Values){
						if(lcfv != null){
							foreach(ProductFieldsRelValue cfv in lcfv){
								ProductFieldsRelValue ncfv = new ProductFieldsRelValue();
								ncfv.idProduct = cfv.idProduct;
								ncfv.idParentField = cfv.idParentField;
								ncfv.fieldValue = cfv.fieldValue;

								int newrefid = -1;		
								fieldIds.TryGetValue(cfv.idParentRelField, out newrefid);
								if(newrefid!=-1){
									ncfv.idParentRelField = newrefid;
								}
								ncfv.fieldRelValue = cfv.fieldRelValue;
								ncfv.fieldRelName = cfv.fieldRelName;
								ncfv.quantity=cfv.quantity;	
								//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}				
				}
				if(newProductRelation != null && newProductRelation.Count>0)
				{							
					foreach(ProductRelation k in newProductRelation){
						k.idParentProduct = product.id;
						session.Save(k);
					}
				}			
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fproduct-"+product.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"+product.id))
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
			}	
		}
		
		public void delete(Product product)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(product.attachments != null && product.attachments.Count>0)
				{
					session.CreateQuery("delete from ProductAttachment where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					product.attachments.Clear();						
				}
				if(product.dattachments != null && product.dattachments.Count>0)
				{
					session.CreateQuery("delete from ProductAttachmentDownload where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					product.dattachments.Clear();						
				}	
				if(product.categories != null && product.categories.Count>0)
				{
					session.CreateQuery("delete from ProductCategory where idParent=:idParent").SetInt32("idParent",product.id).ExecuteUpdate();
					product.categories.Clear();						
				}	
				if(product.languages != null && product.languages.Count>0)
				{
					session.CreateQuery("delete from ProductLanguage where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					product.languages.Clear();						
				}	
				if(product.relations != null && product.relations.Count>0)
				{
					session.CreateQuery("delete from ProductRelation where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					product.relations.Clear();						
				}
				if(product.fields != null && product.fields.Count>0)
				{
					//session.CreateQuery("delete from ProductFieldsValue where idParentField in(select ProductField.id from ProductField where idParentProduct=:idParentProduct)").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					session.CreateSQLQuery("delete from PRODUCT_FIELDS_VALUES where id_parent_field in(select id from PRODUCT_FIELDS where id_parent_product=:idParentProduct)").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					session.CreateQuery("delete from ProductField where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
					product.fields.Clear();						
				}		
				session.CreateQuery("DELETE FROM Geolocalization WHERE idElement=:idElement").SetInt32("idElement", product.id).ExecuteUpdate();	
				session.CreateQuery("DELETE FROM ProductMainFieldTranslation WHERE idParentProduct=:idParentProduct").SetInt32("idParentProduct", product.id).ExecuteUpdate();	
				session.Delete(product);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fproduct-"+product.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"+product.id))
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
			}					
		}

		public void saveCompleteProduct(Product product, IList<Geolocalization> listOfPoints, IList<ProductMainFieldTranslation> mainFieldsTrans, IDictionary<string,string> qtyFieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					IList<ProductAttachment> newProductAttachment = new List<ProductAttachment>();
					IList<ProductAttachmentDownload> newProductAttachmentDownload = new List<ProductAttachmentDownload>();
					IList<ProductLanguage> newProductLanguage = new List<ProductLanguage>();
					IList<ProductCategory> newProductCategory = new List<ProductCategory>();
					IList<ProductField> newProductField = new List<ProductField>();
					IList<ProductRelation> newProductRelation = new List<ProductRelation>();
					IDictionary<int,IList<ProductFieldsValue>> newProductFieldsValues = new Dictionary<int,IList<ProductFieldsValue>>();
					IDictionary<int,IList<ProductFieldsRelValue>> newProductFieldsRelValues = new Dictionary<int,IList<ProductFieldsRelValue>>();
					
					if(product.id != -1){
						if(product.attachments != null && product.attachments.Count>0)
						{
							foreach(ProductAttachment k in product.attachments){					
								ProductAttachment nca = new ProductAttachment();	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;							
								nca.filePath=k.filePath;
								nca.idParentProduct = k.idParentProduct;							
								newProductAttachment.Add(nca);
							}
							product.attachments.Clear();							
						}
						//HttpContext.Current.Response.Write("product.dattachments.Count before save:"+product.dattachments.Count+"<br>");
						if(product.dattachments != null && product.dattachments.Count>0)
						{
							foreach(ProductAttachmentDownload k in product.dattachments){					
								ProductAttachmentDownload nca = new ProductAttachmentDownload();	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;							
								nca.filePath=k.filePath;
								nca.fileSize=k.fileSize;
								nca.idParentProduct = k.idParentProduct;							
								newProductAttachmentDownload.Add(nca);
							}
							product.dattachments.Clear();							
						}
						if(product.languages != null && product.languages.Count>0)
						{
							foreach(ProductLanguage k in product.languages){		
								ProductLanguage ncl = new ProductLanguage();	
								ncl.idLanguage=k.idLanguage;
								newProductLanguage.Add(ncl);
							}
							product.languages.Clear();							
						}
						if(product.categories != null && product.categories.Count>0)
						{
							foreach(ProductCategory k in product.categories){	
								ProductCategory ncc = new ProductCategory();	
								ncc.idCategory=k.idCategory;
								newProductCategory.Add(ncc);
							}
							product.categories.Clear();							
						}		
						if(product.fields != null && product.fields.Count>0)
						{
							foreach(ProductField k in product.fields){	
								ProductField ncf = new ProductField();	
								ncf.id=k.id;
								ncf.idParentProduct=k.idParentProduct;
								ncf.description=k.description;
								ncf.groupDescription=k.groupDescription;
								ncf.value=k.value;
								ncf.type=k.type;
								ncf.typeContent=k.typeContent;
								ncf.sorting=k.sorting;
								ncf.required=k.required;
								ncf.enabled=k.enabled;
								ncf.editable=k.editable;
								ncf.maxLenght=k.maxLenght;					
								newProductField.Add(ncf);
						
								//retrieve field values
								IList<ProductFieldsValue> fvalues = null;
								IQuery q = session.CreateQuery("from ProductFieldsValue where idParentField=:idParentField");	
								q.SetInt32("idParentField", k.id);
								fvalues = q.List<ProductFieldsValue>();
								if(fvalues != null && fvalues.Count>0){
									foreach(ProductFieldsValue pfv in fvalues){
										//HttpContext.Current.Response.Write("<br>- pfv:"+pfv.ToString());
										string tmpkey = new StringBuilder().Append(pfv.idParentField).Append("_").Append(pfv.value).ToString();
										//HttpContext.Current.Response.Write("<br>- tmpkey:"+tmpkey);
										try{
											if(qtyFieldValues.Keys.Contains(tmpkey)){
												//HttpContext.Current.Response.Write("<br>- tmpkey:"+tmpkey+" - quantity:"+qtyFieldValues[tmpkey]);
												pfv.quantity=Convert.ToInt32(qtyFieldValues[tmpkey]);
											}
										}catch(Exception ane){
											//HttpContext.Current.Response.Write("- error:"+ane.Message);
										}
									}
								}
								newProductFieldsValues.Add(k.id,fvalues);
						
								//retrieve field rel values
								IList<ProductFieldsRelValue> frvalues = null;
								IQuery qr = session.CreateQuery("from ProductFieldsRelValue where idParentField=:idParentField");	
								qr.SetInt32("idParentField", k.id);
								frvalues = qr.List<ProductFieldsRelValue>();
								newProductFieldsRelValues.Add(k.id,frvalues);
							}
							product.fields.Clear();							
						}
						if(product.relations != null && product.relations.Count>0)
						{
							foreach(ProductRelation k in product.relations){	
								ProductRelation ncr = new ProductRelation();	
								ncr.idProductRel=k.idProductRel;
								newProductRelation.Add(ncr);
							}
							product.relations.Clear();							
						}					
						
						session.Update(product);	
						
						session.CreateQuery("delete from ProductAttachment where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
						session.CreateQuery("delete from ProductAttachmentDownload where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
						session.CreateQuery("delete from ProductLanguage where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();
						session.CreateQuery("delete from ProductCategory where idParent=:idParent").SetInt32("idParent",product.id).ExecuteUpdate();	
						session.CreateQuery("delete from ProductRelation where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();		
						List<string> ids = new List<string>();
						if(newProductFieldsValues != null && newProductFieldsValues.Count>0){
							foreach(int fvpid in newProductFieldsValues.Keys){
								ids.Add(fvpid.ToString());
							}
							session.CreateQuery(string.Format("delete from ProductFieldsRelValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
							session.CreateQuery(string.Format("delete from ProductFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
						}
						session.CreateQuery("delete from ProductField where idParentProduct=:idParentProduct").SetInt32("idParentProduct",product.id).ExecuteUpdate();		
						
						if(newProductAttachment != null && newProductAttachment.Count>0)
						{							
							foreach(ProductAttachment k in newProductAttachment){
								if(k.idParentProduct == -1){
									k.filePath=product.id+"/";
								}	
								k.idParentProduct = product.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newProductAttachmentDownload != null && newProductAttachmentDownload.Count>0)
						{							
							foreach(ProductAttachmentDownload k in newProductAttachmentDownload){
								if(k.idParentProduct == -1){
									k.filePath=product.id+"/";
								}	
								k.idParentProduct = product.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newProductLanguage != null && newProductLanguage.Count>0)
						{							
							foreach(ProductLanguage k in newProductLanguage){
								k.idParentProduct = product.id;
								session.Save(k);
							}
						}
						if(newProductCategory != null && newProductCategory.Count>0)
						{							
							foreach(ProductCategory k in newProductCategory){
								k.idParent = product.id;
								session.Save(k);
							}
						}
						if(newProductField != null && newProductField.Count>0)
						{
							IDictionary<int,int> fieldIds = new Dictionary<int,int>();
							
							foreach(ProductField k in newProductField){
								k.idParentProduct = product.id;
								IList<ProductFieldsValue> fnvalues = null;
								IList<ProductFieldsRelValue> frnvalues = null;		
								newProductFieldsValues.TryGetValue(k.id, out fnvalues);
								newProductFieldsRelValues.TryGetValue(k.id, out frnvalues);
								int oldid=k.id;
								fieldIds.Add(oldid,k.id);
								session.Save(k);
								fieldIds[oldid]=k.id;
						
								// add field values
								if(fnvalues != null){
									foreach(ProductFieldsValue cfv in fnvalues){
										cfv.idParentField=k.id;
									}
								}
						
								// add field rel values
								if(frnvalues != null){
									foreach(ProductFieldsRelValue cfv in frnvalues){
										cfv.idParentField=k.id;
									}
								}
							}
							foreach(IList<ProductFieldsValue> lcfv in newProductFieldsValues.Values){
								if(lcfv != null){
									foreach(ProductFieldsValue cfv in lcfv){
										ProductFieldsValue ncfv = new ProductFieldsValue();
										ncfv.idParentField = cfv.idParentField;
										ncfv.value = cfv.value;
										ncfv.sorting = cfv.sorting;
										ncfv.quantity=cfv.quantity;	
										//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}
							foreach(IList<ProductFieldsRelValue> lcfv in newProductFieldsRelValues.Values){
								if(lcfv != null){
									foreach(ProductFieldsRelValue cfv in lcfv){
										ProductFieldsRelValue ncfv = new ProductFieldsRelValue();
										ncfv.idProduct = cfv.idProduct;
										ncfv.idParentField = cfv.idParentField;
										ncfv.fieldValue = cfv.fieldValue;

										int newrefid = -1;		
										fieldIds.TryGetValue(cfv.idParentRelField, out newrefid);
										if(newrefid!=-1){
											ncfv.idParentRelField = newrefid;
										}
										ncfv.fieldRelValue = cfv.fieldRelValue;
										ncfv.fieldRelName = cfv.fieldRelName;
										ncfv.quantity=cfv.quantity;	
										//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}
						}
						if(newProductRelation != null && newProductRelation.Count>0)
						{							
							foreach(ProductRelation k in newProductRelation){
								k.idParentProduct = product.id;
								session.Save(k);
							}
						}		
					}else{
						if(product.attachments != null && product.attachments.Count>0)
						{
							foreach(ProductAttachment k in product.attachments){					
								ProductAttachment nca = new ProductAttachment();	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;								
								nca.filePath=k.filePath;
								nca.idParentProduct = k.idParentProduct;		
								newProductAttachment.Add(nca);
							}
							product.attachments.Clear();							
						}
						if(product.dattachments != null && product.dattachments.Count>0)
						{
							foreach(ProductAttachmentDownload k in product.dattachments){					
								ProductAttachmentDownload nca = new ProductAttachmentDownload();	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;								
								nca.filePath=k.filePath;
								nca.fileSize=k.fileSize;
								nca.idParentProduct = k.idParentProduct;		
								newProductAttachmentDownload.Add(nca);
							}
							product.dattachments.Clear();							
						}
						if(product.languages != null && product.languages.Count>0)
						{
							foreach(ProductLanguage k in product.languages){		
								ProductLanguage ncl = new ProductLanguage();	
								ncl.idLanguage=k.idLanguage;
								newProductLanguage.Add(ncl);
							}
							product.languages.Clear();							
						}
						if(product.categories != null && product.categories.Count>0)
						{
							foreach(ProductCategory k in product.categories){	
								ProductCategory ncc = new ProductCategory();	
								ncc.idCategory=k.idCategory;
								newProductCategory.Add(ncc);
							}
							product.categories.Clear();							
						}	
						//HttpContext.Current.Response.Write("new product --> (product.fields != null):"+(product.fields != null)+" -count:"+product.fields.Count+"<br>");	
						if(product.fields != null && product.fields.Count>0)
						{
							//HttpContext.Current.Response.Write("new product --> product.fields.Count:"+product.fields.Count+"<br>");	
							foreach(ProductField k in product.fields){	
								ProductField ncf = new ProductField();	
								ncf.id=k.id;
								ncf.idParentProduct=k.idParentProduct;
								ncf.description=k.description;
								ncf.groupDescription=k.groupDescription;
								ncf.value=k.value;
								ncf.type=k.type;
								ncf.typeContent=k.typeContent;
								ncf.sorting=k.sorting;
								ncf.required=k.required;
								ncf.enabled=k.enabled;
								ncf.editable=k.editable;
								ncf.maxLenght=k.maxLenght;						
								newProductField.Add(ncf);
								//HttpContext.Current.Response.Write("new product --> ProductField:"+ncf.ToString()+"<br>");	
						
								//retrieve field values
								IList<ProductFieldsValue> fvalues = null;
								IQuery q = session.CreateQuery("from ProductFieldsValue where idParentField=:idParentField");	
								q.SetInt32("idParentField", k.id);
								fvalues = q.List<ProductFieldsValue>();
								if(fvalues != null && fvalues.Count>0){
									foreach(ProductFieldsValue pfv in fvalues){
										string tmpkey = new StringBuilder().Append(pfv.idParentField).Append("_").Append(pfv.value).ToString();
										try{
											if(qtyFieldValues.Keys.Contains(tmpkey)){
												pfv.quantity=Convert.ToInt32(qtyFieldValues[tmpkey]);
											}
										}catch(Exception ane){
											//HttpContext.Current.Response.Write("- error:"+ane.Message);
										}
									}
								}								
								newProductFieldsValues.Add(k.id,fvalues);	
						
								//retrieve field rel values
								IList<ProductFieldsRelValue> frvalues = null;
								IQuery qr = session.CreateQuery("from ProductFieldsRelValue where idParentField=:idParentField");	
								qr.SetInt32("idParentField", k.id);
								frvalues = qr.List<ProductFieldsRelValue>();
								newProductFieldsRelValues.Add(k.id,frvalues);						
							}
							product.fields.Clear();							
						}
						if(product.relations != null && product.relations.Count>0)
						{
							foreach(ProductRelation k in product.relations){	
								ProductRelation ncr = new ProductRelation();	
								ncr.idProductRel=k.idProductRel;
								newProductRelation.Add(ncr);
							}
							product.relations.Clear();							
						}				
						
						product.insertDate=DateTime.Now;
						session.Save(product);	

						List<string> ids = new List<string>();
						if(newProductField != null && newProductField.Count>0){
							foreach(ProductField pcid in newProductField){
								ids.Add(pcid.idParentProduct.ToString());
							}
							session.CreateQuery(string.Format("delete from ProductField where idParentProduct in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
						}						
						
						ids = new List<string>();
						if(newProductFieldsValues != null && newProductFieldsValues.Count>0){
							foreach(int fvpid in newProductFieldsValues.Keys){
								ids.Add(fvpid.ToString());
							}
							session.CreateQuery(string.Format("delete from ProductFieldsRelValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
							session.CreateQuery(string.Format("delete from ProductFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();	
						}
						
						if(newProductAttachment != null && newProductAttachment.Count>0)
						{							
							foreach(ProductAttachment k in newProductAttachment){
								if(k.idParentProduct == -1){
									k.filePath=product.id+"/";
								}	
								k.idParentProduct = product.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}						
						if(newProductAttachmentDownload != null && newProductAttachmentDownload.Count>0)
						{							
							foreach(ProductAttachmentDownload k in newProductAttachmentDownload){
								if(k.idParentProduct == -1){
									k.filePath=product.id+"/";
								}	
								k.idParentProduct = product.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newProductLanguage != null && newProductLanguage.Count>0)
						{							
							foreach(ProductLanguage k in newProductLanguage){
								k.idParentProduct = product.id;
								session.Save(k);
							}
						}
						if(newProductCategory != null && newProductCategory.Count>0)
						{							
							foreach(ProductCategory k in newProductCategory){
								k.idParent = product.id;
								session.Save(k);
							}
						}
						if(newProductField != null && newProductField.Count>0)
						{	
							IDictionary<int,int> fieldIds = new Dictionary<int,int>();
							
							foreach(ProductField k in newProductField){
								k.idParentProduct = product.id;
								IList<ProductFieldsValue> fnvalues = null;
								IList<ProductFieldsRelValue> frnvalues = null;		
								newProductFieldsValues.TryGetValue(k.id, out fnvalues);
								newProductFieldsRelValues.TryGetValue(k.id, out frnvalues);
								int oldid=k.id;
								fieldIds.Add(oldid,k.id);
								session.Save(k);
								fieldIds[oldid]=k.id;
						
								// add field values
								if(fnvalues != null){
									foreach(ProductFieldsValue cfv in fnvalues){
										cfv.idParentField=k.id;
									}
								}
						
								// add field rel values
								if(frnvalues != null){
									foreach(ProductFieldsRelValue cfv in frnvalues){
										cfv.idParentField=k.id;
									}
								}
							}
							foreach(IList<ProductFieldsValue> lcfv in newProductFieldsValues.Values){
								if(lcfv != null){
									foreach(ProductFieldsValue cfv in lcfv){
										ProductFieldsValue ncfv = new ProductFieldsValue();
										ncfv.idParentField = cfv.idParentField;
										ncfv.value = cfv.value;
										ncfv.sorting = cfv.sorting;
										ncfv.quantity=cfv.quantity;	
										//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}
							foreach(IList<ProductFieldsRelValue> lcfv in newProductFieldsRelValues.Values){
								if(lcfv != null){
									foreach(ProductFieldsRelValue cfv in lcfv){
										ProductFieldsRelValue ncfv = new ProductFieldsRelValue();
										ncfv.idProduct = cfv.idProduct;
										ncfv.idParentField = cfv.idParentField;
										ncfv.fieldValue = cfv.fieldValue;

										int newrefid = -1;		
										fieldIds.TryGetValue(cfv.idParentRelField, out newrefid);
										if(newrefid!=-1){
											ncfv.idParentRelField = newrefid;
										}
										ncfv.fieldRelValue = cfv.fieldRelValue;
										ncfv.fieldRelName = cfv.fieldRelName;
										ncfv.quantity=cfv.quantity;	
										//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}						
						}
						if(newProductRelation != null && newProductRelation.Count>0)
						{							
							foreach(ProductRelation k in newProductRelation){
								k.idParentProduct = product.id;
								session.Save(k);
							}
						}
					}					
					
					//*
					//* aggiorno le localizzazioni se sono state inserite prima di salvare il contenuto
					//*
					foreach(Geolocalization q in listOfPoints)
					{
						q.idElement=product.id;
						session.Update(q);
					}		
					
					//*
					//* aggiorno i campi multilingu se sono stati inseriti prima di salvare il contenuto
					//*					
					foreach(ProductMainFieldTranslation m in mainFieldsTrans)
					{	
						//session.Delete(m);
						m.idParentProduct=product.id;
						session.Update(m);
						//session.Save(m);
					}										
					// ************** AGGIUNGO TGUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione, meta_xxx ecc
					foreach (MultiLanguage mu in deltranslactions){
						session.Delete(mu);
					}
					foreach (MultiLanguage mu in updtranslactions){
						session.SaveOrUpdate(mu);
					}
					foreach (MultiLanguage mi in newtranslactions){
						session.Save(mi);
					}
					
					tx.Commit();
					NHibernateHelper.closeSession();
				}catch(Exception exx){
					//HttpContext.Current.Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fproduct-"+product.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"+product.id))
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
			}
		}		
		
		public Product clone(Product original)
		{
			Product newproduct = new Product();
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				newproduct.name = original.name;
				newproduct.summary = original.summary;
				newproduct.description = original.description;
				newproduct.keyword = original.keyword;
				newproduct.status = 0;
				newproduct.pageTitle = original.pageTitle;
				newproduct.metaKeyword = original.metaKeyword;
				newproduct.metaDescription = original.metaDescription;
				newproduct.userId = original.userId;
				newproduct.publishDate = original.publishDate;
				newproduct.deleteDate = original.deleteDate;
				newproduct.attachments = new List<ProductAttachment>();
				newproduct.categories = new List<ProductCategory>();
				newproduct.languages = new List<ProductLanguage>();
				newproduct.price = original.price;
				newproduct.discount = original.discount;
				newproduct.quantity = original.quantity;
				newproduct.setBuyQta = original.setBuyQta;
				newproduct.prodType = original.prodType;
				newproduct.idSupplement = original.idSupplement;
				newproduct.idSupplementGroup = original.idSupplementGroup;
				newproduct.maxDownload = original.maxDownload;
				newproduct.maxDownloadTime = original.maxDownloadTime;
				newproduct.quantityRotationMode = original.quantityRotationMode;
				newproduct.rotationModeValue = original.rotationModeValue;
				newproduct.reloadQuantity = original.reloadQuantity;

				IList<ProductAttachment> newProductAttachment = new List<ProductAttachment>();
				IList<ProductAttachmentDownload> newProductAttachmentDownload = new List<ProductAttachmentDownload>();
				IList<ProductLanguage> newProductLanguage = new List<ProductLanguage>();
				IList<ProductCategory> newProductCategory = new List<ProductCategory>();
				IList<ProductField> newProductField = new List<ProductField>();
				IList<ProductRelation> newProductRelation = new List<ProductRelation>();
				IDictionary<int,IList<ProductFieldsValue>> newProductFieldsValues = new Dictionary<int,IList<ProductFieldsValue>>();
							
				// ** insert attachments copy
				if(original.attachments != null){
					foreach(ProductAttachment oca in original.attachments)
					{
						ProductAttachment nca = new ProductAttachment();	
						nca.fileName=oca.fileName;
						nca.filePath=oca.filePath;
						nca.contentType=oca.contentType;
						nca.fileDida=oca.fileDida;
						nca.fileLabel=oca.fileLabel;
						newProductAttachment.Add(nca);
					}
				}
							
				// ** insert attachments download copy
				if(original.dattachments != null){
					foreach(ProductAttachmentDownload oca in original.dattachments)
					{
						ProductAttachmentDownload nca = new ProductAttachmentDownload();	
						nca.fileName=oca.fileName;
						nca.filePath=oca.filePath;
						nca.contentType=oca.contentType;
						nca.fileDida=oca.fileDida;
						nca.fileLabel=oca.fileLabel;
						newProductAttachmentDownload.Add(nca);
					}
				}
				
				// ** insert category copy
				if(original.categories != null){
					foreach(ProductCategory occ in original.categories)
					{
						ProductCategory ncc = new ProductCategory();	
						ncc.idCategory=occ.idCategory;
						newProductCategory.Add(ncc);
					}
				}

				// ** insert language copy
				if(original.languages != null){
					foreach(ProductLanguage ocl in original.languages)
					{
						ProductLanguage ncl = new ProductLanguage();	
						ncl.idLanguage=ocl.idLanguage;
						newProductLanguage.Add(ncl);
					}
				}
							
				// ** insert attachments copy
				if(original.fields != null){
					foreach(ProductField ocf in original.fields)
					{
						ProductField ncf = new ProductField();	
						ncf.id=ocf.id;
						ncf.idParentProduct=ocf.idParentProduct;
						ncf.description=ocf.description;
						ncf.groupDescription=ocf.groupDescription;
						ncf.value=ocf.value;
						ncf.type=ocf.type;
						ncf.typeContent=ocf.typeContent;
						ncf.sorting=ocf.sorting;
						ncf.required=ocf.required;
						ncf.enabled=ocf.enabled;
						ncf.editable=ocf.editable;
						ncf.maxLenght=ocf.maxLenght;			
						newProductField.Add(ncf);
						
						//retrieve field values
						IList<ProductFieldsValue> fvalues = null;
						IQuery qcfv = session.CreateQuery("from ProductFieldsValue where idParentField=:idParentField");	
						qcfv.SetInt32("idParentField", ocf.id);
						fvalues = qcfv.List<ProductFieldsValue>();						
						newProductFieldsValues.Add(ocf.id,fvalues);
					}
				}

				// ** insert prod relations copy
				if(original.relations != null){
					foreach(ProductRelation ocl in original.relations)
					{
						ProductRelation ncr = new ProductRelation();	
						ncr.idProductRel=ocl.idProductRel;
						newProductRelation.Add(ncr);
					}
				}
				
				newproduct.insertDate=DateTime.Now;
				session.Save(newproduct);	

				if(newProductAttachment != null)
				{
					foreach (ProductAttachment k in newProductAttachment)
					{
						k.idParentProduct = newproduct.id;
						k.filePath=k.filePath.Replace(original.id+"/",newproduct.id+"/");
						k.insertDate=DateTime.Now;
						session.Save(k);
					} 
				}
				if(newProductAttachmentDownload != null)
				{
					foreach (ProductAttachmentDownload k in newProductAttachmentDownload)
					{
						k.idParentProduct = newproduct.id;
						k.filePath=k.filePath.Replace(original.id+"/",newproduct.id+"/");
						k.insertDate=DateTime.Now;
						session.Save(k);
					} 
				}
				if(newProductCategory != null)
				{
					foreach (ProductCategory k in newProductCategory)
					{
						k.idParent = newproduct.id;
						session.Save(k);
					} 
				}	
				if(newProductLanguage != null)
				{
					foreach (ProductLanguage k in newProductLanguage)
					{
						k.idParentProduct = newproduct.id;
						session.Save(k);
					} 
				}
				if(newProductField != null)
				{						
					foreach(ProductField k in newProductField){
						k.idParentProduct = newproduct.id;
						IList<ProductFieldsValue> fnvalues = null;		
						newProductFieldsValues.TryGetValue(k.id, out fnvalues);
						session.Save(k);
				
						// add field values
						if(fnvalues != null){
							foreach(ProductFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ProductFieldsValue> lcfv in newProductFieldsValues.Values){
						if(lcfv != null){
							foreach(ProductFieldsValue cfv in lcfv){
								ProductFieldsValue ncfv = new ProductFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								ncfv.quantity=cfv.quantity;	
								//HttpContext.Current.Response.Write("ProductFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}	
				}
				if(newProductRelation != null && newProductRelation.Count>0)
				{							
					foreach(ProductRelation k in newProductRelation){
						k.idParentProduct = newproduct.id;
						session.Save(k);
					}
				}

				// ** insert geolocalization copy
				IList<Geolocalization> geolocs = null;
				IQuery q = session.CreateQuery("from Geolocalization where idElement=:idElement and type=2");	
				q.SetInt32("idElement", original.id);
				geolocs = q.List<Geolocalization>();			
				
				if(geolocs!=null)
				{
					foreach(Geolocalization gl in geolocs)
					{
						Geolocalization ng = new Geolocalization();
						ng.idElement = newproduct.id;
						ng.type = gl.type;
						ng.latitude = gl.latitude;
						ng.longitude = gl.longitude;
						ng.txtInfo = gl.txtInfo;
						session.Save(ng);						
					}
				}

				// ** insert mainfield trans copy
				IList<ProductMainFieldTranslation> mainfieldtrans = null;
				IQuery w = session.CreateQuery("from ProductMainFieldTranslation where idParentProduct=:idParentProduct");	
				w.SetInt32("idParentProduct", original.id);
				mainfieldtrans = w.List<ProductMainFieldTranslation>();			
				
				if(mainfieldtrans!=null)
				{
					foreach(ProductMainFieldTranslation mfl in mainfieldtrans)
					{
						ProductMainFieldTranslation pt = new ProductMainFieldTranslation();
						pt.idParentProduct = newproduct.id;
						pt.mainField = mfl.mainField;
						pt.langCode = mfl.langCode;
						pt.value = mfl.value;
						session.Save(pt);						
					}
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
			}	
			
			return newproduct;
		}
		
		public Product getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public Product getByIdCached(int id, bool cached)
		{
			Product product = null;	
			
			if(cached)
			{
				product = (Product)HttpContext.Current.Cache.Get("fproduct-"+id);
				if(product != null){
					return product;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				product = session.Get<Product>(id);
				
				product.attachments = session.CreateCriteria(typeof(ProductAttachment))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentProduct", product.id))
				.List<ProductAttachment>();
				
				product.dattachments = session.CreateCriteria(typeof(ProductAttachmentDownload))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentProduct", product.id))
				.List<ProductAttachmentDownload>();

				product.languages = session.CreateCriteria(typeof(ProductLanguage))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentProduct", product.id))
				.List<ProductLanguage>();		

				product.categories = session.CreateCriteria(typeof(ProductCategory))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParent", product.id))
				.List<ProductCategory>();			

				product.fields = session.CreateCriteria(typeof(ProductField))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentProduct", product.id))
				.AddOrder(Order.Asc("sorting"))
				.List<ProductField>();		

				product.relations = session.CreateCriteria(typeof(ProductRelation))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentProduct", product.id))
				.List<ProductRelation>();					

				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(product == null){
					product = new Product();
					product.id=-1;
				}
				HttpContext.Current.Cache.Insert("fproduct-"+product.id, product, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return product;
		}

		public IList<Product> find(string name, string keyword, string status, int userId, string prodType, string qryRotationMode, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool withProdRel, bool cached)
		{
			IList<Product> results = null;
			List<string> idsCat = new List<string>();
			List<string> idsLang = new List<string>();
			
			// first check on categories and languages
			if (matchCategories != null && matchCategories.Count > 0){
				foreach(int c in matchCategories){
					idsCat.Add(c.ToString());
				}						
			}
			if (matchLanguages != null && matchLanguages.Count > 0){
				foreach(int c in matchLanguages){
					idsLang.Add(c.ToString());
				}						
			}
			string idsCatC = "";
			if(idsCat.Count>0){
				idsCatC = string.Format("{0}",string.Join(",",idsCat.ToArray()));
			}
			string idsLangC = "";
			if(idsLang.Count>0){
				idsLangC = string.Format("{0}",string.Join(",",idsLang.ToArray()));
			}
			
			StringBuilder cacheKey = new StringBuilder("list-fproduct")
			.Append("-").Append(Utils.encodeTo64(name))
			.Append("-").Append(Utils.encodeTo64(keyword))
			.Append("-").Append(status)
			.Append("-").Append(prodType)
			.Append("-").Append(Utils.encodeTo64(publishDate))
			.Append("-").Append(Utils.encodeTo64(deleteDate))
			.Append("-").Append(orderBy)
			.Append("-").Append(idsCatC)
			.Append("-").Append(idsLangC);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<Product>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from Product where 1=1";

			// check on categories and languages
			if(idsCat.Count>0){strSQL+=string.Format(" and id in(select idParent from ProductCategory where idCategory in({0}))",string.Join(",",idsCat.ToArray()));}
			if(idsLang.Count>0){strSQL+=string.Format(" and id in(select idParentProduct from ProductLanguage where idLanguage in({0}))",string.Join(",",idsLang.ToArray()));}
			
			if (!String.IsNullOrEmpty(name)){			
				strSQL += " and name=:name";
			}
			
			if (!String.IsNullOrEmpty(keyword)){			
				strSQL += " and keyword like:keyword";
			}
			
			if (!String.IsNullOrEmpty(status)){			
				List<string> ids = new List<string>();
				string[] tstatus = status.Split(',');
				foreach(string r in tstatus){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and status in({0})",string.Join(",",ids.ToArray()));}
			}
			
			if (userId > 0){			
				strSQL += " and userId=:userId";
			}
			
			if (!String.IsNullOrEmpty(prodType)){			
				List<string> ids = new List<string>();
				string[] tprodType = prodType.Split(',');
				foreach(string r in tprodType){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and prodType in({0})",string.Join(",",ids.ToArray()));}
			}

			if (!String.IsNullOrEmpty(qryRotationMode)){			
				List<string> ids = new List<string>();
				string[] tqtyrm = qryRotationMode.Split(',');
				foreach(string r in tqtyrm){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and quantityRotationMode in({0})",string.Join(",",ids.ToArray()));}
			}

			if (!String.IsNullOrEmpty(publishDate)){
				strSQL += " and publishDate <= :publishDate";
			}

			if (!String.IsNullOrEmpty(deleteDate)){
				strSQL += " and deleteDate >= :deleteDate";
			}
			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by name asc";
				break;
			    case 2:
				strSQL +=" order by name desc";
				break;
			    case 3:
				strSQL +=" order by summary asc";
				break;
			    case 4:
				strSQL +=" order by summary desc";
				break;
			    case 5:
				strSQL +=" order by keyword asc";
				break;
			    case 6:
				strSQL +=" order by keyword desc";
				break;
			    case 7:
				strSQL +=" order by publishDate asc";
				break;
			    case 8:
				strSQL +=" order by publishDate desc";
				break;
			    case 9:
				strSQL +=" order by status asc";
				break;
			    case 10:
				strSQL +=" order by status desc";
				break;
			    case 11:
				strSQL +=" order by price asc";
				break;
			    case 12:
				strSQL +=" order by price desc";
				break;
			    case 13:
				strSQL +=" order by prodType asc";
				break;
			    case 14:
				strSQL +=" order by prodType desc";
				break;
			    default:
				strSQL +=" order by name asc";
				break;
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (!String.IsNullOrEmpty(name)){
						q.SetString("name", name);
					}
					if (!String.IsNullOrEmpty(keyword)){
						q.SetString("keyword", String.Format("%{0}%", keyword));
					}
					if (userId > 0){
						q.SetInt32("userId", Convert.ToInt32(userId));
					}
					if (publishDate != null){
						q.SetDateTime("publishDate", Convert.ToDateTime(publishDate));
					}
					if (deleteDate != null){
						q.SetDateTime("deleteDate", Convert.ToDateTime(deleteDate));
					}
					results = q.List<Product>();

					if(results != null){
						foreach(Product product in results){							
							if(withAttach){
								product.attachments = session.CreateCriteria(typeof(ProductAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductAttachment>();
								
								//******* attachment download type
								product.dattachments = session.CreateCriteria(typeof(ProductAttachmentDownload))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductAttachmentDownload>();
							}
	
							if(withLang){
								product.languages = session.CreateCriteria(typeof(ProductLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductLanguage>();		
							}
	
							if(withCats){
								product.categories = session.CreateCriteria(typeof(ProductCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParent", product.id))
								.List<ProductCategory>();
							}			

							if(withFields){
								product.fields = session.CreateCriteria(typeof(ProductField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.AddOrder(Order.Asc("sorting"))
								.List<ProductField>();	
							}	
	
							if(withProdRel){
								product.relations = session.CreateCriteria(typeof(ProductRelation))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductRelation>();		
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

			if(cached)
			{
				if(results == null){
					results = new List<Product>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}

		public IList<Product> find(string name, string keyword, string status, int userId, string prodType, string qryRotationMode, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool withProdRel, int pageIndex, int pageSize,out long totalCount)
		{
			IList<Product> products = null;		
			totalCount = 0;	
			string strSQL = "from Product where 1=1";

			// first check on categories and languages
			if (matchCategories != null && matchCategories.Count > 0){
				List<string> ids = new List<string>();
				foreach(int c in matchCategories){
					ids.Add(c.ToString());
				}						
				if(ids.Count>0){strSQL+=string.Format(" and id in(select idParent from ProductCategory where idCategory in({0}))",string.Join(",",ids.ToArray()));}
			}
			
			if (matchLanguages != null && matchLanguages.Count > 0){
				List<string> ids = new List<string>();
				foreach(int c in matchLanguages){
					ids.Add(c.ToString());
				}						
				if(ids.Count>0){strSQL+=string.Format(" and id in(select idParentProduct from ProductLanguage where idLanguage in({0}))",string.Join(",",ids.ToArray()));}
			}
			
			if (!String.IsNullOrEmpty(name)){			
				strSQL += " and name=:name";
			}
			
			if (!String.IsNullOrEmpty(keyword)){			
				strSQL += " and keyword like:keyword";
			}
			
			if (!String.IsNullOrEmpty(status)){			
				List<string> ids = new List<string>();
				string[] tstatus = status.Split(',');
				foreach(string r in tstatus){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and status in({0})",string.Join(",",ids.ToArray()));}
			}
			
			if (userId > 0){			
				strSQL += " and userId=:userId";
			}
			
			if (!String.IsNullOrEmpty(prodType)){			
				List<string> ids = new List<string>();
				string[] tprodType = prodType.Split(',');
				foreach(string r in tprodType){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and prodType in({0})",string.Join(",",ids.ToArray()));}
			}

			if (!String.IsNullOrEmpty(qryRotationMode)){			
				List<string> ids = new List<string>();
				string[] tqtyrm = qryRotationMode.Split(',');
				foreach(string r in tqtyrm){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and quantityRotationMode in({0})",string.Join(",",ids.ToArray()));}
			}

			if (!String.IsNullOrEmpty(publishDate)){
				strSQL += " and publishDate <= :publishDate";
			}

			if (!String.IsNullOrEmpty(deleteDate)){
				strSQL += " and deleteDate >= :deleteDate";
			}

			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by name asc";
				break;
			    case 2:
				strSQL +=" order by name desc";
				break;
			    case 3:
				strSQL +=" order by summary asc";
				break;
			    case 4:
				strSQL +=" order by summary desc";
				break;
			    case 5:
				strSQL +=" order by keyword asc";
				break;
			    case 6:
				strSQL +=" order by keyword desc";
				break;
			    case 7:
				strSQL +=" order by publishDate asc";
				break;
			    case 8:
				strSQL +=" order by publishDate desc";
				break;
			    case 9:
				strSQL +=" order by status asc";
				break;
			    case 10:
				strSQL +=" order by status desc";
				break;
			    case 11:
				strSQL +=" order by price asc";
				break;
			    case 12:
				strSQL +=" order by price desc";
				break;
			    case 13:
				strSQL +=" order by prodType asc";
				break;
			    case 14:
				strSQL +=" order by prodType desc";
				break;
			    default:
				strSQL +=" order by name asc";
				break;
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL:"+strSQL+"<br>");	
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (!String.IsNullOrEmpty(name)){
						q.SetString("name", name);
						qCount.SetString("name", name);
					}
					if (!String.IsNullOrEmpty(keyword)){
						q.SetString("keyword", String.Format("%{0}%", keyword));
						qCount.SetString("keyword", String.Format("%{0}%", keyword));
					}
					if (userId > 0){
						q.SetInt32("userId", Convert.ToInt32(userId));
						qCount.SetInt32("userId", Convert.ToInt32(userId));
					}
					if (publishDate != null){
						q.SetDateTime("publishDate", Convert.ToDateTime(publishDate));
						qCount.SetDateTime("publishDate", Convert.ToDateTime(publishDate));
					}
					if (deleteDate != null){
						q.SetDateTime("deleteDate", Convert.ToDateTime(deleteDate));
						qCount.SetDateTime("deleteDate", Convert.ToDateTime(deleteDate));
					}
					products = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);

					if(products != null){
						foreach(Product product in products){							
							if(withAttach){
								product.attachments = session.CreateCriteria(typeof(ProductAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductAttachment>();
								
								//******* attachment download type
								product.dattachments = session.CreateCriteria(typeof(ProductAttachmentDownload))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductAttachmentDownload>();
							}
	
							if(withLang){
								product.languages = session.CreateCriteria(typeof(ProductLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductLanguage>();	
							}
	
							if(withCats){
								product.categories = session.CreateCriteria(typeof(ProductCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParent", product.id))
								.List<ProductCategory>();
							}		

							if(withFields){
								product.fields = session.CreateCriteria(typeof(ProductField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.AddOrder(Order.Asc("sorting"))
								.List<ProductField>();	
							}		
	
							if(withProdRel){
								product.relations = session.CreateCriteria(typeof(ProductRelation))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentProduct", product.id))
								.List<ProductRelation>();		
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
			
			return products;		
		}
	
		protected IList<Product> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<Product> records = new List<Product>();	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				IList recordstmp = (IList)results[0];
				totalCount = (long)((IList)results[1])[0];

				if(recordstmp != null)
				{
					foreach(Object tmp in recordstmp)
					{
						records.Add((Product)tmp);
					}
				}
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: RETURN NULL
			}
			return records;
		}	
		

		public void changeQuantity(int idProduct, int quantity)
		{
			try{
				using (ISession session = NHibernateHelper.getCurrentSession())
				using (ITransaction tx = session.BeginTransaction())
				{
					session.CreateQuery("update Product set quantity=:quantity where id=:id").SetInt32("quantity",quantity).SetInt32("id",idProduct).ExecuteUpdate();	
					tx.Commit();
					NHibernateHelper.closeSession();
				}
			
				//rimuovo cache		
				IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
				while (CacheEnum.MoveNext())
				{		  
					string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
					if(cacheKey.Contains("fproduct-"+idProduct))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					}
					else if(cacheKey.Contains("list-field-fproduct-"+idProduct))
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
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}			
		}
		
		public IList<ProductAttachment> getProductAttachments(int idProduct)
		{
			IList<ProductAttachment> attachments = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductAttachment where id_parent_product= :id_product");
				q.SetInt32("id_product",idProduct);	
				attachments = q.List<ProductAttachment>();
				NHibernateHelper.closeSession();					
			}	
			return attachments;		
		}	
		

		public ProductAttachment getProductAttachmentById(int idAttach)
		{
			ProductAttachment result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductAttachment where id=:id_attach");
				q.SetInt32("id_attach",idAttach);	
				result = q.UniqueResult<ProductAttachment>();
				NHibernateHelper.closeSession();					
			}	
			return result;		
		}
		
		public void deleteProductAttachment(int idAttach)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductAttachment where id=:id_attach").SetInt32("id_attach",idAttach).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		

		public IList<ProductAttachmentDownload> getProductAttachmentDownloads(int idProduct)
		{
			IList<ProductAttachmentDownload> attachments = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductAttachmentDownload where id_parent_product= :id_product");
				q.SetInt32("id_product",idProduct);	
				attachments = q.List<ProductAttachmentDownload>();
				NHibernateHelper.closeSession();					
			}	
			return attachments;		
		}	
		

		public ProductAttachmentDownload getProductAttachmentDownloadById(int idAttach)
		{
			ProductAttachmentDownload result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductAttachmentDownload where id=:id_attach");
				q.SetInt32("id_attach",idAttach);	
				result = q.UniqueResult<ProductAttachmentDownload>();
				NHibernateHelper.closeSession();					
			}	
			return result;		
		}
		
		public void deleteProductAttachmentDownload(int idAttach)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductAttachmentDownload where id=:id_attach").SetInt32("id_attach",idAttach).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}	
		
	
		public IList<ProductAttachmentLabel> getProductAttachmentLabel()
		{
			return getProductAttachmentLabelCached(false);
		}
	
		public IList<ProductAttachmentLabel> getProductAttachmentLabelCached(bool cached)
		{
			IList<ProductAttachmentLabel> results = null;
			
			if(cached)
			{
				results = (IList<ProductAttachmentLabel>)HttpContext.Current.Cache.Get("fproduct-attachments-label");
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductAttachmentLabel order by description asc");
				results = q.List<ProductAttachmentLabel>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ProductAttachmentLabel>();
				}
				HttpContext.Current.Cache.Insert("fproduct-attachments-label", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}
		
		public void deleteProductAttachmentLabel(int idAttachLabel)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductAttachmentLabel where id=:id_label").SetInt32("id_label",idAttachLabel).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("fproduct-attachments-label");
		}	
		
		public ProductAttachmentLabel insertProductAttachmentLabel(string newdescription)
		{
			ProductAttachmentLabel entry = new ProductAttachmentLabel();
			entry.description=newdescription;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(entry);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("fproduct-attachments-label");
			return entry;
		}			

		public IList<ProductLanguage> getProductLanguages(int idProduct)
		{
			IList<ProductLanguage> languages = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductLanguage where id_parent_product= :id_product");
				q.SetInt32("id_product",idProduct);	
				languages = q.List<ProductLanguage>();
				NHibernateHelper.closeSession();					
			}	
			return languages;		
		}					

		public IList<ProductCategory> getProductCategories(int idProduct)
		{
			IList<ProductCategory> categories = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductCategory where id_parent_product= :id_product");
				q.SetInt32("id_product",idProduct);	
				categories = q.List<ProductCategory>();
				NHibernateHelper.closeSession();					
			}	
			return categories;		
		}
		
		/*PRODUCT FIELDS METHODS*/
	
		public ProductField getProductFieldById(int idField)
		{
			return getProductFieldByIdCached(idField, false);
		}
	
		public ProductField getProductFieldByIdCached(int idField, bool cached)
		{
			ProductField result = null;
			StringBuilder cacheKey = new StringBuilder("field-fproduct-").Append(idField);
				
			if(cached)
			{
				result = (ProductField)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(result != null){
					return result;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				result = session.Get<ProductField>(idField);
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new ProductField();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return result;		
		}
	
		public IList<ProductField> getProductFields(int idProduct, string active, string common)
		{
			return getProductFieldsCached(idProduct, active, false, common);
		}
	
		public IList<ProductField> getProductFieldsCached(int idProduct, string active, bool cached, string common)
		{
			IList<ProductField> results = null;
			StringBuilder cacheKey = new StringBuilder("list-field-fproduct-").Append(idProduct).Append("-").Append(active).Append("-").Append(common);
				
			if(cached)
			{
				results = (IList<ProductField>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from ProductField  where 1=1";
				if(idProduct!=-1){
				sql += " and id_parent_product= :id_product";
				}
				if(!String.IsNullOrEmpty(active)){
				sql += " and enabled= :enabled";
				}
				if(!String.IsNullOrEmpty(common)){
				sql += " and common= :common";
				}
				sql += " order by sorting, groupDescription, description asc";
				IQuery q = session.CreateQuery(sql);
				if(idProduct!=-1){
				q.SetInt32("id_product",idProduct);	
				}
				if(!String.IsNullOrEmpty(active)){
				q.SetBoolean("enabled",Convert.ToBoolean(active));	
				}
				if(!String.IsNullOrEmpty(common)){
				q.SetBoolean("common",Convert.ToBoolean(common));	
				}
				results = q.List<ProductField>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ProductField>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}
	
		public ProductFieldsValue getProductFieldValue(int idField, string value)
		{
			return getProductFieldValueCached(idField, value, false);
		}
	
		public ProductFieldsValue getProductFieldValueCached(int idField, string value, bool cached)
		{
			ProductFieldsValue result = null;	

			StringBuilder cacheKey = new StringBuilder("field-value-").Append(idField).Append("-").Append(value);
				
			if(cached)
			{
				result = (ProductFieldsValue)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(result != null){
					return result;
				}
			}
										
			string strSQL = "from ProductFieldsValue where idParentField=:idParentField and value=:value order by sorting asc";		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);	
				q.SetInt32("idParentField",idField);		
				q.SetString("value",value);				
				result = q.UniqueResult<ProductFieldsValue>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new ProductFieldsValue();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return result;	
		}
	
		public IList<ProductFieldsValue> getProductFieldValues(int idField)
		{
			return getProductFieldValuesCached(idField, false);
		}
	
		public IList<ProductFieldsValue> getProductFieldValuesCached(int idField, bool cached)
		{
			IList<ProductFieldsValue> results = null;	

			StringBuilder cacheKey = new StringBuilder("list-field-values-").Append(idField);
				
			if(cached)
			{
				results = (IList<ProductFieldsValue>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
										
			string strSQL = "from ProductFieldsValue where idParentField=:idParentField order by sorting asc";		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);	
				q.SetInt32("idParentField",idField);			
				results = q.List<ProductFieldsValue>();		
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ProductFieldsValue>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;	
		}
	
		public IList<string> getProductFieldValuesByDescription(string description, string common, string active)
		{
			return getProductFieldValuesByDescriptionCached(description, false, common, active);
		}
	
		public IList<string> getProductFieldValuesByDescriptionCached(string description, bool cached, string common, string active)
		{
			IList values = null;
			IList<string> results = null;	

			StringBuilder cacheKey = new StringBuilder("list-field-name-values-").Append(description);
				
			if(cached)
			{
				results = (IList<string>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			string strSQL = "select distinct value from PRODUCT_FIELDS where description=:description and not isnull(value) and trim(value)<>''";			
			
			if(!String.IsNullOrEmpty(common)){
			strSQL += " and common= :common";
			}			
			if(!String.IsNullOrEmpty(active)){
			strSQL += " and enabled= :enabled";
			}
			strSQL += " order by value asc";
				
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("value", NHibernateUtil.String);
				q.SetString("description",description);
				if(!String.IsNullOrEmpty(common)){
				q.SetBoolean("common",Convert.ToBoolean(common));	
				}	
				if(!String.IsNullOrEmpty(active)){
				q.SetBoolean("enabled",Convert.ToBoolean(active));	
				}			
				values = q.List();			
				NHibernateHelper.closeSession();
			}				
			if(values!=null)
			{
				results = new List<string>();
				foreach(string x in values)
				{					
					results.Add(x);
				}
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<string>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;	
		}

		public void saveCompleteProductField(ProductField field, IList<ProductFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(field.id != -1){
						session.Update(field);
						session.CreateQuery("delete from ProductFieldsValue where idParentField=:idParentField").SetInt32("idParentField",field.id).ExecuteUpdate();
					}else{
						session.Save(field);
					}											
					// ************** AGGIUNGO i values se presenti
					foreach (ProductFieldsValue cfv in fieldValues){
						cfv.idParentField =field.id; 
						session.Save(cfv);
					}					
					// ************** AGGIUNGO TGUTTE LE CHIAVI MULTILINGUA PER LE TRADUZIONI DI descrizione, meta_xxx ecc
					foreach (MultiLanguage mu in deltranslactions){
						session.Delete(mu);
					}
					foreach (MultiLanguage mu in updtranslactions){
						session.SaveOrUpdate(mu);
					}
					foreach (MultiLanguage mi in newtranslactions){
						session.Save(mi);
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
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-fproduct-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("field-fproduct-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}   
				else if(cacheKey.Contains("field-value-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-values-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
			}				
		}
		
		public void updateProductField(ProductField field)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Update(field);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fproduct-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}    
				else if(cacheKey.Contains("field-value-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-values-"+field.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}   
			}
		}
		
		public void deleteProductField(int idField)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{	session.CreateQuery("delete from ProductFieldsRelValue where idParentField=:idParentField").SetInt32("idParentField",idField).ExecuteUpdate();
				session.CreateQuery("delete from ProductFieldsRelValue where idParentRelField=:idParentRelField").SetInt32("idParentRelField",idField).ExecuteUpdate();
				session.CreateQuery("delete from ProductFieldsValue where idParentField=:idParentField").SetInt32("idParentField",idField).ExecuteUpdate();
				session.CreateQuery("delete from ProductField where id=:id").SetInt32("id",idField).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fproduct-"+idField))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}    
				else if(cacheKey.Contains("field-value-"+idField))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-values-"+idField))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fieldres-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}
		}
		
		public void deleteProductFieldValue(int idField, string fieldValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductFieldsRelValue where idParentField=:idParentField").SetInt32("idParentField",idField).ExecuteUpdate();
				session.CreateQuery("delete from ProductFieldsRelValue where idParentRelField=:idParentRelField").SetInt32("idParentRelField",idField).ExecuteUpdate();
				session.CreateQuery("delete from ProductFieldsValue where idParentField=:idParentField and value=:value").SetInt32("idParentField",idField).SetString("value",fieldValue).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-field-fproduct-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}      
				else if(cacheKey.Contains("field-value-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fproduct-"))
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
				else if(cacheKey.Contains("list-fieldres-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
			}
		}

		public IList<ProductFieldsRelValue> getProductFieldRelValues(int idProduct, int idField, string fieldValue)
		{
			return getProductFieldRelValuesCached(idProduct, idField, fieldValue, false);
		}
	
		public IList<ProductFieldsRelValue> getProductFieldRelValuesCached(int idProduct, int idField, string fieldValue, bool cached)
		{
			IList<ProductFieldsRelValue> results = null;	

			StringBuilder cacheKey = new StringBuilder("list-fieldres-values-").Append(idProduct).Append("-").Append(idField).Append("-").Append(fieldValue);
				
			if(cached)
			{
				results = (IList<ProductFieldsRelValue>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
										
			string strSQL = "from ProductFieldsRelValue where idProduct=:idProduct and idParentField=:idParentField and fieldValue=:fieldValue order by fieldRelValue asc";		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);	
				q.SetInt32("idProduct",idProduct);		
				q.SetInt32("idParentField",idField);	
				q.SetString("fieldValue",fieldValue);		
				results = q.List<ProductFieldsRelValue>();		
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ProductFieldsRelValue>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;	
		}

		
		public void insertProductFieldRelValue(int idProduct, int idField, string fieldValue, int idFieldRel, string fieldRelValue, int quantity, string fieldDesc)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductFieldsRelValue where idProduct=:idProduct and idParentField=:idParentField and fieldValue=:fieldValue and idParentRelField=:idParentRelField and fieldRelValue=:fieldRelValue")
				.SetInt32("idProduct",idProduct)
				.SetInt32("idParentField",idField)
				.SetString("fieldValue",fieldValue)
				.SetInt32("idParentRelField",idFieldRel)
				.SetString("fieldRelValue",fieldRelValue)
				.ExecuteUpdate();
				
				ProductFieldsRelValue newPFRV = new ProductFieldsRelValue();
				newPFRV.idProduct = idProduct;
				newPFRV.idParentField = idField;
				newPFRV.fieldValue = fieldValue;
				newPFRV.idParentRelField = idFieldRel;
				newPFRV.fieldRelValue = fieldRelValue;
				newPFRV.fieldRelName = fieldDesc;
				newPFRV.quantity = quantity;
				
				session.Save(newPFRV);					
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-field-fproduct-"))
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
				else if(cacheKey.Contains("list-fieldres-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}		
		}		
		
		public void deleteProductFieldRelValue(int idProduct, int idField, string fieldValue, int idFieldRel, string fieldRelValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductFieldsRelValue where idProduct=:idProduct and idParentField=:idParentField and fieldValue=:fieldValue and idParentRelField=:idParentRelField and fieldRelValue=:fieldRelValue")
				.SetInt32("idProduct",idProduct)
				.SetInt32("idParentField",idField)
				.SetString("fieldValue",fieldValue)
				.SetInt32("idParentRelField",idFieldRel)
				.SetString("fieldRelValue",fieldRelValue)
				.ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fproduct"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-field-fproduct-"))
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
				else if(cacheKey.Contains("list-fieldres-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
			}			
		}
		
		public IList<string> findFieldNames()
		{
			IList names = null;
			IList<string> results = null;					
			string strSQL = "select distinct description from PRODUCT_FIELDS where not isnull(description)";				
			strSQL+=" order by description asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("description", NHibernateUtil.String);						
				names = q.List();			
				NHibernateHelper.closeSession();
			}				
			if(names!=null)
			{
				results = new List<string>();
				foreach(string x in names)
				{					
					results.Add(x);
				}
			}
			return results;	
		}
	
		public IList<string> findFieldGroupNames()
		{
			IList gnames = null;
			IList<string> results = null;					
			string strSQL = "select distinct group_description from PRODUCT_FIELDS where not isnull(group_description)";			
			strSQL+=" order by group_description asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("group_description", NHibernateUtil.String);						
				gnames = q.List();		
				NHibernateHelper.closeSession();
			}				
			if(gnames!=null)
			{
				results = new List<string>();
				foreach(string x in gnames)
				{					
					results.Add(x);
				}
			}
			return results;	
		}
		
		/*MAIN FIELDS TRANSACTION*/
		
		public ProductMainFieldTranslation getMainFieldTranslation(int idProd, int mainField , string langCode, bool useDef, string defVal)
		{
			return getMainFieldTranslationCached(idProd, mainField, langCode, useDef, defVal, false);
		}
	
		public ProductMainFieldTranslation getMainFieldTranslationCached(int idProd, int mainField , string langCode, bool useDef, string defVal, bool cached)
		{
			ProductMainFieldTranslation result = null;
			StringBuilder cacheKey = new StringBuilder("mainfield-fproduct-").Append(idProd).Append("-").Append(mainField).Append("-").Append(langCode);
				
			if(cached)
			{
				result = (ProductMainFieldTranslation)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(result != null){
					//HttpContext.Current.Response.Write("cache result.value: ###"+result.value+"###<br>");	
					return result;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductMainFieldTranslation where idParentProduct=:idParentProduct and mainField=:mainField and langCode=:langCode");
				q.SetInt32("idParentProduct",idProd);	
				q.SetInt32("mainField",mainField);
				q.SetString("langCode",langCode);
				result = q.UniqueResult<ProductMainFieldTranslation>();
				NHibernateHelper.closeSession();
			}
			
			if(result == null){
				result = new ProductMainFieldTranslation();
			}
			
			if(cached)
			{
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			// check for using default value
			if(String.IsNullOrEmpty(result.value) && useDef){
				result.value = defVal;					
			}
			//HttpContext.Current.Response.Write("get result.value: ###"+result.value+"###<br>");
			return result;		
		}
	
		public IList<ProductMainFieldTranslation> getProductMainFieldsTranslation(int idProd, int mainField , string langCode)
		{
			return getProductMainFieldsTranslationCached(idProd, mainField, langCode, false);
		}
	
		public IList<ProductMainFieldTranslation> getProductMainFieldsTranslationCached(int idProd, int mainField , string langCode, bool cached)
		{
			IList<ProductMainFieldTranslation> results = null;	

			StringBuilder cacheKey = new StringBuilder("list-mainfield-fproduct-").Append(idProd).Append("-").Append(mainField).Append("-").Append(langCode);
				
			if(cached)
			{
				results = (IList<ProductMainFieldTranslation>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			string strSQL = "from ProductMainFieldTranslation where idParentProduct=:idParentProduct";			
			
			if(mainField >0){
			strSQL += " and mainField= :mainField";
			}			
			if(!String.IsNullOrEmpty(langCode)){
			strSQL += " and langCode= :langCode";
			}
			strSQL += " order by mainField asc";
				
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idParentProduct",idProd);
				if(mainField >0){
				q.SetInt32("mainField",mainField);
				}	
				if(!String.IsNullOrEmpty(langCode)){
				q.SetString("langCode",langCode);
				}			
				results = q.List<ProductMainFieldTranslation>();			
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ProductMainFieldTranslation>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;	
		}

		public void saveMainFieldTranslation(ProductMainFieldTranslation pmft, int idProd, int mainField, string langCode)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					session.CreateQuery("delete from ProductMainFieldTranslation where idParentProduct=:idParentProduct and mainField=:mainField and langCode=:langCode").SetInt32("idParentProduct",idProd).SetInt32("mainField",mainField).SetString("langCode",langCode).ExecuteUpdate();
					session.Save(pmft);
					tx.Commit();
					NHibernateHelper.closeSession();
				}catch(Exception exx){
					//Response.Write("An inner error occured: " + exx.Message);
					tx.Rollback();
					NHibernateHelper.closeSession();
					throw;					
				}
			}	
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fproduct-"+idProd))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fproduct-"+idProd))
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
				else if(cacheKey.Contains("mainfield-fproduct-"+idProd))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-mainfield-fproduct-"+idProd))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}				
			}				
		}	
		
		//*********** Manage product quantity rotation
		public ProductRotation getProductRotation(int idProd, int rotationMode)
		{
			ProductRotation result = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ProductRotation where idParent=:idParent and idRotationMode=:idRotationMode order by lastUpdate desc");
				q.SetInt32("idParent",idProd);	
				q.SetInt32("idRotationMode",rotationMode);
				result = q.UniqueResult<ProductRotation>();
				NHibernateHelper.closeSession();
			}
			
			return result;				
		}
		
		public void insertProductRotation(ProductRotation rotation)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(rotation);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
		}
		
		public void deleteProductRotation(int idParent, int idRotation)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductRotation where idParent=:idParent and idRotationMode=:idRotationMode").SetInt32("idParent",idParent).SetInt32("idRotationMode",idRotation).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
		}	
		
		public void deleteProductRotationByProd(int idParent)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ProductRotation where idParent=:idParent").SetInt32("idParent",idParent).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}			
		}

		public void saveCompleteProductRotation(int idParent, int reloadQuantity, ProductRotation rotation)
		{
			try{
				using (ISession session = NHibernateHelper.getCurrentSession())
				using (ITransaction tx = session.BeginTransaction())
				{
					session.CreateQuery("update Product set quantity=:quantity where id=:id").SetInt32("quantity",reloadQuantity).SetInt32("id",idParent).ExecuteUpdate();	
					session.CreateQuery("delete from ProductRotation where idParent=:idParent").SetInt32("idParent",idParent).ExecuteUpdate();
					session.Save(rotation);
					tx.Commit();
					NHibernateHelper.closeSession();
				}
			
				//rimuovo cache		
				IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
				while (CacheEnum.MoveNext())
				{		  
					string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
					if(cacheKey.Contains("fproduct-"+idParent))
					{ 
						HttpContext.Current.Cache.Remove(cacheKey);
					}
					else if(cacheKey.Contains("list-field-fproduct-"+idParent))
					{
						HttpContext.Current.Cache.Remove(cacheKey);
					} 
					else if(cacheKey.Contains("list-fproduct"))
					{
						HttpContext.Current.Cache.Remove(cacheKey);
					}    
					else if(cacheKey.Contains("field-value-"))
					{
						HttpContext.Current.Cache.Remove(cacheKey);
					} 
					else if(cacheKey.Contains("field-fproduct-"))
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
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}		
		}		
	}
}