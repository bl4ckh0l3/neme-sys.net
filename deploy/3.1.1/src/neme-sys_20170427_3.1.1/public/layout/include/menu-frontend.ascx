<%@control Language="c#" description="menu-frontend-control" className="MenuFrontendControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<script runat="server">  
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
private ConfigurationService configService = new ConfigurationService();
private ICategoryRepository catrep;
private ILanguageRepository langrep;
protected string baseURL, secureURL;

private int _menuNumber;	
public int menuNumber {
	get { if(_menuNumber!=null){return _menuNumber;}else{return 1;} }
	set { _menuNumber = value; }
}
private string _deep;	
public string deep {
	get {return _deep; }
	set { _deep = value; }
}
private string _hierarchyFrom;	
public string hierarchyFrom {
	get {return _hierarchyFrom; }
	set { _hierarchyFrom = value; }
}
private string _hierarchyTo;	
public string hierarchyTo {
	get {return _hierarchyTo; }
	set { _hierarchyTo = value; }
}
private int _level;	
public int level {
	get { if(_level!=null){return _level;}else{return 0;} }
	set { _level = value; }
}	
private string _ajaxLoad;	
public string ajaxLoad {
	get { if(_ajaxLoad!=null){return _ajaxLoad;}else{return configService.get("ajaxload_menu_frontend").value;} }
	set { _ajaxLoad = value; }
}
private int _modelPageNum;	
public int modelPageNum {
	get { if(_modelPageNum!=null){return _modelPageNum;}else{return 1;} }
	set { _modelPageNum = value; }
}
private string _hierarchy;	
public string hierarchy {
	get { return _hierarchy; }
	set { _hierarchy = value; }
}
private string _categoryid;	
public string categoryid {
	get { return _categoryid; }
	set { _categoryid = value; }
}
private int _index;	
public int index {
	get { return _index; }
	set { _index = value; }
}
private string _cssClass;	
public string cssClass {
	get { if(_cssClass!=null){return _cssClass;}else{return "menu-left";} }
	set { _cssClass = value; }
}
private string _model;	
public string model {
	get { if(_model!=null){return _model;}else{return "vertical";} }
	set { _model = value; }
}

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
	catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	categoryid = "";
	baseURL = Utils.getBaseUrl(Request.Url.ToString(),2).ToString();
	secureURL = Utils.getBaseUrl(Request.Url.ToString(),1).ToString();
}

protected void renderNotAjax()
{
	int clevel = 0;
	Category category = null;
	StringBuilder builder = new StringBuilder(Utils.getBaseUrl(Request.Url.ToString(),2).Scheme).Append("://");
		
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
			Nullable<bool> isDeep = null;
			if (!String.IsNullOrEmpty(deep)) {
				isDeep = Convert.ToBoolean(deep);
			}		
		
			menu = MenuService.getMenu(menuNumber, hierarchyFrom, hierarchyTo, level, isDeep);
		}
		
		if(menu != null && menu.Count>0)
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

<script>
function openLinkMenu<%=index%>(hierarchy, categoryid, actionUrl){
	if(actionUrl!="#"){
		document.menu_<%=index%>_linker.hierarchy.value=hierarchy;
		document.menu_<%=index%>_linker.categoryid.value=categoryid;
		document.menu_<%=index%>_linker.action=actionUrl;
		//alert("hierarchy:"+document.menu_<%=index%>_linker.hierarchy.value+" -categoryid:"+document.menu_<%=index%>_linker.categoryid.value);
		document.menu_<%=index%>_linker.submit();
	}
}
	   
function ajaxLoadMenu<%=index%>(){
  var query_string = "categoryid=<%=categoryid%>&hierarchy=<%=hierarchy%>&index=<%=index%>&model=<%=model%>&menuNumber=<%=menuNumber%>&hierarchyFrom=<%=hierarchyFrom%>&hierarchyTo=<%=hierarchyTo%>&level=<%=level%>&deep=<%=deep%>";
  //alert("query_string: "+query_string);

  $.ajax({
	async: true,
	type: "GET",
	cache: false,
	url: "<%=baseURL%>public/layout/include/ajax-menu-frontend.aspx",
	data: query_string,
	success: function(response) {
		//alert(response);
		$("#loading-menu-<%=index%>").hide();
		<%if(model=="horizontal"){%>
			$("#myslidemenu<%=index%>").append(response);
			$("#myslidemenu<%=index%>").fadeIn(1000);
			jqueryslidemenu.buildmenu("myslidemenu<%=index%>", arrowimages);
		<%}else if(model=="vertical"){%>
			$("#ajx_menu_<%=index%>").append(response);
			$("#ajx_menu_<%=index%>").fadeIn(1000);	
		<%}else if(model=="tips"){%>	
			$("#menu-tips-<%=index%>").empty();
			$("#menu-tips-<%=index%>").append(response);
			$("#menu-tips-<%=index%>").fadeIn(1000);
		<%}%>
	},
	error: function() {
		//alert("errorrrrrrrrrr!");
		<%if(model=="tips"){%>	
			$("#menu-tips-<%=index%>").empty();
		<%}else{%>	
			$("#loading-menu-<%=index%>").hide();
		<%}%>
		
	}
  });
}

jQuery(document).ready(function(){
	<%if(Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){%>
		ajaxLoadMenu<%=index%>();
	<%}else{%>
		$("#loading-menu-<%=index%>").hide();
		<%if(model=="horizontal"){%>
			jqueryslidemenu.buildmenu("myslidemenu<%=index%>", arrowimages);
		<%}else if(model=="vertical"){%>
			$("#ajx_menu_<%=index%>").show();		
		<%}else if(model=="tips"){%>

		<%}%>
	<%}%>
});
</script>

<%if(model=="vertical"){%>
	<div id="menu-<%=index%>" class="<%=cssClass%>">
		<span id="loading-menu-<%=index%>" style="<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){%>display:none;<%}%>"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:50px;padding-bottom:50px;"></span>
		<ul id="ajx_menu_<%=index%>" style="display:none;">
		<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){
			renderNotAjax();
		}%>
		</ul>

		<!--nsys-inc1--><!---nsys-inc1-->
	</div>
<%}else if(model=="horizontal"){%>
	<div id="myslidemenu<%=index%>" class="jqueryslidemenu">
		<span id="loading-menu-<%=index%>" style="<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){%>display:none;<%}%>"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:2px;padding-bottom:0px;"></span>
		<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){
			renderNotAjax();
		}%>
	</div>
<%}else if(model=="tips"){%>
	<div id="menu-tips-<%=index%>" class="menuTips">
		<span id="loading-menu-<%=index%>" style="<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){%>display:none;<%}%>"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:0px;padding-bottom:0px;"></span>
		<%if(!Convert.ToBoolean(Convert.ToInt32(ajaxLoad))){
			renderNotAjax();
		}%>
	</div>
<%}%>
<form name="menu_<%=index%>_linker" method="post" action="">
<input type="hidden" name="categoryid" value="">
<input type="hidden" name="hierarchy" value="">
<input type="hidden" name="modelPageNum" value="<%=modelPageNum%>">
</form>