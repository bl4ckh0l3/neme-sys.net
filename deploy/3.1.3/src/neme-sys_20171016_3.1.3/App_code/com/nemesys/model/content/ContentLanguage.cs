using System;
using System.Text;

namespace com.nemesys.model
{
	public class ContentLanguage
	{	
		private int _idLanguage;
		private int _idParentContent;
		
		public ContentLanguage(){}

		public virtual int idParentContent {
			get { return _idParentContent; }
			set { _idParentContent = value; }
		}

		public virtual int idLanguage {
			get { return _idLanguage; }
			set { _idLanguage = value; }
		}
		
		public override bool Equals(object obj)
		{
			ContentLanguage other = obj as ContentLanguage;
			if (other == null)
				return false;

			return other.idLanguage == this._idLanguage &&
				other.idParentContent == this._idParentContent;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentContent;
				result = (result * 397) ^ _idLanguage;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ContentLanguage idParentContent: ")
			.Append(this._idParentContent)
			.Append(" - idLanguage: ").Append(this._idLanguage);
			
			return builder.ToString();			
		}
	}
}