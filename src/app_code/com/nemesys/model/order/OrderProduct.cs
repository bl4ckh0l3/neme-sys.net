using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderProduct
	{	
		private int _idOrder;
		private int _idProduct;
		private int _productCounter;
		private int _productQuantity;
		private int _productType;
		private string _productName;	
		private decimal _amount;
		private decimal _taxable;
		private decimal _supplement;	
		private decimal _discountPerc;	
		private decimal _discount;	
		private decimal _margin;	
		private string _supplementDesc;	
		private int _idAds;
	
		public OrderProduct(){}

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

		public virtual int productQuantity {
			get { return _productQuantity; }
			set { _productQuantity = value; }
		}

		public virtual int productType {
			get { return _productType; }
			set { _productType = value; }
		}

		public virtual string productName {
			get { return _productName; }
			set { _productName = value; }
		}

		public virtual decimal amount {
			get { return _amount; }
			set { _amount = value; }
		}

		public virtual decimal taxable {
			get { return _taxable; }
			set { _taxable = value; }
		}

		public virtual decimal supplement {
			get { return _supplement; }
			set { _supplement = value; }
		}

		public virtual decimal discountPerc {
			get { return _discountPerc; }
			set { _discountPerc = value; }
		}

		public virtual decimal discount {
			get { return _discount; }
			set { _discount = value; }
		}

		public virtual decimal margin {
			get { return _margin; }
			set { _margin = value; }
		}

		public virtual string supplementDesc {
			get { return _supplementDesc; }
			set { _supplementDesc = value; }
		}

		public virtual int idAds {
			get { return _idAds; }
			set { _idAds = value; }
		}
		
		public override bool Equals(object obj)
		{
			OrderProduct other = obj as OrderProduct;
			if (other == null)
				return false;

			return other.idOrder == this._idOrder &&
				other.idProduct == this._idProduct &&
				other.productCounter == this._productCounter &&
				other.productQuantity == this._productQuantity &&
				other.productType == this._productType &&
				other.productName == this._productName &&
				other.amount == this._amount &&
				other.taxable == this._taxable &&
				other.supplement == this._supplement &&
				other.discountPerc == this._discountPerc &&
				other.discount == this._discount &&
				other.margin == this._margin &&
				other.supplementDesc == this._supplementDesc &&
				other.idAds == this._idAds;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idOrder;
				result = (result * 397) ^ _idProduct;
				result = (result * 397) ^ _productCounter;
				result = (result * 397) ^ _productQuantity;
				result = (result * 397) ^ _productType;
				result = (result * 397) ^ (_productName == null ? 0 : _productName.GetHashCode());
				result = (result * 397) ^ (_amount == null ? 0 : _amount.GetHashCode());
				result = (result * 397) ^ (_taxable == null ? 0 : _taxable.GetHashCode());
				result = (result * 397) ^ (_supplement == null ? 0 : _supplement.GetHashCode());
				result = (result * 397) ^ (_discountPerc == null ? 0 : _discountPerc.GetHashCode());
				result = (result * 397) ^ (_discount == null ? 0 : _discount.GetHashCode());
				result = (result * 397) ^ (_margin == null ? 0 : _margin.GetHashCode());
				result = (result * 397) ^ (_supplementDesc == null ? 0 : _supplementDesc.GetHashCode());
				result = (result * 397) ^ _idAds;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderProduct: ")
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idProduct: ").Append(this._idProduct)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - productQuantity: ").Append(this._productQuantity)
			.Append(" - productType: ").Append(this._productType)
			.Append(" - productName: ").Append(this._productName)
			.Append(" - amount: ").Append(this._amount)
			.Append(" - taxable: ").Append(this._taxable)
			.Append(" - supplement: ").Append(this._supplement)
			.Append(" - discountPerc: ").Append(this._discountPerc)
			.Append(" - discount: ").Append(this._discount)
			.Append(" - margin: ").Append(this._margin)
			.Append(" - supplementDesc: ").Append(this._supplementDesc)
			.Append(" - idAds: ").Append(this._idAds);
			
			return builder.ToString();			
		}
	}
}