using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using com.nemesys.database;
using NHibernate;
using NHibernate.Criterion;
using System.Web;
using System.Security.Cryptography;
using System.Text;

namespace com.nemesys.database.repository
{
	public class UserRepository : IUserRepository
	{		
		public void insert(User user)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<UserAttachment> newUserAttachment = new List<UserAttachment>();
				IList<UserLanguage> newUserLanguage = new List<UserLanguage>();
				IList<UserCategory> newUserCategory = new List<UserCategory>();
				IList<UserNewsletter> newUserNewsletter = new List<UserNewsletter>();
				IList<UserFriend> newUserFriend = new List<UserFriend>();
				IList<UserFieldsMatch> newUserFieldsMatch = new List<UserFieldsMatch>();
				
				if(user.attachments != null && user.attachments.Count>0)
				{
					foreach(UserAttachment k in user.attachments){					
						UserAttachment nca = new UserAttachment();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.isAvatar=k.isAvatar;
						nca.idUser = k.idUser;						
						newUserAttachment.Add(nca);
					}
					user.attachments.Clear();							
				}
				if(user.languages != null && user.languages.Count>0)
				{
					foreach(UserLanguage k in user.languages){		
						UserLanguage ncl = new UserLanguage();	
						ncl.idLanguage=k.idLanguage;
						ncl.idParentUser = user.id;
						newUserLanguage.Add(ncl);
					}
					user.languages.Clear();							
				}
				if(user.categories != null && user.categories.Count>0)
				{
					foreach(UserCategory k in user.categories){	
						UserCategory ncc = new UserCategory();	
						ncc.idCategory=k.idCategory;
						ncc.idParentUser = user.id;
						newUserCategory.Add(ncc);
					}
					user.categories.Clear();							
				}
				if(user.newsletters != null && user.newsletters.Count>0)
				{
					foreach(UserNewsletter k in user.newsletters){	
						UserNewsletter ncc = new UserNewsletter();	
						ncc.newsletterId=k.newsletterId;
						ncc.idParentUser = user.id;
						newUserNewsletter.Add(ncc);
					}
					user.newsletters.Clear();							
				}
				if(user.friends != null && user.friends.Count>0)
				{
					foreach(UserFriend k in user.friends){	
						UserFriend ncc = new UserFriend();	
						ncc.friend=k.friend;
						ncc.idParentUser = user.id;
						ncc.isActive = k.isActive;
						newUserFriend.Add(ncc);
					}
					user.friends.Clear();							
				}
				if(user.fields != null && user.fields.Count>0)
				{
					foreach(UserFieldsMatch k in user.fields){	
						UserFieldsMatch nufm = new UserFieldsMatch();	
						nufm.idParentField=k.idParentField;
						nufm.idParentUser = user.id;
						nufm.value = k.value;
						newUserFieldsMatch.Add(nufm);
					}
					user.fields.Clear();							
				}				
				
				user.insertDate=DateTime.Now;
				user.modifyDate=DateTime.Now;
				session.Save(user);	

				if(newUserAttachment != null && newUserAttachment.Count>0)
				{							
					foreach(UserAttachment k in newUserAttachment){
						if(k.idUser == -1){
							k.filePath=user.id+"/";
						}	
						k.idUser = user.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newUserLanguage != null && newUserLanguage.Count>0)
				{							
					foreach(UserLanguage k in newUserLanguage){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserCategory != null && newUserCategory.Count>0)
				{							
					foreach(UserCategory k in newUserCategory){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserNewsletter != null && newUserNewsletter.Count>0)
				{							
					foreach(UserNewsletter k in newUserNewsletter){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserFriend != null && newUserFriend.Count>0)
				{							
					foreach(UserFriend k in newUserFriend){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserFieldsMatch != null && newUserFieldsMatch.Count>0)
				{							
					foreach(UserFieldsMatch k in newUserFieldsMatch){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void update(User user)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IList<UserAttachment> newUserAttachment = new List<UserAttachment>();
				IList<UserLanguage> newUserLanguage = new List<UserLanguage>();
				IList<UserCategory> newUserCategory = new List<UserCategory>();
				IList<UserNewsletter> newUserNewsletter = new List<UserNewsletter>();
				IList<UserFriend> newUserFriend = new List<UserFriend>();
				IList<UserFieldsMatch> newUserFieldsMatch = new List<UserFieldsMatch>();
				
				if(user.attachments != null && user.attachments.Count>0)
				{
					foreach(UserAttachment k in user.attachments){					
						UserAttachment nca = new UserAttachment();	
						nca.fileName=k.fileName;
						nca.filePath=k.filePath;
						nca.contentType=k.contentType;
						nca.fileDida=k.fileDida;
						nca.fileLabel=k.fileLabel;
						nca.isAvatar=k.isAvatar;
						nca.idUser = k.idUser;						
						newUserAttachment.Add(nca);
					}
					user.attachments.Clear();							
				}
				if(user.languages != null && user.languages.Count>0)
				{
					foreach(UserLanguage k in user.languages){		
						UserLanguage ncl = new UserLanguage();	
						ncl.idLanguage=k.idLanguage;
						ncl.idParentUser = user.id;
						newUserLanguage.Add(ncl);
					}
					user.languages.Clear();							
				}
				if(user.categories != null && user.categories.Count>0)
				{
					foreach(UserCategory k in user.categories){	
						UserCategory ncc = new UserCategory();	
						ncc.idCategory=k.idCategory;
						ncc.idParentUser = user.id;
						newUserCategory.Add(ncc);
					}
					user.categories.Clear();							
				}
				if(user.newsletters != null && user.newsletters.Count>0)
				{
					foreach(UserNewsletter k in user.newsletters){	
						UserNewsletter ncc = new UserNewsletter();	
						ncc.newsletterId=k.newsletterId;
						ncc.idParentUser = user.id;
						newUserNewsletter.Add(ncc);
					}
					user.newsletters.Clear();							
				}
				if(user.friends != null && user.friends.Count>0)
				{
					foreach(UserFriend k in user.friends){	
						UserFriend ncc = new UserFriend();	
						ncc.friend=k.friend;
						ncc.idParentUser = user.id;
						ncc.isActive = k.isActive;
						newUserFriend.Add(ncc);
					}
					user.friends.Clear();							
				}	
				if(user.fields != null && user.fields.Count>0)
				{
					foreach(UserFieldsMatch k in user.fields){	
						UserFieldsMatch nufm = new UserFieldsMatch();	
						nufm.idParentField=k.idParentField;
						nufm.idParentUser = user.id;
						nufm.value = k.value;
						newUserFieldsMatch.Add(nufm);
					}
					user.fields.Clear();							
				}			
				
				user.modifyDate=DateTime.Now;
				session.Update(user);	

				session.CreateQuery("delete from UserAttachment where idUser=:idUser").SetInt32("idUser",user.id).ExecuteUpdate();
				session.CreateQuery("delete from UserLanguage where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
				session.CreateQuery("delete from UserCategory where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
				session.CreateQuery("delete from UserNewsletter where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
				session.CreateQuery("delete from UserFriend where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
				session.CreateQuery("delete from UserFieldsMatch where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
				
				if(newUserAttachment != null && newUserAttachment.Count>0)
				{							
					foreach(UserAttachment k in newUserAttachment){
						if(k.idUser == -1){
							k.filePath=user.id+"/";
						}	
						k.idUser = user.id;
						k.insertDate=DateTime.Now;
						session.Save(k);
					}
				}
				if(newUserLanguage != null && newUserLanguage.Count>0)
				{							
					foreach(UserLanguage k in newUserLanguage){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserCategory != null && newUserCategory.Count>0)
				{							
					foreach(UserCategory k in newUserCategory){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserNewsletter != null && newUserNewsletter.Count>0)
				{							
					foreach(UserNewsletter k in newUserNewsletter){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserFriend != null && newUserFriend.Count>0)
				{							
					foreach(UserFriend k in newUserFriend){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}
				if(newUserFieldsMatch != null && newUserFieldsMatch.Count>0)
				{							
					foreach(UserFieldsMatch k in newUserFieldsMatch){
						k.idParentUser = user.id;
						session.Save(k);
					}
				}			
								
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void delete(User user)
		{
			delete(user, false);
			return;
		}
		
		public bool delete(User user, bool forceDelete)
		{
			bool deleted = true;
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				bool doDisable = false;
				if(!forceDelete)
				{
					//first check on contents and orders associations with user
					//if found user will be disabled, not deleted;
					IList<User> usersXcontents = null;
					IQuery q = session.CreateQuery("from FContent where userId=:userid");
					q.SetInt32("userid",user.id);	
					usersXcontents = q.List<User>();	
					
					// TODO: check for orders: with code must be deleted in cms version build
					/*IList<Order> usersXorders = null;
					IQuery q = session.CreateQuery("from Order where userId=:userid");
					q.SetInt32("userid",user.id);	
					usersXorders = q.List<Order>();*/
					
					if((usersXcontents != null && usersXcontents.Count>0) /*|| (usersXorders != null && usersXorders.Count>0)*/)
					{					
						doDisable = true;
					}
				}
				
				if(doDisable)
				{
					user.isActive=false;
					session.Update(user);
					deleted = false;
				}
				else
				{			
					if(user.attachments != null && user.attachments.Count>0)
					{				
						session.CreateQuery("delete from UserAttachment where idUser=:idUser").SetInt32("idUser",user.id).ExecuteUpdate();
						user.attachments.Clear();
					}
	
					if(user.languages != null && user.languages.Count>0)
					{				
						session.CreateQuery("delete from UserLanguage where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						user.languages.Clear();
					}
					
					if(user.categories != null && user.categories.Count>0)
					{				
						session.CreateQuery("delete from UserCategory where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						user.categories.Clear();
					}
					
					if(user.newsletters != null && user.newsletters.Count>0)
					{				
						session.CreateQuery("delete from UserNewsletter where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						user.newsletters.Clear();
					}
					
					if(user.friends != null && user.friends.Count>0)
					{				
						session.CreateQuery("delete from UserFriend where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						user.friends.Clear();
					}
					
					if(user.fields != null && user.fields.Count>0)
					{				
						session.CreateQuery("delete from UserFieldsMatch where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						user.fields.Clear();
					}					
									
					session.CreateQuery("delete from Preference where userId=:userId").SetInt32("userId",user.id).ExecuteUpdate();					
					session.CreateQuery("delete from UserConfirmation where idUser=:idUser").SetInt32("idUser",user.id).ExecuteUpdate();				
					session.Delete(user);
				}
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return deleted;
		}

		public void saveCompleteUser(User user, string confirmationCode)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					IList<UserAttachment> newUserAttachment = new List<UserAttachment>();
					IList<UserLanguage> newUserLanguage = new List<UserLanguage>();
					IList<UserCategory> newUserCategory = new List<UserCategory>();
					IList<UserNewsletter> newUserNewsletter = new List<UserNewsletter>();
					IList<UserFriend> newUserFriend = new List<UserFriend>();
					IList<UserFieldsMatch> newUserFieldsMatch = new List<UserFieldsMatch>();
					
					if(user.id != -1){						
						if(user.attachments != null && user.attachments.Count>0)
						{
							foreach(UserAttachment k in user.attachments){					
								UserAttachment nca = new UserAttachment();	
								nca.fileName=k.fileName;
								nca.filePath=k.filePath;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;
								nca.isAvatar=k.isAvatar;
								nca.idUser = k.idUser;						
								newUserAttachment.Add(nca);
							}
							user.attachments.Clear();							
						}
						if(user.languages != null && user.languages.Count>0)
						{
							foreach(UserLanguage k in user.languages){		
								UserLanguage ncl = new UserLanguage();	
								ncl.idLanguage=k.idLanguage;
								ncl.idParentUser = user.id;
								newUserLanguage.Add(ncl);
							}
							user.languages.Clear();							
						}
						if(user.categories != null && user.categories.Count>0)
						{
							foreach(UserCategory k in user.categories){	
								UserCategory ncc = new UserCategory();	
								ncc.idCategory=k.idCategory;
								ncc.idParentUser = user.id;
								newUserCategory.Add(ncc);
							}
							user.categories.Clear();							
						}
						if(user.newsletters != null && user.newsletters.Count>0)
						{
							foreach(UserNewsletter k in user.newsletters){	
								UserNewsletter ncc = new UserNewsletter();	
								ncc.newsletterId=k.newsletterId;
								ncc.idParentUser = user.id;
								newUserNewsletter.Add(ncc);
							}
							user.newsletters.Clear();							
						}
						if(user.friends != null && user.friends.Count>0)
						{
							foreach(UserFriend k in user.friends){	
								UserFriend ncc = new UserFriend();	
								ncc.friend=k.friend;
								ncc.idParentUser = user.id;
								ncc.isActive = k.isActive;
								newUserFriend.Add(ncc);
							}
							user.friends.Clear();							
						}	
						if(user.fields != null && user.fields.Count>0)
						{
							foreach(UserFieldsMatch k in user.fields){	
								UserFieldsMatch nufm = new UserFieldsMatch();	
								nufm.idParentField=k.idParentField;
								nufm.idParentUser = user.id;
								nufm.value = k.value;
								newUserFieldsMatch.Add(nufm);
							}
							user.fields.Clear();							
						}				
						
						user.modifyDate=DateTime.Now;
						session.Update(user);	
		
						session.CreateQuery("delete from UserAttachment where idUser=:idUser").SetInt32("idUser",user.id).ExecuteUpdate();
						session.CreateQuery("delete from UserLanguage where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						session.CreateQuery("delete from UserCategory where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						session.CreateQuery("delete from UserNewsletter where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						session.CreateQuery("delete from UserFriend where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						session.CreateQuery("delete from UserFieldsMatch where idParentUser=:idParentUser").SetInt32("idParentUser",user.id).ExecuteUpdate();
						
						if(newUserAttachment != null && newUserAttachment.Count>0)
						{							
							foreach(UserAttachment k in newUserAttachment){
								if(k.idUser == -1){
									k.filePath=user.id+"/";
								}	
								k.idUser = user.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newUserLanguage != null && newUserLanguage.Count>0)
						{							
							foreach(UserLanguage k in newUserLanguage){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserCategory != null && newUserCategory.Count>0)
						{							
							foreach(UserCategory k in newUserCategory){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserNewsletter != null && newUserNewsletter.Count>0)
						{							
							foreach(UserNewsletter k in newUserNewsletter){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserFriend != null && newUserFriend.Count>0)
						{							
							foreach(UserFriend k in newUserFriend){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserFieldsMatch != null && newUserFieldsMatch.Count>0)
						{							
							foreach(UserFieldsMatch k in newUserFieldsMatch){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}											
					}else{
						if(user.attachments != null && user.attachments.Count>0)
						{
							foreach(UserAttachment k in user.attachments){					
								UserAttachment nca = new UserAttachment();	
								nca.fileName=k.fileName;
								nca.filePath=k.filePath;
								nca.contentType=k.contentType;
								nca.fileDida=k.fileDida;
								nca.fileLabel=k.fileLabel;
								nca.isAvatar=k.isAvatar;
								nca.idUser = k.idUser;						
								newUserAttachment.Add(nca);
							}
							user.attachments.Clear();							
						}
						if(user.languages != null && user.languages.Count>0)
						{
							foreach(UserLanguage k in user.languages){		
								UserLanguage ncl = new UserLanguage();	
								ncl.idLanguage=k.idLanguage;
								ncl.idParentUser = user.id;
								newUserLanguage.Add(ncl);
							}
							user.languages.Clear();							
						}
						if(user.categories != null && user.categories.Count>0)
						{
							foreach(UserCategory k in user.categories){	
								UserCategory ncc = new UserCategory();	
								ncc.idCategory=k.idCategory;
								ncc.idParentUser = user.id;
								newUserCategory.Add(ncc);
							}
							user.categories.Clear();							
						}
						if(user.newsletters != null && user.newsletters.Count>0)
						{
							foreach(UserNewsletter k in user.newsletters){	
								UserNewsletter ncc = new UserNewsletter();	
								ncc.newsletterId=k.newsletterId;
								ncc.idParentUser = user.id;
								newUserNewsletter.Add(ncc);
							}
							user.newsletters.Clear();							
						}
						if(user.friends != null && user.friends.Count>0)
						{
							foreach(UserFriend k in user.friends){	
								UserFriend ncc = new UserFriend();	
								ncc.friend=k.friend;
								ncc.idParentUser = user.id;
								ncc.isActive = k.isActive;
								newUserFriend.Add(ncc);
							}
							user.friends.Clear();							
						}
						if(user.fields != null && user.fields.Count>0)
						{
							foreach(UserFieldsMatch k in user.fields){	
								UserFieldsMatch nufm = new UserFieldsMatch();	
								nufm.idParentField=k.idParentField;
								nufm.idParentUser = user.id;
								nufm.value = k.value;
								newUserFieldsMatch.Add(nufm);
							}
							user.fields.Clear();							
						}				
						
						user.insertDate=DateTime.Now;
						user.modifyDate=DateTime.Now;
						session.Save(user);	
		
						if(newUserAttachment != null && newUserAttachment.Count>0)
						{							
							foreach(UserAttachment k in newUserAttachment){
								if(k.idUser == -1){
									k.filePath=user.id+"/";
								}	
								k.idUser = user.id;
								k.insertDate=DateTime.Now;
								session.Save(k);
							}
						}
						if(newUserLanguage != null && newUserLanguage.Count>0)
						{							
							foreach(UserLanguage k in newUserLanguage){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserCategory != null && newUserCategory.Count>0)
						{							
							foreach(UserCategory k in newUserCategory){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserNewsletter != null && newUserNewsletter.Count>0)
						{							
							foreach(UserNewsletter k in newUserNewsletter){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserFriend != null && newUserFriend.Count>0)
						{							
							foreach(UserFriend k in newUserFriend){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						if(newUserFieldsMatch != null && newUserFieldsMatch.Count>0)
						{							
							foreach(UserFieldsMatch k in newUserFieldsMatch){
								k.idParentUser = user.id;
								session.Save(k);
							}
						}
						
						// check for confirmation code insert
						if(!String.IsNullOrEmpty(confirmationCode))
						{
							UserConfirmation confirmCode = new UserConfirmation(user.id, confirmationCode);
							session.Save(confirmCode);
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
		
		public User getById(int id)
		{
			User user = null;					
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				user = session.Get<User>(id);
				
				user.attachments = session.CreateCriteria(typeof(UserAttachment))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idUser", user.id))
				.List<UserAttachment>();

				user.friends = session.CreateCriteria(typeof(UserFriend))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentUser", user.id))
				.List<UserFriend>();	

				user.languages = session.CreateCriteria(typeof(UserLanguage))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentUser", user.id))
				.List<UserLanguage>();		

				user.categories = session.CreateCriteria(typeof(UserCategory))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentUser", user.id))
				.List<UserCategory>();	

				user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentUser", user.id))
				.List<UserNewsletter>();	

				user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
				.SetFetchMode("Permissions", FetchMode.Join)
				.Add(Restrictions.Eq("idParentUser", user.id))
				.List<UserFieldsMatch>();						

				NHibernateHelper.closeSession();
			}		
			
			return user;
		}
		
		public User getByParams(int id, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields)
		{	
			User user = null;							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				user = session.Get<User>(id);
	
				if(withAttach){
					user.attachments = session.CreateCriteria(typeof(UserAttachment))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idUser", user.id))
					.List<UserAttachment>();
				}
				else
				{
					user.attachments = null;
				}
				//System.Web.HttpContext.Current.Response.Write("<b>user.attachments: </b>"+user.attachments.GetType()+"<br>");
				if(withFriend){
					user.friends = session.CreateCriteria(typeof(UserFriend))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserFriend>();	
				}
				else
				{
					user.friends = null;
				}

				if(withLang){
					user.languages = session.CreateCriteria(typeof(UserLanguage))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserLanguage>();		
				}
				else
				{
					user.languages = null;
				}

				if(withCats){
					user.categories = session.CreateCriteria(typeof(UserCategory))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserCategory>();
				}
				else
				{
					user.categories = null;
				}
	
				if(withNewsletters){
					user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserNewsletter>();
				}
				else
				{
					user.newsletters = null;
				}
	
				if(withFields){
					user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserFieldsMatch>();
				}
				else
				{
					user.fields = null;
				}		

				NHibernateHelper.closeSession();
			}		
			
			return user;
		}

		public User findById(int id, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields)
		{
			User user = null;							
			using (ISession session = NHibernateHelper.getCurrentSession())
			{				
				string strSQL = "from User as user where id=:idUser order by username";				
				IQuery q = session.CreateQuery(strSQL);
				q.SetInt32("idUser",id);
				user = q.UniqueResult<User>();
	
				if(user != null){
					if(withAttach){
						user.attachments = session.CreateCriteria(typeof(UserAttachment))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idUser", user.id))
						.List<UserAttachment>();
					}
					else
					{
						user.attachments = null;
					}
					//System.Web.HttpContext.Current.Response.Write("<b>user.attachments: </b>"+user.attachments.GetType()+"<br>");
					if(withFriend){
						user.friends = session.CreateCriteria(typeof(UserFriend))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idParentUser", user.id))
						.List<UserFriend>();	
					}
					else
					{
						user.friends = null;
					}
	
					if(withLang){
						user.languages = session.CreateCriteria(typeof(UserLanguage))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idParentUser", user.id))
						.List<UserLanguage>();		
					}
					else
					{
						user.languages = null;
					}
	
					if(withCats){
						user.categories = session.CreateCriteria(typeof(UserCategory))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idParentUser", user.id))
						.List<UserCategory>();
					}
					else
					{
						user.categories = null;
					}
		
					if(withNewsletters){
						user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idParentUser", user.id))
						.List<UserNewsletter>();
					}
					else
					{
						user.newsletters = null;
					}
		
					if(withFields){
						user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
						.SetFetchMode("Permissions", FetchMode.Join)
						.Add(Restrictions.Eq("idParentUser", user.id))
						.List<UserFieldsMatch>();
					}
					else
					{
						user.fields = null;
					}	
				}

				NHibernateHelper.closeSession();
			}		
			
			return user;			
		}
		
		public IList<User> find(bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields)
		{
			IList<User> results = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				//System.Web.HttpContext.Current.Response.Write("<b>start: delete method</b><br>");
				string strSQL = "from User as user order by username";				
				IQuery q = session.CreateQuery(strSQL);
				results = q.List<User>();
				
				if(results != null){
					foreach(User user in results){							
						if(withAttach){
							user.attachments = session.CreateCriteria(typeof(UserAttachment))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idUser", user.id))
							.List<UserAttachment>();
						}
						else
						{
							user.attachments = null;
						}

						if(withFriend){
							user.friends = session.CreateCriteria(typeof(UserFriend))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idParentUser", user.id))
							.List<UserFriend>();	
						}
						else
						{
							user.friends = null;
						}

						if(withLang){
							user.languages = session.CreateCriteria(typeof(UserLanguage))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idParentUser", user.id))
							.List<UserLanguage>();		
						}
						else
						{
							user.languages = null;
						}

						if(withCats){
							user.categories = session.CreateCriteria(typeof(UserCategory))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idParentUser", user.id))
							.List<UserCategory>();
						}
						else
						{
							user.categories = null;
						}
	
						if(withNewsletters){
							user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idParentUser", user.id))
							.List<UserNewsletter>();
						}
						else
						{
							user.newsletters = null;
						}
	
						if(withFields){
							user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
							.SetFetchMode("Permissions", FetchMode.Join)
							.Add(Restrictions.Eq("idParentUser", user.id))
							.List<UserFieldsMatch>();
						}
						else
						{
							user.fields = null;
						}	
					}
				}				
				
				NHibernateHelper.closeSession();
			}	
			
			return results;	
		}

		public IList<User> find(string userNameOrMail, string roles, string active, string isPublic, string automatic, int order_by, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields)
		{
			IList<User> results = null;		
			string strSQL = "from User where 1=1";
			if (!String.IsNullOrEmpty(userNameOrMail)){			
				strSQL += " and (username like :username  or email like :email)";
			}	
			if (!String.IsNullOrEmpty(roles)){			
				//strSQL += " and role IN(:roles)";				
				List<string> ids = new List<string>();
				string[] troles = roles.Split(',');
				foreach(string r in troles){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and role in({0})",string.Join(",",ids.ToArray()));}		
			}			
			if (!String.IsNullOrEmpty(active)){	
				strSQL += " and active=:active";	
			}	
			if (!String.IsNullOrEmpty(isPublic)){
				strSQL += " and isPublicProfile=:isPublic";
			}	
			if (!String.IsNullOrEmpty(automatic)){	
				strSQL += " and isAutomaticUser=:automatic";
			}

			switch (order_by)
			{
			    case 1:
				strSQL +=" order by username asc";
				break;
			    case 2:
				strSQL +=" order by username desc";
				break;
			    case 3:
				strSQL +=" order by role asc";
				break;
			    case 4:
				strSQL +=" order by role desc";
				break;
			    case 5:
				strSQL +=" order by isActive asc";
				break;
			    case 6:
				strSQL +=" order by isActive desc";
				break;
			    case 7:
				strSQL +=" order by isPublicProfile asc";
				break;
			    case 8:
				strSQL +=" order by isPublicProfile desc";
				break;
			    default:
				strSQL +=" order by username asc";
				break;
			}						
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			//using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				try
				{
					if (!String.IsNullOrEmpty(userNameOrMail)){
						q.SetString("username", String.Format("%{0}%", userNameOrMail));
						q.SetString("email", String.Format("%{0}%", userNameOrMail));
					}
					/*if (!String.IsNullOrEmpty(roles)){
						q.SetString("roles", roles);
					}*/
					if (!String.IsNullOrEmpty(active)){
						q.SetBoolean("active", Convert.ToBoolean(active));
					}
					if (!String.IsNullOrEmpty(isPublic)){
						q.SetBoolean("isPublic", Convert.ToBoolean(isPublic));
					}
					if (!String.IsNullOrEmpty(automatic)){
						q.SetBoolean("automatic", Convert.ToBoolean(automatic));
					}
					results = q.List<User>();
					//System.Web.HttpContext.Current.Response.Write("languages.Count: " + languages.GetType()+"<br>");

					if(results != null){
						foreach(User user in results){							
							if(withAttach){
								user.attachments = session.CreateCriteria(typeof(UserAttachment))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idUser", user.id))
								.List<UserAttachment>();
							}
							else
							{
								user.attachments = null;
							}
	
							if(withFriend){
								user.friends = session.CreateCriteria(typeof(UserFriend))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentUser", user.id))
								.List<UserFriend>();	
							}
							else
							{
								user.friends = null;
							}
	
							if(withLang){
								user.languages = session.CreateCriteria(typeof(UserLanguage))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentUser", user.id))
								.List<UserLanguage>();		
							}
							else
							{
								user.languages = null;
							}
	
							if(withCats){
								user.categories = session.CreateCriteria(typeof(UserCategory))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentUser", user.id))
								.List<UserCategory>();
							}
							else
							{
								user.categories = null;
							}
	
							if(withNewsletters){
								user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentUser", user.id))
								.List<UserNewsletter>();
							}
							else
							{
								user.newsletters = null;
							}
	
							if(withFields){
								user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
								.SetFetchMode("Permissions", FetchMode.Join)
								.Add(Restrictions.Eq("idParentUser", user.id))
								.List<UserFieldsMatch>();
							}
							else
							{
								user.fields = null;
							}		
						}
					}
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				//tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return results;		
		}

		public IList<User> find(string userNameOrMail, string roles, string active, string isPublic, string automatic, int order_by, int pageIndex, int pageSize,out long totalCount)
		{
			IList<User> users = null;		
			totalCount = 0;	
			string strSQL = "from User where 1=1";
			if (!String.IsNullOrEmpty(userNameOrMail)){			
				strSQL += " and (username like :username  or email like :email)";
			}	
			if (!String.IsNullOrEmpty(roles)){			
				//strSQL += " and role in(:roles)";				
				List<string> ids = new List<string>();
				string[] troles = roles.Split(',');
				foreach(string r in troles){
					ids.Add(r);
				}						
				if(ids.Count>0){strSQL+=string.Format(" and role in({0})",string.Join(",",ids.ToArray()));}
			}	
			if (!String.IsNullOrEmpty(active)){	
				strSQL += " and active=:active";	
			}	
			if (!String.IsNullOrEmpty(isPublic)){
				strSQL += " and isPublicProfile=:isPublic";
			}	
			if (!String.IsNullOrEmpty(automatic)){	
				strSQL += " and isAutomaticUser=:automatic";
			}
					
			strSQL +=" order by username asc";			
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				IQuery q = session.CreateQuery(strSQL);
				IQuery qCount = session.CreateQuery("select count(*) "+strSQL);	
				try
				{
					if (!String.IsNullOrEmpty(userNameOrMail)){
						q.SetString("username", String.Format("%{0}%", userNameOrMail));
						q.SetString("email", String.Format("%{0}%", userNameOrMail));
						qCount.SetString("username", String.Format("%{0}%", userNameOrMail));
						qCount.SetString("email", String.Format("%{0}%", userNameOrMail));
					}
					if (!String.IsNullOrEmpty(active)){
						q.SetBoolean("active", Convert.ToBoolean(active));
						qCount.SetBoolean("active", Convert.ToBoolean(active));
					}
					if (!String.IsNullOrEmpty(isPublic)){
						q.SetBoolean("isPublic", Convert.ToBoolean(isPublic));
						qCount.SetBoolean("isPublic", Convert.ToBoolean(isPublic));
					}
					if (!String.IsNullOrEmpty(automatic)){
						q.SetBoolean("automatic", Convert.ToBoolean(automatic));
						qCount.SetBoolean("automatic", Convert.ToBoolean(automatic));
					}
					users = getByQuery(q,qCount,session,pageIndex,pageSize,out totalCount);
					//System.Web.HttpContext.Current.Response.Write("languages.Count: " + languages.GetType()+"<br>");
				}
				catch(Exception ex)
				{
					//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					// DO NOTHING: RETURN NULL
				}
				tx.Commit();
				NHibernateHelper.closeSession();
			}
			
			return users;		
		}
	
		protected IList<User> getByQuery(
			IQuery query, 
			IQuery queryCount,
			ISession session, 
			int pageIndex,
			int pageSize, 
			out long totalCount)
		{
			IList<User> records = new List<User>();	
			totalCount=0;

			try
			{
				IList results = session.CreateMultiQuery()
				.Add(query.SetFirstResult(((pageIndex * pageSize) - pageSize)).SetMaxResults(pageSize))
				.Add(queryCount)
				.SetCacheable(true)
				.List();
				IList recordstmp = (IList)results[0];
				//System.Web.HttpContext.Current.Response.Write("pageIndex: " + pageIndex + " - pageSize:"+pageSize+"<br>");
				//System.Web.HttpContext.Current.Response.Write("query: " + query +"<br>");
				//System.Web.HttpContext.Current.Response.Write("queryCount: " + queryCount +"<br>");
				totalCount = (long)((IList)results[1])[0];
				//System.Web.HttpContext.Current.Response.Write("records.Count: " + records.Count + " - totalCount:"+totalCount+"<br>");

				if(recordstmp != null)
				{
					foreach(Object tmp in recordstmp)
					{
						records.Add((User)tmp);
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

		public User getByMail(string email)
		{
			User user = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from User where email=:email");
				q.SetString("email",email);	
				user = q.UniqueResult<User>();
				NHibernateHelper.closeSession();					
			}	
			return user;		
		}	

		public User getByUsernameAndMail(string username, string email)
		{
			User user = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from User where username= :username and email=:email");
				q.SetString("username",username);	
				q.SetString("email",email);	
				user = q.UniqueResult<User>();
				NHibernateHelper.closeSession();					
			}	
			return user;		
		}	

		public bool userAlreadyExists(string username, string email, int userid)
		{
			bool exist = false;
			IList<User> users = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from User where (username= :username or email=:email) and id != :userid");
				q.SetString("username",username);	
				q.SetString("email",email);	
				q.SetInt32("userid",userid);	
				users = q.List<User>();
				NHibernateHelper.closeSession();					
			}
				
			if(users!=null && users.Count >0)
			{
				exist=true;
			}
			
			return exist;		
		}	

		public IList<UserFriend> getUserFriends(int id_user)
		{
			IList<UserFriend> friends = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserFriend as userFriend where id_parent_user= :id_user");
				q.SetInt32("id_user",id_user);	
				friends = q.List<UserFriend>();
				NHibernateHelper.closeSession();					
			}	
			return friends;		
		}		

		public IList<UserAttachment> getUserAttachments(int id_user)
		{
			IList<UserAttachment> attachments = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserAttachment as userAttachment where id_parent_user= :id_user");
				q.SetInt32("id_parent_user",id_user);	
				attachments = q.List<UserAttachment>();
				NHibernateHelper.closeSession();					
			}	
			return attachments;		
		}				

		public IList<UserLanguage> getUserLanguages(int id_user)
		{
			IList<UserLanguage> languages = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserLanguage as userLanguage where id_parent_user= :id_user");
				q.SetInt32("id_parent_user",id_user);	
				languages = q.List<UserLanguage>();
				NHibernateHelper.closeSession();					
			}	
			return languages;		
		}					

		public IList<UserCategory> getUserCategories(int id_user)
		{
			IList<UserCategory> categories = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserCategory as userCategory where id_parent_user= :id_user");
				q.SetInt32("id_parent_user",id_user);	
				categories = q.List<UserCategory>();
				NHibernateHelper.closeSession();					
			}	
			return categories;		
		}					

		public IList<UserFieldsMatch> getUserFieldsMatch(int id_user)
		{
			IList<UserFieldsMatch> fields = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserFieldsMatch as userFieldsMatch where id_parent_user= :id_user");
				q.SetInt32("id_parent_user",id_user);	
				fields = q.List<UserFieldsMatch>();
				NHibernateHelper.closeSession();					
			}	
			return fields;		
		}				

		public UserGroup getDefaultUserGroup()
		{
			UserGroup group = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserGroup where defaultGroup=1");	
				group = q.UniqueResult<UserGroup>();
				NHibernateHelper.closeSession();					
			}	
			return group;		
		}	
		
		public UserGroup getUserGroup(User user)
		{
			UserGroup group = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserGroup where id= :id");
				q.SetInt32("id",user.userGroup);	
				group = q.UniqueResult<UserGroup>();
				NHibernateHelper.closeSession();					
			}	
			return group;		
		}		
		
		public UserGroup getUserGroupById(int id)
		{
			UserGroup group = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserGroup where id= :id");
				q.SetInt32("id",id);	
				group = q.UniqueResult<UserGroup>();
				NHibernateHelper.closeSession();					
			}	
			return group;		
		}			

		public IList<UserGroup> getAllUserGroup()
		{
			IList<UserGroup> groups = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserGroup");
				groups = q.List<UserGroup>();
				NHibernateHelper.closeSession();					
			}	
			return groups;		
		}

		public void insertUserGroup(UserGroup userGroup)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(userGroup);
				tx.Commit();
				NHibernateHelper.closeSession();				
			}			
		}

		public void updateUserGroup(UserGroup userGroup)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Update(userGroup);
				tx.Commit();
				NHibernateHelper.closeSession();				
			}			
		}

		public void deleteUserGroup(int id)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from UserGroup where id= :id").SetInt32("id",id).ExecuteUpdate();
				tx.Commit();
				NHibernateHelper.closeSession();				
			}			
		}		
		

		/**
		METHODS FOR USER CONFIRMATION
		*/
		public UserConfirmation getConfirmationCode(User user)
		{
			UserConfirmation userConfirmation = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserConfirmation as userConfirmation where id_user= :id_user");
				q.SetInt32("id_user",user.id);	
				userConfirmation = q.UniqueResult<UserConfirmation>();
				NHibernateHelper.closeSession();					
			}	
			return userConfirmation;		
		}

		public bool matchConfirmationCode(User user, string confirmationCodeCheck, out UserConfirmation userConfirmation)
		{
			bool match = false;
			userConfirmation = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserConfirmation as userConfirmation where id_user= :id_user and confirmationCode= :confirmationCode");
				q.SetInt32("id_user",user.id);		
				q.SetString("confirmationCode",confirmationCodeCheck);
				userConfirmation = q.UniqueResult<UserConfirmation>();
				match = (userConfirmation != null);
				NHibernateHelper.closeSession();					
			}	
			return match;		
		}

		public void insertConfirmationCode(UserConfirmation userConfirmation)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Save(userConfirmation);
				tx.Commit();
				NHibernateHelper.closeSession();				
			}			
		}

		public void deleteConfirmationCode(UserConfirmation userConfirmation)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Delete(userConfirmation);
				tx.Commit();
				NHibernateHelper.closeSession();				
			}			
		}


		public User login(User user)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				user.password=getMd5Hash(user.password);
				IQuery q = session.CreateQuery("from User as user where username= :username and password= :password and isActive=1");
				q.SetString("username",user.username);
				q.SetString("password",user.password);
				user = q.UniqueResult<User>();

				if(user != null){				
					user.attachments = session.CreateCriteria(typeof(UserAttachment))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idUser", user.id))
					.List<UserAttachment>();

					user.friends = session.CreateCriteria(typeof(UserFriend))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserFriend>();	

					user.languages = session.CreateCriteria(typeof(UserLanguage))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserLanguage>();		

					user.categories = session.CreateCriteria(typeof(UserCategory))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserCategory>();	

					user.newsletters = session.CreateCriteria(typeof(UserNewsletter))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserNewsletter>();					

					user.fields = session.CreateCriteria(typeof(UserFieldsMatch))
					.SetFetchMode("Permissions", FetchMode.Join)
					.Add(Restrictions.Eq("idParentUser", user.id))
					.List<UserFieldsMatch>();				
				}				
				
				NHibernateHelper.closeSession();					
			}	
			return user;
		}

		public string getMd5Hash(string input)
		{
			// Create a new instance of the MD5CryptoServiceProvider object.
			MD5 md5Hasher = MD5.Create();
		
			// Convert the input string to a byte array and compute the hash.
			byte[] data = md5Hasher.ComputeHash(Encoding.Default.GetBytes(input));
		
			// Create a new Stringbuilder to collect the bytes
			// and create a string.
			StringBuilder sBuilder = new StringBuilder();
		
			// Loop through each byte of the hashed data 
			// and format each one as a hexadecimal string.
			for (int i = 0; i < data.Length; i++)
			{
				sBuilder.Append(data[i].ToString("x2"));
			}
		
			// Return the hexadecimal string.
			return sBuilder.ToString();
		}	
		
		
		/*USER FIELDS METHODS*/
	
		public UserField getUserFieldById(int idField)
		{
			UserField result = null;			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				result = session.Get<UserField>(idField);
				NHibernateHelper.closeSession();
			}
			
			return result;		
		}
	
		public bool userFieldAlreadyExists(string description)
		{
			bool exist = false;
			IList<UserField> fields = null;
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserField where description=:description");
				q.SetString("description",description);	
				fields = q.List<UserField>();
				NHibernateHelper.closeSession();					
			}				
			if(fields!=null && fields.Count >0)
			{
				exist=true;
			}			
			return exist;		
		}
	
		public IList<UserField> getUserFields(string active, List<string> userFor, List<string> applyTo)
		{
			IList<UserField> results = null;
			
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				string sql = "from UserField  where 1=1";
				if(!String.IsNullOrEmpty(active)){
					sql += " and enabled= :enabled";
				}
				if(userFor != null && userFor.Count>0){
					sql+=string.Format(" and useFor in({0})",string.Join(",",userFor.ToArray()));
				}	
				if(applyTo != null && applyTo.Count>0){
					sql+=string.Format(" and applyTo in({0})",string.Join(",",applyTo.ToArray()));
				}
				sql += " order by sorting, groupDescription, description asc";
				
				IQuery q = session.CreateQuery(sql);
				if(!String.IsNullOrEmpty(active)){
				q.SetBoolean("enabled",Convert.ToBoolean(active));	
				}
				results = q.List<UserField>();
				NHibernateHelper.closeSession();
			}
			
			return results;		
		}
	
		public IList<UserFieldsValue> getUserFieldValues(int idField)
		{
			IList<UserFieldsValue> results = null;	
										
			string strSQL = "from UserFieldsValue where idParentField=:idParentField order by sorting asc";		
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL);	
				q.SetInt32("idParentField",idField);			
				results = q.List<UserFieldsValue>();		
				NHibernateHelper.closeSession();
			}
						
			return results;	
		}

		public void saveCompleteUserField(UserField field, IList<UserFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{					
				try{
					if(field.id != -1){
						session.Update(field);
						session.CreateQuery("delete from UserFieldsValue where idParentField=:idParentField").SetInt32("idParentField",field.id).ExecuteUpdate();
					}else{
						session.Save(field);
					}											
					// ************** AGGIUNGO i values se presenti
					foreach (UserFieldsValue ufv in fieldValues){
						ufv.idParentField =field.id; 
						session.Save(ufv);
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
		}
		
		public void updateUserField(UserField field)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.Update(field);
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteUserField(int idField)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from UserFieldsValue where idParentField=:idParentField").SetInt32("idParentField",idField).ExecuteUpdate();
				session.CreateQuery("delete from UserFieldsMatch where idParentField=:idParentField").SetInt32("idParentField",idField).ExecuteUpdate();	
				session.CreateQuery("delete from UserField where id=:id").SetInt32("id",idField).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public void deleteUserFieldValue(int idField, string fieldValue)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{
				session.CreateQuery("delete from UserFieldsValue where idParentField=:idParentField and value=:value").SetInt32("idParentField",idField).SetString("value",fieldValue).ExecuteUpdate();	
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}

		public IDictionary<string,int> getUniqueFieldsMatch(int idField)
		{
			IList matchs = null;
			IDictionary<string,int> results = null;					
			string strSQL = "from UserFieldsMatch where idParentField=:idParentField order by value asc";	
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery(strSQL).SetInt32("idParentField",idField);				
				matchs = q.List();		
				NHibernateHelper.closeSession();
			}				
			if(matchs!=null)
			{
				results = new Dictionary<string,int>();
				foreach(UserFieldsMatch x in matchs)
				{
					if(!results.ContainsKey(x.value)){
						results.Add(x.value, x.idParentField);
					}
				}
			}
			return results;				
		}
		
		public IList<string> findFieldNames()
		{
			IList names = null;
			IList<string> results = null;					
			string strSQL = "select distinct description from USER_FIELDS where not isnull(description) order by description asc";			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL+"<br>");
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("description", NHibernateUtil.String);				
				names = q.List();
				//System.Web.HttpContext.Current.Response.Write("results!=null: " + results!=null +"<br>");				
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
			string strSQL = "select distinct group_description from USER_FIELDS where not isnull(group_description) order by group_description asc";			
			//System.Web.HttpContext.Current.Response.Write("strSQL: " + strSQL+"<br>");
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateSQLQuery(strSQL).AddScalar("group_description", NHibernateUtil.String);				
				gnames = q.List();
				//System.Web.HttpContext.Current.Response.Write("results!=null: " + results!=null +"<br>");				
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

		public void insertDownload(UserDownload userDownload)
		{
			using (ISession session = NHibernateHelper.getCurrentSession())
			using (ITransaction tx = session.BeginTransaction())
			{				
				userDownload.downloadDate=DateTime.Now;
				session.Save(userDownload);		
				
				tx.Commit();
				NHibernateHelper.closeSession();
			}
		}
		
		public IList<UserDownload> getUserDownloads()
		{
			IList<UserDownload> results = null;	
											
			using (ISession session = NHibernateHelper.getCurrentSession())
			{
				IQuery q = session.CreateQuery("from UserDownload order by downloadDate desc");			
				results = q.List<UserDownload>();		
				NHibernateHelper.closeSession();
			}
						
			return results;	
		}		
	}
}