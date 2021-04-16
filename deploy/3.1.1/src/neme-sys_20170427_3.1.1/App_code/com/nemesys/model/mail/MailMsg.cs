using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Net.Mail;
using System.Web.UI.WebControls;

namespace com.nemesys.model
{
	public class MailMsg
	{	
		private int _id;
		private string _name;
		private string _description;
		private string _langCode;
		private string _sender;
		private string _receiver;
		private string _cc;
		private string _bcc;
		private int _priority;
		private string _subject;
		private string _body;
		private bool _isActive;
		private bool _isBodyHTML;
		private bool _isBase;
		private MailCategory _mailCategory;
		private DateTime _modifyDate;
		
		public MailMsg(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string name {
			get { return _name; }
			set { _name = value; }
		}

		public virtual string description {
			get { return _description; }
			set { _description = value; }
		}

		public virtual string langCode {
			get { return _langCode; }
			set { _langCode = value; }
		}

		public virtual string sender {
			get { return _sender; }
			set { _sender = value; }
		}

		public virtual string receiver {
			get { return _receiver; }
			set { _receiver = value; }
		}

		public virtual string cc {
			get { return _cc; }
			set { _cc = value; }
		}

		public virtual string bcc {
			get { return _bcc; }
			set { _bcc = value; }
		}

		public virtual int priority {
			get { return _priority; }
			set { _priority = value; }
		}

		public virtual string subject {
			get { return _subject; }
			set { _subject = value; }
		}

		public virtual string body {
			get { return _body; }
			set { _body = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}

		public virtual bool isBodyHTML {
			get { return _isBodyHTML; }
			set { _isBodyHTML = value; }
		}

		public virtual bool isBase {
			get { return _isBase; }
			set { _isBase = value; }
		}

		public virtual MailCategory mailCategory {
			get { return _mailCategory; }
			set { _mailCategory = value; }
		}

		public virtual DateTime modifyDate {
			get { return _modifyDate; }
			set { _modifyDate = value; }
		}
		
		public virtual string ToString() {
			string mailCategory = "";
			if(this._mailCategory != null){
				mailCategory = this._mailCategory.name;
			}
			StringBuilder builder = new StringBuilder("MailMsg id: ")
			.Append(this._id)
			.Append(" - name: ").Append(this._name)
			.Append(" - description: ").Append(this._description)
			.Append(" - langCode: ").Append(this._langCode)
			.Append(" - sender: ").Append(this._sender)
			.Append(" - receiver: ").Append(this._receiver)
			.Append(" - cc: ").Append(this._cc)
			.Append(" - bcc: ").Append(this._bcc)
			.Append(" - priority: ").Append(this._priority)
			.Append(" - subject: ").Append(this._subject)
			.Append(" - body: ").Append(this._body)
			.Append(" - isActive: ").Append(this._isActive)
			.Append(" - isBodyHTML: ").Append(this._isBodyHTML)
			.Append(" - isBase: ").Append(this._isBase)
			.Append(" - mailCategory: ").Append(mailCategory)
			.Append(" - modifyDate: ").Append(this._modifyDate);
			
			return builder.ToString();			
		}
	}
}