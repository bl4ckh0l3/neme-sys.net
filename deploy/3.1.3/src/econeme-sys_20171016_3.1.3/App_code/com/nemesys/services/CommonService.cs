using System;
using System.Text;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Collections;
using System.Threading;
using System.Web.Caching;
using System.Xml;
using System.IO;
using com.nemesys.model;

namespace com.nemesys.services
{
	public class CommonService
	{	
		protected static ConfigurationService confService = new ConfigurationService();		
		
		public static UriBuilder getBaseUrl(string RequestUrl, int useHttps)	
		{
			UriBuilder redirectUrl = new UriBuilder(RequestUrl);
			if( confService.get("use_https").value=="2" ||
			   (confService.get("use_https").value=="1" && useHttps==1) || 
		  	   (confService.get("use_https").value=="1" && useHttps==2 && "https".Equals(redirectUrl.Scheme))
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
		
		public static void SaveFileFrom64(string toDecode, string filePath)
		{
			//this is a simple white background image
			//string myfilename= string.Format(@"{0}", Guid.NewGuid());
			
			byte[] bytess = Convert.FromBase64String(toDecode);
			using (FileStream imageFile = new FileStream(filePath, FileMode.Create))
			{
				imageFile.Write(bytess, 0, bytess.Length);
				imageFile.Flush();
			}
		}	
		
		public static Stream StringToStream(string s)
		{
			MemoryStream stream = new MemoryStream();
			StreamWriter writer = new StreamWriter(stream);
			writer.Write(s);
			writer.Flush();
			stream.Position = 0;
			return stream;
		}
		
		public static Stream ByteToStream(byte[] bytess)
		{
			MemoryStream stream = new MemoryStream();
			StreamWriter writer = new StreamWriter(stream);
			writer.Write(bytess);
			writer.Flush();
			stream.Position = 0;
			return stream;
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
			
			return !String.IsNullOrEmpty(ext) && acceptedExtension.Contains(ext.ToLower());
		}
		
		public static void directoryCopy(string sourceDirName, string destDirName, bool copySubDirs, bool errorIfDirNotExists)
		{                                
			if(Directory.Exists(sourceDirName)){
				DirectoryInfo dir = new DirectoryInfo(sourceDirName);
				DirectoryInfo[] dirs = dir.GetDirectories();
		
				if (!Directory.Exists(destDirName))
				{
					Directory.CreateDirectory(destDirName);
				}
		
				FileInfo[] files = dir.GetFiles();
				foreach (FileInfo file in files)
				{
					string temppath = Path.Combine(destDirName, file.Name);
					file.CopyTo(temppath, false);
				}
		
				if (copySubDirs)
				{
					foreach (DirectoryInfo subdir in dirs)
					{
						string temppath = Path.Combine(destDirName, subdir.Name);
						directoryCopy(subdir.FullName, temppath, copySubDirs, errorIfDirNotExists);
					}
				}
			}else{
				if(errorIfDirNotExists){
					throw new DirectoryNotFoundException("Source directory does not exist or could not be found: "+ sourceDirName);
				}				
			}
		}
		
		public static void SaveStreamToFile(Stream stream, string filename)
		{  
		   using(Stream destination = File.Create(filename))
			  Write(stream, destination);
		}		
		
		
		//Typically I implement this Write method as a Stream extension method. 
		//The framework handles buffering.		
		static void Write(Stream from, Stream to)
		{
		   for(int a = from.ReadByte(); a != -1; a = from.ReadByte())
			  to.WriteByte( (byte) a );
		}

		
		
		public static bool deleteDirectory(string directory)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				if(Directory.Exists(directory)) 
				{
					Directory.Delete(directory, true);
					deleted = true;
				}
			}catch(Exception ex)
			{
				deleted = false;
			}

			return deleted;			
		}
		
		public static bool deleteFile(string filename)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				//System.Web.HttpContext.Current.Response.Write("filename: " + filename+"<br><br><br>");
				if(File.Exists(filename)) 
				{
					File.Delete(filename);
					deleted = true;
				}
			}catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("find - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				deleted = false;
			}			

			return deleted;			
		}
	}
}