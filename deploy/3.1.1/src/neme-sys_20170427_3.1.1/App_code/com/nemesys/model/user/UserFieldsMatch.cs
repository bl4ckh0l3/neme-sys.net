using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserFieldsMatch
	{	
		private int _idParentField;
		private int _idParentUser;
		private string _value;
		
		public UserFieldsMatch(){}

		public virtual int idParentField {
			get { return _idParentField; }
			set { _idParentField = value; }
		}

		public virtual int idParentUser {
			get { return _idParentUser; }
			set { _idParentUser = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}
		
		public override bool Equals(object obj)
		{
			UserFieldsMatch other = obj as UserFieldsMatch;
			if (other == null)
				return false;

			return other.idParentField == this._idParentField &&
				other.idParentUser == this._idParentUser &&
				other.value == this._value;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentField;
				result = (result * 397) ^ _idParentUser;
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserFieldsMatch: ")
			.Append(" - idParentField: ").Append(this._idParentField)
			.Append(" - idParentUser: ").Append(this._idParentUser)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}