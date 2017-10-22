using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductLanguage
	{	
		private int _idLanguage;
		private int _idParentProduct;
		
		public ProductLanguage(){}

		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual int idLanguage {
			get { return _idLanguage; }
			set { _idLanguage = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductLanguage other = obj as ProductLanguage;
			if (other == null)
				return false;

			return other.idLanguage == this._idLanguage &&
				other.idParentProduct == this._idParentProduct;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParentProduct;
				result = (result * 397) ^ _idLanguage;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductLanguage idParentProduct: ")
			.Append(this._idParentProduct)
			.Append(" - idLanguage: ").Append(this._idLanguage);
			
			return builder.ToString();			
		}
	}
}