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
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<script runat="server">
public ASP.BoMultiLanguageControl lang;
public ASP.UserLoginControl login;
protected Template template;
protected int counter = 0;
protected ConfigurationService confservice;
protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
	
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
	login.acceptedRoles = "1";
	if(!login.checkedUser()){
		Response.Redirect("~/login.aspx?error_code=002");
	}

	ITemplateRepository temprep = RepositoryFactory.getInstance<ITemplateRepository>("ITemplateRepository");
	confservice = new ConfigurationService();
	
	try
	{
		if(!String.IsNullOrEmpty(Request["id"])){
			template = temprep.getById(Convert.ToInt32(Request["id"]));
		}
		
		if(!String.IsNullOrEmpty(Request["counter"])){
			counter = Convert.ToInt32(Request["counter"]);
		}		
	}
	catch(Exception ex)
	{
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
		template = null;
	}
}
</script>

<%if(template!=null){%>
	<table border="0" cellpadding="0" cellspacing="0" class="secondary">
	<tr>
	<th><%=lang.getTranslated("backend.templates.view.table.label.id_template")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.templates.view.table.label.base_template")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.templates.view.table.label.elem_x_page")%></th>
	<td class="separator">&nbsp;</td>
	<th><%=lang.getTranslated("backend.templates.view.table.label.order_by")%></th>
	</tr>
	<tr>
	<td><%=template.id%></td>
	<td class="separator">&nbsp;</td>
	<td>
	<div class="ajax" id="view_base_<%=counter%>" onmouseover="javascript:showHide('view_base_<%=counter%>','edit_base_<%=counter%>','base_<%=counter%>',500, true);">
	<%
	if (template.isBase) { 
		Response.Write(lang.getTranslated("backend.commons.yes"));
	}else{ 
		Response.Write(lang.getTranslated("backend.commons.no"));
	}
	%>
	</div>
	<div class="ajax" id="edit_base_<%=counter%>">
	<select name="isBase" class="formfieldAjaxSelect" id="base_<%=counter%>" onblur="javascript:updateField('edit_base_<%=counter%>','view_base_<%=counter%>','base_<%=counter%>','Template|ITemplateRepository|bool',<%=template.id%>,2,<%=counter%>);">
	<OPTION VALUE="0" <%if (!template.isBase) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
	<OPTION VALUE="1" <%if (template.isBase) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
	</SELECT>	
	</div>
	<script>
	$("#edit_base_<%=counter%>").hide();
	</script>	
	</td>
	<td class="separator">&nbsp;</td>
	<td>
		<div class="ajax" id="view_page_elem_<%=counter%>" onmouseover="javascript:showHide('view_page_elem_<%=counter%>','edit_page_elem_<%=counter%>','page_elem_<%=counter%>',500, false);"><%=template.elemXpage%></div>
		<div class="ajax" id="edit_page_elem_<%=counter%>"><input type="text" class="formfieldAjaxShort" id="page_elem_<%=counter%>" name="elemXpage" onmouseout="javascript:restoreField('edit_page_elem_<%=counter%>','view_page_elem_<%=counter%>','page_elem_<%=counter%>','Template|ITemplateRepository|int',<%=template.id%>,1,<%=counter%>);" value="<%=template.elemXpage%>" maxlength="2" onkeypress="javascript:return isInteger(event);"></div>
		<script>
		$("#edit_page_elem_<%=counter%>").hide();
		</script>	
	</td>
	<td class="separator">&nbsp;</td>
	<td>
	<div class="ajax" id="view_order_by_<%=counter%>" onmouseover="javascript:showHide('view_order_by_<%=counter%>','edit_order_by_<%=counter%>','order_by_<%=counter%>',500, true);">
	<%if(0 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_default"));}%>
	<%if(1 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_title_asc"));}%>
	<%if(2 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_title_desc"));}%>
	<%if(3 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_abstract_asc"));}%>
	<%if(4 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_abstract_desc"));}%>
	<%if(5 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_keyword_asc"));}%>
	<%if(6 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_keyword_desc"));}%>
	<%if(7 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_data_pub_asc"));}%>
	<%if(8 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_data_pub_desc"));}%>
	<!--nsys-tmpajx1-->
	<%if(9 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_attivo_asc"));}%>
	<%if(10 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_attivo_desc"));}%>
	<%if(11 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_prezzo_asc"));}%>
	<%if(12 == template.orderBy) { Response.Write(lang.getTranslated("backend.templates.option.label.order_prezzo_desc"));}%>
	<!---nsys-tmpajx1-->
	</div>
	<div class="ajax" id="edit_order_by_<%=counter%>">
	<select name="orderBy" class="formfieldAjaxSelect" id="order_by_<%=counter%>" onblur="javascript:updateField('edit_order_by_<%=counter%>','view_order_by_<%=counter%>','order_by_<%=counter%>','Template|ITemplateRepository|int',<%=template.id%>,2,<%=counter%>);">
	<OPTION VALUE="0" <%if(0 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_default")%></OPTION>
	<OPTION VALUE="1" <%if(1 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_title_asc")%></OPTION>
	<OPTION VALUE="2" <%if(2 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_title_desc")%></OPTION>
	<OPTION VALUE="3" <%if(3 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_abstract_asc")%></OPTION>
	<OPTION VALUE="4" <%if(4 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_abstract_desc")%></OPTION>
	<OPTION VALUE="5" <%if(5 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_keyword_asc")%></OPTION>
	<OPTION VALUE="6" <%if(6 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_keyword_desc")%></OPTION>
	<OPTION VALUE="7" <%if(7 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_data_pub_asc")%></OPTION>
	<OPTION VALUE="8" <%if(8 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_data_pub_desc")%></OPTION>
	<!--nsys-tmpajx1-->
	<OPTION VALUE="9" <%if(9 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_attivo_asc")%></OPTION>
	<OPTION VALUE="10" <%if(10 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_attivo_desc")%></OPTION>
	<OPTION VALUE="11" <%if(11 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_prezzo_asc")%></OPTION>
	<OPTION VALUE="12" <%if(12 == template.orderBy) { Response.Write("selected");}%>><%=lang.getTranslated("backend.templates.option.label.order_prezzo_desc")%></OPTION>
	<!---nsys-tmpajx1-->
	</SELECT>	
	</div>
	<script>
	$("#edit_order_by_<%=counter%>").hide();
	</script>		
	</td>
	</tr>		
	<%if (template.pages != null && template.pages.Count > 0) {%>
		<tr>
		<td colspan="7">
		<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">
		<th colspan="3">&nbsp;</th>
		<th><%=lang.getTranslated("backend.templates.view.table.label.attached_pages")%></th>
		<th><%=lang.getTranslated("backend.templates.view.table.label.page_priority")%></th>
		<th>&nbsp;</th>
		<th>&nbsp;</th>
		</tr>			
		<%		
		int pageCounter=0;
		foreach(TemplatePage z in template.pages)
		{
			string pathTemplatePart = z.filePath+z.fileName;
			string extension = Path.GetExtension(pathTemplatePart);
			bool doModify = true;
			if(".jpg"==extension || ".jpeg"==extension || ".bmp"==extension || ".png"==extension || ".gif"==extension){doModify = false;}
			%>
			<tr id="fileparttr_<%=z.id%>">
			<td style="width:20px;text-align:center;vertical-align:top;"><%if(doModify){%><img style="cursor:pointer;" id="edit_<%=pageCounter%>_<%=z.id%>" src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.modify_template")%>" hspace="2" vspace="0" border="0"><%}%></td>
			<td style="width:20px;text-align:center;vertical-align:top;"><%if(doModify){%><img style="cursor:pointer;" id="save_<%=pageCounter%>_<%=z.id%>" src="/backoffice/img/disk.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.save_template")%>" hspace="2" vspace="0" border="0"><%}%></td>
			<td style="width:20px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="delete_<%=pageCounter%>_<%=z.id%>" src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.delete_template")%>" hspace="2" vspace="0" border="0"></td>
			<td style="width:150px;vertical-align:top;"><%=z.fileName%></td>
			<td style="width:55px;text-align:center;vertical-align:top;">
			<div style="width:30px;text-align:right;">			
			<div class="ajax" id="view_priority_<%=pageCounter%>_<%=z.id%>" onmouseover="javascript:showHide('view_priority_<%=pageCounter%>_<%=z.id%>','edit_priority_<%=pageCounter%>_<%=z.id%>','priority_<%=pageCounter%>_<%=z.id%>',500, false);"><%if(z.priority>=0) {Response.Write(z.priority);}%></div>				
			</div>
			<div class="ajax" id="edit_priority_<%=pageCounter%>_<%=z.id%>"><input type="text" class="formfieldAjaxShort" id="priority_<%=pageCounter%>_<%=z.id%>" name="priority" onmouseout="javascript:restoreField('edit_priority_<%=pageCounter%>_<%=z.id%>','view_priority_<%=pageCounter%>_<%=z.id%>','priority_<%=pageCounter%>_<%=z.id%>','TemplatePage|ITemplateRepository|int|getPageById|updateTemplatePage',<%=z.id%>,1,<%=pageCounter%>);" value="<%=z.priority%>" maxlength="2" onkeypress="javascript:return isDouble(event);"></div>
			<script>
			$("#edit_priority_<%=pageCounter%>_<%=z.id%>").hide();
			</script>
			<td>&nbsp;</td>
			</td>  
			<td><div id="show_part_<%=pageCounter%>_<%=z.id%>"><form accept-charset="UTF-8" method="post" action=""><textarea name="text_part_<%=pageCounter%>_<%=z.id%>" id="text_part_<%=pageCounter%>_<%=z.id%>" class="formFieldTXTAREABig"></textarea></form></div></td>
			</tr>
			<script>
			$('#show_part_<%=pageCounter%>_<%=z.id%>').hide();
			$('#edit_<%=pageCounter%>_<%=z.id%>').click(function(){ajaxTemplateFilePart('<%="~/public/templates/"+pathTemplatePart%>', '', 'text_part_<%=pageCounter%>_<%=z.id%>', 'loadfile', 'show_part_<%=pageCounter%>_<%=z.id%>', '');});
			$('#save_<%=pageCounter%>_<%=z.id%>').click(function(){ajaxTemplateFilePart('<%="~/public/templates/"+pathTemplatePart%>', $('#text_part_<%=pageCounter%>_<%=z.id%>').val(), 'text_part_<%=pageCounter%>_<%=z.id%>', 'savefile', 'show_part_<%=pageCounter%>_<%=z.id%>', '');});
			$('#delete_<%=pageCounter%>_<%=z.id%>').click(function(){ajaxTemplateFilePart('<%="~/public/templates/"+pathTemplatePart%>', '', 'text_part_<%=pageCounter%>_<%=z.id%>', 'deletefile', 'show_part_<%=pageCounter%>_<%=z.id%>', '<%=z.id%>');});
			</script>
			<%pageCounter++;				
		}%>
		
		<tr id="attach_table_row<%=counter%>">
			<td colspan="7" class="attach_table_cell<%=counter%>">
			<form action="/backoffice/templates/templatelist.aspx" method="post" name="form_add_page<%=counter%>" enctype="multipart/form-data" accept-charset="UTF-8">
			<input type="hidden" value="addfile" name="operation">
			<input type="hidden" value="<%=template.id%>" name="templateid">
			<input type="hidden" value="LTP" name="cssClass">	
			<input type="file" name="fileupload<%=counter%>" id="fileupload<%=counter%>" class="formFieldTXT">
			<input type="text" value="<%=confservice.get("num_max_attachments").value%>" name="numMaxImgs" id="numMaxImgs<%=counter%>" class="formFieldTXTShortThin" onkeypress="javascript:return isInteger(event);">
			<a href="javascript:changeNumMaxImgs(<%=counter%>,<%=template.id%>);"><img src="/common/img/refresh.gif" vspace="0" hspace="4" border="0" align="top" title="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a>
			<input type="button" id="addfilebutt<%=counter%>" class="buttonForm" onclick="javascript:addFile(document.form_add_page<%=counter%>,<%=counter%>);" hspace="0" vspace="0" border="0" align="bottom" value="<%=lang.getTranslated("backend.templates.lista.button.label.insfile")%>" />
			<span id="loading-templ-page<%=counter%>"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:0px;padding-bottom:0px;"></span>
			</form>
			</td>
		</tr>
		<script>
		$("#loading-templ-page<%=counter%>").hide();
		</script>  		
		<tr><td colspan="6">&nbsp;</td></tr>
		</table>
		</td>
		</tr>			
	<%}%>
	</table>
<%}%>