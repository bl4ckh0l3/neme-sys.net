using System;
using System.Text;

namespace com.nemesys.model
{
	public class RepositoryMapping : IComparable<RepositoryMapping>
	{	
		private string _key;
		private string _description;
		private string _value;
		private string _singleton;
		private string _lazy;
		
		public RepositoryMapping(){}		
		
		public RepositoryMapping(string key, string value, string description, string singleton, string lazy){
			this._key=key;
			this._value=value;
			this._description=description;
			this._singleton=singleton;
			this._lazy=lazy;
		}
		
		public string key {
			get { return _key; }
			set { _key = value; }
		}

		public string description {
			get { return _description; }
			set { _description = value; }
		}

		public string value {
			get { return _value; }
			set { _value = value; }
		}

		public string singleton {
			get { return _singleton; }
			set { _singleton = value; }
		}

		public string lazy {
			get { return _lazy; }
			set { _lazy = value; }
		}

		public int CompareTo( RepositoryMapping other )
		{
			return this._value.CompareTo(other.value);
		}
		
		public override string ToString() {
			return "keyword: "+_key+
				" - value: "+_value+
				" - description: "+_description+
				" - singleton: "+_singleton+
				" - lazy: "+_lazy;
		}
	}
}