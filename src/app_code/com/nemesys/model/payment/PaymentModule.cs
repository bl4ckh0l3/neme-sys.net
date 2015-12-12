using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class PaymentModule
	{	
		private int _id;
		private string _name;
		private string _icon;
		private string _idOrderField;
		private string _ipProvider;		
		
		
		public PaymentModule(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual string icon {
			get { return _icon; }
			set { _icon = value; }
		}

		public virtual string idOrderField {
			get { return _idOrderField; }
			set { _idOrderField = value; }
		}

		public virtual string ipProvider {
			get { return _ipProvider; }
			set { _ipProvider = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("PaymentModule: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - name: ").Append(this._name)
			.Append(" - icon: ").Append(this._icon)
			.Append(" - idOrderField: ").Append(this._idOrderField)
			.Append(" - ipProvider: ").Append(this._ipProvider);
			
			return builder.ToString();			
		}
	}
}