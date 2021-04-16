using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class MultiLanguage : IEquatable<MultiLanguage>
	{	
		private int _id;
		private string _keyword;
		private string _langCode;
		private string _value;
		
		public MultiLanguage(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string keyword {
			get { return _keyword; }
			set { _keyword = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual bool Equals(MultiLanguage other)
		{
			if (this.id == other.id & this.keyword == other.keyword & this.langCode == other.langCode) {
				return true;
			}else{
				return false;
			}
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("MultiLanguage id: ")
			.Append(this._id)
			.Append(" - keyword: ").Append(this._keyword)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}