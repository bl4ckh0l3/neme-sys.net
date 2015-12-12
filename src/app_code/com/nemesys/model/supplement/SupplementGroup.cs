using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class SupplementGroup
	{	
		private int _id;
		private string _description;
		private IList<SupplementGroupValue> _values;
		
		public SupplementGroup(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}
	
		public virtual IList<SupplementGroupValue> values {
			get { return _values; }
			set { _values = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("SupplementGroup: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description);
			
			return builder.ToString();			
		}
	}
}