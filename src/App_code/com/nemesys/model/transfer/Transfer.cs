using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Transfer : IComparable<Transfer>, IEquatable<Transfer>
	{		
		private int _id;
		private string _serviceName;
		private string _operatorName;
		private int _seat;
		private string _logo;
		private string _image;
		private int _maxLuggage;
		private int _duration;
		private decimal _amount;
		private string _currency;
		private DateTime _dOut;
		private DateTime _dRtn;
		private string _from;
		private string _to;
		
		public Transfer(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string serviceName {
			get { return _serviceName; }
			set { _serviceName = value; }
		}

		public virtual string operatorName {
			get { return _operatorName; }
			set { _operatorName = value; }
		}

		public virtual int seat {
			get { return _seat; }
			set { _seat = value; }
		}

		public virtual string logo {
			get { return _logo; }
			set { _logo = value; }
		}

		public virtual string image {
			get { return _image; }
			set { _image = value; }
		}

		public virtual int maxLuggage {
			get { return _maxLuggage; }
			set { _maxLuggage = value; }
		}

		public virtual int duration {
			get { return _duration; }
			set { _duration = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual string currency {
			get { return _currency; }
			set { _currency = value; }
		}

		public virtual DateTime dOut {
			get { return _dOut; }
			set { _dOut = value; }
		}

		public virtual DateTime dRtn {
			get { return _dRtn; }
			set { _dRtn = value; }
		}

		public virtual string from {
			get { return _from; }
			set { _from = value; }
		}

		public virtual string to {
			get { return _to; }
			set { _to = value; }
		}

		public virtual int CompareTo(Transfer other)
		{
			int val = this._amount.CompareTo(other.amount);
			return val;
		}

		public virtual bool Equals(Transfer other) 
		{
			if (other == null) 
				return false;
			
			return other.id == this._id &&
				other.serviceName == this._serviceName &&
				other.operatorName == this._operatorName &&
				other.seat == this._seat &&
				other.logo == this._logo &&
				other.image == this._image &&
				other.maxLuggage == this._maxLuggage &&
				other.duration == this._duration &&
				other.amount == this._amount &&
				other.currency == this._currency &&
				other.dOut == this._dOut &&
				other.dRtn == this._dRtn &&
				other.from == this._from &&
				other.to == this._to;
		} 		
		
		public override bool Equals(Object obj)
		{
			if (obj == null) 
				return false;
     
			Transfer other = obj as Transfer;
			if (other == null)
				return false;

			return Equals(other);
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _id;
				result = (result * 397) ^ (_serviceName == null ? 0 : _serviceName.GetHashCode());
				result = (result * 397) ^ (_operatorName == null ? 0 : _operatorName.GetHashCode());
				result = (result * 397) ^ _seat;
				result = (result * 397) ^ (_logo == null ? 0 : _logo.GetHashCode());
				result = (result * 397) ^ (_image == null ? 0 : _image.GetHashCode());
				result = (result * 397) ^ _maxLuggage;
				result = (result * 397) ^ _duration;
				result = (result * 397) ^ (_amount == null ? 0 : _amount.GetHashCode());
				result = (result * 397) ^ (_currency == null ? 0 : _currency.GetHashCode());
				result = (result * 397) ^ (_from == null ? 0 : _from.GetHashCode());
				result = (result * 397) ^ (_to == null ? 0 : _to.GetHashCode());
				result = (result * 397) ^ (_dOut == null ? 0 : _dOut.GetHashCode());
				result = (result * 397) ^ (_dRtn == null ? 0 : _dRtn.GetHashCode());
				return result;
			}
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Transfer id: ")
			.Append(this._id)
			.Append(" - serviceName: ").Append(this._serviceName)
			.Append(" - operatorName: ").Append(this._operatorName)
			.Append(" - seat: ").Append(this._seat)
			.Append(" - logo: ").Append(this._logo)
			.Append(" - image: ").Append(this._image)
			.Append(" - maxLuggage: ").Append(this._maxLuggage)
			.Append(" - duration: ").Append(this._duration)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - currency: ").Append(this._currency)
			.Append(" - dOut: ").Append(this._dOut)
			.Append(" - dRtn: ").Append(this._dRtn)
			.Append(" - from: ").Append(this._from)
			.Append(" - to: ").Append(this._to);
			
			return builder.ToString();			
		}
	}
}