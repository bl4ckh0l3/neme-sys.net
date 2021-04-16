using System;
using System.Text;

namespace com.nemesys.model
{
	public class UserDownload
	{	
		private int _id;
		private string _user;
		private int _idFile;
		private string _fileName;
		private string _contentType;
		private string _filePath;
		private string _userHost;
		private string _userInfo;
		private DateTime _downloadDate;

		
		public UserDownload(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string user {
			get { return _user; }
			set { _user = value; }
		}

		public virtual int idFile {
			get { return _idFile; }
			set { _idFile = value; }
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

		public virtual string userHost {
			get { return _userHost; }
			set { _userHost = value; }
		}

		public virtual string userInfo {
			get { return _userInfo; }
			set { _userInfo = value; }
		}

		public virtual DateTime downloadDate {
			get { return _downloadDate; }
			set { _downloadDate = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("UserDownload id: ")
			.Append(this._id)
			.Append(" - user: ").Append(this._user)
			.Append(" - idFile: ").Append(this._idFile)
			.Append(" - fileName: ").Append(this._fileName)
			.Append(" - contentType: ").Append(this._contentType)
			.Append(" - filePath: ").Append(this._filePath)
			.Append(" - userHost: ").Append(this._userHost)
			.Append(" - userInfo: ").Append(this._userInfo)
			.Append(" - downloadDate: ").Append(this._downloadDate);
			
			return builder.ToString();			
		}
	}
}