using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductFieldsValue : IComparable<ProductFieldsValue>
	{
		private int _idParentField;
		private string _value;
		private int _sorting;
		private int _quantity;
		
		public ProductFieldsValue(){}
		
		public virtual int idParentField {
			get { return _idParentField; }
			set { _idParentField = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual int sorting {
			get { return _sorting; }
			set { _sorting = value; }
		}

		public virtual int quantity {
			get { return _quantity; }
			set { _quantity = value; }
		}

		public virtual int CompareTo(ProductFieldsValue other)
		{
			int val = this._sorting.CompareTo(other.sorting);
			//System.Web.HttpContext.Current.Response.Write("this._hierarchy:"+this._hierarchy+" - other._hierarchy:"+other._hierarchy+" - compareTo val:"+val+"<br>");
			return val;
		}
		
		public override bool Equals(object obj)
		{
			ProductFieldsValue other = obj as ProductFieldsValue;
			if (other == null)
				return false;

			return other.idParentField == this._idParentField &&
				other.value == this._value &&
				other.sorting == this._sorting &&
				other.quantity == this._quantity;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentField;
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				result = (result * 397) ^ _sorting;
				result = (result * 397) ^ _quantity;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductFieldsValue: ")
			.Append(" - idParentField: ").Append(this._idParentField)
			.Append(" - value: ").Append(this._value)
			.Append(" - sorting: ").Append(this._sorting)
			.Append(" - quantity: ").Append(this._quantity);
			
			return builder.ToString();			
		}
	}
}