using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductFieldTranslation
	{	
		private int _id;
		private int _idParentProduct;
		private int _idField;
		private string _type;
		private string _baseVal;
		private string _langCode;
		private string _value;
		
		public ProductFieldTranslation(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}
		
		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual int idField {
			get { return _idField; }
			set { _idField = value; }
		}

		public virtual string type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual string baseVal {
			get { return _baseVal; }
			set { _baseVal = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}
		
		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductFieldTranslation other = obj as ProductFieldTranslation;
			if (other == null)
				return false;

			return other.id == this._id &&
				other.idParentProduct == this._idParentProduct &&
				other.idField == this._idField &&
				other.type == this._type &&
				other.baseVal == this._baseVal &&
				other.langCode == this._langCode &&
				other.value == this._value;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _id;
				result = (result * 397) ^ _idParentProduct;
				result = (result * 397) ^ _idField;
				result = (result * 397) ^ (_type == null ? 0 : _type.GetHashCode());
				result = (result * 397) ^ (_baseVal == null ? 0 : _baseVal.GetHashCode());
				result = (result * 397) ^ (_langCode == null ? 0 : _langCode.GetHashCode());
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductFieldTranslation: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idParentProduct: ").Append(this._idParentProduct)
			.Append(" - idField: ").Append(this._idField)
			.Append(" - type: ").Append(this._type)
			.Append(" - baseVal: ").Append(this._baseVal)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}