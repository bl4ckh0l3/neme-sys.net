using System;
using System.Text;

namespace com.nemesys.model
{
	public class FeeConfig
	{	
		private int _id;
		private int _idFee;
		private string _descProdField;
		private decimal _rateFrom;
		private decimal _rateTo;
		private int _operation;
		private decimal _value;
		
		public FeeConfig(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idFee {
			get { return _idFee; }
			set { _idFee = value; }
		}

		public virtual string descProdField {
			get { return _descProdField; }
			set { _descProdField = value; }
		}

		public virtual decimal rateFrom {
			get { return _rateFrom; }
			set { _rateFrom = value; }
		}

		public virtual decimal rateTo {
			get { return _rateTo; }
			set { _rateTo = value; }
		}

		public virtual int operation {
			get { return _operation; }
			set { _operation = value; }
		}

		public virtual decimal value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("FeeConfig: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idFee: ").Append(this._idFee)
			.Append(" - descProdField: ").Append(this._descProdField)
			.Append(" - rateFrom: ").Append(this._rateFrom.ToString())
			.Append(" - rateTo: ").Append(this._rateTo.ToString())
			.Append(" - operation: ").Append(this._operation)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}