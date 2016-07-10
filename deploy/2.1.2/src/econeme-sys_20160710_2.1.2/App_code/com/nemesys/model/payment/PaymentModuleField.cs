using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class PaymentModuleField : IPaymentField
	{	
		private int _id;
		private int _idPayment;
		private int _idModule;
		private string _keyword;
		private string _value;
		private string _matchField;	

		
		public PaymentModuleField(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}
		
		public virtual int idPayment {
			get { return -1; }
			set { _idPayment = -1; }
		}

		public virtual int idModule {
			get { return _idModule; }
			set { _idModule = value; }
		}

		public virtual string keyword {
			get { return _keyword; }
			set { _keyword = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual string matchField {
			get { return _matchField; }
			set { _matchField = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("PaymentModuleField: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idPayment: ").Append(this._idPayment)
			.Append(" - idModule: ").Append(this._idModule)
			.Append(" - keyword: ").Append(this._keyword)
			.Append(" - value: ").Append(this._value)
			.Append(" - matchField: ").Append(this._matchField);
			
			return builder.ToString();			
		}
	}
}