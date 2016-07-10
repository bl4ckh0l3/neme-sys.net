using System;
using System.Text;

namespace com.nemesys.model
{
	public class VoucherCode
	{	
		private int _id;
		private string _code;
		private int _campaign;
		private int _usageCounter;
		private int _userId;
		private DateTime _insertDate;
		
		
		public VoucherCode(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string code {
			get { return _code; }
			set { _code = value; }
		}
		
		public virtual int campaign {
			get { return _campaign; }
			set { _campaign = value; }
		}

		public virtual int usageCounter {
			get { return _usageCounter; }
			set { _usageCounter = value; }
		}	

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}	

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}			
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("VoucherCode: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - code: ").Append(this._code)
			.Append(" - campaign: ").Append(this._campaign)
			.Append(" - usageCounter: ").Append(this._usageCounter)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}