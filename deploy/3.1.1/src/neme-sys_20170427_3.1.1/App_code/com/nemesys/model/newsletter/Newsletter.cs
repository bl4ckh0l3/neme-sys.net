using System;
using System.Data;
using System.Text;

namespace com.nemesys.model
{
	public class Newsletter
	{	
		private int _id;
		private string _description;
		private bool _isActive;
		private int _templateId;
		private int _idVoucherCampaign;
		private DateTime _modifyDate;
		
		public Newsletter(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}

		public virtual int templateId {
			get { return _templateId; }
			set { _templateId = value; }
		}

		public virtual int idVoucherCampaign {
			get { return _idVoucherCampaign; }
			set { _idVoucherCampaign = value; }
		}

		public virtual DateTime modifyDate {
			get { return _modifyDate; }
			set { _modifyDate = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Newsletter: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - description: ").Append(this._description)
			.Append(" - isActive: ").Append(this._isActive)
			.Append(" - templateId: ").Append(this._templateId)
			.Append(" - idVoucherCampaign: ").Append(this._idVoucherCampaign)
			.Append(" - modifyDate: ").Append(this._modifyDate);
			
			return builder.ToString();			
		}
	}
}