using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class MailCategory : IComparable<MailCategory>
	{	
		private string _name;
		
		public MailCategory(){}
		
		public MailCategory(string name)
		{
			this._name=name;
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual int CompareTo(MailCategory other)
		{
			return this._name.CompareTo(other.name);
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("User: ")
			.Append(" - name: ").Append(this._name);
			
			return builder.ToString();			
		}
	}
}