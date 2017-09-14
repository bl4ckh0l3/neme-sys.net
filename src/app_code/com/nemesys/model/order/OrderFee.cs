using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderFee
	{	
		private int _idOrder;
		private int _idFee;	
		private decimal _amount;
		private decimal _taxable;
		private decimal _supplement;	
		private string _feeDesc;
		private bool _autoactive;
		private bool _required;
		private bool _multiply;
		private string _feeGroup;
	
		public OrderFee(){}

		public virtual int idOrder {
			get { return _idOrder; }
			set { _idOrder = value; }
		}

		public virtual int idFee {
			get { return _idFee; }
			set { _idFee = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual decimal taxable {
			get { return _taxable; }
			set { _taxable = value; }
		}

		public virtual decimal supplement {
			get { return _supplement; }
			set { _supplement = value; }
		}

		public virtual string feeDesc {
			get { return _feeDesc; }
			set { _feeDesc = value; }
		}

		public virtual bool autoactive {
			get { return _autoactive; }
			set { _autoactive = value; }
		}

		public virtual bool required {
			get { return _required; }
			set { _required = value; }
		}

		public virtual bool multiply {
			get { return _multiply; }
			set { _multiply = value; }
		}

		public virtual string feeGroup {
			get { return _feeGroup; }
			set { _feeGroup = value; }
		}		
		
		public override bool Equals(object obj)
		{
			OrderFee other = obj as OrderFee;
			if (other == null)
				return false;

			return other.idOrder == this._idOrder &&
				other.idFee == this._idFee &&
				other.amount == this._amount &&
				other.taxable == this._taxable &&
				other.supplement == this._supplement &&
				other.feeDesc == this._feeDesc;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idOrder;
				result = (result * 397) ^ _idFee;
				result = (result * 397) ^ (_amount == null ? 0 : _amount.GetHashCode());
				result = (result * 397) ^ (_taxable == null ? 0 : _taxable.GetHashCode());
				result = (result * 397) ^ (_supplement == null ? 0 : _supplement.GetHashCode());
				result = (result * 397) ^ (_feeDesc == null ? 0 : _feeDesc.GetHashCode());
				return result;
			}
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderFee: ")
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idFee: ").Append(this._idFee)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - taxable: ").Append(this._taxable)
			.Append(" - supplement: ").Append(this._supplement)
			.Append(" - feeDesc: ").Append(this._feeDesc)
			.Append(" - autoactive: ").Append(this._autoactive)
			.Append(" - required: ").Append(this._required)
			.Append(" - multiply: ").Append(this._multiply)
			.Append(" - feeGroup: ").Append(this._feeGroup);
			
			return builder.ToString();			
		}
	}
}