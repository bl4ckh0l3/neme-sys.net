<%@ Page Language="C#" AutoEventWireup="true" CodeFile="detail.aspx.cs" Inherits="_Detail" Debug="false" %>
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
<%@ Register TagPrefix="UserOnlineWidget" TagName="render" Src="~/public/layout/addson/user/user-online-widget.ascx" %>
<%@ Register TagPrefix="CommentsWidgetWrapperControl" TagName="render" Src="~/public/layout/addson/comments/comments-widget-wrapper.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
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
<script>
function openAttach(path, fileName, idAttach, contentType){

	var query_string = "attach_id="+idAttach+"&attach_path="+path+"&page_url=<%=Request.Url%>&contenttype="+contentType+"&filename="+fileName;
	//alert(query_string);
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "/public/layout/addson/tracking/ajaxlogdownload.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			
		},
		error: function() {
			//alert("error");
		}
	});	
	
	window.open('/public/upload/files/contents/'+path, '_blank');
}

var mapid = "map";
var latlng = new Array();
var infowin = new Array();
<%if(points.Count>0){
	foreach(Geolocalization k in points){
		if(k.latitude != null && k.latitude >0 && k.longitude != null && k.longitude >0){%>
			latlng.push(new google.maps.LatLng(replaceCommaInNumber('<%=k.latitude%>'), replaceCommaInNumber('<%=k.longitude%>')));
			infowin.push("<%=k.txtInfo%>");
		<%}
	}
}%>

function showMap(mapid){
	$('#'+mapid).show();
        var mapOptions = {
          center: new google.maps.LatLng(0, 0),
          zoom: 2,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        var map = new google.maps.Map(document.getElementById(mapid),  mapOptions);
	var latlngbounds = new google.maps.LatLngBounds();

	if(latlng.length==1){
		map.setCenter(latlng[0]);
		map.setZoom(10);
	}else{
		for (var j=0; j<latlng.length; j++){
			latlngbounds.extend(latlng[j]);
		}
		map.fitBounds(latlngbounds);
	}

	for (var j=0; j<latlng.length; j++){
		var infowintxt = infowin[j];
		var marker = createMarker(latlng[j], infowintxt, map);
	}

        var polyOptions = {
          strokeColor: '#4e26d0',
          strokeOpacity: 1.0,
          strokeWeight: 7,
	  geodesic:true,
	  path: latlng
        }
        poly = new google.maps.Polyline(polyOptions);
        poly.setMap(map);
}

function createMarker(point,html,map) {  
	var infowindow = new google.maps.InfoWindow(); 
	var marker = new google.maps.Marker({
		position: point,
		map: map
	});
	google.maps.event.addListener(marker, "click", function() {
		infowindow.setContent(html);
		infowindow.open(map, marker);					
	}); 
	return marker;
}
	
jQuery(document).ready(function(){
	<%if(points.Count>0){%>
		showMap(mapid);
	<%}%>
});

function replaceCommaInNumber(number){
	return number.replace(',','.');
}
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<div style="clear:left;float:left;">
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<UserOnlineWidget:render runat="server" ID="uow1" index="1" style="float:top;clear:left;width:170px;"/>
		</div>
		<div id="content-center">
			<MenuFrontendControl:insert runat="server" ID="mf3" index="3" model="tips"/>
			<div align="left">
			<%if (content != null) {%>
				<div>
				<p><strong><asp:Literal id="ctitle" runat="server" /></strong></p>
				<div style="float:right;width:300px;height:250px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;margin-left:3px;" id="map"></div>
				<asp:Literal id="csummary" runat="server" />
				<asp:Literal id="cdescription" runat="server" />
				
				<%
				if(contentFields.Count>0){ 
					Response.Write(ContentService.renderField(contentFields, null, "", "", lang.currentLangCode, lang.defaultLangCode));
				}
				
				if(attachmentsDictionary.Keys.Count>0){ 
					foreach(string keyword in attachmentsDictionary.Keys){%>
						<br/><br/><strong><%=keyword%></strong><br/>
						<%foreach(ContentAttachment item in attachmentsDictionary[keyword]){%>
							<!--<a href="javascript:openWin('/public/layout/include/popup.aspx?attachmentid=<%=item.id%>&parent_type=1','popupallegati',400,400,100,100)"><%=item.fileName%></a><br>-->
							<a href="javascript:openAttach('<%=item.filePath+item.fileName%>','<%=item.fileName%>','<%=item.id%>','<%=item.contentType%>')"><%=item.fileName%></a><br>
						<%}
					}
				}%>
				</div>
				
				<CommentsWidgetWrapperControl:render runat="server" ID="cwwc1" index="1"/>
		
				<div id="torna"><a href="/common/include/feedRSS.aspx?hierarchy=<%=hierarchy%>&contentid=<%=content.id%>&page=<%=numPage%>&modelPageNum=<%=modelPageNum%>" target="_blank"><img src="/common/img/rss_image.gif" vspace="3" hspace="3" border="0" align="right" alt="RSS"></a></div>
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
			<%}%>
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