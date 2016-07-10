using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductFieldsRelValue
	{
		private int _idProduct;
		private int _idParentField;
		private string _fieldValue;
		private int _idParentRelField;
		private string _fieldRelValue;
		private string _fieldRelName;
		private int _quantity;
		
		public ProductFieldsRelValue(){}
		
		public ProductFieldsRelValue(int idProduct, int idParentField, string fieldValue, int idParentRelField, string fieldRelValue){
			this._idProduct = idProduct;
			this._idParentField = idParentField;
			this._fieldValue = fieldValue;
			this._idParentRelField = idParentRelField;
			this._fieldRelValue = fieldRelValue;
		}
		
		public virtual int idProduct {
			get { return _idProduct; }
			set { _idProduct = value; }
		}
		
		public virtual int idParentField {
			get { return _idParentField; }
			set { _idParentField = value; }
		}

		public virtual string fieldValue {
			get { return _fieldValue; }
			set { _fieldValue = value; }
		}

		public virtual int idParentRelField {
			get { return _idParentRelField; }
			set { _idParentRelField = value; }
		}

		public virtual string fieldRelValue {
			get { return _fieldRelValue; }
			set { _fieldRelValue = value; }
		}

		public virtual string fieldRelName {
			get { return _fieldRelName; }
			set { _fieldRelName = value; }
		}

		public virtual int quantity {
			get { return _quantity; }
			set { _quantity = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductFieldsRelValue other = obj as ProductFieldsRelValue;
			if (other == null)
				return false;

			return other.idProduct == this._idProduct &&
				other.idParentField == this._idParentField &&
				other.fieldValue == this._fieldValue &&
				other.idParentRelField == this._idParentRelField &&
				other.fieldRelValue == this._fieldRelValue;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idProduct;
				result = (result * 397) ^ _idParentField;
				result = (result * 397) ^ (_fieldValue == null ? 0 : _fieldValue.GetHashCode());
				result = (result * 397) ^ _idParentRelField;
				result = (result * 397) ^ (_fieldRelValue == null ? 0 : _fieldRelValue.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductFieldsRelValue: ")
			.Append(" - idProduct: ").Append(this._idProduct)
			.Append(" - idParentField: ").Append(this._idParentField)
			.Append(" - fieldValue: ").Append(this._fieldValue)
			.Append(" - idParentRelField: ").Append(this._idParentRelField)
			.Append(" - fieldRelValue: ").Append(this._fieldRelValue)
			.Append(" - fieldRelName: ").Append(this._fieldRelName)
			.Append(" - quantity: ").Append(this._quantity);
			
			return builder.ToString();			
		}
	}
}