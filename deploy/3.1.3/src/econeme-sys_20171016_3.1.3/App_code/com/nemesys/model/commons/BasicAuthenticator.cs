using System;
using System.Text;

namespace com.nemesys.model
{
	public class BasicAuthenticator
	{	
		private string _user;
		private string _password;
		
		public BasicAuthenticator(){}
		
		public BasicAuthenticator(string user, string password){
			this._user=user;
			this._password=password;
		}

		public virtual string user {
			get { return _user; }
			set { _user = value; }
		}

		public virtual string password {
			get { return _password; }
			set { _password = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("BasicAuthenticator: ")
			.Append(" - user: ").Append(this._user)
			.Append(" - password: ").Append(this._password);
			
			return builder.ToString();			
		}
	}
}