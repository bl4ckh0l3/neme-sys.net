<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertorder.aspx.cs" Inherits="_InsertOrder" Debug="false" ValidateRequest="false"%>
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
function chooseOrderUser(idOrder, userId){
	if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.confirm_choose_new_order_user")%>")){
		location.href='/backoffice/orders/insertorder.aspx?cssClass=LO&id='+idOrder+'&userid='+userId;
	}
}

function addItemToOrder(idProduct, counter){
	var fields = "";
	var quantity = $("#quantity_"+counter).val();

	if(isNaN(quantity)){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.isnan_value")%>");
		$("#quantity_"+counter).val('');
		return;
	}else if(quantity.length == 0 || quantity==0){
		alert("<%=lang.getTranslated("backend.ordini.detail.js.alert.select_qta_prod")%>");
		$("#quantity_"+counter).val('');
		return;
	}	
	
	// TODO: creare json con fields per prodotto selezionati
	
	
	document.add_new_item.productid.value=idProduct;
	document.add_new_item.productquantity.value=quantity;
	document.add_new_item.productfields.value=fields;
	document.add_new_item.submit();
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr>
					<th align="center" width="25">&nbsp;</th>
					<th width="200"><lang:getTranslated keyword="backend.utenti.lista.table.header.username" runat="server" /></th>
					<th width="200"><lang:getTranslated keyword="backend.utenti.lista.table.header.mail" runat="server" /></th>
					<th>&nbsp;</th>
				</tr>
			</table>
			<%if(user!= null){%>
				<table border="0" cellpadding="0" cellspacing="0" class="principal">	
				<tr class="table-list-on">
					<td align="center" width="25">&nbsp;</td>
					<td width="200"><%=user.username%></td>
					<td width="200"><%=user.email%></td>
					<td>&nbsp;</td>
				</tr>	
				</table>			
			<%}else{%>
				<div class="order-user-select">
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<%int selUserCounter = 0;
				foreach(User u in users){%>
					<tr class="<%if(selUserCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
						<td align="center" width="25"><input type="radio" onclick="javascript:chooseOrderUser(<%=orderid%>,<%=u.id%>);" value="<%=u.id%>" name="order_user"></td>
						<td width="200"><%=u.username%></td>
						<td width="200"><%=u.email%></td>
						<td>&nbsp;</td>
					</tr>
					<%selUserCounter++;
				}%>
				</table>
				</div>
			<%}%>
			
			
			<%if(orderid==-1 && user != null){%>
				<div style="padding-top:30px;padding-bottom:20px;float:top;min-height:40px;border: 1px solid rgb(201, 201, 201);">		
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" accept-charset="UTF-8">
						<input type="hidden" value="<%=orderid%>" name="id">
						<input type="hidden" value="<%=orderUserId%>" name="userid">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">
						<div style="float:left;padding-right:10px;padding-top:15px;">
						<input type="submit" value="<%=lang.getTranslated("backend.product.lista.label.search")%>" class="buttonForm" hspace="4">
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.title_filter")%></span><br>
						<input type="text" name="titlef" value="<%=titlef%>" class="formFieldTXT">	
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.keyword_filter")%></span><br>
						<input type="text" name="keywordf" value="<%=keywordf%>" class="formFieldTXT">	
						</div>
						<div style="float:left;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.type_filter")%></span><br>
						<select name="typef" class="formfieldSelect">
						<option value=""></option>
						<option value="0" <%if ("0".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_portable")%></option>
						<option value="1" <%if ("1".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_download")%></option>
						<option value="2" <%if ("2".Equals(typef)) { Response.Write("selected");}%>><%=lang.getTranslated("backend.product.detail.table.label.type_ads")%></option>
						</SELECT>
						</div>
						<div style="float:top;padding-right:10px;">
						<span class="labelForm"><%=lang.getTranslated("backend.product.lista.label.category_filter")%></span><br>
						<select name="categoryf" class="formfieldSelect">
						<option value=""></option>
						<%
						string catdesc;
						foreach (Category c in categories){
							if(CategoryService.checkUserCategory(login.userLogged, c)){
								catdesc = "-&nbsp;"+c.description;
								string[] level = c.hierarchy.Split('.');
								if(level != null){
									for(int l=1;l<level.Length;l++){
										catdesc = "&nbsp;&nbsp;&nbsp;"+catdesc;
									}
								}%>
								<OPTION VALUE="<%=c.id%>" <%if (c.id==categoryf) { Response.Write("selected");}%>><%=catdesc%></OPTION>
							<%}
						}%>
						</SELECT>
						</div>	
				</form>
				</div>
			
				<%if(products != null && products.Count>0){%>
					<table border="0" cellpadding="0" cellspacing="0" class="principal">
						<tr>
							<th align="center" width="25">&nbsp;</th>
							<th width="250"><%=lang.getTranslated("backend.ordini.detail.table.label.nome_prod")%></th>
							<th width="200"><%=lang.getTranslated("backend.ordini.detail.table.label.prezzo_prod")%></th>
							<th width="150"><%=lang.getTranslated("backend.ordini.detail.table.label.qta_prod")%></th>
							<th><%=lang.getTranslated("backend.ordini.detail.table.label.fields_prod")%></th>
						</tr>
					</table>
					<div class="order-product-select">
					<table border="0" cellpadding="0" cellspacing="0" class="principal">
					<%int selProdCounter = 0;
					foreach(Product p in products){%>
						<tr class="<%if(selProdCounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:addItemToOrder(<%=p.id%>,<%=selProdCounter%>);"><img src="/backoffice/img/add.png" title="<%=lang.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" alt="<%=lang.getTranslated("backend.ordini.detail.table.alt.add_prod_combination")%>" hspace="2" vspace="0" border="0" align="top"></a></td>
							<td width="250"><%=p.name%></td>
							<td width="200">&euro;&nbsp;<%=p.price.ToString("#,###0.00")%></td>
							<td width="150">
							<input type="text" name="quantity" id="quantity_<%=selProdCounter%>" value="" class="formFieldTXTQtaProd" onKeyPress="javascript:return isInteger(event);">
							<%
							if(p.quantity>-1){%>
								<br/><%=lang.getTranslated("backend.ordini.detail.table.label.product_disp")+"&nbsp;"+p.quantity%>
							<%}%></td>
							<td>&nbsp;</td>
						</tr>
						<%selProdCounter++;
					}%>
					</table>
					</div>					
				<%}
			}%>
			
			
			<%if(order!=null){%>
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
					
					shipInfo = shipaddr.name + " " + shipaddr.surname + " ("+userLabelIsCompanyClient+") - " + shipaddr.cfiscvat + " - " +oshipaddr.address +" - "+oshipaddr.city+" ("+oshipaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+oshipaddr.stateRegion);
						
					Response.Write("<b>"+lang.getTranslated("backend.ordini.view.table.label.shipping_address")+":</b>&nbsp;"+shipInfo+"<br/>");	
				}	
				
				//****** MANAGE BILLS ADDRESS
				if(hasBillsAddress){
					string billsInfo = billsaddr.name + " " + billsaddr.surname + " - " + billsaddr.cfiscvat + " - " +obillsaddr.address +" - "+obillsaddr.city+" ("+obillsaddr.zipCode+") - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.country)+" - "+lang.getTranslated("portal.commons.select.option.country."+obillsaddr.stateRegion);
									
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
				<td><%=pdone%></td>
				<td class="separator">&nbsp;</td>
				<td><%=downNotified%></td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.list_transaction_order")%></th>
				</tr>
				<tr>
				<td colspan="5"><%=paymentTrans%>&nbsp;</td>
				</tr>
				<tr>
				<th colspan="5"><%=lang.getTranslated("backend.ordini.view.table.label.attached_prods")%></th>
				</tr>
				<tr>
				<td colspan="5">
					<table border="0" align="top" cellpadding="0" cellspacing="0" class="inner-table">							
					<tr>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.nome_prod")%></th>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.totale_prod")%></th>
					<th><%=lang.getTranslated("backend.ordini.view.table.header.totale_tax")%></th>
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
							suppdesc = "&nbsp;("+suppdesc+")";	
		
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
								foreach(OrderProductField opf in opfs){
									string flabel = lang.getTranslated("backend.prodotti.detail.table.label.field_description_"+opf.description+"_"+prod.keyword);
									if(String.IsNullOrEmpty(flabel)){
										flabel = opf.description;
									}
									
									if(opf.fieldType==8){
										productFields+=flabel+":&nbsp;<a target='_blank' href='"+builder.ToString()+"public/upload/files/orders/"+opf.idOrder+"/"+opf.value+"'>"+opf.value+"</a><br/>";
									}else{
										productFields+=flabel+":&nbsp;"+opf.value+"<br/>";
									}
								}
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
								<td><%=productFields%></td>	
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
			
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="add_new_item">
			<input type="hidden" value="<%=orderid%>" name="id">
			<input type="hidden" value="<%=orderUserId%>" name="userid">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="<%=titlef%>" name="titlef">		
			<input type="hidden" value="<%=keywordf%>" name="keywordf">		
			<input type="hidden" value="<%=typef%>" name="typef">		
			<input type="hidden" value="<%=categoryf%>" name="categoryf">	
			<input type="hidden" value="" name="productid">
			<input type="hidden" value="" name="productfields">
			<input type="hidden" value="" name="productquantity">
			</form>			
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>		