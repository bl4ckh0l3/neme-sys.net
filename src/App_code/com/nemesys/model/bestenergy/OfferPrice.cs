using System;
using System.Text;

namespace com.nemesys.model
{
	public class OfferPrice
	{	
		private int _id;
		private int _idOffer;
		private OfferType _type;
		private decimal _amount;
		private string _currency;
		private DateTime _insertDate;
		private bool _isFixedPrice;

		
		public OfferPrice(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idOffer {
			get { return _idOffer; }
			set { _idOffer = value; }
		}

		public virtual OfferType type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual string currency {
			get { return _currency; }
			set { _currency = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual bool isFixedPrice {
			get { return _isFixedPrice; }
			set { _isFixedPrice = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OfferPrice id: ")
			.Append(this._id)
			.Append(" - idOffer: ").Append(this._idOffer)
			.Append(" - type: ").Append(this._type.label)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - currency: ").Append(this._currency)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - isFixedPrice: ").Append(this._isFixedPrice);
			
			return builder.ToString();			
		}
	}
}