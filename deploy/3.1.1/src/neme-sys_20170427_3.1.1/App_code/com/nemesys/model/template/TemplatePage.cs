using System;
using System.Text;

namespace com.nemesys.model
{
	public class TemplatePage : IComparable<TemplatePage>
	{	
		private int _id;
		private int _templateId;
		private string _filePath;
		private string _fileName;
		private int _priority;

		
		public TemplatePage(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual int templateId {
			get { return _templateId; }
			set { _templateId = value; }
		}

		public virtual string filePath {
			get { return _filePath; }
			set { _filePath = value; }
		}

		public virtual string fileName {
			get { return _fileName; }
			set { _fileName = value; }
		}

		public virtual int priority {
			get { return _priority; }
			set { _priority = value; }
		}

		public virtual int CompareTo(TemplatePage other)
		{
			int val = this._priority.CompareTo(other.priority);
			return val;
		}

		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("TemplatePage: ")
			.Append(" - id: ").Append(this._id)
			.Append(" - templateId: ").Append(this._templateId)
			.Append(" - filePath: ").Append(this._filePath)
			.Append(" - fileName: ").Append(this._fileName)
			.Append(" - priority: ").Append(this._priority);
			
			return builder.ToString();			
		}
	}
}