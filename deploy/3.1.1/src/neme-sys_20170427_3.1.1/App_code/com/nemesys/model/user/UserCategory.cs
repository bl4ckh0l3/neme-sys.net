using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserCategory
	{	
		private int _idCategory;
		private int _idParentUser;
		
		public UserCategory(){}
		
		public UserCategory(int idParentUser, int idCategory){
			this._idParentUser=idParentUser;
			this._idCategory=idCategory;
		}

		public virtual int idParentUser {
			get { return _idParentUser; }
			set { _idParentUser = value; }
		}

		public virtual int idCategory {
			get { return _idCategory; }
			set { _idCategory = value; }
		}
		
		public override bool Equals(object obj)
		{
			UserCategory other = obj as UserCategory;
			if (other == null)
				return false;

			return other.idCategory == this._idCategory &&
				other.idParentUser == this._idParentUser;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentUser;
				result = (result * 397) ^ _idCategory;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserCategory idParentUser: ")
			.Append(this._idParentUser)
			.Append(" - idCategory: ").Append(this._idCategory);
			
			return builder.ToString();			
		}
	}
}