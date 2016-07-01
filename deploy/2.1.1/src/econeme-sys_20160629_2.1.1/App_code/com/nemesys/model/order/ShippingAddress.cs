using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class ShippingAddress
	{	
		private int _id;
		private int _idUser;
		private string _name;
		private string _surname;
		private string _cfiscvat;
		private string _address;
		private string _city;
		private string _zipCode;
		private string _country;
		private string _stateRegion;
		private bool _isCompanyClient;
		
		
		public ShippingAddress(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idUser {
			get { return _idUser; }
			set { _idUser = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual string surname {
			get { return _surname; }
			set { _surname = value; }
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

		public virtual bool isCompanyClient {
			get { return _isCompanyClient; }
			set { _isCompanyClient = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ShippingAddress id: ")
			.Append(this._id)
			.Append(" - idUser: ").Append(this._idUser)
			.Append(" - name: ").Append(this._name)
			.Append(" - surname: ").Append(this._surname)
			.Append(" - cfiscvat: ").Append(this._cfiscvat)
			.Append(" - address: ").Append(this._address)
			.Append(" - city: ").Append(this._city)
			.Append(" - zipCode: ").Append(this._zipCode)
			.Append(" - country: ").Append(this._country)
			.Append(" - stateRegion: ").Append(this._stateRegion)
			.Append(" - isCompanyClient: ").Append(this._isCompanyClient);
			
			return builder.ToString();			
		}
	}
}