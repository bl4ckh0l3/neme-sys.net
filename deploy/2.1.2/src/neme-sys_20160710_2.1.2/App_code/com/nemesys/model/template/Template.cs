using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Template
	{	
		private int _id;
		private string _directory;
		private string _langCode;
		private string _description;
		private bool _isBase;
		private int _orderBy;
		private int _elemXpage;
		private DateTime _modifyDate;
		private IList<TemplatePage> _pages;
		
		public Template(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string directory {
			get { return _directory; }
			set { _directory = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual bool isBase {
			get { return _isBase; }
			set { _isBase = value; }
		}

		public virtual int orderBy {
			get { return _orderBy; }
			set { _orderBy = value; }
		}

		public virtual int elemXpage {
			get { return _elemXpage; }
			set { _elemXpage = value; }
		}

		public virtual DateTime modifyDate {
			get { return _modifyDate; }
			set { _modifyDate = value; }
		}
	
		public virtual IList<TemplatePage> pages {
			get { return _pages; }
			set { _pages = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Template: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - directory: ").Append(this._directory)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - description: ").Append(this._description)
			.Append(" - isBase: ").Append(this._isBase)
			.Append(" - orderBy: ").Append(this._orderBy)
			.Append(" - elemXpage: ").Append(this._elemXpage)
			.Append(" - modifyDate: ").Append(this._modifyDate);
			
			return builder.ToString();			
		}
	}
}