using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Product
	{	
		private int _id;
		private string _name;
		private string _summary;
		private string _description;
		private string _keyword;
		private int _status;
		private string _pageTitle;
		private string _metaKeyword;
		private string _metaDescription;
		private int _userId;
		private DateTime _insertDate;
		private DateTime _publishDate;
		private DateTime _deleteDate;
		private IList<ProductAttachment> _attachments;
		private IList<ProductAttachmentDownload> _dattachments;
		private IList<ProductLanguage> _languages;
		private IList<ProductCategory> _categories;
		private IList<ProductRelation> _relations;
		private IList<ProductField> _fields;
		private decimal _price;
		private decimal _discount;
		private int _quantity;
		private int _idSupplement;
		private int _idSupplementGroup;
		private int _prodType;
		private bool _setBuyQta;
		private int _maxDownload;
		private int _maxDownloadTime;
		private int _quantityRotationMode;
		private string _rotationModeValue;
		private int _reloadQuantity;
		
		
		public Product(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual string summary {
			get { return _summary; }
			set { _summary = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string keyword {
			get { return _keyword; }
			set { _keyword = value; }
		}

		public virtual int status {
			get { return _status; }
			set { _status = value; }
		}

		public virtual string pageTitle {
			get { return _pageTitle; }
			set { _pageTitle = value; }
		}

		public virtual string metaKeyword {
			get { return _metaKeyword; }
			set { _metaKeyword = value; }
		}

		public virtual string metaDescription {
			get { return _metaDescription; }
			set { _metaDescription = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime publishDate {
			get { return _publishDate; }
			set { _publishDate = value; }
		}

		public virtual DateTime deleteDate {
			get { return _deleteDate; }
			set { _deleteDate = value; }
		}
	
		public virtual IList<ProductAttachment> attachments {
			get { return _attachments; }
			set { _attachments = value; }
		}
	
		public virtual IList<ProductAttachmentDownload> dattachments {
			get { return _dattachments; }
			set { _dattachments = value; }
		}

		public virtual IList<ProductLanguage> languages {
			get { return _languages; }
			set { _languages = value; }
		}

		public virtual IList<ProductCategory> categories {
			get { return _categories; }
			set { _categories = value; }
		}

		public virtual IList<ProductRelation> relations {
			get { return _relations; }
			set { _relations = value; }
		}

		public virtual IList<ProductField> fields {
			get { return _fields; }
			set { _fields = value; }
		}

		public virtual decimal price {
			get { return _price; }
			set { _price = value; }
		}

		public virtual decimal discount {
			get { return _discount; }
			set { _discount = value; }
		}

		public virtual int quantity {
			get { return _quantity; }
			set { _quantity = value; }
		}

		public virtual int idSupplement {
			get { return _idSupplement; }
			set { _idSupplement = value; }
		}

		public virtual int idSupplementGroup {
			get { return _idSupplementGroup; }
			set { _idSupplementGroup = value; }
		}

		public virtual int prodType {
			get { return _prodType; }
			set { _prodType = value; }
		}

		public virtual bool setBuyQta {
			get { return _setBuyQta; }
			set { _setBuyQta = value; }
		}

		public virtual int maxDownload {
			get { return _maxDownload; }
			set { _maxDownload = value; }
		}

		public virtual int maxDownloadTime {
			get { return _maxDownloadTime; }
			set { _maxDownloadTime = value; }
		}

		public virtual int quantityRotationMode {
			get { return _quantityRotationMode; }
			set { _quantityRotationMode = value; }
		}

		public virtual string rotationModeValue {
			get { return _rotationModeValue; }
			set { _rotationModeValue = value; }
		}

		public virtual int reloadQuantity {
			get { return _reloadQuantity; }
			set { _reloadQuantity = value; }
		}
	
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Product: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - name: ").Append(this._name)
			.Append(" - summary: ").Append(this._summary)
			.Append(" - description: ").Append(this._description)
			.Append(" - keyword: ").Append(this._keyword)
			.Append(" - status: ").Append(this._status)
			.Append(" - pageTitle: ").Append(this._pageTitle)
			.Append(" - metaKeyword: ").Append(this._metaKeyword)
			.Append(" - metaDescription: ").Append(this._metaDescription)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - publishDate: ").Append(this._publishDate)
			.Append(" - deleteDate: ").Append(this._deleteDate)
			.Append(" - price: ").Append(this._price)
			.Append(" - discount: ").Append(this._discount)
			.Append(" - quantity: ").Append(this._quantity)
			.Append(" - setBuyQta: ").Append(this._setBuyQta)
			.Append(" - maxDownload: ").Append(this._maxDownload)
			.Append(" - maxDownloadTime: ").Append(this._maxDownloadTime)
			.Append(" - quantityRotationMode: ").Append(this._quantityRotationMode)
			.Append(" - rotationModeValue: ").Append(this._rotationModeValue)
			.Append(" - reloadQuantity: ").Append(this._reloadQuantity);
			
			return builder.ToString();			
		}
	}
}