using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class FOrder
	{	
		private int _id;
		private int _userId;
		private string _guid;
		private string _notes;
		private int _status;
		private decimal _amount;
		private decimal _taxable;
		private decimal _supplement;
		private int _paymentId;
		private decimal _paymentCommission;
		private bool _paymentDone;
		private bool _downloadNotified;
		private bool _noRegistration;
		private bool _mailSent;
		private DateTime _insertDate;
		private DateTime _lastUpdate;
		IDictionary<string,OrderProduct> _products;
		
		
		public FOrder(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime lastUpdate {
			get { return _lastUpdate; }
			set { _lastUpdate = value; }
		}

		public virtual string guid {
			get { return _guid; }
			set { _guid = value; }
		}

		public virtual string notes {
			get { return _notes; }
			set { _notes = value; }
		}

		public virtual int status {
			get { return _status; }
			set { _status = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual decimal taxable {
			get { return _taxable; }
			set { _taxable = value; }
		}

		public virtual decimal supplement {
			get { return _supplement; }
			set { _supplement = value; }
		}

		public virtual int paymentId {
			get { return _paymentId; }
			set { _paymentId = value; }
		}

		public virtual decimal paymentCommission {
			get { return _paymentCommission; }
			set { _paymentCommission = value; }
		}

		public virtual bool paymentDone {
			get { return _paymentDone; }
			set { _paymentDone = value; }
		}

		public virtual bool downloadNotified {
			get { return _downloadNotified; }
			set { _downloadNotified = value; }
		}

		public virtual bool noRegistration {
			get { return _noRegistration; }
			set { _noRegistration = value; }
		}

		public virtual bool mailSent {
			get { return _mailSent; }
			set { _mailSent = value; }
		}
	
		public virtual IDictionary<string,OrderProduct> products {
			get { return _products; }
			set { _products = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("FOrder: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - lastUpdate: ").Append(this._lastUpdate)
			.Append(" - guid: ").Append(this._guid)
			.Append(" - notes: ").Append(this._notes)
			.Append(" - status: ").Append(this._status)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - taxable: ").Append(this._taxable)
			.Append(" - supplement: ").Append(this._supplement)
			.Append(" - paymentId: ").Append(this._paymentId)
			.Append(" - paymentCommission: ").Append(this._paymentCommission)
			.Append(" - paymentDone: ").Append(this._paymentDone)
			.Append(" - downloadNotified: ").Append(this._downloadNotified)
			.Append(" - noRegistration: ").Append(this._noRegistration)
			.Append(" - mailSent: ").Append(this._mailSent);
			
			return builder.ToString();			
		}
	}
}