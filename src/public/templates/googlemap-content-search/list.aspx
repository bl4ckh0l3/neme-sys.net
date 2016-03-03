<%@ Page Language="C#" AutoEventWireup="true" CodeFile="list.aspx.cs" Inherits="_List" Debug="false" %>
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
var markers = new Array();
var map, mc;
var drawingManager;
var lastSelectionType="";
var currentOverlay = new Array();
var currentOverlayCoordinates;
var hasGeoSearchActive = false;
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
          center: new google.maps.LatLng(41.87194,12.567379999999957),
          zoom: 5,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        map = new google.maps.Map(document.getElementById(mapid),  mapOptions);
	var latlngbounds = new google.maps.LatLngBounds();

	if(latlng.length==1){
		map.setCenter(latlng[0]);
		map.setZoom(10);
	}else if(latlng.length>1){
		for (var j=0; j<latlng.length; j++){
			latlngbounds.extend(latlng[j]);
		}
		map.fitBounds(latlngbounds);
	}

	for (var j=0; j<latlng.length; j++){
		var infowintxt = infowin[j];
		var marker = createMarker(latlng[j], infowintxt, map);
	}
	
	setDrawingManager(map);
	
	<%
	if (bolHasGeoSearchActive){
	 
		Response.Write("createShapes('"+((IDictionary<string,object>)Session["geolocalsearchpoly"])["current_overlay"]+"', map, true);");		
		Response.Write("lastSelectionType='"+((IDictionary<string,object>)Session["geolocalsearchpoly"])["last_selection"]+"';");
	}%>
	
	var mcOptions = {gridSize: 50, maxZoom: 15};
	mc = new MarkerClusterer(map, markers, mcOptions);
}


function setDrawingManager(mapObj){
	drawingManager = new google.maps.drawing.DrawingManager({
		drawingMode: google.maps.drawing.OverlayType.POLYGON,
		drawingControl: true,
		drawingControlOptions: {
			position: google.maps.ControlPosition.TOP_CENTER,
			drawingModes: [
				//google.maps.drawing.OverlayType.MARKER,
				google.maps.drawing.OverlayType.CIRCLE,
				google.maps.drawing.OverlayType.POLYGON,
				//google.maps.drawing.OverlayType.POLYLINE,
				//google.maps.drawing.OverlayType.RECTANGLE
			]
		},
		circleOptions: {
			clickable: false,
			zIndex: 1,
			editable: true
		},
		polygonOptions: {
			zIndex: 1,
			editable: true			
		}
	});

	drawingManager.setMap(mapObj);

	google.maps.event.addListener(drawingManager, 'overlaycomplete', function(event) {
		if (event.type == google.maps.drawing.OverlayType.CIRCLE) {
			setCircle(event);
			lastSelectionType = event.type;
			currentOverlay.push(event.overlay);
			drawingManager.setOptions({
				drawingControl: false,
				drawingMode: null
			});
			$('#georesetbuttons').show();
			hasGeoSearchActive=true;	
		}
		else if (event.type == google.maps.drawing.OverlayType.POLYGON) {
			setVertices(event);
			lastSelectionType = event.type;
			currentOverlay.push(event.overlay);
			drawingManager.setOptions({
				drawingControl: false,
				drawingMode: null
			});
			$('#georesetbuttons').show();	
			hasGeoSearchActive=true;
		}
	});
}

function setVertices(event) {
	var type = 1;
	var vertices = event.overlay.getPath();
	currentOverlayCoordinates=type+"#";
	var contentString = "type="+type+"&vertices=";
	for (var i =0; i < vertices.length; i++) {
		var xy = vertices.getAt(i);
		contentString += xy.lat() +"," + xy.lng() + "|";		
		currentOverlayCoordinates+= xy.lat() +"," + xy.lng() + "|";
	}
	contentString += vertices.getAt(0).lat() +"," + vertices.getAt(0).lng();
	currentOverlayCoordinates+= vertices.getAt(0).lat() +"," + vertices.getAt(0).lng();
	
	dataString = contentString+"&current_overlay="+currentOverlayCoordinates+"&last_selection="+event.type; 
	//alert(dataString);	
	$.ajax({  
		type: "POST",  
		url: "<%=tmpurl+"/ajaxsetgeolocalsearch.aspx"%>",  
		data: dataString,  
		success: function(response) {  
			//$('#'+container).html(response); 
			//alert("funziona");
			document.form_geo_search.search_active.value=1;
		}
	}); 
}

function setCircle(event){
	var type = 2;
	var radius = parseInt(event.overlay.getRadius());
	var center = event.overlay.getCenter();
	currentOverlayCoordinates=type+"#"+radius+"#"+center.lat()+","+center.lng();
	var contentString = "";
	contentString+="type="+type+"&radius="+radius+"&center="+center.lat()+","+center.lng();
	dataString = contentString+"&current_overlay="+currentOverlayCoordinates+"&last_selection="+event.type;   
	//alert(dataString);
	$.ajax({  
		type: "POST",  
		url: "<%=tmpurl+"/ajaxsetgeolocalsearch.aspx"%>",  
		data: dataString,  
		success: function(response) {  
			//$('#'+container).html(response); 
			//alert("funziona");
			document.form_geo_search.search_active.value=1;
		}
	}); 	
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
	markers.push(marker);
	return marker;
}

function reActivateDrawingMode(){
	for(var i=0; i<currentOverlay.length;i++){
		currentOverlay[i].setMap(null);
	}
	for(var i=0; i<markers.length;i++){
		markers[i].setMap(null);
	}
	mc.removeMarkers(markers);
	
	currentOverlayCoordinates="";	
	dataString = "type=0"; 
	$('#searchresetbuttons').hide();
	$('#georesetbuttons').hide();
	document.form_geo_search.search_active.value=0;
	$('#content_list_container').hide();
	hasGeoSearchActive=false;
	$.ajax({  
		type: "POST",  
		url: "<%=tmpurl+"/ajaxsetgeolocalsearch.aspx"%>",  
		data: dataString,  
		success: function(response) { 
				if($('#field_regione_provincia').val()!= ""){
				drawingManager.setOptions({
					drawingControl: true,
					drawingMode: lastSelectionType
				});
			}
		}
	}); 
}

function enableDrawingMode(){
	if(drawingManager){
		var selectionMode = lastSelectionType;
		if(selectionMode==""){
			selectionMode = google.maps.drawing.OverlayType.POLYGON;
		}
		drawingManager.setOptions({
			drawingControl: true,
			drawingMode: selectionMode
		});		
	}
}

function disableDrawingMode(){
	if(drawingManager){
		drawingManager.setOptions({
			drawingControl: false,
			drawingMode: null
		});		
	}
}

function sendGeoSearch(){
	if(document.form_geo_search.price_from.value!= "" || document.form_geo_search.price_to.value !=""){
		document.form_geo_search.field_prezzo.value = document.form_geo_search.price_from.value + ' x ' + document.form_geo_search.price_to.value;
	}else{
		document.form_geo_search.field_prezzo.value ="";
	}
	
	if(document.form_geo_search.superficie_from.value!= "" || document.form_geo_search.superficie_to.value !=""){
		document.form_geo_search.field_superficie.value = document.form_geo_search.superficie_from.value + ' x ' + document.form_geo_search.superficie_to.value;
	}else{
		document.form_geo_search.field_superficie.value ="";
	}

	if(document.form_geo_search.locali_from.value!= "" || document.form_geo_search.locali_to.value !=""){
		document.form_geo_search.field_locali.value = document.form_geo_search.locali_from.value + ' x ' + document.form_geo_search.locali_to.value;
	}else{
		document.form_geo_search.field_locali.value ="";
	}

	form_geo_search.submit();
}

function resetGeoSearch(){
	for(var i=0; i<currentOverlay.length;i++){
		currentOverlay[i].setMap(null);
	}
	currentOverlayCoordinates="";	
	dataString = "type=3"; 
	$('#georesetbuttons').hide();
	document.form_geo_search.search_active.value=0;
	hasGeoSearchActive=false;
	$.ajax({  
		type: "POST",  
		url: "<%=tmpurl+"/ajaxsetgeolocalsearch.aspx"%>",  
		data: dataString,  
		success: function(response) {  
			drawingManager.setOptions({
				drawingControl: true,
				drawingMode: lastSelectionType
			});		
		}
	}); 	
}

function createShapes(referStr, map, exist){
	var arr=referStr.split("#");
	
	if(arr[0]=="1"){
		var arrVertices=arr[1].split("|");
		createPolygon(arrVertices, map, exist);
	}else if(arr[0]=="2"){
		var radius = arr[1];
		var center = arr[2].split(",");
		createCircle(radius, center, map, exist);
	}
	
	if(exist){
		hasGeoSearchActive = true;
	}
}

function createPolygon(vertices, map, exist){
	var polyCoords = [];
	var latlngbounds = new google.maps.LatLngBounds();
	
	for(var i=0; i<vertices.length;i++){
		coords = vertices[i].split(",");
		var point = new google.maps.LatLng(coords[0], coords[1]);
		polyCoords.push(point);
		latlngbounds.extend(point);
	}

	newPoly = new google.maps.Polygon({
		paths: polyCoords
	});

	newPoly.setMap(map);
	map.fitBounds(latlngbounds);
	currentOverlay.push(newPoly);

	if(exist){
		drawingManager.setOptions({
			drawingControl: false,
			drawingMode: null
		});
		$('#georesetbuttons').show();		
	}
}

function createCircle(radiusPar, centerArr, map, exist){
	var circleOptions = {
	map: map,
	center: new google.maps.LatLng(centerArr[0],centerArr[1]),
	radius: parseInt(radiusPar)
	};
	newCircle = new google.maps.Circle(circleOptions);
	map.fitBounds(newCircle.getBounds());
	currentOverlay.push(newCircle);

	if(exist){
		drawingManager.setOptions({
			drawingControl: false,
			drawingMode: null
		});
		$('#georesetbuttons').show();
	}

}

function replaceCommaInNumber(number){
	return number.replace(',','.');
}

function ajaxLoadLatLng(mapObj, idEl,zoomLevel){
	var point = new google.maps.LatLng(41.87194,12.567379999999957);

	if(idEl!=""){
		var query_string = "id="+idEl;	
		$.ajax({
			async: false,
			type: "POST",
			cache: false,
			url: "<%=tmpurl+"/ajaxloadjselement.aspx"%>",
			data: query_string,
			success: function(response) {
				var newarrpoint = eval(response);

				if(newarrpoint.length==1){
					mapObj.setCenter(newarrpoint[0]);
					mapObj.setZoom(zoomLevel);
				}else if(newarrpoint.length>1){			
					var latlngbounds = new google.maps.LatLngBounds();
					for (var j=0; j<newarrpoint.length; j++){
						latlngbounds.extend(newarrpoint[j]);
					}
					mapObj.fitBounds(latlngbounds);
				}			
			},
			error: function() {
				mapObj.setCenter(point);
				mapObj.setZoom(5);
			}
		});
	}else{
		mapObj.setCenter(point);
		mapObj.setZoom(5);		
	}
}

jQuery(document).ready(function(){
	<%if (!bolHasFilterSearchActive){%>
	$('#searchresetbuttons').hide();
	<%}%>
	$('#georesetbuttons').hide();

	showMap(mapid);
		
	if($('#field_regione_provincia').val()== ""){		
		disableDrawingMode();
	}
});
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


				<div>
				<form action="<%=currentURL%>" method="post" name="form_geo_search">	
					<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">	
					<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
					<input type="hidden" value="<%=categoryid%>" name="categoryid">	
					<input type="hidden" value="1" name="page">
					<input type="hidden" value="<%=orderBy%>" name="order_by">  
					<input type="hidden" value="<%=Request["content_preview"]%>" name="content_preview">  					
					<input type="hidden" value="0" name="search_active">				
					<input type="hidden" value="1" name="fields_filter">
					<%string fieldValueMatch = "";%>
					<div id="contract" style="float:left;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.contract")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("contratto", out fieldValueMatch);
						IList<string> contracts =  contentrep.getContentFieldValuesByDescriptionCached("contratto", false, true, true);								
						%>
						<select name="field_contratto" id="field_contratto">
						<option value=""></option>
						<%if(contracts != null && contracts.Count>0){
							foreach(string x in contracts){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>

					<div id="category" style="float:left;padding-left:20px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.category")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("categoria", out fieldValueMatch);
						IList<string> categories =  contentrep.getContentFieldValuesByDescriptionCached("categoria", false, true, true);								
						%>
						<select name="field_categoria" id="field_categoria">
						<option value=""></option>
						<%if(categories != null && categories.Count>0){
							foreach(string x in categories){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>

					<div id="typology" style="padding-left:20px;float:left;height:80px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.typology")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("tipologia", out fieldValueMatch);
						IList<string> typology =  contentrep.getContentFieldValuesByDescriptionCached("tipologia", false, true, true);								
						%>
						<select name="field_tipologia" id="field_tipologia" multiple="3">
						<option value=""></option>
						<%if(typology != null && typology.Count>0){							
							foreach(string x in typology){
								string typologychecked = "";
								if(!String.IsNullOrEmpty(fieldValueMatch)){
									string[] spitValuesMatch = fieldValueMatch.Split(',');
									foreach(string j in spitValuesMatch){
										if(x==j){
											typologychecked = " selected";
											break;
										}
									}
								}%>
								<option value="<%=x%>" <%=typologychecked%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>
					
					<div class="clear" style="height:10px;"></div>
					
					<div id="typeproperty" style="float:left;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.typeproperty")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("tipo_proprieta", out fieldValueMatch);
						IList<string> typeproperty =  contentrep.getContentFieldValuesByDescriptionCached("tipo_proprieta", false, true, true);
						%>
						<select name="field_tipo_proprieta" id="field_tipo_proprieta">
						<option value=""></option>
						<%if(typeproperty != null && typeproperty.Count>0){
							foreach(string x in typeproperty){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>

					<div id="status" style="float:left;padding-left:20px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.status")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("stato", out fieldValueMatch);
						IList<string> status =  contentrep.getContentFieldValuesByDescriptionCached("stato", false, true, true);								
						%>
						<select name="field_stato" id="field_stato">
						<option value=""></option>
						<%if(status != null && status.Count>0){
							foreach(string x in status){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>

					<div id="riscaldamento" style="float:left;padding-left:20px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.riscaldamento")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("riscaldamento", out fieldValueMatch);
						IList<string> heating =  contentrep.getContentFieldValuesByDescriptionCached("riscaldamento", false, true, true);								
						%>
						<select name="field_riscaldamento" id="field_riscaldamento">
						<option value=""></option>
						<%if(heating != null && heating.Count>0){
							foreach(string x in heating){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>

					<div id="baths" style="float:left;padding-left:20px;height:40px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.baths")%></span><br/>
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("bagni", out fieldValueMatch);
						IList<string> bathslist =  contentrep.getContentFieldValuesByDescriptionCached("bagni", false, true, true);								
						%>
						<select name="field_bagni" id="field_bagni">
						<option value=""></option>
						<%if(bathslist != null && bathslist.Count>0){
							foreach(string x in bathslist){%>
								<option value="<%=x%>" <%if(x==fieldValueMatch){Response.Write(" selected");}%>><%=x%></option>
							<%}
						}%>
						</select>
					</div>
					
					<div class="clear" style="height:10px;"></div>

					<div id="price">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.price")%></span><br/>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">da</div>
						<div style="height:35px;float:left;"><input type="text" style="width:100px;" name="price_from" id="price_from" value="<%if(prcsxVal>0){Response.Write(prcsxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">a</div>
						<div style="height:35px;"><input type="text" style="width:100px;" name="price_to" id="price_to" value="<%if(prcdxVal>0){Response.Write(prcdxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<input type="hidden" value="" name="field_prezzo" id="field_prezzo">							
					</div>

					<div id="superficie">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.superficie")%></span><br/>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">da</div>
						<div style="height:35px;float:left;"><input type="text" style="width:100px;" name="superficie_from" id="superficie_from" value="<%if(supsxVal>0){Response.Write(supsxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">a</div>
						<div style="height:35px;"><input type="text" style="width:100px;" name="superficie_to" id="superficie_to" value="<%if(supdxVal>0){Response.Write(supdxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<input type="hidden" value="" name="field_superficie" id="field_superficie">							
					</div>

					<div id="locali">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.locali")%></span><br/>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">da</div>
						<div style="height:35px;float:left;"><input type="text" style="width:100px;" name="locali_from" id="locali_from" value="<%if(locsxVal>0){Response.Write(locsxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<div style="height:35px;float:left;font-weight:bold;padding-left:3px;padding-right:3px;">a</div>
						<div style="height:35px;"><input type="text" style="width:100px;" name="locali_to" id="locali_to" value="<%if(locdxVal>0){Response.Write(locdxVal);}%>" onkeypress="javascript:return isInteger(event);"></div>
						<input type="hidden" value="" name="field_locali" id="field_locali">							
					</div>

					<div id="accessori">
						<%
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("accessori", out fieldValueMatch);
						IList<string> accessories =  contentrep.getContentFieldValuesByDescriptionCached("accessori", false, true, true);								
						
						if(accessories != null && accessories.Count>0){
							IList<string> splitaccessories = new List<string>();
							foreach(string x in accessories){
								string[] spitValues = x.Split(',');
								if(spitValues!=null){
									foreach(string y in spitValues){ 
										if(!splitaccessories.Contains(y)){
											splitaccessories.Add(y);
										}
									} 	
								}								
							}
							accessories = splitaccessories;
							int acccounter = 1;
							foreach(string x in accessories){
								string accessorieschecked = "";
								if(!String.IsNullOrEmpty(fieldValueMatch)){
									string[] spitValuesMatch = fieldValueMatch.Split(',');
									foreach(string j in spitValuesMatch){
										if(x==j){
											accessorieschecked = " checked='checked'";
											break;
										}
									}
								}
								%>
								<input type="checkbox" name="field_accessori" value="<%=x%>" <%=accessorieschecked%>>&nbsp;<%=x%>
								<%if(acccounter % 4 == 0){Response.Write("<br/>");}
								acccounter++;
							}
						}%>						
					</div>

					<div id="regione_provincia" style="padding-top:30px;">
						<span style="font-weight:bold;"><%=lang.getTranslated("frontend.template.annunci.label.regione_provincia")%></span><br/>
						<%
						IList<Country> stateRegions = countryrep.findStateRegionByCountry("IT","1");	
						fieldValueMatch = "";						
						objListPairKeyValue.TryGetValue("regione_provincia", out fieldValueMatch);%>
						<select name="field_regione_provincia" id="field_regione_provincia">
						<option value=""></option>
						<%if(stateRegions != null){
							foreach(Country x in stateRegions){
								string checkRpValue = x.stateRegionCode+"_"+x.id;%>
								<option value="<%=x.stateRegionCode%>_<%=x.id%>" <%if(checkRpValue==fieldValueMatch){Response.Write(" selected");}%>><%=x.stateRegionDescription%></option>
							<%}
						}%>
						</select>
					<script>
					
					/*$('#field_regione_provincia option').each(function() {
						var tmpv = $(this).val();
						if(tmpv.length>0 && tmpv.indexOf('IT-')==-1){
							$(this).remove();
						}
					});*/
					
					$('#field_regione_provincia').change(function() {
						$('#maplist').show();
						var tmpval = $('#field_regione_provincia').val();
						baseForZoom = tmpval.substring(0,tmpval.indexOf("_"));
						zoomLevel = 8;
						if(baseForZoom.length>5){
							zoomLevel = 10;
						}
						tmpval = tmpval.substring(tmpval.indexOf("_")+1);
						ajaxLoadLatLng(map, tmpval,zoomLevel);
							
						if($('#field_regione_provincia').val()!= "" && !hasGeoSearchActive){
							enableDrawingMode();	
						}else{
							disableDrawingMode();
						}
					});
					
					</script>
					</div>

					
				</form>			
				
				<div class="clear" style="height:10px;"></div>
				<div id="geosearchbuttons" style="float:left;"><input type="button" value="<%=lang.getTranslated("frontend.template.annunci.label.search")%>" onclick="javascript:sendGeoSearch();"/></div>
				<div id="searchresetbuttons" style="float:left;"><input type="button" value="<%=lang.getTranslated("frontend.template.annunci.label.reset_search")%>" onclick="javascript:reActivateDrawingMode();"/></div>
				<div id="georesetbuttons"><input type="button" value="<%=lang.getTranslated("frontend.template.annunci.label.clear_map")%>" onclick="javascript:resetGeoSearch();"/></div>					
				</div>
				<div class="clear" style="height:10px;"></div>
				<div style="width:480px;height:400px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;margin-bottom:30px;margin-top:30px;" id="maplist"></div>
		
				<script>
				jQuery(document).ready(function(){
				
				});							
				</script>

			
			
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
