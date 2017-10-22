<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertcategory.aspx.cs" Inherits="_Category" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertCategoria(){
	if(controllaCampiInput()){
		//document.form_inserisci.submit();
		$('#form_inserisci').submit();
	}else{
		return;
	}
}

$('#form_inserisci').submit(function() {
    $('#template_lang_cat').text($(this).serialize());
    return false;
});

function controllaCampiInput(){		
	if(document.form_inserisci.num_menu.value == ""){
		alert("<%=lang.getTranslated("backend.categorie.detail.js.alert.insert_num_menu")%>");		
		document.form_inserisci.num_menu.focus();
		return false;
	}
	
	if(document.form_inserisci.hierarchy.value == ""){
		alert("<%=lang.getTranslated("backend.categorie.detail.js.alert.insert_gerarchia")%>");		
		document.form_inserisci.hierarchy.focus();
		return false;
	}
	
	if(!checkGerarchiaFormat(document.form_inserisci.hierarchy.value)){
		alert("<%=lang.getTranslated("backend.categorie.detail.js.alert.insert_correct_gerarchia")%>");		
		document.form_inserisci.hierarchy.focus();
		return false;
	}
	
	if(document.form_inserisci.description.value == ""){
		alert("<%=lang.getTranslated("backend.categorie.detail.js.alert.insert_description")%>");
		document.form_inserisci.description.focus();
		return false;
	}
	
	if(document.form_inserisci.id.value == "0" || document.form_inserisci.id.value == "-1" || document.form_inserisci.id.value == ""){
		if(confirm("<%=lang.getTranslated("backend.categorie.detail.js.alert.confirm_set_target_to_user")%>")){
			document.form_inserisci.set_to_users.value = 1;
		}
	}
		
	return true;
}

function replaceChars(inString){
	var outString = inString;

	for(a = 0; a < outString.length; a++){
		if(outString.charAt(a) == '"'){
			outString=outString.substring(0,a) + "&quot;" + outString.substring(a+1, outString.length);
		}
	}
	return outString;
}

function addParentCat(gerarchiaParent){
	var gerParent = gerarchiaParent.value;
	document.form_inserisci.hierarchy.value = gerParent + ".";
}


function checkGerarchiaFormat(field){
	var fieldVal = field;	
	/*alert("fieldVal: " + fieldVal);
	
	var expr1 = /^\d+,\d+$/;
	var expr2 = /^\d+$/;
			
	var expr3 = /(^\d$)|(^\d,\d$)|(^10$)|(^10,0$)/;
	var expr4 = /(^\d{4}\/([1-9]|10|11|12)$)/;
	var expr5 = /^[0-9]$/*/
	
	var expr = /(^\d+$)|(^\d+\.\d+$)|(\.\d+$)/
	var ok = expr.test(fieldVal);
	//alert("ok: " + ok);
	
	
	/*
	var exprA0 = /^\d$/;
	var exprA1 = /^\d,\d$/;
	var exprA2 = /^10$/;
	var exprA3 = /^10,0$/;
	
	ar ok = exprA0.test(fieldVal);
	alert("ok0: " + ok);	
	ok = (ok || exprA1.test(fieldVal));		
	alert("ok1: " + ok);
	ok = (ok || exprA2.test(fieldVal));
	alert("ok2: " + ok);
	ok = (ok || exprA3.test(fieldVal));
	alert("ok3: " + ok);
	
	alert("ok: " + ok);	
	*/
	
	return ok;
}

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	});
})

function showDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;

	element.style.left=tempX+10;
	element.style.top=tempY+10;
	$(jquery_id).show(500);
	element.style.visibility = 'visible';		
	element.style.display = "block";
}

function hideDiv(elemID){
	var element = document.getElementById(elemID);

	element.style.visibility = 'hidden';
	element.style.display = "none";
}

function loadUrlRewrite(catid,templateid){
	var query_string = "id="+catid+"&templateid="+templateid;	
	//alert(query_string);

	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/categories/ajaxurlrewrite.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#template_lang_cat').empty();
			$('#template_lang_cat').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#template_lang_cat').hide();
			$('#template_lang_cat').empty();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.num_menu.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<form action="/backoffice/categories/insertcategory.aspx" method="post" name="form_inserisci" id="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
			<table border="0" cellspacing="0" cellpadding="0" class="principal">
		  <input type="hidden" value="<%=category.id%>" name="id">
		  <input type="hidden" value="insert" name="operation">
		  <input type="hidden" value="0" name="set_to_users">
		  <input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">			
			<tr> 		  		  
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.num_menu")%></span><br/>
				<input type="text" name="num_menu" value="<%=category.numMenu%>" maxlength="2" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);">			  
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top" width="30%">			  
			  <span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.parent_cat")%></span><br/>
			<select name="parent_cat" class="formFieldTXT" onchange="javascript:addParentCat(this);">
			<option value=""></option>
			<%
			string iParentHierarchy;
			if(category != null && !String.IsNullOrEmpty(category.hierarchy) && category.hierarchy.LastIndexOf (".")>0) {iParentHierarchy = category.hierarchy.Substring(0,category.hierarchy.LastIndexOf ("."));}else{ iParentHierarchy = "-1";}			
			foreach(Category cat in categories){%>
				<option value="<%=cat.hierarchy%>" <%if (String.Compare (cat.hierarchy,iParentHierarchy)==0) { Response.Write("selected");}%>><%=cat.hierarchy+"&nbsp;&nbsp;("+cat.description+")"%></option>
			<%}%>
			</select></td>			  
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top"><span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.gerarchia")%></span><br/>
			    <input class="formFieldTXT" type="text" name="hierarchy" value="<%=category.hierarchy%>" onkeypress="javascript:return isDecimal(event);">
				</td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 		  		  
			<td align="left" valign="top" width="25%">
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.description")%></span><br/>
			<input type="text" name="description" value="<%=category.description%>" class="formFieldTXT"><a href="javascript:showHideDiv('description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
			<!--
			&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc');" class="labelForm" onmouseout="javascript:hideDiv('help_desc');">?</a>
			<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc">
			<%//=lang.getTranslated("backend.categorie.detail.table.label.field_help_desc")%>
			</div>
			-->
			<br/>
			<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="description_ml">
			<%
			foreach (Language x in languages){%>
			<input type="text" hspace="2" vspace="2" name="description_<%=x.label%>" id="description_<%=x.label%>" value="<%=mlangrep.translate("backend.categorie.detail.table.label.description_"+category.hierarchy, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>			
			
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.summary")%></span><br/>
			<%foreach (Language x in languages){%>
			<input type="text" name="summary_<%=x.label%>" id="summary_<%=x.label%>" value="<%=mlangrep.translate("backend.categorie.detail.table.label.summary_"+category.hierarchy, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>			
			
			</div>
		  	</td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
			  <span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.fileupload")%></span><br/>
			  <input type="file" name="category_image" />
				<%if(!String.IsNullOrEmpty(category.filePath)){%>
					<br/><img class="category_image" align="top"  src="<%="/public/upload/files/categories/"+category.id+"/"+category.filePath%>" />
					&nbsp;<input type="checkbox" class="category_image_checkbox" value="1" name="del_catimage">&nbsp;<%=lang.getTranslated("frontend.area_user.manage.label.del_catimage")%>
				<%}%>
			  </td>			  
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top">
			  <div style="float:left;padding-right:30px;">
			  <span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.visibile")%></span><br/>
			  <select name="visible" class="formFieldTXTShort">
			  <option value="1" <%if (category.visible) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
			  <option value="0" <%if (!category.visible) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
			</select>	
			</div>
			<div>
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.automatic")%></span><br/>
			<select name="automatic" class="formFieldTXTShort">
			<option value="1" <%if (category.automatic) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
			<option value="0" <%if (!category.automatic) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
			</select>		
			</div>
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="left" valign="top">
			  <span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.contiene_news")%></span><br/>
				<select name="has_elements" class="formFieldTXTShort">
					<option value="1" <%if (category.hasElements) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
					<option value="0" <%if (!category.hasElements) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
				</select>	    
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
				  	<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.page_title")%></span><br/>
				<input type="text" name="page_title" value="<%=HttpUtility.HtmlEncode(category.pageTitle)%>" class="formFieldTXT">
				<a href="javascript:showHideDiv('page_title_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
			<br/>
				<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="page_title_ml">
				<%foreach (Language x in languages){%>
				<input type="text" hspace="2" vspace="2" name="page_title_<%=x.label%>" id="page_title_<%=x.label%>" value="<%=mlangrep.translate("backend.categorie.detail.table.label.page_title_"+category.hierarchy, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
				&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>				  
			  </td>
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.meta_description")%></span><br/>
			    <input type="text" name="meta_description" value="<%=HttpUtility.HtmlEncode(category.metaDescription)%>" class="formFieldTXT">
				<a href="javascript:showHideDiv('meta_description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
			<br/>
				<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="meta_description_ml">
				<%foreach (Language x in languages){%>
				<input type="text" hspace="2" vspace="2" name="meta_description_<%=x.label%>" id="meta_description_<%=x.label%>" value="<%=mlangrep.translate("backend.categorie.detail.table.label.meta_description_"+category.hierarchy, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
				&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>			  
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.meta_keyword")%></span><br/>
			    <input type="text" name="meta_keyword" value="<%=HttpUtility.HtmlEncode(category.metaKeyword)%>" class="formFieldTXT">
				<a href="javascript:showHideDiv('meta_keyword_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>
			<br/>
				<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="meta_keyword_ml">
				<%foreach (Language x in languages){%>
				<input type="text" hspace="2" vspace="2" name="meta_keyword_<%=x.label%>" id="meta_keyword_<%=x.label%>" value="<%=mlangrep.translate("backend.categorie.detail.table.label.meta_keyword_"+category.hierarchy, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
				&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
				<%}%>					
				</div>
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.categorie.detail.table.label.url_subdomain")%></span><br/>
			<input type="text" name="url_subdomain" value="<%=category.subDomainUrl%>" class="formFieldTXTLong">
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
			  
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>			
			<tr> 
			  <td align="left" valign="top" class="special"><span class="labelForm"><%=lang.getTranslated("backend.categorie.lista.table.header.template_id")%></span><br/>
			<select name="id_template" id="id_template" class="formFieldTXT">
			  <option value="-1"></option>
			  <%foreach(Template t in templates){%>
			  <option value="<%=t.id%>" <%if (t.id==category.idTemplate) {Response.Write("selected");}%>><%=t.description%></option>
			  <%}%>
			</select></td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top" colspan="3" class="special">
				<div id="template_lang_cat"></div>&nbsp;
			  </td>
			</tr>
			<script language="JavaScript">
			$('#id_template').change(function() {
				var id_template_val_ch = $('#id_template').val();
				if(id_template_val_ch!=-1){				
					$("#template_lang_cat").show();		
					loadUrlRewrite(<%=category.id%>,id_template_val_ch);
				}else{
					$("#template_lang_cat").hide();				
				}
			});

			jQuery(document).ready(function(){
				<%if(category.id>-1){%>
				loadUrlRewrite(<%=category.id%>,<%=category.idTemplate%>);
				<%}%>
	
				var id_template_val = $('#id_template').val();
				if(id_template_val!=-1){
					$("#template_lang_cat").show();
				}else{
					$("#template_lang_cat").hide();			
				}
			})
			</script>
			</table>
			</form>	
			<br/>	    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.categorie.detail.button.inserisci.label")%>" onclick="javascript:insertCategoria();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/categories/categorylist.aspx?cssClass=LCE';" />
		  <br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>