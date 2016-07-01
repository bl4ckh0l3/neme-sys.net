using System;
using System.Text;

namespace com.nemesys.model
{
	public class ProductAttachment
	{	
		private int _id;
		private int _idParentProduct;
		private string _filePath;
		private string _fileName;
		private string _contentType;
		private string _fileDida;
		private int _fileLabel;
		private DateTime _insertDate;

		
		public ProductAttachment(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int idParentProduct {
			get { return _idParentProduct; }
			set { _idParentProduct = value; }
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
			StringBuilder builder = new StringBuilder("ProductAttachment id: ")
			.Append(this._id)
			.Append(" - idParentProduct: ").Append(this._idParentProduct)
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