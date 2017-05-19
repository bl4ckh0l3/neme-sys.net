using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using com.nemesys.services;

namespace com.nemesys.model
{
	public class Utils
	{
		private static ConfigurationService configService = new ConfigurationService();
		
		public static UriBuilder getBaseUrl(string RequestUrl, int useHttps)	
		{
			UriBuilder redirectUrl = new UriBuilder(RequestUrl);
			if( configService.get("use_https").value=="2" ||
			   (configService.get("use_https").value=="1" && useHttps==1) || 
		  	   (configService.get("use_https").value=="1" && useHttps==2 && "https".Equals(redirectUrl.Scheme))
		  	  )
			{	
				redirectUrl.Scheme = "https";
			}
			else
			{
				redirectUrl.Scheme = "http";
			}
			redirectUrl.Port = -1;	
			redirectUrl.Path = "";
			redirectUrl.Query="";
			
			return redirectUrl;
		}		
		
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
		
		public static bool isValidExtension(string ext)
		{
			IList<string> acceptedExtension = new List<string>();
			acceptedExtension.Add(".jpg");
			acceptedExtension.Add(".jpeg");
			acceptedExtension.Add(".png");
			acceptedExtension.Add(".gif");
			acceptedExtension.Add(".bmp");
			acceptedExtension.Add(".doc");
			acceptedExtension.Add(".docx"); 
			acceptedExtension.Add(".xls");
			acceptedExtension.Add(".xlsx");
			acceptedExtension.Add(".pdf");
			acceptedExtension.Add(".csv");
			acceptedExtension.Add(".zip");	
			
			return acceptedExtension.Contains(ext);
		}
	}
}