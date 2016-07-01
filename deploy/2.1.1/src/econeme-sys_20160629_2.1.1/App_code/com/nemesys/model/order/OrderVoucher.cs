using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderVoucher
	{  			
		private int _voucherId;
		private int _orderId;
		private string _voucherCode;
		private decimal _voucherAmount;
		private DateTime _insertDate;
		
		public OrderVoucher(){}

		public virtual int voucherId {
			get { return _voucherId; }
			set { _voucherId = value; }
		}

		public virtual int orderId {
			get { return _orderId; }
			set { _orderId = value; }
		}

		public virtual string voucherCode {
			get { return _voucherCode; }
			set { _voucherCode = value; }
		}

		public virtual decimal voucherAmount {
			get { return _voucherAmount; }
			set { _voucherAmount = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}
		
		public override bool Equals(object obj) 
		{
			OrderVoucher other = obj as OrderVoucher;
			if (other == null) 
				return false;
			
			return other.voucherId == this._voucherId &&
				other.orderId == this._orderId &&
				other.voucherCode == this._voucherCode &&
				other.voucherAmount == this._voucherAmount;
		} 	

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _voucherId;
				result = (result * 397) ^ _orderId;
				result = (result * 397) ^ (_voucherCode == null ? 0 : _voucherCode.GetHashCode());
				result = (result * 397) ^ (_voucherAmount == null ? 0 : _voucherAmount.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderVoucher: ")
			.Append(" - voucherId: ").Append(this._voucherId)
			.Append(" - orderId: ").Append(this._orderId)
			.Append(" - voucherCode: ").Append(this._voucherCode)
			.Append(" - voucherAmount: ").Append(this._voucherAmount)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}