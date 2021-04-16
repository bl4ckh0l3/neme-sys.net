using System;
using System.Text;

namespace com.nemesys.model
{
	public class CategoryTemplate
	{	
		private int _categoryId;
		private int _templateId;
		private int _templatePageId;
		private string _langCode;
		private string _urlRewrite;
		
		public CategoryTemplate(){}
		
		public CategoryTemplate(int categoryId, int templateId, int templatePageId, string langCode, string urlRewrite){
			this._categoryId = categoryId;
			this._templateId = templateId;
			this._templatePageId = templatePageId;
			this._langCode = langCode;
			this._urlRewrite = urlRewrite;
		}

		public virtual int categoryId {
			get { return _categoryId; }
			set { _categoryId = value; }
		}

		public virtual int templateId {
			get { return _templateId; }
			set { _templateId = value; }
		}

		public virtual int templatePageId {
			get { return _templatePageId; }
			set { _templatePageId = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}

		public virtual string urlRewrite {
			get { return _urlRewrite; }
			set { _urlRewrite = value; }
		}
		
		public override bool Equals(object obj)
		{
			CategoryTemplate other = obj as CategoryTemplate;
			if (other == null)
				return false;

			return other.categoryId == this._categoryId &&
				other.templateId == this._templateId &&
				other.templatePageId == this._templatePageId &&
				other.langCode == this._langCode &&
				other.urlRewrite == this._urlRewrite;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _categoryId;
				result = (result * 397) ^ _templateId;
				result = (result * 397) ^ _templatePageId;
				result = (result * 397) ^ (_langCode == null ? 0 : _langCode.GetHashCode());
				result = (result * 397) ^ (_urlRewrite == null ? 0 : _urlRewrite.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("CategoryTemplate: ")
			.Append(" - categoryId: ").Append(this._categoryId)
			.Append(" - templateId: ").Append(this._templateId)
			.Append(" - templatePageId: ").Append(this._templatePageId)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - urlRewrite: ").Append(this._urlRewrite);			
			return builder.ToString();			
		}
	}
}