<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
protected IList<Language> languages;
protected Template template;
protected Category category;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		

	ICategoryRepository catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	ITemplateRepository templrep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");

	category = new Category();		
	category.id = -1;
	category.idTemplate = -1;
	template = new Template();
	template.id=-1;
		
		if(!String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
		{
			try{
				category = catrep.getById(Convert.ToInt32(Request["id"]));
			}catch (Exception ex){
				category = new Category();		
				category.id = -1;
			}		
		}	
	
		// recupero elementi della pagina necessari
		try{			
			languages = langrep.getLanguageList();	
			if(languages == null){				
				languages = new List<Language>();						
			}
		}catch (Exception ex){
			languages = new List<Language>();
		}
		
		int templateId = -1;
		if(!String.IsNullOrEmpty(Request["templateid"]) && Request["templateid"]!= "-1"){
			templateId = Convert.ToInt32(Request["templateid"]);
		}
		
		try{				
			template = templrep.getById(templateId);		
			if(template == null){				
				template = new Template();	
				template.id=-1;					
			}
		}catch (Exception ex){
			template = new Template();
			template.id=-1;
		}
}
</script>
<span class="labelForm"><%=lang.getTranslated("backend.categorie.lista.table.header.template_id_lang")%></span>
<%
string lang_code_cat, label_lang_cat;
foreach (Language x in languages){
	lang_code_cat = x.label;
	label_lang_cat = x.description;%>
	<div style="padding-bottom:3px;">
	<img width="16" height="11" border="0" style="padding-left:0px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("backend.lingue.lista.table.lang_label."+label_lang_cat)%>" title="<%=lang.getTranslated("backend.lingue.lista.table.lang_label."+label_lang_cat)%>" src="/backoffice/img/flag/flag-<%=lang_code_cat%>.png"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+label_lang_cat)%><br/>	
	<%if(template!=null && template.id>-1){
		foreach(TemplatePage tp in template.pages){
			if(tp.priority>=0){
				string urlRewrite = "";
				if(category!=null && category.id!=-1){
					foreach(CategoryTemplate ct in category.templates){
						if(ct.templateId==template.id && ct.langCode==lang_code_cat && ct.templatePageId==tp.id){
							urlRewrite = ct.urlRewrite;
							break;
						}
					}
				}%>
				<input type="text" name="url_rewrite_<%=lang_code_cat+"_"+tp.id%>" value="<%=urlRewrite%>" class="formFieldTXT" style="margin-right:5px;" onkeypress="javascript:return notSpecialCharButUnderscoreAndMinusAndSlashAndDot(event);"><%=tp.filePath+tp.fileName%><br/>
			<%}
		}
	}%>			
	</div>
<%}%>