using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class BillingData
	{	
		private int _id;
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
		private string _filePath;
		
		
		public BillingData(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
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

		public virtual string filePath {
			get { return _filePath; }
			set { _filePath = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("BillingData id: ")
			.Append(this._id)
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
			.Append(" - filePath: ").Append(this._filePath);
			
			return builder.ToString();			
		}
	}
}