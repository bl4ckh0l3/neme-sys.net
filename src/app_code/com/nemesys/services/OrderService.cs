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
using System.Net.Mail;
using System.Net.Mime;
using com.nemesys.model;
using com.nemesys.database.repository;

namespace com.nemesys.services
{
	public class OrderService
	{	
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
		
		public static IDictionary<int,string> getOrderStatus()
		{
			IDictionary<int,string> status = new Dictionary<int,string>();
			status.Add(1,"added");
			status.Add(2,"execution");
			status.Add(3,"processed");
			status.Add(4,"rejected");
			
			return status;
		}
	}
}