using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserFriend
	{	
		private int _friend;
		private int _idParentUser;
		private bool _isActive;
		
		public UserFriend(){}

		public virtual int idParentUser {
			get { return _idParentUser; }
			set { _idParentUser = value; }
		}

		public virtual int friend {
			get { return _friend; }
			set { _friend = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}
		
		public override bool Equals(object obj)
		{
			UserFriend other = obj as UserFriend;
			if (other == null)
				return false;

			return other.friend == this.friend &&
				other.idParentUser == this.idParentUser;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentUser;
				result = (result * 397) ^ _friend;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserFriend idParentUser: ")
			.Append(this._idParentUser)
			.Append(" - friend: ").Append(this._friend)
			.Append(" - isActive: ").Append(this._isActive);
			
			return builder.ToString();			
		}
	}
}