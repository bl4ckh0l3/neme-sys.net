using System;
using System.Text;

namespace com.nemesys.model
{
	public class ContentField : IComparable<ContentField>
	{	
		private int _id;
		private int _idParentContent;
		private string _description;
		private string _groupDescription;
		private string _value;
		private int _type;
		private int _typeContent;
		private int _sorting;
		private bool _required;
		private bool _enabled;
		private bool _editable;
		private bool _forBlog;
		private bool _common;
		private int _maxLenght;
		
		public ContentField(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idParentContent {
			get { return _idParentContent; }
			set { _idParentContent = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string groupDescription {
			get { return _groupDescription; }
			set { _groupDescription = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual int typeContent {
			get { return _typeContent; }
			set { _typeContent = value; }
		}

		public virtual int sorting {
			get { return _sorting; }
			set { _sorting = value; }
		}

		public virtual bool required {
			get { return _required; }
			set { _required = value; }
		}

		public virtual bool enabled {
			get { return _enabled; }
			set { _enabled = value; }
		}

		public virtual bool editable {
			get { return _editable; }
			set { _editable = value; }
		}

		public virtual bool forBlog {
			get { return _forBlog; }
			set { _forBlog = value; }
		}

		public virtual bool common {
			get { return _common; }
			set { _common = value; }
		}

		public virtual int maxLenght {
			get { return _maxLenght; }
			set { _maxLenght = value; }
		}

		public virtual int CompareTo(ContentField other)
		{
			int val = this._sorting.CompareTo(other.sorting);
			//System.Web.HttpContext.Current.Response.Write("this._hierarchy:"+this._hierarchy+" - other._hierarchy:"+other._hierarchy+" - compareTo val:"+val+"<br>");
			return val;
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ContentField: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idParentContent: ").Append(this._idParentContent)
			.Append(" - description: ").Append(this._description)
			.Append(" - groupDescription: ").Append(this._groupDescription)
			.Append(" - value: ").Append(this._value)
			.Append(" - type: ").Append(this._type)
			.Append(" - typeContent: ").Append(this._typeContent)
			.Append(" - sorting: ").Append(this._sorting)
			.Append(" - required: ").Append(this._required)
			.Append(" - enabled: ").Append(this._enabled)
			.Append(" - editable: ").Append(this._editable)
			.Append(" - forBlog: ").Append(this._forBlog)
			.Append(" - common: ").Append(this._common)
			.Append(" - maxLenght: ").Append(this._maxLenght);
			
			return builder.ToString();			
		}
	}
}