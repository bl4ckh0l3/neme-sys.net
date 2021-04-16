using System;
using System.Text;

namespace com.nemesys.model
{
	public class ContentAttachmentLabel
	{	
		private int _id;
		private string _description;

		
		public ContentAttachmentLabel(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ContentAttachmentLabel: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description);
			
			return builder.ToString();			
		}
	}
}