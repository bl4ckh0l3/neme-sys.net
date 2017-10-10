<?xml version="1.0"?>
<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/common/include/pagination.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected bool bolFoundLista = false;
protected IList<FContent> contents;
protected int numPage, itemsXpage, orderBy, modelPageNum;
protected int fromContent, toContent;
protected IList<int> matchCategories = null;
protected string status;
protected string hierarchy;
protected string categoryid, categoryDesc, hrefGer, newCatId;
protected string contentid;
protected string pageTitle, metaDescription, metaKeyword;
protected IList<ContentAttachmentLabel> attachmentsLabel = null;
protected StringBuilder builder;
protected Category category = null;
protected Template template = null;	
protected IList<int> matchLanguages = null;	
protected ICategoryRepository catrep;
protected ITemplateRepository templrep;
protected ILanguageRepository langrep;
protected UriBuilder path;
	
protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
	login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(object sender, EventArgs e) 
{	
	lang.set();
	Response.Clear();				
	Response.ContentType = "text/xml";
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");	
	langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	confservice = new ConfigurationService();
	path = CommonService.getBaseUrl(Request.Url.ToString(),2);

	//se il sito � offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		Response.Redirect(path.ToString());
	}
			
	builder = new StringBuilder(path.Scheme).Append("://").Append(path.Host);
	
	category = null;
	template = null;	
	matchLanguages = null;
	numPage = 1;
	status = "1";
	itemsXpage = 20;
	orderBy = 1;
	modelPageNum = 1;
	attachmentsLabel = contentrep.getContentAttachmentLabelCached(true);
	contentid = "";
	categoryDesc = "";
	hrefGer = "";
	newCatId = "";
	
	try
	{
		// verifico se � stato richiesto un singolo contenuto
		if(!String.IsNullOrEmpty(Request["contentid"]))
		{
			contentid = Request["contentid"];				
		}
		
		// tento di risolvere la categoria e il template in base ai parametri della request
		if(!String.IsNullOrEmpty(Request["categoryid"]))
		{
			category = catrep.getByIdCached(Convert.ToInt32(Request["categoryid"]), true);
			hierarchy = category.hierarchy;				
		}
		if(CategoryService.isCategoryNull(category))
		{	
			if(!String.IsNullOrEmpty(Request["hierarchy"]))
			{
				hierarchy = Request["hierarchy"];
				category = catrep.getByHierarchyCached(hierarchy, true);	
			}			
		}
		
		if(!CategoryService.isCategoryNull(category))
		{
			categoryid = category.id.ToString();
			categoryDesc = category.description;
		}
	}catch (Exception ex){
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}

	if (!String.IsNullOrEmpty(lang.currentLangCode)) {
		matchLanguages = new List<int>();
		matchLanguages.Add(langrep.getByLabel(lang.currentLangCode, true).id);
	}

	if(!String.IsNullOrEmpty(Request["order_by"]))
	{
		orderBy = Convert.ToInt32(Request["order_by"]);	
	}
					
	try
	{
		if(!String.IsNullOrEmpty(contentid)){
			contents = new List<FContent>();
			FContent tmp = contentrep.getByIdCached(Convert.ToInt32(contentid), true);
			contents.Add(tmp);
		}else{
			contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);		
			if(contents != null && contents.Count>0){				
				bolFoundLista = true;						
			}
		}		
	}
	catch (Exception ex){
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		contents = new List<FContent>();						
		bolFoundLista = false;
	}
}	
</script>
<rss version="2.0">
  <channel> 
    <title>Feed RSS: <%=categoryDesc%></title> 
    <link><%=path.Host%></link> 
    <description>Feed RSS: <%=categoryDesc%></description> 
    <language><%=lang.currentLangCode%></language> 
	<%if(bolFoundLista) {		
		foreach(FContent content in contents){
			string detailLink = "#";
			if(content.categories != null){
				foreach(ContentCategory cc in content.categories){
					category = catrep.getByIdCached(Convert.ToInt32(cc.idCategory), true);
					int templateid = CategoryService.getTemplateId(category, lang.currentLangCode);
					template = templrep.getByIdCached(templateid,true);
					
					if(template != null){				
						bool langHasSubDomainActive = false;
						string langUrlSubdomain = "";
						Language language = langrep.getByLabel(lang.currentLangCode, true);	
						modelPageNum = TemplateService.getMaxPriority(template.pages);						
								
						if(language != null){	
							langHasSubDomainActive = language.subdomainActive;
							langUrlSubdomain = language.urlSubdomain;
						}								
						
						detailLink = MenuService.resolvePageHrefUrl(path.Scheme+"://", modelPageNum, lang.currentLangCode, langHasSubDomainActive, langUrlSubdomain, category, template, true);
						break;

					}		
				}
			}			
			%>
			<item>
			<title><![CDATA[<%=content.title%>]]></title>
			<description><![CDATA[<%=content.summary%>]]></description>
			<link><![CDATA[<%=detailLink%>]]></link>
			</item>
		<%}		
	}%>
  </channel> 
</rss>