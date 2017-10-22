<%@ Page Language="C#"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
private ASP.UserLoginControl login;
protected string hierarchy;
protected string categoryid;
protected int numPage, modelPageNum;
	
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");	
	IMultiLanguageRepository multilangrep = RepositoryFactory.getInstance<IMultiLanguageRepository>("IMultiLanguageRepository");	
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	ConfigurationService confservice = new ConfigurationService();

	//se il sito è offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		UriBuilder defRedirect = new UriBuilder(Request.Url);
		defRedirect.Port = -1;	
		defRedirect.Path = "";			
		defRedirect.Query = "";
		Response.Redirect(defRedirect.ToString());
	}	
	
	StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
	string basePath = Request.Path.ToLower();
	string newLangCode = "";
	
	Category category = null;
	Template template = null;	
	IList<int> matchLanguages = null;
	numPage = 1;
	string status = "1";
	int orderBy = 1;
	modelPageNum = 1;
	hierarchy = (string)HttpContext.Current.Items["hierarchy"];
	categoryid = (string)HttpContext.Current.Items["categoryid"];
	
	if (!String.IsNullOrEmpty(Request["page"])) {
		numPage = Convert.ToInt32(Request["page"]);
	}
	
	try
	{
		if(!String.IsNullOrEmpty(Request["hierarchy"]))
		{
			hierarchy = Request["hierarchy"];
		}
		if(!String.IsNullOrEmpty(Request["categoryid"]))
		{
			categoryid = Request["categoryid"];
		}		
		
		// tento di risolvere la categoria e il template in base ai parametri della request
		if(!String.IsNullOrEmpty(categoryid))
		{
			category = catrep.getByIdCached(Convert.ToInt32(categoryid), true);
			hierarchy = category.hierarchy;				
		}
		if(CategoryService.isCategoryNull(category))
		{	
			if(!String.IsNullOrEmpty(hierarchy))
			{
				category = catrep.getByHierarchyCached(hierarchy, true);	
			}			
		}

		//Response.Write("category:"+category.ToString()+"<br>");			
		
		if(!CategoryService.isCategoryNull(category)){				
			//setMetaCategory(category);
		}	
		
		// if category still null try to resolve category by url
		if(CategoryService.isCategoryNull(category))
		{
			template = TemplateService.resolveTemplateByVirtualPath(basePath, lang.currentLangCode, out newLangCode);
			if(template != null)
			{
				category = catrep.getByTemplateCached(template.id, Page.Request.RawUrl.ToString(), true);
				if(!CategoryService.isCategoryNull(category))
				{
					if(String.IsNullOrEmpty(Request["lang_code"]) && !String.IsNullOrEmpty(newLangCode)){
						HttpContext.Current.Items["lang-code"] = newLangCode;
						lang.set();
					}	
					hierarchy = category.hierarchy;					
					//setMetaCategory(category); 					
				}
			}
		}
		if(!CategoryService.isCategoryNull(category))
		{
			categoryid = category.id.ToString();
		}

		if (!String.IsNullOrEmpty(lang.currentLangCode)) {
			matchLanguages = new List<int>();
			matchLanguages.Add(langrep.getByLabel(lang.currentLangCode).id);
		}

		if (!String.IsNullOrEmpty(Request["content_preview"])) {
			status = null;
		}
			
		if(!String.IsNullOrEmpty(Request["order_by"]))
		{
			orderBy = Convert.ToInt32(Request["order_by"]);	
		}	
	}catch (Exception ex){
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}
	
	// init menu frontend
	this.mf1.modelPageNum = this.modelPageNum;
	this.mf1.categoryid = categoryid;	
	this.mf1.hierarchy = hierarchy;	
	this.mf2.modelPageNum = this.modelPageNum;
	this.mf2.categoryid = categoryid;	
	this.mf2.hierarchy = hierarchy;	
	this.mf3.modelPageNum = this.modelPageNum;
	this.mf3.categoryid = categoryid;	
	this.mf3.hierarchy = hierarchy;
	//this.mf4.modelPageNum = this.modelPageNum;
	//this.mf4.categoryid = categoryid;	
	//this.mf4.hierarchy = hierarchy;
	this.mf5.modelPageNum = this.modelPageNum;
	this.mf5.categoryid = categoryid;	
	this.mf5.hierarchy = hierarchy;
}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%//=pageTitle%></title>
<META name="description" CONTENT="<%//=metaDescription%>">
<META name="keywords" CONTENT="<%//=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<div style="clear:left;float:left;">
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		</div>
		<div id="content-center">
			<MenuFrontendControl:insert runat="server" ID="mf3" index="3" model="tips"/>
			<div align="left">
			<%//if (content != null) {%>
				<div>
				<p><lang:getTranslated keyword="portal.commons.templates.label.mailsent" runat="server" /></p>				
				</div>
				<%//}else{%>
				<!--<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>-->
			<%//}%>
			</div>
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
		<!-- include virtual="/public/layout/addson/contents/news_comments_widget.inc" -->
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>