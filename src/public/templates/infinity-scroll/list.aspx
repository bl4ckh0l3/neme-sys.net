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
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<CommonCssJs:insert runat="server" />
<script type="text/javascript" src="/common/js/infinity-scroll.min.js"></script>
<script>  
var maxPages = <%=this.totalCPages%>;
var infinity_counter = 2;
function openDetailContentPage(contentid){
	<%if(bolHasDetailLink){%>
    document.form_detail_link_news.contentid.value=contentid;
    document.form_detail_link_news.submit();
	<%}%>
}

function infinityScroll(pageNum){	
	var query_string = "categoryid=<%=categoryid%>&page="+pageNum+"&items=<%=itemsXpage%>";	
	//alert(query_string);
	
	$('#loading_zoom').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/common/include/content_xml.aspx",
		data: query_string,
		dataType: "xml",
		success: function(xml) {
			$('#loading_zoom').hide();
			
			$(xml).find('item').each(function(){
				var id = $(this).find('id').text();
				var title = $(this).find('title').text();
				var summary = $(this).find('summary').text();

				var newrow = '<div><p class="title_contenuti"><a href="javascript:openDetailContentPage('+id+');">'+title+'</a></p>'+summary+'</div><p class=line></p>';
				$('#contenuti').append(newrow);				
			});
		},
		error: function(response) {
			//alert(response.responseText);	
			//$('#commentsContainer').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
			$('#loading_zoom').hide();
		}
	});	
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
				<%
				foreach (FContent content in contents){%>
					<div><p class="title_contenuti"><a href="javascript:openDetailContentPage(<%=content.id%>);"><%=content.title%></a></p>
					<%=content.summary%>
					</div>
					<p class="line"></p>
				<%}%>
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
			<%}%>
			</div>
			<div style="width:100%;text-align:center;"><img style="display:none" id="loading_zoom" src="/common/img/loading_icon3.gif" alt="" align="center" width="23" height="23" hspace="2" vspace="0" border="0"></div>
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
<script type="text/javascript">
var options = {
  distance: 50,
  callback: function(done) {
    // 1. fetch data from the server
    // 2. insert it into the document
    // 3. call done when we are done
    if(infinity_counter<=maxPages){
    	infinityScroll(infinity_counter);
    	done();
    	infinity_counter++;
    }
  }
}

// setup infinite scroll
infiniteScroll(options);
</script>
</body>
</html>