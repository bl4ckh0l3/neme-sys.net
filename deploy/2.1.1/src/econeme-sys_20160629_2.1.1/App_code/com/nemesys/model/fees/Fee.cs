using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Fee
	{
		private int _id;
		private string _description;
		private decimal _amount;
		private int _type;
		private int _idSupplement;
		private int _supplementGroup;
		private int _applyTo;
		private bool _autoactive;
		private bool _multiply;
		private bool _required;
		private string _feeGroup;
		private int _typeView;
		private IList<FeeConfig> _configs;

		
		public Fee(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual int idSupplement {
			get { return _idSupplement; }
			set { _idSupplement = value; }
		}

		public virtual int supplementGroup {
			get { return _supplementGroup; }
			set { _supplementGroup = value; }
		}

		public virtual int applyTo {
			get { return _applyTo; }
			set { _applyTo = value; }
		}

		public virtual bool autoactive {
			get { return _autoactive; }
			set { _autoactive = value; }
		}

		public virtual bool multiply {
			get { return _multiply; }
			set { _multiply = value; }
		}

		public virtual bool required {
			get { return _required; }
			set { _required = value; }
		}

		public virtual string feeGroup {
			get { return _feeGroup; }
			set { _feeGroup = value; }
		}

		public virtual int typeView {
			get { return _typeView; }
			set { _typeView = value; }
		}

		public virtual IList<FeeConfig> configs {
			get { return _configs; }
			set { _configs = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Fee: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - type: ").Append(this._type)
			.Append(" - idSupplement: ").Append(this._idSupplement)
			.Append(" - supplementGroup: ").Append(this._supplementGroup)
			.Append(" - applyTo: ").Append(this._applyTo)
			.Append(" - autoactive: ").Append(this._autoactive)
			.Append(" - multiply: ").Append(this._multiply)
			.Append(" - required: ").Append(this._required)
			.Append(" - feeGroup: ").Append(this._feeGroup)
			.Append(" - typeView: ").Append(this._typeView);
			
			return builder.ToString();			
		}
	}
}