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
	public class TemplateService
	{
		protected static ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		protected static ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		protected static ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		protected static ConfigurationService confservice = new ConfigurationService();
		protected static string baseFileExt = ".aspx";
		
		public static void generateTree(string path, IDictionary<string, string> elementsMap)
		{
			string vDir = path;
			string root = System.Web.HttpContext.Current.Server.MapPath(vDir);
			System.IO.DirectoryInfo dirInfo = new DirectoryInfo(root);
			System.IO.DirectoryInfo[] dirInfos = dirInfo.GetDirectories("*.*");
			System.IO.FileInfo[] fileNames = dirInfo.GetFiles("*.*");
			
			foreach (System.IO.DirectoryInfo d in dirInfos)
			{
				string fpath = vDir + d.Name + "/";
				generateTree(fpath, elementsMap);
			}

			foreach (System.IO.FileInfo fi in fileNames)
			{
				elementsMap.Add(fi.Name, vDir);
			}
		}
		
		public static bool deleteTemplateDirectory(string directory)
		{
			bool deleted = false;
			//cancello la directory fisica del template
			try{
				string tpath = HttpContext.Current.Server.MapPath("~/public/templates/"+directory);
				if(Directory.Exists(tpath)) 
				{
					Directory.Delete(tpath, true);
					deleted = true;
				}
			}catch(Exception ex)
			{
				deleted = false;
			}

			return deleted;			
		}
		
		public static string resolveVirtualPath(string virtualPath, string defLangCode, out string newLangCode)
		{
			string realPath = "";
			string basePath = "/public/templates/";
			newLangCode = "";
			//System.Web.HttpContext.Current.Response.Write("<b>start virtualPath: </b>"+virtualPath+"<br>");
			try
			{
				//System.Web.HttpContext.Current.Response.Write("<b>1- modify virtualPath: </b>"+virtualPath+"<br>");
				
				//if(Convert.ToBoolean(Convert.ToInt32(confservice.get("url_with_langcode_prefix").value))){
					try
					{			
						IList<Language> languages = langrep.findActive(true);	
						if(languages != null)
						{				
							foreach(Language l in languages)
							{
								if(virtualPath.Contains("/"+l.label+"/"))
								{
									virtualPath=virtualPath.Substring(virtualPath.IndexOf("/"+l.label+"/")+l.label.Length+1);
									newLangCode = l.label;
									break;
								}
								else if(virtualPath.Contains("/"+l.label.ToLower()+"/"))
								{
									virtualPath=virtualPath.Substring(virtualPath.IndexOf("/"+l.label.ToLower()+"/")+l.label.Length+1);
									newLangCode = l.label;
									break;
								}	
							}						
						}
						
						if(String.IsNullOrEmpty(newLangCode) && !String.IsNullOrEmpty(defLangCode)){
							newLangCode = defLangCode;
						}
					}catch (Exception ex){}					
				//}
				//System.Web.HttpContext.Current.Response.Write("<b>2- modify virtualPath: </b>"+virtualPath+"<br>");
				
				if(virtualPath.StartsWith("/")){virtualPath=virtualPath.Substring(1);}
				//System.Web.HttpContext.Current.Response.Write("<b>3- modify virtualPath: </b>"+virtualPath+"<br>");
				if(virtualPath.EndsWith(baseFileExt)){virtualPath=virtualPath.Substring(0,virtualPath.LastIndexOf(baseFileExt));}
				//System.Web.HttpContext.Current.Response.Write("TemplateService.resolveVirtualPath - <b>virtualPath: </b>"+virtualPath+"<br>");
				
				TemplateVO tvo = temprep.getByUrlRewriteCached(virtualPath, newLangCode, true);
				//System.Web.HttpContext.Current.Response.Write("TemplateService.resolveVirtualPath - <b>tvo: </b>"+(tvo!=null)+"<br>");
					
				if(tvo != null && tvo.templatePage != null)
				{
					//System.Web.HttpContext.Current.Response.Write("<b>tvo: </b>"+tvo.ToString()+"<br>");
					
					if(!String.IsNullOrEmpty(tvo.langCode))
					{
						newLangCode = tvo.langCode;
					}
				
					//System.Web.HttpContext.Current.Response.Write("<b>templ: </b>"+templ.ToString()+"<br>");
					StringBuilder builder = new StringBuilder(basePath).Append(tvo.templatePage.filePath).Append(tvo.templatePage.fileName);
					realPath = builder.ToString();
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("TemplateSerivce.resolveVirtualPath -  An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				realPath="";
			}
			//System.Web.HttpContext.Current.Response.Write("<b>5- realPath: </b>"+realPath+"<br>");
			
			return realPath;
		}
		
		public static string resolveDefaultPath(string scheme, string currentLangCode, string categoryid, string hierarchy, out string newLangCode, out string ocategoryid, out string ohierarchy)
		{
			string realPath = "";
			ocategoryid = "";
			ohierarchy = "";
			newLangCode = "";
			StringBuilder baseUrl = new StringBuilder();
			
			/*
			System.Web.HttpContext.Current.Response.Write("<b>TemplateService.resolveDefaultPath:</b><br>");
			System.Web.HttpContext.Current.Response.Write("<b>0- scheme:</b>"+scheme+"<br>");
			System.Web.HttpContext.Current.Response.Write("<b>1- currentLangCode:</b>"+currentLangCode+"<br>");
			System.Web.HttpContext.Current.Response.Write("<b>1- categoryid:</b>"+categoryid+"<br>");
			System.Web.HttpContext.Current.Response.Write("<b>1- hierarchy:</b>"+hierarchy+"<br>");
			*/
			
			try
			{				
				StringBuilder builder = new StringBuilder(scheme).Append("://");
				
				Category category = null;
				if (!String.IsNullOrEmpty(categoryid)) {
					category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
				}else if (!String.IsNullOrEmpty(hierarchy)){
					category = catrep.getByHierarchyCached(hierarchy, true);					
				}else{
					category = catrep.findFirstCategoryCached(true);					
				}
				
				if(!CategoryService.isCategoryNull(category)){							
					// recupero l'id template corretto in base alla lingua
					int templateId = category.idTemplate;
					Template template = null;
					if(templateId>0){
						template = temprep.getByIdCached(templateId, true);
					}
					if(!TemplateService.isTemplateNull(template))
					{
						//Response.Write("template:"+template.ToString()+"<br>");
						bool langHasSubDomainActive = false;
						string langUrlSubdomain = "";
						Language language = langrep.getByLabel(currentLangCode, true);									
						if(!LanguageService.isLanguageNull(language))
						{	
							langHasSubDomainActive = language.subdomainActive;
							langUrlSubdomain = language.urlSubdomain;
						}	

						newLangCode = currentLangCode;
						
						//System.Web.HttpContext.Current.Response.Write("<b>category!=null:</b>"+(category!=null)+"<br>");
						//System.Web.HttpContext.Current.Response.Write("<b>template!=null:</b>"+(template!=null)+"<br>");
											
						foreach(TemplatePage tp in template.pages){
							//System.Web.HttpContext.Current.Response.Write("<b>tp:</b>"+tp.ToString()+"<br>");
							if(1==tp.priority){	
								//System.Web.HttpContext.Current.Response.Write("<b>builder.ToString():</b>"+builder.ToString()+"<br>");	
								//System.Web.HttpContext.Current.Response.Write("<b>currentLangCode:</b>"+currentLangCode+"<br>");	
								//System.Web.HttpContext.Current.Response.Write("<b>langHasSubDomainActive:</b>"+langHasSubDomainActive+"<br>");	
								//System.Web.HttpContext.Current.Response.Write("<b>langUrlSubdomain:</b>"+langUrlSubdomain+"<br>");		
								//System.Web.HttpContext.Current.Response.Write("<b>baseUrl:</b>"+baseUrl.ToString()+"<br>");	

								ohierarchy = category.hierarchy;
								ocategoryid = category.id.ToString();	
								string resolvedURL = MenuService.resolvePageHrefUrl(builder.ToString(), 1, currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
								//System.Web.HttpContext.Current.Response.Write("<b>resolvedURL:</b>"+resolvedURL+"<br>");
								if(resolvedURL!=null){
									baseUrl.Append(resolvedURL);
									UriBuilder urlBuilder = new UriBuilder(baseUrl.ToString());
									realPath = urlBuilder.Path;
								}
								break;
							}
						}
					}
				}
			}
			catch (Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			}
			
			return realPath;
		}
		
		public static Template resolveTemplateByVirtualPath(string virtualPath, string defLangCode, out string newLangCode)
		{
			Template result = null;
			newLangCode = "";
			try
			{
				virtualPath = virtualPath.Replace("/public/templates/","");
				
				//if(Convert.ToBoolean(Convert.ToInt32(confservice.get("url_with_langcode_prefix").value))){
					try
					{			
						IList<Language> languages = langrep.findActive(true);	
						if(languages != null)
						{				
							foreach(Language l in languages)
							{
								if(virtualPath.Contains("/"+l.label+"/"))
								{
									virtualPath=virtualPath.Substring(virtualPath.IndexOf("/"+l.label+"/")+l.label.Length+1);
									newLangCode = l.label;
									break;
								}
								else if(virtualPath.Contains("/"+l.label.ToLower()+"/"))
								{
									virtualPath=virtualPath.Substring(virtualPath.IndexOf("/"+l.label.ToLower()+"/")+l.label.Length+1);
									newLangCode = l.label;
									break;
								}	
							}						
						}
						
						if(String.IsNullOrEmpty(newLangCode) && !String.IsNullOrEmpty(defLangCode)){
							newLangCode = defLangCode;
						}
					}catch (Exception ex){
						//System.Web.HttpContext.Current.Response.Write("TemplateService.resolveTemplateByVirtualPath (language for) - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
					}					
				//}
				
				//System.Web.HttpContext.Current.Response.Write("<b>TemplateService: start virtualPath: </b>"+virtualPath+"<br>");
				
				if(virtualPath.StartsWith("/")){virtualPath=virtualPath.Substring(1);}
				//System.Web.HttpContext.Current.Response.Write("<b>start virtualPath: </b>"+virtualPath+"<br>");
				if(virtualPath.EndsWith(baseFileExt)){virtualPath=virtualPath.Substring(0,virtualPath.LastIndexOf(baseFileExt));}
				//System.Web.HttpContext.Current.Response.Write("<b>TemplateService: modify virtualPath: </b>"+virtualPath+"<br>");
				
				TemplateVO tvo = temprep.getByUrlRewriteCached(virtualPath, newLangCode, true);
					
				if(tvo != null && tvo.templatePage != null)
				{
					if(!String.IsNullOrEmpty(tvo.langCode))
					{
						newLangCode = tvo.langCode;
					}
					result = temprep.getByIdCached(tvo.templatePage.templateId, true);
				}else{
					//System.Web.HttpContext.Current.Response.Write("<b>Path.GetDirectoryName(virtualPath):</b>"+Path.GetDirectoryName(virtualPath)+";<br>");
					result = temprep.getByDirectoryCached(Path.GetDirectoryName(virtualPath), true);
					//System.Web.HttpContext.Current.Response.Write("<b>result: </b>"+result.ToString()+"<br>");
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("TemplateService.resolveTemplateByVirtualPath - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				result = null;
			}
			
			return result;
		}
		
		public static bool isTemplateNull(Template template)
		{
			return (template == null || template.id==-1);	
		}
		
		public static int getMaxPriority(IList<TemplatePage> pages)
		{
			int maxPriority = -1;
			foreach(TemplatePage tp in pages){
				if(tp.priority>0){
					if(tp.priority>maxPriority){maxPriority=tp.priority;}
				}
			}

			return maxPriority;
		}
	}
}