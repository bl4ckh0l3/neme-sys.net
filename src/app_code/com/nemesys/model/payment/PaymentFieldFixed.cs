using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class PaymentFieldFixed
	{	
		private int _id;
		private string _keyword;
		private string _value;
		private bool _used;	

		
		public PaymentFieldFixed(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string keyword {
			get { return _keyword; }
			set { _keyword = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual bool used {
			get { return _used; }
			set { _used = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("PaymentFieldFixed: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - keyword: ").Append(this._keyword)
			.Append(" - value: ").Append(this._value)
			.Append(" - used: ").Append(this._used);
			
			return builder.ToString();			
		}
	}
}