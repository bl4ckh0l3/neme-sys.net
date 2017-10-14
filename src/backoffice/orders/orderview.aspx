<%@ Page Language="C#" AutoEventWireup="true" CodeFile="orderview.aspx.cs" Inherits="_OrderView" Debug="false" ValidateRequest="false"%>
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
<script>
function downloadStatus(orderid, productid){
	var query_string = "id_element="+productid+"&id_order="+orderid;	
	//alert(query_string);

	$('#downloadContainer').empty();
	$('#downloadContainer').append('<div align="center" style="padding-top:150px;" id="loading-menu"><img src="/common/img/loading_icon.gif" hspace="0" vspace="0" border="0" align="center" alt="" style="vertical-align:middle;text-align:center;padding-top:0px;padding-bottom:0px;"></div>');	
	$('#downloadContainer').show();
	
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/orders/ajaxdownloadstatus.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#downloadContainer').empty();
			$('#downloadContainer').append('<div align="right"><span style="cursor:pointer;text-decoration:underline;" onclick="javascript:hideCommentDiv();">x</span></div>');
			$('#downloadContainer').append(response);
		},
		error: function(response) {
			//alert(response.responseText);	
			$('#downloadContainer').hide();
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function hideCommentDiv(){
	$('#downloadContainer').hide();
}

$(function() {
	$("#downloadContainer").draggable();
});

function enableExternalShipping(orderId, provider, feeId){
	var query_string = "cssClass=LO&provider="+provider+"&id_order="+orderId+"&id_fee="+feeId;	
	//alert(query_string);

	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/orders/ajaxorderextshipping.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#shipping_enabled').empty();
			$('#shipping_enabled').append('<img src="/backoffice/img/accept.png" hspace="3" vspace="0" border="0" align="absmiddle">');
		},
		error: function(response) {
			//alert(response.responseText);	
			alert("<%=lang.getTranslated("portal.commons.js.label.loading_error")%>");
		}
	});	
}

function generateBilling(orderId){
	var query_string = "cssClass=LB&id_order="+orderId;	
	//alert(query_string);

	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/billings/ajaxbillingcreate.aspx",
		data: query_string,
		success: function(response) {
			//alert(response);
			$('#billing_show').empty();
			$('#billing_show').append('<a href="/backoffice/billings/billingview.aspx?id='+response+'&cssClass=LB"><%=lang.getTranslated("backend.ordini.view.table.label.view_billing")%></a>');
		},
		error: function(response) {
			//alert(response.responseText);	
			alert("<%=lang.getTranslated("backend.ordini.view.js.alert.billing_not_created")%>");
		}
	});	
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<%if(order!=null){%>
				
				<div id="downloadWrapper" style="position:relative;">
					<div id="downloadContainer" style="z-index:10000;position:absolute;top:0px;top:200px;left:400px;width:500px;height:200px;border:1px solid #000;padding:5px;display:none; overflow:auto; background-color:#FFFFFF;"></div>
				</div>
				
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.id_ordine")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.dta_insert_order")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.stato_order")%></th>
				</tr>
				<tr>
				<td><%=order.id%></td>
				<td class="separator">&nbsp;</td>
				<td><%=order.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
				<td class="separator">&nbsp;</td>
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
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.guid_ordine")%></th>
				</tr>
				<tr>
				<td colspan="5"><%=order.guid%>&nbsp;</td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.order_notes")%></th>
				</tr>
				<tr>
				<td colspan="5"><%=order.notes%>&nbsp;</td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.order_client")%></th>
				</tr>
				<tr>
				<td colspan="5">
				<strong>ID:</strong>&nbsp;<%=user.username%>&nbsp;-&nbsp;<strong>mail:</strong>&nbsp;<%=user.email%><br/>
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
						Response.Write(label+":&nbsp;<b>"+value+"</b><br/><br/>");							
					}
				}
				
				//****** MANAGE SHIPPING ADDRESS
				if(hasShipAddress){
					string shipInfo = "";
					string userLabelIsCompanyClient = "";
					if(oshipaddr.isCompanyClient){
						userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_company");
					}else{
						userLabelIsCompanyClient = lang.getTranslated("frontend.utenti.detail.table.label.is_private");
					}								
					
					shipInfo = oshipaddr.name + " " + oshipaddr.surname + " ("+userLabelIsCompanyClient+") - " + oshipaddr.cfiscvat + " - " +oshipaddr.address +" - "+oshipaddr.city+" ("+oshipaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.stateRegion);
						
					Response.Write("<b>"+lang.getTranslated("backend.ordini.view.table.label.shipping_address")+":</b>&nbsp;"+shipInfo+"<br/>");	
				}	
				
				//****** MANAGE BILLS ADDRESS
				if(hasBillsAddress){
					string billsInfo = obillsaddr.name + " " + obillsaddr.surname + " - " + obillsaddr.cfiscvat + " - " +obillsaddr.address +" - "+obillsaddr.city+" ("+obillsaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.stateRegion);
									
					Response.Write("<b>"+lang.getTranslated("backend.ordini.view.table.label.bills_address")+":</b>&nbsp;"+billsInfo+"<br/>");					
				}%></td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.tipo_pagam_order")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.pagam_order_done")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.user_notified_x_download")%></th>
				</tr>
				<tr>
				<td><%=paymentType%></td>
				<td class="separator">&nbsp;</td>
				<td><%=pdone+billingShow%></td>
				<td class="separator">&nbsp;</td>
				<td><%=downNotified%></td>
				</tr>
				<tr>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.list_transaction_order")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.mail_sent")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.ads_enabled")%></th>					
				</tr>
				<tr>
				<td><%=paymentTrans%>&nbsp;</td>
				<td class="separator">&nbsp;</td>
				<td><%=mailSent%></td>
				<td class="separator">&nbsp;</td>
				<td><%=adsEnabled%></td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.attached_prods")%></th>
				</tr>
				<tr>
				<td colspan="5">
					<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
					<tr>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
					<th class="upper"><%=lang.getTranslated("backend.ordini.view.table.header.taxable_amount")%></th>
					<th class="upper"><%=lang.getTranslated("backend.ordini.view.table.header.tax_amount")%></th>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.qta_prod")%></th>	
					<th><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>	
					<th><%=lang.getTranslated("backend.ordini.view.table.header.prod_type")%></th>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.status_download")%></th>				
					</tr>
					<%		
					if(order.products != null && order.products.Count>0){
						int counter = 0;
						foreach(OrderProduct op in order.products.Values){
							Product prod = productrep.getByIdCached(op.idProduct, true);
							IList<OrderProductField> opfs = orderep.findItemFields(order.id, op.idProduct, op.productCounter);

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
						
							<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
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
								<td>
								<%if(op.productType == 1){%>
								<a href="javascript:downloadStatus(<%=order.id%>,<%=op.idProduct%>);" title="<%=lang.getTranslated("backend.ordini.view.table.alt.status_download")%>"><img src="/backoffice/img/zoom.png" hspace="0" vspace="0" border="0"></a>
								<%}%>
								&nbsp;</td>	
							</tr>
						<%
						counter++;
						}  
					}%>	
					</table><br/>
				</td>
				</tr>
				<tr>
				<th><span class="labelForm"><%=lang.getTranslated("backend.ordini.view.table.label.spese_spediz_order")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.payment_commission")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.ordini.view.table.label.business_rules")%></th>
				</tr>
				<tr>
				<td><%=orderFees%></td>
				<td class="separator">&nbsp;</td>
				<td >&euro;&nbsp;<%=paymentCommissions.ToString("#,###0.00")%></td>
				<td class="separator">&nbsp;</td>
				<td><%=orderRulesDesc%></td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.totale_order")%></th>
				</tr>
				<tr>
				<td colspan="5">&euro;&nbsp;<%=orderAmount.ToString("#,###0.00")%></td>
				</tr>
				</table><br/>
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/orders/orderlist.aspx?cssClass=LO';" />
				<br/><br/>
			<%}%>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>		