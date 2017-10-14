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
<script type="text/javascript" src="/common/js/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.3/jspdf.min.js"></script>
<script type="text/javascript" src="/common/js/jspdf.plugin.autotable.min.js"></script>

<script>
function generateBillingImage(imgData,orderId,billingId){
	var query_string = "id_order="+orderId+"&id_billing="+billingId+"&img_data="+encodeURIComponent(imgData);	
	//alert(query_string);

	//$("#show_img").append(query_string);
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "/backoffice/billings/ajaxbillingimagecreate.aspx",
		data: query_string,
		success: function(response) {
			alert(response);
			//$('#billing_show').empty();
			//$('#billing_show').append('<a href="/backoffice/billings/billingview.aspx?id='+response+'&cssClass=LB"><%=lang.getTranslated("backend.ordini.view.table.label.view_billing")%></a>');
		},
		error: function(response) {
			//alert(response.responseText);	
			alert("<%=lang.getTranslated("backend.billing.lista.js.alert.error_generate_pdf")%>");
		}
	});	
}

function viewBillingfile(orderId,billingId){
	var pdfPath = "/public/upload/files/billings/invoice_"+billingId+"_"+orderId+".pdf"; 
	window.open(pdfPath, '_blank');
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
				<div id="invoice-canvas" style="width:8.27in;">
				<table border="0" cellpadding="0" cellspacing="0" class="invoice-table" id="invoice-table">
				<tr>
				<td style="width:40%;" id="shippedFrom">
				<%if(!String.IsNullOrEmpty(companyLogo)){%>
				<img src="<%=companyLogo%>" border="0" align="top" style="margin-bottom:15px;display:block;"/>
				<%}%>
				<strong style="margin-bottom:20px;"><%=billing.name%></strong><br/>
				<%=billing.address%><br/>
				<%=billing.zipCode+"&nbsp;-&nbsp;"+billing.city+"&nbsp;&nbsp;"+lang.getTranslated("portal.commons.select.option.country."+billing.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+billing.stateRegion)%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_cfiscvat")%>:&nbsp;<%=billing.cfiscvat%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_phone")%>:&nbsp;<%=billing.phone%><br/>
				<%=lang.getTranslated("backend.ordini.view.table.label.billing_data_fax")%>:&nbsp;<%=billing.fax%><br/>
				<%=billing.description%>		
				</td>
				<td style="width:60%;" id="shippedTo">
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
				<br/><br/>
				<table border="0" cellpadding="0" cellspacing="0" class="invoice-table">
				<tr>
				<th style="width:40%"><%=lang.getTranslated("backend.ordini.view.table.label.doc_type")%></th>
				<th style="width:30%"><%=lang.getTranslated("backend.ordini.view.table.label.dta_doc")%></th>
				<th style="width:30%"><%=lang.getTranslated("backend.ordini.view.table.label.num_doc")%></th>
				</tr>
				<tr>
				<td><%if(billing.idRegisteredBilling>0){Response.Write(lang.getTranslated("backend.ordini.view.table.label.doc_type_registered_bill"));}else{Response.Write(lang.getTranslated("backend.ordini.view.table.label.doc_type_pro_bill"));}%></td>
				<td><%if(billing.idRegisteredBilling>0){Response.Write(billing.registeredDate.ToString("dd/MM/yyyy HH:mm"));}else{Response.Write(billing.insertDate.ToString("dd/MM/yyyy HH:mm"));}%></td>
				<td><%if(billing.idRegisteredBilling>0){Response.Write(billing.idRegisteredBilling+"/"+billing.registeredDate.ToString("yyyy"));}else{Response.Write("&nbsp;");}%></td>
				</tr>
				<tr>
				<td colspan="3">&nbsp;</td>
				</tr>				
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.id_ordine")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.dta_insert_order")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.stato_order")%></th>
				</tr>
				<tr>
				<td><%=order.id%></td>
				<td><%=order.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
				<td>
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
				<tr>
				<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.guid_ordine")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.pagam_order_done")%></th>
				</tr>
				<tr>
				<td><%=order.guid%></td>
				<td><%=paymentType%></td>
				<td><%=pdone%></td>
				</tr>
				<tr>
				<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
				<td colspan="3">
					<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
					<tr>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
					<th class="upper"><%=lang.getTranslated("backend.ordini.view.table.header.taxable_amount")%></th>
					<th class="upper"><%=lang.getTranslated("backend.ordini.view.table.header.tax_amount")%></th>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.qta_prod")%></th>	
					<th><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>	
					<th><%=lang.getTranslated("backend.ordini.view.table.header.prod_type")%></th>			
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
								<td><%=productrep.getMainFieldTranslationCached(op.idProduct, 1 , lang.currentLangCode, true,  op.productName, true).value+adsRefTitle%></td>
								<td>&euro;&nbsp;<%=op.taxable.ToString("#,###0.00")%>
									<ul style=padding-left:10px;padding-top:5px;margin:0px;>
									<%=opmargin+opdiscPerc+orderProdRules%>
									</ul>
								</td>
								<td>&euro;&nbsp;<%=op.supplement.ToString("#,###0.00")+suppdesc%></td>
								<td><%=op.productQuantity%></td>	
								<td><%=boproductCalendars+productFields%></td>	
								<td>
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
					</table><br/>
				</td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.spese_spediz_order")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.payment_commission")%></th>
				<th>&nbsp;</th>
				</tr>
				<tr>
				<td><%=orderFees%></td>
				<td >&euro;&nbsp;<%=paymentCommissions.ToString("#,###0.00")%></td>
				<td>&nbsp;</td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.header.totale_prod")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.header.totale_tax_prod")%></th>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.totale_order")%></th>
				</tr>
				<tr>
				<td>&euro;&nbsp;<%=taxableAmount.ToString("#,###0.00")%></td>
				<td>&euro;&nbsp;<%=taxAmount.ToString("#,###0.00")%></td>
				<td>&euro;&nbsp;<%=orderAmount.ToString("#,###0.00")%></td>
				</tr>
				</table>
				</div>
				<br/>
				<input type="button" id="create_invoice" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.invoice.label.create_invoice")%>" />
				<%if(hasInvoicePdf){%>
				<input type="button" id="view_invoice" class="buttonForm" style="margin-right:10px;" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.invoice.label.view_invoice")%>" />							
				<%}%>
				<br/><br/>
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/billings/billinglist.aspx?cssClass=LB';" />
				<br/><br/>
				
				<div id="show_img"></div>
				<!--<a id="btn-Convert-Html2Image" href="#">Download</a>-->
				
				<script>
				<%if(hasInvoicePdf){%>
				$("#view_invoice").on('click', function () {
					viewBillingfile(<%=order.id%>,<%=billing.id%>);
				});	
				<%}%>
				
				var invoice_element = $("#invoice-canvas"); // global variable		
				
				$("#create_invoice").on('click', function () {
					
					var doc = new jsPDF('p', 'in', 'a4');
					
					/*
					var elementHandler = {
					  '#ignorePDF': function (element, renderer) {
						return true;
					  }
					};
					//var source = window.document.getElementsByTagName("body")[0];
					var source = $('#invoice-canvas').html();
					doc.fromHTML(
					  source,
					  0.5,
					  0.5,
					  {
						'width': 180
						,'elementHandlers': elementHandler
					  });	
					*/
					
					/*
					var columns = [
						{title: "", dataKey: "shippedFrom"},
						{title: "", dataKey: "shippedTo"}
					];
					var rows = [
						{"shippedFrom": $('#shippedFrom').html(), "shippedTo": $('#shippedTo').html()}
					];					
										
					doc.autoTable(columns, rows);					
					*/  				

					
					var res = doc.autoTableHtmlToJson(document.getElementById("invoice-table"));
					doc.autoTable(res.columns, res.data, {margin: {top: 80}});					
					
					var result = doc.output("datauristring");
					result = result.replace(/^data:application\/pdf;base64,/, "");				
					
					generateBillingImage(result,<%=order.id%>,<%=billing.id%>);
				
				
				
				
					/*
					window.scrollTo(0,0);
					
					html2canvas(invoice_element, {
					background: "#fff",
					onrendered: function (canvas) {
						var imgageData = canvas.toDataURL("image/png");
						var newData = imgageData.replace(/^data:image\/png;base64,/, "");
						
						//generateBillingImage(newData,<%=order.id%>,<%=billing.id%>);	
						
						//$("#show_img").append(newData);
						
						
						$("<img/>", {
						  id: "image",
						  src: imgageData,
						  width: '100%',
						  height: '100%'
						}).appendTo($("#show_img").empty());		
											
					}
					}); 
					*/
					
					
					/*
					var scaleBy = 2;
					//var w = invoice_element.width();
					//var h = invoice_element.height();
					
					var w = window.innerWidth;
					var h = window.innerHeight;
					
					var div = invoice_element;
					var canvas = document.createElement('canvas');
					canvas.width = w * scaleBy;
					canvas.height = h * scaleBy;
					canvas.style.width = w + 'px';
					canvas.style.height = h + 'px';
					var context = canvas.getContext('2d');
					context.scale(scaleBy, scaleBy);
					alert("invoice_element.width(): "+w+"\ninvoice_element.height(): "+h+"\ncanvas.width: "+canvas.width+"\canvas.height: "+canvas.height+"\ncanvas.style.width: "+canvas.style.width+"\ncanvas.style.height: "+canvas.style.height);
				
					window.scrollTo(0,0);
					
					html2canvas(div, {
						canvas:canvas,
						onrendered: function (canvas) {
							var imgageData = canvas.toDataURL("image/png");
							var newData = imgageData.replace(/^data:image\/png;base64,/, "");
							
							//generateBillingImage(newData,<%=order.id%>,<%=billing.id%>);	
							
							//$("#show_img").append(newData);
							
							
							$("<img/>", {
							  id: "image",
							  src: imgageData,
							  width: '100%',
							  height: '100%'
							}).appendTo($("#show_img").empty());	
						}
					});	
					*/
				});	
				
				/*
				$("#btn-Convert-Html2Image").on('click', function () {
					html2canvas(invoice_element, {
					onrendered: function (canvas) {
						var imgageData = canvas.toDataURL("image/png");
						var newData = imgageData.replace(/^data:image\/png/, "data:application/octet-stream");
						$("#btn-Convert-Html2Image").attr("download", "your_pic_name.png").attr("href", newData);						
					}
					});  
				});
				*/
				</script>
				
			<%}%>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>		