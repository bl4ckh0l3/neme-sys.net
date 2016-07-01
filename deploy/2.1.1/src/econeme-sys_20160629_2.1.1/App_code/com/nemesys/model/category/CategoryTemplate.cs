using System;
using System.Text;

namespace com.nemesys.model
{
	public class CategoryTemplate
	{	
		private int _categoryId;
		private int _templateId;
		private string _langCode;
		
		public CategoryTemplate(){}
		
		public CategoryTemplate(int categoryId, int templateId, string langCode){
			this._categoryId = categoryId;
			this._templateId = templateId;
			this._langCode = langCode;
		}

		public virtual int categoryId {
			get { return _categoryId; }
			set { _categoryId = value; }
		}

		public virtual int templateId {
			get { return _templateId; }
			set { _templateId = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}
		
		public override bool Equals(object obj)
		{
			CategoryTemplate other = obj as CategoryTemplate;
			if (other == null)
				return false;

			return other.categoryId == this._categoryId &&
				other.templateId == this._templateId &&
				other.langCode == this._langCode;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _categoryId;
				result = (result * 397) ^ _templateId;
				result = (result * 397) ^ (_langCode == null ? 0 : _langCode.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("CategoryTemplate: ")
			.Append(" - categoryId: ").Append(this._categoryId)
			.Append(" - templateId: ").Append(this._templateId)
			.Append(" - langCode: ").Append(this._langCode);			
			return builder.ToString();			
		}
	}
}