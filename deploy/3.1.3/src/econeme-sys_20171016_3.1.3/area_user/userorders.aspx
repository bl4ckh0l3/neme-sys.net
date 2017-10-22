<%@ Page Language="C#" AutoEventWireup="true" CodeFile="userorders.aspx.cs" Inherits="_FeOrderList" Debug="true" ValidateRequest="false"%>
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
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">		
			<table border="0" cellpadding="0" cellspacing="0" class="friends_table">
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

				  <tr> 
				<th>&nbsp;</td>
				<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.dta_insert_order")%></th>
				<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.totale_order")%></th>
				<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.tipo_pagam_order")%></th>
				<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.pagam_order_done")%></th>
				<th><%=lang.getTranslated("frontend.area_user.ordini.table.header.stato_order")%></th>
				  </tr>
				  
					<%
					int intCount = 0;				
					if(bolFoundLista){
						for(intCount = fromOrder; intCount<= toOrder;intCount++){
							FOrder k = orders[intCount];
							
							string pdone = lang.getTranslated("portal.commons.no");
							if(k.paymentDone){
								pdone = lang.getTranslated("portal.commons.yes");
							}
							
							string orderStatus = "";
							if(k.status==1){
								orderStatus = statusOrder[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
									orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
								}
							}else if(k.status==2){
								orderStatus = statusOrder[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
									orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
								}
							}else if(k.status==3){
								orderStatus = statusOrder[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
									orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
								}
							}else if(k.status==4){
								orderStatus = statusOrder[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+orderStatus))){
									orderStatus = lang.getTranslated("backend.ordini.view.table.label."+orderStatus);
								}
							}
							
							string ptype = "";
							paymentTypes.TryGetValue(k.id, out ptype);
							%>		
							<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
							<td align="center" width="25"><a href="<%=secureURL%>area_user/vieworder.aspx?orderid=<%=k.id%>" title="<%=lang.getTranslated("frontend.area_user.ordini.alt.view_order")%>"><img src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("frontend.area_user.ordini.alt.view_order")%>" hspace="2" vspace="0" border="0"></a></td>
							<td><%=k.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
							<td>&euro;&nbsp;<%=k.amount.ToString("#,###0.00")%></td>
							<td><%=ptype%></td>
							<td><%=pdone%></td>
							<td><%=orderStatus%></td>
							</tr>
						<%}
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