<%@control Language="c#" description="backend-geolocalization-widget" className="BoGeolocalizationControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<script runat="server">
private ASP.BoMultiLanguageControl lang;
private ASP.UserLoginControl login;
ConfigurationService configuration;
protected string cssClass;
IGeolocalizationRepository georep;
protected string savetext;
protected string class_style;
protected int tmpcounter=1;
protected IList<Geolocalization> points;

private int _idElem;	
public int idElem {
	get { return _idElem; }
	set { _idElem = value; }
}

private int _elemType;	
public int elemType {
	get { return _elemType; }
	set { _elemType = value; }
}

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		//Response.Redirect("~/login.aspx?error_code=002");
		return;
	}
	
	configuration = new ConfigurationService();
	georep = RepositoryFactory.getInstance<IGeolocalizationRepository>("IGeolocalizationRepository");
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	cssClass = Request["cssClass"];
	savetext = lang.getTranslated("backend.commons.detail.table.label.save");
	class_style="backend-localization";
	points = new List<Geolocalization>();
	
	//Response.Write("<br>load _idElem:"+_idElem);
	//Response.Write("<br>load _elemType:"+_elemType);
	if((this._idElem==null || this._idElem <=0) &&  !String.IsNullOrEmpty(Request["id"]) && Request["id"]!= "-1")
	{		
		this._idElem=Convert.ToInt32(Request["id"]);
	}
	
	try
	{
		if(this._idElem!=null && this._idElem >0){
			points = georep.findByElement(idElem, elemType);
		}
	}
	catch(Exception ex)
	{
		//Response.Write("An inner error occured: " + ex.Message);
		points = new List<Geolocalization>();
	}
}
</script>

<%if(configuration.get("googlemaps_key").value!=""){%>
	<script language="Javascript">
	var mapWidgetX = 0;
	var mapWidgetY = 0;

	jQuery(document).ready(function(){
		$(document).mousemove(function(e){
			mapWidgetX = e.pageX;
			mapWidgetY = e.pageY;
		}); 
	});

	function prepareMap(latitude,longitude,address,info,mapid,counter){
		var loc_type = $("#loc_type"+counter).val();
		if(loc_type==0 && (latitude=="" || longitude=="")){
			alert("<%=lang.getTranslated("backend.commons.detail.js.alert.point")%>");
			return;
		}else if(loc_type==1 && address==""){
			alert("<%=lang.getTranslated("backend.commons.detail.js.alert.address")%>");
			return;	
		}
		if(loc_type==0 && (latitude!="" && longitude!="")){
			address="";
		}else if(loc_type==1 && address!=""){
			latitude="";
			longitude="";	
		}
		
		if((loc_type==0 && latitude!="" && longitude!="") || (loc_type==1 && address!="")){
			var divmap = document.getElementById(mapid);
			var offsetx   = 400;
			var offsety   = 50;	

			if(ie||mac_ie){
				divmap.style.left=mapWidgetX-offsetx;
				divmap.style.top=mapWidgetY-offsety;
			}else{
				divmap.style.left=mapWidgetX-offsetx+"px";
				divmap.style.top=mapWidgetY-offsety+"px";
			}

			$("#"+mapid).show(1000);
			divmap.style.visibility = "visible";
			divmap.style.display = "block";
			//alert("info2: "+info);
			
			showMap(mapid, info, latitude,longitude,address,counter);
		}
	}

	function hideMap(mapid){
		$('#'+mapid).hide();
		$('#verifypointjs').empty();
	} 

	function checkLocalization(info,mapid,counter){
		var latitude = $("#latitude"+counter).val();
		//alert("latitude: "+latitude);
		var longitude = $("#longitude"+counter).val();
		//alert("longitude: "+longitude);
		var address = $("#address"+counter).val();
		$('#verifypointjs').empty();
		//alert("info: "+info);
		prepareMap(replaceCommaInNumber(latitude),replaceCommaInNumber(longitude),address,info,mapid,counter);	
	}

	function showMap(mapid, info, latitude,longitude,address,counter){	
		var mapOptions = {
		  center: new google.maps.LatLng(0, 0),
		  zoom: 1,
		  mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		var map = new google.maps.Map(document.getElementById(mapid+"-inner"),  mapOptions);
		var geocoder = new google.maps.Geocoder();
		var infowindow = new google.maps.InfoWindow();
		var infoWin = info;

		if(latitude!="" && longitude!=""){
			point = new google.maps.LatLng(latitude, longitude);		
			geocoder.geocode({'latLng': point}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					if (results[1]) {
						map.setCenter(point);
						map.setZoom(10);
						var marker = new google.maps.Marker({
							position: point,
							map: map
						});
						infowindow.setContent(infoWin);
						infowindow.open(map, marker);
						google.maps.event.addListener(marker, "click", function() {
							infowindow.setContent(infoWin);
							infowindow.open(map, marker);					
						});
					}
				}/* else {
					alert("Geocoder failed due to: " + status);
				}*/
			});		
			verifyPoint(latitude,longitude,mapid,counter);		
		}else if(address!=""){
			geocoder.geocode( { 'address': address}, function(results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					point = results[0].geometry.location;
					map.setCenter(point);
					map.setZoom(10);
					var marker = new google.maps.Marker({
					    map: map,
					    position: point
					});
					infowindow.setContent(infoWin);
					infowindow.open(map, marker);
					google.maps.event.addListener(marker, "click", function() {
						infowindow.setContent(infoWin);
						infowindow.open(map, marker);					
					});
					verifyPoint(point.lat(),point.lng(),mapid,counter);
				}/* else {
					alert("Geocode was not successful for the following reason: " + status);
				}*/
			});
		}	
	}

	function verifyPoint(latitude,longitude,mapid,counter){
		$('#verifypointjs').append("<a href=javascript:switchPoint('"+latitude+"','"+longitude+"','"+mapid+"',"+counter+");><%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%></a>");
	}

	function switchPoint(latitude,longitude,mapid,counter){
		if(latitude.length==0 || longitude.length==0){
			alert("<%=lang.getTranslated("backend.commons.detail.js.alert.point")%>");
			hideMap(mapid);
			return;
		}else{
			$("#latitude"+counter).val(latitude);
			$("#longitude"+counter).val(longitude);
			if($("#txtinfo1"+counter).val()!= "" && $("#txtinfo0"+counter).val()== ""){
				$("#txtinfo0"+counter).val($("#txtinfo1"+counter).val());
			}
			$("#deletepoint0"+counter).hide();
			$("#deletepoint1"+counter).hide();
			$("#verifypoint0"+counter).hide();
			$("#verifypoint1"+counter).hide();
			$('#savepoint0'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save")%>');
			$('#savepoint0'+counter).attr('class','backend-localization');
			$('#savepoint1'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save")%>');
			$('#savepoint1'+counter).attr('class','backend-localization');
			$("#use_address_localization"+counter).hide();
			$("#loc_type"+counter).val(0);
			$("#use_point_localization"+counter).show();	
			$("#savepoint0"+counter).show();
			$("#savepoint1"+counter).show();
			hideMap(mapid);
		}	
	}

	function savePoint(id,latitude,longitude,txtinfo,id_element,type_elem,counter){
		//if($('#loc_type').val()==0){
			if(latitude.length==0 || longitude.length==0){
				alert("<%=lang.getTranslated("backend.commons.detail.js.alert.point")%>");
				return;
			}/*else{
				address="";
			}
		}else{
			if(address.length==0){
				alert("<%=lang.getTranslated("backend.commons.detail.js.alert.address")%>");
				return;			
			}else{
				latitude="";
				longitude="";
			}
		}*/

		var query_string = "idp="+id+"&latitude="+replaceCommaInNumber(latitude)+"&longitude="+replaceCommaInNumber(longitude)+"&txtinfo="+encodeURIComponent(txtinfo)+"&id_element="+id_element+"&type="+type_elem;

		//alert("query_string: "+query_string);
		
		$.ajax({
			type: "POST",
			url: "/backoffice/include/ajaxsavepoint.aspx",
			data: query_string,
			success: function(response) {
				//alert("salvato point: "+response);
				//alert("#savepoint0: "+$('#savepoint0').val());
				//alert("#savepoint1: "+$('#savepoint1').val());
				$("#id"+counter).val(response);
				$("#latitude"+counter).val(replaceCommaInNumber(latitude));
				$("#longitude"+counter).val(replaceCommaInNumber(longitude));
				$('#savepoint0'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save_confirmed")%>');
				$('#savepoint0'+counter).attr('class','backend-localization_active');
				$('#savepoint1'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save_confirmed")%>');
				$('#savepoint1'+counter).attr('class','backend-localization_active');
				$("#deletepoint0"+counter).show();
				$("#deletepoint1"+counter).show();
				$('#verifypointjs').empty();
			},
			error: function(response) {
				alert("<%=lang.getTranslated("backend.commons.fail_updated_field")%>: "+response);
			}
		});	
	}

	function deletePoint(id,counter){
		var query_string = "idp="+id+"&operation=delete";

		//alert("query_string: "+query_string);
		
		$.ajax({
			type: "POST",
			url: "/backoffice/include/ajaxsavepoint.aspx",
			data: query_string,
			success: function(response) {
				//alert("salvato point: "+response);
				//alert("#savepoint0: "+$('#savepoint0').val());
				//alert("#savepoint1: "+$('#savepoint1').val());
				//alert("pointCounterRef: "+pointCounterRef);
				if(Number(pointCounterRef)-1>1){
					//$("#id"+counter).remove();
					$("#divLocalization"+counter).remove();
					pointCounterRef--;
					//alert("pointCounterRef after: "+pointCounterRef);
				}else{
					$("#savepoint0"+counter).hide();
					$("#savepoint1"+counter).hide();
					$("#deletepoint0"+counter).hide();
					$("#deletepoint1"+counter).hide();
					$("#verifypoint0"+counter).show();
					$("#verifypoint1"+counter).show();
					$('#savepoint0'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save")%>');
					$('#savepoint0'+counter).attr('class','backend-localization');
					$('#savepoint1'+counter).val('<%=lang.getTranslated("backend.commons.detail.table.label.save")%>');
					$('#savepoint1'+counter).attr('class','backend-localization');
					$("#latitude"+counter).val("");
					$("#longitude"+counter).val("");
					$("#address"+counter).val("");
					$("#txtinfo0"+counter).val("");
					$("#txtinfo1"+counter).val("");
					$("#id"+counter).val(-1);
					$("#loc_type"+counter).val(0);
					$("#use_address_localization"+counter).hide();
					$("#use_point_localization"+counter).show();
				}
				$('#verifypointjs').empty();
			},
			error: function(response) {
				alert("<%=lang.getTranslated("backend.commons.fail_updated_field")%>: "+response);
			}
		});
	}

	function replaceCommaInNumber(number){
		if(number!=""){
			return number.replace(',','.');
		}else{
			return number;
		}
	}

	function addPoint(counter){
		$("#addpointhere").append('<div id="divLocalization'+counter+'" align="left" style="height:30px;">');
		$("#divLocalization"+counter).append($('<input type="hidden"/>').attr('id', "id"+counter).attr('name', "idp").attr('value', "-1"));
		$("#divLocalization"+counter).append('<div id="loc_container'+counter+'" style="float:left;padding-right:5px;padding-top:5px;">');
		$("#loc_container"+counter).append($('<select>').attr('id', "loc_type"+counter).attr('name', "loc_type").attr('class', "formFieldSelect").change(function(event) {return changeNewPointLocType(counter); }));	
		$("#loc_type"+counter).append('<option value="0" selected><%=lang.getTranslated("backend.commons.label.localization.point")%></option>');
		$("#loc_type"+counter).append('<option value="1"><%=lang.getTranslated("backend.commons.label.localization.address")%></option>');
		$("#divLocalization"+counter).append('<div id="use_point_localization'+counter+'">');
		$("#use_point_localization"+counter).append('<div id="latitude_container'+counter+'" style="float:left;">');
		$("#latitude_container"+counter).append('<%=lang.getTranslated("backend.commons.detail.table.label.latitude")%>&nbsp;');
		$("#latitude_container"+counter).append($('<input type="text"/>').attr('name', "latitude").attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "latitude"+counter).keypress(function(event) {return isDouble(event); }));
		$("#use_point_localization"+counter).append('<div id="longitude_container'+counter+'" style="float:left;">');
		$("#longitude_container"+counter).append('<%=lang.getTranslated("backend.commons.detail.table.label.longitude")%>&nbsp;');
		$("#longitude_container"+counter).append($('<input type="text"/>').attr('name', "longitude").attr('class', "formFieldTXTMedium").attr('value', "").attr('id', "longitude"+counter).keypress(function(event) {return isDouble(event); }));
		$("#use_point_localization"+counter).append('<div id="button_group_container'+counter+'" style="padding-left:5px;">');
		$("#button_group_container"+counter).append('&nbsp;').append('<span style="vertical-align:top;padding-right:4px;" id="txtinfo_container'+counter+'">');
		$("#txtinfo_container"+counter).append('<%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%>');
		$("#button_group_container"+counter).append($('<textarea/>').attr('name', "txtinfo").attr('class', "formFieldTXTLong2").attr('id', "txtinfo0"+counter));
		var render='&nbsp;&nbsp;<a href="';
		render+="javascript:checkLocalization($('#txtinfo0"+counter+"').val(),'map',"+counter+");";
		render+='"><img src="/backoffice/img/world_go.png" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" hspace="4" vspace="0" border="0" align="top"></a>';
		render+='&nbsp;&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint0'+counter+'" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="';
		render+="javascript:checkLocalization($('#txtinfo0"+counter+"').val(),'map',"+counter+");";
		render+='"/>';
		render+='&nbsp;&nbsp;<input type="button" class="backend-localization"  style="display:none;" id="savepoint0'+counter+'" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.save")%>" onclick="';
		render+="javascript:savePoint($('#id"+counter+"').val(),$('#latitude"+counter+"').val(),$('#longitude"+counter+"').val(),$('#txtinfo0"+counter+"').val(),<%=idElem%>,<%=elemType%>,"+counter+");";
		render+='"/>';
		render+='<span id="deletepoint0'+counter+'" style="display:none;">&nbsp;&nbsp;<a href="';
		render+="javascript:deletePoint($('#id"+counter+"').val(),"+counter+");";
		render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" hspace="4" vspace="0" border="0" align="top"></a></span>';
		$("#button_group_container"+counter).append(render);
		$("#divLocalization"+counter).append('<div id="use_address_localization'+counter+'" style="display:none;">');
		$("#use_address_localization"+counter).append('<div id="address_container'+counter+'" style="float:left;">');
		$("#address_container"+counter).append('<%=lang.getTranslated("backend.commons.detail.table.label.address")%>&nbsp;');
		$("#address_container"+counter).append($('<input type="text"/>').attr('name', "address").attr('class', "formFieldTXTlocalizAddr").attr('value', "").attr('id', "address"+counter).attr('maxlength', "250"));	
		$("#use_address_localization"+counter).append('<div id="button_group_container2'+counter+'" style="padding-left:5px;">');
		$("#button_group_container2"+counter).append('&nbsp;').append('<span style="vertical-align:top;padding-right:4px;" id="txtinfo_container2'+counter+'">');
		$("#txtinfo_container2"+counter).append('<%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%>');
		$("#button_group_container2"+counter).append($('<textarea/>').attr('name', "txtinfo").attr('class', "formFieldTXTLong2").attr('id', "txtinfo1"+counter));
		render='&nbsp;&nbsp;<a href="';
		render+="javascript:checkLocalization($('#txtinfo1"+counter+"').val(),'map',"+counter+");";
		render+='"><img src="/backoffice/img/world_go.png" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" hspace="4" vspace="0" border="0" align="top"></a>';
		render+='&nbsp;&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint1'+counter+'" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="';
		render+="javascript:checkLocalization($('#txtinfo1"+counter+"').val(),'map',"+counter+");";
		render+='"/>';
		render+='&nbsp;&nbsp;<input type="button" class="backend-localization" style="display:none;" id="savepoint1'+counter+'" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.save")%>" onclick="';
		render+="javascript:savePoint($('#id"+counter+"').val(),$('#latitude"+counter+"').val(),$('#longitude"+counter+"').val(),$('#txtinfo1"+counter+"').val(),<%=idElem%>,<%=elemType%>,"+counter+");";
		render+='"/>';
		render+='<span id="deletepoint1'+counter+'" style="display:none;">&nbsp;&nbsp;<a href="';
		render+="javascript:deletePoint($('#id"+counter+"').val(),"+counter+");";
		render+='"><img src="/backoffice/img/delete.png" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" hspace="4" vspace="0" border="0" align="top"></a></span>';
		$("#button_group_container2"+counter).append(render);	
		
		pointCounter++;
		pointCounterRef++;
	}

	function changeNewPointLocType(fieldid){
		var loc_type_val_ch = $("#loc_type"+fieldid).val();
		if(loc_type_val_ch==0){
			$("#use_address_localization"+fieldid).hide();
			$("#use_point_localization"+fieldid).show();
		}else{
			$("#loc_type"+fieldid).val(1);
			$("#use_point_localization"+fieldid).hide();
			$("#use_address_localization"+fieldid).show();
		}	
	}

	var pointCounter=1;
	var pointCounterRef=1;
	</script>
	<div style="width:500px;height:305px;position:absolute;left:-0px;top:0px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;" id="map">
	<p style="text-align:right;padding:5px;margin:0px;"><span id="verifypointjs"></span>&nbsp;&nbsp;&nbsp;<a href="javascript:hideMap('map');">x</a></p>
	<div style="width:500px;height:280px;" id="map-inner">&nbsp;</div>
	</div>
	<div class="labelForm" align="left"><%=lang.getTranslated("backend.commons.label.localization")%>
	&nbsp;<a href="javascript:addPoint(pointCounter);"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.commons.detail.table.label.add_point")%>" alt="<%=lang.getTranslated("backend.commons.detail.table.label.add_point")%>" hspace="5" vspace="0" border="0"></a></div>
	<%
	if(points.Count>0){
		foreach(Geolocalization p in points)
		{
			savetext = lang.getTranslated("backend.commons.detail.table.label.save_confirmed");
			class_style="backend-localization_active";%>
			<div id="divLocalization<%=tmpcounter%>" align="left" style="height:30px;">
			<input type="hidden" name="idp" id="id<%=tmpcounter%>" value="<%=p.id%>" />
			<div style="float:left;padding-right:5px;padding-top:5px;">
			<select name="loc_type" id="loc_type<%=tmpcounter%>" class="formFieldSelect">
			<option value="0" selected><%=lang.getTranslated("backend.commons.label.localization.point")%></option>
			<option value="1"><%=lang.getTranslated("backend.commons.label.localization.address")%></option>
			</select>
			</div>
			<div id="use_point_localization<%=tmpcounter%>">
			<div style="float:left;"><%=lang.getTranslated("backend.commons.detail.table.label.latitude")%>
			<input type="text" name="latitude" id="latitude<%=tmpcounter%>" value="<%=p.latitude%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" />
			</div>
			<div style="float:left;"><%=lang.getTranslated("backend.commons.detail.table.label.longitude")%>
			<input type="text" name="longitude" id="longitude<%=tmpcounter%>" value="<%=p.longitude%>" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" /></div>
			<div style="padding-left:5px;">
			&nbsp;<span style="vertical-align:top;padding-right:4px;"><%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%></span><textarea name="txtinfo" id="txtinfo0<%=tmpcounter%>" class="formFieldTXTLong2"><%=p.txtInfo%></textarea>
			&nbsp;<a href="javascript:checkLocalization($('#txtinfo0<%=tmpcounter%>').val(),'map',<%=tmpcounter%>)"><img src=/backoffice/img/world_go.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>"></a>
			&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint0<%=tmpcounter%>" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="javascript:checkLocalization($('#txtinfo0<%=tmpcounter%>').val(),'map'<%=tmpcounter%>);" />
			&nbsp;<input type="button" class="<%=class_style%>" id="savepoint0<%=tmpcounter%>" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=savetext%>" onclick="javascript:savePoint($('#id<%=tmpcounter%>').val(),$('#latitude<%=tmpcounter%>').val(),$('#longitude<%=tmpcounter%>').val(),$('#txtinfo0<%=tmpcounter%>').val(),<%=idElem%>,<%=elemType%>,<%=tmpcounter%>);" />
			<span id="deletepoint0<%=tmpcounter%>">&nbsp;<a href="javascript:deletePoint($('#id<%=tmpcounter%>').val(),<%=tmpcounter%>);"><img src=/backoffice/img/delete.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>"></a></span>
			</div>
			</div>
			<div id="use_address_localization<%=tmpcounter%>">
			<div style="float:left;"><%=lang.getTranslated("backend.commons.detail.table.label.address")%>
			<input type="text" name="address" id="address<%=tmpcounter%>" value="" class="formFieldTXTlocalizAddr" maxlength="250" /></div>
			<div style="padding-left:5px;">
			&nbsp;<span style="vertical-align:top;padding-right:4px;"><%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%></span><textarea name="txtinfo" id="txtinfo1<%=tmpcounter%>" class="formFieldTXTLong2"><%=p.txtInfo%></textarea>
			&nbsp;<a href="javascript:checkLocalization($('#txtinfo1<%=tmpcounter%>').val(),'map',<%=tmpcounter%>)"><img src=/backoffice/img/world_go.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>"></a>
			&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint1<%=tmpcounter%>" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="javascript:checkLocalization($('#txtinfo1<%=tmpcounter%>').val(),'map',<%=tmpcounter%>);" />
			&nbsp;<input type="button" class="<%=class_style%>" id="savepoint1<%=tmpcounter%>" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=savetext%>" onclick="javascript:savePoint($('#id<%=tmpcounter%>').val(),$('#latitude<%=tmpcounter%>').val(),$('#longitude<%=tmpcounter%>').val(),$('#txtinfo1<%=tmpcounter%>').val(),<%=idElem%>,<%=elemType%>,<%=tmpcounter%>);" />  
			<span id="deletepoint1<%=tmpcounter%>">&nbsp;<a href="javascript:deletePoint($('#id<%=tmpcounter%>').val(),<%=tmpcounter%>);"><img src=/backoffice/img/delete.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>"></a></span>
			</div>
			</div>
			</div>
			<script language="Javascript">
			$("#verifypoint0<%=tmpcounter%>").hide();
			$("#verifypoint1<%=tmpcounter%>").hide();
			$("#loc_type<%=tmpcounter%>").val(0);
			$("#use_address_localization<%=tmpcounter%>").hide();
			$("#use_point_localization<%=tmpcounter%>").show();	
	
			$('#loc_type<%=tmpcounter%>').change(function() {
				var loc_type_val_ch = $('#loc_type<%=tmpcounter%>').val();
				if(loc_type_val_ch==0){
					$("#use_address_localization<%=tmpcounter%>").hide();
					$("#use_point_localization<%=tmpcounter%>").show();
				}else{
					$("#loc_type<%=tmpcounter%>").val(1);
					$("#use_point_localization<%=tmpcounter%>").hide();
					$("#use_address_localization<%=tmpcounter%>").show();
				}
			});
			</script>
			<%
			tmpcounter++;
		}%>
		<script language="Javascript">
		pointCounter=<%=tmpcounter%>;
		pointCounterRef=<%=tmpcounter%>;
		</script>
	<%}else{%>
	<div id="divLocalization0" align="left" style="height:30px;">
		<input type="hidden" name="idp" id="id0" value="-1" />
		<div style="float:left;padding-right:5px;padding-top:5px;">
			<select name="loc_type" id="loc_type0" class="formFieldSelect">
			<option value="0" selected><%=lang.getTranslated("backend.commons.label.localization.point")%></option>
			<option value="1"><%=lang.getTranslated("backend.commons.label.localization.address")%></option>
			</select>
		</div>
		<div id="use_point_localization0">
			<div style="float:left;"><%=lang.getTranslated("backend.commons.detail.table.label.latitude")%>
				<input type="text" name="latitude" id="latitude0" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" />
			</div>
			<div style="float:left;">
				<%=lang.getTranslated("backend.commons.detail.table.label.longitude")%>
				<input type="text" name="longitude" id="longitude0" value="" class="formFieldTXTMedium" onkeypress="javascript:return isDouble(event);" />
			</div>
			<div style="padding-left:5px;">
				&nbsp;<span style="vertical-align:top;padding-right:4px;"><%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%></span><textarea name="txtinfo" id="txtinfo00" class="formFieldTXTLong2"></textarea>
				&nbsp;<a href="javascript:checkLocalization($('#txtinfo00').val(),'map',0)"><img src=/backoffice/img/world_go.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>"></a>
				&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint00" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="javascript:checkLocalization($('#txtinfo00').val(),'map',0);" />
				&nbsp;<input type="button" class="<%=class_style%>" id="savepoint00" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=savetext%>" onclick="javascript:savePoint($('#id0').val(),$('#latitude0').val(),$('#longitude0').val(),$('#txtinfo00').val(),<%=idElem%>,<%=elemType%>,0);" />
				<span id="deletepoint00">&nbsp;<a href="javascript:deletePoint($('#id0').val(),0);"><img src=/backoffice/img/delete.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>"></a></span>
			</div>
		</div>
		<div id="use_address_localization0">
			<div style="float:left;"><%=lang.getTranslated("backend.commons.detail.table.label.address")%>
				<input type="text" name="address" id="address0" value="" class="formFieldTXTlocalizAddr" maxlength="250" />
			</div>
			<div style="padding-left:5px;">
				&nbsp;<span style="vertical-align:top;padding-right:4px;"><%=lang.getTranslated("backend.commons.detail.table.label.txtinfo")%></span><textarea name="txtinfo" id="txtinfo10" class="formFieldTXTLong2"></textarea>
				&nbsp;<a href="javascript:checkLocalization($('#txtinfo10').val(),'map',0)"><img src=/backoffice/img/world_go.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>"></a>
				&nbsp;<input type="button" class="backend-localization_verify" id="verifypoint10" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.detail.table.label.check_loc")%>" onclick="javascript:checkLocalization($('#txtinfo10').val(),'map',0);" />
				&nbsp;<input type="button" class="<%=class_style%>" id="savepoint10" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=savetext%>" onclick="javascript:savePoint($('#id0').val(),$('#latitude0').val(),$('#longitude0').val(),$('#txtinfo10').val(),<%=idElem%>,<%=elemType%>,0);" />  
				<span id="deletepoint10">&nbsp;<a href="javascript:deletePoint($('#id0').val(),0);"><img src=/backoffice/img/delete.png vspace="0" hspace="4" border="0" align="top" alt="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>" title="<%=lang.getTranslated("backend.commons.detail.table.label.delete")%>"></a></span>
			</div>
		</div>
	</div>
	<script language="Javascript">
	$("#savepoint00").hide();
	$("#deletepoint00").hide();
	$("#savepoint10").hide();
	$("#deletepoint10").hide();
	$("#loc_type0").val(0);
	$("#use_address_localization0").hide();
	$("#use_point_localization0").show();

	$('#loc_type0').change(function() {
		var loc_type_val_ch = $('#loc_type0').val();
		if(loc_type_val_ch==0){
			$("#use_address_localization0").hide();
			$("#use_point_localization0").show();
		}else{
			$("#loc_type0").val(1);
			$("#use_point_localization0").hide();
			$("#use_address_localization0").show();
		}
	});
	</script>
	<%}%>
	<span id="addpointhere">
	</span>
	<br><br>
<%}%>