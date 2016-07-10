using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IContentRepository : IRepository<FContent>
	{		
		void insert(FContent content);
		
		void update(FContent content);
		
		void delete(FContent content);
		
		FContent clone(FContent original);
		
		FContent getById(int id);
		FContent getByIdCached(int id, bool cached);
		
		void saveCompleteContent(FContent content, IList<Geolocalization> listOfPoints);
		
		IList<FContent> find(string title, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool cached);
		
		IList<FContent> find(string title, string keyword, string status, int userId, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, int pageIndex, int pageSize,out long totalCount);
	
		IList<ContentAttachment> getContentAttachments(int idContent);
		
		void deleteContentAttachment(int idAttach);
		
		ContentAttachment getContentAttachmentById(int idAttach);
	
		IList<ContentAttachmentLabel> getContentAttachmentLabel();
		IList<ContentAttachmentLabel> getContentAttachmentLabelCached(bool cached);
		
		ContentAttachmentLabel insertContentAttachmentLabel(string newdescription);
		
		void deleteContentAttachmentLabel(int idAttachLabel);
		
		IList<ContentLanguage> getContentLanguages(int idContent);
		
		IList<ContentCategory> getContentCategories(int idContent);
		
		IList<ContentField> getContentFields(int idContent, Nullable<bool> active, Nullable<bool> forBlog, Nullable<bool> common);
		IList<ContentField> getContentFieldsCached(int idContent, Nullable<bool> active, Nullable<bool> forBlog, Nullable<bool> common, bool cached);
		
		IList<ContentFieldsValue> getContentFieldValues(int idField);
		
		IList<ContentFieldsValue> getContentFieldValuesCached(int idField, bool cached);
		
		IList<string> getContentFieldValuesByDescription(string description, Nullable<bool> common, Nullable<bool> active);
		IList<string> getContentFieldValuesByDescriptionCached(string description, Nullable<bool> common, Nullable<bool> active, bool cached);

		ContentField getContentFieldById(int idField);
		
		ContentField getContentFieldByIdCached(int idField, bool cached);

		void saveCompleteContentField(ContentField field, IList<ContentFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
				
		void updateContentField(ContentField field);
		
		void deleteContentField(int idField);
		
		void deleteContentFieldValue(int idField, string fieldValue);
		
		IList<string> findFieldNames(bool forBlog);
		
		IList<string> findFieldGroupNames(bool forBlog);
	}
}