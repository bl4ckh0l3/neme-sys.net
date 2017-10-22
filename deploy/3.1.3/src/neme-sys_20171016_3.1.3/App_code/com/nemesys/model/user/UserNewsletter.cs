using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserNewsletter
	{	
		private int _idParentUser;
		private int _newsletterId;
		
		public UserNewsletter(){}

		public virtual int idParentUser {
			get { return _idParentUser; }
			set { _idParentUser = value; }
		}

		public virtual int newsletterId {
			get { return _newsletterId; }
			set { _newsletterId = value; }
		}
		
		public override bool Equals(object obj)
		{
			UserNewsletter other = obj as UserNewsletter;
			if (other == null)
				return false;

			return other.newsletterId == this._newsletterId &&
				other.idParentUser == this._idParentUser;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentUser;
				result = (result * 397) ^ _newsletterId;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserNewsletter idParentUser: ")
			.Append(this._idParentUser)
			.Append(" - newsletterId: ").Append(this._newsletterId);
			
			return builder.ToString();			
		}
	}
}