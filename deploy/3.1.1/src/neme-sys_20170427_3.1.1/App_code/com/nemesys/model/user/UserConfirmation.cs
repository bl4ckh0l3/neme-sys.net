using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserConfirmation
	{	
		private int _idUser;
		private string _confirmationCode;
		
		public UserConfirmation(){}

		public UserConfirmation(int idUser, string confirmationCode){
			this._idUser = idUser;
			this._confirmationCode = confirmationCode;
		}

		public virtual int idUser {
			get { return _idUser; }
			set { _idUser = value; }
		}

		public virtual string confirmationCode {
			get { return _confirmationCode; }
			set { _confirmationCode = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserConfirmation idUser: ")
			.Append(this._idUser)
			.Append(" - confirmationCode: ").Append(this._confirmationCode);
			
			return builder.ToString();			
		}
	}
}