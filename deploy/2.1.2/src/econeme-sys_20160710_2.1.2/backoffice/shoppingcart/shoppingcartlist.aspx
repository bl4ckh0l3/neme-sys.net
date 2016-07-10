<%@ Page Language="C#" AutoEventWireup="true" CodeFile="shoppingcartlist.aspx.cs" Inherits="_ShoppingcartList" Debug="false" ValidateRequest="false"%>
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
<script>

function deleteCart(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.carrello.detail.js.alert.confirm_del_card")%>")){	
		ajaxDeleteItem(id_objref,"ShoppingCart|IShoppingCartRepository",row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
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
			url: "/backoffice/shoppingcart/ajaxviewshoppingcart.aspx",  
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
</SCRIPT>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		
			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>		
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
					<th colspan="5" align="left">
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

				  <tr> 
				<th colspan="2">&nbsp;</td>
				<th class="upper"><lang:getTranslated keyword="backend.carrello.lista.table.header.id_carrello" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.carrello.lista.table.header.cliente" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.carrello.lista.table.header.data_insert" runat="server" /></th>
				  </tr>
				  
					<%
					int intCount = 0;				
					if(bolFoundLista){
						for(intCount = fromShop; intCount<= toShop;intCount++){
							ShoppingCart k = shoppingcarts[intCount];%>		
							<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
							<td align="center" width="25">
							<img style="cursor:pointer;" id="view_zoom_<%=intCount%>" src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.carrello.lista.table.alt.view_carrello")%>" hspace="2" vspace="0" border="0">
							<img style="display:none" id="loading_zoom_<%=intCount%>" src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
							</td>
							<td align="center" width="25"><a href="javascript:deleteCart(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.carrello.lista.table.alt.delete_carrello")%>" hspace="2" vspace="0" border="0"></a></td>
							<td width="100"><%=k.id%></td>							
							<td width="200">
							<%
							string scuser = null;
							bool foundpel = users.TryGetValue(k.id, out scuser);
							if(foundpel){
								Response.Write(scuser);
							}else{
								Response.Write(k.idUser);
							}%>
							</td>
							<td><%=k.lastUpdate.ToString("dd/MM/yyyy HH:mm")%></td>
							</tr>

							<tr class="preview_row" id="tr_preview_row_<%=intCount%>">
							<td colspan="5">
							<div id="view_product_<%=intCount%>"></div>
							<script>
							$("#view_product_<%=intCount%>").hide();
							$('#view_zoom_<%=intCount%>').click(function(){ajaxViewZoom('<%=k.id%>', 'view_product_<%=intCount%>', <%=intCount%>);});
							</script>	
							</td>
							</tr>
							<%
						}
					}%>
				
				<tr> 
					<th colspan="5" align="left">
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
		</div>		
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>