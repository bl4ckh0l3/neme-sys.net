using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductRelation
	{	
		private int _idProductRel;
		private int _idParentProduct;
		
		public ProductRelation(){}

		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual int idProductRel {
			get { return _idProductRel; }
			set { _idProductRel = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductRelation other = obj as ProductRelation;
			if (other == null)
				return false;

			return other.idProductRel == this._idProductRel &&
				other.idParentProduct == this._idParentProduct;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentProduct;
				result = (result * 397) ^ _idProductRel;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductRelation idParentProduct: ")
			.Append(this._idParentProduct)
			.Append(" - idProductRel: ").Append(this._idProductRel);
			
			return builder.ToString();			
		}
	}
}