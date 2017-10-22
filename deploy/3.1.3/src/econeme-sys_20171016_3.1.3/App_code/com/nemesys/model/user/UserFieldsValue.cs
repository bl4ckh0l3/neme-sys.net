using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserFieldsValue : IComparable<UserFieldsValue>
	{	
		private int _idParentField;
		private string _value;
		private int _sorting;
		
		public UserFieldsValue(){}

		public virtual int idParentField {
			get { return _idParentField; }
			set { _idParentField = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual int sorting {
			get { return _sorting; }
			set { _sorting = value; }
		}

		public virtual int CompareTo(UserFieldsValue other)
		{
			int val = this._sorting.CompareTo(other.sorting);
			//System.Web.HttpContext.Current.Response.Write("this._hierarchy:"+this._hierarchy+" - other._hierarchy:"+other._hierarchy+" - compareTo val:"+val+"<br>");
			return val;
		}
		
		public override bool Equals(object obj)
		{
			UserFieldsValue other = obj as UserFieldsValue;
			if (other == null)
				return false;

			return other.idParentField == this._idParentField &&
				other.value == this._value &&
				other.sorting == this._sorting;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentField;
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				result = (result * 397) ^ _sorting;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserFieldsValue: ")
			.Append(" - idParentField: ").Append(this._idParentField)
			.Append(" - value: ").Append(this._value)
			.Append(" - sorting: ").Append(this._sorting);
			
			return builder.ToString();			
		}
	}
}