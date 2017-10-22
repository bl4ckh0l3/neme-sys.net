using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class PaymentTransaction
	{	
		private int _id;
		private int _idOrder;
		private int _idModule;
		private string _idTransaction;
		private string _status;
		private bool _notified;
		private DateTime _insertDate;

		
		public PaymentTransaction(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idOrder {
			get { return _idOrder; }
			set { _idOrder = value; }
		}

		public virtual int idModule {
			get { return _idModule; }
			set { _idModule = value; }
		}

		public virtual string idTransaction {
			get { return _idTransaction; }
			set { _idTransaction = value; }
		}

		public virtual string status {
			get { return _status; }
			set { _status = value; }
		}

		public virtual bool notified {
			get { return _notified; }
			set { _notified = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("PaymentTransaction: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idModule: ").Append(this._idModule)
			.Append(" - status: ").Append(this._status)
			.Append(" - notified: ").Append(this._notified)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}