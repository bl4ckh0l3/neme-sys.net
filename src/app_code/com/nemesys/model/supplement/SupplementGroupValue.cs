using System;
using System.Text;

namespace com.nemesys.model
{
	public class SupplementGroupValue
	{	
		private int _id;
		private int _idGroup;
		private string _countryCode;
		private string _stateRegionCode;
		private int _idFee;
		private bool _excludeCalculation;
		
		public SupplementGroupValue(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idGroup {
			get { return _idGroup; }
			set { _idGroup = value; }
		}

		public virtual string countryCode {
			get { return _countryCode; }
			set { _countryCode = value; }
		}

		public virtual string stateRegionCode {
			get { return _stateRegionCode; }
			set { _stateRegionCode = value; }
		}

		public virtual int idFee {
			get { return _idFee; }
			set { _idFee = value; }
		}

		public virtual bool excludeCalculation {
			get { return _excludeCalculation; }
			set { _excludeCalculation = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("SupplementGroupValue: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idGroup: ").Append(this._idGroup)
			.Append(" - countryCode: ").Append(this._countryCode)
			.Append(" - stateRegionCode: ").Append(this._stateRegionCode)
			.Append(" - idFee: ").Append(this._idFee)
			.Append(" - excludeCalculation: ").Append(this._excludeCalculation);
			
			return builder.ToString();			
		}
	}
}