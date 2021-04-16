using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class Preference
	{	
		private int _id;
		private int _userId;
		private int _friendId;
		private int _commentId;
		private int _commentType;
		private int _type;
		private string _message;
		private DateTime _insertDate;
		private bool _active;

		
		public Preference(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int userId {
			get { return _userId; }
			set { _userId = value; }
		}

		public virtual int friendId {
			get { return _friendId; }
			set { _friendId = value; }
		}

		public virtual int commentId {
			get { return _commentId; }
			set { _commentId = value; }
		}

		public virtual int commentType {
			get { return _commentType; }
			set { _commentType = value; }
		}

		public virtual int type {
			get { return _type; }
			set { _type = value; }
		}

		public virtual string message {
			get { return _message; }
			set { _message = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual bool active {
			get { return _active; }
			set { _active = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("Preference: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - userId: ").Append(this._userId)
			.Append(" - friendId: ").Append(this._friendId)
			.Append(" - commentId: ").Append(this._commentId)
			.Append(" - commentType: ").Append(this._commentType)
			.Append(" - type: ").Append(this._type)
			.Append(" - message: ").Append(this._message)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - active: ").Append(this._active);
			
			return builder.ToString();			
		}
	}
}