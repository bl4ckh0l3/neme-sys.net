using System;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using com.nemesys.model;
using System.Web.Caching;
using System.Xml;
using System.IO;
//using System.Threading;
//using System.Net;

namespace com.nemesys.services
{
	public class RepositoryService
	{
		private const string REPOSITORY_PATH = "~/app_data/conf/repository-mapping.xml";
		private const string CACHE_PREFIX = "RepositoryMapping:";

		public IList<RepositoryMapping> getAllRepositoryMappings()
		{
			List<RepositoryMapping> results = new List<RepositoryMapping>();

			XmlDocument xml = new XmlDocument();
			xml.Load(new StringReader(getXmlContent()));	
			XmlNode xnList = xml.FirstChild;
			if (xnList.HasChildNodes)
			{
				for (int i=0; i<xnList.ChildNodes.Count; i++)
				{
					XmlNode inner = xnList.ChildNodes[i];
					if (inner.HasChildNodes)
					{
					
						string keyword = inner.Name;
						string value = inner["value"].InnerText;
						string description = inner["description"].InnerText;
						string singleton = null;
						string lazy = null;
						if(inner.Attributes.GetNamedItem("singleton")!=null){
							singleton = inner.Attributes.GetNamedItem("singleton").Value;
						}
						if(inner.Attributes.GetNamedItem("lazy")!=null){
							lazy = inner.Attributes.GetNamedItem("lazy").Value;
						}
						
						results.Add(new RepositoryMapping(keyword,value,description,singleton,lazy));
					}
				}
			}
			results.Sort();
			return results;
		}	

		public RepositoryMapping get(string key)
		{
			RepositoryMapping result = null;

			if((RepositoryMapping)HttpContext.Current.Cache.Get(CACHE_PREFIX+key) != null)
			{
				result = (RepositoryMapping)HttpContext.Current.Cache.Get(CACHE_PREFIX+key);
				//System.Web.HttpContext.Current.Response.Write("recupero da cache: "+result.ToString()+"<br>");
				return result;
			}

			try
			{
				XmlDocument xml = new XmlDocument();
				xml.Load(new StringReader(getXmlContent()));	
				XmlNode inner = xml.SelectSingleNode("/repository/"+key);
				
				if (inner.HasChildNodes)
				{
					string keyword = inner.Name;
					string value = inner["value"].InnerText;
					string description = inner["description"].InnerText;
					string singleton = null;
					string lazy = null;
					if(inner.Attributes.GetNamedItem("singleton")!=null){
						singleton = inner.Attributes.GetNamedItem("singleton").Value;
					}
					if(inner.Attributes.GetNamedItem("lazy")!=null){
						lazy = inner.Attributes.GetNamedItem("lazy").Value;
					}
					
					result = new RepositoryMapping(keyword,value,description,singleton,lazy);
				}	
	
				//System.Web.HttpContext.Current.Response.Write("recupero da xml: "+result.ToString()+"<br>");
	
				HttpContext.Current.Cache.Insert(CACHE_PREFIX+result.key, result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			}
			catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				// DO NOTHING: RETURN NULL
			}
			
			return result;		
		}

		public void insert(RepositoryMapping repositoryMapping)
		{
			XmlDocument xml = new XmlDocument();
			xml.Load(new StringReader(getXmlContent()));

			XmlElement elem = xml.CreateElement(repositoryMapping.key);
			
			XmlElement value = xml.CreateElement("value");
			value.InnerText=repositoryMapping.value;				
			XmlElement description = xml.CreateElement("description");
			description.InnerText=repositoryMapping.description;	
			//Add the nodes to the elem.
			elem.AppendChild(value);
			elem.AppendChild(description);

			if(!String.IsNullOrEmpty(repositoryMapping.singleton)){
				XmlAttribute newAttr = xml.CreateAttribute("singleton");
				newAttr.Value = repositoryMapping.singleton;
				elem.Attributes.Append(newAttr);
			}

			if(!String.IsNullOrEmpty(repositoryMapping.lazy)){
				XmlAttribute newAttr = xml.CreateAttribute("lazy");
				newAttr.Value = repositoryMapping.lazy;
				elem.Attributes.Append(newAttr);
			}
			
			XmlNode node = xml.FirstChild;	
			node.AppendChild(elem);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(REPOSITORY_PATH));	
		}	

		public void update(RepositoryMapping repositoryMapping)
		{
			XmlDocument xml = new XmlDocument();
			xml.Load(new StringReader(getXmlContent()));

			XmlElement elem = xml.CreateElement(repositoryMapping.key);			
			XmlElement value = xml.CreateElement("value");
			value.InnerText=repositoryMapping.value;				
			XmlElement description = xml.CreateElement("description");
			description.InnerText=repositoryMapping.description;				
			//Add the nodes to the elem.
			elem.AppendChild(value);
			elem.AppendChild(description);

			if(!String.IsNullOrEmpty(repositoryMapping.singleton)){
				XmlAttribute newAttr = xml.CreateAttribute("singleton");
				newAttr.Value = repositoryMapping.singleton;
				elem.Attributes.Append(newAttr);
			}

			if(!String.IsNullOrEmpty(repositoryMapping.lazy)){
				XmlAttribute newAttr = xml.CreateAttribute("lazy");
				newAttr.Value = repositoryMapping.lazy;
				elem.Attributes.Append(newAttr);
			}
			
			XmlNode node = xml.SelectSingleNode("/repository/"+repositoryMapping.key);
			XmlNode root = xml.FirstChild;	
			root.ReplaceChild(elem, node);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(REPOSITORY_PATH));	

			// cache cleaning
			if((RepositoryMapping)HttpContext.Current.Cache.Get(CACHE_PREFIX+repositoryMapping.key) != null)
				HttpContext.Current.Cache.Remove(CACHE_PREFIX+repositoryMapping.key);
		}	

		public void updateAll(IList<RepositoryMapping> repositoryMappings)
		{
			//System.Web.HttpContext.Current.Response.Write(config.toString()+"<br>");

			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));
			XmlNode root = xml.FirstChild;	

			foreach (RepositoryMapping rm in repositoryMappings)
			{
				XmlElement elem = xml.CreateElement(rm.key);			
				XmlElement value = xml.CreateElement("value");
				value.InnerText=rm.value;				
				XmlElement description = xml.CreateElement("description");
				description.InnerText=rm.description;				
				//Add the nodes to the elem.
				elem.AppendChild(value);
				elem.AppendChild(description);

				if(!String.IsNullOrEmpty(rm.singleton)){
					XmlAttribute newAttr = xml.CreateAttribute("singleton");
					newAttr.Value = rm.singleton;
					elem.Attributes.Append(newAttr);
				}
	
				if(!String.IsNullOrEmpty(rm.lazy)){
					XmlAttribute newAttr = xml.CreateAttribute("lazy");
					newAttr.Value = rm.lazy;
					elem.Attributes.Append(newAttr);
				}
				
				XmlNode node = xml.SelectSingleNode("/repository/"+rm.key);
				root.ReplaceChild(elem, node);
	
				// cache cleaning
				if((RepositoryMapping)HttpContext.Current.Cache.Get(CACHE_PREFIX+rm.key) != null)
					HttpContext.Current.Cache.Remove(CACHE_PREFIX+rm.key);
			}
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(REPOSITORY_PATH));	
		}

		public void delete(string key)
		{
			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));
			XmlNode root = xml.FirstChild;	
			XmlNode node = xml.SelectSingleNode("/repository/"+key);
			root.RemoveChild(node);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(REPOSITORY_PATH));

			// cache cleaning
			if((RepositoryMapping)HttpContext.Current.Cache.Get(CACHE_PREFIX+key) != null)
				HttpContext.Current.Cache.Remove(CACHE_PREFIX+key);
		}

		private string getXmlContent()
		{
			string content = "";
			//Get a StreamReader class that can be used to read the file
			StreamReader reader = File.OpenText(System.Web.HttpContext.Current.Server.MapPath(REPOSITORY_PATH));
			//Now, read the entire file into a string
			content = reader.ReadToEnd();
			reader.Close();
			return content;			
		}
	}
}