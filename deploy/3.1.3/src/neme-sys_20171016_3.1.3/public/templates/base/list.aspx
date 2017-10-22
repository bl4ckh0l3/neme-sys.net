<%@ Page Language="C#" AutoEventWireup="true" CodeFile="list.aspx.cs" Inherits="_List" Debug="true" %>
<%@ import Namespace="System" %>
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
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/common/include/pagination.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
<script>  
function openDetailContentPage(contentid){
	<%if(bolHasDetailLink){%>
    document.form_detail_link_news.contentid.value=contentid;
    document.form_detail_link_news.submit();
	<%}%>
}
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<div id="content-center">
			<MenuFrontendControl:insert runat="server" ID="mf3" index="3" model="tips"/>

			<div align="left" id="contenuti">
			<%int counter = 0;
			if(bolFoundLista) {%>
				<br/>			
				<%for(counter = fromContent; counter<= toContent;counter++){
					FContent content = contents[counter];%>
					<div><p class="title_contenuti"><a href="javascript:openDetailContentPage(<%=content.id%>);"><%=content.title%></a></p>
					<%=content.summary%>
					</div>
					<p class="line"></p>
				<%}%>
				<div><CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" /></div>
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
			<%}%>
			</div>
			<form method="post" name="form_detail_link_news" action="<%=detailURL%>">	
			<input type="hidden" value="" name="contentid">	
			<input type="hidden" value="<%=modelPageNum+1%>" name="modelPageNum">	
			<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
			<input type="hidden" value="<%=categoryid%>" name="categoryid">	
			<input type="hidden" value="<%=numPage%>" name="page">
			<input type="hidden" value="<%=orderBy%>" name="order_by">  
			<input type="hidden" value="<%=Request["content_preview"]%>" name="content_preview">          
			</form>	
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
