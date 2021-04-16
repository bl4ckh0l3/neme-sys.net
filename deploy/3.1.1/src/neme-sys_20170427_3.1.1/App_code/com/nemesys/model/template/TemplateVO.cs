using System;
using System.Text;

namespace com.nemesys.model
{
	public class TemplateVO
	{	
		private TemplatePage _templatePage;
		private string _langCode;

		
		public TemplateVO(){
			this._templatePage=null;
			this._langCode=null;
		}

		public virtual TemplatePage templatePage {
			get { return _templatePage; }
			set { _templatePage = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("TemplateVO: ")
			.Append(" - templatePage: ").Append(this._templatePage)
			.Append(" - langCode: ").Append(this._langCode);
			
			return builder.ToString();			
		}
	}
}