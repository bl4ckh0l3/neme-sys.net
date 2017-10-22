using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace com.nemesys.model
{
	public class UserRole
	{	
		public enum Roles : int {ADMIN=1, EDITOR=2, GUEST=3};

		private int _id;
		
		public UserRole(){}
		
		public UserRole(int id){
			_id = id;
		}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public string label {
			get { return Enum.GetName(typeof(Roles), id); }
		}

		public string labelU {
			get { return UppercaseFirst(Enum.GetName(typeof(Roles), id).ToLower()); }
		}

		public bool isAdmin() {
			return (int)Roles.ADMIN == _id;
		}

		public bool isEditor() {
			return (int)Roles.EDITOR == _id;
		}

		public bool isGuest() {
			return (int)Roles.GUEST == _id;
		}

		public bool isInRole(int role) {
			return role == _id;
		}

		public static IList<int> roles()
		{
			IList<int> result = new List<int>();			
			foreach(int role in Enum.GetValues(typeof(Roles)))
			{
				result.Add(role);
			}
			return result;
		}
				
		public static string UppercaseFirst(string s)
		{
			if (string.IsNullOrEmpty(s))
			{
				return string.Empty;
			}
			char[] a = s.ToCharArray();
			a[0] = char.ToUpper(a[0]);
			return new string(a);
		}
	}
}