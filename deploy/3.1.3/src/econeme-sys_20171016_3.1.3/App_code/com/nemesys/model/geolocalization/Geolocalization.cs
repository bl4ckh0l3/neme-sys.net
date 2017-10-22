using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class Geolocalization : IComparable<Geolocalization>
	{		
		private int _id;
		private int _idElement;
		private int _type;
		private decimal _latitude;
		private decimal _longitude;
		private string _txtInfo;	
		
		public Geolocalization(){}
		
		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idElement {
			get { return _idElement; }
			set { _idElement = value; }
		}
		
		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual decimal latitude {
			get { return _latitude; }
			set { _latitude = value; }
		}

		public virtual decimal longitude {
			get { return _longitude; }
			set { _longitude = value; }
		}

		public virtual string txtInfo {
			get { return _txtInfo; }
			set { _txtInfo = value; }
		}

		public virtual int CompareTo(Geolocalization other)
		{
			return this._id.CompareTo(other.id);
		}
		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Geolocalization id: ")
			.Append(this._id)
			.Append(" - idElement: ").Append(this._idElement)
			.Append(" - type: ").Append(this._type)
			.Append(" - latitude: ").Append(this._latitude)
			.Append(" - longitude: ").Append(this._longitude)
			.Append(" - txtInfo: ").Append(this._txtInfo);
			
			return builder.ToString();			
		}
	}
}