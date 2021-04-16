using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class Country : IComparable<Country>
	{		
		private int _id;
		private string _countryCode;
		private string _stateRegionCode;
		private string _countryDescription;
		private string _stateRegionDescription;
		private bool _active;
		private string _useFor;
		
		public Country(){}
		
		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string countryCode {
			get { return _countryCode; }
			set { _countryCode = value; }
		}
		
		public virtual string countryDescription {
			get { return _countryDescription; }
			set { _countryDescription = value; }
		}

		public virtual string stateRegionCode {
			get { return _stateRegionCode; }
			set { _stateRegionCode = value; }
		}

		public virtual string stateRegionDescription {
			get { return _stateRegionDescription; }
			set { _stateRegionDescription = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual string useFor {
			get { return _useFor; }
			set { _useFor = value; }
		}

		public virtual int CompareTo(Country other)
		{
			return this._countryDescription.CompareTo(other.countryDescription);
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Country id: ")
			.Append(this._id)
			.Append(" - countryCode: ").Append(this._countryCode)
			.Append(" - countryDescription: ").Append(this._countryDescription)
			.Append(" - stateRegionCode: ").Append(this._stateRegionCode)
			.Append(" - stateRegionDescription: ").Append(this._stateRegionDescription)
			.Append(" - active: ").Append(this._active)
			.Append(" - useFor: ").Append(this._useFor);
			
			return builder.ToString();			
		}
	}
}