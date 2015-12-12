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
protected IList<ContentAttachmentLabel> labelsList;
protected FContent content;
protected bool hasFields,hasComments;
protected IList<SystemFieldsType> systemFieldsType;
protected IContentRepository contrep;
protected ICountryRepository countryrep;
protected IList<Comment> comments;
protected IList<Country> countries;
protected IList<Country> stateRegions;

protected void Page_Init(Object sender, EventArgs e)
{
	lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;		

	ICommonRepository commonrep = RepositoryFactory.getInstance<ICommonRepository>("ICommonRepository");
	ICommentRepository commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	contrep = RepositoryFactory.getInstance<IContentRepository>("IContentRepository");
	countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	hasFields = false;
	hasComments = false;
	comments = new List<Comment>();

	try{				
		countries = countryrep.findAllCountries("1");		
		if(countries == null){				
			countries = new List<Country>();						
		}
	}catch (Exception ex){
		countries = new List<Country>();
	}
	try{				
		stateRegions = countryrep.findStateRegionByCountry(null,"1");	
		if(stateRegions == null){				
			stateRegions = new List<Country>();						
		}
	}catch (Exception ex){
		stateRegions = new List<Country>();
	}

	try
	{		
		content = contrep.getById(Convert.ToInt32(Request["id"]));
		labelsList = contrep.getContentAttachmentLabelCached(true);
		if(content.fields != null && content.fields.Count>0){hasFields = true;}
		
		systemFieldsType = commonrep.getSystemFieldsType();		
		if(systemFieldsType == null){				
			systemFieldsType = new List<SystemFieldsType>();						
		}
				
		//check for comments
		comments = commentrep.find(0,content.id,1,null);
		if(comments != null && comments.Count>0){
			hasComments = true;
		}
	}
	catch(Exception ex)
	{
		//Response.Write(ex.Message);
		content=null;
		hasComments = false;
		comments = new List<Comment>();
		labelsList = new List<ContentAttachmentLabel>();
		systemFieldsType = new List<SystemFieldsType>();
	}	
}
</script>


<link rel="stylesheet" href="/backoffice/css/jquery-ui-latest.custom.css" type="text/css">
<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui-latest.custom.min.js"></script>
<script>
function previewComments<%=content.id%>(){
	var query_string = "id_element=<%=content.id%>&element_type=1&mode=view&container=commentsContainer<%=content.id%>";	
	//alert(query_string);

	$('#commentsContainer<%=content.id%>').empty();
	$('#commentsContainer<%=content.id%>').append('<div align="center" style="padding-top:150px;" id="loading-menu-<%=content.id%>"><img src="/common/img/loading_icon.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="vertical-align:middle;text-align:center;padding-top:0px;padding-bottom:0px;"></div>');	
	$('#commentsContainer<%=content.id%>').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/include/ajaxpreviewcomments.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#commentsContainer<%=content.id%>').empty();
			$('#commentsContainer<%=content.id%>').append('<div align="right"><span style="cursor:pointer;text-decoration:underline;" onclick="javascript:hideCommentDiv<%=content.id%>();">x</span></div>');
			$('#commentsContainer<%=content.id%>').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#commentsContainer<%=content.id%>').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function hideCommentDiv<%=content.id%>(){
	$('#commentsContainer<%=content.id%>').hide();
}

$(function() {
	$("#commentsContainer<%=content.id%>").draggable();
});
</script>
<%if(content!=null){%>
	<table border="0" cellpadding="0" cellspacing="0" class="secondary">
	<tr>
	<th><%=lang.getTranslated("backend.news.view.table.label.title")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.abstract_field")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("portal.templates.commons.label.see_comments_news")%></th>
	</tr>
	<tr>
	<td><%=content.title%></td>
	<td class="separator">&nbsp;</td>
	<td><%=content.summary%></td>
	<td class="separator">&nbsp;</td>
	<td>
	<%if(hasComments) {%>
		<a href="javascript:previewComments<%=content.id%>();" title="<%=lang.getTranslated("portal.templates.commons.label.see_comments_news")%>"><img src="/backoffice/img/comments.png" hspace="0" vspace="0" border="0"></a>
		<div id="commentsWrapper<%=content.id%>" style="position:relative;">
			<div id="commentsContainer<%=content.id%>" style="z-index:10000;position:absolute;top:0px;top:-200px;left:-520px;width:500px;height:400px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
		</div>
	<%}else{
		Response.Write("<div align='left'>"+lang.getTranslated("backend.news.detail.table.label.no_comments")+"</div>");
	}%><br/>
	</td>
	</tr>
	<tr>
	<th colspan="5"><%=lang.getTranslated("backend.news.view.table.label.text")%></th>
	</tr>
	<tr>
	<td colspan="5"><%=content.description%></td>
	</tr>
	<tr>
	<th><%=lang.getTranslated("backend.news.view.table.label.keyword")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.stato_news")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.attached_files")%></th>
	</tr>
	<tr>
	<td><%=content.keyword%></td>
	<td class="separator">&nbsp;</td>
	<td><%
	if(content.status==0){
		Response.Write(lang.getTranslated("backend.news.view.table.label.da_editare"));
	}else{
		Response.Write(lang.getTranslated("backend.news.view.table.label.pubblicata"));
	}%></td>
	<td class="separator">&nbsp;</td>
	<td><%
	if (content.attachments!=null) {
		foreach(ContentAttachment ca in content.attachments){
			string clabel = "";
			if(labelsList != null){
				foreach(ContentAttachmentLabel cal in labelsList){
					if(cal.id == ca.fileLabel){
						clabel = cal.description;
						break;
					}
				}
			}
			Response.Write("-&nbsp;"+ca.filePath+ca.fileName+" ("+clabel+")<br>");
		}
	}%></td>
	</tr>
	<tr>
	<th><%=lang.getTranslated("backend.news.view.table.label.page_title")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.meta_description")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.meta_keyword")%></th>
	</tr>
	<tr>
	<td><%=content.pageTitle%></td>
	<td class="separator">&nbsp;</td>
	<td><%=content.metaDescription%></td>
	<td class="separator">&nbsp;</td>
	<td><%=content.metaKeyword%></td>
	</tr>
	<tr>
	<th><%=lang.getTranslated("backend.news.view.table.label.inserted_date")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.data_pub")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.data_del")%></th>
	</tr>
	<tr>
	<td><%=content.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
	<td class="separator">&nbsp;</td>
	<td><%=content.publishDate.ToString("dd/MM/yyyy HH:mm")%></td>
	<td class="separator">&nbsp;</td>
	<td><%=content.deleteDate.ToString("dd/MM/yyyy HH:mm")%></td>
	</tr>

	<tr>
	<th colspan="6"><%=lang.getTranslated("backend.contenuti.view.table.label.extra_fields")%></th>
	</tr>
	<tr>
	<td colspan="6">
	<%if(hasFields) {%>
		 <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-content-field-list">
			<tr>
			<th width="200"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span></th>
			<th width="100"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_type")%></span></th>
			<th width="40"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span></th>
			<th width="150"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span></th>
			<th><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.field_values")%></span></th>
			</tr>		
			<%foreach(ContentField cf in content.fields){			
				string labelForm = cf.description;
				
				if(!String.IsNullOrEmpty(lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm))){
					 labelForm = lang.getTranslated("backend.contenuti.detail.table.label.field_description_"+labelForm);
				}

				string currtype = "";
				foreach(SystemFieldsType x in systemFieldsType){
					if(cf.type==x.id){
						currtype=x.description;
						break;
					}
				}
				
				string currvalue = cf.value;
				if(cf.type==3){
					if(cf.typeContent==7 && !String.IsNullOrEmpty(cf.value)){
						string tmpcfval = cf.value.Substring(0,cf.value.IndexOf('_'));
						foreach(Country c in countries){
							if(tmpcfval == c.countryCode){
								currvalue = c.countryDescription;
								break;
							}
						}
					}else if(cf.typeContent==8 && !String.IsNullOrEmpty(cf.value)){
						string tmpcfval = cf.value.Substring(0,cf.value.IndexOf('_'));
						foreach(Country sr in stateRegions){
							if(tmpcfval == sr.stateRegionCode){
								currvalue = sr.countryDescription+" "+sr.stateRegionDescription;
								break;
							}
						}									
					}
				}				
				
				string listvalues = "";
				if(cf.type==3 || cf.type==4 || cf.type==5 || cf.type==6){
					IList<ContentFieldsValue> values = contrep.getContentFieldValues(cf.id);				
					if(values != null){
						foreach(ContentFieldsValue cfv in values){
							listvalues += cfv.value+", ";
						}
						if(listvalues.LastIndexOf(',')>0){
							listvalues = listvalues.Substring(0,listvalues.LastIndexOf(','));
						}
					}
				}%>
				<tr>
					<td><%=labelForm%></td>
					<td><%=currtype%></td>
					<td><%if(cf.enabled){Response.Write(lang.getTranslated("portal.commons.yes"));}else{Response.Write(lang.getTranslated("portal.commons.no"));}%></td>
					<td><%=currvalue%></td>
					<td><%=listvalues%></td>
				</tr>
			<%}%>
		</table>
	<%}%>
	</td>
	</tr>
	</table>
<%}%>