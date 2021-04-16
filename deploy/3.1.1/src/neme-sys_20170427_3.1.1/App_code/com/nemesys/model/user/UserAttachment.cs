using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserAttachment : IComparable<UserAttachment>
	{	
		private int _id;
		private int _idUser;
		private string _fileName;
		private string _contentType;
		private string _filePath;
		private string _fileDida;
		private string _fileLabel;
		private bool _isAvatar;
		private DateTime _insertDate;

		
		public UserAttachment(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idUser {
			get { return _idUser; }
			set { _idUser = value; }
		}

		public virtual string fileName {
			get { return _fileName; }
			set { _fileName = value; }
		}

		public virtual string contentType {
			get { return _contentType; }
			set { _contentType = value; }
		}

		public virtual string filePath {
			get { return _filePath; }
			set { _filePath = value; }
		}

		public virtual string fileDida {
			get { return _fileDida; }
			set { _fileDida = value; }
		}

		public virtual string fileLabel {
			get { return _fileLabel; }
			set { _fileLabel = value; }
		}

		public virtual bool isAvatar {
			get { return _isAvatar; }
			set { _isAvatar = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual int CompareTo(UserAttachment other)
		{
			int val = other.id.CompareTo(this._id);
			return val;
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserAttachment id: ")
			.Append(this._id)
			.Append(" - idUser: ").Append(this._idUser)
			.Append(" - fileName: ").Append(this._fileName)
			.Append(" - contentType: ").Append(this._contentType)
			.Append(" - filePath: ").Append(this._filePath)
			.Append(" - fileDida: ").Append(this._fileDida)
			.Append(" - fileLabel: ").Append(this._fileLabel)
			.Append(" - isAvatar: ").Append(this._isAvatar)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}