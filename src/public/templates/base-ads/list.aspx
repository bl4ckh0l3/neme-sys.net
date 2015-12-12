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
<script>  
function openDetailContentPage(contentid){
	<%if(bolHasDetailLink){%>
    document.form_detail_link_news.contentid.value=contentid;
    document.form_detail_link_news.submit();
	<%}%>
}

var mapid = "maplist";
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
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		<div id="content-center">
			<MenuFrontendControl:insert runat="server" ID="mf3" index="3" model="tips"/>

			<div align="left" id="contenuti">			
				<form action="<%=currentUrl%>" method="post" name="form_search" accept-charset="UTF-8">
				<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">	
				<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
				<input type="hidden" value="<%=categoryid%>" name="categoryid">	
				<input type="hidden" value="<%=numPage%>" name="page">
				<input type="hidden" value="<%=orderBy%>" name="order_by">  
				<input type="hidden" value="<%=Request["content_preview"]%>" name="content_preview">  
				<div>
				<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.ads_type")%></strong><br>
				<select name="ads_type" class="formFieldTXT">
				<option value=""></option>
				<option value="0" <%if("0".Equals(search_ads_type)){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_ads.label.sell")%></option>
				<option value="1" <%if("1".Equals(search_ads_type)){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_ads.label.buy")%></option>
				</select>
				</div>
				<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.ads_title")%></strong><br>
				<input type="text" name="ads_title" value="<%=search_title%>" class="formFieldTXTMedium" /></div>	
				
				<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.price_from")%></strong><br>
				<input type="text" name="price_from" value="<%=search_price_from.ToString("#,###0.00")%>" class="formFieldTXT" onkeypress="javascript:return isDouble(event);"></div>
				<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.price_to")%></strong><br>
				<input type="text" name="price_to" value="<%=search_price_to.ToString("#,###0.00")%>" class="formFieldTXT" onkeypress="javascript:return isDouble(event);"></div>		
				
				<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.dta_from")%></strong><br>
				<input type="text" name="dta_ins_from" id="dta_ins_from" value="<%=search_dta_ins_from%>" class="formFieldTXT"></div>
				<script>						
				$(function() {
					$('#dta_ins_from').datetimepicker({									
						format:'d/m/Y',
						closeOnDateSelect:true
					});		
				});
				</script> 
				<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.dta_to")%></strong><br>
				<input type="text" name="dta_ins_to" id="dta_ins_to" value="<%=search_dta_ins_to%>" class="formFieldTXT"></div>
				<script>						
				$(function() {
					$('#dta_ins_to').datetimepicker({									
						format:'d/m/Y',
						closeOnDateSelect:true
					});		
				});
				</script> 
				<br/>
				<input type="submit" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("frontend.template.annunci.label.search")%>" />					
				</div>
				</form>
				<br/>
				<br/>
			<%int counter = 0;
			if(bolFoundLista) {%>
				<div style="width:480px;height:400px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;" id="maplist"></div>			
				<%for(counter = fromContent; counter<= toContent;counter++){
					Ads ad = ads[counter];
					IList<object> pelements = null;
					bool foundpel = adsData.TryGetValue(ad.id, out pelements);
					FContent content = null;
					User user = null;
					bool hasUrgent = false;
					bool hasHighlight = false;
					
					if(foundpel){
						user = (User)pelements[1];
						content = (FContent)pelements[2];
						hasUrgent = Convert.ToBoolean(pelements[3]);
						hasHighlight = Convert.ToBoolean(pelements[4]);%>
						<div>
						<%if(hasUrgent){%>
							<div class="ads_urgent"></div>
						<%}%>
						<p class="<%if(hasHighlight){Response.Write("ads_highlight");}else{Response.Write("title_contenuti");}%>"><a href="javascript:openDetailContentPage(<%=content.id%>);"><%=content.title%></a></p>
						<%=content.summary%>
							
						<br/><b><%=lang.getTranslated("frontend.template_ads.label.ads_user")%>:</b> <%=user.username%><br/>
						<b><%=lang.getTranslated("frontend.template_ads.label.ads_type")%>:</b> <%if (ad.type == 0){Response.Write(lang.getTranslated("frontend.template_ads.label.sell"));}else{Response.Write(lang.getTranslated("frontend.template_ads.label.buy"));}%><br/>
						<%if(ad.price>0){Response.Write("<b>"+lang.getTranslated("frontend.template_ads.label.ads_price")+":</b>&euro;&nbsp;"+ad.price.ToString("#,###0.00")+"<br/>");}%>
						<b><%=lang.getTranslated("frontend.template_ads.label.ads_dta_ins")%>:</b> <%=ad.insertDate.ToString("dd/MM/yyyy HH:mm")%><br/><br/>					
						</div>
						<p class="line"></p>
					<%}
				}%>
				<div><CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" /></div>
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="frontend.ads.table.label.no_result_found" runat="server" /></strong></div>
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
