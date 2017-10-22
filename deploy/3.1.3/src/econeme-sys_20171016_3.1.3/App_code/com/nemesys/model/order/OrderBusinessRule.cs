using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderBusinessRule
	{  			
		private int _ruleId;
		private int _orderId;
		private int _productId;
		private int _productCounter;
		private int _ruleType;
		private string _label;
		private decimal _value;
		
		public OrderBusinessRule(){}

		public virtual int ruleId {
			get { return _ruleId; }
			set { _ruleId = value; }
		}

		public virtual int orderId {
			get { return _orderId; }
			set { _orderId = value; }
		}

		public virtual int productId {
			get { return _productId; }
			set { _productId = value; }
		}

		public virtual int productCounter {
			get { return _productCounter; }
			set { _productCounter = value; }
		}

		public virtual int ruleType {
			get { return _ruleType; }
			set { _ruleType = value; }
		}

		public virtual string label {
			get { return _label; }
			set { _label = value; }
		}

		public virtual decimal value {
			get { return _value; }
			set { _value = value; }
		}
		
		public override bool Equals(object obj) 
		{
			OrderBusinessRule other = obj as OrderBusinessRule;
			if (other == null) 
				return false;
			
			return other.ruleId == this._ruleId &&
				other.orderId == this._orderId &&
				other.productId == this._productId &&
				other.productCounter == this._productCounter &&
				other.ruleType == this._ruleType &&
				other.label == this._label &&
				other.value == this._value;
		} 	

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _ruleId;
				result = (result * 397) ^ _orderId;
				result = (result * 397) ^ _productId;
				result = (result * 397) ^ _productCounter;
				result = (result * 397) ^ _ruleType;
				result = (result * 397) ^ (_label == null ? 0 : _label.GetHashCode());
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderBusinessRule: ")
			.Append(" - ruleId: ").Append(this._ruleId)
			.Append(" - orderId: ").Append(this._orderId)
			.Append(" - productId: ").Append(this._productId)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - ruleType: ").Append(this._ruleType)
			.Append(" - label: ").Append(this._label)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}