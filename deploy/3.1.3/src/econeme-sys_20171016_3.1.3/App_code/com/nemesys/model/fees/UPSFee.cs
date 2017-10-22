using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class UPSFee
	{
		private decimal _amount;
		private string _currency;
		private string _extResponse;
		private bool _success;

		
		public UPSFee(){}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual string extResponse {
			get { return _extResponse; }
			set { _extResponse = value; }
		}

		public virtual string currency {
			get { return _currency; }
			set { _currency = value; }
		}

		public virtual bool success {
			get { return _success; }
			set { _success = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UPSFee: ")
			.Append(" - amount: ").Append(this._amount)
			.Append(" - currency: ").Append(this._currency)
			.Append(" - extResponse: ").Append(this._extResponse)
			.Append(" - success: ").Append(this._success);
			
			return builder.ToString();			
		}
	}
}