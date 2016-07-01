using System;
using System.Text;

namespace com.nemesys.model
{
	public class FeeStrategyField
	{	
		private string _descField;
		private int _quantity;
		private decimal _value;
		
		public FeeStrategyField(){}

		public virtual string descField {
			get { return _descField; }
			set { _descField = value; }
		}

		public virtual int quantity {
			get { return _quantity; }
			set { _quantity = value; }
		}

		public virtual decimal value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("FeeStrategyField: ")
			.Append(" - descField: ").Append(this._descField)
			.Append(" - quantity: ").Append(this._quantity)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}