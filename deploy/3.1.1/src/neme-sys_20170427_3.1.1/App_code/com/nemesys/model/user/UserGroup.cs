using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserGroup
	{	
		private int _id;
		private string _shortDesc;
		private string _longDesc;
		private bool _defaultGroup;
		private int _supplementGroup;
		private decimal _discount;
		private decimal _margin;
		private bool _applyProdDiscount;
		private bool _applyUserDiscount;
		
		public UserGroup(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string shortDesc {
			get { return _shortDesc; }
			set { _shortDesc = value; }
		}

		public virtual string longDesc {
			get { return _longDesc; }
			set { _longDesc = value; }
		}

		public virtual bool defaultGroup {
			get { return _defaultGroup; }
			set { _defaultGroup = value; }
		}

		public virtual int supplementGroup {
			get { return _supplementGroup; }
			set { _supplementGroup = value; }
		}

		public virtual decimal discount {
			get { return _discount; }
			set { _discount = value; }
		}

		public virtual decimal margin {
			get { return _margin; }
			set { _margin = value; }
		}

		public virtual bool applyProdDiscount {
			get { return _applyProdDiscount; }
			set { _applyProdDiscount = value; }
		}

		public virtual bool applyUserDiscount {
			get { return _applyUserDiscount; }
			set { _applyUserDiscount = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserGroup id: ")
			.Append(this._id)
			.Append(" - shortDesc: ").Append(this._shortDesc)
			.Append(" - longDesc: ").Append(this._longDesc)
			.Append(" - defaultGroup: ").Append(this._defaultGroup)
			.Append(" - supplementGroup: ").Append(this._supplementGroup)
			.Append(" - discount: ").Append(this._discount)
			.Append(" - margin: ").Append(this._margin)
			.Append(" - applyProdDiscount: ").Append(this._applyProdDiscount)
			.Append(" - applyUserDiscount: ").Append(this._applyUserDiscount);
			
			return builder.ToString();			
		}
	}
}