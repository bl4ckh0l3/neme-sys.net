using System;
using System.Text;

namespace com.nemesys.model
{
	public class BusinessRule
	{	
		private int _id;
		private string _label;
		private string _description;
		private bool _active;
		private int _ruleType;
		private int _voucherId;		
		
		
		public BusinessRule(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string label {
			get { return _label; }
			set { _label = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual int ruleType {
			get { return _ruleType; }
			set { _ruleType = value; }
		}

		public virtual int voucherId {
			get { return _voucherId; }
			set { _voucherId = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("BusinessRule: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - label: ").Append(this._label)
			.Append(" - description: ").Append(this._description)
			.Append(" - active: ").Append(this._active)
			.Append(" - ruleType: ").Append(this._ruleType)
			.Append(" - voucherId: ").Append(this._voucherId);
			
			return builder.ToString();			
		}
	}
}