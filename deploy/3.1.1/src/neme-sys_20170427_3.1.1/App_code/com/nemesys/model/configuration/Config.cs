using System;
using System.Text;

namespace com.nemesys.model
{
	public class Config : IComparable<Config>
	{	
		private string _key;
		private string _description;
		private string _value;
		private string _alert;
		private string _type;
		private string _type_values;
		private bool _is_base;

		public Config(){
			
		}

		public Config(string key, string value, string description, string alert, string type, string type_values, bool is_base){
			this._key=key;
			this._value=value;
			this._description=description;
			this._alert=alert;
			this._type=type;
			this._type_values=type_values;	
			this._is_base=is_base;		
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

		public string alert {
			get { return _alert; }
			set { _alert = value; }
		}

		public string type {
			get { return _type; }
			set { _type = value; }
		}

		public string type_values {
			get { return _type_values; }
			set { _type_values = value; }
		}

		public bool is_base {
			get { return _is_base; }
			set { _is_base = value; }
		}

		public int CompareTo( Config other )
		{
			return this._type.CompareTo(other.type);
		}

		public override string ToString() {
			return "keyword: "+_key+
				" - value: "+_value+
				" - description: "+_description+
				" - alert: "+_alert+
				" - type: "+_type+
				" - type_values: "+_type_values+
				" - is_base: "+_is_base;
		}
	}
}