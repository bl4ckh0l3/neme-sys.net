using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class Currency : IComparable<Currency>
	{		
		private int _id;
		private string _currency;
		private decimal _rate;
		private DateTime _referDate;
		private DateTime _insertDate;
		private bool _active;
		private bool _isDefault;
		
		public Currency(){}
		
		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string currency {
			get { return _currency; }
			set { _currency = value; }
		}

		public virtual decimal rate {
			get { return _rate; }
			set { _rate = value; }
		}

		public virtual DateTime referDate {
			get { return _referDate; }
			set { _referDate = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual bool isDefault {
			get { return _isDefault; }
			set { _isDefault = value; }
		}

		public virtual int CompareTo(Currency other)
		{
			int val = this._currency.CompareTo(other.currency);
			//System.Web.HttpContext.Current.Response.Write("this._hierarchy:"+this._hierarchy+" - other._hierarchy:"+other._hierarchy+" - compareTo val:"+val+"<br>");
			return val;
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Currency id: ")
			.Append(this._id)
			.Append(" - currency: ").Append(this._currency)
			.Append(" - rate: ").Append(this._rate)
			.Append(" - referDate: ").Append(this._referDate)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - active: ").Append(this._active)
			.Append(" - isDefault: ").Append(this._isDefault);
			
			return builder.ToString();			
		}
	}
}