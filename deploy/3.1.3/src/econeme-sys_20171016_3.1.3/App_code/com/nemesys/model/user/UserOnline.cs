using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserOnline
	{	
		private DateTime _entryDate;
		private User _userOnline;
		
		public UserOnline(){}

		public virtual DateTime entryDate {
			get { return _entryDate; }
			set { _entryDate = value; }
		}

		public virtual User userOnline {
			get { return _userOnline; }
			set { _userOnline = value; }
		}
	}
}