<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init1.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%>
<script language="Javascript">
var mapid = "maplist";
var latlng = new Array();
var infowin = new Array();
<%if(objListPoint.count>0)then
	for each k in objListPoint
		//response.write("//getLatitude: "&k.getLatitude()&" -getLongitude: "&k.getLongitude())
		if(k.getLatitude()<>"" AND k.getLongitude()<>"")then%>
			latlng.push(new GLatLng(replaceCommaInNumber('<%=k.getLatitude()%>'), replaceCommaInNumber('<%=k.getLongitude()%>')));
			infowin.push("<%=objListPoint(k)%>");
		<%end if
	next%>
<%end if%>

function showMap(mapid){
	if (GBrowserIsCompatible()) {
		$('#'+mapid).show();		
		var map = new GMap2(document.getElementById(mapid));	
		map.setCenter(new GLatLng(0, 0), 2);
		map.addControl(new GLargeMapControl());	
		var latlngbounds = new GLatLngBounds( );

		if(latlng.length==1){
			map.setCenter(latlng[0],10);
		}else{
			for (var j=0; j<latlng.length; j++){
				latlngbounds.extend(latlng[j]);
			}
			map.setCenter(latlngbounds.getCenter(), map.getBoundsZoomLevel(latlngbounds));
		}

		for (var j=0; j<latlng.length; j++){
			//alert("lat: "+latlng[j].lat()+" -lng: "+latlng[j].lng());
			var infowintxt = infowin[j];
			//alert("infowin: "+infowintxt);
			var marker = createMarker(latlng[j], infowintxt);
			map.addOverlay(marker);
		}
	} 
}

function createMarker(point,html) {
  var marker = new GMarker(point);
  GEvent.addListener(marker, "click", function() {
    marker.openInfoWindowHtml(html);
  });
  return marker;
}
	
jQuery(document).ready(function(){
	<%if(objListPoint.count>0)then%>
		showMap(mapid);
	<%end if%>
});

function replaceCommaInNumber(number){
	return number.replace(',','.');
}
  
function openDetailContentPage(strAction, strGerarchia, numIdNews, numPageNum){
    document.form_detail_link_news.action=strAction;
    document.form_detail_link_news.gerarchia.value=strGerarchia;
    document.form_detail_link_news.id_news.value=numIdNews;
    document.form_detail_link_news.modelPageNum.value=numPageNum;
    document.form_detail_link_news.submit();
}
</script> 
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- include virtual="/public/layout/include/menu_orizz.inc" -->
		<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">
			<!-- #include virtual="/public/layout/include/menutips.inc" -->

			<div align="left" id="contenuti">
			<%
			'************** codice per la lista news e paginazione
			'response.write("objListPoint.count: "&objListPoint.count&"<br>")
			'response.write("bolHasObj: "& bolHasObj &"<br>")
			if(bolHasObj) then%>
				<br/>
				<div id="content-center-prodotto">				
					<div style="width:480px;height:400px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;" id="maplist">
					</div>
					<%		
					for newsCounter = FromNews to ToNews
						Set objSelNews = objTmpNews(newsCounter)
						detailURL = "#"
						if(bolHasDetailLink) then
							detailURL = objMenuFruizione.resolveHrefUrl(base_url, (modelPageNum+1), lang, objCategoriaTmp, objTemplateSelected, objPageTempl)
						end if%>
						
						<div id="prodotto-immagine">
						<%if not(isNull(objSelNews.getFilePerNews())) AND not(isEmpty(objSelNews.getFilePerNews())) then
							Dim hasNotSmallImg
							hasNotSmallImg = true
							Set objListaFilePerNews = objSelNews.getFilePerNews()			
							for each xObjFile in objListaFilePerNews
								Set objFileXNews = objListaFilePerNews(xObjFile)
								iTypeFile = objFileXNews.getFileTypeLabel()
								if(Cint(iTypeFile) = 1) then%>	
									<img src="<%=Application("dir_upload_news")&objFileXNews.getFilePath()%>" alt="<%=objSelNews.getTitolo()%>" width="140" height="130" />
									<%hasNotSmallImg = false
									Exit for
								end if
								Set objFileXNews = nothing	
							next		
							if(hasNotSmallImg) then%>
								<img width="140" height="130" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
							<%end if
							Set objListaFilePerNews = nothing
						else%>
							<img width="140" height="130" src="<%=Application("baseroot")&"/common/img/spacer.gif"%>" hspace="0" vspace="0" border="0">
						<%end if%>          
						</div>						
						
						<div id="prodotto-testo"><p class="title_contenuti"><a href="javascript:openDetailContentPage('<%=detailURL%>', '<%=strGerarchia%>', <%=objSelNews.getNewsID()%>, <%=(modelPageNum+1)%>);"><%=objSelNews.getTitolo()%></a></p>
						<%if (Len(objSelNews.getAbstract1()) > 0) then response.Write(objSelNews.getAbstract1()) end if%>
						</div>
						<div id="clear"></div>
						<div id="prodotto-footer"></div>
						<%Set objSelNews = nothing
					next%>
					<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "") end if%></div>
					<div id="torna"><a href="<%=Application("baseroot") & "/common/include/feedRSS.asp?gerarchia="&strGerarchia%>" target="_blank"><img src="<%=Application("baseroot")&"/common/img/rss_image.gif"%>" vspace="3" hspace="3" border="0" align="right" alt="RSS"></a></div>
				</div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
			</div>
			<form action="" method="post" name="form_detail_link_news">	
			<input type="hidden" value="" name="id_news">	
			<input type="hidden" value="" name="modelPageNum">	
			<input type="hidden" value="" name="gerarchia">	
			<input type="hidden" value="<%=numPage%>" name="page">
			<input type="hidden" value="<%=order_by%>" name="order_by">            
			</form>	
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set objCat = nothing
Set objPageTempl = nothing
Set objTemplate = nothing
Set objMenuFruizione = nothing
Set objListPoint = nothing
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>
