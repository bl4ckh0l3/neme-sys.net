using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductCalendar : IComparable<ProductCalendar>
	{	
		private int _id;
		private int _idParentProduct;
		private DateTime _startDate;
		private int _availability;
		private int _unit;
		private string _content;

		
		public ProductCalendar(){}
		
		public ProductCalendar(DateTime startDate){
			this._startDate=startDate;
		}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual DateTime startDate {
			get { return _startDate; }
			set { _startDate = value; }
		}

		public virtual int availability {
			get { return _availability; }
			set { _availability = value; }
		}

		public virtual int unit {
			get { return _unit; }
			set { _unit = value; }
		}

		public virtual string content {
			get { return _content; }
			set { _content = value; }
		}
		
		public virtual int CompareTo(ProductCalendar other)
		{
			int val = this._startDate.Date.CompareTo(other.startDate.Date);
			return val;
		}		

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductCalendar id: ")
			.Append(this._id)
			.Append(" - idParentProduct: ").Append(this._idParentProduct)
			.Append(" - startDate: ").Append(this._startDate)
			.Append(" - availability: ").Append(this._availability)
			.Append(" - unit: ").Append(this._unit)
			.Append(" - content: ").Append(this._content);
			
			return builder.ToString();			
		}
	}
}