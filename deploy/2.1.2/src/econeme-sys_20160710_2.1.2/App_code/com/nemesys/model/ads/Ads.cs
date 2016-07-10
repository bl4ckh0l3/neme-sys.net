using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Ads
	{	
		private int _id;
		private int _elementId;
		private int _userId;
		private int _type;
		private string _phone;
		private decimal _price;
		private DateTime _insertDate;
		private IList<AdsPromotion> _promotions;
	
		
		public Ads(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int elementId {
			get { return _elementId; }
			set { _elementId = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual string phone {
			get { return _phone; }
			set { _phone = value; }
		}

		public virtual decimal price {
			get { return _price; }
			set { _price = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}
	
		public virtual IList<AdsPromotion> promotions {
			get { return _promotions; }
			set { _promotions = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Ads: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - elementId: ").Append(this._elementId)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - type: ").Append(this._type)
			.Append(" - phone: ").Append(this._phone)
			.Append(" - price: ").Append(this._price)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}