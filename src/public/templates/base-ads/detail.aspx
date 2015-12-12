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

function sendMail(){
	if(controllaCampiMail()){
		document.form_sendmail.submit();
	}else{
		return;
	}
}

function controllaCampiMail(){	
	var strMail = document.form_sendmail.email.value;
	if(strMail != ""){
		if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
			alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.alert.wrong_mail")%>");
			document.form_sendmail.email.focus();
			return false;
		}
	}else if(strMail == ""){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.insert_mail")%>");
		document.form_sendmail.email.focus();
		return false;
	}		
	
	if(!document.form_sendmail.acceptPrivacy.checked){
		alert("<%=lang.getTranslated("frontend.template_contatti.js.alert.confirm_privacy")%>");
		return false;
	}	

  <%if(confservice.get("use_recaptcha").value == "1") {%>
    // VECCHIA FUNZIONE PER CAPTCHA 	
    if(document.form_sendmail.captchacode.value == ""){
      alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
      document.form_sendmail.captchacode.focus();
      return false;
    }
  <%}else if(confservice.get("use_recaptcha").value == "2"){%>
    // FUNZIONE PER RECAPTCHA  
    if(document.form_sendmail.recaptcha_response_field.value == ""){
      alert("<%=lang.getTranslated("frontend.area_user.js.alert.insert_captchacode")%>");
      document.form_sendmail.recaptcha_response_field.focus();
      return false;
    }
  <%}%>
	
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
			<%if (content != null) {
				IList<object> pelements = null;
				bool foundpel = adsData.TryGetValue(content.id, out pelements);
				Ads ad = null;
				User user = null;
				bool hasUrgent = false;
				bool hasHighlight = false;
				
				if(foundpel){
					ad = (Ads)pelements[0];
					user = (User)pelements[1];
					hasUrgent = Convert.ToBoolean(pelements[2]);
					hasHighlight = Convert.ToBoolean(pelements[3]);
				}%>
				<div>
				<%if(hasUrgent){%>
					<div class="ads_urgent"></div>
				<%}%>
				<p class="<%if(hasHighlight){Response.Write("ads_highlight");}else{Response.Write("title_contenuti");}%>"><asp:Literal id="ctitle" runat="server" /></p>
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
				
				<%if(foundpel){%>
					<br/><b><%=lang.getTranslated("frontend.template_ads.label.ads_user")%>:</b> <%=user.username%><br/>
					<b><%=lang.getTranslated("frontend.template_ads.label.ads_type")%>:</b> <%if (ad.type == 0){Response.Write(lang.getTranslated("frontend.template_ads.label.sell"));}else{Response.Write(lang.getTranslated("frontend.template_ads.label.buy"));}%><br/>
					<%if(ad.price>0){Response.Write("<b>"+lang.getTranslated("frontend.template_ads.label.ads_price")+":</b>&euro;&nbsp;"+ad.price.ToString("#,###0.00")+"<br/>");}%>
					<b><%=lang.getTranslated("frontend.template_ads.label.ads_dta_ins")%>:</b> <%=ad.insertDate.ToString("dd/MM/yyyy HH:mm")%><br/><br/>
					
					<asp:Literal id="mailRespMsg" runat="server" />				
					<form method="post" action="<%=currentUrl%>" name="form_sendmail">
					<input type="hidden" value="sendmail" name="operation">
					<input type="hidden" value="<%=hierarchy%>" name="hierarchy">
					<input type="hidden" value="<%=categoryid%>" name="categoryid">
					<input type="hidden" value="<%=numPage%>" name="page">
					<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">
					<input type="hidden" value="<%=content.id%>" name="contentid">
					<input type="hidden" name="adsid" value="<%=ad.id%>">
					<input type="hidden" name="adstitle" value="<%=content.title%>">
					<input type="hidden" name="adsuser" value="<%=user.id%>">

					<p><strong><%=lang.getTranslated("frontend.template_ads.label.testo_intro_mail")%></strong><br/>
					<span style="font-size:9px;"><%=lang.getTranslated("frontend.template_ads.label.testo_intro_mail2")%></span></p>
					
					<%if(!String.IsNullOrEmpty(ad.phone)){%><b><%=lang.getTranslated("frontend.template_ads.label.phone")%>:</b>&nbsp;<%=ad.phone%><br/><br/><%}%>
					
					<ul>
					<li><span><%=lang.getTranslated("frontend.template_ads.label.email")%> (*)</span></li>
					<li><input type="text" name="email" value="" /></li>
					</ul>
					<ul>
					<li><br/><span><%=lang.getTranslated("frontend.template_ads.label.phone_requestor")%></span></li>
					<li><input type="text" name="phone" value="" /></li>
					</ul>
					<ul>
					<li><br/><span><%=lang.getTranslated("frontend.template_ads.label.testo_mail")%></span></li>
					<li><textarea name="message" rows="3"></textarea></li>
					</ul>
					<ul>
					<li><br/><span><%=lang.getTranslated("frontend.template_contatti.label.info_privacy")%> (*)</span></li>
					<li><textarea name="testo_privacy" rows="3"><%=lang.getTranslated("frontend.template_contatti.label.info_privacy_law")%></textarea></li>
					</ul>
					<ul>
					<li><br/><input type="checkbox" name="acceptPrivacy" value="1" hspace="0" vspace="0"><%=lang.getTranslated("frontend.template_contatti.label.privacy_accept")%><br/><br/></li>
					</ul>
					<ul>
					<li> 
					<%
					  if(Request["captcha_err"] == "1") {
						Response.Write("<span class=imgError>"+lang.getTranslated("frontend.area_user.manage.label.wrong_captcha_code")+"</span><br/>");
					  }
					  
					  if(confservice.get("use_recaptcha").value == "1"){%>
						<img id="imgCaptcha" width="210" align="left" style="padding-right:10px;" src="/common/include/captcha/base_captcha.aspx"/>
						<a href="javascript:void(0)" onclick="RefreshImage('imgCaptcha')"><%=lang.getTranslated("frontend.area_user.manage.label.change_captcha_img")%></a>
						<br/><input name="captchacode" style="margin-top:3px;" type="text" id="captchacode" /><br/><br/>            
					  <%}else if(confservice.get("use_recaptcha").value == "2"){%>
						<br/><%=CaptchaService.renderRecaptcha()%><br/>
					  <%}%>
					  <br/>					
					</li>
					</ul>    
					<ul>
					<li><br/><input type="button" name="send" value="<%=lang.getTranslated("portal.commons.button.label.sendmail")%>" onclick="javascript:sendMail();"></li>
					</ul>
					</div>					
					
					</form>					
				<%}%>					
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