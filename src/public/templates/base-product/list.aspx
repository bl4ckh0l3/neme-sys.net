<%@ Page Language="C#" AutoEventWireup="true" CodeFile="list.aspx.cs" Inherits="_List" Debug="false"%>
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

<%
if(bolFoundLista) {
	foreach(Product p in products){%>
		function checkFieldsValidations<%=p.id%>(){
			<%if(p.fields != null && p.fields.Count>0){%>
				<%=ProductService.renderFieldJsFormValidation(p.fields, lang.currentLangCode, lang.defaultLangCode)%>
				return true;
			<%}else{%>
				return true;
			<%}%>
		}
	<%}
}%>


var formSent = false;
function addToCarrello(theFrom, counter, checkqtafields){
	var formname = theFrom.name;
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
	
	jQuery.globalEval("var checkf = checkFieldsValidations"+theFrom.productid.value+"()");
	if(!checkf){return};
	
	var hasfield4prod = false;
	var query_string = "id_prod="+theFrom.productid.value;
	query_string+="&prod_fields="
	
	var jsonfields = "";

	var fieldscounter = 0;	
	$("#"+formname+" select[name*='product_field_']").each(function(){
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

	$("#"+formname+" input:checkbox[name*='product_field_']").each(function(){
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

	$("#"+formname+" input:radio[name*='product_field_']").each(function(){
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
		
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
		
		final_qta = ajaxCheckQta4Prod(theFrom.productid.value, sel_qta);
		if(final_qta>max_prod_qty){
			$("#addtocardloadingimg"+counter).hide();
			$("#addtocardloading"+counter).show();
			alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.exceed_qta_prod")%> ");
			return;			
		}
	
		if(hasfield4prod){
			final_qta = ajaxCheckQta4X(theFrom.name, theFrom.productid.value, sel_qta, counter, 0, 0, jsonfields);
			query_string+="&quantity="+final_qta;
			//alert("query_string 2: "+query_string);
	
			result = ajaxCheckFieldAvailability(query_string);
			//alert("result: "+result);
	
			var obj = jQuery.parseJSON(result);
			var ischecked = obj.checked;
			var message_error_qta = obj.message_error;
	
			if (ischecked!="1"){
				$("#addtocardloadingimg"+counter).hide();
				$("#addtocardloading"+counter).show();
				alert("<%=lang.getTranslated("frontend.template_prodotto.js.alert.notfound_qta_prod_field")%> "+message_error_qta);
				return;
			}
		}
	}
	
	if(formSent == false){
		formSent = true;
		$("#addtocardloading"+counter).hide();
		$("#addtocardloadingimg"+counter).show();
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

function changeCurrency(){
	document.change_currency.submit();
}

function changeOrder(){
	document.change_order.submit();
}

function openDetailContentPage(productid){
	<%if(bolHasDetailLink){%>
    document.form_detail_link_news.productid.value=productid;
    document.form_detail_link_news.submit();
	<%}%>
}
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
				<div align="left" style="padding-top:0px;<%if (!"2".Equals(confservice.get("disable_ecommerce").value)) {Response.Write("float:left;");}%>">
				<form name="change_order" method="post" action="<%=Request.Url%>">
				<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">	
				<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
				<input type="hidden" value="<%=categoryid%>" name="categoryid">	
				<input type="hidden" value="<%=numPage%>" name="page">			
				<span class="prodotto_select_label"><%=lang.getTranslated("frontend.template_prodotto.order.label")%></span>&nbsp;<select class="prodotto_select" name="order_by" onchange="javascript:changeOrder();">
				<option value=""></option>
				<option value="1" <%if(orderBy==1){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_name_asc")%></option>
				<option value="2" <%if(orderBy==2){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_name_desc")%></option>
				<option value="11" <%if(orderBy==11){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_price_asc")%></option>
				<option value="12" <%if(orderBy==12){Response.Write("selected");}%>><%=lang.getTranslated("frontend.template_prodotto.label.orderby_price_desc")%></option>
				</select>
				</form>
				</div>
			
				<%if (!"2".Equals(confservice.get("disable_ecommerce").value)) {%>
					<div>
						<form name="change_currency" method="post" action="<%=Request.Url%>">
							<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">	
							<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
							<input type="hidden" value="<%=categoryid%>" name="categoryid">	
							<input type="hidden" value="<%=numPage%>" name="page">
							<input type="hidden" value="<%=orderBy%>" name="order_by">  
							
							&nbsp;|&nbsp;<span class="prodotto_select_label"><%=lang.getTranslated("frontend.template.currency.label")%></span>&nbsp;<select class="prodotto_select" name="currency" onchange="javascript:changeCurrency();">
							<option value=""></option>
							<%foreach(Currency x in currencyList){%>
							<option value="<%=x.currency%>" <%if(x.currency == (string)Session["currency"]){Response.Write("selected");}%>><%=x.currency%> (<%=lang.getTranslated("backend.currency.keyword.label."+x.currency)%>)</option>
							<%}%>
							</select>
						</form>
					</div>
				<%}%>
					
				<%int counter = 0;
				if(bolFoundLista) {%>
					<br/>			
					<%for(counter = fromProduct; counter<= toProduct;counter++){
						Product product = products[counter];
						IList<string> pelements = null;
						bool foundpel = prodsData.TryGetValue(product.id, out pelements);
						string prevprice = "0";
						string price = "0";
						string discountperc = "0";
						string suppdesc = "";
						
						if(foundpel){
							prevprice = pelements[0];
							price = pelements[1];
							discountperc = pelements[2];
							suppdesc = pelements[3];
						}
						%>
						<form action="<%=shoppingcardURL%>" method="post" name="form_add_to_carrello_<%=counter%>" id="form_add_to_carrello_<%=counter%>" enctype="multipart/form-data">
						<!--<input type="hidden" value="<%//=price%>" name="price">-->
						<input type="hidden" value="<%=product.id%>" name="productid">
						<input type="hidden" value="<%=product.prodType%>" name="prod_type">
						<input type="hidden" value="<%=hierarchy%>" name="hierarchy">
						<input type="hidden" value="<%=categoryid%>" name="categoryid">
						<input type="hidden" value="additem" name="operation">
						<input type="hidden" value="<%=counter%>" name="form_counter">
						<input type="hidden" value="<%=product.quantity%>" name="max_prod_qta">	
						
						<div>
							<div class="prodotto-immagine">
							<%if (product.attachments != null && product.attachments.Count>0) {	
								bool hasNotSmallImg = true;
								foreach(ProductAttachment attach in product.attachments){	
									foreach(ProductAttachmentLabel cal in attachmentsLabel){
										if(cal.id==attach.fileLabel){
											if(cal.description.Equals("img small")){%>	
												<img src="/public/upload/files/products/<%=attach.filePath+attach.fileName%>" alt="<%=attach.fileDida%>" width="140" height="130" />
												<%hasNotSmallImg = false;
												break;
											}
										}
									}	
								}		
								if(hasNotSmallImg) {%>
									<img width="140" height="130" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
								<%}
							}else{%>
								<img width="140" height="130" src="/common/img/spacer.gif" hspace="0" vspace="0" border="0">
							<%}%>
							</div>						
							<div class="prodotto-testo">
							<h2><a href="javascript:openDetailContentPage(<%=product.id%>);"><%=productrep.getMainFieldTranslationCached(product.id, 1 , lang.currentLangCode, true,  product.name, true).value%></a></h2>
							<p><%=productrep.getMainFieldTranslationCached(product.id, 2 , lang.currentLangCode, true,  product.summary, true).value%></p>
							
							<%if (!"2".Equals(confservice.get("disable_ecommerce").value)) {%>
								<p>
								<%if(!String.IsNullOrEmpty(discountperc) && Convert.ToDecimal(discountperc) > 0) {%><span class="testoBarrato"><%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]))) {Response.Write(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]));}else{Response.Write(Session["currency"]);}%>&nbsp;<%=prevprice+"&nbsp;"+suppdesc%></span><br/><%}%>
								<%if(!String.IsNullOrEmpty(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]))){Response.Write(lang.getTranslated("backend.currency.symbol.label."+Session["currency"]));}else{Response.Write(Session["currency"]);}%>&nbsp;<%=price+"&nbsp;"+suppdesc%>
								
								<%if(!String.IsNullOrEmpty(discountperc) && Convert.ToDecimal(discountperc) > 0) {Response.Write("<br/><br/><strong>"+lang.getTranslated("frontend.template_prodotto.table.label.sconto")+" "+discountperc+"%</strong>");}%>		
								<%if(product.status==0){
									Response.Write("<br/><br/>"+lang.getTranslated("frontend.template_prodotto.table.alt.non_disponibile"));
								}					
							
								// gestisco i field per contenuto
								if(product.fields != null && product.fields.Count>0){
									Response.Write(ProductService.renderField(product.fields, null, "", "", lang.currentLangCode, lang.defaultLangCode, ProductService.getMapProductFieldsTranslations(product.id)));
								}%>
								</p>
							<%}%>						
							</div>
							<div class="clear"></div>
							<div class="prodotto-footer">							
							<%if ("0".Equals(confservice.get("disable_ecommerce").value)) {%>
								<%if(product.status== 1 && product.quantity!=0){
									int checkqtafields = 1;
									if(product.quantity == -1){checkqtafields = 0;}%>
									<span style="display:none;" id="addtocardloadingimg<%=counter%>"><img src="/common/img/loading_icon.gif" border="0" width="16" height="16" hspace="0" vspace="0"></span>
									<span id="addtocardloading<%=counter%>"><a href="javascript:addToCarrello(document.form_add_to_carrello_<%=counter%>,<%=counter%>, <%=checkqtafields%>);" title="<%=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="/common/img/cart_add.png" hspace="0" vspace="0" border="0"></a></span>
									<!--<a href="javascript:ajaxCheckQta6Multiple('form_add_to_carrello_<%=counter%>', document.form_add_to_carrello_<%=counter%>.productid.value, document.form_add_to_carrello_<%=counter%>.quantity.value, <%=counter%>, 6, 0),addToCarrello(document.form_add_to_carrello_<%=counter%>,<%=counter%>, <%=checkqtafields%>);" title="<%//=lang.getTranslated("frontend.template_prodotto.table.alt.put_on_carrello")%>"><img src="/common/img/cart_add.png" hspace="0" vspace="0" border="0"></a>-->
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
							</div>
						</div>
						
						</form>
					<%}%>
					<div><CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" /></div>
				<%}else{%>
					<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
				<%}%>
			</div>
			<form method="post" name="form_detail_link_news" action="<%=detailURL%>">	
			<input type="hidden" value="" name="productid">	
			<input type="hidden" value="<%=modelPageNum+1%>" name="modelPageNum">	
			<input type="hidden" value="<%=hierarchy%>" name="hierarchy">	
			<input type="hidden" value="<%=categoryid%>" name="categoryid">	
			<input type="hidden" value="<%=numPage%>" name="page">
			<input type="hidden" value="<%=orderBy%>" name="order_by">  
			<input type="hidden" value="<%=Request["product_preview"]%>" name="product_preview">          
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
