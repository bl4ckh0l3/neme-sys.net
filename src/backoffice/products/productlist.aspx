<%@ Page Language="C#" AutoEventWireup="true" CodeFile="productlist.aspx.cs" Inherits="_ProductList" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script>
function confirmClone(id){
	if(confirm('<%=lang.getTranslated("backend.product.detail.js.alert.confirm_clone_product")%>')){
		location.href='/backoffice/products/cloneproduct.aspx?cssClass=LP&productid='+id;
	}else{
		return;
	}
}

function deleteProduct(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.product.detail.js.alert.confirm_del_prod")%>")){	
		ajaxDeleteItem(id_objref,"Product|IProductRepository|com.nemesys.services.CommonService|deleteDirectory|static|"+id_objref,row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
	}
}

function editProduct(id){
	location.href='/backoffice/products/insertproduct.aspx?cssClass=LP&id='+id;
}

/*function deleteField(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.product.lista.js.alert.delete_field")%>?")){
		ajaxDeleteItem(id_objref,"ProductField||IProductRepository|deleteProductField|public|"+id_objref,row,refreshrows);
	}
}*/

function deleteField(theForm){
	if(confirm("<%=lang.getTranslated("backend.product.lista.js.alert.delete_field")%>?")){
		theForm.operation.value = "deleteField";
		theForm.action = "/backoffice/products/productlist.aspx";
		theForm.submit();
	}
}

function ajaxViewZoom(id, container, counter){
	var dataString;

	if($('#'+container).css("display")=="none"){
		dataString = 'id='+ id;  
		
		$('#view_zoom_'+counter).hide();
		$('#loading_zoom_'+counter).show();
		
		$.ajax({  
			type: "POST",  
			url: "/backoffice/products/ajaxviewproduct.aspx",  
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

function sortProductParam(val){
	document.product_sort.order_by.value = val;
	document.product_sort.submit();	
}

function previewComments(){	
	var query_string = "element_type=2&mode=manage&container=commentsContainer";	
	//alert(query_string);
	
	$('#commentsContainer').empty();
	$('#commentsContainer').append('<div align="center" style="padding-top:150px;" id="loading-menu-comment"><img src="/common/img/loading_icon.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="vertical-align:middle;text-align:center;padding-top:0px;padding-bottom:0px;"></div>');	
	$('#commentsContainer').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/include/ajaxpreviewcomments.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#commentsContainer').empty();
			$('#commentsContainer').append('<div align="right"><span style="cursor:pointer;text-decoration:underline;" onclick="javascript:hideCommentDiv();">x</span></div>');
			$('#commentsContainer').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#commentsContainer').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function hideCommentDiv(){
	$('#commentsContainer').hide();
}

$(function() {
	$("#commentsContainer").draggable();
});

function showHideDivProductField(element){
	var elementUl = document.getElementById("productlist");
	var elementaUl = document.getElementById("aproductlist");
	var elementUf = document.getElementById("productfield");
	var elementaUf = document.getElementById("aproductfield");

	if(element == 'productlist'){
		elementUf.style.visibility = 'hidden';		
		elementUf.style.display = "none";
		elementaUf.className= "";
		elementUl.style.visibility = 'visible';
		elementUl.style.display = "block";
		elementaUl.className= "active";
	}else if(element == 'productfield'){
		elementUl.style.visibility = 'hidden';
		elementUl.style.display = "none";
		elementaUl.className= "";
		elementUf.style.visibility = 'visible';		
		elementUf.style.display = "block";
		elementaUf.className= "active";
	}
}

jQuery(document).ready(function(){
	showHideDivProductField('<%=showTab%>'); 
})
</SCRIPT>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		

		<div id="tab-product-field"><a id="aproductlist" <%if(showTab=="productlist"){ Response.Write("class=active");}%> href="javascript:showHideDivProductField('productlist');"><%=lang.getTranslated("backend.utenti.lista.table.header.label_product_list")%></a><a id="aproductfield" <%if(showTab=="productfield"){Response.Write("class=active");}%> href="javascript:showHideDivProductField('productfield');"><%=lang.getTranslated("backend.utenti.lista.table.header.label_product_field")%></a></div>
		<div id="productlist" style="visibility:hidden;/*display:block;*/margin:0px;padding:0px;">

			<div style="padding-bottom:20px;float:top;min-height:40px;border: 1px solid rgb(201, 201, 201);">		
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" accept-charset="UTF-8">
					<input type="hidden" value="1" name="page">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">
					<div style="float:left;padding-right:10px;padding-top:15px;">
					<input type="submit" value="<%=lang.getTranslated("backend.product.lista.label.search")%>" class="buttonForm" hspace="4">
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.title_filter")%></span><br>
					<input type="text" name="titlef" value="<%=titlef%>" class="formFieldTXT">	
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.keyword_filter")%></span><br>
					<input type="text" name="keywordf" value="<%=keywordf%>" class="formFieldTXT">	
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.type_filter")%></span><br>
					<select name="typef" class="formfieldSelect">
					<option value=""></option>
					<option value="0" <%if ("0".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_portable")%></option>
					<option value="1" <%if ("1".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_download")%></option>
					<option value="2" <%if ("2".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_ads")%></option>
					<option value="3" <%if ("3".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_booking")%></option>
					</SELECT>
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.status_filter")%></span><br>
					<select name="statusf" class="formfieldSelect">
					<option value=""></option>
					<option value="0"<%if ("0"==statusf) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_inactive")%></option>	
					<option value="1"<%if ("1"==statusf) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_active")%></option>	
					</SELECT>
					</div>
					<div style="float:left;padding-right:10px;">
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.category_filter")%></span><br>
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
					<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.language_filter")%></span><br>
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
						<th colspan="12" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">	
						<input type="hidden" value="productlist" name="showtab">
						<input type="text" name="itemsProd" class="formFieldTXTNumXPage" value="<%=itemsXpageProd%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
						</div>
						</th>
					</tr>

				      <tr> 
					<th colspan="4">&nbsp;</td>
					<th class="upper" onclick="javascript:sortProductParam(<%if(Request["order_by"]=="1"){ Response.Write("2"); }else{ Response.Write("1");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.product.lista.label.name" runat="server" /></th>
					<th class="upper" onclick="javascript:sortProductParam(<%if(Request["order_by"]=="13"){ Response.Write("14"); }else{ Response.Write("13");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.product.lista.table.header.prod_type" runat="server" /></th>
					<th class="upper" onclick="javascript:sortProductParam(<%if(Request["order_by"]=="11"){ Response.Write("12"); }else{ Response.Write("11");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.product.lista.label.price" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.tassa" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.product.lista.table.header.quantity" runat="server" /></th>
					<th class="upper" onclick="javascript:sortProductParam(<%if(Request["order_by"]=="9"){ Response.Write("10"); }else{ Response.Write("9");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.product.lista.label.status" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.product.lista.table.header.category" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.product.lista.table.header.lang" runat="server" /></th>
				      </tr>
					  
						<%
						int intCount = 0;				
						if(bolFoundLista){
							foreach (Product k in products){%>		
								<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
								<td align="center" width="25"><a href="javascript:confirmClone('<%=k.id%>');"><img src="/backoffice/img/page_white_copy.png" alt="<%=lang.getTranslated("backend.product.lista.table.alt.clone")%>" hspace="2" vspace="0" border="0"></a></td>
								<td align="center" width="25">
								<img style="cursor:pointer;" id="view_zoom_<%=intCount%>" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.product.lista.table.alt.view")%>" hspace="2" vspace="0" border="0">
								<img style="display:none" id="loading_zoom_<%=intCount%>" src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
								</td>
								<td align="center" width="25"><a href="javascript:editProduct('<%=k.id%>');"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.product.lista.table.alt.modify")%>" hspace="2" vspace="0" border="0"></a></td>
								<td align="center" width="25"><a href="javascript:deleteProduct(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.product.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>
								<td nowrap width="280">						
								<strong><%=k.name%></strong>
								</td>							
								<td>
								<%
								if(k.prodType==0){
									Response.Write(lang.getTranslated("backend.product.detail.table.label.type_portable"));
								}else if(k.prodType==1){
									Response.Write(lang.getTranslated("backend.product.detail.table.label.type_download"));
								}else if(k.prodType==2){
									Response.Write(lang.getTranslated("backend.product.detail.table.label.type_ads"));
								}else if(k.prodType==3){
									Response.Write(lang.getTranslated("backend.product.detail.table.label.type_booking"));
								}
								%>
								</td>
								<td width="100">
								<div style="float:left">&euro;&nbsp;</div>	
								<div class="ajax" id="view_price_prod_<%=intCount%>" onmouseover="javascript:showHide('view_price_prod_<%=intCount%>','edit_price_prod_<%=intCount%>','price_<%=intCount%>',500, false);"><%=k.price.ToString("#,###0.00")%></div>
								<div class="ajax" id="edit_price_prod_<%=intCount%>"><input type="text" class="formfieldAjaxMedium" id="price_<%=intCount%>" name="price" onmouseout="javascript:restoreField('edit_price_prod_<%=intCount%>','view_price_prod_<%=intCount%>','price_<%=intCount%>','Product|IProductRepository|decimal',<%=k.id%>,1,<%=intCount%>);" value="<%=k.price.ToString("#,###0.00")%>" onkeypress="javascript:return isDouble(event);"></div>
								<script>
								$("#edit_price_prod_<%=intCount%>").hide();
								</script>
								</td>
								<td>
								
								<%								
								string supDesc = "";
								StringBuilder supOptions = new StringBuilder();	
								foreach (Supplement x in supplements){
									supOptions.Append("<option value=\"").Append(x.id).Append("\"");
									if(k.idSupplement != null && k.idSupplement>0 && k.idSupplement==x.id){
										supDesc = x.description;
										supOptions.Append(" selected");
									}
									supOptions.Append(">").Append(x.description).Append("</option>");
								}			
								%>								
								<div class="ajax" id="view_id_supplement_<%=intCount%>" onmouseover="javascript:showHide('view_id_supplement_<%=intCount%>','edit_id_supplement_<%=intCount%>','id_supplement_<%=intCount%>',500, true);"><%=supDesc%></div>
								<div class="ajax" id="edit_id_supplement_<%=intCount%>">
								<select name="idSupplement" class="formfieldAjaxSelect" id="id_supplement_<%=intCount%>" onblur="javascript:updateField('edit_id_supplement_<%=intCount%>','view_id_supplement_<%=intCount%>','id_supplement_<%=intCount%>','Product|IProductRepository|int',<%=k.id%>,2,<%=intCount%>);">
									<option value=""></option>
									<%=supOptions.ToString()%>	  
								</select>
								</div>
								<script>
								$("#edit_id_supplement_<%=intCount%>").hide();
								</script>								
								
								
								
								</td>
								<td width="100"><%
								if(k.prodType==3){
									Response.Write(lang.getTranslated("backend.product.detail.table.label.qta_calendar"));
								}else{
									if(k.quantity<0){
										Response.Write(lang.getTranslated("backend.product.detail.table.label.qta_unlimited"));
									}else{
										Response.Write(k.quantity);
									}
								}%></td>
								<td width="90">
								<div class="ajax" id="view_stato_news_<%=intCount%>" onmouseover="javascript:showHide('view_stato_news_<%=intCount%>','edit_stato_news_<%=intCount%>','stato_news_<%=intCount%>',500, true);">
								<%
								if(k.status==0){
									Response.Write(lang.getTranslated("backend.product.lista.label.status_inactive"));
								}else{
									Response.Write(lang.getTranslated("backend.product.lista.label.status_active"));
								}%>
								</div>
								<div class="ajax" id="edit_stato_news_<%=intCount%>">
								<select name="status" class="formfieldAjaxSelect" id="stato_news_<%=intCount%>" onblur="javascript:updateField('edit_stato_news_<%=intCount%>','view_stato_news_<%=intCount%>','stato_news_<%=intCount%>','Product|IProductRepository|int',<%=k.id%>,2,<%=intCount%>);">
								<option value="0"<%if (k.status==0) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_inactive")%></option>	
								<option value="1"<%if (k.status==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.product.lista.label.status_active")%></option>	
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
										foreach(ProductCategory cl in k.categories){
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
										foreach(ProductLanguage cl in k.languages){
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

								<tr class="preview_row" id="tr_preview_row_<%=intCount%>">
								<td colspan="12">
								<div id="view_product_<%=intCount%>"></div>
								<script>
								$("#view_product_<%=intCount%>").hide();
								$('#view_zoom_<%=intCount%>').click(function(){ajaxViewZoom('<%=k.id%>', 'view_product_<%=intCount%>', <%=intCount%>);});
								</script>	
								</td>
								</tr>
								<%intCount++;
							}
						}
						%>
					
					<tr> 
						<th colspan="12" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">
						<input type="hidden" value="productlist" name="showtab">	
						<input type="text" name="itemsProd" class="formFieldTXTNumXPage" value="<%=itemsXpageProd%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
						</div>
						</th>
					</tr>			
				</table>
				<br/>
				<div style="float:left;">
					<form action="/backoffice/products/insertproduct.aspx" method="post" name="form_crea">
						<input type="hidden" value="-1" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.product.lista.button.insert.label")%>" onclick="javascript:document.form_crea.submit();" />
					</form>
				</div>
				<div style="float:left;">
					&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.lista.button.label.download_excel")%>" onclick="javascript:openWinExcel('/backoffice/report/create-prod-catalog.aspx','crea_excel',400,400,100,100);" />
				</div>
				<div>
					&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("portal.templates.commons.label.see_comments_news")%>" onclick="javascript:previewComments();" />
				</div>

				<form action="/backoffice/products/productlist.aspx" method="post" name="product_sort">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				<input type="hidden" value="<%=itemsXpageProd%>" name="itemsProd">	
				<input type="hidden" value="<%=numPageProd%>" name="page">	
				<input type="hidden" value="" name="order_by">
				</form>
				
				<div id="commentsWrapper" style="z-index:10000;">
					<div id="commentsContainer" style="z-index:10000;position:absolute;top:200px;left:400px;width:500px;height:400px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
				</div>
			</div>
			
			</div>
			
			<div id="productfield" style="visibility:hidden;">

			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
			<th colspan="9" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="productfield" name="showtab">
			<input type="text" name="itemsField" class="formFieldTXTNumXPage" value="<%=itemsXpageField%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg3" runat="server" index="3" maxVisiblePages="10" />
			</div>
			</th>
			<tr> 
				<th colspan="2">&nbsp;</th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.description" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.group" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.order" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.type" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.type_content" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.required" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.prodotti.lista.table.header.enabled" runat="server" /></th>
			</tr>
				<%						
				int fcounter = 0;				
				if(bolFoundField)
				{
					for(fcounter = fromFields; fcounter<= toFields;fcounter++)
					{
						ProductField k = productfields[fcounter];%>
						<form action="/backoffice/products/insertfield.aspx" method="post" name="form_lista_field_<%=fcounter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="" name="operation">
						<input type="hidden" value="productfield" name="showtab">
						<input type="hidden" value="LP" name="cssClass">	
						</form>		
						<tr id="tr_delete_flist_<%=fcounter%>" class="<%if(fcounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_field_<%=fcounter%>.submit();"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.prodotti.lista.table.alt.modify_field")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteField(document.form_lista_field_<%=fcounter%>);"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.prodotti.lista.table.alt.delete_field")%>" hspace="5" vspace="0" border="0"></a></td>										
							<td width="15%">						
							<div class="ajax" id="view_description_<%=fcounter%>" onmouseover="javascript:showHide('view_description_<%=fcounter%>','edit_description_<%=fcounter%>','description_<%=fcounter%>',500, false);"><%=k.description%></div>
							<div class="ajax" id="edit_description_<%=fcounter%>"><input type="text" class="formfieldAjax" id="description_<%=fcounter%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=fcounter%>','view_description_<%=fcounter%>','description_<%=fcounter%>','ProductField|IProductRepository|string|getProductFieldById|updateProductField',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.description%>"></div>
							<script>
							$("#edit_description_<%=fcounter%>").hide();
							</script>
							</td>
							<td width="18%">						
							<div class="ajax" id="view_id_group_<%=fcounter%>" onmouseover="javascript:showHide('view_id_group_<%=fcounter%>','edit_id_group_<%=fcounter%>','id_group_<%=fcounter%>',500, true);"><%=k.groupDescription%></div>
							<div class="ajax" id="edit_id_group_<%=fcounter%>">
							<select name="groupDescription" class="formfieldAjaxSelect" id="id_group_<%=fcounter%>" onblur="javascript:updateField('edit_id_group_<%=fcounter%>','view_id_group_<%=fcounter%>','id_group_<%=fcounter%>','ProductField|IProductRepository|string|getProductFieldById|updateProductField',<%=k.id%>,2,<%=fcounter%>);">
								<option></option>
								<%foreach(string x in fieldGroupNames){%>
								<option value="<%=x%>" <%if(x==k.groupDescription){Response.Write("selected='selected'");}%>><%=x%></option>
								<%}%>
							</select>
							</div>
							<script>
							$("#edit_id_group_<%=fcounter%>").hide();
							</script>
							</td>
							<td>				
							<div class="ajax" id="view_order_<%=fcounter%>" onmouseover="javascript:showHide('view_order_<%=fcounter%>','edit_order_<%=fcounter%>','order_<%=fcounter%>',500, false);"><%=k.sorting%></div>
							<div class="ajax" id="edit_order_<%=fcounter%>"><input type="text" class="formfieldAjaxShort" id="order_<%=fcounter%>" name="sorting" onmouseout="javascript:restoreField('edit_order_<%=fcounter%>','view_order_<%=fcounter%>','order_<%=fcounter%>','ProductField|IProductRepository|int|getProductFieldById|updateProductField',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.sorting%>" maxlength="3" onkeypress="javascript:return isInteger(event);"></div>
							<script>
							$("#edit_order_<%=fcounter%>").hide();
							</script>
							</td>
							<td>
							<%foreach(SystemFieldsType x in systemFieldsType){
								if (x.id==k.type) {
									string stypeLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
										stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
									}
									Response.Write(stypeLabel);
									break;
								}
								%>
							<%}%></td>
							<td>
							<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
								if (x.id==k.typeContent) {
									string stypecLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
										stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
									}
									Response.Write(stypecLabel);
									break;
								}
							}%></td>
							<td>
							<div class="ajax" id="view_required_<%=fcounter%>" onmouseover="javascript:showHide('view_required_<%=fcounter%>','edit_required_<%=fcounter%>','required_<%=fcounter%>',500, true);">
							<%
							if (k.required) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else {
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_required_<%=fcounter%>">
							<select name="required" class="formfieldAjaxSelect" id="required_<%=fcounter%>" onblur="javascript:updateField('edit_required_<%=fcounter%>','view_required_<%=fcounter%>','required_<%=fcounter%>','ProductField|IProductRepository|bool|getProductFieldById|updateProductField',<%=k.id%>,2,<%=fcounter%>);">
							<OPTION VALUE="0" <%if (!k.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_required_<%=fcounter%>").hide();
							</script>
							</td>
							<td>
							<div class="ajax" id="view_enabled_<%=fcounter%>" onmouseover="javascript:showHide('view_enabled_<%=fcounter%>','edit_enabled_<%=fcounter%>','enabled_<%=fcounter%>',500, true);">
							<%
							if (k.enabled) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else {
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_enabled_<%=fcounter%>">
							<select name="enabled" class="formfieldAjaxSelect" id="enabled_<%=fcounter%>" onblur="javascript:updateField('edit_enabled_<%=fcounter%>','view_enabled_<%=fcounter%>','enabled_<%=fcounter%>','ProductField|IProductRepository|bool|getProductFieldById|updateProductField',<%=k.id%>,2,<%=fcounter%>);">
							<OPTION VALUE="0" <%if (!k.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_enabled_<%=fcounter%>").hide();
							</script>
							</td>			
						</tr>				
					<%}
				}%>
			<tr> 
			<th colspan="9" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="productfield" name="showtab">
			<input type="text" name="itemsField" class="formFieldTXTNumXPage" value="<%=itemsXpageField%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg4" runat="server" index="4" maxVisiblePages="10" />
			</div>
			</th>
			</tr>				  
		    </table>
			<br/>
			<form action="/backoffice/products/insertfield.aspx" method="post" name="form_crea_field">
			<input type="hidden" value="-1" name="id">
			<input type="hidden" value="LP" name="cssClass">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.prodotti.lista.button.inserisci_field.label")%>" onclick="javascript:document.form_crea_field.submit();" />
			</form>


			</div>

		</div>		
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>