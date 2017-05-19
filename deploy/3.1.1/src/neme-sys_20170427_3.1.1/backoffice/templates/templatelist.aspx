<%@ Page Language="C#" AutoEventWireup="true" CodeFile="templatelist.aspx.cs" Inherits="_TemplateList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/backoffice/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function deleteTemplate(id_objref, row, refreshrows, directory){
	if(confirm("<%=lang.getTranslated("backend.templates.lista.js.alert.confirm_delete_template")%>")){
/*<!--nsys-demoedittmp1-->*/		
		ajaxDeleteItem(id_objref,"Template|ITemplateRepository|com.nemesys.services.TemplateService|deleteTemplateDirectory|static|"+directory,row,refreshrows);
		$('#view_template_'+row.substring(row.indexOf("tr_delete_list_")+15)).hide();
/*<!---nsys-demoedittmp1-->*/		
	}
}

function changeRowListData(listCounter, objtype, field){
	objtype = objtype.substring(0,objtype.indexOf("|"));
	
	if(objtype=="Template"){
		var base = $("#base_"+listCounter).val();
		var render = "";

		if(base==1){
			render +=('<img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.cant_delete")%>" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.cant_delete")%>" hspace="2" vspace="0" border="0">');
		}else{
			render +='<a href="';
			render+="javascript:deleteTemplate("+eval("document.form_lista_"+listCounter+".id.value")+",'tr_delete_list_"+listCounter+"','tr_delete_list_');";
			render+='">';
			render +=('<img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.cant_delete")%>" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.cant_delete")%>" hspace="2" vspace="0" border="0">');
			render +=('</a>');
		}
		
		$("#cancel_"+listCounter).empty();
		$("#cancel_"+listCounter).append(render);
	}
}

function confirmClone(theForm){
	if(confirm("<%=lang.getTranslated("backend.templates.lista.js.alert.confirm_clone_template")%>")){
/*<!--nsys-demoedittmp2-->*/
		theForm.submit();
/*<!---nsys-demoedittmp2-->*/
	}
}

function ajaxTemplateFile(path, content, textarea, command, container){
/*<!--nsys-demoedittmp3-->*/
	var dataString;

	// seleziono il comando da eseguire
	switch(command) {
		case "loadfile":
			$('#message').empty();
			if($('#'+container).css("display")=="none"){
				dataString = 'filepath='+ path + '&command=' + command;  
				$.ajax({  
					type: "POST",  
					url: "/backoffice/templates/ajaxtemplatefile.aspx",  
					data: dataString,  
					success: function(response) {  
						$('#'+textarea).val(response);			
					},
					error: function() {
						$('#message').html("<%=lang.getTranslated("backend.commons.fail_updated_file")%>");
						$('#message').fadeIn();
						$('#message').fadeOut(4000);
					}
				}); 
			}else{
				$('#'+textarea).val();
			}
			$('#'+container).slideToggle();
			break; //si ferma qui

		case "savefile":		
			$('#message').empty();
			if($('#'+container).css("display")!="none"){
				if(confirm("<%=lang.getTranslated("backend.templates.lista.js.alert.confirm_save_file")%>")){
					dataString = 'filepath=' + path + '&command=' + command + '&content=' + encodeURIComponent(content);  
					//alert (dataString);
					$.ajax({  
						type: "POST",  
						url: "/backoffice/templates/ajaxtemplatefile.aspx",  
						data: dataString,  
						success: function(response) {
							$('#'+container).hide();	  
							$('#message').html("<%=lang.getTranslated("backend.commons.ok_updated_file")%>"); 
							$('#message').fadeIn();
							$('#message').fadeOut(4000);
							$('#'+textarea).val();			
						},
						error: function() {
							$('#message').html("<%=lang.getTranslated("backend.commons.fail_updated_file")%>");
							$('#message').fadeIn();
							$('#message').fadeOut(4000);
						}
					}); 
				}
			}
			break; //si ferma qui

		default:
			//istruzioni
	}	
/*<!---nsys-demoedittmp3-->*/
	return false; 	
}

function ajaxTemplateFilePart(path, content, textarea, command, container, fileid){
/*<!--nsys-demoedittmp4-->*/
	var dataString;

	// seleziono il comando da eseguire
	switch(command) {
		case "loadfile":
			if($('#'+container).css("display")=="none"){
				dataString = 'filepath='+ path + '&command=' + command;  
				$.ajax({  
					type: "POST",  
					url: "/backoffice/templates/ajaxtemplatefile.aspx",  
					data: dataString,  
					success: function(response) {  
						$('#'+textarea).val(response);			
					}
				}); 
			}else{
				$('#'+textarea).val();
			}
			$('#'+container).slideToggle();
			break; //si ferma qui

		case "savefile":	
			if($('#'+container).css("display")!="none"){
				if(confirm("<%=lang.getTranslated("backend.templates.lista.js.alert.confirm_save_file")%>")){	
					dataString = 'filepath='+ path + '&command=' + command + '&content=' + encodeURIComponent(content);  
					//alert (dataString);
					$.ajax({  
						type: "POST",  
						url: "/backoffice/templates/ajaxtemplatefile.aspx",  
						data: dataString,  
						success: function(response) {
							$('#'+container).hide();	  
							$('#'+textarea).val();			
						}
					}); 
				}
			}
			break; //si ferma qui

		case "deletefile":
			if(confirm("<%=lang.getTranslated("backend.templates.lista.js.alert.confirm_delete_file")%>")){			
				dataString = 'filepath=' + path + '&command=' + command + '&fileid='+fileid;  
				//alert (dataString);
				$.ajax({  
					type: "POST",  
					url: "/backoffice/templates/ajaxtemplatefile.aspx",  
					data: dataString,  
					success: function(response) {
						$('#'+container).hide();	  
						$('#'+textarea).val();
						$('#fileparttr_'+fileid).remove();					
					}
				});
			} 
			break; //si ferma qui

		default:
			//istruzioni
	}	
/*<!---nsys-demoedittmp4-->*/
	return false; 	
}

function ajaxViewZoom(id_template, container, counter){
	var dataString;

	if($('#'+container).css("display")=="none"){
		dataString = 'id='+ id_template+"&counter="+counter; 
		
		$('#view_zoom_'+counter).hide();
		$('#loading_zoom_'+counter).show();
		
		$.ajax({  
			type: "POST",  
			url: "/backoffice/templates/ajaxviewtemplate.aspx",  
			data: dataString,  
			success: function(response) {  
				$('#'+container).html(response); 
				$('#view_zoom_'+counter).show();
				$('#loading_zoom_'+counter).hide(); 			
			},
			error: function(response) {
				$('#view_zoom_'+counter).show();
				$('#loading_zoom_'+counter).hide(); 
			}
		}); 
	}else{
		$('#'+container).empty();
	}
	$('#'+container).slideToggle();	

	return false; 	
}

function sendForm(){
	if(controllaCampiInput()){
		$("#loading-templatebutt").hide();
		$("#loading-template").show();
		document.form_inserisci.submit();
	}else{
		return;
	}
}
function controllaCampiInput(){
	if(document.form_inserisci.description.value == ""){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.insert_description")%>");
		document.form_inserisci.description.focus();
		return false;
	}
	
	if(document.form_inserisci.directory.value == ""){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.insert_directory_name")%>");
		document.form_inserisci.directory.focus();
		return false;
	}else if(document.form_inserisci.directory.value.indexOf(" ") != -1 || document.form_inserisci.directory.value.indexOf(",") != -1 || document.form_inserisci.directory.value.indexOf(";") != -1){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.dont_use_special_char")%>");
		document.form_inserisci.directory.value = "";
		document.form_inserisci.directory.focus();
		return false;		
	}	

	return true;
}

function changeNumMaxImgs(counter, templid){
	if($("#numMaxImgs"+counter).val() == ""){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.insert_value")%>");
		$("#numMaxImgs"+counter).focus();
		return;
	}else if(isNaN($("#numMaxImgs"+counter).val())){
		alert("<%=lang.getTranslated("backend.templates.detail.js.alert.isnan_value")%>");
		$("#numMaxImgs"+counter).focus();
		return;		
	}
	renderNumImgsTable($("#numMaxImgs"+counter).val(), counter, templid);
}

function renderNumImgsTable(counter, refid, templid){
	$("#attach_table_row"+refid).empty();
	
	var render ="";

	render=render+'<td colspan="7" class="attach_table_cell'+refid+'">';
	render=render+'<form action="/backoffice/templates/templatelist.aspx" method="post" name="form_add_page'+refid+'" enctype="multipart/form-data" accept-charset="UTF-8">';
	render=render+'<input type="hidden" value="addfile" name="operation">';
	render=render+'<input type="hidden" value="'+templid+'" name="templateid">';	
	for(var i=1;i<=counter;i++){
			render=render+'<input type="file" name="fileupload'+refid+i+'" id="fileupload'+refid+i+'" class="formFieldTXT">';
			if(i==1){
			render=render+'<input type="text" value="'+counter+'" name="numMaxImgs" id="numMaxImgs'+refid+'" class="formFieldTXTShortThin" onkeypress="javascript:return isInteger(event);"><a href="javascript:changeNumMaxImgs('+refid+','+templid+');"><img src="/common/img/refresh.gif" vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.change_num_imgs")%>"></a>';
			render=render+'<input type="button" id="addfilebutt'+refid+'" class="buttonForm" onclick="javascript:addFile(document.form_add_page'+refid+');" hspace="0" vspace="0" border="0" align="bottom" value="<%=lang.getTranslated("backend.templates.lista.button.label.insfile")%>" />';
			render=render+'<span id="loading-templ-page'+refid+'"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:0px;padding-bottom:0px;"></span>';
			}
			render=render+'<br/>';
	}
	render=render+'</form>';
	render=render+'</td><script>';
	render=render+'$("#loading-templ-page'+refid+'").hide()';
	render=render+'<\/script>';

	$("#attach_table_row"+refid).append(render);

}

function addFile(thForm, refid){
	$("#addfilebutt"+refid).hide();
	$("#loading-templ-page"+refid).show();
	thForm.submit();	
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<div style="font-weight:bold;float:left;padding-right:5px;padding-top:20px;padding-bottom:20px;width:60px;vertical-align:top;height:40px;">
		<%=lang.getTranslated("backend.templates.lista.download_template_example")%>
		</div>
		<div style="float:left;padding-right:50px;padding-top:20px;padding-bottom:20px;width:40px;vertical-align:top;height:40px;display:inline;">
		<a href="/public/utils/templates_neme-sys.zip"><img src="/common/img/iconaZip.gif" title="<%=lang.getTranslated("backend.templates.lista.download_template_example")%>" hspace="2" vspace="0" border="0" align="right"></a>
		</div>
		<div style="display:block;padding-top:15px;vertical-align:top;">
			<form action="/backoffice/templates/templatelist.aspx" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			<input type="hidden" value="-1" name="id">
			<input type="hidden" value="insert" name="operation">		
			<div style="float:left;padding-right:5px;padding-top:18px;">
			<input type="button" id="loading-templatebutt" class="buttonForm" onclick="javascript:sendForm();" hspace="0" vspace="0" border="0" align="bottom" value="<%=lang.getTranslated("backend.templates.lista.button.label.inserisci")%>" />
			<span id="loading-template"><img src="/common/img/loading_icon2.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:0px;padding-bottom:0px;"></span>
			<script>
			$("#loading-template").hide();
			</script>
			</div>
			<div style="float:left;padding-right:5px;">
			<span class="labelForm"><%=lang.getTranslated("backend.templates.lista.table.header.descrizione")%></span><br/>
			<input class="formFieldTXT" type="text" name="description" value="">
			</div>
			<div style="float:left;padding-right:5px;">
			<span class="labelForm"><%=lang.getTranslated("backend.templates.lista.table.header.template_dir")%></span><br/>
			<input class="formFieldTXT" type="text" name="directory" value="" onkeypress="javascript:return notSpecialCharButUnderscoreAndMinus(event);">
			</div>
			<div>
			<span class="labelForm"><%=lang.getTranslated("backend.templates.lista.table.header.filename")%></span><br/>
			<input id="template_body" type="file" runat="server">
			</div>
			</form>
		</div>

		<form action="/backoffice/templates/templatelist.aspx" method="post" name="form_delete">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">
		<input type="hidden" value="-1" name="templateid">
		<input type="hidden" value="" name="directory">
		<input type="hidden" value="delete" name="operation">
		</form>
		
		<div class="treeview">		
		<span id="message" class="error"></span>
		<br/>		
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>		
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr> 
				<th colspan="6" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
				</div>
				</th>
			</tr>
			<tr nowrap> 
				<th colspan="3">&nbsp;</th>
				<th><lang:getTranslated keyword="backend.templates.lista.table.header.descrizione" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.templates.lista.table.header.template_dir" runat="server" /></th>
				<th>&nbsp;</th>
			</tr>			  
				<%int intCount = 0;				
				if(bolFoundLista){
					foreach (Template k in templates){%>
						<form action="/backoffice/templates/templatelist.aspx" method="post" name="form_lista_<%=intCount%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">
						</form>	
						<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
						<td align="center" width="25"><img style="cursor:pointer;" id="clone_zoom_<%=intCount%>" src="/backoffice/img/page_white_copy.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.clone")%>" hspace="2" vspace="0" border="0"></td>
						<td align="center" width="25">
						<img style="cursor:pointer;" id="view_zoom_<%=intCount%>" src="/backoffice/img/zoom.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.view")%>" hspace="2" vspace="0" border="0">
						<img style="display:none" id="loading_zoom_<%=intCount%>" src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
						</td>
						<%if(!k.isBase){%>
						<td align="center" width="25" id="cancel_<%=intCount%>"><a href="javascript:deleteTemplate(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_', '<%=k.directory%>');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.templates.lista.table.alt.delete_template")%>" hspace="2" vspace="0" border="0"></a></td>
						<%}else{%>
						<td align="center" width="25" id="cancel_<%=intCount%>"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.cant_delete")%>" hspace="2" vspace="0" border="0"></td>
						<%}%>
						<td nowrap width="30%">					
						<div class="ajax" id="view_description_<%=intCount%>" onmouseover="javascript:showHide('view_description_<%=intCount%>','edit_description_<%=intCount%>','description_<%=intCount%>',500, false);"><%=k.description%></div>
						<div class="ajax" id="edit_description_<%=intCount%>"><input type="text" class="formfieldAjaxLong" id="description_<%=intCount%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=intCount%>','view_description_<%=intCount%>','description_<%=intCount%>','Template|ITemplateRepository|string',<%=k.id%>,1,<%=intCount%>);" value="<%=k.description%>"></div>
						<script>
						$("#edit_description_<%=intCount%>").hide();
						</script>
						</td>
						<td nowrap width="30%"><%=k.directory%></td>
						<td>&nbsp;</td>
						</tr>
						
						<tr class="preview_row">
						<td colspan="8">
						<div id="view_template_<%=intCount%>"></div>						
						<div id="clone_template_<%=intCount%>">
						<form action="/backoffice/templates/clonetemplate.aspx" method="post" name="form_clone_<%=intCount%>">
						<input type="hidden" value="<%=k.id%>" name="id_template">
						<input type="text" class="formfieldAjaxLong" name="new_dir_template" onkeypress="javascript:return notSpecialCharButUnderscoreAndMinus(event);">
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.templates.lista.button.label.inserisci_dir")%>" onclick="javascript:confirmClone(document.form_clone_<%=intCount%>);" />
						</form>
						</div>
						<script>
						$("#view_template_<%=intCount%>").hide();
						$("#clone_template_<%=intCount%>").hide();
						$('#view_zoom_<%=intCount%>').click(function(){$('#clone_template_<%=intCount%>').hide();ajaxViewZoom('<%=k.id%>', 'view_template_<%=intCount%>',<%=intCount%>);});
						$('#clone_zoom_<%=intCount%>').click(function(){$('#view_template_<%=intCount%>').hide();$('#clone_template_<%=intCount%>').slideToggle();});
						</script>
						</td>
						</tr>						
						<%intCount++;
					}
				}%>
				  
				<tr> 
					<th colspan="6" align="left">
					<div style="float:left;padding-right:3px;height:15px;">
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					<input type="hidden" value="1" name="page">	
					<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
					</form>
					</div>
					<div style="height:15px;">
					<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
					</div>
					</th>
		      	</tr>
		</table>

		<br/>		

		<table class="secondary" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr nowrap>
			<th style="text-align:center;width:25px;vertical-align:top;"><img style="cursor:pointer;" id="view_widget_files" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.view")%>" hspace="2" vspace="0" border="0"></th>
			<th style="text-align:left;vertical-align:top;"><%=lang.getTranslated("backend.templates.lista.table.header.widget_files")%></th>
		    </tr>
		</table>
		<div id="widget_files" style="display:none;">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<%
			intCount = 0;
			string prefix="-wf-";
			IDictionary<string, string> elementsMap = new Dictionary<string, string>();
			string treeRoot = "/public/layout/addson/";
			TemplateService.generateTree(treeRoot, elementsMap);

			foreach(string elem in elementsMap.Keys)
			{
				string elemId = elem.Substring(0,elem.IndexOf('.'))+prefix+intCount; %>			
				<tr nowrap> 
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="edit_<%=elemId%>" src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.modify_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="save_<%=elemId%>" src="/backoffice/img/disk.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.save_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/folder.gif" hspace="2" border="0" />&nbsp;<%=elementsMap[elem]%></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/file.gif" hspace="2" border="0" />&nbsp;<%=elem%></td>
					<td><div id="show_<%=elemId%>"><form accept-charset="UTF-8" method="post" action=""><textarea name="text_<%=elemId%>" id="text_<%=elemId%>" class="formFieldTXTAREABig"></textarea></form></div></td>
				</tr>
				<script>
				$('#show_<%=elemId%>').hide();
				$('#edit_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', '', 'text_<%=elemId%>', 'loadfile', 'show_<%=elemId%>');});
				$('#save_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', $('#text_<%=elemId%>').val(), 'text_<%=elemId%>', 'savefile', 'show_<%=elemId%>');});
				</script>
			<%intCount++;
			}%>
		</table>
		</div>
		<script>
		$('#widget_files').hide();
		$('#view_widget_files').click(function(){$('#widget_files').slideToggle();});
		</script>
		<table class="secondary" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr nowrap> 
			<th style="text-align:center;width:25px;vertical-align:top;"><img style="cursor:pointer;" id="view_area_user_files" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.view")%>" hspace="2" vspace="0" border="0"></th>
			<th style="text-align:left;vertical-align:top;"><%=lang.getTranslated("backend.templates.lista.table.header.area_user_files")%></th>
		    </tr>
		</table>
		<div id="area_user_files" style="display:none;">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">	
			<%
			intCount = 0;
			prefix="-uf-";
			elementsMap = new Dictionary<string, string>();
			treeRoot = "/public/layout/area_user/";
			TemplateService.generateTree(treeRoot, elementsMap);

			foreach(string elem in elementsMap.Keys)
			{
				string elemId = elem.Substring(0,elem.IndexOf('.'))+prefix+intCount;%>			
				<tr nowrap> 
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="edit_<%=elemId%>" src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.modify_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="save_<%=elemId%>" src="/backoffice/img/disk.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.save_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/folder.gif" hspace="2" border="0" />&nbsp;<%=elementsMap[elem]%></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/file.gif" hspace="2" border="0" />&nbsp;<%=elem%></td>
					<td><div id="show_<%=elemId%>"><form accept-charset="UTF-8" method="post" action=""><textarea name="text_<%=elemId%>" id="text_<%=elemId%>" class="formFieldTXTAREABig"></textarea></form></div></td>
				</tr>
				<script>
				$('#show_<%=elemId%>').hide();
				$('#edit_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', '', 'text_<%=elemId%>', 'loadfile', 'show_<%=elemId%>');});
				$('#save_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', $('#text_<%=elemId%>').val(), 'text_<%=elemId%>', 'savefile', 'show_<%=elemId%>');});
				</script>
			<%intCount++;
			}%>
		</table>
		</div>
		<script>
		$('#area_user_files').hide();
		$('#view_area_user_files').click(function(){$('#area_user_files').slideToggle();});
		</script>
		<table class="secondary" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr nowrap> 
			<th style="text-align:center;width:25px;vertical-align:top;"><img style="cursor:pointer;" id="view_css_files" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.view")%>" hspace="2" vspace="0" border="0"></th>
			<th style="text-align:left;vertical-align:top;"><%=lang.getTranslated("backend.templates.lista.table.header.css_files")%></th>
		    </tr>
		</table>
		<div id="css_files" style="display:none;">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">	
			<%
			intCount = 0;
			prefix="-cf-";
			elementsMap = new Dictionary<string, string>();
			treeRoot = "/public/layout/css/";
			TemplateService.generateTree(treeRoot, elementsMap);

			foreach(string elem in elementsMap.Keys)
			{
				string elemId = elem.Substring(0,elem.IndexOf('.'))+prefix+intCount;%>			
				<tr nowrap> 
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="edit_<%=elemId%>" src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.modify_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="save_<%=elemId%>" src="/backoffice/img/disk.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.save_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/folder.gif" hspace="2" border="0" />&nbsp;<%=elementsMap[elem]%></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/file.gif" hspace="2" border="0" />&nbsp;<%=elem%></td>
					<td><div id="show_<%=elemId%>"><form accept-charset="UTF-8" method="post" action=""><textarea name="text_<%=elemId%>" id="text_<%=elemId%>" class="formFieldTXTAREABig"></textarea></form></div></td>
				</tr>
				<script>
				$('#show_<%=elemId%>').hide();
				$('#edit_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', '', 'text_<%=elemId%>', 'loadfile', 'show_<%=elemId%>');});
				$('#save_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', $('#text_<%=elemId%>').val(), 'text_<%=elemId%>', 'savefile', 'show_<%=elemId%>');});
				</script>
			<%intCount++;
			}%>
		</table>
		</div>
		<script>
		$('#css_files').hide();
		$('#view_css_files').click(function(){$('#css_files').slideToggle();});
		</script>
		<table class="secondary" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr nowrap> 
			<th style="text-align:center;width:25px;vertical-align:top;"><img style="cursor:pointer;" id="view_include_files" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.view")%>" hspace="2" vspace="0" border="0"></th>
			<th style="text-align:left;vertical-align:top;"><%=lang.getTranslated("backend.templates.lista.table.header.include_files")%></th>
		    </tr>
		</table>
		<div id="include_files" style="display:none;">
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">	
			<%
			intCount = 0;
			prefix="-if-";
			elementsMap = new Dictionary<string, string>();
			treeRoot = "/public/layout/include/";
			TemplateService.generateTree(treeRoot, elementsMap);

			foreach(string elem in elementsMap.Keys)
			{
				string elemId = elem.Substring(0,elem.IndexOf('.'))+prefix+intCount;%>			
				<tr nowrap> 
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="edit_<%=elemId%>" src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.modify_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="width:25px;text-align:center;vertical-align:top;"><img style="cursor:pointer;" id="save_<%=elemId%>" src="/backoffice/img/disk.png" alt="<%=lang.getTranslated("backend.templates.lista.table.alt.save_template")%>" hspace="2" vspace="0" border="0"></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/folder.gif" hspace="2" border="0" />&nbsp;<%=elementsMap[elem]%></td>
					<td style="text-align:left;vertical-align:top;width:25%;" valign="top"><img src="img/file.gif" hspace="2" border="0" />&nbsp;<%=elem%></td>
					<td><div id="show_<%=elemId%>"><form accept-charset="UTF-8" method="post" action=""><textarea name="text_<%=elemId%>" id="text_<%=elemId%>" class="formFieldTXTAREABig"></textarea></form></div></td>
				</tr>
				<script>
				$('#show_<%=elemId%>').hide();
				$('#edit_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', '', 'text_<%=elemId%>', 'loadfile', 'show_<%=elemId%>');});
				$('#save_<%=elemId%>').click(function(){ajaxTemplateFile('<%=elementsMap[elem]+elem%>', $('#text_<%=elemId%>').val(), 'text_<%=elemId%>', 'savefile', 'show_<%=elemId%>');});
				</script>
			<%intCount++;
			}%>
		</table>
		</div>
		<script>
		$('#include_files').hide();
		$('#view_include_files').click(function(){$('#include_files').slideToggle();});
		</script>
		</div>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>
