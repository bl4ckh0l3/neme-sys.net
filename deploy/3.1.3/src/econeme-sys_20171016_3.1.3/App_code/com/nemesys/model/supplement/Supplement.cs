using System;
using System.Text;

namespace com.nemesys.model
{
	public class Supplement
	{	
		private int _id;
		private string _description;
		private decimal _value;
		private int _type;
		
		public Supplement(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual decimal value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Supplement: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description)
			.Append(" - value: ").Append(this._value)
			.Append(" - type: ").Append(this._type);
			
			return builder.ToString();			
		}
	}
}