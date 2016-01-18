using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderBillsAddress
	{	
		private int _idOrder;
		private int _idBills;
		private string _name;
		private string _surname;
		private string _cfiscvat;
		private string _address;
		private string _city;
		private string _zipCode;
		private string _country;
		private string _stateRegion;
		
		
		public OrderBillsAddress(){}

		public virtual int idOrder {
			get { return _idOrder; }
			set { _idOrder = value; }
		}

		public virtual int idBills {
			get { return _idBills; }
			set { _idBills = value; }
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
		
		public override bool Equals(object obj)
		{
			OrderBillsAddress other = obj as OrderBillsAddress;
			if (other == null)
				return false;

			return other.idOrder == this._idOrder &&
				other.idBills == this._idBills &&
				other.name == this._name &&
				other.surname == this._surname &&
				other.cfiscvat == this._cfiscvat &&
				other.address == this._address &&
				other.city == this._city &&
				other.zipCode == this._zipCode &&
				other.country == this._country &&
				other.stateRegion == this._stateRegion;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idOrder;
				result = (result * 397) ^ _idBills;
				result = (result * 397) ^ (_name == null ? 0 : _name.GetHashCode());
				result = (result * 397) ^ (_surname == null ? 0 : _surname.GetHashCode());
				result = (result * 397) ^ (_cfiscvat == null ? 0 : _cfiscvat.GetHashCode());
				result = (result * 397) ^ (_address == null ? 0 : _address.GetHashCode());
				result = (result * 397) ^ (_city == null ? 0 : _city.GetHashCode());
				result = (result * 397) ^ (_zipCode == null ? 0 : _zipCode.GetHashCode());
				result = (result * 397) ^ (_country == null ? 0 : _country.GetHashCode());
				result = (result * 397) ^ (_stateRegion == null ? 0 : _stateRegion.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderBillsAddress idOrder: ")
			.Append(this._idOrder)
			.Append(" - idBills: ").Append(this._idBills)
			.Append(" - name: ").Append(this._name)
			.Append(" - surname: ").Append(this._surname)
			.Append(" - cfiscvat: ").Append(this._cfiscvat)
			.Append(" - address: ").Append(this._address)
			.Append(" - city: ").Append(this._city)
			.Append(" - zipCode: ").Append(this._zipCode)
			.Append(" - country: ").Append(this._country)
			.Append(" - stateRegion: ").Append(this._stateRegion);
			
			return builder.ToString();			
		}
	}
}