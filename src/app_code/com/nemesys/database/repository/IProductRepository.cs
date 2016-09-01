using System;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;

namespace com.nemesys.database.repository
{
	public interface IProductRepository : IRepository<Product>
	{		
		void insert(Product product);
		
		void update(Product product);
		
		void delete(Product product);
		
		Product clone(Product product);
		
		Product getById(int id);
		Product getByIdCached(int id, bool cached);
		
		void saveCompleteProduct(Product product, IList<Geolocalization> listOfPoints, IList<ProductMainFieldTranslation> mainFieldsTrans, IDictionary<string,string> qtyFieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
		
		IList<Product> find(string name, string keyword, string status, int userId, string prodType, string qryRotationMode, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool withProdRel, bool withProdCal, bool cached);
		
		IList<Product> find(string name, string keyword, string status, int userId, string prodType, string qryRotationMode, string publishDate, string deleteDate, int orderBy, IList<int> matchCategories, IList<int> matchLanguages, bool withAttach, bool withLang, bool withCats, bool withFields, bool withProdRel, bool withProdCal, int pageIndex, int pageSize,out long totalCount);

		void changeQuantity(int idProduct, int quantity);
		
		IList<ProductAttachment> getProductAttachments(int idProduct);		
		void deleteProductAttachment(int idAttach);		
		ProductAttachment getProductAttachmentById(int idAttach);
	
		IList<ProductAttachmentDownload> getProductAttachmentDownloads(int idProduct);		
		void deleteProductAttachmentDownload(int idAttach);		
		ProductAttachmentDownload getProductAttachmentDownloadById(int idAttach);		
	
		IList<ProductAttachmentLabel> getProductAttachmentLabel();
		IList<ProductAttachmentLabel> getProductAttachmentLabelCached(bool cached);
		
		ProductAttachmentLabel insertProductAttachmentLabel(string newdescription);
		
		void deleteProductAttachmentLabel(int idAttachLabel);
		
		IList<ProductLanguage> getProductLanguages(int idProduct);
		
		IList<ProductCategory> getProductCategories(int idProduct);
		
		IList<ProductField> getProductFields(int idProduct, Nullable<bool> active, Nullable<bool> common);
		IList<ProductField> getProductFieldsCached(int idProduct, Nullable<bool> active, Nullable<bool> common, bool cached);
		
		ProductFieldsValue getProductFieldValue(int idField, string value);
		ProductFieldsValue getProductFieldValueCached(int idField, string value, bool cached);
		
		IList<ProductFieldsValue> getProductFieldValues(int idField);		
		IList<ProductFieldsValue> getProductFieldValuesCached(int idField, bool cached);
		
		IList<string> getProductFieldValuesByDescription(string description, Nullable<bool> common, Nullable<bool> active);
		IList<string> getProductFieldValuesByDescriptionCached(string description, Nullable<bool> common, Nullable<bool> active, bool cached);

		ProductField getProductFieldById(int idField);		
		ProductField getProductFieldByIdCached(int idField, bool cached);
		
		IList<ProductFieldsRelValue> getProductFieldRelValues(int idProduct, int idField, string fieldValue);
		IList<ProductFieldsRelValue> getProductFieldRelValuesCached(int idProduct, int idField, string fieldValue, bool cached);
		
		void insertProductFieldRelValue(int idProduct, int idField, string fieldValue, int idFieldRel, string fieldRelValue, int quantity, string fieldDesc);
		void deleteProductFieldRelValue(int idProduct, int idField, string fieldValue, int idFieldRel, string fieldRelValue);

		void saveCompleteProductField(ProductField field, IList<ProductFieldsValue> fieldValues, IList<MultiLanguage> newtranslactions, IList<MultiLanguage> updtranslactions, IList<MultiLanguage> deltranslactions);
				
		void updateProductField(ProductField field);
		
		void deleteProductField(int idField);
		
		void deleteProductFieldValue(int idField, string fieldValue);
		
		IList<string> findFieldNames();
		
		IList<string> findFieldGroupNames();
		
		ProductMainFieldTranslation getMainFieldTranslation(int idProd, int mainField , string langCode, bool useDef, string defValue);
		
		ProductMainFieldTranslation getMainFieldTranslationCached(int idProd, int mainField , string langCode, bool useDef, string defValue, bool cached);
		
		IList<ProductMainFieldTranslation> getProductMainFieldsTranslation(int idProd, int mainField , string langCode);
		
		IList<ProductMainFieldTranslation> getProductMainFieldsTranslationCached(int idProd, int mainField , string langCode, bool cached);
		
		void saveMainFieldTranslation(ProductMainFieldTranslation pmft, int idProd, int mainField, string langCode);
		
		ProductRotation getProductRotation(int idProd, int rotationMode);
		
		void insertProductRotation(ProductRotation rotation);
		
		void deleteProductRotation(int idParent, int idRotation);
		
		void deleteProductRotationByProd(int idParent);
		
		void saveCompleteProductRotation(int idParent, int reloadQuantity, ProductRotation rotation);
	}
}