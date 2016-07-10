using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductCategory: IElementCategory
	{	
		private int _idCategory;
		private int _idParent;
		
		public ProductCategory(){}
		
		public ProductCategory(int idParent, int idCategory){
			this._idParent=idParent;
			this._idCategory=idCategory;
		}

		public virtual int idParent {
			get { return _idParent; }
			set { _idParent = value; }
		}

		public virtual int idCategory {
			get { return _idCategory; }
			set { _idCategory = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductCategory other = obj as ProductCategory;
			if (other == null)
				return false;

			return other.idCategory == this._idCategory &&
				other.idParent == this._idParent;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParent;
				result = (result * 397) ^ _idCategory;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductCategory idParent: ")
			.Append(this._idParent)
			.Append(" - idCategory: ").Append(this._idCategory);
			
			return builder.ToString();			
		}
	}
}