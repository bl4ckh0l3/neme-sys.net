using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace com.nemesys.model
{
	public class User
	{	
		private int _id;
		private string _username;
		private string _password;
		private string _email;
		private bool _privacyAccept;
		private bool _hasNewsletter;
		private bool _isActive;
		private decimal _discount;
		private string _boComments;
		private bool _isPublicProfile;
		private bool _isAutomaticUser;
		private DateTime _insertDate;
		private DateTime _modifyDate;
		private UserRole _role;
		private IList<UserFriend> _friends;
		private IList<UserAttachment> _attachments;
		private IList<UserLanguage> _languages;
		private IList<UserCategory> _categories;
		private IList<UserNewsletter> _newsletters;
		private IList<UserFieldsMatch> _fields;
		private int _userGroup;
		
		public User(){}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public virtual string username {
			get { return _username; }
			set { _username = value; }
		}

		public virtual string password {
			get { return _password; }
			set { _password = value; }
		}

		public virtual string email {
			get { return _email; }
			set { _email = value; }
		}

		public virtual bool privacyAccept {
			get { return _privacyAccept; }
			set { _privacyAccept = value; }
		}

		public virtual bool hasNewsletter {
			get { return _hasNewsletter; }
			set { _hasNewsletter = value; }
		}

		public virtual bool isActive {
			get { return _isActive; }
			set { _isActive = value; }
		}

		public virtual decimal discount {
			get { return _discount; }
			set { _discount = value; }
		}

		public virtual string boComments {
			get { return _boComments; }
			set { _boComments = value; }
		}

		public virtual bool isAutomaticUser {
			get { return _isAutomaticUser; }
			set { _isAutomaticUser = value; }
		}

		public virtual bool isPublicProfile {
			get { return _isPublicProfile; }
			set { _isPublicProfile = value; }
		}

		public virtual DateTime insertDate {
			get { return _insertDate; }
			set { _insertDate = value; }
		}

		public virtual DateTime modifyDate {
			get { return _modifyDate; }
			set { _modifyDate = value; }
		}

		public virtual UserRole role {
			get { return _role; }
			set { _role = value; }
		}

		public virtual int userGroup {
			get { return _userGroup; }
			set { _userGroup = value; }
		}

		public virtual IList<UserFriend> friends {
			get { return _friends; }
			set { _friends = value; }
		}
	
		public virtual IList<UserAttachment> attachments {
			get { return _attachments; }
			set { _attachments = value; }
		}

		public virtual IList<UserLanguage> languages {
			get { return _languages; }
			set { _languages = value; }
		}

		public virtual IList<UserCategory> categories {
			get { return _categories; }
			set { _categories = value; }
		}

		public virtual IList<UserNewsletter> newsletters {
			get { return _newsletters; }
			set { _newsletters = value; }
		}

		public virtual IList<UserFieldsMatch> fields {
			get { return _fields; }
			set { _fields = value; }
		}

		
		public virtual string ToString() {
			StringBuilder builder = new StringBuilder("User id: ")
			.Append(this._id)
			.Append(" - username: ").Append(this._username)
			.Append(" - password: ").Append(this._password)
			.Append(" - email: ").Append(this._email)
			.Append(" - privacyAccept: ").Append(this._privacyAccept)
			.Append(" - hasNewsletter: ").Append(this._hasNewsletter)
			.Append(" - isActive: ").Append(this._isActive)
			.Append(" - discount: ").Append(this._discount)
			.Append(" - boComments: ").Append(this._boComments)
			.Append(" - isPublicProfile: ").Append(this._isPublicProfile)
			.Append(" - isAutomaticUser: ").Append(this._isAutomaticUser)
			.Append(" - role: ").Append(this._role.label)
			.Append(" - userGroup: ").Append(this._userGroup)
			.Append(" - insertDate: ").Append(this._insertDate)
			.Append(" - modifyDate: ").Append(this._modifyDate);
			/*if(this._attachments != null){
				builder.Append(" - attachments: ").Append(this._attachments.Count);
			}
			if(this._friends != null){
				builder.Append(" - friends: ").Append(this._friends.Count);
			}*/
			
			return builder.ToString();			
		}
	}
}