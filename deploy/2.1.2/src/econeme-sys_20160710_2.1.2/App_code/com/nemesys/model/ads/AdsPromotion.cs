using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class AdsPromotion
	{	
		private int _adsId;
		private int _elementId;
		private string _elementCode;
		private bool _active;
		private DateTime _insertDate;
		
		public AdsPromotion(){}

		public virtual int adsId {
			get { return _adsId; }
			set { _adsId = value; }
		}

		public virtual int elementId {
			get { return _elementId; }
			set { _elementId = value; }
		}

		public virtual string elementCode {
			get { return _elementCode; }
			set { _elementCode = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}
		
		public override bool Equals(object obj)
		{
			AdsPromotion other = obj as AdsPromotion;
			if (other == null)
				return false;

			return other.adsId == this._adsId &&
				other.elementId == this._elementId &&
				other.elementCode == this._elementCode &&
				other.active == this._active;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _adsId;
				result = (result * 397) ^ _elementId;
				result = (result * 397) ^ (_elementCode == null ? 0 : _elementCode.GetHashCode());
				result = (result * 397) ^ (_active == null ? 0 : _active.GetHashCode());
				return result;
			}
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("AdsPromotion: ")
			.Append(" - adsId: ").Append(this._adsId)
			.Append(" - elementId: ").Append(this._elementId)
			.Append(" - elementCode: ").Append(this._elementCode)
			.Append(" - active: ").Append(this._active)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}