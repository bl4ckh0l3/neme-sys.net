using System;
using System.Text;

namespace com.nemesys.model
{
	public class OrderProductAttachmentDownload
	{	
		private int _id;
		private int _idOrder;
		private int _idParentProduct;
		private int _idDownFile;
		private int _userId;
		private bool _active;
		private int _maxDownload;
		private DateTime _insertDate;
		private DateTime _expireDate;
		private DateTime _downloadDate;
		private int _downloadCounter;
		
		public OrderProductAttachmentDownload(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idOrder {
			get { return _idOrder; }
			set { _idOrder = value; }
		}

		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
		}

		public virtual int idDownFile {
			get { return _idDownFile; }
			set { _idDownFile = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual int maxDownload {
			get { return _maxDownload; }
			set { _maxDownload = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime expireDate {
			get { return _expireDate; }
			set { _expireDate = value; }
		}

		public virtual DateTime downloadDate {
			get { return _downloadDate; }
			set { _downloadDate = value; }
		}

		public virtual int downloadCounter {
			get { return _downloadCounter; }
			set { _downloadCounter = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("OrderProductAttachmentDownload id: ")
			.Append(this._id)
			.Append(" - idOrder: ").Append(this._idOrder)
			.Append(" - idParentProduct: ").Append(this._idParentProduct)
			.Append(" - idDownFile: ").Append(this._idDownFile)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - active: ").Append(this._active)
			.Append(" - maxDownload: ").Append(this._maxDownload)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - expireDate: ").Append(this._expireDate)
			.Append(" - downloadDate: ").Append(this._downloadDate)
			.Append(" - downloadCounter: ").Append(this._downloadCounter);
			
			return builder.ToString();			
		}
	}
}