using System;
using System.Text;

namespace com.nemesys.model
{
	public class SystemFieldsTypeContent
	{	
		private int _id;
		private string _description;
		
		public SystemFieldsTypeContent(){}
		
		public SystemFieldsTypeContent(int id, string description){
			this._id=id;
			this._description=description;
		}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("SystemFieldsTypeContent: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description);
			
			return builder.ToString();			
		}
	}
}