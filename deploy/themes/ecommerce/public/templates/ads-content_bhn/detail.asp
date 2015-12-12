<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<!-- #include virtual="/common/include/captcha/adovbs.asp"-->
<!-- #include virtual="/common/include/captcha/iasutil.asp"-->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include virtual="/common/include/captcha/functions.asp"--> 
<!-- #include file="include/init2.inc" -->
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
var mapid = "map";
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

function sendMail(){
	if(controllaCampiMail()){
		return true;
		//document.form_send_mail.submit();
	}else{
		return false;
	}
}

function controllaCampiMail(){	
	var strMail = document.form_send_mail.email.value;
	if(strMail != ""){
		if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
			alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.alert.wrong_mail")%>");
			document.form_send_mail.email.focus();
			return false;
		}
	}else if(strMail == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_mail")%>");
		document.form_send_mail.email.focus();
		return false;
	}		
	
	if(!document.form_send_mail.acceptPrivacy.checked){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.confirm_privacy")%>");
		return false;
	}	

  <%if(Application("use_recaptcha") = 0) then%>
    if(document.form_send_mail.captchacode.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.captchacode.focus();
      return false;
    }
    
    // imposto campo hidden sent_captchacode 
    // perchè quello originale non viene recuperato in process
    document.form_send_mail.sent_captchacode.value = document.form_send_mail.captchacode.value;
  <%else%>
    // FUNZIONE PER RECAPTCHA  
    if(document.form_send_mail.recaptcha_response_field.value == ""){
      alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_captchacode")%>");
      document.form_send_mail.recaptcha_response_field.focus();
      return false;
    }
      // imposto campo hidden sent_recaptcha_challenge_field e  sent_recaptcha_response_field
    // perchè quello originale non viene recuperato in process
    document.form_send_mail.sent_recaptcha_challenge_field.value = document.form_send_mail.recaptcha_challenge_field.value;
    document.form_send_mail.sent_recaptcha_response_field.value = document.form_send_mail.recaptcha_response_field.value;
  <%end if%>
	
	return true;
}


function RefreshImage(valImageId) {
	var objImage = document.images[valImageId];
	if (objImage == undefined) {
		return;
	}
	var now = new Date();
	objImage.src = objImage.src.split('?')[0] + '?x=' + now.toUTCString();
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

			<div align="left">
			<%if (bolHasObj) then
				bolHasHighlight=false
				bolHasUrgent=false
				if(bolHasAds)then
					Set objU = new UserClass
					Set objUserAds = objU.findUserByID(objCurrAds.getIDUtente())

					id_ads = objCurrAds.getID()
					ads_id_user = objCurrAds.getIDUtente()
					ads_user = objUserAds.getUserName()
					ads_user_mail = objUserAds.getEmail()
					ads_type = objCurrAds.getAdsType()
					ads_price = objCurrAds.getPrice()
					strPhone = objCurrAds.getPhone()
					dta_ins =	objCurrAds.getDtaInserimento()
					ads_title = objCurrentNews.getTitolo()					

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
					end if
					Set objUserAds = nothing					
					Set objU = nothing
				end if%>
				<div>
				<%if(bolHasUrgent)then%>
				<div class="ads_urgent"></div>
				<%end if%>
				<p class="<%if(bolHasHighlight)then response.write("ads_highlight") else response.write("ads_title") end if%>"><%=objCurrentNews.getTitolo()%></p>				
				<div style="float:right;width:300px;height:250px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;margin-left:3px;" id="map"></div>
				<%
				if (Len(objCurrentNews.getAbstract1()) > 0) then response.Write(objCurrentNews.getAbstract1()) end if
				if (Len(objCurrentNews.getAbstract3()) > 0) then response.Write(objCurrentNews.getAbstract3()) end if
				response.Write(objCurrentNews.getTesto())
				
				if(bolHasAttach) then 
					for each key in attachMap
						if(attachMap(key).count > 0)then%>
							<br/><br/><strong><%=lang.getTranslated(attachMultiLangKey(key))%></strong><br/>
							<%for each item in attachMap(key)%>
								<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popup.asp?id_allegato="&item.getFileID()&"&parent_type=1"%>','popupallegati',400,400,100,100)"><%=item.getFileName()%></a><br>
							<%next
						end if
					next
				end if
				Set objCurrentNews = nothing
				
				if(bolHasAds)then%>
					<br/><br/><b><%=lang.getTranslated("frontend.template_ads.label.ads_user")%>:</b> <%=ads_user%><br/>
					<b><%=lang.getTranslated("frontend.template_ads.label.ads_type")%>:</b> <%if (ads_type = 0) then response.Write(lang.getTranslated("frontend.template_ads.label.sell")) else response.Write(lang.getTranslated("frontend.template_ads.label.buy")) end if%><br/>
					<%if(ads_price<>"")then response.write("<b>"&lang.getTranslated("frontend.template_ads.label.ads_price")&":</b>&euro;&nbsp;"&FormatNumber(ads_price, 2,-1)&"<br/>") end if%>
					<b><%=lang.getTranslated("frontend.template_ads.label.ads_dta_ins")%>:</b> <%=FormatDateTime(dta_ins,2)&" "&FormatDateTime(dta_ins,vbshorttime)%><br/><br/>					

					<%
					' recupero url corrente per definire path a confirm.asp
					tmpurl = request.ServerVariables("URL")
					tmpurl = Mid(tmpurl,1,InStrRev(tmpurl,"/",-1,1))
					%>
					<div id="profilo-utente">
					<form action="<%=tmpurl&"confirm.asp"%>" method="post" name="form_send_mail" onSubmit="return sendMail();">
					<input type="hidden" name="gerarchia" value="<%=strGerarchia%>">
					<input type="hidden" name="id_ads" value="<%=id_ads%>">
					<input type="hidden" name="ads_title" value="<%=ads_title%>">
					<input type="hidden" name="ads_id_user" value="<%=ads_id_user%>">
					<input type="hidden" name="sent_captchacode" value="">
					<input type="hidden" name="sent_recaptcha_challenge_field" value="">
					<input type="hidden" name="sent_recaptcha_response_field" value="">

					<p><strong><%=lang.getTranslated("frontend.template_ads.label.testo_intro_mail")%></strong><br/>
					<span style="font-size:9px;"><%=lang.getTranslated("frontend.template_ads.label.testo_intro_mail2")%></span></p>
					
					<%if(strPhone<>"")then%><b><%=lang.getTranslated("frontend.template_ads.label.phone")%>:</b>&nbsp;<%=strPhone%><br/><%end if%>
					
					<ul>
					<li><span><%=lang.getTranslated("frontend.template_ads.label.email")%> (*)</span></li>
					<li><input type="text" name="email" value="" /></li>
					</ul>
					<ul>
					<li><span><%=lang.getTranslated("frontend.template_ads.label.testo_mail")%></span></li>
					<li><textarea name="testo" rows="3"></textarea></li>
					</ul>
					<ul>
					<li><span><%=lang.getTranslated("frontend.template_contatti.label.info_privacy")%> (*)</span></li>
					<li><textarea name="testo_privacy" rows="3"><%=lang.getTranslated("frontend.template_contatti.label.info_privacy_law")%></textarea></li>
					</ul>
					<ul>
					<li><input type="checkbox" name="acceptPrivacy" value="1" hspace="0" vspace="0"><%=lang.getTranslated("frontend.template_contatti.label.privacy_accept")%></li>
					</ul>
					<ul>
					<li>    
					<%
					if(request("captcha_err") = 1) then
					response.write("<span  class=imgError>"&lang.getTranslated("frontend.template_contatti.label.wrong_captcha_code") & "</span><br/>")
					end if

					if(Application("use_recaptcha") = 0) then%>
					<br/><img id="imgCaptcha" src="<%=Application("baseroot")&"/common/include/captcha/base_captcha.asp"%>" />&nbsp;&nbsp;<input name="captchacode" type="text" id="captchacode" />
					<br/><a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%'=lang.getTranslated("frontend.template_contatti.label.change_captcha_img")%></a>
					<%else%>
					<br/><%=recaptcha_challenge_writer(Application("recaptcha_pub_key"))%>
					<%end if%>
					</li>
					</ul>    
					<ul>
					<li><br/><input type="submit" name="submit" value="<%=lang.getTranslated("frontend.template_contatti.button.send.label")%>" vspace="0" align="absmiddle">&nbsp;<input type="reset" name="reset" value="<%=lang.getTranslated("frontend.template_contatti.button.cancel.label")%>" vspace="0" align="absmiddle"></li>
					</ul>
					</div>
					</form>
					</div>

				<%end if%>
				</div>
				<div id="torna"><a href="<%=Application("baseroot") & "/common/include/feedRSS.asp?gerarchia="&strGerarchia&"&id_news="&id_news&"&page="&numPage&"&modelPageNum="&modelPageNum%>" target="_blank"><img src="<%=Application("baseroot")&"/common/img/rss_image.gif"%>" vspace="3" hspace="3" border="0" align="right" alt="RSS"></a></div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
			</div>
		</div>
		<!-- #include virtual="/public/layout/include/menu_vert_dx.inc" -->
		<!-- #include virtual="/public/layout/addson/contents/news_comments_widget.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set objAds = Nothing
Set News = Nothing
%>