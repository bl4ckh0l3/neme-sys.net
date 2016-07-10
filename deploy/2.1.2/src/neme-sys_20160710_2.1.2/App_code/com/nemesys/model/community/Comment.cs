using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Comment
	{	
		private int _id;
		private string _message;
		private int _elementId;
		private int _elementType;
		private int _voteType;
		private int _userId;
		private bool _active;
		private DateTime _insertDate;

		
		public Comment(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string message {
			get { return _message; }
			set { _message = value; }
		}

		public virtual int elementId {
			get { return _elementId; }
			set { _elementId = value; }
		}

		public virtual int elementType {
			get { return _elementType; }
			set { _elementType = value; }
		}

		public virtual int voteType {
			get { return _voteType; }
			set { _voteType = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Comment: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - message: ").Append(this._message)
			.Append(" - elementId: ").Append(this._elementId)
			.Append(" - elementType: ").Append(this._elementType)
			.Append(" - voteType: ").Append(this._voteType)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - active: ").Append(this._active)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}