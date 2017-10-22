using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Data;

namespace com.nemesys.model
{
	public class ProductCalendarEventData
	{	
		//private string __id;
		private string _title;
		private DateTime _start;
		private DateTime _end;
		private int _availability;
		private int _unit;
		private bool _allDay;
		private bool _overlap;
		private int _price_type;
		private IDictionary<string,string> _price;
		//room:
		//adult:
		//childs_0_2:
		//childs_3_11:
		//childs_12_17:
		//discount:
		
		
		public ProductCalendarEventData(){}

		/*public virtual string _id {
			get { return __id; }
			set { __id = value; }
		}*/

		public virtual string title {
			get { return _title; }
			set { _title = value; }
		}

		public virtual DateTime start {
			get { return _start; }
			set { _start = value; }
		}

		public virtual DateTime end {
			get { return _end; }
			set { _end = value; }
		}
		
		public virtual int availability {
			get { return _availability; }
			set { _availability = value; }
		}
		
		public virtual int unit {
			get { return _unit; }
			set { _unit = value; }
		}
		
		public virtual bool allDay {
			get { return _allDay; }
			set { _allDay = value; }
		}
		
		public virtual bool overlap {
			get { return _overlap; }
			set { _overlap = value; }
		}
		
		public virtual int price_type {
			get { return _price_type; }
			set { _price_type = value; }
		}
		
		public virtual IDictionary<string,string> price {
			get { return _price; }
			set { _price = value; }
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductCalendarEventData: ")
			//.Append(" - _id: ").Append(this.__id)
			.Append(" - title: ").Append(this._title)
			.Append(" - start: ").Append(this._start)
			.Append(" - end: ").Append(this._end)
			.Append(" - availability: ").Append(this._availability)
			.Append(" - unit: ").Append(this._unit)
			.Append(" - allDay: ").Append(this._allDay)
			.Append(" - overlap: ").Append(this._overlap)
			.Append(" - price_type: ").Append(this._availability)
			.Append(" - price: ").Append(this._price_type.ToString());
			
			return builder.ToString();			
		}
	}
}