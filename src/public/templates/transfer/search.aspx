<%@ Page Language="C#" AutoEventWireup="true" CodeFile="search.aspx.cs" Inherits="_Search" Debug="false" %>
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
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="MenuTransferFooterControl" TagName="insert" Src="~/public/layout/include/menu-transfer.ascx" %>
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
	function validateSearch() {
		var pickup,dropoff,pax,startD,startDv,dateS,returnD,returnDv,onlyOut;
		pickup = $('#formSearchUpLocation3').val();
		dropoff = $('#formSearchOffLocation3').val();
		pax = $('#shuttleselectpicker').val();
		onlyOut = $('#formSearchOffToggle3').val();
		startD = false;
		startDv = $('#formSearchUpDate3').val();
		returnD = false;
			
		if(startDv){
			dateS = moment(startDv,'DD/MM/YYYY HH:mm').add(moment().utcOffset(),'minutes');
			if(dateS && moment().add(moment().utcOffset(),'minutes').isSameOrBefore(dateS, "minutes")){
				startD = true;			
			}
		}
	
		var isValid = pickup && dropoff && pax && startD;
		
		if("return"==onlyOut){
			returnDv = $('#formSearchOffDate3').val();
			if(returnDv){
				var dateR = moment(returnDv,'DD/MM/YYYY HH:mm').add(moment().utcOffset(),'minutes');
				if(dateR && moment().add(moment().utcOffset(),'minutes').isSameOrBefore(dateR, "minutes") && dateS.isSameOrBefore(dateR, "minutes")){
					returnD = true;			
				}
			}		
		
			isValid = isValid && returnD;
		}
		
		return isValid;
	}	
	
	function validateErrors(){
		var pickup,dropoff,pax,startD,isStartD,isStartDAfterNow,startDv,dateS,returnD,returnDv,onlyOut;
		pickup = $('#formSearchUpLocation3').val();
		dropoff = $('#formSearchOffLocation3').val();
		pax = $('#shuttleselectpicker').val();
		onlyOut = $('#formSearchOffToggle3').val();
		startD = false;
		isStartD = true;
		isStartDAfterNow = true;
		startDv = $('#formSearchUpDate3').val();
		returnD = false;
		isReturnD = true;
		isReturnDAfterNow = true;
		
		if(startDv){
			dateS = moment(startDv,'DD/MM/YYYY HH:mm').add(moment().utcOffset(),'minutes');
			var sDateNow = moment().add(moment().utcOffset(),'minutes');
			if(dateS.isValid() && sDateNow.isSameOrBefore(dateS, "minutes")){
				startD = true;			
			}else{
				if(!dateS.isValid()){
					isStartD =false;
				}else{
					if(!sDateNow.isSameOrBefore(dateS, "minutes")){
						isStartDAfterNow = false;
					}
				}
			}
		}		

		if(!pickup){
			$('#alert-inline-pickup').show();
		}
		if(!dropoff){
			$('#alert-inline-dropoff').show();
		}	
		if(!pax){
			$('#alert-inline-pax').show();
		}	
		
		if(!isStartDAfterNow){
			$('#alert-inline-startd').empty();
			$('#alert-inline-startd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.startdate.afternow" runat="server" />');
			$('#alert-inline-startd').show();	
		}else if(!isStartD){
			$('#alert-inline-startd').empty();
			$('#alert-inline-startd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.startdate.invalid" runat="server" />');
			$('#alert-inline-startd').show();
		}else if(!startD){
			$('#alert-inline-startd').empty();
			$('#alert-inline-startd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.startdate.mandatory" runat="server" />');
			$('#alert-inline-startd').show();	
		}
		
		if("return"==onlyOut){
			returnDv = $('#formSearchOffDate3').val();
			if(returnDv){
				var dateR = moment(returnDv,'DD/MM/YYYY HH:mm').add(moment().utcOffset(),'minutes');
				var rDateNow = moment().add(moment().utcOffset(),'minutes');
				if(dateR.isValid() && rDateNow.isSameOrBefore(dateR, "minutes") && dateS.isSameOrBefore(dateR, "minutes")){
					returnD = true;			
				}else{
					if(!dateR.isValid()){
						isReturnD =false;
					}else{
						if(!sDateNow.isSameOrBefore(dateS, "minutes") || !dateS.isSameOrBefore(dateR, "minutes")){
							isReturnDAfterNow = false;
						}
					}
				}
			}		
		
			if(!isReturnDAfterNow){		
				$('#alert-inline-returnd').empty();
				$('#alert-inline-returnd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.returndate.afternow" runat="server" />');
				$('#alert-inline-returnd').show();		
			}else if(!isReturnD){
				$('#alert-inline-returnd').empty();
				$('#alert-inline-returnd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.returndate.invalid" runat="server" />');
				$('#alert-inline-returnd').show();		
			}else if(!returnD){
				$('#alert-inline-returnd').empty();
				$('#alert-inline-returnd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.returndate.mandatory" runat="server" />');
				$('#alert-inline-returnd').show();			
			}
		}
	}
	
	function setSessionStorageLocations(place, type){
		if("pickup"==type){
			var pcObject = {
				name:place.name,
				fieldValue: $('#formSearchUpLocation3').val(), 
				lat:place.geometry.location.lat(),
				lon:place.geometry.location.lng()
			};
			sessionStorage.setItem("formSearchUpLocation3", JSON.stringify(pcObject));
		}else{
			var doObject = {
				name:place.name,
				fieldValue: $('#formSearchOffLocation3').val(), 
				lat:place.geometry.location.lat(),
				lon:place.geometry.location.lng()
			};
			sessionStorage.setItem("formSearchOffLocation3", JSON.stringify(doObject));	
		}
	}	
	
	function setSessionStorageValues(){
		sessionStorage.setItem("shuttleselectpicker", $('#shuttleselectpicker').val());	
		sessionStorage.setItem("formSearchOffToggle3", $('#formSearchOffToggle3').val());	
		sessionStorage.setItem("formSearchUpDate3", $('#formSearchUpDate3').val());	
		sessionStorage.setItem("formSearchOffDate3", $('#formSearchOffDate3').val());			
	}
	
	function getSessionStorageValues(){
		var storedPc = sessionStorage.getItem("formSearchUpLocation3");
		var storedDo = sessionStorage.getItem("formSearchOffLocation3");
		
		if(storedPc){
			$('#formSearchUpLocation3').val(JSON.parse(storedPc).fieldValue);
		}
		if(storedDo){
			$('#formSearchOffLocation3').val(JSON.parse(storedDo).fieldValue);
		}
		
		if(sessionStorage.getItem("shuttleselectpicker")){
			$('#shuttleselectpicker').selectpicker('val', sessionStorage.getItem("shuttleselectpicker"));
		}
		if(sessionStorage.getItem("formSearchOffToggle3")){
			$('#formSearchOffToggle3').val(sessionStorage.getItem("formSearchOffToggle3"));
		}
		if(sessionStorage.getItem("formSearchUpDate3")){
			$('#formSearchUpDate3').val(sessionStorage.getItem("formSearchUpDate3"));
		}
		if(sessionStorage.getItem("formSearchOffDate3")){
			$('#formSearchOffDate3').val(sessionStorage.getItem("formSearchOffDate3"));	
		}
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
         <CommonHeader:insert runat="server" />
         <!-- /HEADER -->
         
         <!-- CONTENT AREA -->
         <div class="content-area">
            <!-- PAGE -->
            <section class="page-section no-padding slider">
               <div class="container full-width">
                  <div class="main-slider">
                     <!-- Slide 3 -->
                     <div class="item slide3 ver3">
                        <div class="caption">
                           <div class="container">
                              <div class="div-table">
                                 <div class="div-cell">
                                    <div class="caption-content">
                                       <!-- Search form -->
                                       <div class="form-search light">
                                       
										  <form action="#" id="searchtransfer" name="searchtransfer" method="post">
											<div class="places-service"></div>
											 <div class="form-title">
												<i class="fa fa-globe"></i>
												<h2><lang:getTranslated keyword="frontend.transfer.search.widget.title" runat="server" /></h2>
											 </div>
											 <div class="row row-inputs">
												<div class="container-fluid">
												   <div class="col-sm-12">
													  <div class="form-group has-icon has-label">
														 <label for="formSearchUpLocation3"><lang:getTranslated keyword="frontend.transfer.search.widget.pickup.location" runat="server" /></label>
														 <input type="text" class="form-control" id="formSearchUpLocation3" value="" placeholder="<lang:getTranslated keyword="frontend.transfer.search.widget.pickup.placeholder" runat="server" />">
														 <span class="form-control-icon"><i class="fa fa-location-arrow"></i></span>
														 <div class="alert-inline alert-inline-danger" id="alert-inline-pickup"><lang:getTranslated keyword="frontend.transfer.search.widget.error.pickup.mandatory" runat="server" /></div>
													  </div>
												   </div>
												   <div class="col-sm-12">
													  <div class="form-group has-icon has-label">
														 <label for="formSearchOffLocation3"><lang:getTranslated keyword="frontend.transfer.search.widget.dropoff.location" runat="server" /></label>
														 <input type="text" class="form-control" id="formSearchOffLocation3" placeholder="<lang:getTranslated keyword="frontend.transfer.search.widget.dropoff.placeholder" runat="server" />">
														 <span class="form-control-icon"><i class="fa fa-location-arrow"></i></span>
														 <div class="alert-inline alert-inline-danger" id="alert-inline-dropoff"><lang:getTranslated keyword="frontend.transfer.search.widget.error.dropoff.mandatory" runat="server" /></div>
													  </div>
												   </div>
												</div>
											 </div>
											 
											 <div class="row row-inputs">
												<div class="container-fluid">
												   <div class="col-sm-6">
													  <div class="form-group has-icon has-label">
														 <label for="formSearchOffToggle3"><lang:getTranslated keyword="frontend.transfer.search.widget.onlyoutbound" runat="server" /></label>
														 <div style="visibility:hidden;">
															<input type="checkbox" class="form-control" id="formSearchOffToggle3" value="onlyOutbound" name="returnTrip">
														 </div>
														 <span class="form-control-icon2" id="formSearchOffToggle"><i class="fa fa-toggle-off fa-3x"></i></span>
													  </div>
												   </div>
												   <div class="col-sm-6">
													  <div class="form-group has-icon has-label">
														 <label><lang:getTranslated keyword="frontend.transfer.search.widget.passengers" runat="server" /></label>
														 <span class="form-control-icon"><i class="fa fa-users"></i></span> 
														 <select class="selectpicker input-price" id="shuttleselectpicker" data-live-search="true" data-width="100%" data-toggle="tooltip" title="Select">
															<option> </option>
															<option>1</option>
															<option>2</option>
															<option>3</option>
															<option>4</option>
															<option>5</option>
															<option>6</option>
															<option>7</option>
															<option>8</option>
															<option>9</option>
														 </select>
														 <div class="alert-inline alert-inline-danger" id="alert-inline-pax"><lang:getTranslated keyword="frontend.transfer.search.widget.error.pax.mandatory" runat="server" /></div>
													  </div>
												   </div>
												</div>
											 </div>  
											 
											 <div class="row row-inputs">
												<div class="container-fluid">
												   <div class="col-sm-6">
													  <div class="form-group has-icon has-label">
														 <label for="formSearchUpDate3"><lang:getTranslated keyword="frontend.transfer.search.widget.departure.date" runat="server" /></label>
														 <input type="text" class="form-control datepicker" id="formSearchUpDate3" placeholder="dd/mm/yyyy HH:mm">
														 <span class="form-control-icon"><i class="fa fa-calendar"></i></span>
														 <div class="alert-inline alert-inline-danger" id="alert-inline-startd"><lang:getTranslated keyword="frontend.transfer.search.widget.error.startdate.mandatory" runat="server" /></div>
													  </div>
												   </div>
												  <div class="col-sm-6">
												  	<div id="return-journey-switch" style="display:none;">
														 <div class="form-group has-icon has-label">
															<label for="formSearchOffDate3"><lang:getTranslated keyword="frontend.transfer.search.widget.return.date" runat="server" /></label>
															<input type="text" class="form-control datepicker" id="formSearchOffDate3" placeholder="dd/mm/yyyy HH:mm">
															<span class="form-control-icon"><i class="fa fa-calendar"></i></span>
															<div class="alert-inline alert-inline-danger" id="alert-inline-returnd"><lang:getTranslated keyword="frontend.transfer.search.widget.error.returndate.mandatory" runat="server" /></div>
														 </div>
													 </div>
												  </div>
												</div>
											 </div> 
											 
											 <div class="row row-submit">
												<div class="container-fluid">
												   <div class="inner">
													  <button type="button" id="formSearchSubmit3" class="btn btn-submit btn-theme pull-right"><lang:getTranslated keyword="frontend.transfer.search.widget.cta" runat="server" /></button>
												   </div>
												</div>
											 </div>
											 
											<script>
											   $(document).ready(function() {
													
													$('#formSearchUpDate3').datetimepicker({
														locale: '<%=lang.currentLangCode%>',
														sideBySide: true,
														format: 'DD/MM/YYYY HH:mm'
													}); 
													
													$('#formSearchOffDate3').datetimepicker({
														locale: '<%=lang.currentLangCode%>',
														sideBySide: true,
														format: 'DD/MM/YYYY HH:mm'
													}); 
													
													$('#shuttleselectpicker').selectpicker({
													  size:5
													});
													$('#shuttleselectpicker').selectpicker('val',1);
													
													
													// get session storage values
													getSessionStorageValues();
													
													
													$('#formSearchOffToggle').on('click', function(){
														if($('#return-journey-switch').is(':visible')){
															$('#formSearchOffToggle i.fa').removeClass('fa-toggle-on').addClass('fa-toggle-off');
															$('#return-journey-switch').hide();		
															$('#formSearchOffToggle3').val('onlyOutbound');
														}else{
															$('#formSearchOffToggle i.fa').removeClass('fa-toggle-off').addClass('fa-toggle-on');
															$('#return-journey-switch').show();		
															$('#formSearchOffToggle3').val('return');
														}
													});	

											
													if("return"==$('#formSearchOffToggle3').val()){
														$('#formSearchOffToggle i.fa').removeClass('fa-toggle-off').addClass('fa-toggle-on');
														$('#return-journey-switch').show();	
													
														$('#formSearchOffDate3').on('blur', function(){
															var value = $(this).val();
															if(value){
																$('#alert-inline-returnd').hide();
															}else{
																$('#alert-inline-returnd').empty();
																$('#alert-inline-returnd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.returndate.mandatory" runat="server" />');
																$('#alert-inline-returnd').show();
															}
														});	
													}else{
														$('#formSearchOffToggle i.fa').removeClass('fa-toggle-on').addClass('fa-toggle-off');
														$('#return-journey-switch').hide();															
													}													
													
													$('#formSearchUpLocation3').on('blur', function(){
														var value = $(this).val();
														if(value){
															$('#alert-inline-pickup').hide();
														}else{
															$('#alert-inline-pickup').show();
														}
													});		
													
													
													$('#formSearchOffLocation3').on('blur', function(){
														var value = $(this).val();
														if(value){
															$('#alert-inline-dropoff').hide();
														}else{
															$('#alert-inline-dropoff').show();
														}
													});		
													
													
													$('#shuttleselectpicker').on('change', function(){
														var value = $(this).val();
														if(value){
															$('#alert-inline-pax').hide();
														}else{
															$('#alert-inline-pax').show();
														}
													});		
													
													
													$('#formSearchUpDate3').on('blur', function(){
														var value = $(this).val();
														if(value){
															$('#alert-inline-startd').hide();
														}else{
															$('#alert-inline-startd').empty();
															$('#alert-inline-startd').append('<lang:getTranslated keyword="frontend.transfer.search.widget.error.startdate.mandatory" runat="server" />');
															$('#alert-inline-startd').show();
														}
													});
											   }); 	
											   
											   
												pdw = new PickDropWidget({
													pickupInputId: 'formSearchUpLocation3',
													dropoffInputId: 'formSearchOffLocation3',
													submitBtnId: 'formSearchSubmit3',
											
													onSubmit: function (pickup_Place, dropoff_Place, event) {
														if (validateSearch()) {
															$('#alert-inline-pickup').hide();
															$('#alert-inline-dropoff').hide();
															$('#alert-inline-pax').hide();
															$('#alert-inline-startd').hide();
															$('#alert-inline-returnd').hide();
															
															// set values on sessionStorage
															setSessionStorageValues();
															
															if(pickup_Place){
																// set locations on sessionStorage
																setSessionStorageLocations(pickup_Place, 'pickup');
																
																var pcN = pickup_Place.name;
																var pcLat = pickup_Place.geometry.location.lat();
																var pcLon = pickup_Place.geometry.location.lng();
															}else{
																if(sessionStorage.getItem("formSearchUpLocation3")){
																	var storedPc = JSON.parse(sessionStorage.getItem("formSearchUpLocation3"));
																	pcN = storedPc.name;
																	pcLat = storedPc.lat;
																	pcLon = storedPc.lon;
																}else{
																	throw new Error('Missing locations!');
																}
															}
															
															if(dropoff_Place){
																// set locations on sessionStorage
																setSessionStorageLocations(dropoff_Place, 'dropoff');
																
																var doN = dropoff_Place.name;
																var doLat = dropoff_Place.geometry.location.lat();
																var doLon = dropoff_Place.geometry.location.lng();
															}else{
																if(sessionStorage.getItem("formSearchOffLocation3")){
																	var storedDo = JSON.parse(sessionStorage.getItem("formSearchOffLocation3"));
																	doN = storedDo.name;
																	doLat = storedDo.lat;
																	doLon = storedDo.lon;
																}else{
																	throw new Error('Missing locations!');
																}
															}															
														
														  if ( $('input[name=returnTrip]').val() == "onlyOutbound" ) {
															var url = "<%=formAction%>?" + $.param({
																from_type: 'geo',
																to_type: 'geo',
											
																pickupName: pcN,
																pickupLatitude: pcLat,
																pickupLongitude: pcLon,
											
																dropoffName: doN,
																dropoffLatitude: doLat,
																dropoffLongitude: doLon,
																pickupDate: $('#formSearchUpDate3').val(),
																trip: $('input[name=returnTrip]').val(),
																passenger: $('#shuttleselectpicker').val()
															});
														  }
											
														  if ( $('input[name=returnTrip]').val() == "return" ) {
															var url = "<%=formAction%>?" + $.param({
																from_type: 'geo',
																to_type: 'geo',
											
																pickupName: pcN,
																pickupLatitude: pcLat,
																pickupLongitude: pcLon,
											
																dropoffName: doN,
																dropoffLatitude: doLat,
																dropoffLongitude: doLon,
																pickupDate: $('#formSearchUpDate3').val(),
																trip: $('input[name=returnTrip]').val(),
																returnDate: $('#formSearchOffDate3').val(),
																passenger: $('#shuttleselectpicker').val()
															});
														  }
											
														  $("#searchtransfer").attr("action", url)
														  $('#searchtransfer').submit();
											
														} else {
															//alert("<lang:getTranslated keyword="frontend.transfer.search.widget.error.missing.location" runat="server" />");
															
															validateErrors();
														}
													},
											
													onError: function (error) {
														alert(error);
													}
												});              
											   
											</script>                                             
											 
											 <input type="hidden" id="adPlat" value="hp" class="form-control">
										  </form>
                                       </div>
                                       <!-- /Search form -->
                                    </div>
                                 </div>
                              </div>
                           </div>
                        </div>
                        <!-- /Slide 3 -->
                     </div>
                  </div>
               </div>
            </section>
            <!-- /PAGE -->          
            

			<%if (foundAuthors) {%>            
            <section class="page-section testimonials">
               <div class="container">
                  <div class="testimonials-carousel">
                     <div class="owl-carousel" id="testimonials">
                     	<%foreach(FContent c in contentAuthors){%>
                        <div class="testimonial">
                           <div class="media">
                              <div class="media-left">
                                 <a href="#">
                                 <img class="media-object testimonial-avatar" src="/common/img/preview/avatars/testimonial-140x140x1.jpg" alt="Testimonial avatar">
                                 </a>
                              </div>
                              <div class="media-body">
                                 <div class="testimonial-text"><%=c.description%></div>
                                 <div class="testimonial-name"><%=c.title%> <span class="testimonial-position"><%=c.summary%></span></div>
                              </div>
                           </div>
                        </div>
                        <%}%>
                     </div>
                  </div>
               </div>
            </section>
			<%}%>  
         </div>
         <!-- /CONTENT AREA -->
         
         <!-- FOOTER -->
         <footer class="footer">
         	<MenuTransferFooterControl:insert runat="server"/>
         </footer>
            
            <!-- PAGE -->
            <%if (foundKpis) {%>
            <section class="page-section image">
               <div class="container">
                  <div class="row">
                  	<%foreach(FContent c in contentKpis){
                  		string faClass = "fa-car";
                  		if(c.fields != null && c.fields.Count>0){
							foreach(ContentField cf in c.fields){
								if(cf.enabled && "faclass".Equals(cf.description)){
									faClass = cf.value;
									break;
								}
							}                  			
                  		}%>                  
                     <div class="col-md-3 col-sm-6">
                        <div class="thumbnail thumbnail-counto no-border no-padding">
                           <div class="caption">
                              <div class="caption-icon"><i class="fa <%=faClass%>"></i></div>
                              <div class="caption-number"><%=c.summary%></div>
                              <h4 class="caption-title"><%=c.title%></h4>
                           </div>
                        </div>
                     </div>
                     <%}%>
                  </div>
               </div>
            </section>
            <%}%> 
            <!-- /PAGE -->            
            
            <!-- PAGE -->
            <%if (foundAdvantages) {%>
            <section class="page-section">
               <div class="container">
                  <div class="row">
                  	<%foreach(FContent c in contentAdvantages){
                  		string faClass = "fa-map-marker";
                  		if(c.fields != null && c.fields.Count>0){
							foreach(ContentField cf in c.fields){
								if(cf.enabled && "faclass".Equals(cf.description)){
									faClass = cf.value;
									break;
								}
							}                  			
                  		}
                  		%>
                     <div class="col-md-4">
                        <div class="thumbnail thumbnail-featured no-border no-padding">
                           <div class="media">
                              <a class="media-link" href="#">
                                 <div class="caption">
                                    <div class="caption-wrapper div-table">
                                       <div class="caption-inner">
                                          <div class="caption-icon"><i class="fa <%=faClass%>"></i></div>
                                          <h4 class="caption-title"><%=c.title%></h4>
                                          <div class="caption-text"><%=c.summary%></div>
                                       </div>
                                    </div>
                                 </div>
                                 <div class="caption hovered">
                                    <div class="caption-wrapper div-table">
                                       <div class="caption-inner">
                                          <div class="caption-icon"><i class="fa <%=faClass%>"></i></div>
                                          <h4 class="caption-title"><%=c.title%></h4>
                                       </div>
                                    </div>
                                 </div>
                              </a>
                           </div>
                        </div>
                     </div>
                     <%}%>
                  </div>
               </div>
            </section>
            <%}%> 
            <!-- /PAGE -->  
            
         <CommonFooter:insert runat="server" />
         <!-- /FOOTER -->
         <div id="to-top" class="to-top"><i class="fa fa-angle-up"></i></div>
      </div>
      <!-- /WRAPPER -->
      <!-- JS Global -->
      <script src="/common/js/theme.js"></script>
</body>
</html>