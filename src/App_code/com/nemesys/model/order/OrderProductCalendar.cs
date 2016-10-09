using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderProductCalendar : IComparable<OrderProductCalendar>, IEquatable<OrderProductCalendar>
	{	
		private int _idOrder;
		private int _idProduct;
		private int _productCounter;
		private DateTime _date;
		private int _adults;
		private int _children;
		private int _rooms;
		private string _childrenAge;
		private string _searchText;
		
		public OrderProductCalendar(){}

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

		public virtual DateTime date {
			get { return _date; }
			set { _date = value; }
		}

		public virtual int adults {
			get { return _adults; }
			set { _adults = value; }
		}

		public virtual int children {
			get { return _children; }
			set { _children = value; }
		}

		public virtual int rooms {
			get { return _rooms; }
			set { _rooms = value; }
		}

		public virtual string childrenAge {
			get { return _childrenAge; }
			set { _childrenAge = value; }
		}

		public virtual string searchText {
			get { return _searchText; }
			set { _searchText = value; }
		}

		public virtual int CompareTo(OrderProductCalendar other)
		{
			int val = this._idProduct.CompareTo(other.idProduct);
			return val;
		}

		public virtual bool Equals(OrderProductCalendar other) 
		{
			if (other == null) 
				return false;
			
			return other.idOrder == this._idOrder &&
				other.idProduct == this._idProduct &&
				other.productCounter == this._productCounter &&
				other.date == this._date &&
				other.adults == this._adults &&
				other.children == this._children &&
				other.rooms == this._rooms &&
				other.childrenAge == this._childrenAge &&
				other.searchText == this._searchText;
		} 		
		
		public override bool Equals(Object obj)
		{
			if (obj == null) 
				return false;
     
			OrderProductCalendar other = obj as OrderProductCalendar;
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
				result = (result * 397) ^ (_date == null ? 0 : _date.GetHashCode());
				result = (result * 397) ^ _adults;
				result = (result * 397) ^ _children;
				result = (result * 397) ^ _rooms;
				result = (result * 397) ^ (_childrenAge == null ? 0 : _childrenAge.GetHashCode());
				result = (result * 397) ^ (_searchText == null ? 0 : _searchText.GetHashCode());
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderProductCalendar: ")
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idProduct: ").Append(this._idProduct)
			.Append(" - productCounter: ").Append(this._productCounter)
			.Append(" - date: ").Append(this._date)
			.Append(" - adults: ").Append(this._adults)
			.Append(" - children: ").Append(this._children)
			.Append(" - rooms: ").Append(this._rooms)
			.Append(" - childrenAge: ").Append(this._childrenAge)
			.Append(" - searchText: ").Append(this._searchText);
			
			return builder.ToString();			
		}
	}
}