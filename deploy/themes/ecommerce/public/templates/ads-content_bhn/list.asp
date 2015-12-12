<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
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

$(function() {
	$('#dta_ins_from').datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true
	});
});

$(function() {
	$('#dta_ins_to').datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true
	});
});
  
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
			if(bolHasObj) then
			tmpurl = request.ServerVariables("URL")
			tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
			%>
				<br/>
				<div id="content-center-prodotto">				
					<div style="width:480px;height:400px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;" id="maplist"></div>
					<form action="<%=tmpurl&"list.asp"%>" method="post" name="form_search" accept-charset="UTF-8">
					<input type="hidden" value="<%=request("gerarchia")%>" name="gerarchia" />
					<div>
					<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.ads_type")%></strong><br>
					<select name="ads_type" class="formFieldTXT">
					<option value=""></option>
					<option value="0" <%if("0"=search_ads_type)then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_ads.label.sell")%></option>
					<option value="1" <%if("1"=search_ads_type)then response.write("selected") end if%>><%=lang.getTranslated("frontend.template_ads.label.buy")%></option>
					</select>
					</div>
					<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.ads_title")%></strong><br>
					<input type="text" name="ads_title" value="<%=search_title%>" class="formFieldTXTMedium" /></div>	
					
					<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.price_from")%></strong><br>
					<input type="text" name="price_from" value="<%=search_price_from%>" class="formFieldTXT" onkeypress="javascript:return isDouble(event);"></div>
					<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.price_to")%></strong><br>
					<input type="text" name="price_to" value="<%=search_price_to%>" class="formFieldTXT" onkeypress="javascript:return isDouble(event);"></div>		
					
					<div style="float:left;padding-right:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.dta_from")%></strong><br>
					<input type="text" name="dta_ins_from" id="dta_ins_from" value="<%=search_dta_ins_from%>" class="formFieldTXT"></div>
					<div style="padding-left:5px;"><strong><%=lang.getTranslated("frontend.template_ads.label.dta_to")%></strong><br>
					<input type="text" name="dta_ins_to" id="dta_ins_to" value="<%=search_dta_ins_to%>" class="formFieldTXT"></div>
					<br/>
					<input type="submit" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("portal.commons.user_field.label.search")%>" />					
					</div>
					</form>
					<br/>
					<%		
					for newsCounter = FromNews to ToNews
						Set objSelNews = objTmpNews(newsCounter)
						detailURL = "#"
						if(bolHasDetailLink) then
							detailURL = objMenuFruizione.resolveHrefUrl(base_url, (modelPageNum+1), lang, objCategoriaTmp, objTemplateSelected, objPageTempl)
						end if
						
						bolHasHighlight=false
						bolHasUrgent=false
						if(bolHasAds)then
							on error Resume Next
							bolThisHasAd = true
							Set objCurrAds = objListAdsFind(objSelNews.getNewsID())
							Set objUserAds = objU.findUserByID(objCurrAds.getIDUtente())

							id_ads = objCurrAds.getID()
							ads_user = objUserAds.getUserName()
							ads_user_mail = objUserAds.getEmail()
							ads_type = objCurrAds.getAdsType()
							ads_price = objCurrAds.getPrice()
							strPhone = objCurrAds.getPhone()
							dta_ins =	objCurrAds.getDtaInserimento()
							
							Set objUserAds = nothing
							Set objCurrAds = nothing
							if Err.number <> 0 then
								bolHasHighlight=false
								bolHasUrgent=false
								bolThisHasAd = false
							end if				

							'********** cerco eventuali promozioni acquistate per l'annuncio corrente
							'********** se esistono promozioni attive imposto la grafica opportuna in base alla promozione
							'********** in questo template di dettaglio abilito la visualizzazione solo delle promozioni Highlight  (cod_element=ad-1) e Urgent (cod_element=ad-2)
							on error Resume Next
							Set objAdsPromotion = objAds.findAdsPromotionByID(id_ads) 
							for each q in objAdsPromotion
								if(objAdsPromotion(q).isActive())then
									cod_elem = objAdsPromotion(q).getCodElement()
									'response.write("cod_elem: "&cod_elem&"<br>")
									if (Instr(1, cod_elem, "ad-1", 1) > 0) then
										expire = Right(cod_elem,Len(cod_elem)-InStrRev(cod_elem,"#",-1,1))
										'response.write("expire: "&expire&"<br>")
										if(DateDiff("d",objAdsPromotion(q).getDtaInserimento(),now())<=Cint(expire))then
											bolHasHighlight=true
										end if
									elseif(Instr(1, cod_elem, "ad-2", 1) > 0)then
										expire = Right(cod_elem,Len(cod_elem)-InStrRev(cod_elem,"#",-1,1))
										'response.write("expire: "&expire&"<br>")
										if(DateDiff("d",objAdsPromotion(q).getDtaInserimento(),now())<=Cint(expire))then
											bolHasUrgent=true
										end if								
									end if
								end if
							next
							Set objAdsPromotion = nothing
							if Err.number <> 0 then
								bolHasHighlight=false
								bolHasUrgent=false
							end if
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
						<div id="prodotto-testo">
						<%if(bolHasUrgent)then%>
						<div class="ads_urgent"></div>
						<%end if%>
						<p class="<%if(bolHasHighlight)then response.write("ads_highlight") else response.write("title_contenuti") end if%>"><a href="javascript:openDetailContentPage('<%=detailURL%>', '<%=strGerarchia%>', <%=objSelNews.getNewsID()%>, <%=(modelPageNum+1)%>);"><%=objSelNews.getTitolo()%></a></p>
						<%if (Len(objSelNews.getAbstract1()) > 0) then response.Write(objSelNews.getAbstract1()) end if				
						
						if(bolThisHasAd)then%>
							<br/><b><%=lang.getTranslated("frontend.template_ads.label.ads_user")%>:</b> <%=ads_user%><br/>
							<b><%=lang.getTranslated("frontend.template_ads.label.ads_type")%>:</b> <%if (ads_type = 0) then response.Write(lang.getTranslated("frontend.template_ads.label.sell")) else response.Write(lang.getTranslated("frontend.template_ads.label.buy")) end if%><br/>
							<%if(ads_price<>"")then response.write("<b>"&lang.getTranslated("frontend.template_ads.label.ads_price")&":</b>&euro;&nbsp;"&FormatNumber(ads_price, 2,-1)&"<br/>") end if%>
							<b><%=lang.getTranslated("frontend.template_ads.label.ads_dta_ins")%>:</b> <%=FormatDateTime(dta_ins,2)&" "&FormatDateTime(dta_ins,vbshorttime)%><br/><br/>
						<%end if%>
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
Set objU = nothing
Set objAds = Nothing
Set News = Nothing
%>
