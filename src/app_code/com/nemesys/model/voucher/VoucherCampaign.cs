using System;
using System.Text;

namespace com.nemesys.model
{
	public class VoucherCampaign
	{	
		private int _id;
		private int _type;
		private string _label;
		private string _description;
		private decimal _voucherAmount;
		private bool _active;
		private bool _excludeProdRule;
		private int _operation;
		private int _maxGeneration;
		private int _maxUsage;
		private DateTime _enableDate;
		private DateTime _expireDate;
		
		
		public VoucherCampaign(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}
		
		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual string label {
			get { return _label; }
			set { _label = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual decimal voucherAmount {
			get { return _voucherAmount; }
			set { _voucherAmount = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual bool excludeProdRule {
			get { return _excludeProdRule; }
			set { _excludeProdRule = value; }
		}

		public virtual int operation {
			get { return _operation; }
			set { _operation = value; }
		}

		public virtual int maxGeneration {
			get { return _maxGeneration; }
			set { _maxGeneration = value; }
		}	

		public virtual int maxUsage {
			get { return _maxUsage; }
			set { _maxUsage = value; }
		}	

		public virtual DateTime enableDate {
			get { return _enableDate; }
			set { _enableDate = value; }
		}		

		public virtual DateTime expireDate {
			get { return _expireDate; }
			set { _expireDate = value; }
		}				
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("VoucherCampaign: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - type: ").Append(this._type)
			.Append(" - label: ").Append(this._label)
			.Append(" - description: ").Append(this._description)
			.Append(" - voucherAmount: ").Append(this._voucherAmount)
			.Append(" - active: ").Append(this._active)
			.Append(" - excludeProdRule: ").Append(this._excludeProdRule)
			.Append(" - operation: ").Append(this._operation)
			.Append(" - maxGeneration: ").Append(this._maxGeneration)
			.Append(" - maxUsage: ").Append(this._maxUsage)
			.Append(" - enableDate: ").Append(this._enableDate)
			.Append(" - expireDate: ").Append(this._expireDate);
			
			return builder.ToString();			
		}
	}
}