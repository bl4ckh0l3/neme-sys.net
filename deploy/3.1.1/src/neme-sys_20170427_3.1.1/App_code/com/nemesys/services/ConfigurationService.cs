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
	public class ConfigurationService
	{
		private const string CONFIG_PATH = "~/app_data/conf/nemesys-config.xml";
		//private static Cache cache = new Cache(); 

		public IList<Config> getAllConfigurations()
		{
			List<Config> results = new List<Config>();

			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));
			
			//XmlNode node = xml.SelectSingleNode("/config/server_name");
			//System.Web.HttpContext.Current.Response.Write(node.Attributes.GetNamedItem("attr_server_name").Value+"<br>");
			
			//XmlNodeList  xnList = xml.SelectNodes("//config/");	
			XmlNode xnList = xml.FirstChild;
			if (xnList.HasChildNodes)
			{
				//System.Web.HttpContext.Current.Response.Write("xnList.HasChildNodes<br>");	

				for (int i=0; i<xnList.ChildNodes.Count; i++)
				{
					//System.Web.HttpContext.Current.Response.Write("xnList.ChildNodes[i].Name: "+xnList.ChildNodes[i].Name+"<br>");	
					XmlNode inner = xnList.ChildNodes[i];
					if (inner.HasChildNodes)
					{
						string keyword = inner.Name;
						string value = inner["value"].InnerText;
						string description = inner["description"].InnerText;
						string alert = inner["alert"].InnerText;
						string type = inner["type"].InnerText;
						string type_values = inner["type_values"].InnerText;
						bool is_base = Convert.ToBoolean(Convert.ToInt32(inner["is_base"].InnerText));
						/*System.Web.HttpContext.Current.Response.Write("keyword: "+keyword+
						" - value: "+value+
						" - description: "+description+
						" - alert: "+alert+
						" - type: "+type+
						" - type_values: "+type_values+
						"<br>");*/
						
						results.Add(new Config(keyword,value,description,alert,type,type_values,is_base));
					}
				}
			}
			results.Sort();
			return results;
		}	

		public Config get(string key)
		{
			Config result = new Config();

			if((Config)HttpContext.Current.Cache.Get(key) != null)
			{
				result = (Config)HttpContext.Current.Cache.Get(key);
				//System.Web.HttpContext.Current.Response.Write("recupero da cache: "+result.toString()+"<br>");
				return result;
			}

			XmlDocument xml = new XmlDocument();
			xml.Load(new StringReader(getXmlContent()));	
			XmlNode inner = xml.SelectSingleNode("/config/"+key);
			
			if (inner.HasChildNodes)
			{
				string keyword = inner.Name;
				string value = inner["value"].InnerText;
				string description = inner["description"].InnerText;
				string alert = inner["alert"].InnerText;
				string type = inner["type"].InnerText;
				string type_values = inner["type_values"].InnerText;
				bool is_base = Convert.ToBoolean(Convert.ToInt32(inner["is_base"].InnerText));
				/*System.Web.HttpContext.Current.Response.Write("keyword: "+keyword+
				" - value: "+value+
				" - description: "+description+
				" - alert: "+alert+
				" - type: "+type+
				" - type_values: "+type_values+
				"<br>");*/
				
				result = new Config(keyword,value,description,alert,type,type_values,is_base);
			}	

			//System.Web.HttpContext.Current.Response.Write("recupero da xml: "+result.toString()+"<br>");

			HttpContext.Current.Cache.Insert(result.key, result, null, DateTime.Now.AddHours(24), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, null);
			return result;		
		}

		public void insert(Config config)
		{
			XmlDocument xml = new XmlDocument();
			xml.Load(new StringReader(getXmlContent()));

			XmlElement elem = xml.CreateElement(config.key);
			
			XmlElement value = xml.CreateElement("value");
			value.InnerText=config.value;				
			XmlElement description = xml.CreateElement("description");
			description.InnerText=config.description;				
			XmlElement alert = xml.CreateElement("alert");
			alert.InnerText=config.alert;			
			XmlElement type = xml.CreateElement("type");
			type.InnerText=config.type;		
			XmlElement type_values = xml.CreateElement("type_values");
			type_values.InnerText=config.type_values;
			XmlElement is_base = xml.CreateElement("is_base");
			is_base.InnerText=Convert.ToInt32(config.is_base).ToString();
			//Add the nodes to the elem.
			elem.AppendChild(value);
			elem.AppendChild(description);
			elem.AppendChild(alert);
			elem.AppendChild(type);
			elem.AppendChild(type_values);
			elem.AppendChild(is_base);
			
			XmlNode node = xml.FirstChild;	
			node.AppendChild(elem);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(CONFIG_PATH));	
		}	

		public void update(Config config)
		{
			//System.Web.HttpContext.Current.Response.Write(config.toString()+"<br>");

			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));

			XmlElement elem = xml.CreateElement(config.key);			
			XmlElement value = xml.CreateElement("value");
			value.InnerText=config.value;				
			XmlElement description = xml.CreateElement("description");
			description.InnerText=config.description;				
			XmlElement alert = xml.CreateElement("alert");
			alert.InnerText=config.alert;			
			XmlElement type = xml.CreateElement("type");
			type.InnerText=config.type;		
			XmlElement type_values = xml.CreateElement("type_values");
			type_values.InnerText=config.type_values;
			XmlElement is_base = xml.CreateElement("is_base");
			is_base.InnerText=Convert.ToInt32(config.is_base).ToString();
			//Add the nodes to the elem.
			elem.AppendChild(value);
			elem.AppendChild(description);
			elem.AppendChild(alert);
			elem.AppendChild(type);
			elem.AppendChild(type_values);
			elem.AppendChild(is_base);
			
			XmlNode node = xml.SelectSingleNode("/config/"+config.key);
			XmlNode root = xml.FirstChild;	
			root.ReplaceChild(elem, node);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(CONFIG_PATH));	

			// cache cleaning
			if((Config)HttpContext.Current.Cache.Get(config.key) != null)
				HttpContext.Current.Cache.Remove(config.key);
		}	

		public void updateAll(IList<Config> configs)
		{
			//System.Web.HttpContext.Current.Response.Write(config.toString()+"<br>");

			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));
			XmlNode root = xml.FirstChild;	

			foreach (Config config in configs)
			{
				XmlElement elem = xml.CreateElement(config.key);			
				XmlElement value = xml.CreateElement("value");
				value.InnerText=config.value;				
				XmlElement description = xml.CreateElement("description");
				description.InnerText=config.description;				
				XmlElement alert = xml.CreateElement("alert");
				alert.InnerText=config.alert;			
				XmlElement type = xml.CreateElement("type");
				type.InnerText=config.type;		
				XmlElement type_values = xml.CreateElement("type_values");
				type_values.InnerText=Convert.ToString(config.type_values);
				XmlElement is_base = xml.CreateElement("is_base");
				is_base.InnerText=Convert.ToInt32(config.is_base).ToString();
				//Add the nodes to the elem.
				elem.AppendChild(value);
				elem.AppendChild(description);
				elem.AppendChild(alert);
				elem.AppendChild(type);
				elem.AppendChild(type_values);
				elem.AppendChild(is_base);
				
				XmlNode node = xml.SelectSingleNode("/config/"+config.key);
				root.ReplaceChild(elem, node);
	
				// cache cleaning
				if((Config)HttpContext.Current.Cache.Get(config.key) != null)
					HttpContext.Current.Cache.Remove(config.key);
			}
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(CONFIG_PATH));	
		}

		public void delete(string key)
		{
			XmlDocument xml = new XmlDocument();
			//xml.LoadXml(myXmlString); // suppose that myXmlString contains "<Names>...</Names>"
			xml.Load(new StringReader(getXmlContent()));
			XmlNode root = xml.FirstChild;	
			XmlNode node = xml.SelectSingleNode("/config/"+key);
			root.RemoveChild(node);
			xml.Save(System.Web.HttpContext.Current.Server.MapPath(CONFIG_PATH));

			// cache cleaning
			if((Config)HttpContext.Current.Cache.Get(key) != null)
				HttpContext.Current.Cache.Remove(key);
		}

		private string getXmlContent()
		{
			string content = "";
			//Get a StreamReader class that can be used to read the file
			StreamReader reader = File.OpenText(System.Web.HttpContext.Current.Server.MapPath(CONFIG_PATH));
			//Now, read the entire file into a string
			content = reader.ReadToEnd();
			reader.Close();
			return content;			
		}
	}
}