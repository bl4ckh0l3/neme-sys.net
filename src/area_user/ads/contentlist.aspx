<%@ Page Language="C#" AutoEventWireup="true" CodeFile="contentlist.aspx.cs" Inherits="_FeContentList" Debug="false" ValidateRequest="false"%>
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
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/common/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="3" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script>
/*<!--nsys-usr-lnews1-->*/
function createAds(id){
	location.href='<%=secureURL%>area_user/ads/insertads.aspx?contentid='+id;
}
/*<!---nsys-usr-lnews1-->*/

function deleteContent(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.contenuti.detail.js.alert.confirm_del_news")%>?")){	
		ajaxDeleteItem(id_objref,"FContent|IContentRepository|com.nemesys.services.CommonService|deleteDirectory|static|"+id_objref,row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
	}
}

function editContent(id){
	location.href='<%=secureURL%>area_user/ads/insertcontent.aspx?cssClass=LN&id='+id;
}

function sortContentParam(val){
	document.content_sort.order_by.value = val;
	document.content_sort.submit();	
}

function sendAjaxCommand(field_name, field_val, objtype, id_objref, listCounter, field){
	var query_string = "field_name="+field_name+"&field_val="+encodeURIComponent(field_val)+"&objtype="+objtype+"&id_objref="+id_objref;
	//alert("query_string: "+query_string);
	var resp = false;

	$.ajax({
		async: false,
		type: "GET",
		cache: false,
		url: "<%=secureURL%>area_user/ads/ajaxupdate.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.ok_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = true;

			// il codice seguente server per inviare il contatore dell'oggetto modificato nella lista
			// per chiamare la funzione specifica di ogni pagina, per modificare elementi della pagina accessori
			if(typeof changeRowListData == 'function'){				
				changeRowListData(listCounter, objtype, field);
			}
		},
		error: function (response) {
			/*var r = jQuery.parseJSON(response.responseText);
			alert("Message: " + r.Message);
			alert("StackTrace: " + r.StackTrace);
			alert("ExceptionType: " + r.ExceptionType);*/
			//alert("error: "+response.responseText);
			$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");
			resp = false;
		}
	});

	return resp;
}


function ajaxDeleteItem(id_objref,objtype,row,refreshrows){
	var query_string = "id_objref="+id_objref+"&objtype="+objtype;
	
	$.ajax({
		async: false,
		type: "GET",
		cache: false,
		url: "<%=secureURL%>area_user/ads/ajaxdelete.aspx",
		data: query_string,
		success: function(response) {
			var classon = "table-list-on";
			var classoff = "table-list-off";
			var counter = 1;

			$('#'+row).remove();	
			
			$("tr[id*='"+refreshrows+"']").each(function(){
				if(counter % 2 == 0){
					$(this).attr("class",classoff);
				}else{
					$(this).attr("class",classon);
				}
				counter+=1;
			});
		},
		error: function() {
			$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_delete_item")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");
		}
	});
}


var field_lock = false;
var has_focus = false;
var orig_val;
function showHide(fieldHide, fieldShow, field, mode, focus){
	var timer = 1500;
	if(!field_lock){
		$("#"+fieldHide).hide();
		$("#"+fieldShow).show();
		//$("#"+fieldShow).show(mode);
		if(focus){
			$('#'+field).focus();
			timer = 2000;
		}
		orig_val = $('#'+field).val();
		field_lock = true;

		setTimeout(function(){resetFieldFocus(fieldShow, fieldHide, field, orig_val, focus);}, timer);
	}
}

function updateField(fieldHide, fieldShow, field, objtype, id_objref, field_type, listCounter){
	var edit_val_ch = $('#'+field).val();
	var field_name = $('#'+field).attr("name");
	var resp = false;
  
  //alert("updateField - edit_val_ch: "+edit_val_ch);
  //alert("updateField - field_name: "+field_name);

	if(edit_val_ch != orig_val){
		resp = sendAjaxCommand(field_name, edit_val_ch, objtype, id_objref, listCounter, field);
	}else{
		orig_val = "";
	}	

	if(resp){
		$("#"+fieldShow).empty();
		if(field_type==2){
			$("#"+fieldShow).append($('#'+field+' :selected').text());		
		}else{
			$("#"+fieldShow).append(edit_val_ch);			
		}
	}

	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();
	field_lock = false;
	has_focus = false;
}

function restoreField(fieldHide, fieldShow, field, objtype, id_objref, field_type, listCounter){
	var edit_val_ch = $('#'+field).val();
  
  //alert("restoreField - edit_val_ch: "+edit_val_ch);
	
	if(edit_val_ch != orig_val){
		updateField(fieldHide, fieldShow, field, objtype, id_objref, field_type, listCounter)
	}

	$("#"+fieldHide).hide();
	$("#"+fieldShow).show();
	field_lock = false;
	has_focus = false;
}

function resetFieldFocus(fieldHide, fieldShow, field, orig_val, focus){
	if(orig_val==$('#'+field).val()){
		if(has_focus==false){	
			if(focus){
				$("#"+field).blur();
				has_focus = false;
			}else{
				$("#"+fieldHide).hide();
				$("#"+fieldShow).show();
				field_lock = false;
				has_focus = false;
			}	
		}
	}
}

function setFocusField(){
	has_focus=true;
}

$(document).ready(function() {
	$("input[type='text']").click( function() {setFocusField();});
	$("textarea").click(function() {setFocusField();});
	$("select").click(function() {setFocusField();});
});
</SCRIPT>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">		

			<!--<a href="<%=secureURL%>area_user/account.aspx">&lt;&lt;&nbsp;&nbsp;<%=lang.getTranslated("frontend.area_user.manage.label.profile")%></a>-->

			<div style="padding-top:20px;padding-bottom:20px;float:top;min-height:40px;">		
				<form action="<%=currentURL%>" method="post" name="form_search" accept-charset="UTF-8">
					<input type="hidden" value="1" name="page">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">
					<div style="float:left;padding-right:10px;padding-top:15px;">
					<input type="submit" value="<%=lang.getTranslated("backend.content.lista.label.search")%>" class="buttonForm" hspace="4">
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.content.lista.label.title_filter")%></span><br>
					<input type="text" name="titlef" value="<%=titlef%>" class="formFieldTXT">	
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.content.lista.label.keyword_filter")%></span><br>
					<input type="text" name="keywordf" value="<%=keywordf%>" class="formFieldTXT">	
					</div>
					<div style="float:top;padding-right:10px;height:40px;">
					<span class="labelForm"><%=lang.getTranslated("backend.content.lista.label.status_filter")%></span><br>
					<select name="statusf" class="formfieldSelect">
					<option value=""></option>
					<option value="0"<%if ("0"==statusf) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.edit")%></option>	
					<option value="1"<%if ("1"==statusf) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.public")%></option>	
					</SELECT>
					</div>
					<div style="float:left;padding-right:10px;padding-top:15px;width:95px;"></div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.content.lista.label.category_filter")%></span><br>
					<select name="categoryf" class="formfieldSelect">
					<option value=""></option>
					<%
					string catdesc;
					foreach (Category c in categories){
						if(CategoryService.checkUserCategory(login.userLogged, c)){
							catdesc = "-&nbsp;"+c.description;
							string[] level = c.hierarchy.Split('.');
							if(level != null){
								for(int l=1;l<level.Length;l++){
									catdesc = "&nbsp;&nbsp;&nbsp;"+catdesc;
								}
							}%>
							<OPTION VALUE="<%=c.id%>" <%if (c.id==categoryf) { Response.Write("selected");}%>><%=catdesc%></OPTION>
						<%}
					}%>
					</SELECT>
					</div>
					<div style="float:top;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.content.lista.label.language_filter")%></span><br>
					<select name="languagef" class="formfieldSelect">
					<option value=""></option>
					<%
					foreach (Language l in languages){
						if(LanguageService.checkUserLanguage(login.userLogged, l)){%>
						<option value="<%=l.id%>" <%if (l.id==languagef) { Response.Write("selected");}%> style="background-image: url('/backoffice/img/flag/flag-<%=l.label%>.png');background-repeat: no-repeat;background-position: left center;padding-left:20px;padding-bottom:2px;vertical-align:top;"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+l.description)%></option>
						<%}
					}%>	
					</SELECT>
					</div>		
			</form>
			</div>

			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<div id="contenutilist" style="visibility:visible;display:block;margin:0px;padding:0px;">
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
					<tr> 
						<th colspan="8" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=currentURL%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">	
						<input type="text" name="itemsNews" class="formFieldTXTNumXPage" value="<%=itemsXpageNews%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
						</div>
						</th>
					</tr>

				      <tr> 
					<th colspan="3">&nbsp;</td>
					<th class="upper" onclick="javascript:sortContentParam(<%if(Request["order_by"]=="1"){ Response.Write("2"); }else{ Response.Write("1");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.contenuti.lista.table.header.title" runat="server" /></th>
					<th class="upper" onclick="javascript:sortContentParam(<%if(Request["order_by"]=="7"){ Response.Write("8"); }else{ Response.Write("7");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.contenuti.lista.table.header.pub_date" runat="server" /></th>
					<th class="upper" onclick="javascript:sortContentParam(<%if(Request["order_by"]=="9"){ Response.Write("10"); }else{ Response.Write("9");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.contenuti.lista.table.header.stato" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.contenuti.lista.table.header.category" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.contenuti.lista.table.header.lang" runat="server" /></th>
				      </tr>
					  
						<%
						int intCount = 0;				
						if(bolFoundLista){
							foreach (FContent k in contents){%>		
								<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
								<td align="center" width="25">
								<!--nsys-usr-lnews3--><%if(Convert.ToBoolean(Convert.ToInt32(configService.get("enable_ads").value))){%><a href="javascript:createAds('<%=k.id%>');"><img src="/backoffice/img/vcard_add.png" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.ads")%>" title="<%=lang.getTranslated("backend.contenuti.lista.table.alt.ads")%>" hspace="2" vspace="0" border="0"></a><%}%><!---nsys-usr-lnews3-->
								</td>
								<td align="center" width="25"><a href="javascript:editContent('<%=k.id%>');"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.contenuti.lista.table.alt.modify")%>" hspace="2" vspace="0" border="0"></a></td>
								<td align="center" width="25"><a href="javascript:deleteContent(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.contenuti.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>
								<td nowrap width="240">						
								<strong><div class="ajax" id="view_title_<%=intCount%>" onmouseover="javascript:showHide('view_title_<%=intCount%>','edit_title_<%=intCount%>','title_<%=intCount%>',500, false);"><%=k.title%></div></strong>
								<div class="ajax" id="edit_title_<%=intCount%>"><textarea class="formfieldAjaxArea2" id="title_<%=intCount%>" name="title" onmouseout="javascript:restoreField('edit_title_<%=intCount%>','view_title_<%=intCount%>','title_<%=intCount%>','FContent|IContentRepository|string',<%=k.id%>,1,<%=intCount%>);"><%=k.title%></textarea></div>
								<script>
								$("#edit_title_<%=intCount%>").hide();
								</script>
								</td>
								<td width="135">
								<div class="ajax" id="view_news_data_pub_<%=intCount%>" onmouseover="javascript:showHide('view_news_data_pub_<%=intCount%>','edit_news_data_pub_<%=intCount%>','news_data_pub_<%=intCount%>',500, true);"><%=k.publishDate.ToString("dd/MM/yyyy HH:mm")%></div>
								<div class="ajax" id="edit_news_data_pub_<%=intCount%>"><input type="text" class="formfieldAjaxMedium3" id="news_data_pub_<%=intCount%>" name="publishDate" onchange="javascript:updateField('edit_news_data_pub_<%=intCount%>','view_news_data_pub_<%=intCount%>','news_data_pub_<%=intCount%>','FContent|IContentRepository|datetime',<%=k.id%>,1,<%=intCount%>);" value="<%=k.publishDate.ToString("dd/MM/yyyy HH:mm")%>"></div>
								<script>
								
								$(function() {
									$('#news_data_pub_<%=intCount%>').datetimepicker({
										/*showButtonPanel: false,
										dateFormat: 'dd/mm/yy',
										timeFormat: 'HH.mm'*/								
										format:'d/m/Y H.i',
										closeOnDateSelect:true
									});
									//$('#ui-datepicker-div').hide();							
								});

								$("#edit_news_data_pub_<%=intCount%>").hide();
								</script>
								</td>
								<td width="90">
								<div class="ajax" id="view_stato_news_<%=intCount%>" onmouseover="javascript:showHide('view_stato_news_<%=intCount%>','edit_stato_news_<%=intCount%>','stato_news_<%=intCount%>',500, true);">
								<%
								if(k.status==0){
									Response.Write(lang.getTranslated("backend.contenuti.lista.table.select.option.edit"));
								}else{
									Response.Write(lang.getTranslated("backend.contenuti.lista.table.select.option.public"));
								}%>
								</div>
								<div class="ajax" id="edit_stato_news_<%=intCount%>">
								<select name="status" class="formfieldAjaxSelect" id="stato_news_<%=intCount%>" onblur="javascript:updateField('edit_stato_news_<%=intCount%>','view_stato_news_<%=intCount%>','stato_news_<%=intCount%>','FContent|IContentRepository|int',<%=k.id%>,2,<%=intCount%>);">
								<option value="0"<%if (k.status==0) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.edit")%></option>	
								<option value="1"<%if (k.status==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.contenuti.lista.table.select.option.public")%></option>	
								</select>	
								</div>
								<script>
								$("#edit_stato_news_<%=intCount%>").hide();
								</script>
								</td>
								<td nowrap>
								<%
								foreach (Category x in categories){
									if(k.categories!=null){
										bool hasCat = false;
										foreach(ContentCategory cl in k.categories){
											if(x.id==cl.idCategory){
												hasCat = true;
												break;
											}
										}
										if(hasCat){Response.Write("-&nbsp;"+x.description+"<br/>");}
									}
								}%>	
								</td>
								<td nowrap>						
								<%
								int lCount = 1;
								foreach (Language x in languages){
									if(k.languages!=null){
										bool hasLang = false;
										foreach(ContentLanguage cl in k.languages){
											if(x.id==cl.idLanguage){
												hasLang = true;
												break;
											}
										}
										if(hasLang){%>
										<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><%if(lCount % 4 == 0){Response.Write("<br/>");}%>
										<%}
									}
									lCount++;
								}%>	
								</td>
								</tr>
								<%intCount++;
							}
						}
						%>
					
					<tr> 
						<th colspan="8" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=currentURL%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">	
						<input type="text" name="itemsNews" class="formFieldTXTNumXPage" value="<%=itemsXpageNews%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
						</div>
						</th>
					</tr>			
				</table>
				<br/>
				<div>
					<form action="<%=secureURL%>area_user/ads/insertcontent.aspx" method="post" name="form_crea">
						<input type="hidden" value="-1" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.contenuti.lista.button.inserisci.label")%>" onclick="javascript:document.form_crea.submit();" />
					</form>
				</div>

				<form action="<%=secureURL%>area_user/ads/contentlist.aspx" method="post" name="content_sort">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				<input type="hidden" value="<%=itemsXpageNews%>" name="itemsNews">	
				<input type="hidden" value="<%=numPageNews%>" name="page">	
				<input type="hidden" value="" name="order_by">
				</form>
				
				<div id="commentsWrapper" style="z-index:10000;">
					<div id="commentsContainer" style="z-index:10000;position:absolute;top:200px;left:400px;width:500px;height:400px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
				</div>
			</div>	
		</div>		
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>