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
	public class MenuService
	{
		protected static ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
		protected static ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
		protected static ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
		protected static ConfigurationService confservice = new ConfigurationService();
		protected static string baseFileExt = ".aspx";
		
		public static IList<Category> getMenu(int numMenu, string hierarchyFrom, string hierarchyTo, int level, Nullable<bool> boolDeep)
		{
			IList<Category> result = new List<Category>();	
			try
			{
				IList<Category> categories = catrep.findCached(numMenu, true, true);	
				//System.Web.HttpContext.Current.Response.Write("<b>categories!=null:</b>"+(categories!=null)+"<br>");
				foreach(Category category in categories)
				{
					//System.Web.HttpContext.Current.Response.Write("<b>category:</b>"+category.ToString()+"<br>");
					
					int clevel = category.getLevel();
					double hierarchyDouble = category.hierarchy2double();					
					
					//System.Web.HttpContext.Current.Response.Write("<b>hierarchyDouble:</b>"+hierarchyDouble+"<br><b>hierarchyFrom:</b>"+hierarchyFrom+"<br><br><b>hierarchyTo:</b>"+hierarchyTo+"<br>");
					
					if(boolDeep != null) {
						if(!Convert.ToBoolean(boolDeep)) {					
							if (clevel == level) {
								if(addedByHierarchy(hierarchyDouble, hierarchyFrom, hierarchyTo)){
									result.Add(category);
								}
							}						
						}else{
							if (clevel >= level) {
								if(addedByHierarchy(hierarchyDouble, hierarchyFrom, hierarchyTo)){
									result.Add(category);
								}
							}
						}
					}else{
						if(addedByHierarchy(hierarchyDouble, hierarchyFrom, hierarchyTo)){
							result.Add(category);
						}					
					}
				}
			}catch(Exception ex)
			{
				//System.Web.HttpContext.Current.Response.Write("getMenu - An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				result = new List<Category>();
			}
			
			return result;
		}
		
		public static IList<Category> getMenuTips(string hierarchy)
		{
			IList<Category> result = new List<Category>();	
			
			string[] p = null;
			if(!String.IsNullOrEmpty(hierarchy)){
				p = hierarchy.Split('.');
			}
			if(p!=null){
				string strTmp = "";
				foreach (string item in p){
					strTmp += item;
					Category tmp = catrep.getByHierarchyCached(strTmp, true);
					if(!CategoryService.isCategoryNull(tmp)){
						result.Add(tmp);
					}
					strTmp += ".";
				}
			}		
			
			return result;
		}
		
		public static string resolvePageHrefUrl(string basePath, int modelPageNum, string langCode, bool langSubDomainActive, string langUrlSubdomain, Category category, Template template, bool returnUrlRewrite)
		{
			string resolveHrefUrl = "#";
			string tmpBaseUrl = basePath;
			//System.Web.HttpContext.Current.Response.Write("<b>0- basePath:</b>"+basePath+"<br>");
			//System.Web.HttpContext.Current.Response.Write("<b>1- tmpBaseUrl:</b>"+tmpBaseUrl+"<br>");

			//'*** recupero la dir language o il sottodominio per lingua
			string langcodeDir = "/" + langCode.ToLower() + "/";
			if(langSubDomainActive) { langcodeDir = "";}
			
			//'*** verifico esistenza del sottodominio per categoria e compongo la base_url
			string catSubDomUrl = category.subDomainUrl.Replace(" ","");

			if(!String.IsNullOrEmpty(catSubDomUrl)){
				tmpBaseUrl += catSubDomUrl;
			}else{
				if (langSubDomainActive) {
					tmpBaseUrl += langUrlSubdomain;
				}else{
					tmpBaseUrl += confservice.get("server_name").value;
				}
			}
			

			string baseRealPath = "/public/templates/";
			//System.Web.HttpContext.Current.Response.Write("<b>start tmpBaseUrl:</b>"+tmpBaseUrl+"<br>");
			string fileExt = "";
			if(Convert.ToBoolean(Convert.ToInt32(confservice.get("url_rewrite_file_ext").value))){
				fileExt = baseFileExt;
			}
			
			try
			{
				if(template.pages != null)
				{				
					foreach(TemplatePage tp in template.pages)
					{
						if(tp.priority==modelPageNum){
							if(!String.IsNullOrEmpty(tp.urlRewrite) && returnUrlRewrite){								
								StringBuilder builder = new StringBuilder(tmpBaseUrl);
								//System.Web.HttpContext.Current.Response.Write("<b>3- tmpBaseUrl:</b>"+tmpBaseUrl+"<br>");
								if(Convert.ToBoolean(Convert.ToInt32(confservice.get("url_with_langcode_prefix").value))){
									builder.Append(langcodeDir);	
								}else{								
									builder.Append("/");
								}
								builder.Append(tp.urlRewrite);	
								builder.Append(fileExt);							
								resolveHrefUrl = builder.ToString();
								break;
							}else{
								StringBuilder builder = new StringBuilder(tmpBaseUrl).Append(baseRealPath).Append(tp.filePath).Append(tp.fileName);
								resolveHrefUrl = builder.ToString();	
								break;						
							}
						}
					}
				}
			}catch(Exception ex){
				//System.Web.HttpContext.Current.Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
				resolveHrefUrl = "#";
			}
			//System.Web.HttpContext.Current.Response.Write("<b>3- resolveHrefUrl:</b>"+resolveHrefUrl+"<br>");
			return resolveHrefUrl;			
		}

		public static void renderMenuVertical(IList<Category> menu, string currentLangCode, string hierarchy, string scheme, int clevel, int index, IDictionary<string, IList<string>> labels)
		{
			if(menu != null && menu.Count>0)
			{
				ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	
				int menuCounter = 0;
				foreach(Category cat in menu){					
					int level = cat.getLevel();
					int iGerDiff = level - clevel;			
					string menuCompleteCatLabelTrans = labels[cat.hierarchy][0];
					string menuCompleteCatDescTrans = labels[cat.hierarchy][1];
					StringBuilder imagePath = new StringBuilder();
					if(!String.IsNullOrEmpty(cat.filePath)){
						imagePath.Append("<img border=0 hspace=0 align=left vspace=0 style='padding-left:1px;padding-right:2px;' src='/public/upload/files/categories/").Append(cat.id).Append("/").Append(cat.filePath).Append("'>");
					}
					
					if(level > 1) {
						//StringBuilder test = new StringBuilder()
						//.Append("-hierarchy: ").Append(hierarchy)
						//.Append("<br>-cat: ").Append(cat.ToString())
						//.Append("<br>-clevel: ").Append(clevel)
						//.Append(" -level: ").Append(level)
						//.Append("<br>-iGerDiff: ").Append(iGerDiff)
						//.Append(" -iGerDiff <= 1: ").Append(iGerDiff <= 1)
						//.Append(" -iGerDiff<=0: ").Append(iGerDiff<=0);
					
						int iWidth = ((level-1) * 10)+5; 
						string strSubTmpGer=cat.hierarchy;
						
						if(level>clevel){
							if(cat.hierarchy.LastIndexOf('.')>0){
								//test.Append("<br>-cat.hierarchy.LastIndexOf('.'): ").Append(cat.hierarchy.LastIndexOf('.'));
								strSubTmpGer = cat.hierarchy.Substring(0,cat.hierarchy.LastIndexOf('.'));
								//test.Append("<br>-strSubTmpGer filtered: ").Append(strSubTmpGer);
							}
						}
						
						int numDeltaSubTmpGer = 0;
						if(strSubTmpGer.LastIndexOf('.')>0){
							numDeltaSubTmpGer = strSubTmpGer.LastIndexOf('.');
							//test.Append("<br>-numDeltaSubTmpGer: ").Append(numDeltaSubTmpGer);
						}
						string strSubTmpGerFiltered = strSubTmpGer.Substring(0,numDeltaSubTmpGer);
						
						//test.Append("<br>-strSubTmpGerFiltered filtered: ").Append(strSubTmpGerFiltered);						
						//Logger log = new Logger(test.ToString(),"system","debug",DateTime.Now);		
						//lrep.write(log);
					  
						if(iGerDiff <= 1) {
							if(iGerDiff<=0){
								strSubTmpGer = strSubTmpGerFiltered;
							}
							if (!String.IsNullOrEmpty(hierarchy) && hierarchy.Contains(strSubTmpGer)) {                
								//'*** Controllo se la categoria contiene news, altrimenti cerco la prima sottocategoria che contenga news
								//'*** e imposto la nuova gerarchia come parametro nel link
								string hrefGer = "";
								string newCatId = "";
								string strHref = resolveMenuItemUrl(cat, currentLangCode, scheme, 1, out hrefGer, out newCatId);
								
								//'*** checkSelectedCategory
								bool bolSelectedCat = false;
								string strSubSelCat = hierarchy;
								for (int a=1; a<Math.Abs(iGerDiff);a++)
								{
									strSubSelCat = strSubSelCat.Substring(strSubSelCat.LastIndexOf('.')-1);
								}
								
								if(cat.hierarchy==strSubSelCat) {
									bolSelectedCat = true;
								}
					
								//test = new StringBuilder().Append("<br>-strSubTmpGer: ").Append(strSubTmpGer)
								//.Append(" -strSubTmpGerFiltered: ").Append(strSubTmpGerFiltered)
								//.Append("<br>-strSubSelCat: ").Append(strSubSelCat)
								//.Append("-bolSelectedCat: ").Append(bolSelectedCat)
								//.Append("<br>-hierarchy.StartsWith(cat.hierarchy): ").Append(hierarchy.StartsWith(cat.hierarchy))								
								//.Append("<br><br>");
								//log = new Logger(test.ToString(),"system","debug",DateTime.Now);		
								//lrep.write(log);
																
								//Logger log = new Logger(new StringBuilder(" level> 1 - hierarchy:").Append(hierarchy).Append(" - cat.hierarchy:").Append(cat.hierarchy).Append(" - strSubSelCat:").Append(strSubSelCat).ToString(),"system","debug",DateTime.Now);
								//lrep.write(log);
								
								if(hierarchy.StartsWith(cat.hierarchy)){
									bolSelectedCat = true;
								}								
								
								string cssClass = "class=\"link-menu-sub\"";
								if(bolSelectedCat) { cssClass = "class=\"link-attivo-menu-sub\"";}
								System.Web.HttpContext.Current.Response.Write("<li><a href=\"javascript:openLinkMenu"+index+"('"+hrefGer+"','"+newCatId+"','"+strHref+"');\" style=\"padding-left:"+iWidth+"px;\" "+cssClass+">"+imagePath.ToString()+menuCompleteCatLabelTrans+"</a>");
								
								if(!String.IsNullOrEmpty(menuCompleteCatDescTrans)){
									System.Web.HttpContext.Current.Response.Write("<p style=\"padding-left:"+iWidth+5+"px;\">"+menuCompleteCatDescTrans+"</p>");
								}
								System.Web.HttpContext.Current.Response.Write("</li>");		
							}
						}
					}else{
						int iWidth = 0;
						string strSubTmpGer=hierarchy;
						int numDeltaTmpGer = 0;
						if(!String.IsNullOrEmpty(hierarchy)){
							if(hierarchy.LastIndexOf('.')>0){
								numDeltaTmpGer = hierarchy.Length-hierarchy.LastIndexOf('.');
							}
							strSubTmpGer = hierarchy.Substring(0,hierarchy.Length-numDeltaTmpGer);	
						}
						//'*** Controllo se la categoria contiene elementi, altrimenti cerco la prima sottocategoria che contenga elementi
						//'*** e imposto la nuova gerarchia come parametro nel link
						string hrefGer = "";
						string newCatId = "";
						string strHref = resolveMenuItemUrl(cat, currentLangCode, scheme, 1, out hrefGer, out newCatId);
			
						bool bolSelectedCat = false;
						if(cat.hierarchy==strSubTmpGer) {
							bolSelectedCat = true;
						}						

						//Logger log = new Logger(new StringBuilder(" level= 1 - hierarchy:").Append(hierarchy).Append(" - cat.hierarchy:").Append(cat.hierarchy).Append(" - strSubTmpGer:").Append(strSubTmpGer).ToString(),"system","debug",DateTime.Now);
						//lrep.write(log);
						
						/*if(hierarchy.StartsWith(cat.hierarchy, StringComparison.Ordinal)){
							bolSelectedCat = true;
						}*/

						string cssClass = "class=";
						if(bolSelectedCat) { cssClass = "class=\"link-attivo\"";}
						System.Web.HttpContext.Current.Response.Write("<li><a href=\"javascript:openLinkMenu"+index+"('"+hrefGer+"','"+newCatId+"','"+strHref+"');\" "+cssClass+">"+imagePath.ToString()+menuCompleteCatLabelTrans+"</a>");
						
						if(!String.IsNullOrEmpty(menuCompleteCatDescTrans)){
							System.Web.HttpContext.Current.Response.Write("<p style=\"padding-left:"+iWidth+5+"px;\">"+menuCompleteCatDescTrans+"</p>");
						}
						System.Web.HttpContext.Current.Response.Write("</li>");	
					}				
					menuCounter++;
				}
			}	
		}

		public static void renderMenuHorizontal(IList<Category> menu, string currentLangCode, string hierarchy, string scheme, int index, IDictionary<string, IList<string>> labels)
		{
			System.Web.HttpContext.Current.Response.Write("<ul>");			
			if(menu != null && menu.Count>0)
			{	
				int oldlevel = 1;
				int menuCounter = 0;
				foreach(Category cat in menu){		
					int level = cat.getLevel(); 
					string menuCompleteCatLabelTrans = labels[cat.hierarchy][0]; 					
					string strSubTmpGer=hierarchy;
					//System.Web.HttpContext.Current.Response.Write("strSubTmpGer.IndexOf('.'):"+strSubTmpGer.IndexOf('.')+"<br>");
					if(!String.IsNullOrEmpty(hierarchy) && hierarchy.IndexOf('.')>0){
						strSubTmpGer = hierarchy.Substring(0,hierarchy.IndexOf('.'));
					}
					//System.Web.HttpContext.Current.Response.Write("hierarchy:"+hierarchy+" - cat.hierarchy:"+cat.hierarchy+" - strSubTmpGer:"+strSubTmpGer+"<br>");
					
					//'*** Controllo se la categoria contiene elementi, altrimenti cerco la prima sottocategoria che contenga elementi
					//'*** e imposto la nuova gerarchia come parametro nel link
					string hrefGer = "";
					string newCatId = "";
					string strHref = resolveMenuItemUrl(cat, currentLangCode, scheme, 1, out hrefGer, out newCatId);
					StringBuilder imagePath = new StringBuilder();
					if(!String.IsNullOrEmpty(cat.filePath)){
						imagePath.Append("<img border=0 hspace=0 align=left vspace=0 style='padding-left:1px;padding-right:2px;' src='/public/upload/files/categories/").Append(cat.id).Append("/").Append(cat.filePath).Append("'>");
					}
					
					if(level<oldlevel) 
					{
						for(int counter=level; counter<oldlevel; counter++)
						{
							System.Web.HttpContext.Current.Response.Write("</ul></li>");
						}	
					}
					bool bolSelectedCat = false;
					if(level==1 && cat.hierarchy==strSubTmpGer) {
						bolSelectedCat = true;
					}				
					//if(level==1 && hierarchy.StartsWith(cat.hierarchy)){
						//bolSelectedCat = true;
					//}
					
					string cssClass = "class=";
					if(bolSelectedCat) { cssClass = "class=\"link-attivo\"";}
					System.Web.HttpContext.Current.Response.Write("<li><a href=\"javascript:openLinkMenu"+index+"('"+hrefGer+"','"+newCatId+"','"+strHref+"');\" "+cssClass+">"+imagePath.ToString()+menuCompleteCatLabelTrans+"</a>");

					bool bolHasSubCat = false;
					Category child = catrep.findFirstChildCategoryCached(cat, true);
					if(!CategoryService.isCategoryNull(child)){bolHasSubCat=true;}
					if(bolHasSubCat)
					{
						//System.Web.HttpContext.Current.Response.Write("child:"+child.ToString()+" -is visible:"+child.visible+"<br>");
						if(child.visible)
						{
							System.Web.HttpContext.Current.Response.Write("<ul>");
						}
						else
						{
							System.Web.HttpContext.Current.Response.Write("</li>");
						}
					}
					else
					{
						System.Web.HttpContext.Current.Response.Write("</li>");
					}      
					oldlevel = level;
					menuCounter++;		
					
					if(menuCounter==menu.Count)
					{
						if(level>1)
						{
							for (int counter=1; counter<level; counter++)
							{
								System.Web.HttpContext.Current.Response.Write("</ul></li>");
							}	
						}			
					}
				}
			}
			System.Web.HttpContext.Current.Response.Write("</ul><br style=\"clear: left\" />");
		}

		public static void renderMenuTips(IList<Category> menu, string currentLangCode, string scheme, int index, IDictionary<string, IList<string>> labels)
		{	
			if(menu != null && menu.Count>0)
			{	
				int menuCounter = 1;
				foreach(Category cat in menu){		
					int level = cat.getLevel(); 
					string menuCompleteCatLabelTrans = labels[cat.hierarchy][0]; 
					string hrefGer = "";
					string newCatId = "";
					string strHref = resolveMenuItemUrl(cat, currentLangCode, scheme, 1, out hrefGer, out newCatId);
					System.Web.HttpContext.Current.Response.Write("<li><a href=\"javascript:openLinkMenu"+index+"('"+hrefGer+"','"+newCatId+"','"+strHref+"');\">"+menuCompleteCatLabelTrans+"</a>");
					if(menuCounter<menu.Count && menu.Count>1) {
						System.Web.HttpContext.Current.Response.Write("--&gt;");
					}
					menuCounter++;
				}
			}
		}

		public static string resolveMenuItemUrl(Category cat, string currentLangCode, string basePath, int modelPageNum, out string hrefGer, out string newCatId)
		{
			string strHref = "#";
			hrefGer = "";
			newCatId = "";
			Category toCheck = checkEmptyCategory(cat, true);
			if (toCheck != null) {
				//System.Web.HttpContext.Current.Response.Write("resolveMenuItemUrl:toCheck: " + toCheck.ToString()+"<br><br>");
				hrefGer = toCheck.hierarchy;
				newCatId = toCheck.id.ToString();
				
				// recupero l'id template corretto in base alla lingua
				int templateId = toCheck.idTemplate;
				foreach(CategoryTemplate ct in toCheck.templates)
				{
					if(ct.langCode==currentLangCode)
					{
						templateId = ct.templateId;
						break;
					}	
				}
				Template template = null;
				if(templateId>0){
					template = templrep.getByIdCached(templateId, true);
				}
				if(!TemplateService.isTemplateNull(template))
				{
					bool langHasSubDomainActive = false;
					string langUrlSubdomain = "";
					Language language = langrep.getByLabel(currentLangCode, true);	
					if(!LanguageService.isLanguageNull(language))
					{	
						langHasSubDomainActive = language.subdomainActive;
						langUrlSubdomain = language.urlSubdomain;
					}
										
					strHref = resolvePageHrefUrl(basePath, modelPageNum, currentLangCode, langHasSubDomainActive, langUrlSubdomain, toCheck, template, true);
				}
			}else{
				strHref = "#";                  
			}
			
			return strHref;
		}
		
		private static bool addedByHierarchy(double hierarchyDouble, string hierarchyFrom, string hierarchyTo)
		{
			bool added = false;
			double hierarchyFromDouble = hierarchy2double(hierarchyFrom);
			double hierarchyToDouble = hierarchy2double(hierarchyTo);	
			//System.Web.HttpContext.Current.Response.Write("hierarchyDouble:" + hierarchyDouble+" -hierarchyFromDouble:"+hierarchyFromDouble+" -hierarchyToDouble:"+hierarchyToDouble+"<br>");		
			
			if(!String.IsNullOrEmpty(hierarchyFrom)){
				if(hierarchyDouble >= hierarchyFromDouble) {
					if(!String.IsNullOrEmpty(hierarchyTo)){
						if(hierarchyDouble <= hierarchyToDouble) {
							added = true;
						}
					}else{
						added = true;
					}
				}
			}else{
				if(!String.IsNullOrEmpty(hierarchyTo)){
					if(hierarchyDouble <= hierarchyToDouble) {
						added = true;
					}
				}else{
					added = true;
				}							
			}	
			//System.Web.HttpContext.Current.Response.Write("added: " + added+"<br><br>");				
			
			return added;
		}
		
		public static Category checkEmptyCategory(Category toCheck, bool deep)
		{
			if(toCheck.hasElements)
			{
				return toCheck;
			}

			//System.Web.HttpContext.Current.Response.Write("deep: " + deep+"<br><br>");				
			if(deep)
			{
				Category catChecked = catrep.findFirstSubCategoryWithElementsCached(toCheck, true); 
				//System.Web.HttpContext.Current.Response.Write("catChecked: " + catChecked.ToString()+"<br><br>");
				if(!CategoryService.isCategoryNull(catChecked)){
					return catChecked;
				}
			}
			
			return null;
		}
		
		public static double hierarchy2double(string hierarchy)
		{			
			double gerarchiaDbl= 0.0;
			double scale= 1.0 / 100.0;
			
			string[] p = null;
			if(!String.IsNullOrEmpty(hierarchy)){
				p = hierarchy.Split('.');
			}
			if(p!=null){
				foreach (string item in p){
					int level = Convert.ToInt32(item);
					gerarchiaDbl = gerarchiaDbl + (level * scale);	
					scale = scale / 100.0;					
				}
			} 

			return gerarchiaDbl;
		}		
	}
}