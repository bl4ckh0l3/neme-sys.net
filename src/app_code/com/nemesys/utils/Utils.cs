using System;
using System.Text;

namespace com.nemesys.model
{
	public class Utils
	{	
		public static string getCurrentCopyrightYearRange()	
		{
			return getCurrentCopyrightYearRange(2);
		}	

		public static string getCurrentCopyrightYearRange(int yearsRange)	
		{
			string copyright;
			try
			{	    
				DateTime current = DateTime.Now;
				int syyyy = current.Year;
				int eyyyy = syyyy-yearsRange;
				copyright=eyyyy+"-"+syyyy;
			}
			catch (Exception ex)
			{
				copyright = "";
			}
			return copyright;			
		}
		
		public static string encodeTo64(string toEncode)
		{
			string result = "";
			if(!String.IsNullOrEmpty(toEncode)){
				byte[] bytes = Encoding.UTF8.GetBytes(toEncode);
				result = Convert.ToBase64String(bytes);
			}
			return result;
		}
		
		public static string decodeFrom64(string toDecode)
		{
			string result = "";
			if(!String.IsNullOrEmpty(toDecode)){
				byte[] data = Convert.FromBase64String(toDecode);
				result = Encoding.UTF8.GetString(data);
			}
			return result;
		}
	}
}