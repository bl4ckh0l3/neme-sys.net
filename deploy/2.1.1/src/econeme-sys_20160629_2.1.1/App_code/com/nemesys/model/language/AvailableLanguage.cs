using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class AvailableLanguage : IComparable<AvailableLanguage>
	{	
		private string _keyword;
		private string _description;
		
		public AvailableLanguage(){}

		public virtual string keyword {
			get { return _keyword; }
			set { _keyword = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual int CompareTo(AvailableLanguage other)
		{
			return this._description.CompareTo(other.description);
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("AvailableLanguage")
			.Append(" keyword: ").Append(this._keyword)
			.Append(" - description: ").Append(this._description);
			
			return builder.ToString();			
		}
	}
}