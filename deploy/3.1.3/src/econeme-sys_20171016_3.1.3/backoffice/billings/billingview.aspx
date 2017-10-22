<%@ Page Language="C#" AutoEventWireup="true" CodeFile="billingview.aspx.cs" Inherits="_BillingView" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Text" %>
<%@ import Namespace="System.Text.RegularExpressions" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script src="/common/js/jspdf.min.js"></script>
<script src="/common/js/jspdf.plugin.autotable.min.js"></script>

<script>
// https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.3/jspdf.min.js

function generateBillingImage(imgId,imgType,orderId,billingId){

	var doc = new jsPDF('p', 'pt', 'a4');
	
	var firstStartY = 20;
	
	if(imgId){
		var c = document.createElement('canvas');
		var ctx = c.getContext('2d');
		var img = document.getElementById(imgId);
		//c.height = img.naturalHeight;
		//c.width = img.naturalWidth;
		c.height = img.height;
		c.width = img.width;
		ctx.drawImage(img, 0, 0);
		var base64String = c.toDataURL(imgType); 
		var imgWidth = img.width/100*78;
		var imgHeight = img.height/100*78;
		firstStartY = img.height+20;
		
		//alert("real imgWidth: "+img.width+"\npdf imgWidth: "+imgWidth+"\nreal imgHeight: "+img.height+"\npdf imgHeight: "+imgHeight);
	}
	
	var pageContent = function (data) {
		if(imgId){
			if (base64String) {
				doc.addImage(base64String, imgType, data.settings.margin.left, 15, imgWidth, imgHeight);
			}
		}
	}; 	
	
	var res = doc.autoTableHtmlToJson(document.getElementById('invoice-table'));
	doc.autoTable(res.columns, res.data, {
		addPageContent: pageContent,
		startY: firstStartY,
		theme: 'grid',
		headerStyles: {fontStyle: 'normal',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res2 = doc.autoTableHtmlToJson(document.getElementById('invoice-table2'));
	doc.autoTable(res2.columns, res2.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res3 = doc.autoTableHtmlToJson(document.getElementById('invoice-table3'));
	doc.autoTable(res3.columns, res3.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res4 = doc.autoTableHtmlToJson(document.getElementById('invoice-table4'));
	doc.autoTable(res4.columns, res4.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res5 = doc.autoTableHtmlToJson(document.getElementById('invoice-table5'));
	doc.autoTable(res5.columns, res5.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res6 = doc.autoTableHtmlToJson(document.getElementById('invoice-table6'));
	doc.autoTable(res6.columns, res6.data, {
		startY: doc.autoTableEndPosY() + 10,
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	var res7 = doc.autoTableHtmlToJson(document.getElementById('invoice-table7'));
	doc.autoTable(res7.columns, res7.data, {
		startY: doc.autoTableEndPosY(),
		theme: 'grid',
		headerStyles: {overflow: 'linebreak',fontStyle: 'bold',fillColor: false,textColor: 20,lineColor: 20,lineWidth: 1},
		bodyStyles: {overflow: 'linebreak',fontStyle: 'normal',lineColor: 20,lineWidth: 1},
		showHeader: 'firstPage'
	});
	
	
	//doc.save("table.pdf");

	var result = doc.output("datauristring");
	result = result.replace(/^data:application\/pdf;base64,/, "");	

	var query_string = "id_order="+orderId+"&id_billing="+billingId+"&img_data="+encodeURIComponent(result);	
	//alert(query_string);

	$('#create_invoice').hide();
	$('#view_invoice').hide();
	$('#loading_billing_buttons').show();	
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "/backoffice/billings/ajaxbillingimagecreate.aspx",
		data: query_string,
		success: function(response) {
			$('#loading_billing_buttons').hide();	
			$('#create_invoice').show();
			$('#view_invoice').show();
			//$("#view_invoice").attr("style", "visibility:visible;display:inline;");
		},
		error: function(response) {
			//alert(response.responseText);	
			
			$('#loading_billing_buttons').hide();	
			$('#create_invoice').show();
			$('#view_invoice').hide();
			//$("#view_invoice").attr("style", "visibility:hidden;display:none;");
			
			alert("<%=lang.getTranslated("backend.billing.lista.js.alert.error_generate_pdf")%>");
		}
	});	
}

function viewBillingfile(orderId,billingId){
	var pdfPath = "/public/upload/files/billings/invoice_"+billingId+"_"+orderId+".pdf"; 
	window.open(pdfPath, '_blank');
}

function getExtension(filename) {
    return filename.split('.').pop().toLowerCase();
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<%if(billing!=null){%>
				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table" style="border:1px solid #C9C9C9;width:800px;">
				<tr>
				<td style="width:300px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<%if(!String.IsNullOrEmpty(companyLogo)){%>
				<img src="<%=companyLogo%>" id="invoice-logo" border="0" align="top" style="margin-bottom:15px;display:block;"/>
				<%}%>
				<strong style="margin-bottom:20px;"><%=billing.name%></strong><br/>
				<%=billing.address%><br/>
				<%=billing.zipCode+"&nbsp;-&nbsp;"+billing.city+"&nbsp;&nbsp;"+lang.getTranslated("portal.commons.select.option.country."+billing.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+billing.stateRegion)%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_cfiscvat")%>:&nbsp;<%=billing.cfiscvat%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_phone")%>:&nbsp;<%=billing.phone%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_fax")%>:&nbsp;<%=billing.fax%><br/>
				<%=billing.description%>		
				</td>
				<td style="width:500px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<%		
				if(order.noRegistration && "1".Equals(confservice.get("show_user_field_on_direct_buy").value) && user.fields != null && user.fields.Count>0 && usrfields != null && usrfields.Count>0){							
					foreach(UserFieldsMatch f in user.fields){
						string label = "";
						string value = "";
						foreach(UserField uf in usrfields){
							if(uf.id==f.idParentField){
								label = uf.description;
								value = f.value;
								if(uf.typeContent==7 || uf.typeContent==8){
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.select.option.country."+f.value))){
										value = lang.getTranslated("portal.commons.select.option.country."+f.value);
									}
								}
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value))){
									label = lang.getTranslated("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+f.value);
								}
								break;
							}										
						}
						Response.Write(label+":&nbsp;"+value+"<br/>");							
					}
				}%>
				
				mail:&nbsp;<%=user.email%><br/>
				
				<%
				//****** MANAGE SHIPPING ADDRESS
				if(hasShipAddress){
					string shipInfo = "";
					string userLabelIsCompanyClient = "";
					if(oshipaddr.isCompanyClient){
						userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company");
					}else{
						userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private");
					}								
					
					shipInfo = oshipaddr.name + " " + oshipaddr.surname + " ("+userLabelIsCompanyClient+")<br/>"+oshipaddr.address +"<br/>"+oshipaddr.zipCode+"&nbsp;-&nbsp;"+oshipaddr.city+"&nbsp;&nbsp;"+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.stateRegion)+"<br/>"+lang.getTranslated("frontend.carrello.table.label.cfiscvat")+":&nbsp;"+oshipaddr.cfiscvat;
					
					Response.Write("<br/><b>"+lang.getTranslated("backend.ordini.view.table.label.shipping_address")+":</b><br/>"+shipInfo+"<br/>");	
				}	
				
				//****** MANAGE BILLS ADDRESS
				if(hasBillsAddress){
					string billsInfo = obillsaddr.name + " " + obillsaddr.surname + "<br/>"+obillsaddr.address +"<br/>"+obillsaddr.zipCode+"&nbsp;-&nbsp;"+obillsaddr.city+"&nbsp;&nbsp;"+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.stateRegion)+"<br/>"+lang.getTranslated("frontend.carrello.table.label.cfiscvat")+":&nbsp;"+obillsaddr.cfiscvat;
									
					Response.Write("<br/><b>"+lang.getTranslated("backend.ordini.view.table.label.bills_address")+":</b><br/>"+billsInfo+"<br/>");					
				}%>				
				</td>
				</tr>
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table2" style="margin-top:20px;width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">				
				<tr>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.doc_type")%></th>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.dta_doc")%></th>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.num_doc")%></th>
				</tr>
				<tr>
				<td style="border:1px solid #C9C9C9;"><%if(billing.idRegisteredBilling>0){Response.Write(lang.getTranslated("backend.ordini.view.table.label.doc_type_registered_bill"));}else{Response.Write(lang.getTranslated("backend.ordini.view.table.label.doc_type_pro_bill"));}%></td>
				<td style="border:1px solid #C9C9C9;"><%if(billing.idRegisteredBilling>0){Response.Write(billing.registeredDate.ToString("dd/MM/yyyy HH:mm"));}else{Response.Write(billing.insertDate.ToString("dd/MM/yyyy HH:mm"));}%></td>
				<td style="border:1px solid #C9C9C9;"><%if(billing.idRegisteredBilling>0){Response.Write(billing.idRegisteredBilling+"/"+billing.registeredDate.ToString("yyyy"));}else{Response.Write("&nbsp;");}%></td>
				</tr>	
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table3" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.id_ordine")%></th>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.dta_insert_order")%></th>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.stato_order")%></th>
				</tr>
				<tr>
				<td style="border:1px solid #C9C9C9;"><%=order.id%></td>
				<td style="border:1px solid #C9C9C9;"><%=order.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
				<td style="border:1px solid #C9C9C9;">
				<%
				string labelStatus = "";
				if (order.status==1) {
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
					Response.Write(labelStatus);
				}else if(order.status==2){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
					Response.Write(labelStatus);
				}else if(order.status==3){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
					Response.Write(labelStatus);
				}else if(order.status==4){ 
					labelStatus = orderStatus[order.status];
					if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
						labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
					}
					Response.Write(labelStatus);
				}
				%></td>	
				</tr>
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table4" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.guid_ordine")%></th>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")%></th>
				<th style="padding-top:10px;border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.pagam_order_done")%></th>
				</tr>
				<tr>
				<td style="border:1px solid #C9C9C9;"><%=order.guid%></td>
				<td style="border:1px solid #C9C9C9;"><%=paymentType%></td>
				<td style="border:1px solid #C9C9C9;"><%=pdone%></td>
				</tr>
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table5" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">									
					<tr>
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.taxable_amount")%></th>
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.tax_amount")%></th>
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.qta_prod")%></th>	
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>	
					<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.prod_type")%></th>			
					</tr>
					<%		
					if(order.products != null && order.products.Count>0){
						int counter = 0;
						foreach(OrderProduct op in order.products.Values){
							Product prod = productrep.getByIdCached(op.idProduct, true);
							IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);
							
							taxableAmount+= op.taxable;
							taxAmount+= op.supplement;

							IList<OrderProductCalendar> opfc = null;
							
							if(prod.prodType==3){
								opfc = orderep.findItemCalendars(order.id, op.idProduct, op.productCounter);
							}							
							
							string adsRefTitle = "";
							if(op.idAds != null && op.idAds>-1){
								Ads a = adsrep.getById(op.idAds);
								if(a != null){
									FContent f = contrep.getByIdCached(a.elementId, true);
									if(f != null){
										adsRefTitle = "<br/><b>"+lang.getTranslated("frontend.carrello.table.label.ads_title")+"</b>&nbsp;"+f.title;
									}
								}
							}
							
							//****** MANAGE SUPPLEMENT DESCRIPTION
							string suppdesc = op.supplementDesc;
							string suppdesctrans = lang.getTranslated("backend.supplement.description.label."+suppdesc);
							if(!String.IsNullOrEmpty(suppdesctrans)){
								suppdesc = suppdesctrans;
							}
							if(!String.IsNullOrEmpty(suppdesc)){
								suppdesc = "&nbsp;("+suppdesc+")";
							}
		
							string opmargin = "";
							if(op.margin > 0){
								opmargin = "<li>"+lang.getTranslated("frontend.carrello.table.label.commissioni")+":&nbsp;&euro;&nbsp;"+op.margin.ToString("#,###0.00")+"</li>";
							}
							
							string opdiscPerc = "";
							if (op.discountPerc > 0) {
								decimal discountValue = 0-op.discount;
								opdiscPerc ="<li>"+lang.getTranslated("frontend.carrello.table.label.sconto_applicato")+"&nbsp;"+op.discountPerc.ToString("#,###0.##")+"%:&nbsp;&euro;&nbsp;"+discountValue.ToString("#,###0.00")+"</li>";
							}					
							
							//****** MANAGE ORDER RULES FOR PRODUCT
							string orderProdRules = "";
							if (hasProductRule){
								foreach(OrderBusinessRule w in productRules){
									int tmpIdProd = w.productId;
									int tmpCounterProd = w.productCounter;
									if(tmpIdProd==op.idProduct && tmpCounterProd==op.productCounter){
										string tmpLabel = w.label;                 
										decimal tmpAmountRule = w.value;
										orderProdRules+="<li>";
										if(!String.IsNullOrEmpty(lang.getTranslated("backend.businessrule.label.label."+tmpLabel))){
											orderProdRules+=lang.getTranslated("backend.businessrule.label.label."+tmpLabel);
										}else{
											orderProdRules+=tmpLabel;
										}
										if(tmpAmountRule!=0){
											orderProdRules+=":&nbsp;&euro;&nbsp;"+tmpAmountRule.ToString("#,###0.00");
										}
										orderProdRules+="</li>";
									}
								}
							}	
							
							//****** MANAGE FIELDS FOR PRODUCT
							string productFields = "";
							if(opfs != null && opfs.Count>0){
								IDictionary<string,ProductFieldTranslation> pftMap = ProductService.getMapProductFieldsTranslations(prod.id);
								ProductFieldTranslation pftv = null;
										
								foreach(OrderProductField opf in opfs){
									string flabel = opf.description;
									if(pftMap.TryGetValue(new StringBuilder().Append(prod.id).Append("-").Append(opf.idField).Append("-").Append("desc").Append("-").Append("").Append("-").Append(lang.currentLangCode).ToString(), out pftv)){
										flabel = pftv.value;
									}	
									
									if(opf.fieldType==8){
										productFields+=flabel+":&nbsp;<a target='_blank' href='"+builder.ToString()+"public/upload/files/orders/"+opf.idOrder+"/"+opf.value+"'>"+opf.value+"</a><br/>";
									}else if(opf.fieldType==3 || opf.fieldType==4 || opf.fieldType==5 || opf.fieldType==6){
										string fvalue = opf.value;
										if(pftMap.TryGetValue(new StringBuilder().Append(prod.id).Append("-").Append(opf.idField).Append("-").Append("values").Append("-").Append(fvalue).Append("-").Append(lang.currentLangCode).ToString(), out pftv)){
											fvalue = pftv.value;
										}else{
											if(opf.fieldType==3){
												string tmpv = lang.getTranslated("portal.commons.select.option.country."+opf.value);
												if(!String.IsNullOrEmpty(tmpv)){
													fvalue = tmpv;
												}
											}
										}
										productFields+=flabel+":&nbsp;"+fvalue+"<br/>";
									}else{
										string fvalue = opf.value;
										if(pftMap.TryGetValue(new StringBuilder().Append(prod.id).Append("-").Append(opf.idField).Append("-").Append("value").Append("-").Append("").Append("-").Append(lang.currentLangCode).ToString(), out pftv)){
											fvalue = pftv.value;
										}
										productFields+=flabel+":&nbsp;"+fvalue+"<br/>";
									}
								}
							}
						
							string boproductCalendars = "";
							if(opfc != null && opfc.Count>0){
								OrderProductCalendar opcStart = opfc[0];
								OrderProductCalendar opcEnd = opfc[opfc.Count-1];
								StringBuilder sb = new StringBuilder("")
								.Append(lang.getTranslated("backend.ordini.view.table.label.adults")).Append(":&nbsp;").Append(opcStart.adults).Append("<br/>")
								.Append(lang.getTranslated("backend.ordini.view.table.label.childs")).Append(":&nbsp;").Append(opcStart.children);
								if(!String.IsNullOrEmpty(opcStart.childrenAge)){
									sb.Append("&nbsp;(")
									.Append(opcStart.childrenAge)
									.Append(")");
								}
								sb.Append("<br/>");
								
								boproductCalendars = sb.ToString();
								boproductCalendars+=lang.getTranslated("backend.ordini.view.table.label.checkin")+":&nbsp;"+opcStart.date.ToString("dd/MM/yyyy")+"&nbsp;("+lang.getTranslated("backend.ordini.view.table.label.rooms")+":&nbsp;"+opcStart.rooms+")<br/>";	
								
								int counterCal = 0;
								if(opfc.Count>2){
									foreach(OrderProductCalendar opc in opfc){
										if(counterCal>0 && counterCal<opfc.Count-1){
											boproductCalendars+=lang.getTranslated("backend.ordini.view.table.label.date")+":&nbsp;"+opc.date.ToString("dd/MM/yyyy")+"&nbsp;("+lang.getTranslated("backend.ordini.view.table.label.rooms")+":&nbsp;"+opc.rooms+")<br/>";	
										}
										counterCal++;
									}
								}
								boproductCalendars+=lang.getTranslated("backend.ordini.view.table.label.checkout")+":&nbsp;"+opcEnd.date.ToString("dd/MM/yyyy")+"&nbsp;("+lang.getTranslated("backend.ordini.view.table.label.rooms")+":&nbsp;"+opcEnd.rooms+")<br/>";	
							}%>				
						
							<tr class="table-list-off">
								<td style="border:1px solid #C9C9C9;"><%=productrep.getMainFieldTranslationCached(op.idProduct, 1 , lang.currentLangCode, true,  op.productName, true).value+adsRefTitle%></td>
								<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=op.taxable.ToString("#,###0.00")%>
									<ul style=padding-left:10px;padding-top:5px;margin:0px;>
									<%=opmargin+opdiscPerc+orderProdRules%>
									</ul>
								</td>
								<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=op.supplement.ToString("#,###0.00")+suppdesc%></td>
								<td style="border:1px solid #C9C9C9;"><%=op.productQuantity%></td>	
								<td style="border:1px solid #C9C9C9;"><%=boproductCalendars+productFields%></td>	
								<td style="border:1px solid #C9C9C9;">
								<%if(op.productType == 0){ 
									Response.Write(lang.getTranslated("backend.prodotti.detail.table.label.type_portable"));
								}else if(op.productType == 1){ 
									Response.Write(lang.getTranslated("backend.prodotti.detail.table.label.type_download"));
								}else if(op.productType == 2){ 
									Response.Write(lang.getTranslated("backend.prodotti.detail.table.label.type_ads"));
								}%></td>	
							</tr>
						<%
						counter++;
						}  
					}%>	
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table6" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.spese_spediz_order")%></th>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.payment_commission")%></th>
				</tr>
				<tr>
				<td style="border:1px solid #C9C9C9;"><%=orderFees%></td>
				<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=paymentCommissions.ToString("#,###0.00")%></td>
				</tr>
				</table>

				<table border="0" cellpadding="5" cellspacing="0" id="invoice-table7" style="width:800px;text-align:left;vertical-align:top;border:1px solid #C9C9C9;">
				<tr>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.totale_prod")%></th>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.header.totale_tax_prod")%></th>
				<th style="border:1px solid #C9C9C9;"><%=lang.getTranslated("backend.ordini.view.table.label.totale_order")%></th>
				</tr>
				<tr>
				<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=taxableAmount.ToString("#,###0.00")%></td>
				<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=taxAmount.ToString("#,###0.00")%></td>
				<td style="border:1px solid #C9C9C9;">&euro;&nbsp;<%=orderAmount.ToString("#,###0.00")%></td>
				</tr>
				</table>
				<br/>
				<input type="button" id="create_invoice" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.invoice.label.create_invoice")%>" />
				<%
				string view_button = "";
				if(!hasInvoicePdf){
					view_button = "display:none;";
				}%>
				<input type="button" id="view_invoice" class="buttonForm" style="margin-right:10px;<%=view_button%>" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.invoice.label.view_invoice")%>" />
				<img style="display:none" id="loading_billing_buttons" src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">
				<br/><br/>
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/billings/billinglist.aspx?cssClass=LB';" />
				<br/><br/>
				
				<script>
				$("#view_invoice").on('click', function () {
					viewBillingfile(<%=order.id%>,<%=billing.id%>);
				});	
				
				$("#create_invoice").on('click', function () {
					var invoiceLogoId = "";
					var invoiceLogoType = "";
					
					<%if(!String.IsNullOrEmpty(companyLogo)){%>
					invoiceLogoId = "invoice-logo";
					var invoiceLogoSrc = $('#invoice-logo').attr('src');
					invoiceLogoType = getExtension(invoiceLogoSrc);
					<%}%>
				
					generateBillingImage(invoiceLogoId,invoiceLogoType,<%=order.id%>,<%=billing.id%>);
				});
				</script>
				
			<%}%>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>		