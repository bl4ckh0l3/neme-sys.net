<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();

	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ConfigurationService confservice = new ConfigurationService();
	Category category = null;
	int clevel = 0;
	string categoryid = Request["categoryid"];
	string hierarchy = Request["hierarchy"];
	int index = Convert.ToInt32(Request["index"]);
	string model = Request["model"];
	int  menuNumber = 1;
	if(!String.IsNullOrEmpty(Request["menuNumber"])){
		menuNumber = Convert.ToInt32(Request["menuNumber"]);	
	}
	string hierarchyFrom = Request["hierarchyFrom"];
	string hierarchyTo = Request["hierarchyTo"];
	int level = 0;
	if(!String.IsNullOrEmpty(Request["level"])){
		level = Convert.ToInt32(Request["level"]);	
	}
	string deep = Request["deep"];
	
	StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
		
	try
	{
		// tento di risolvere la categoria e il template in base ai parametri della request	
		if(!String.IsNullOrEmpty(hierarchy))
		{
			category = catrep.getByHierarchyCached(hierarchy, true);	
		}	
		if(CategoryService.isCategoryNull(category))
		{	
			if(!String.IsNullOrEmpty(categoryid))
			{
				category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
				hierarchy = category.hierarchy;				
			}	
		}
		
		if(!CategoryService.isCategoryNull(category)){						
			clevel = category.getLevel();
		}
		
		IList<Category> menu = null;
		if(model=="tips"){
			menu = MenuService.getMenuTips(hierarchy);
		}else{
			menu = MenuService.getMenu(menuNumber, hierarchyFrom, hierarchyTo, level, deep);
		}
				
		if(menu != null)
		{
			IDictionary<string, IList<string>> labels = new Dictionary<string, IList<string>>();
			foreach(Category cat in menu){
				string menuCompleteCatLabelTrans = lang.getTranslated("backend.categorie.detail.table.label.description_"+cat.hierarchy);
				if (String.IsNullOrEmpty(menuCompleteCatLabelTrans)){
					menuCompleteCatLabelTrans = cat.description;
				}
				string menuCompleteCatDescTrans = lang.getTranslated("backend.categorie.detail.table.label.summary_"+cat.hierarchy);
				
				IList<string> lbs = new List<string>();
				lbs.Add(menuCompleteCatLabelTrans);	
				lbs.Add(menuCompleteCatDescTrans);	
				labels.Add(cat.hierarchy,lbs);	
			}
		
			if(model=="vertical"){
				MenuService.renderMenuVertical(menu, lang.currentLangCode, hierarchy, builder.ToString(), clevel, index, labels);
			}else if(model=="horizontal"){
				MenuService.renderMenuHorizontal(menu, lang.currentLangCode, hierarchy, builder.ToString(), index, labels);
			}else if(model=="tips"){
				MenuService.renderMenuTips(menu, lang.currentLangCode, builder.ToString(), index, labels);
			}
		}
	}
	catch(Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
}
</script>