using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IUserRepository : IRepository<User>
	{		
		void insert(User user);
		
		void update(User user);
		
		void delete(User user);
		
		bool delete(User user, bool forceDelete);
		
		User getById(int id);
		
		User getByParams(int id, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields);
		
		User findById(int id, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields);
		
		User getByMail(string email);
		
		User getByUsernameAndMail(string username, string email);
		
		bool userAlreadyExists(string username, string email, int userid);
		
		void saveCompleteUser(User user, string confirmationCode);
		
		IList<User> find(bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields);
		
		IList<User> find(string userNameOrMail, string roles, string active, string isPublic, string automatic, int order_by, int pageIndex, int pageSize,out long totalCount);
		
		IList<User> find(string userNameOrMail, string roles, string active, string isPublic, string automatic, int order_by, bool withAttach, bool withFriend, bool withLang, bool withCats, bool withNewsletters, bool withFields);
		
		UserConfirmation getConfirmationCode(User user);
		
		UserGroup getDefaultUserGroup();
		
		UserGroup getUserGroup(User user);
		
		UserGroup getUserGroupById(int id);
		
		IList<UserGroup> getAllUserGroup();
		
		void insertUserGroup(UserGroup userGroup);
		
		void updateUserGroup(UserGroup userGroup);
		
		void deleteUserGroup(int id);

 		bool matchConfirmationCode(User user, string confirmationCodeCheck, out UserConfirmation userConfirmation);

		void insertConfirmationCode(UserConfirmation userConfirmation);

		void deleteConfirmationCode(UserConfirmation userConfirmation);

 		User login(User user);
		
		IList<UserFriend> getUserFriends(int id_user);
		
		IList<UserAttachment> getUserAttachments(int id_user);
		
		IList<UserLanguage> getUserLanguages(int id_user);
		
		IList<UserCategory> getUserCategories(int id_user);
		
		string getMd5Hash(string input);
		
		
		// methods for user fields		
		IList<UserFieldsMatch> getUserFieldsMatch(int id_user);
		
		IDictionary<string,int> getUniqueFieldsMatch(int idField);
		
		IList<UserField> getUserFields(string active, List<string> userFor, List<string> applyTo);
		
		IList<UserFieldsValue> getUserFieldValues(int idField);		

		UserField getUserFieldById(int idField);		
		
		bool userFieldAlreadyExists(string description);

		void saveCompleteUserField(UserField field, IList<UserFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);

		void updateUserField(UserField field);
				
		void deleteUserField(int idField);
		
		void deleteUserFieldValue(int idField, string fieldValue);
		
		IList<string> findFieldNames();
		
		IList<string> findFieldGroupNames();	

		void insertDownload(UserDownload userDownload);

		IList<UserDownload> getUserDownloads();
	}
}