using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductMainFieldTranslation
	{	
		private int _id;
		private int _idParentProduct;
		private int _mainField;
		private string _langCode;
		private string _value;
		
		public ProductMainFieldTranslation(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}
		
		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual int mainField {
			get { return _mainField; }
			set { _mainField = value; }
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
			ProductMainFieldTranslation other = obj as ProductMainFieldTranslation;
			if (other == null)
				return false;

			return other.id == this._id &&
				other.idParentProduct == this._idParentProduct &&
				other.mainField == this._mainField &&
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
				result = (result * 397) ^ _mainField;
				result = (result * 397) ^ (_langCode == null ? 0 : _langCode.GetHashCode());
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductMainFieldTranslation: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - idParentProduct: ").Append(this._idParentProduct)
			.Append(" - mainField: ").Append(this._mainField)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - value: ").Append(this._value);
			
			return builder.ToString();			
		}
	}
}