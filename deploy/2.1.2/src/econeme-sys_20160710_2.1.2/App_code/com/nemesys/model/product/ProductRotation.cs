using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductRotation
	{	
		private int _idRotationMode;
		private int _idParent;
		private string _rotationValue;
		private DateTime _lastUpdate;
		
		public ProductRotation(){}
		
		public ProductRotation(int idParent, int idRotationMode, string rotationValue, DateTime lastUpdate){
			this._idParent=idParent;
			this._idRotationMode=idRotationMode;
			this._rotationValue=rotationValue;
			this._lastUpdate=lastUpdate;
		}

		public virtual int idParent {
			get { return _idParent; }
			set { _idParent = value; }
		}

		public virtual int idRotationMode {
			get { return _idRotationMode; }
			set { _idRotationMode = value; }
		}

		public virtual string rotationValue {
			get { return _rotationValue; }
			set { _rotationValue = value; }
		}

		public virtual DateTime lastUpdate {
			get { return _lastUpdate; }
			set { _lastUpdate = value; }
		}
		
		public override bool Equals(object obj)
		{
			ProductRotation other = obj as ProductRotation;
			if (other == null)
				return false;

			return other.idRotationMode == this._idRotationMode &&
				other.idParent == this._idParent;
		}

		public override int GetHashCode()
		{
			unchecked
			{
				int result = 0;
				result = (result * 397) ^ _idParent;
				result = (result * 397) ^ _idRotationMode;
				return result;
			}
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ProductRotation idParent: ")
			.Append(this._idParent)
			.Append(" - idRotationMode: ").Append(this._idRotationMode)
			.Append(" - rotationValue: ").Append(this._rotationValue)
			.Append(" - lastUpdate: ").Append(this._lastUpdate);
			
			return builder.ToString();			
		}
	}
}