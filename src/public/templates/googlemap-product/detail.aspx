<%@ Page Language="C#" AutoEventWireup="true" CodeFile="detail.aspx.cs" Inherits="_Detail" Debug="false"%>
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
<script language="JavaScript">

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


var formSent = false;
function addToCarrello(theFrom, checkqtafields){
	var sel_qta = theFrom.quantity.value;
	if(sel_qta == ""){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.select_qta_prod")%>");
		return;
	}else if(isNaN(sel_qta)){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.quantity.value = "";
		return;
	}else if(sel_qta.indexOf('.') != -1){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.only_integer_value")%>");
		theFrom.quantity.value = "";
		return;
	}
	
	<%
	if(productFields.Count>0){ 
		Response.Write(ProductService.renderFieldJsFormValidation(productFields, lang.currentLangCode, lang.defaultLangCode));
	}%>	

	var hasfield4prod = false;
	var query_string = "id_prod="+theFrom.productid.value;
	query_string+="&prod_fields="
	
	var jsonfields = "";

	var fieldscounter = 0;	
	$("select[name*='product_field_']").each(function(){
		var key = $(this).attr('name');
		key = key.substring(key.lastIndexOf('_')+1); 
		var myRegExp = new RegExp(/"/g);
		var thisval = $(this).val();		
		if(thisval instanceof Array){
			thisval = thisval.toString();
		}				
		thisval = thisval.replace(myRegExp, '\&quot;');				
		jsonfields += "\""+fieldscounter+"-"+key+"\":\""+encodeURIComponent(thisval)+"\",";	
		hasfield4prod = true;
		fieldscounter++;
	});

	$("input:checkbox[name*='product_field_']").each(function(){
		var key = $(this).attr('name');
		key = key.substring(key.lastIndexOf('_')+1); 
		if($(this).is(':checked')){
			var myRegExp = new RegExp(/"/g);
			var thisval = $(this).val();		
			if(thisval instanceof Array){
				thisval = thisval.toString();
			}				
			thisval = thisval.replace(myRegExp, '\&quot;');				
			jsonfields += "\""+fieldscounter+"-"+key+"\":\""+encodeURIComponent(thisval)+"\",";	
			hasfield4prod = true;
			fieldscounter++;
		}
	});	

	$("input:radio[name*='product_field_']").each(function(){
		var key = $(this).attr('name');
		key = key.substring(key.lastIndexOf('_')+1); 
		if($(this).is(':checked')){
			var myRegExp = new RegExp(/"/g);
			var thisval = $(this).val();			
			if(thisval instanceof Array){
				thisval = thisval.toString();
			}			
			thisval = thisval.replace(myRegExp, '\&quot;');				
			jsonfields += "\""+fieldscounter+"-"+key+"\":\""+encodeURIComponent(thisval)+"\",";	
			hasfield4prod = true;
			fieldscounter++;
		}
	});	
	
	jsonfields = jsonfields.substring(0,jsonfields.lastIndexOf(","));
	jsonfields = "{"+jsonfields;
	jsonfields += "}";	
	
	query_string+=jsonfields;
	
	//alert(query_string);
	
	//integro chiamata ajax per verificare disponibilita combinazione field prodotto
	if(checkqtafields==1){
		var final_qta;
		var max_prod_qty = theFrom.max_prod_qta.value;
		
		$("#addtocardloading").hide();
		$("#addtocardloadingimg").show();
		
		final_qta = ajaxCheckQta4Prod(theFrom.productid.value, sel_qta);
		if(final_qta>max_prod_qty){
			$("#addtocardloadingimg").hide();
			$("#addtocardloading").show();
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%> ");
			return;			
		}
	
		if(hasfield4prod){
			$("#addtocardloading").hide();
			$("#addtocardloadingimg").show();
			final_qta = ajaxCheckQta4X(theFrom.name, theFrom.productid.value, sel_qta, "", 0, 0, jsonfields);
			query_string+="&quantity="+final_qta;
			//alert("query_string 2: "+query_string);
	
			result = ajaxCheckFieldAvailability(query_string);
			//alert("result: "+result);
	
			var obj = jQuery.parseJSON(result);
			var ischecked = obj.checked;
			var message_error_qta = obj.message_error;
	
			if (ischecked!="1"){
				$("#addtocardloadingimg").hide();
				$("#addtocardloading").show();
				alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
				return;
			}
		}
	}
	
	if(formSent == false){
		formSent = true;
		$("#addtocardloading").hide();
		$("#addtocardloadingimg").show();
		theFrom.submit();
	}else{
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.form_already_sent")%>");
	}
}

function checkMaxQtaProd(maxQtaProd, field){
	if(Number(field.value) > maxQtaProd){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%>");
		field.value="";
	}
}
  
function checkQta6Multiple(field){
    if(Number(field.value) > 1 && Number(field.value) % 6 != 0){
      alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.no_multilpe_6_qta_prod")%>");
      field.value="";      
    }
}

function ajaxCheckQta4Prod(id_prod, qta_prod){
	var query_string = "id_prod="+id_prod+"&qta_prod="+qta_prod;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=currentBaseURL+"ajaxcheckprodqta.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("response: "+response);
			return;
		},
		error: function(response) {
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = response;
		}
	});
  
  	var final_qta = Number(qta_prod)
  	if(!isNaN(resp)){
  		final_qta+=Number(resp);
	}
	return final_qta;
}

function ajaxCheckQta4X(theForm, id_prod, qta_prod, counter, x, method, jsonfields){
	var query_string = "id_prod="+id_prod+"&prod_counter="+counter+"&qta_prod="+qta_prod+"&prod_fields="+jsonfields;
	//alert("query_string: "+query_string);

	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "<%=currentBaseURL+"ajaxcheckprodfieldsqta.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("response: "+response);
			return;
		},
		error: function(response) {
			/*$("#ajaxresp").empty();
			$("#ajaxresp").append("<%=lang.getTranslated("backend.commons.fail_updated_field")%>");
			$("#ajaxresp").fadeIn(1500,"linear");
			$("#ajaxresp").fadeOut(600,"linear");*/
			resp = response;
		}
	});
  
  	var final_qta = Number(qta_prod)
  	if(!isNaN(resp)){
  		final_qta+=Number(resp);
	}
  	//alert("resp: "+resp+" - final_qta: "+final_qta);
	var lock = false;
	if(method==0){
		return final_qta;
	}else if(method==1){
		if(Number(final_qta) > 1 && Number(final_qta) % x != 0){
			lock = true;
		}
	}else if(method==2){
		if(Number(final_qta) > x){
			lock = true;
		}	
	}
	if(lock){
		alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.no_multilpe_6_qta_prod")%>");
		var objForm = $('#'+theForm);
		objForm.quantity.value="";  
		return;	
	}
}

function ajaxCheckFieldAvailability(query_string){
	//alert("query_string: "+query_string);
	
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		//dataType: "xml",
		url: "<%=currentBaseURL+"ajaxcheckprodavailability.aspx"%>",
		data: query_string,
		success: function(response) {
			resp = response;
			//alert("resp: "+resp);
			//alert("ischecked: "+ischecked+" - message_error_qta: "+message_error_qta);
		},
		error: function(response) {
			resp = response;
			//alert("resp error: "+response);
		}
	});

	return resp;
}


function openAttach(path, fileName, idAttach, contentType){

	var query_string = "attach_id="+idAttach+"&attach_path="+path+"&page_url=<%=Request.Url%>&contenttype="+contentType+"&filename="+fileName;
	//alert(query_string);
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "/public/layout/addson/tracking/ajaxlogdownload-p.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			
		},
		error: function() {
			//alert("error");
		}
	});	
	
	window.open('/public/upload/files/products/'+path, '_blank');
}

function changeCurrency(){
	document.change_currency.submit();
}

function openRelatedProdPage(actionurl, hierarchy, idProduct, numPageNum){
	if(actionurl != "#"){
		document.form_detail_rel_prod.action=actionurl;
		document.form_detail_rel_prod.hierarchy.value=hierarchy;
		document.form_detail_rel_prod.productid.value=idProduct;
		document.form_detail_rel_prod.modelPageNum.value=numPageNum;
		document.form_detail_rel_prod.submit();
    }
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
			<%if (product != null) {%>
				<%if (!"2".Equals(confservice.get("disable_ecommerce").value)) {%>
					<div>
						<form name="change_currency" method="post" action="<%=Request.Url%>">
							<input type="hidden" value="<%=product.id%>" name="productid">	
							<input type="hidden" value="<%=modelPageNum+1%>" name="modelPageNum">	
							<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
							<input type="hidden" value="<%=categoryid%>" name="categoryid">	
							<input type="hidden" value="<%=numPage%>" name="page">
							<input type="hidden" value="<%=orderBy%>" name="order_by">  
							
							<!-- &nbsp;|&nbsp; --><span class="prodotto_select_label"><%=lang.getTranslated("frontend.template.currency.label")%></span>&nbsp;<select class="prodotto_select" name="currency" onchange="javascript:changeCurrency();">
							<option value=""></option>
							<%foreach(Currency x in currencyList){%>
							<option value="<%=x.currency%>" <%if(x.currency == (string)Session["currency"]){Response.Write("selected");}%>><%=x.currency%> (<%=lang.getTranslated("backend.currency.keyword.label."+x.currency)%>)</option>
							<%}%>
							</select>
						</form>
					</div>
				<%}%>			
			
			
				<div>
					<p><strong><asp:Literal id="cname" runat="server" /></strong></p>
					<div style="float:right;width:300px;height:250px;vertical-align:top;text-align:left;display:none;border:1px solid;background:#FFFFFF;margin-left:3px;" id="map"></div>
					<asp:Literal id="csummary" runat="server" />
					<asp:Literal id="cdescription" runat="server" />		
					
					<form action="<%=shoppingcardURL%>" method="post" name="form_add_to_carrello" id="form_add_to_carrello" enctype="multipart/form-data">
					<!--<input type="hidden" value="<%//=price%>" name="price">-->
					<input type="hidden" value="<%=product.id%>" name="productid">
					<input type="hidden" value="<%=product.prodType%>" name="prod_type">
					<input type="hidden" value="<%=hierarchy%>" name="hierarchy">
					<input type="hidden" value="<%=categoryid%>" name="categoryid">
					<input type="hidden" value="additem" name="operation">
					<input type="hidden" value="<%=product.quantity%>" name="max_prod_qta">	
		   
					<%if (!"2".Equals(confservice.get("disable_ecommerce").value)) {%>
						<h3>
						<%if(discountperc > 0) {%><span class="testoBarrato"><%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]))) {Response.Write(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]));}else{Response.Write(Session["currency"]);}%>&nbsp;<%=prevprice.ToString("###0.00")+"&nbsp;"+suppdesc%></span><br/><%}%>
						<%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]))){Response.Write(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]));}else{Response.Write(Session["currency"]);}%>&nbsp;<%=price.ToString("###0.00")+"&nbsp;"+suppdesc%>
						</h3>
						<%if(discountperc > 0) {Response.Write("<h3><strong>"+lang.getTranslated("frontend.template_prodotto.table.label.sconto")+" "+discountperc.ToString("###0.##")+"%</strong></h3>");}%>		
						<%if(product.status==0){
							Response.Write("<h3>"+lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")+ "</h3>");
						}
					}%>
					
					<%
					if(productFields.Count>0){ 
						Response.Write(ProductService.renderField(productFields, null, "", "", lang.currentLangCode, lang.defaultLangCode, ProductService.getMapProductFieldsTranslations(product.id)));
					}%>
					

					<%if ("0".Equals(confservice.get("disable_ecommerce").value)) {%>
						<div style="height:30px;"></div>
						<%if(product.status== 1 && product.quantity!=0){
							int checkqtafields = 1;
							if(product.quantity == -1){checkqtafields = 0;}%>
							<span style="display:none;" id="addtocardloadingimg"><img src="/common/img/loading_icon.gif" border="0" width="16" height="16" hspace="0" vspace="0"></span>
							<span id="addtocardloading"><a href="javascript:addToCarrello(document.form_add_to_carrello, <%=checkqtafields%>);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="/common/img/cart_add.png" hspace="0" vspace="0" border="0"></a></span>
							<!--<a href="javascript:ajaxCheckQta6Multiple('form_add_to_carrello', document.form_add_to_carrello.id_prodotto.value, document.form_add_to_carrello.quantity.value, '', 6, 0),addToCarrello(document.form_add_to_carrello, <%=checkqtafields%>);" title="<%//=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="/common/img/cart_add.png" hspace="0" vspace="0" border="0"></a>-->
						<%}else{%>
							<img src="/common/img/ico-carrello.png" hspace="0" vspace="0" border="0" alt="<%=lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")%>" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")%>">
						<%}%>

						<%//GESTISCO LA QUANTITA' SELEZIONABILE	
						if(product.status== 1 && product.quantity!=0){
							if(product.quantity == -1) {
								if(product.setBuyQta){%>
									<input type="text" name="quantity" value="" onkeypress="javascript:return isInteger(event);" class="formFieldTXTShort">
									<!--<input type="text" name="quantity" value="" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkQta6Multiple(this);" class="formFieldTXTShort">-->
								<%}else{%>
									<input type="hidden" name="quantity" value="1">
								<%}
							}else{
								if(product.setBuyQta) {%>
									<input type="text" name="quantity" id="quantity" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%=product.quantity%>,this);">
									<!--<input type="text" name="quantity" id="quantity" value="" class="formFieldTXTShort" onkeypress="javascript:return isInteger(event);" onblur="javascript:checkMaxQtaProd(<%//=product.quantity%>,this),checkQta6Multiple(this);">-->				
								<%}else{%>
									<input type="hidden" name="quantity" value="1">
								<%}%>
								&nbsp;<%=lang.getTranslated("frontend.template_prodotto.table.label.product_disp")+"&nbsp;"+product.quantity%>&nbsp;&nbsp;
							<%}
						}else{%>
							&nbsp;<%=lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile")%>
						<%}						
					}%>
					
					</form>

					
					<%if(attachmentsDictionary.Keys.Count>0){ 
						foreach(string keyword in attachmentsDictionary.Keys){%>
							<br/><br/><strong><%=keyword%></strong><br/>
							<%foreach(ProductAttachment item in attachmentsDictionary[keyword]){%>
								<a href="javascript:openAttach('<%=item.filePath+item.fileName%>','<%=item.fileName%>','<%=item.id%>','<%=item.contentType%>')"><%=item.fileName%></a><br>
							<%}
						}
					}%>
				</div>
				
				
				<%
				if (product.relations != null && product.relations.Count>0){%>
					<div style="display:block;float:top;text-align:center;padding-top:20px;" align="left">
					<h2><%=lang.getTranslated("frontend.template_prodotto.table.label.related_prod")%></h2>
					<%
					int prcounter = 1;
					foreach(ProductRelation k in product.relations){
						Product rel = productrep.getByIdCached(k.idProductRel,true);
						bool hasNotSmallImg = true;
						string relName = productrep.getMainFieldTranslationCached(rel.id, 1 , lang.currentLangCode, true,  rel.name, true).value;
						
						string relUrl = "#";
						string relHierarchy = "";
						int relModelPageNum = 0;
						
						IList<ProductCategory> relpcats = productrep.getProductCategories(rel.id);
						if(relpcats != null && relpcats.Count>0){
							Category relcategory = catrep.getByIdCached(relpcats.First().idCategory, true);
							relHierarchy = relcategory.hierarchy;
							Template reltemplate = null;
							
							int relTemplateId = relcategory.idTemplate;
							foreach(CategoryTemplate ct in relcategory.templates)
							{
								if(ct.langCode==lang.currentLangCode)
								{
									relTemplateId = ct.templateId;
									break;
								}	
							}
							if(relTemplateId>0){
								reltemplate = templrep.getByIdCached(relTemplateId,true);
							}
							if(reltemplate != null)
							{
								relModelPageNum = templrep.findMaxPriority(reltemplate);
								bool relLangHasSubDomainActive = false;
								string relLangUrlSubdomain = "";
								Language relLanguage = langrep.getByLabel(lang.currentLangCode, true);		
								StringBuilder builder = new StringBuilder(Request.Url.Scheme).Append("://");
								
								if(relLanguage != null)
								{	
									relLangHasSubDomainActive = relLanguage.subdomainActive;
									relLangUrlSubdomain = relLanguage.urlSubdomain;
								}								
								
								relUrl = MenuService.resolvePageHrefUrl(builder.ToString(), relModelPageNum, lang.currentLangCode, relLangHasSubDomainActive, relLangUrlSubdomain, relcategory, reltemplate, true);	
								if(relUrl==null){
									relUrl = "#";
								}
							}
						}
						%>
				
						<%if(prcounter % 4 == 0){%><div id="clear"></div><%}%>
						<div class="prodotto-immagine" style="margin:5px;padding-right:5px;">
						<%if (rel.attachments != null && rel.attachments.Count>0) {		
							foreach(ProductAttachment attach in rel.attachments){	
								foreach(ProductAttachmentLabel cal in attachmentsLabel){
									if(cal.id==attach.fileLabel){
										if(cal.description.Equals("img small")){%>	
											<a href="javascript:openRelatedProdPage('<%=relUrl%>', '<%=relHierarchy%>', <%=rel.id%>, <%=relModelPageNum%>);" title="<%=relName%>"><img src="/public/upload/files/products/<%=attach.filePath+attach.fileName%>" alt="<%=relName%>" width="100" height="100" /></a>
											<%hasNotSmallImg = false;
											break;
										}
									}
								}	
							}		
							if(hasNotSmallImg) {%>
								<a href="javascript:openRelatedProdPage('<%=relUrl%>', '<%=relHierarchy%>', <%=rel.id%>, <%=relModelPageNum%>);" title="<%=relName%>"><img width="100" height="100" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0" alt="<%=relName%>"></a>
							<%}
						}else{%>
							<a href="javascript:openRelatedProdPage('<%=relUrl%>', '<%=relHierarchy%>', <%=rel.id%>, <%=relModelPageNum%>);" title="<%=relName%>"><img width="100" height="100" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0" alt="<%=relName%>"></a>
						<%}%>
						<p><%=relName%></p>
						<strong><%=lang.getTranslated("backend.prodotti.detail.table.label.cod_rel_prod")%>:</strong>&nbsp;<%=rel.keyword%>
						</div>
						<%prcounter++;
					}%>
					</div>
					<div id="clear" style="margin-bottom:20px;"></div>
					
					<form action="" method="post" name="form_detail_rel_prod">	   
					<input type="hidden" value="" name="productid">	
					<input type="hidden" value="" name="modelPageNum">	
					<input type="hidden" value="" name="hierarchy">		
					<input type="hidden" value="<%=numPage%>" name="page">
					<input type="hidden" value="<%=orderBy%>" name="order_by">  
					</form>	
				<%}%>				
		
				
				<CommentsWidgetWrapperControl:render runat="server" ID="cwwc1" index="1"/>
		
				<!--<div id="torna"><a href="/common/include/feedRSS.aspx?hierarchy=<%=hierarchy%>&productid=<%=product.id%>&page=<%=numPage%>&modelPageNum=<%=modelPageNum%>" target="_blank"><img src="/common/img/rss_image.gif" vspace="3" hspace="3" border="0" align="right" alt="RSS"></a></div>-->
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