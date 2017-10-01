using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Billing
	{	
		private int _id;
		private int _idParentOrder;
		private decimal _orderAmount;
		private DateTime _orderDate;
		private string _name;
		private string _cfiscvat;
		private string _address;
		private string _city;
		private string _zipCode;
		private string _country;
		private string _stateRegion;
		private string _phone;
		private string _fax;
		private string _description;
		private DateTime _insertDate;
		private DateTime _lastUpdate;
		private int _idRegisteredBilling;
		private DateTime _registeredDate;
		
		
		public Billing(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idParentOrder {
			get { return _idParentOrder; }
			set { _idParentOrder = value; }
		}

		public virtual decimal orderAmount {
			get { return _orderAmount; }
			set { _orderAmount = value; }
		}

		public virtual DateTime orderDate {
			get { return _orderDate; }
			set { _orderDate = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual string cfiscvat {
			get { return _cfiscvat; }
			set { _cfiscvat = value; }
		}

		public virtual string address {
			get { return _address; }
			set { _address = value; }
		}

		public virtual string city {
			get { return _city; }
			set { _city = value; }
		}

		public virtual string zipCode {
			get { return _zipCode; }
			set { _zipCode = value; }
		}

		public virtual string country {
			get { return _country; }
			set { _country = value; }
		}

		public virtual string stateRegion {
			get { return _stateRegion; }
			set { _stateRegion = value; }
		}

		public virtual string phone {
			get { return _phone; }
			set { _phone = value; }
		}

		public virtual string fax {
			get { return _fax; }
			set { _fax = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime lastUpdate {
			get { return _lastUpdate; }
			set { _lastUpdate = value; }
		}

		public virtual int idRegisteredBilling {
			get { return _idRegisteredBilling; }
			set { _idRegisteredBilling = value; }
		}

		public virtual DateTime registeredDate {
			get { return _registeredDate; }
			set { _registeredDate = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Billing id: ")
			.Append(this._id)
			.Append(" - idParentOrder: ").Append(this._idParentOrder)
			.Append(" - orderAmount: ").Append(this._orderAmount)
			.Append(" - orderDate: ").Append(this._orderDate)
			.Append(" - name: ").Append(this._name)
			.Append(" - cfiscvat: ").Append(this._cfiscvat)
			.Append(" - address: ").Append(this._address)
			.Append(" - city: ").Append(this._city)
			.Append(" - zipCode: ").Append(this._zipCode)
			.Append(" - country: ").Append(this._country)
			.Append(" - stateRegion: ").Append(this._stateRegion)
			.Append(" - phone: ").Append(this._phone)
			.Append(" - fax: ").Append(this._fax)
			.Append(" - description: ").Append(this._description)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - lastUpdate: ").Append(this._lastUpdate)
			.Append(" - idRegisteredBilling: ").Append(this._idRegisteredBilling)
			.Append(" - registeredDate: ").Append(this._registeredDate);
			
			return builder.ToString();			
		}
	}
}