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
protected IList<ProductAttachmentLabel> labelsList;
protected Product product;
protected bool hasFields,hasComments;
protected IList<SystemFieldsType> systemFieldsType;
protected IProductRepository prodrep;
protected ICountryRepository countryrep;
protected IList<Comment> comments;
protected IList<Country> countries;
protected IList<Country> stateRegions;
protected string supplement;
protected string supplementg;

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
	ISupplementRepository suprep = RepositoryFactory.getInstance<ISupplementRepository>("ISupplementRepository");	
	ISupplementGroupRepository supgrep = RepositoryFactory.getInstance<ISupplementGroupRepository>("ISupplementGroupRepository");
	prodrep = RepositoryFactory.getInstance<IProductRepository>("IProductRepository");
	countryrep = RepositoryFactory.getInstance<ICountryRepository>("ICountryRepository");
	StringBuilder url = new StringBuilder("/error.aspx?error_code=");
	hasFields = false;
	hasComments = false;
	comments = new List<Comment>();
	supplement = "";
	supplementg = "";

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
		product = prodrep.getById(Convert.ToInt32(Request["id"]));
		labelsList = prodrep.getProductAttachmentLabelCached(true);
		if(product.fields != null && product.fields.Count>0){hasFields = true;}
		
		systemFieldsType = commonrep.getSystemFieldsType();		
		if(systemFieldsType == null){				
			systemFieldsType = new List<SystemFieldsType>();						
		}
				
		//check for comments
		comments = commentrep.find(0,product.id,1,null);
		if(comments != null && comments.Count>0){
			hasComments = true;
		}
		
		//check for supplements/supplements group
		if(product.idSupplement != null && product.idSupplement>0){
			try{			
				Supplement sup = suprep.getById(product.idSupplement);	
				if(sup != null){				
					supplement = sup.description;						
				}
			}catch (Exception ex){}
		}
		if(product.idSupplementGroup != null && product.idSupplementGroup>0){
			try{			
				SupplementGroup supg = supgrep.getById(product.idSupplementGroup);	
				if(supg != null){				
					supplementg = supg.description;						
				}
			}catch (Exception ex){}
		}
	}
	catch(Exception ex)
	{
		//Response.Write(ex.Message);
		product=null;
		hasComments = false;
		comments = new List<Comment>();
		supplement = "";
		supplementg = "";
		labelsList = new List<ProductAttachmentLabel>();
		systemFieldsType = new List<SystemFieldsType>();
	}	
}
</script>


<link rel="stylesheet" href="/backoffice/css/jquery-ui-latest.custom.css" type="text/css">
<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui-latest.custom.min.js"></script>
<script>
function previewComments<%=product.id%>(){
	var query_string = "id_element=<%=product.id%>&element_type=1&mode=view&container=commentsContainer<%=product.id%>";	
	//alert(query_string);

	$('#commentsContainer<%=product.id%>').empty();
	$('#commentsContainer<%=product.id%>').append('<div align="center" style="padding-top:150px;" id="loading-menu-<%=product.id%>"><img src="/common/img/loading_icon.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="vertical-align:middle;text-align:center;padding-top:0px;padding-bottom:0px;"></div>');	
	$('#commentsContainer<%=product.id%>').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/include/ajaxpreviewcomments.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#commentsContainer<%=product.id%>').empty();
			$('#commentsContainer<%=product.id%>').append('<div align="right"><span style="cursor:pointer;text-decoration:underline;" onclick="javascript:hideCommentDiv<%=product.id%>();">x</span></div>');
			$('#commentsContainer<%=product.id%>').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#commentsContainer<%=product.id%>').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function hideCommentDiv<%=product.id%>(){
	$('#commentsContainer<%=product.id%>').hide();
}

$(function() {
	$("#commentsContainer<%=product.id%>").draggable();
});
</script>
<%if(product!=null){%>
	<table border="0" cellpadding="0" cellspacing="0" class="secondary">
	<tr>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.cod_prod")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.nome_prod")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.stato_news")%></th>
	</tr>
	<tr>
	<td><%=product.keyword%></td>
	<td class="separator">&nbsp;</td>
	<td><%=product.name%></td>
	<td class="separator">&nbsp;</td>
	<td><%
	if(product.status==0){
		Response.Write(lang.getTranslated("backend.product.lista.label.status_inactive"));
	}else if(product.status==1){
		Response.Write(lang.getTranslated("backend.product.lista.label.status_active"));
	}%>
	</td>
	</tr>
	<tr>
	<th colspan="5"><%=lang.getTranslated("backend.prodotti.view.table.label.sommario_prod")%></th>
	</tr>
	<tr>
	<td colspan="5"><%=product.summary%></td>
	</tr>
	<tr>
	<th colspan="5"><%=lang.getTranslated("backend.prodotti.view.table.label.desc_prod")%></th>
	</tr>
	<tr>
	<td colspan="5"><%=product.description%></td>
	</tr>

	<tr>
	<th><%=lang.getTranslated("backend.prodotti.detail.table.label.prod_type")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.qta_prod")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.edit_buy_qta")%></th>
	</tr>
	<tr>
	<td><%if(product.prodType==0){
		Response.Write(lang.getTranslated("backend.product.detail.table.label.type_portable"));
	}else if(product.prodType==1){
		Response.Write(lang.getTranslated("backend.product.detail.table.label.type_download"));
	}else if(product.prodType==2){
		Response.Write(lang.getTranslated("backend.product.detail.table.label.type_ads"));
	}%></td>
	<td class="separator">&nbsp;</td>
	<td><%if(product.quantity<0){
		Response.Write(lang.getTranslated("backend.product.detail.table.label.qta_unlimited"));
	}else{
		Response.Write(product.quantity);
	}%></td>
	<td class="separator">&nbsp;</td>
	<td><%if(product.setBuyQta){
		Response.Write(lang.getTranslated("backend.commons.no"));
	}else{
		Response.Write(lang.getTranslated("backend.commons.yes"));
	}%></td>
	</tr>

	<tr>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.prezzo_prod")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.tassa_applicata")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.taxs_group")%></th>
	</tr>
	<tr>
	<td>&euro;&nbsp;<%=product.price.ToString("###0.00")%></td>
	<td class="separator">&nbsp;</td>
	<td><%=supplement%></td>
	<td class="separator">&nbsp;</td>
	<td><%=supplementg%></td>
	</tr>

	<tr>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.sconto_prod")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.attached_files")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("portal.templates.commons.label.see_comments_news")%></th>
	</tr>
	<tr>
	<td><%=product.discount.ToString("##0.00")%>%</td>
	<td class="separator">&nbsp;</td>
	<td><%
	if (product.attachments!=null) {
		foreach(ProductAttachment ca in product.attachments){
			string clabel = "";
			if(labelsList != null){
				foreach(ProductAttachmentLabel cal in labelsList){
					if(cal.id == ca.fileLabel){
						clabel = cal.description;
						break;
					}
				}
			}
			Response.Write("-&nbsp;"+ca.filePath+ca.fileName+" ("+clabel+")<br>");
		}
	}%></td>
	<td class="separator">&nbsp;</td>
	<td>
	<%if(hasComments) {%>
		<a href="javascript:previewComments(<%=product.id%>);" title="<%=lang.getTranslated("portal.templates.commons.label.see_comments_news")%>"><img src="/backoffice/img/comments.png" hspace="0" vspace="0" border="0"></a>
		<div id="commentsWrapper<%=product.id%>" style="position:relative;">
			<div id="commentsContainer<%=product.id%>" style="z-index:10000;position:absolute;top:0px;top:-200px;left:-520px;width:500px;height:400px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
		</div>
	<%}else{
		Response.Write("<div align='left'>"+lang.getTranslated("backend.news.detail.table.label.no_comments")+"</div>");
	}%><br/></td>
	</tr>
	<tr>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.page_title")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.meta_description")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.prodotti.view.table.label.meta_keyword")%></th>
	</tr>
	<tr>
	<td><%=product.pageTitle%></td>
	<td class="separator">&nbsp;</td>
	<td><%=product.metaDescription%></td>
	<td class="separator">&nbsp;</td>
	<td><%=product.metaKeyword%></td>
	</tr>
	<tr>
	<th><%=lang.getTranslated("backend.news.view.table.label.inserted_date")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.data_pub")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.news.view.table.label.data_del")%></th>
	</tr>
	<tr>
	<td><%=product.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
	<td class="separator">&nbsp;</td>
	<td><%=product.publishDate.ToString("dd/MM/yyyy HH:mm")%></td>
	<td class="separator">&nbsp;</td>
	<td><%=product.deleteDate.ToString("dd/MM/yyyy HH:mm")%></td>
	</tr>

	<tr>
	<th colspan="6"><%=lang.getTranslated("backend.prodotti.view.table.label.extra_fields")%></th>
	</tr>
	<tr>
	<td colspan="6">
	<%if(hasFields) {%>
		 <table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table" id="inner-table-product-field-list">
			<tr>
			<th width="200"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_name")%></span></th>
			<th width="100"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_type")%></span></th>
			<th width="40"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_attivo")%></span></th>
			<th width="150"><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.prod_field_values")%></span></th>
			<th><span class="labelForm"><%=lang.getTranslated("backend.contenuti.detail.table.label.field_values")%></span></th>
			</tr>		
			<%foreach(ProductField cf in product.fields){			
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
					IList<ProductFieldsValue> values = prodrep.getProductFieldValues(cf.id);				
					if(values != null){
						foreach(ProductFieldsValue cfv in values){
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