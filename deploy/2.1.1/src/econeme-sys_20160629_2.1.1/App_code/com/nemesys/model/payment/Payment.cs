using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Payment
	{	
		private int _id;
		private string _description;
		private string _paymentData;
		private decimal _commission;		
		private int _commissionType;
		private bool _hasExternalUrl;
		private int _idModule;
		private int _paymentType;
		private bool _isActive;		
		private int _applyTo;
		private IList<IPaymentField> _fields;
		
		public Payment(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string paymentData {
			get { return _paymentData; }
			set { _paymentData = value; }
		}

		public virtual decimal commission {
			get { return _commission; }
			set { _commission = value; }
		}

		public virtual int commissionType {
			get { return _commissionType; }
			set { _commissionType = value; }
		}

		public virtual bool hasExternalUrl {
			get { return _hasExternalUrl; }
			set { _hasExternalUrl = value; }
		}

		public virtual int idModule {
			get { return _idModule; }
			set { _idModule = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}

		public virtual int paymentType {
			get { return _paymentType; }
			set { _paymentType = value; }
		}

		public virtual int applyTo {
			get { return _applyTo; }
			set { _applyTo = value; }
		}

		public virtual IList<IPaymentField> fields {
			get { return _fields; }
			set { _fields = value; }
		}

		public virtual decimal getCommissionAmount(decimal dblAmount){
			decimal amount = 0;
			if(_commissionType == 2) {
				amount = dblAmount * (_commission / 100);
			}else{
				amount = _commission;
			}
			
			return amount;
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Payment: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description)
			.Append(" - paymentData: ").Append(this._paymentData)
			.Append(" - commission: ").Append(this._commission)
			.Append(" - commissionType: ").Append(this._commissionType)
			.Append(" - hasExternalUrl: ").Append(this._hasExternalUrl)
			.Append(" - idModule: ").Append(this._idModule)
			.Append(" - isActive: ").Append(this._isActive)
			.Append(" - paymentType: ").Append(this._paymentType)
			.Append(" - applyTo: ").Append(this._applyTo);
			
			return builder.ToString();			
		}
	}
}