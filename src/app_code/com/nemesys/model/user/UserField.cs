using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserField : IComparable<UserField>
	{	
		private int _id;
		private string _description;
		private string _groupDescription;
		private int _type;
		private int _typeContent;
		private int _sorting;
		private bool _required;
		private bool _enabled;
		private int _maxLenght;
		private int _useFor;
		private int _applyTo;
		
		public UserField(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string groupDescription {
			get { return _groupDescription; }
			set { _groupDescription = value; }
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

		public virtual int maxLenght {
			get { return _maxLenght; }
			set { _maxLenght = value; }
		}

		public virtual int useFor {
			get { return _useFor; }
			set { _useFor = value; }
		}

		public virtual int applyTo {
			get { return _applyTo; }
			set { _applyTo = value; }
		}

		public virtual int CompareTo(UserField other)
		{
			int val = this._sorting.CompareTo(other.sorting);
			return val;
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserField: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description)
			.Append(" - groupDescription: ").Append(this._groupDescription)
			.Append(" - type: ").Append(this._type)
			.Append(" - typeContent: ").Append(this._typeContent)
			.Append(" - sorting: ").Append(this._sorting)
			.Append(" - required: ").Append(this._required)
			.Append(" - enabled: ").Append(this._enabled)
			.Append(" - maxLenght: ").Append(this._maxLenght)
			.Append(" - usefor: ").Append(this._useFor)
			.Append(" - applyTo: ").Append(this._applyTo);
			
			return builder.ToString();			
		}
	}
}