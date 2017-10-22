<%@ Page Language="C#" Debug="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService confservice;
protected bool bolFoundLista = false;
protected bool paginate = false;
protected IList<FContent> contents;
protected int numPage, itemsXpage, orderBy, modelPageNum;
protected int fromContent, toContent;
protected long totalCount;
protected IList<int> matchCategories = null;
protected string status;
protected string hierarchy;
protected string categoryid;
protected string contentid;
protected string pageTitle, metaDescription, metaKeyword;
protected IList<ContentAttachmentLabel> attachmentsLabel = null;
protected StringBuilder builder;
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
	Response.AddHeader("content-disposition", "attachment;  filename=contents.xml");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	IContentRepository contentrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");	
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	confservice = new ConfigurationService();
	path = CommonService.getBaseUrl(Request.Url.ToString(),2);

	//se il sito � offline rimando a pagina default
	if ("1".Equals(confservice.get("go_offline").value)) 
	{
		Response.Redirect(path.ToString());
	}
			
	builder = new StringBuilder(path.Scheme).Append("://").Append(path.Host);
	
	Category category = null;
	Template template = null;	
	IList<int> matchLanguages = null;
	numPage = 1;
	status = "1";
	itemsXpage = 20;
	orderBy = 1;
	modelPageNum = 1;
	attachmentsLabel = contentrep.getContentAttachmentLabelCached(true);
	contentid = "";
	totalCount = 0L;
	
	try
	{
		// verifico se � stato richiesto un singolo contenuto
		if(!String.IsNullOrEmpty(Request["contentid"]))
		{
			contentid = Request["contentid"];				
		}

		// verifico se e' stata richiesta la paginazione
		if(!String.IsNullOrEmpty(Request["items"]))
		{
			paginate = true;	
			itemsXpage = Convert.ToInt32(Request["items"]);
			numPage = Convert.ToInt32(Request["page"]);
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
			contents.Add(contentrep.getByIdCached(Convert.ToInt32(contentid), true));
		}else{
			if(paginate){
				contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,numPage,itemsXpage,out totalCount);
			}else{
				contents = contentrep.find(null,null,status,0,null,null,orderBy,matchCategories,matchLanguages,true,true,true,true,true);	
			}
			
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
<!--<?xml version="1.0"?>-->
  <root> 
	<%
	if(bolFoundLista) {		
		if(paginate){%>
			<total_count><%=totalCount%></total_count>
		<%}
		
		foreach (FContent content in contents){%>
			<item>
			<id><%=content.id%></id>
			<title><![CDATA[<%=content.title%>]]></title>
			<summary><![CDATA[<%=content.summary%>]]></summary>
			<description><![CDATA[<%=content.description%>]]></description>
			<keyword><![CDATA[<%=content.keyword%>]]></keyword>
			<page_title><![CDATA[<%=content.pageTitle%>]]></page_title>
			<meta_keyword><![CDATA[<%=content.metaKeyword%>]]></meta_keyword>
			<meta_description><![CDATA[<%=content.metaDescription%>]]></meta_description>
			<data_public><![CDATA[<%=content.publishDate%>]]></data_public>
			<data_delete><![CDATA[<%=content.deleteDate%>]]></data_delete>
			<%
			IDictionary<string, IList<ContentAttachment>> attachmentsDictionary = new Dictionary<string, IList<ContentAttachment>>();
			if(content.attachments != null)
			{
				foreach(ContentAttachment ca in content.attachments)
				{				
					int label = ca.fileLabel;
					string alabel = "";
					foreach(ContentAttachmentLabel cal in attachmentsLabel)
					{
						if(cal.id==label)
						{
							alabel = cal.description;
							break;
						}
					}
					
					if(attachmentsDictionary.ContainsKey(alabel))
					{
						IList<ContentAttachment> items = null;
						if(attachmentsDictionary.TryGetValue(alabel, out items)){
							items.Add(ca);
							attachmentsDictionary[alabel] = items;
						}
					}
					else
					{
						IList<ContentAttachment> items = new List<ContentAttachment>();
						items.Add(ca);
						attachmentsDictionary[alabel] = items;
					}
				}
			}	

			if(attachmentsDictionary.Keys.Count>0){%> 
				<attachments>
				<%foreach(string keyword in attachmentsDictionary.Keys){%>
					<%foreach(ContentAttachment item in attachmentsDictionary[keyword]){%>
						<attach><%=builder.ToString()+"/public/upload/files/contents/"+item.filePath+item.fileName%></attach>
					<%}
				}%>
				</attachments>
			<%}%>			
			</item>
		<%}		
	}%>
  </root> 