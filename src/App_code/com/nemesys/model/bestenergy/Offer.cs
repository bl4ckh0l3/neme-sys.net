using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Offer
	{	
		private int _id;
		private string _name;
		private OfferType _type;
		private bool _isActive;
		private DateTime _insertDate;
		private DateTime _lastUpdate;
		private DateTime _expireDate;
		private IList<OfferPrice> _prices;
		private bool _hasApp;
		
		public Offer(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual OfferType type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}

		public virtual bool hasApp {
			get { return _hasApp; }
			set { _hasApp = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime lastUpdate {
			get { return _lastUpdate; }
			set { _lastUpdate = value; }
		}

		public virtual DateTime expireDate {
			get { return _expireDate; }
			set { _expireDate = value; }
		}
		
		public virtual IList<OfferPrice> prices {
			get { return _prices; }
			set { _prices = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Offer id: ")
			.Append(this._id)
			.Append(" - name: ").Append(this._name)
			.Append(" - type: ").Append(this._type.label)
			.Append(" - isActive: ").Append(this._isActive)
			.Append(" - hasApp: ").Append(this._hasApp)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - lastUpdate: ").Append(this._lastUpdate)
			.Append(" - expireDate: ").Append(this._expireDate);
			
			return builder.ToString();			
		}
	}
}