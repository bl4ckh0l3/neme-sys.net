using System;
using System.Text;

namespace com.nemesys.model
{
	public class ShoppingCartProduct
	{	
		private int _idCart;
		private int _idProduct;
		private int _productCounter;
		private int _productQuantity;
		private int _productType;
		private string _productName;
		private int _idAds;
		
		
		public ShoppingCartProduct(){}

		public virtual int idCart {
			get { return _idCart; }
			set { _idCart = value; }
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

		public virtual int idAds {
			get { return _idAds; }
			set { _idAds = value; }
		}
		
		public override bool Equals(object obj)
		{
			ShoppingCartProduct other = obj as ShoppingCartProduct;
			if (other == null)
				return false;

			return other.idCart == this._idCart &&
				other.idProduct == this._idProduct &&
				other.productCounter == this._productCounter &&
				other.productQuantity == this._productQuantity &&
				other.productType == this._productType &&
				other.productName == this._productName &&
				other.idAds == this._idAds;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idCart;
				result = (result * 397) ^ _idProduct;
				result = (result * 397) ^ _productCounter;
				result = (result * 397) ^ _productQuantity;
				result = (result * 397) ^ _productType;
				result = (result * 397) ^ (_productName == null ? 0 : _productName.GetHashCode());
				result = (result * 397) ^ _idAds;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ShoppingCartProduct: ")
			.Append(" - idCart: ").Append(this._idCart)
			.Append(" - idProduct: ").Append(this._idProduct)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - productQuantity: ").Append(this._productQuantity)
			.Append(" - productType: ").Append(this._productType)
			.Append(" - productName: ").Append(this._productName)
			.Append(" - idAds: ").Append(this._idAds);
			
			return builder.ToString();			
		}
	}
}