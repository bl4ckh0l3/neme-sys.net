using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;

namespace com.nemesys.model
{
	public class OfferType
	{	
		public enum Types : int {LIGHT=1, GAS=2, GASLIGHT=3};

		private int _id;
		
		public OfferType(){}
		
		public OfferType(int id){
			_id = id;
		}

		public virtual int id {
			get { return _id; }
			set { _id = value; }
		}

		public string label {
			get { return Enum.GetName(typeof(Types), id); }
		}

		public string labelU {
			get { return UppercaseFirst(Enum.GetName(typeof(Types), id).ToLower()); }
		}

		public bool isLight() {
			return (int)Types.LIGHT == _id;
		}

		public bool isGas() {
			return (int)Types.GAS == _id;
		}

		public bool isGasLight() {
			return (int)Types.GASLIGHT == _id;
		}

		public bool isInType(int type) {
			return type == _id;
		}

		public static IList<int> types()
		{
			IList<int> result = new List<int>();			
			foreach(int type in Enum.GetValues(typeof(Types)))
			{
				result.Add(type);
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