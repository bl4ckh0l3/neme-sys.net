using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserLanguage
	{	
		private int _idLanguage;
		private int _idParentUser;
		
		public UserLanguage(){}

		public virtual int idParentUser {
			get { return _idParentUser; }
			set { _idParentUser = value; }
		}

		public virtual int idLanguage {
			get { return _idLanguage; }
			set { _idLanguage = value; }
		}
		
		public override bool Equals(object obj)
		{
			UserLanguage other = obj as UserLanguage;
			if (other == null)
				return false;

			return other.idLanguage == this._idLanguage &&
				other.idParentUser == this._idParentUser;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentUser;
				result = (result * 397) ^ _idLanguage;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserLanguage idParentUser: ")
			.Append(this._idParentUser)
			.Append(" - idLanguage: ").Append(this._idLanguage);
			
			return builder.ToString();			
		}
	}
}