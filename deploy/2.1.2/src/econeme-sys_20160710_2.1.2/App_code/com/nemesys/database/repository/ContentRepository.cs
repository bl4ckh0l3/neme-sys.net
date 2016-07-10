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
	public class ContentRepository : IContentRepository
	{		
		public void insert(FContent content)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{			
				IList<ContentAttachment> newContentAttachment = new List<ContentAttachment>();
				IList<ContentLanguage> newContentLanguage = new List<ContentLanguage>();
				IList<ContentCategory> newContentCategory = new List<ContentCategory>();
				IList<ContentField> newContentField = new List<ContentField>();
				IDictionary<int,IList<ContentFieldsValue>> newContentFieldsValues = new Dictionary<int,IList<ContentFieldsValue>>();
				if(content.attachments != null && content.attachments.Count>0)
				{
					foreach(ContentAttachment k in content.attachments){					
						ContentAttachment nca = new ContentAttachment();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentContent = k.idParentContent;
						newContentAttachment.Add(nca);
					}
					content.attachments.Clear();							
				}
				if(content.languages != null && content.languages.Count>0)
				{
					foreach(ContentLanguage k in content.languages){		
						ContentLanguage ncl = new ContentLanguage();	
						ncl.idLanguage=k.idLanguage;
						newContentLanguage.Add(ncl);
					}
					content.languages.Clear();							
				}
				if(content.categories != null && content.categories.Count>0)
				{
					foreach(ContentCategory k in content.categories){	
						ContentCategory ncc = new ContentCategory();	
						ncc.idCategory=k.idCategory;
						newContentCategory.Add(ncc);
					}
					content.categories.Clear();							
				}	
				if(content.fields != null && content.fields.Count>0)
				{
					foreach(ContentField k in content.fields){	
						ContentField ncf = new ContentField();	
						ncf.id=k.id;
						ncf.idParentContent=k.idParentContent;
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
						newContentField.Add(ncf);
						
						//retrieve field values
						IList<ContentFieldsValue> fvalues = null;
						IQuery q = session.CreateQuery("from ContentFieldsValue where idParentField=:idParentField");	
						q.SetInt32("idParentField", k.id);
						fvalues = q.List<ContentFieldsValue>();						
						newContentFieldsValues.Add(k.id,fvalues);
					}
					content.fields.Clear();							
				}			
				
				content.insertDate=DateTime.Now;
				session.Save(content);			
				
				List<string> ids = new List<string>();
				if(newContentFieldsValues != null && newContentFieldsValues.Count>0){
					foreach(int fvpid in newContentFieldsValues.Keys){
						ids.Add(fvpid.ToString());
					}
					session.CreateQuery(string.Format("delete from ContentFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
				}

				ids = new List<string>();
				/*if(newContentField != null && newContentField.Count>0){
					foreach(ContentField pcid in newContentField){
						ids.Add(pcid.idParentContent.ToString());
					}
					session.CreateQuery(string.Format("delete from ContentField where idParentContent in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();		
				}*/

				if(newContentAttachment != null && newContentAttachment.Count>0)
				{							
					foreach(ContentAttachment k in newContentAttachment){
						if(k.idParentContent == -1){
							k.filePath=content.id+"/";
						}	
						k.idParentContent = content.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newContentLanguage != null && newContentLanguage.Count>0)
				{							
					foreach(ContentLanguage k in newContentLanguage){
						k.idParentContent = content.id;
						session.Save(k);
					}
				}
				if(newContentCategory != null && newContentCategory.Count>0)
				{							
					foreach(ContentCategory k in newContentCategory){
						k.idParent = content.id;
						session.Save(k);
					}
				}
				if(newContentField != null && newContentField.Count>0)
				{							
					foreach(ContentField k in newContentField){
						k.idParentContent = content.id;
						IList<ContentFieldsValue> fnvalues = null;		
						newContentFieldsValues.TryGetValue(k.id, out fnvalues);
						if(k.id>0){
							session.Update(k);
						}else{
							session.Save(k);
						}
				
						// add field values
						if(fnvalues != null){
							foreach(ContentFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ContentFieldsValue> lcfv in newContentFieldsValues.Values){
						if(lcfv != null){
							foreach(ContentFieldsValue cfv in lcfv){
								ContentFieldsValue ncfv = new ContentFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								//HttpContext.Current.Response.Write("ContentFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
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
				if(cacheKey.Contains("list-fcontent"))
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
		
		public void update(FContent content)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<ContentAttachment> newContentAttachment = new List<ContentAttachment>();
				IList<ContentLanguage> newContentLanguage = new List<ContentLanguage>();
				IList<ContentCategory> newContentCategory = new List<ContentCategory>();
				IList<ContentField> newContentField = new List<ContentField>();
				IDictionary<int,IList<ContentFieldsValue>> newContentFieldsValues = new Dictionary<int,IList<ContentFieldsValue>>();
				if(content.attachments != null && content.attachments.Count>0)
				{
					foreach(ContentAttachment k in content.attachments){					
						ContentAttachment nca = new ContentAttachment();		
						nca.id=k.id;
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.idParentContent = k.idParentContent;	
						newContentAttachment.Add(nca);
					}
					content.attachments.Clear();							
				}
				if(content.languages != null && content.languages.Count>0)
				{
					foreach(ContentLanguage k in content.languages){		
						ContentLanguage ncl = new ContentLanguage();	
						ncl.idLanguage=k.idLanguage;
						newContentLanguage.Add(ncl);
					}
					content.languages.Clear();							
				}
				if(content.categories != null && content.categories.Count>0)
				{
					foreach(ContentCategory k in content.categories){	
						ContentCategory ncc = new ContentCategory();	
						ncc.idCategory=k.idCategory;
						newContentCategory.Add(ncc);
					}
					content.categories.Clear();							
				}		
				if(content.fields != null && content.fields.Count>0)
				{
					foreach(ContentField k in content.fields){	
						ContentField ncf = new ContentField();	
						ncf.id=k.id;
						ncf.idParentContent=k.idParentContent;
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
						newContentField.Add(ncf);
						
						//retrieve field values
						IList<ContentFieldsValue> fvalues = null;
						IQuery q = session.CreateQuery("from ContentFieldsValue where idParentField=:idParentField");	
						q.SetInt32("idParentField", k.id);
						fvalues = q.List<ContentFieldsValue>();						
						newContentFieldsValues.Add(k.id,fvalues);
					}
					content.fields.Clear();							
				}			
				
				session.Update(content);	
				
				//session.CreateQuery("delete from ContentAttachment where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
				session.CreateQuery("delete from ContentLanguage where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
				session.CreateQuery("delete from ContentCategory where idParent=:idParent").SetInt32("idParent",content.id).ExecuteUpdate();
				List<string> ids = new List<string>();
				if(newContentFieldsValues != null && newContentFieldsValues.Count>0){
					foreach(int fvpid in newContentFieldsValues.Keys){
						ids.Add(fvpid.ToString());
					}
					session.CreateQuery(string.Format("delete from ContentFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();	
				}				
				//session.CreateQuery("delete from ContentField where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();	
				
				if(newContentAttachment != null && newContentAttachment.Count>0)
				{							
					foreach(ContentAttachment k in newContentAttachment){
						if(k.idParentContent == -1){
							k.filePath=content.id+"/";
						}	
						k.idParentContent = content.id;
						k.insertDate=DateTime.Now;
						if(k.id>0){
							session.Update(k);
						}else{
							session.Save(k);
						}
					}
				}
				if(newContentLanguage != null && newContentLanguage.Count>0)
				{							
					foreach(ContentLanguage k in newContentLanguage){
						k.idParentContent = content.id;
						session.Save(k);
					}
				}
				if(newContentCategory != null && newContentCategory.Count>0)
				{							
					foreach(ContentCategory k in newContentCategory){
						k.idParent = content.id;
						session.Save(k);
					}
				}
				if(newContentField != null && newContentField.Count>0)
				{					
					foreach(ContentField k in newContentField){
						k.idParentContent = content.id;
						IList<ContentFieldsValue> fnvalues = null;		
						newContentFieldsValues.TryGetValue(k.id, out fnvalues);
						if(k.id>0){
							session.Update(k);
						}else{
							session.Save(k);
						}
				
						// add field values
						if(fnvalues != null){
							foreach(ContentFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ContentFieldsValue> lcfv in newContentFieldsValues.Values){
						if(lcfv != null){
							foreach(ContentFieldsValue cfv in lcfv){
								ContentFieldsValue ncfv = new ContentFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								//HttpContext.Current.Response.Write("ContentFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
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
				if(cacheKey.Contains("fcontent-"+content.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fcontent-"+content.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fcontent"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("field-fcontent-"))
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
		
		public void delete(FContent content)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				if(content.attachments != null && content.attachments.Count>0)
				{
					session.CreateQuery("delete from ContentAttachment where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
					content.attachments.Clear();						
				}	
				if(content.categories != null && content.categories.Count>0)
				{
					session.CreateQuery("delete from ContentCategory where idParent=:idParent").SetInt32("idParent",content.id).ExecuteUpdate();
					content.categories.Clear();						
				}	
				if(content.languages != null && content.languages.Count>0)
				{
					session.CreateQuery("delete from ContentLanguage where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
					content.languages.Clear();						
				}
				if(content.fields != null && content.fields.Count>0)
				{
					//session.CreateQuery("delete from ContentFieldsValue where idParentField in(select ContentField.id from ContentField where idParentContent=:idParentContent)").SetInt32("idParentContent",content.id).ExecuteUpdate();
					session.CreateSQLQuery("delete from CONTENT_FIELDS_VALUES where id_field in(select id from CONTENT_FIELDS where id_parent_content=:idParentContent)").SetInt32("idParentContent",content.id).ExecuteUpdate();
					session.CreateQuery("delete from ContentField where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
					content.fields.Clear();						
				}		
				session.CreateQuery("DELETE FROM Geolocalization WHERE idElement=:idElement").SetInt32("idElement", content.id).ExecuteUpdate();	
				session.Delete(content);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("fcontent-"+content.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fcontent-"+content.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fcontent"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fcontent-"))
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

		public void saveCompleteContent(FContent content, IList<Geolocalization> listOfPoints)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					IList<ContentAttachment> newContentAttachment = new List<ContentAttachment>();
					IList<ContentLanguage> newContentLanguage = new List<ContentLanguage>();
					IList<ContentCategory> newContentCategory = new List<ContentCategory>();
					IList<ContentField> newContentField = new List<ContentField>();
					IDictionary<int,IList<ContentFieldsValue>> newContentFieldsValues = new Dictionary<int,IList<ContentFieldsValue>>();
					
					if(content.id != -1){
						if(content.attachments != null && content.attachments.Count>0)
						{
							foreach(ContentAttachment k in content.attachments){					
								ContentAttachment nca = new ContentAttachment();	
								nca.id=k.id;	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;							
								nca.filePath=k.filePath;
								nca.idParentContent = k.idParentContent;							
								newContentAttachment.Add(nca);
							}
							content.attachments.Clear();							
						}
						if(content.languages != null && content.languages.Count>0)
						{
							foreach(ContentLanguage k in content.languages){		
								ContentLanguage ncl = new ContentLanguage();	
								ncl.idLanguage=k.idLanguage;
								newContentLanguage.Add(ncl);
							}
							content.languages.Clear();							
						}
						if(content.categories != null && content.categories.Count>0)
						{
							foreach(ContentCategory k in content.categories){	
								ContentCategory ncc = new ContentCategory();	
								ncc.idCategory=k.idCategory;
								newContentCategory.Add(ncc);
							}
							content.categories.Clear();							
						}		
						if(content.fields != null && content.fields.Count>0)
						{
							foreach(ContentField k in content.fields){	
								ContentField ncf = new ContentField();	
								ncf.id=k.id;
								ncf.idParentContent=k.idParentContent;
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
								newContentField.Add(ncf);
						
								//retrieve field values
								IList<ContentFieldsValue> fvalues = null;
								IQuery q = session.CreateQuery("from ContentFieldsValue where idParentField=:idParentField");	
								q.SetInt32("idParentField", k.id);
								fvalues = q.List<ContentFieldsValue>();						
								newContentFieldsValues.Add(k.id,fvalues);
							}
							content.fields.Clear();							
						}					
						
						//HttpContext.Current.Response.Write("<br>content before update: " + content.ToString());
						session.Update(content);	
						//HttpContext.Current.Response.Write("<br>content after update: " + content.ToString());
						
						//session.CreateQuery("delete from ContentAttachment where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
						session.CreateQuery("delete from ContentLanguage where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();
						session.CreateQuery("delete from ContentCategory where idParent=:idParent").SetInt32("idParent",content.id).ExecuteUpdate();			
						List<string> ids = new List<string>();
						if(newContentFieldsValues != null && newContentFieldsValues.Count>0){
							foreach(int fvpid in newContentFieldsValues.Keys){
								ids.Add(fvpid.ToString());
							}
							session.CreateQuery(string.Format("delete from ContentFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
						}
						//session.CreateQuery("delete from ContentField where idParentContent=:idParentContent").SetInt32("idParentContent",content.id).ExecuteUpdate();		
						
						if(newContentAttachment != null && newContentAttachment.Count>0)
						{							
							foreach(ContentAttachment k in newContentAttachment){
								if(k.idParentContent == -1){
									k.filePath=content.id+"/";
								}	
								k.idParentContent = content.id;
								k.insertDate=DateTime.Now;
								if(k.id>0){
									session.Update(k);
								}else{
									session.Save(k);
								}
							}
						}
						if(newContentLanguage != null && newContentLanguage.Count>0)
						{							
							foreach(ContentLanguage k in newContentLanguage){
								k.idParentContent = content.id;
								session.Save(k);
							}
						}
						if(newContentCategory != null && newContentCategory.Count>0)
						{							
							foreach(ContentCategory k in newContentCategory){
								k.idParent = content.id;
								session.Save(k);
							}
						}
						if(newContentField != null && newContentField.Count>0)
						{					
							foreach(ContentField k in newContentField){
								k.idParentContent = content.id;
								IList<ContentFieldsValue> fnvalues = null;		
								newContentFieldsValues.TryGetValue(k.id, out fnvalues);
								if(k.id>0){
									session.Update(k);
								}else{
									session.Save(k);
								}
						
								// add field values
								if(fnvalues != null){
									foreach(ContentFieldsValue cfv in fnvalues){
										cfv.idParentField=k.id;
									}
								}
							}
							foreach(IList<ContentFieldsValue> lcfv in newContentFieldsValues.Values){
								if(lcfv != null){
									foreach(ContentFieldsValue cfv in lcfv){
										ContentFieldsValue ncfv = new ContentFieldsValue();
										ncfv.idParentField = cfv.idParentField;
										ncfv.value = cfv.value;
										ncfv.sorting = cfv.sorting;
										//HttpContext.Current.Response.Write("ContentFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}
						}		
					}else{
						if(content.attachments != null && content.attachments.Count>0)
						{
							foreach(ContentAttachment k in content.attachments){					
								ContentAttachment nca = new ContentAttachment();	
								nca.fileName=k.fileName;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;								
								nca.filePath=k.filePath;
								nca.idParentContent = k.idParentContent;		
								newContentAttachment.Add(nca);
							}
							content.attachments.Clear();							
						}
						if(content.languages != null && content.languages.Count>0)
						{
							foreach(ContentLanguage k in content.languages){		
								ContentLanguage ncl = new ContentLanguage();	
								ncl.idLanguage=k.idLanguage;
								newContentLanguage.Add(ncl);
							}
							content.languages.Clear();							
						}
						if(content.categories != null && content.categories.Count>0)
						{
							foreach(ContentCategory k in content.categories){	
								ContentCategory ncc = new ContentCategory();	
								ncc.idCategory=k.idCategory;
								newContentCategory.Add(ncc);
							}
							content.categories.Clear();							
						}	
						//HttpContext.Current.Response.Write("new content --> (content.fields != null):"+(content.fields != null)+" -count:"+content.fields.Count+"<br>");	
						if(content.fields != null && content.fields.Count>0)
						{
							//HttpContext.Current.Response.Write("new content --> content.fields.Count:"+content.fields.Count+"<br>");	
							foreach(ContentField k in content.fields){	
								ContentField ncf = new ContentField();	
								ncf.id=k.id;
								ncf.idParentContent=k.idParentContent;
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
								newContentField.Add(ncf);
								//HttpContext.Current.Response.Write("new content --> ContentField:"+ncf.ToString()+"<br>");	
						
								//retrieve field values
								IList<ContentFieldsValue> fvalues = null;
								IQuery q = session.CreateQuery("from ContentFieldsValue where idParentField=:idParentField");	
								q.SetInt32("idParentField", k.id);
								fvalues = q.List<ContentFieldsValue>();						
								newContentFieldsValues.Add(k.id,fvalues);
								//HttpContext.Current.Response.Write("newContentFieldsValues.Count:"+newContentFieldsValues.Count+"<br>");								
							}
							content.fields.Clear();							
						}				
						
						content.insertDate=DateTime.Now;
						session.Save(content);	

						List<string> ids = new List<string>();
						/*if(newContentField != null && newContentField.Count>0){
							foreach(ContentField pcid in newContentField){
								ids.Add(pcid.idParentContent.ToString());
							}
							session.CreateQuery(string.Format("delete from ContentField where idParentContent in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();
						}*/						
						
						ids = new List<string>();
						if(newContentFieldsValues != null && newContentFieldsValues.Count>0){
							foreach(int fvpid in newContentFieldsValues.Keys){
								ids.Add(fvpid.ToString());
							}
							session.CreateQuery(string.Format("delete from ContentFieldsValue where idParentField in ({0})",string.Join(",",ids.ToArray()))).ExecuteUpdate();	
						}
						
						if(newContentAttachment != null && newContentAttachment.Count>0)
						{							
							foreach(ContentAttachment k in newContentAttachment){
								if(k.idParentContent == -1){
									k.filePath=content.id+"/";
								}	
								k.idParentContent = content.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newContentLanguage != null && newContentLanguage.Count>0)
						{							
							foreach(ContentLanguage k in newContentLanguage){
								k.idParentContent = content.id;
								session.Save(k);
							}
						}
						if(newContentCategory != null && newContentCategory.Count>0)
						{							
							foreach(ContentCategory k in newContentCategory){
								k.idParent = content.id;
								session.Save(k);
							}
						}
						if(newContentField != null && newContentField.Count>0)
						{							
							foreach(ContentField k in newContentField){
								k.idParentContent = content.id;
								IList<ContentFieldsValue> fnvalues = null;		
								newContentFieldsValues.TryGetValue(k.id, out fnvalues);
								//HttpContext.Current.Response.Write("ContentField before save:"+k.ToString()+"<br>");
								if(k.id>0){
									session.Update(k);
								}else{
									session.Save(k);
								}
						
								// add field values
								if(fnvalues != null){
									foreach(ContentFieldsValue cfv in fnvalues){
										cfv.idParentField=k.id;
									}
								}
							}
							foreach(IList<ContentFieldsValue> lcfv in newContentFieldsValues.Values){
								if(lcfv != null){
									foreach(ContentFieldsValue cfv in lcfv){
										ContentFieldsValue ncfv = new ContentFieldsValue();
										ncfv.idParentField = cfv.idParentField;
										ncfv.value = cfv.value;
										ncfv.sorting = cfv.sorting;
										//HttpContext.Current.Response.Write("ContentFieldsValue before save:"+ncfv.ToString()+"<br>");
										session.Save(ncfv);
									}
								}
							}						
						}
					}	
					
					//*
					//* aggiorno le localizzazioni se sono state inserite prima di salvare il contenuto
					//*
					foreach(Geolocalization q in listOfPoints)
					{
						q.idElement=content.id;
						session.Update(q);
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
				if(cacheKey.Contains("fcontent-"+content.id))
				{ 
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fcontent-"+content.id))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-fcontent"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fcontent-"))
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
		
		public FContent clone(FContent original)
		{
			FContent newcontent = new FContent();
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				newcontent.title = original.title;
				newcontent.summary = original.summary;
				newcontent.description = original.description;
				newcontent.keyword = original.keyword;
				newcontent.status = 0;
				newcontent.pageTitle = original.pageTitle;
				newcontent.metaKeyword = original.metaKeyword;
				newcontent.metaDescription = original.metaDescription;
				newcontent.userId = original.userId;
				newcontent.publishDate = original.publishDate;
				newcontent.deleteDate = original.deleteDate;
				newcontent.attachments = new List<ContentAttachment>();
				newcontent.categories = new List<ContentCategory>();
				newcontent.languages = new List<ContentLanguage>();

				IList<ContentAttachment> newContentAttachment = new List<ContentAttachment>();
				IList<ContentLanguage> newContentLanguage = new List<ContentLanguage>();
				IList<ContentCategory> newContentCategory = new List<ContentCategory>();
				IList<ContentField> newContentField = new List<ContentField>();
				IDictionary<int,IList<ContentFieldsValue>> newContentFieldsValues = new Dictionary<int,IList<ContentFieldsValue>>();
							
				// ** insert attachments copy
				if(original.attachments != null){
					foreach(ContentAttachment oca in original.attachments)
					{
						ContentAttachment nca = new ContentAttachment();	
						nca.fileName=oca.fileName;
						nca.filePath=oca.filePath;
						nca.contentType=oca.contentType;
						nca.fileDida=oca.fileDida;
						nca.fileLabel=oca.fileLabel;
						newContentAttachment.Add(nca);
					}
				}

				// ** insert category copy
				if(original.categories != null){
					foreach(ContentCategory occ in original.categories)
					{
						ContentCategory ncc = new ContentCategory();	
						ncc.idCategory=occ.idCategory;
						newContentCategory.Add(ncc);
					}
				}

				// ** insert language copy
				if(original.languages != null){
					foreach(ContentLanguage ocl in original.languages)
					{
						ContentLanguage ncl = new ContentLanguage();	
						ncl.idLanguage=ocl.idLanguage;
						newContentLanguage.Add(ncl);
					}
				}
							
				// ** insert attachments copy
				if(original.fields != null){
					foreach(ContentField ocf in original.fields)
					{
						ContentField ncf = new ContentField();	
						ncf.id=ocf.id;
						ncf.idParentContent=ocf.idParentContent;
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
						newContentField.Add(ncf);
						
						//retrieve field values
						IList<ContentFieldsValue> fvalues = null;
						IQuery qcfv = session.CreateQuery("from ContentFieldsValue where idParentField=:idParentField");	
						qcfv.SetInt32("idParentField", ocf.id);
						fvalues = qcfv.List<ContentFieldsValue>();						
						newContentFieldsValues.Add(ocf.id,fvalues);
					}
				}
				
				newcontent.insertDate=DateTime.Now;
				session.Save(newcontent);	

				if(newContentAttachment != null)
				{
					foreach (ContentAttachment k in newContentAttachment)
					{
						k.idParentContent = newcontent.id;
						k.filePath=k.filePath.Replace(original.id+"/",newcontent.id+"/");
						k.insertDate=DateTime.Now;
						session.Save(k);
					} 
				}
				if(newContentCategory != null)
				{
					foreach (ContentCategory k in newContentCategory)
					{
						k.idParent = newcontent.id;
						session.Save(k);
					} 
				}	
				if(newContentLanguage != null)
				{
					foreach (ContentLanguage k in newContentLanguage)
					{
						k.idParentContent = newcontent.id;
						session.Save(k);
					} 
				}
				if(newContentField != null)
				{						
					foreach(ContentField k in newContentField){
						k.idParentContent = newcontent.id;
						IList<ContentFieldsValue> fnvalues = null;		
						newContentFieldsValues.TryGetValue(k.id, out fnvalues);
						session.Save(k);
				
						// add field values
						if(fnvalues != null){
							foreach(ContentFieldsValue cfv in fnvalues){
								cfv.idParentField=k.id;
							}
						}
					}
					foreach(IList<ContentFieldsValue> lcfv in newContentFieldsValues.Values){
						if(lcfv != null){
							foreach(ContentFieldsValue cfv in lcfv){
								ContentFieldsValue ncfv = new ContentFieldsValue();
								ncfv.idParentField = cfv.idParentField;
								ncfv.value = cfv.value;
								ncfv.sorting = cfv.sorting;
								//HttpContext.Current.Response.Write("ContentFieldsValue before save:"+ncfv.ToString()+"<br>");
								session.Save(ncfv);
							}
						}
					}	
				}

				// ** insert geolocalization copy
				IList<Geolocalization> geolocs = null;
				IQuery q = session.CreateQuery("from Geolocalization where idElement=:idElement and type=1");	
				q.SetInt32("idElement", original.id);
				geolocs = q.List<Geolocalization>();			
				
				if(geolocs!=null)
				{
					foreach(Geolocalization gl in geolocs)
					{
						Geolocalization ng = new Geolocalization();
						ng.idElement = newcontent.id;
						ng.type = gl.type;
						ng.latitude = gl.latitude;
						ng.longitude = gl.longitude;
						ng.txtInfo = gl.txtInfo;
						session.Save(ng);						
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
				if(cacheKey.Contains("list-fcontent"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-name-values-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
			}	
			
			return newcontent;
		}
		
		public FContent getById(int id)
		{
			return getByIdCached(id, false);
		}
		
		public FContent getByIdCached(int id, bool cached)
		{
			FContent content = null;	
			
			if(cached)
			{
				content = (FContent)HttpContext.Current.Cache.Get("fcontent-"+id);
				if(content != null){
					return content;
				}
			}
							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				content = session.Get<FContent>(id);
				
				content.attachments = session.CreateCriteria(typeof(ContentAttachment))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentContent", content.id))
				.AddOrder(Order.Desc("id"))
				.List<ContentAttachment>();

				content.languages = session.CreateCriteria(typeof(ContentLanguage))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentContent", content.id))
				.List<ContentLanguage>();		

				content.categories = session.CreateCriteria(typeof(ContentCategory))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParent", content.id))
				.List<ContentCategory>();			

				content.fields = session.CreateCriteria(typeof(ContentField))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentContent", content.id))
				.AddOrder(Order.Asc("sorting"))
				.List<ContentField>();						

				NHibernateHelper.closeSession();
			}

			if(cached)
			{
				if(content == null){
					content = new FContent();
					content.id=-1;
				}
				HttpContext.Current.Cache.Insert("fcontent-"+content.id, content, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return content;
		}

		public IList<FContent> find(string title, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool cached)
		{
			IList<FContent> results = null;
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
			
			StringBuilder cacheKey = new StringBuilder("list-fcontent")
			.Append("-").Append(Utils.encodeTo64(title))
			.Append("-").Append(Utils.encodeTo64(keyword))
			.Append("-").Append(status)
			.Append("-").Append(Utils.encodeTo64(publishDate))
			.Append("-").Append(Utils.encodeTo64(deleteDate))
			.Append("-").Append(orderBy)
			.Append("-").Append(idsCatC)
			.Append("-").Append(idsLangC);
							
			//System.Web.HttpContext.Current.Response.Write("cacheKey: " + cacheKey.ToString());
							
			if(cached)
			{			
				results = (IList<FContent>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}				
			}
			
			string strSQL = "from FContent where 1=1";

			// check on categories and languages
			if(idsCat.Count>0){strSQL+=string.Format(" and id in(select idParent from ContentCategory where idCategory in({0}))",string.Join(",",idsCat.ToArray()));}
			if(idsLang.Count>0){strSQL+=string.Format(" and id in(select idParentContent from ContentLanguage where idLanguage in({0}))",string.Join(",",idsLang.ToArray()));}
			
			if (!String.IsNullOrEmpty(title)){			
				strSQL += " and title=:title";
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

			if (!String.IsNullOrEmpty(publishDate)){
				strSQL += " and publishDate <= :publishDate";
			}

			if (!String.IsNullOrEmpty(deleteDate)){
				strSQL += " and deleteDate >= :deleteDate";
			}
			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by title asc";
				break;
			    case 2:
				strSQL +=" order by title desc";
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
			    default:
				strSQL +=" order by title asc";
				break;
			}
			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL);					
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (!String.IsNullOrEmpty(title)){
						q.SetString("title", title);
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
					results = q.List<FContent>();

					if(results != null){
						foreach(FContent content in results){							
							if(withAttach){
								content.attachments = session.CreateCriteria(typeof(ContentAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.AddOrder(Order.Desc("id"))
								.List<ContentAttachment>();
							}
	
							if(withLang){
								content.languages = session.CreateCriteria(typeof(ContentLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.List<ContentLanguage>();		
							}
	
							if(withCats){
								content.categories = session.CreateCriteria(typeof(ContentCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParent", content.id))
								.List<ContentCategory>();
							}			

							if(withFields){
								content.fields = session.CreateCriteria(typeof(ContentField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.AddOrder(Order.Asc("sorting"))
								.List<ContentField>();	
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
					results = new List<FContent>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;		
		}

		public IList<FContent> find(string title, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, int pageIndex, int pageSize,out long totalCount)
		{
			IList<FContent> contents = null;		
			totalCount = 0;	
			string strSQL = "from FContent where 1=1";

			// first check on categories and languages
			if (matchCategories != null && matchCategories.Count > 0){
				List<string> ids = new List<string>();
				foreach(int c in matchCategories){
					ids.Add(c.ToString());
				}						
				if(ids.Count>0){strSQL+=string.Format(" and id in(select idParent from ContentCategory where idCategory in({0}))",string.Join(",",ids.ToArray()));}
			}
			
			if (matchLanguages != null && matchLanguages.Count > 0){
				List<string> ids = new List<string>();
				foreach(int c in matchLanguages){
					ids.Add(c.ToString());
				}						
				if(ids.Count>0){strSQL+=string.Format(" and id in(select idParentContent from ContentLanguage where idLanguage in({0}))",string.Join(",",ids.ToArray()));}
			}
			
			if (!String.IsNullOrEmpty(title)){			
				strSQL += " and title=:title";
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

			if (!String.IsNullOrEmpty(publishDate)){
				strSQL += " and publishDate <= :publishDate";
			}

			if (!String.IsNullOrEmpty(deleteDate)){
				strSQL += " and deleteDate >= :deleteDate";
			}

			
			switch (orderBy)
			{
			    case 1:
				strSQL +=" order by title asc";
				break;
			    case 2:
				strSQL +=" order by title desc";
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
			    default:
				strSQL +=" order by title asc";
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
					if (!String.IsNullOrEmpty(title)){
						q.SetString("title", title);
						qCount.SetString("title", title);
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
					contents = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);

					if(contents != null){
						foreach(FContent content in contents){							
							if(withAttach){
								content.attachments = session.CreateCriteria(typeof(ContentAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.AddOrder(Order.Desc("id"))
								.List<ContentAttachment>();
							}
	
							if(withLang){
								content.languages = session.CreateCriteria(typeof(ContentLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.List<ContentLanguage>();	
							}
	
							if(withCats){
								content.categories = session.CreateCriteria(typeof(ContentCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParent", content.id))
								.List<ContentCategory>();
							}		

							if(withFields){
								content.fields = session.CreateCriteria(typeof(ContentField))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentContent", content.id))
								.AddOrder(Order.Asc("sorting"))
								.List<ContentField>();	
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
			
			return contents;		
		}
	
		protected IList<FContent> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<FContent> records = new List<FContent>();	
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
						records.Add((FContent)tmp);
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
		

		public IList<ContentAttachment> getContentAttachments(int idContent)
		{
			IList<ContentAttachment> attachments = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ContentAttachment where id_parent_content= :id_content");
				q.SetInt32("id_content",idContent);	
				attachments = q.List<ContentAttachment>();
				NHibernateHelper.closeSession();					
			}	
			return attachments;		
		}	
		

		public ContentAttachment getContentAttachmentById(int idAttach)
		{
			ContentAttachment result = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ContentAttachment where id=:id_attach");
				q.SetInt32("id_attach",idAttach);	
				result = q.UniqueResult<ContentAttachment>();
				NHibernateHelper.closeSession();					
			}	
			return result;		
		}
		
		public void deleteContentAttachment(int idAttach)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ContentAttachment where id=:id_attach").SetInt32("id_attach",idAttach).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
	
		public IList<ContentAttachmentLabel> getContentAttachmentLabel()
		{
			return getContentAttachmentLabelCached(false);
		}
	
		public IList<ContentAttachmentLabel> getContentAttachmentLabelCached(bool cached)
		{
			IList<ContentAttachmentLabel> results = null;
			
			if(cached)
			{
				results = (IList<ContentAttachmentLabel>)HttpContext.Current.Cache.Get("fcontent-attachments-label");
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ContentAttachmentLabel order by description asc");
				results = q.List<ContentAttachmentLabel>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ContentAttachmentLabel>();
				}
				HttpContext.Current.Cache.Insert("fcontent-attachments-label", results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}
		
		public void deleteContentAttachmentLabel(int idAttachLabel)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ContentAttachmentLabel where id=:id_label").SetInt32("id_label",idAttachLabel).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("fcontent-attachments-label");
		}	
		
		public ContentAttachmentLabel insertContentAttachmentLabel(string newdescription)
		{
			ContentAttachmentLabel entry = new ContentAttachmentLabel();
			entry.description=newdescription;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				session.Save(entry);	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			HttpContext.Current.Cache.Remove("fcontent-attachments-label");
			return entry;
		}			

		public IList<ContentLanguage> getContentLanguages(int idContent)
		{
			IList<ContentLanguage> languages = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ContentLanguage where id_parent_content= :id_content");
				q.SetInt32("id_content",idContent);	
				languages = q.List<ContentLanguage>();
				NHibernateHelper.closeSession();					
			}	
			return languages;		
		}					

		public IList<ContentCategory> getContentCategories(int idContent)
		{
			IList<ContentCategory> categories = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from ContentCategory where id_parent_content= :id_content");
				q.SetInt32("id_content",idContent);	
				categories = q.List<ContentCategory>();
				NHibernateHelper.closeSession();					
			}	
			return categories;		
		}
		
		/*CONTENT FIELDS METHODS*/
	
		public ContentField getContentFieldById(int idField)
		{
			return getContentFieldByIdCached(idField, false);
		}
	
		public ContentField getContentFieldByIdCached(int idField, bool cached)
		{
			ContentField result = null;
			StringBuilder cacheKey = new StringBuilder("field-fcontent-").Append(idField);
				
			if(cached)
			{
				result = (ContentField)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(result != null){
					return result;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				result = session.Get<ContentField>(idField);
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(result == null){
					result = new ContentField();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return result;		
		}
	
		public IList<ContentField> getContentFields(int idContent, Nullable<bool> active, Nullable<bool> forBlog, Nullable<bool> common)
		{
			return getContentFieldsCached(idContent, active, forBlog, common, false);
		}
	
		public IList<ContentField> getContentFieldsCached(int idContent, Nullable<bool> active, Nullable<bool> forBlog, Nullable<bool> common, bool cached)
		{
			IList<ContentField> results = null;
			StringBuilder cacheKey = new StringBuilder("list-field-fcontent-").Append(idContent).Append("-").Append(active).Append("-").Append(forBlog).Append("-").Append(common);
				
			if(cached)
			{
				results = (IList<ContentField>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from ContentField  where 1=1";
				if(idContent!=-1){
				sql += " and id_parent_content= :id_content";
				}
				if(active != null){
				sql += " and enabled= :enabled";
				}
				if(forBlog != null){
				sql += " and forBlog= :forBlog";
				}
				if(common != null){
				sql += " and common= :common";
				}
				sql += " order by sorting, groupDescription, description asc";
				IQuery q = session.CreateQuery(sql);
				if(idContent!=-1){
				q.SetInt32("id_content",idContent);	
				}
				if(active != null){
				q.SetBoolean("enabled",Convert.ToBoolean(active));	
				}
				if(forBlog != null){
				q.SetBoolean("forBlog",Convert.ToBoolean(forBlog));	
				}
				if(common != null){
				q.SetBoolean("common",Convert.ToBoolean(common));	
				}
				results = q.List<ContentField>();
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ContentField>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			
			return results;		
		}
	
		public IList<ContentFieldsValue> getContentFieldValues(int idField)
		{
			return getContentFieldValuesCached(idField, false);
		}
	
		public IList<ContentFieldsValue> getContentFieldValuesCached(int idField, bool cached)
		{
			IList<ContentFieldsValue> results = null;	

			StringBuilder cacheKey = new StringBuilder("list-field-values-").Append(idField);
				
			if(cached)
			{
				results = (IList<ContentFieldsValue>)HttpContext.Current.Cache.Get(cacheKey.ToString());
				if(results != null){
					return results;
				}
			}
										
			string strSQL = "from ContentFieldsValue where idParentField=:idParentField order by sorting asc";		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);	
				q.SetInt32("idParentField",idField);			
				results = q.List<ContentFieldsValue>();		
				NHibernateHelper.closeSession();
			}
			
			if(cached)
			{
				if(results == null){
					results = new List<ContentFieldsValue>();
				}
				HttpContext.Current.Cache.Insert(cacheKey.ToString(), results, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
						
			return results;	
		}
	
		public IList<string> getContentFieldValuesByDescription(string description, Nullable<bool> common, Nullable<bool> active)
		{
			return getContentFieldValuesByDescriptionCached(description, common, active, false);
		}
	
		public IList<string> getContentFieldValuesByDescriptionCached(string description, Nullable<bool> common, Nullable<bool> active, bool cached)
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
			
			string strSQL = "select distinct value from CONTENT_FIELDS where description=:description and not isnull(value) and trim(value)<>''";			
			
			if(common != null){
			strSQL += " and common= :common";
			}			
			if(active != null){
			strSQL += " and enabled= :enabled";
			}
			strSQL += " order by value asc";
				
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("value", NHibernateUtil.String);
				q.SetString("description",description);
				if(common != null){
				q.SetBoolean("common",Convert.ToBoolean(common));	
				}	
				if(active != null){
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

		public void saveCompleteContentField(ContentField field, IList<ContentFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(field.id != -1){
						session.Update(field);
						session.CreateQuery("delete from ContentFieldsValue where idParentField=:idParentField").SetInt32("idParentField",field.id).ExecuteUpdate();
					}else{
						session.Save(field);
					}											
					// ************** AGGIUNGO i values se presenti
					foreach (ContentFieldsValue cfv in fieldValues){
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
				if(cacheKey.Contains("list-fcontent"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("list-field-fcontent-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("field-fcontent-"+field.id))
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
		
		public void updateContentField(ContentField field)
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
				if(cacheKey.Contains("list-fcontent"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fcontent-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fcontent-"+field.id))
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
		
		public void deleteContentField(int idField)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ContentField where id=:id").SetInt32("id",idField).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fcontent"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}
				else if(cacheKey.Contains("list-field-fcontent-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				} 
				else if(cacheKey.Contains("field-fcontent-"+idField))
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
			}
		}
		
		public void deleteContentFieldValue(int idField, string fieldValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from ContentFieldsValue where idParentField=:idParentField and value=:value").SetInt32("idParentField",idField).SetString("value",fieldValue).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			//rimuovo cache		
			IDictionaryEnumerator CacheEnum = HttpContext.Current.Cache.GetEnumerator();
			while (CacheEnum.MoveNext())
			{		  
				string cacheKey = HttpContext.Current.Server.HtmlEncode(CacheEnum.Key.ToString()); 
				if(cacheKey.Contains("list-fcontent"))
				{ 
					//HttpContext.Current.Response.Write(cacheKey+"<br>");		
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("list-field-fcontent-"))
				{
					HttpContext.Current.Cache.Remove(cacheKey);
				}  
				else if(cacheKey.Contains("field-fcontent-"))
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
	
		public IList<string> findFieldNames(bool forBlog)
		{
			IList names = null;
			IList<string> results = null;					
			string strSQL = "select distinct description from CONTENT_FIELDS where not isnull(description)";
			if(forBlog){
				strSQL+= " and for_blog=1";
			}else{
				strSQL+= " and for_blog=0";
			}				
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
	
		public IList<string> findFieldGroupNames(bool forBlog)
		{
			IList gnames = null;
			IList<string> results = null;					
			string strSQL = "select distinct group_description from CONTENT_FIELDS where not isnull(group_description)";
			if(forBlog){
				strSQL+= " and for_blog=1";
			}else{
				strSQL+= " and for_blog=0";
			}			
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
		
	}
}