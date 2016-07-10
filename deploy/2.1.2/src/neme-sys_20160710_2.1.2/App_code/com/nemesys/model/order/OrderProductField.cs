using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderProductField : IComparable<OrderProductField>, IEquatable<OrderProductField>
	{	
		private int _idOrder;
		private int _idProduct;
		private int _productCounter;
		private int _idField;
		private int _fieldType;
		private string _value;
		private int _productQuantity;
		private string _description;	
		
		public OrderProductField(){}

		public virtual int idOrder {
			get { return _idOrder; }
			set { _idOrder = value; }
		}

		public virtual int idProduct {
			get { return _idProduct; }
			set { _idProduct = value; }
		}

		public virtual int productCounter {
			get { return _productCounter; }
			set { _productCounter = value; }
		}

		public virtual int idField {
			get { return _idField; }
			set { _idField = value; }
		}

		public virtual int fieldType {
			get { return _fieldType; }
			set { _fieldType = value; }
		}

		public virtual string value {
			get { return _value; }
			set { _value = value; }
		}

		public virtual int productQuantity {
			get { return _productQuantity; }
			set { _productQuantity = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual int CompareTo(OrderProductField other)
		{
			int val = this._idProduct.CompareTo(other.idProduct);
			return val;
		}

		public virtual bool Equals(OrderProductField other) 
		{
			if (other == null) 
				return false;
			
			return other.idOrder == this._idOrder &&
				other.idProduct == this._idProduct &&
				other.productCounter == this._productCounter &&
				other.idField == this._idField &&
				other.fieldType == this._fieldType &&
				other.value == this._value &&
				//other.productQuantity == this._productQuantity &&
				other.description == this._description;
		} 		
		
		public override bool Equals(Object obj)
		{
			if (obj == null) 
				return false;
     
			OrderProductField other = obj as OrderProductField;
			if (other == null)
				return false;

			return Equals(other);
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idOrder;
				result = (result * 397) ^ _idProduct;
				result = (result * 397) ^ _productCounter;
				result = (result * 397) ^ _idField;
				result = (result * 397) ^ _fieldType;
				result = (result * 397) ^ (_value == null ? 0 : _value.GetHashCode());
				//result = (result * 397) ^ _productQuantity;
				result = (result * 397) ^ (_description == null ? 0 : _description.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderProductField: ")
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idProduct: ").Append(this._idProduct)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - idField: ").Append(this._idField)
			.Append(" - fieldType: ").Append(this._fieldType)
			.Append(" - value: ").Append(this._value)
			.Append(" - productQuantity: ").Append(this._productQuantity)
			.Append(" - description: ").Append(this._description);
			
			return builder.ToString();			
		}
	}
}