using System;
using System.Text;

namespace com.nemesys.model
{
	public class ContentAttachment
	{	
		private int _id;
		private int _idParentContent;
		private string _filePath;
		private string _fileName;
		private string _contentType;
		private string _fileDida;
		private int _fileLabel;
		private DateTime _insertDate;

		
		public ContentAttachment(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idParentContent {
			get { return _idParentContent; }
			set { _idParentContent = value; }
		}

		public virtual string filePath {
			get { return _filePath; }
			set { _filePath = value; }
		}

		public virtual string fileName {
			get { return _fileName; }
			set { _fileName = value; }
		}

		public virtual string contentType {
			get { return _contentType; }
			set { _contentType = value; }
		}

		public virtual string fileDida {
			get { return _fileDida; }
			set { _fileDida = value; }
		}

		public virtual int fileLabel {
			get { return _fileLabel; }
			set { _fileLabel = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("ContentAttachment id: ")
			.Append(this._id)
			.Append(" - idParentContent: ").Append(this._idParentContent)
			.Append(" - filePath: ").Append(this._filePath)
			.Append(" - fileName: ").Append(this._fileName)
			.Append(" - contentType: ").Append(this._contentType)
			.Append(" - fileDida: ").Append(this._fileDida)
			.Append(" - fileLabel: ").Append(this._fileLabel)
			.Append(" - insertDate: ").Append(this._insertDate);
			
			return builder.ToString();			
		}
	}
}