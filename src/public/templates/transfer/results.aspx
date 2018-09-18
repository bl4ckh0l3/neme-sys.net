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
				
				<CommentsWidgetWrapperControl:render runat="server" ID="cwwc1" index="1"/>
		
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
			<%}%>
			</div>
			
			<div>   
				<p><strong>pickup:</strong> <%=searchFrom%></p>
				<p><strong>dropoff:</strong> <%=searchTo%></p> 
				<div>
					<p><strong>partenza:</strong> <%=searchDtOut.ToString("dd/MM/yyyy hh:mm")%></p>  
					<%if(!string.IsNullOrEmpty(Request["returnDate"])){%>
					<p><strong>ritorno:</strong> <%=searchDtRtn.ToString("dd/MM/yyyy hh:mm")%></p>
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
				%>
				
				<div class="myresults" style="margin-bottom:10px;margin-top:10px;clear:left;border-top: 2px solid rgb(201, 201, 201);" provider="<%=tr.serviceName%>" duration="<%=tr.duration%>">
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
						<%=tr.currency%> <%=tr.amount%> <input type=submit value=PRENOTA>	
						<div style="font-size:10px">
							servizio offerto da:</br>
							<%=tr.operatorName%>
						</div>
					</div>
				</div>
			<%}%>				
			
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