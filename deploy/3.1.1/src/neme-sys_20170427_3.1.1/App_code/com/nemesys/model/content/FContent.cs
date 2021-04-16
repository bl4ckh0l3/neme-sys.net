using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class FContent
	{	
		private int _id;
		private string _title;
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
		private IList<ContentAttachment> _attachments;
		private IList<ContentLanguage> _languages;
		private IList<ContentCategory> _categories;
		private IList<ContentField> _fields;

		
		public FContent(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string title {
			get { return _title; }
			set { _title = value; }
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
	
		public virtual IList<ContentAttachment> attachments {
			get { return _attachments; }
			set { _attachments = value; }
		}

		public virtual IList<ContentLanguage> languages {
			get { return _languages; }
			set { _languages = value; }
		}

		public virtual IList<ContentCategory> categories {
			get { return _categories; }
			set { _categories = value; }
		}

		public virtual IList<ContentField> fields {
			get { return _fields; }
			set { _fields = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("FContent: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - title: ").Append(this._title)
			.Append(" - summary: ").Append(this._summary)
			.Append(" - description: ").Append(this._description)
			.Append(" - keyword: ").Append(this._keyword)
			.Append(" - status: ").Append(this._status)
			.Append(" - pageTitle: ").Append(this._pageTitle)
			.Append(" - metaKeyword: ").Append(this._metaKeyword)
			.Append(" - metaDescription: ").Append(this._metaDescription)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - publishDate: ").Append(this._publishDate)
			.Append(" - deleteDate: ").Append(this._deleteDate);
			
			return builder.ToString();			
		}
	}
}