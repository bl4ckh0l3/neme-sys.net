using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class Language : IComparable<Language>
	{	
		private int _id;
		private string _label;
		private string _description;
		private string _urlSubdomain;
		private bool _langActive;
		private bool _subdomainActive;
		
		public Language(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string label {
			get { return _label; }
			set { _label = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string urlSubdomain {
			get { return _urlSubdomain; }
			set { _urlSubdomain = value; }
		}

		public virtual bool langActive {
			get { return _langActive; }
			set { _langActive = value; }
		}

		public virtual bool subdomainActive {
			get { return _subdomainActive; }
			set { _subdomainActive = value; }
		}

		public virtual int CompareTo(Language other)
		{
			return this._description.CompareTo(other.description);
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Language id: ")
			.Append(this._id)
			.Append(" - label: ").Append(this._label)
			.Append(" - description: ").Append(this._description)
			.Append(" - urlSubdomain: ").Append(this._urlSubdomain)
			.Append(" - langActive: ").Append(this._langActive)
			.Append(" - subdomainActive: ").Append(this._subdomainActive);
			
			return builder.ToString();			
		}
	}
}