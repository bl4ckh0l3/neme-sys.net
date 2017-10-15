<%@ Page Language="C#" AutoEventWireup="true" CodeFile="billinglist.aspx.cs" Inherits="_BillingList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/backoffice/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script type="text/javascript" src="/common/js/html2canvas.min.js"></script>
<script language="JavaScript">
function viewBilling(idBilling){
	location.href='/backoffice/billings/billingview.aspx?cssClass=LB&id='+idBilling;
}

function sendBillingEmail(idBilling,orderId,counter){
	var query_string = "id_order="+orderId+"&id_billing="+idBilling;	
	//alert(query_string);

		$('#send_mail_'+counter).hide();
		$('#loading_send_mail_'+counter).show();	
	
	$.ajax({
		async: true,
		type: "POST",
		cache: false,
		url: "/backoffice/billings/ajaxpdfbillingexist.aspx",
		data: query_string,
		success: function(response) {
			location.href='/backoffice/billings/billinglist.aspx?cssClass=LB&operation=send&id_billing='+idBilling;
		},
		error: function(response) {
			var statusResp = response.status;
			
			$('#loading_send_mail_'+counter).hide();
			$('#send_mail_'+counter).show();
			
			//alert(statusResp);
			
			if(statusResp == 400){
				alert("<%=lang.getTranslated("backend.billing.lista.js.alert.error_send_mail")%>");
			}else if(statusResp == 404){
				alert("<%=lang.getTranslated("backend.billing.lista.js.alert.must_generate_pdf")%>");
			}
		}
	});	
}

function deleteBilling(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.billing.lista.js.alert.delete_billing")%>")){
		ajaxDeleteItem(id_objref,"Billing|IBillingRepository",row,refreshrows);
	}
}

function insertBillingData(){
	if(
		$("#bills_name").val()=="" || 
		$("#bills_surname").val()=="" || 
		$("#bills_cfiscvat").val()=="" || 
		$("#bills_address").val()=="" || 
		$("#bills_zip_code").val()=="" || 
		$("#bills_city").val()=="" || 
		$("#bills_country").val()=="" || 
		$("#bills_phone").val()==""
	){
		alert("<%=lang.getTranslated("backend.billing.lista.js.alert.insert_bills_address")%>");
		return;		
	}	

    document.form_billing_data.submit();
}

function registerBilling(idBilling){
	location.href='/backoffice/billings/billinglist.aspx?cssClass=LB&operation=register&id_billing='+idBilling;
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>	
			
			<table align="top" border="0" class="principal" cellpadding="0" cellspacing="0">	
				<tr> 
					<th><%=lang.getTranslated("backend.billing.lista.table.header.billing_data")%></th>
				</tr>
				<tr>
					<td>			
			
			  <form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_billing_data" accept-charset="UTF-8" enctype="multipart/form-data">
			  <input type="hidden" value="<%=cssClass%>" name="cssClass">
			  <input type="hidden" value="1" name="page">
			  <input type="hidden" value="insert" name="operation">

			  	<div style="margin-top:10px;">
					<div style="float:left;margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.name")%></strong><br>
					<input type="text" id="bills_name" name="bills_name" value="<%=billingData.name%>"></div>
					<div style="float:left;margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.cfiscvat")%></strong><br>
					<input type="text" id="bills_cfiscvat" name="bills_cfiscvat" value="<%=billingData.cfiscvat%>"></div>
					<div style="float:left;margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.phone")%></strong><br>
					<input type="text" id="bills_phone" name="bills_phone" value="<%=billingData.phone%>"></div>
					<div><strong><%=lang.getTranslated("backend.billing.lista.table.label.fax")%></strong><br>
					<input type="text" id="bills_fax" name="bills_fax" value="<%=billingData.fax%>"></div>
				</div>
				<div style="margin-top:10px;">
					<div style="float:left;margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.address")%></strong><br>
					<input type="text" id="bills_address" name="bills_address" value="<%=billingData.address%>"></div>
					<div style="float:left;margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.zip_code")%></strong><br>
					<input type="text" id="bills_zip_code" name="bills_zip_code" value="<%=billingData.zipCode%>"></div>
					<div style="margin-right:30px;"><strong><%=lang.getTranslated("backend.billing.lista.table.label.city")%></strong><br>
					<input type="text" id="bills_city" name="bills_city" value="<%=billingData.city%>"></div>
				</div>
				<div style="margin-top:10px;">
					<div style="float:left;padding-right:30px;">
						<strong><%=lang.getTranslated("backend.billing.lista.table.label.country")%></strong><br>
						<select id="bills_country" name="bills_country">
						<option value=""></option>
						<%foreach(Country x in countries){%>
						  <option value="<%=x.countryCode%>" <%if(x.countryCode.Equals(billingData.country)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.countryCode)%></option>     
						<%}%>
						</select> 
					</div>
					<div>
						<strong><%=lang.getTranslated("backend.billing.lista.table.label.state_region")%></strong><br>	 
						<select name="bills_state_region" id="bills_state_region">
						<option value=""></option>
						<%if(!String.IsNullOrEmpty(billingData.country)){
							foreach(Country x in stateRegions){%>
							  <option value="<%=x.stateRegionCode%>" <%if(x.stateRegionCode.Equals(billingData.stateRegion)){Response.Write("selected");}%>><%=lang.getTranslated("portal.commons.select.option.country."+x.stateRegionCode)%></option>     
							<%}
						}%>
						</select>	
					</div>
				</div>
				<div style="display:block;margin-top:10px;margin-bottom:20px;">
					<div style="float:left;margin-right:30px;">
						<div style="margin-right:30px;">
							<strong><%=lang.getTranslated("backend.billing.lista.table.label.ext_description")%></strong><br>
							<textarea id="bills_description" name="bills_description" class="formFieldTXTAREA"><%=billingData.description%></textarea>
						</div>				
					</div>
					<div>
						<strong><%=lang.getTranslated("backend.billing.lista.table.label.fileupload")%></strong><br>
						<input type="file" name="billing_image" />
						<%if(!String.IsNullOrEmpty(billingData.filePath)){%>
							<br/><input type="checkbox" style="margin-top:10px;" class="billing_image_checkbox" value="1" name="del_billingimage">&nbsp;<%=lang.getTranslated("backend.billing.lista.label.del_billingimage")%>
							<br/><img class="billing_image" align="top"  src="<%="/public/upload/files/billing_data/"+billingData.filePath%>" />
						<%}%>				
					</div>			  
				</div>
				<div style="padding-top:5px;margin-bottom:20px;float:top;clear:both;">
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.billing.lista.button.billing_data.insert")%>" onclick="javascript:insertBillingData();" />
				</div>    
			  </form>
				
				<script>
				$('#bills_country').change(function() {
					var type_val_ch = $('#bills_country').val();
					var query_string = "field_val="+encodeURIComponent(type_val_ch);

					$.ajax({
						async: true,
						type: "GET",
						cache: false,
						url: "/backoffice/billings/ajaxstateregionupdate.aspx",
						data: query_string,
						success: function(response) {
							//alert("response: "+response);
							$("select#bills_state_region").empty();
							$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
							$("select#bills_state_region").append(response);
						},
						error: function() {
							$("select#bills_state_region").empty();
							$("select#bills_state_region").append($("<option></option>").attr("value","").text(""));
						}
					});		
				});	
				</script>
			  </td>
			  </tr>
			</table>	
		
			<div id="mailsent" align="center" style="color:#FF0000; display:none;"><%=lang.getTranslated("backend.billing.lista.table.mail_sent")%></div>
			<%if(mailSent){%>
			<script>
			$("#mailsent").fadeIn(1500,"linear");
			$("#mailsent").fadeOut(1500,"linear");	
			</script>
			<%}%>
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
				<th colspan="8" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
				</div>
				</th>
		      	</tr>
			    <tr> 
				<th colspan="3">&nbsp;</td>
				<th><%=lang.getTranslated("backend.billing.lista.table.header.id_billing")%></th>
				<th><%=lang.getTranslated("backend.billing.lista.table.header.data_insert")%></th>
				<th><%=lang.getTranslated("backend.billing.lista.table.header.id_order")%></th>
				<th><%=lang.getTranslated("backend.billing.lista.table.header.order_date")%></th>
				<th><%=lang.getTranslated("backend.billing.lista.table.header.totale_order")%></th>
			    </tr>
				<%
				int counter = 0;				
				if(bolFoundLista){
					for(counter = fromBilling; counter<= toBilling;counter++){
							Billing k = billings[counter];%>	
							<tr id="tr_delete_list_<%=counter%>" class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:viewBilling(<%=k.id%>);"><img src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.billing.lista.table.alt.view_billing")%>" title="<%=lang.getTranslated("backend.billing.lista.table.alt.view_billing")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25" id="send_billing_<%=counter%>">
							<!--<a href="javascript:sendBillingEmail(<%=k.id%>, <%=k.idParentOrder%>);"><img src="/backoffice/img/email_go.png" title="<%=lang.getTranslated("backend.billing.lista.table.alt.send_billing")%>" hspace="2" vspace="0" border="0"></a>-->
							<img style="cursor:pointer;" id="send_mail_<%=counter%>" src="/backoffice/img/email_go.png" title="<%=lang.getTranslated("backend.billing.lista.table.alt.send_billing")%>" alt="<%=lang.getTranslated("backend.billing.lista.table.alt.send_billing")%>" hspace="2" vspace="0" border="0">
							<img style="display:none" id="loading_send_mail_<%=counter%>" src="/common/img/loading_icon3.gif" alt="" width="16" height="16" hspace="2" vspace="0" border="0">	
							</td>
							<td align="center" width="25"><%if(k.idRegisteredBilling==0){%><a href="javascript:deleteBilling(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.billing.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a><%}%></td>
							<td id="billing_id_<%=counter%>"><%if(k.idRegisteredBilling==0){%><div class="register-billing"><a href="javascript:registerBilling(<%=k.id%>);"><%=lang.getTranslated("backend.billing.detail.button.register.label")%></a></div><%}else{Response.Write(k.idRegisteredBilling+"/"+k.registeredDate.ToString("yyyy"));}%></td>
							<td><%if(k.idRegisteredBilling>0){Response.Write(k.registeredDate.ToString("dd/MM/yyyy HH:mm"));}else{Response.Write(k.insertDate.ToString("dd/MM/yyyy HH:mm"));}%></td>
							<td><%=k.idParentOrder%></td>
							<td><%=k.orderDate.ToString("dd/MM/yyyy HH:mm")%></td>
							<td>&euro;&nbsp;<%=k.orderAmount.ToString("#,###0.00")%></td>
							</tr>
							<script>
							$('#send_mail_<%=counter%>').click(function(){sendBillingEmail(<%=k.id%>, <%=k.idParentOrder%>, <%=counter%>);});
							</script>					
						<%
					}
				}%>	  

			<tr> 
				<th colspan="8" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
				</div>
				</th>
		      	</tr>
			</table>
			<br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>