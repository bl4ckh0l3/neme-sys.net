<%@ Page Language="C#" AutoEventWireup="true" CodeFile="results.aspx.cs" Inherits="_Results" Debug="false" %>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="Newtonsoft.Json" %>
<%@ Import Namespace="Newtonsoft.Json.Linq" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<!DOCTYPE html>
<html>
<head>
<title><%=pageTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@shuttlegenius.com">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />

<!--[if IE]>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<![endif]-->
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Favicon -->
<link rel="apple-touch-icon-precomposed" sizes="144x144" href="#">
<link rel="shortcut icon" href="#">
<!-- CSS Global -->
<link href="/common/plugins/bootstrap/css/bootstrap.min.css" rel="stylesheet">
<link href="/common/plugins/bootstrap-select/css/bootstrap-select.min.css" rel="stylesheet">
<link href="/common/plugins/fontawesome/css/font-awesome.min.css" rel="stylesheet">
<link href="/common/plugins/owl-carousel2/assets/owl.carousel.min.css" rel="stylesheet">
<link href="/common/plugins/owl-carousel2/assets/owl.theme.default.min.css" rel="stylesheet">
<link href="/common/plugins/datetimepicker/css/bootstrap-datetimepicker.min.css" rel="stylesheet">
<!-- Theme CSS -->
<link href="/common/css/theme.css" rel="stylesheet">
<!-- Head Libs -->
<script src="/common/plugins/modernizr.custom.js"></script>
<!--[if lt IE 9]>
<script src="/common/plugins/iesupport/html5shiv.js"></script>
<script src="/common/plugins/iesupport/respond.min.js"></script>
<![endif]-->
<script src="/common/plugins/bootstrap/js/bootstrap.min.js"></script>
<script src="/common/plugins/bootstrap-select/js/bootstrap-select.min.js"></script>	
<script src="/common/plugins/jquery.easing.min.js"></script>
<script src="/common/plugins/jquery.smoothscroll.min.js"></script>
<script src="/common/plugins/datetimepicker/js/moment-with-locales.min.js"></script>
<script src="/common/plugins/datetimepicker/js/bootstrap-datetimepicker.min.js"></script>   
<script src="/common/plugins/owl-carousel2/owl.carousel.min.js"></script>
<script type="text/javascript" src="/common/js/widget.js"></script>
<script src='/common/js/moment.min.js'></script>

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

function formatTime(hours,minutes){
	var h = " ora ";
	var m = " minuto";
	var date = "";
	
	if(Number(minutes) >1){m = " minuti";}
	
	if(Number(hours) >0){
		if(Number(hours) >1){h = " ore ";}
		date = hours +h+ minutes +m;
	}else{
		date=minutes +m;
	}
	
	return date;
}

function addZero(i) {
    if (i < 10) {
        i = "0" + i;
    }
    return i;
}
function myFunction(minutes) {
	var h = (Number(minutes) - Number(minutes) % 60) / 60;
	var m = Number(minutes) - Number(h)*60;   
    var formattedDate = formatTime(h,m);
    
	$('#durationSelected').empty();
	$('#durationSelected').append(formattedDate);
}


function filterResultByDuration(duration){
	$(".myresults").each(function(){
		var tduration = $(this).attr("duration");
		if(Number(tduration)>duration){
			$(this).hide();
		}else{
			$(this).show();
		}
	});	
}

function filterResultByProvider(){
	var providers = []; 
	$('input[name*="service_type"]').each( function(){
		if($(this).is(':checked')){
			providers.push($(this).val());
		}
	});	


	$(".myresults").each(function(){
		var tprovider = $(this).attr("provider");
		
		if(providers.indexOf(tprovider) == -1){
			$(this).hide();
		}else{
			$(this).show();
		}
	});	
}

function deeplinkRedirect(url){
	window.open(url,'_blank');
}
</script>
</head>
<body id="home" class="wide">

      <!-- PRELOADER -->
      <div id="preloader">
         <div id="preloader-status">
            <div class="spinner">
               <div class="rect1"></div>
               <div class="rect2"></div>
               <div class="rect3"></div>
               <div class="rect4"></div>
               <div class="rect5"></div>
            </div>
            <div id="preloader-title"><lang:getTranslated keyword="frontend.transfer.search.preloader.title" runat="server" /></div>
         </div>
      </div>
      <!-- /PRELOADER -->
      
      <!-- WRAPPER -->
      <div class="wrapper">
         <!-- HEADER -->
         <header class="header fixed">
            <div class="header-wrapper">
               <div class="container">
                  <!-- Logo -->
                  <!--div class="logo"-->
                     <a href="<%=mainPage%>">
                     <!--img src="/common/img/Logo.png" alt="<lang:getTranslated keyword="frontend.transfer.search.logo.alt" runat="server" />"/-->
                     <img src="/common/img/logo_tentative.png" height="62px" alt="<lang:getTranslated keyword="frontend.transfer.search.logo.alt" runat="server" />"/>
                     </a>
                  <!--/div-->
                  <!-- /Logo -->
               </div>
            </div>
         </header>
         <!-- /HEADER -->
         <!-- CONTENT AREA -->
         <div class="content-area">
			<%if (content != null) {%>
				<div>
				<!--<p><strong><asp:Literal id="ctitle" runat="server" /></strong></p>-->
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
		
			<%}%>
			</div>
			<div style="margin-bottom:50px;display:block;"></div>
			<div style="float:left;display:block;width:20%;margin-left:5px;">
				<div>   
					<p><strong>pickup:</strong> <%=searchFrom%></p>
					<p><strong>dropoff:</strong> <%=searchTo%></p> 
					<p><strong>passeggeri:</strong> <%=passengers%></p> 
					<div>
						<p><strong>partenza:</strong> <%=searchDtOut.ToString("dd/MM/yyyy HH:mm")%></p>  
						<%if(!string.IsNullOrEmpty(Request["returnDate"])){%>
						<p><strong>ritorno:</strong> <%=searchDtRtn.ToString("dd/MM/yyyy HH:mm")%></p>
						<%}%>
					</div> 
				</div>   
				<div style="margin-top:50px;">   
					<p><strong>Tipo di veicolo</strong></p> 
					<div>
						<%foreach(string type in types.Keys){%>
						<p><input type="checkbox" name="service_type" value="<%=type%>" onclick="filterResultByProvider()" checked="checked">&nbsp;&nbsp;<strong><%=type%></strong></p>
						<%}%>
					</div> 
				</div> 
				
				<div style="margin-top:50px;">   
					<p><strong>Durata del viaggio</strong></p> 
					<div id="slider"></div> 
				</div> 
				<p id="durationSelected"></p>
				<script>
				$(document).ready(function() {
					$("#slider").slider({
						min: <%=minDuration%>,
						max: <%=maxDuration%>,
						range: <%=minDuration%>,
						step: 1,
						value: <%=maxDuration%>,
						change: function( event, ui ) {
							myFunction(ui.value);
							filterResultByDuration(ui.value);
						}
					});
					myFunction(<%=maxDuration%>);
				});
				</script>
			</div>
			<div style="width:75%;text-align:right;float:right;margin-right:10px">
			<%
			foreach(Transfer tr in tresult){
				int duration = tr.duration;
				int hours = (duration-duration%60)/60;
				int minutes = duration-hours*60;
				
				string date = "";
				string h = " ora ";
				string m = " minuto";
				
				if(minutes >1){m = " minuti";}
				
				if(hours >0){
					if(hours >1){h = " ore ";}
					date = hours +h+ minutes +m;
				}else{
					date=minutes+m;
				}
				
				string visible = "display:block;";
				if(!"XB".Equals(tr.serviceName) && passengers>tr.seat){
					visible = "display:none;";
				}
				%>
				
				<div class="myresults" style="margin-bottom:10px;margin-top:10px;clear:left;border-top: 2px solid rgb(201, 201, 201);<%=visible%>" provider="<%=tr.serviceName%>" duration="<%=tr.duration%>">
					<div style="">
						<div style="padding-right:20px;float:left;">
							<strong><%=tr.serviceName%></strong>
						</div>
						<div style="display:inline-block;">
							1-<%=tr.seat%> passeggeri
						</div>
					</div>
					<div style="float:left;display:inline-block;">
						<div style="background-color:#f3f2f5;padding:10px;margin:5px;min-width:100px;float:left;display:inline-block;">
							<%=tr.maxLuggage%> valigie
						</div>
						<div style="background-color:#f3f2f5;padding:10px;margin:5px;min-width:100px;display:inline-block;">
							<strong>durata:</strong> <%=date%>
						</div>
						<div>
							<img src="<%=tr.logo%>" width=70 align=left>
						</div>
					</div>
					<div style="float:left;display:inline-block;">
						<img src="<%=tr.image%>" width=200 align=left style="margin-bottom:5px;">		
					</div>
					<div style="">
						<%=tr.currency%> <%=tr.amount%> <input type=button value=PRENOTA onclick="javascript:deeplinkRedirect('<%=tr.deeplink%>');">	
						<div style="font-size:10px">
							servizio offerto da:</br>
							<%=tr.operatorName%>
						</div>
					</div>
				</div>
			<%}%>
			</div>

         </div>
         <!-- /CONTENT AREA -->
         
         <!-- FOOTER -->
         <footer class="footer">
        
            <div class="footer-meta">
               <div class="container">
                  <div class="row">
                     <div class="col-sm-12">
                        <div class="copyright">
                        &copy; <asp:Literal id="copyr" runat="server" /> <lang:getTranslated keyword="frontend.bottom.label.copyright" runat="server" />
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </footer>
         <!-- /FOOTER -->
         <div id="to-top" class="to-top"><i class="fa fa-angle-up"></i></div>
      </div>
      <!-- /WRAPPER -->
      <!-- JS Global -->
      <script src="/common/js/theme.js"></script>
</body>
</html>