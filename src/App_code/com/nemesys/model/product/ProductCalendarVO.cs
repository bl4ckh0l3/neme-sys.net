using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductCalendarVO
	{	
		private ProductCalendar _calendar;
		private int _rooms;


		public ProductCalendarVO(){}
		
		public ProductCalendarVO(ProductCalendar p, int rooms){
			this._calendar = p;
			this._rooms = rooms;
		}

		public virtual ProductCalendar calendar {
			get { return _calendar; }
			set { _calendar = value; }
		}

		public virtual int rooms {
			get { return _rooms; }
			set { _rooms = value; }
		}		

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductCalendarVO: ")
			.Append(" - ProductCalendar: ").Append(this._calendar.ToString())
			.Append(" - rooms: ").Append(this._rooms);
			
			return builder.ToString();			
		}
	}
}