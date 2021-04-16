using System;
using System.Text;

namespace com.nemesys.model
{
	public class Logger
	{	
		private int _id;
		private string _msg;
		private string _usr;
		private string _type;
		private DateTime _date;
		
		public Logger(){}
		
		public Logger(string msg, string usr, string type, DateTime date)
		{
			this._msg=msg;
			this._usr=usr;
			this._type=type;
			this._date=date;			
		}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string msg {
			get { return _msg; }
			set { _msg = value; }
		}

		public virtual string usr {
			get { return _usr; }
			set { _usr = value; }
		}

		public virtual string type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual DateTime date {
			get { return _date; }
			set { _date = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Logger id: ")
			.Append(this._id)
			.Append(" - msg: ").Append(this._msg)
			.Append(" - usr: ").Append(this._usr)
			.Append(" - type: ").Append(this._type)
			.Append(" - date: ").Append(this._date);
			
			return builder.ToString();			
		}
	}
}