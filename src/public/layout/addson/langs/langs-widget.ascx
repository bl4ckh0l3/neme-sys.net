<%@control Language="c#" description="lang-widget"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
private ASP.UserLoginControl login;
private string cssClass, url;
private IList<Language> languages;
private ConfigurationService confservice;
protected string hierarchy, categoryid;
protected Category category;
protected Template template;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	cssClass = Request["cssClass"];
	confservice = new ConfigurationService();
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	hierarchy = (string)Context.Items["hierarchy"];
	categoryid = (string)Context.Items["categoryid"];
	category = null;
	template = null;
	
	//Response.Write("Context.Items[hierarchy]: " + Context.Items["hierarchy"]+"<br><br>Context.Items[categoryid]: "+Context.Items["categoryid"]+"<br><br>");
			
	if(!String.IsNullOrEmpty(Request["hierarchy"]))
	{
		hierarchy = Request["hierarchy"];
	}
	if(!String.IsNullOrEmpty(Request["categoryid"]))
	{
		categoryid = Request["categoryid"];
	}

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
	if(!CategoryService.isCategoryNull(category)){	
		if(category.idTemplate>0){
			template = templrep.getByIdCached(category.idTemplate,true);
		}		
	}
	
	try
	{
		languages = langrep.findActive(true);
	}
	catch(Exception ex)
	{
		languages = new List<Language>();		
	}
}
</script>

<script language="Javascript">  
function changeActiveLang(strAction, strLangCode){
	document.form_change_lang.action=strAction;
	document.form_change_lang.lang_code.value=strLangCode;
	document.form_change_lang.submit();
}
</script>
<ul>
	<li><%	
	foreach (Language x in languages){
		if(template != null)
		{
			bool langHasSubDomainActive = false;
			string langUrlSubdomain = "";
			langHasSubDomainActive = x.subdomainActive;
			langUrlSubdomain = x.urlSubdomain;								
			
			url = MenuService.resolvePageHrefUrl(Request.Url.Scheme+"://", 1, x.label, langHasSubDomainActive, langUrlSubdomain, category, template, true);
			//Response.Write("url:"+url+"<br>");				
		}
		
		if(url== null){
			StringBuilder searchPath = new StringBuilder();
			if(x.subdomainActive)
			{	
				searchPath.Append(x.urlSubdomain);
			}
			
			UriBuilder builder = new UriBuilder(Request.Url);
			if(confservice.get("use_https").value=="1")
			{	
				builder.Scheme = "https";
			}
			else
			{
				builder.Scheme = "http";
			}
			builder.Port = -1;	
			builder.Query="";
			builder.Path = searchPath.ToString();		
			url = builder.ToString();
		}%>                
		<a href="javascript:changeActiveLang('<%=url%>', '<%=x.label%>');" title="<%//=lang.getTranslated("frontend.header.label.tips_nav_lang")%><%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" class="lang-widget<%if(x.label==lang.currentLangCode){Response.Write("-active");}%>"><img src="/common/img/flag/flag-<%=x.label%>.png" alt="<%//=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" border="0" align="absmiddle" /><%//=x.label%></a>
	<%}%>
	</li>
</ul>
<form action="" method="post" name="form_change_lang">	
<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
<input type="hidden" value="<%=categoryid%>" name="categoryid">	
<input type="hidden" value="" name="lang_code">          
</form>