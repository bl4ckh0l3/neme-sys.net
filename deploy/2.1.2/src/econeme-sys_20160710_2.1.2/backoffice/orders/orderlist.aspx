<%@ Page Language="C#" AutoEventWireup="true" CodeFile="orderlist.aspx.cs" Inherits="_OrderList" Debug="false" ValidateRequest="false"%>
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
<script type="text/javascript" src="/common/js/highcharts.min.js"></script>
<script language="JavaScript">
function viewOrder(idOrder){
	location.href='/backoffice/orders/orderview.aspx?cssClass=LO&id='+idOrder;
}

function editOrder(idOrder){
	location.href='/backoffice/orders/insertorder.aspx?cssClass=LO&id='+idOrder;
}

/*
function deleteOrder(id_objref, row, refreshrows, status){
	if(status == 4 || status == 3){
		if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.confirm_del_order_status_sca_ese")%>")){
			ajaxDeleteItem(id_objref,"FOrder|IOrderRepository",row, refreshrows);
		}
	}else{		
		if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.confirm_del_order_change_qta_disp")%>")){
			ajaxDeleteItem(id_objref,"FOrder|IOrderRepository",row, refreshrows);
		}
	}
}
*/

function deleteOrder(idOrder){
	var change_qty = 0;
	
	if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.del_order_change_qta_disp_confirmation")%>")){
		change_qty = 1;
	}
	if(confirm("<%=lang.getTranslated("backend.ordini.detail.js.alert.confirm_del_order")%>")){
		location.href='/backoffice/orders/deleteorder.aspx?cssClass=LO&id='+idOrder+"&changeqty="+change_qty;
	}
}

function changeRowListData(listCounter, objtype, field){
	if(objtype.indexOf("FOrder")>=0){
		var status = $("#status_"+listCounter).val();
		var render = "";

		if(status==3 || status==4){
			render +=('&nbsp;');
		}else{
			var orderid = $('#order_id_'+listCounter).text();
			render +='<a href="';
			render+="javascript:editOrder("+orderid+");";
			render+='">';
			render +=('<img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.ordini.lista.table.alt.modify_order")%>" alt="<%=lang.getTranslated("backend.ordini.lista.table.alt.modify_order")%>" hspace="2" vspace="0" border="0">');
			render +=('</a>');
		}
		
		$("#edit_order_"+listCounter).empty();
		$("#edit_order_"+listCounter).append(render);
	}
}

/**
 * DHTML date validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
 */
// Declaring valid date character, minimum year and maximum year
var dtCh= "/";
var minYear=1900;
var maxYear=2100;

function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
   } 
   return this
}

function isDate(dtStr){
	var daysInMonth = DaysArray(12)
	var pos1=dtStr.indexOf(dtCh)
	var pos2=dtStr.indexOf(dtCh,pos1+1)
	var strDay=dtStr.substring(0,pos1)
	var strMonth=dtStr.substring(pos1+1,pos2)
	var strYear=dtStr.substring(pos2+1)
	strYr=strYear
	if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
	if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
	}
	month=parseInt(strMonth)
	day=parseInt(strDay)
	year=parseInt(strYr)
	if (pos1==-1 || pos2==-1){
		alert("The date format should be : dd/mm/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		alert("Please enter a valid date")
		return false
	}
return true
}

function sendSearchOrder(){
	var dtf=document.form_search.order_date_from;
	if(dtf.value != ""){
		if (isDate(dtf.value)==false){
			dtf.focus();
			return;
		}
		
	}
	var dtt=document.form_search.order_date_to;
	if(dtt.value != ""){
		if (isDate(dtt.value)==false){
			dtt.focus();
			return;
		}
		
	}
    document.form_search.submit();
}

$(function() {
	$('#dta_from').datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true
	});
	$('#ui-datepicker-div').hide();	
});

$(function() {
	$('#dta_to').datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true
	});
	$('#ui-datepicker-div').hide();	
});
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
			  <form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" accept-charset="UTF-8">
			  <input type="hidden" value="<%=cssClass%>" name="cssClass">
			  <input type="hidden" value="1" name="page">
		       <tr> 
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.cliente")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.data_insert")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.data_insert_to")%></th>
				  </tr>
				<tr>
				<td>
				  <select name="order_user" class="formFieldTXT">
				  <option value=""></option>
				  <%if(bolFoundUser){
					  foreach(User y in users){%>		  
						<option value="<%=y.id%>" <%if(search_user == y.id){Response.Write("selected");}%>><%=y.username%></option>
					  <%}
				  }%>
				  </select>	
				  </td>
					<td>
					<input type="text" value="<%=search_datefrom%>" name="order_date_from" id="dta_from" class="formFieldTXT">
					</td>
				  <td>			  
				  <input type="text" value="<%=search_dateto%>" name="order_date_to" id="dta_to" class="formFieldTXT">	  
				  </td> 
				  </tr>
				  <tr> 
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.type_pagam")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.pagam_done")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.order_by")%></th>
				  </tr>	
				  <tr>
				  <td>			  
				  <select name="order_payment" class="formFieldTXT">		
					<option value=""></option>		
				  <%if(bolFoundFees){			  
					  foreach(Payment k in payments){
						string pdesc = k.description;
						if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+pdesc))){
							pdesc = lang.getTranslated("backend.payment.description.label."+pdesc);
						}%>
						<option value="<%=k.id%>" <%if(search_paytype == k.id){Response.Write("selected");}%>><%=pdesc%></option>					
					  <%}
				  }%> 
				  </select>
				  </td>
				  <td>			  
				  <select name="payment_done" class="formFieldChangeStato">
					<option value=""></option>
					<option value="false" <%if("false".Equals(search_paydone)){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
					<option value="true" <%if("true".Equals(search_paydone)){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
				  </select>		  
				  </td> 
				<td>			  
				  <select name="order_by" class="formFieldSelect">
					  <option value=""></option>
					  <option value="3" <%if(search_orderby == 3){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_asc")%></option>
					  <option value="4" <%if(search_orderby == 4){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_desc")%></option>
					  <option value="5" <%if(search_orderby == 5){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_asc")%></option>
					  <option value="6" <%if(search_orderby == 6){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_desc")%></option>
					  <option value="7" <%if(search_orderby == 7){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_amount_ordine_asc")%></option>
					  <option value="8" <%if(search_orderby == 8){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_amount_ordine_desc")%></option>
					  <option value="11" <%if(search_orderby == 11){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_asc")%></option>
					  <option value="12" <%if(search_orderby == 12){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_desc")%></option>
				  </select>					                                                                                                                                                                     
				  </td>
			  </tr>
				<tr> 
					<th colspan="2"><%=lang.getTranslated("backend.ordini.lista.table.search.header.order_guid")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.stato_ord")%></th>
				  </tr>	
				<tr><td colspan="2">
					<input type="text" value="<%=search_guid%>" name="order_guid" class="formFieldTXTBig">
					</td>
					  <td>			  
					  <select name="order_status" class="formFieldChangeStato">
						<option value=""></option>
						<option value="1" <%if("1".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_inserting")%></option>
						<option value="2" <%if("2".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_executing")%></option>
						<option value="3" <%if("3".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_executed")%></option>
						<option value="4" <%if("4".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_sca")%></option>
					  </select> 
					  </td> 
				</tr>
			  <tr><td colspan="3">			  
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.lista.button.search.label")%>" onclick="javascript:sendSearchOrder();" />&nbsp;
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.lista.button.label.download_excel")%>" onclick="javascript:openWinExcel('/backoffice/report/create-order-catalog.aspx?<%=urlParamOrderFilter.ToString()%>','crea_excel',400,400,100,100);" />
				<br/><br/>
				</td></tr>	    
			  </form>
		 	</table>			
			
			
			<%if(showChart){%>
				<table border="0" class="chart" align="top" cellpadding="0" cellspacing="0">
				<tr>
				<td valign="middle" align="right">
					<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_change_chart">
					<input type="hidden" value="<%=search_orderby%>" name="order_by">
					<input type="hidden" value="<%=itemsXpage%>" name="items">			
					<input type="hidden" value="<%=numPage%>" name="page">	
					<input type="hidden" value="<%=cssClass%>" name="cssClass">		
					  <select name="chart_filter" class="formFieldChangeStato" onChange="document.form_change_chart.submit();">
						<option value="m" <%if ("m".Equals(chart_filter)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.chart.month")%></option>
						<option value="y" <%if ("y".Equals(chart_filter) || String.IsNullOrEmpty(chart_filter)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.chart.year")%></option>
					  </select>			
					</form>
				</td>
				<td>
					<script type="text/javascript">
					$(function () {
						var chart;
						$(document).ready(function() {
						chart = new Highcharts.Chart({
							chart: {
							renderTo: 'chartbox',
							type: 'line',
							marginRight: 130,
							marginBottom: 25,
							width: 800,
							height: 200					
							},
							title: {
							text: '<%=lang.getTranslated("backend.ordini.lista.table.chart.sales_rep")%><%if ("m".Equals(chart_filter)){Response.Write(" "+lang.getTranslated("backend.ordini.lista.table.chart.month"));}else{Response.Write(" "+lang.getTranslated("backend.ordini.lista.table.chart.year"));}%><%=" ("+chartReference+")"%>',
							x: -20 //center
							},
							subtitle: {
							text: '(<%=lang.getTranslated("backend.ordini.lista.table.chart.sales_rep_sub")+" "+totalOrderc%>)',
							x: -20 //center
							},
							xAxis: {
							categories: [
							<%
							string categories = "";
							foreach(int q in dictChart.Keys){
								if("m".Equals(chart_filter)){
									categories+= "'"+ q.ToString() +"',";							
								}else{
									categories+= "'"+ dictMonths[q] +"',";						
								}
							}					
							if(categories.LastIndexOf(',')>0){
								categories = categories.Substring(0,categories.LastIndexOf(','));
							}			
							Response.Write(categories);
							%>					
							]
							},
							yAxis: {
							title: {
								text: ''
							},
							plotLines: [{
								value: 0,
								width: 1,
								color: '#808080'
							}],
							min: 0,
							tickInterval: 1
							},
							tooltip: {
							formatter: function() {
								return '<b>'+ this.series.name +'</b><br/>'+this.x +': '+ this.y;
							}
							},
							legend: {
							layout: 'vertical',
							align: 'right',
							verticalAlign: 'top',
							x: -10,
							y: 100,
							borderWidth: 0
							},
							series: [{
							name: '<%=lang.getTranslated("backend.ordini.lista.table.chart.orders_label")%>',
							data: [
							<%
							string series = "";
							foreach(int q in dictChart.Keys){
								series+= dictChart[q].ToString() +",";
							}					
							if(series.LastIndexOf(',')>0){
								series = series.Substring(0,series.LastIndexOf(','));
							}			
							Response.Write(series);
							%>
							]
							}]
						});
						});
						
					});
					</script>
					<div id="chartbox" style="width: 700px; height: 230px; margin: 0 auto"></div>
				</td>
				</tr>
				</table>
			<%}%>
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
				<th colspan="10" align="left">
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
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.id_ordine")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.cliente")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.data_insert")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.type_pagam")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.pagam_done")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.totale_order")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.stato_ord")%></th>
			    </tr>
				<%
				int counter = 0;				
				if(bolFoundLista){
					for(counter = fromOrder; counter<= toOrder;counter++){
							FOrder k = orders[counter];
							bool hasExtURL = false;%>	
							<tr id="tr_delete_list_<%=counter%>" class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:viewOrder(<%=k.id%>);"><img src="/backoffice/img/zoom.png" alt="<%=lang.getTranslated("backend.ordini.lista.table.alt.view_order")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25" id="edit_order_<%=counter%>"><%if(k.status!=3 && k.status!=4){%><a href="javascript:editOrder(<%=k.id%>);"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.ordini.lista.table.alt.modify_order")%>" hspace="2" vspace="0" border="0"></a><%}else{Response.Write("&nbsp;");}%></td>
							<td align="center" width="25"><a href="javascript:deleteOrder(<%=k.id%>,'tr_delete_list_<%=counter%>','tr_delete_list_',$('#status_<%=counter%>').val());"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.ordini.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>
							<td id="order_id_<%=counter%>"><%=k.id%></td>
							<td><%=usrrep.getById(k.userId).username%></td>
							<td><%=k.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
							<td><%
							Payment p = payrep.getByIdCached(k.paymentId, true);
							if(p != null){
								hasExtURL = p.hasExternalUrl;
								string paydesc = p.description;
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+paydesc))){
									paydesc = lang.getTranslated("backend.payment.description.label."+paydesc);
								}							
								Response.Write(paydesc);
							}
							%></td>
							<td>
							<%
							if(k.paymentDone){
								bool payNotified = false;
								
								if(paytransrep.hasPaymentTransactionNotified(k.id)){
									payNotified = true;
								}
								
								if(payNotified || !hasExtURL){%>
									&nbsp;&nbsp;<img src="/backoffice/img/sema_no.png" title="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_paied_notified")%>" alt="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_paied_notified")%>" hspace="2" vspace="0" border="0" align="absmiddle">
								<%}else{%>
									&nbsp;&nbsp;<img src="/backoffice/img/sema_adup.png" title="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_paied_no_notified")%>" alt="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_paied_no_notified")%>" hspace="2" vspace="0" border="0" align="absmiddle">
								<%}							
								Response.Write(lang.getTranslated("backend.commons.yes"));							
							}else{%>
								&nbsp;&nbsp;<img src="/backoffice/img/sema_al.png" title="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_to_pay")%>" alt="<%=lang.getTranslated("backend.ordini.lista.table.alt.order_to_pay")%>" hspace="2" vspace="0" border="0" align="absmiddle">
								<%Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</td>
							<td>&euro;&nbsp;<%=k.amount.ToString("#,###0.00")%></td>
							<td width="150">
							<div class="ajax" id="view_status_<%=counter%>" onmouseover="javascript:showHide('view_status_<%=counter%>','edit_status_<%=counter%>','status_<%=counter%>',500, true);">
							<%
							string labelStatus = "";
							if (k.status==1) {
								labelStatus = orderStatus[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
									labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
								}
								Response.Write(labelStatus);
							}else if(k.status==2){ 
								labelStatus = orderStatus[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
									labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
								}
								Response.Write(labelStatus);
							}else if(k.status==3){ 
								labelStatus = orderStatus[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
									labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
								}
								Response.Write(labelStatus);
							}else if(k.status==4){ 
								labelStatus = orderStatus[k.status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+labelStatus))){
									labelStatus = lang.getTranslated("backend.ordini.view.table.label."+labelStatus);
								}
								Response.Write(labelStatus);
							}
							%>
							</div>
							<div class="ajax" id="edit_status_<%=counter%>">
							<select name="status" class="formfieldAjaxSelect" id="status_<%=counter%>" onblur="javascript:updateField('edit_status_<%=counter%>','view_status_<%=counter%>','status_<%=counter%>','FOrder|IOrderRepository|int',<%=k.id%>,2,<%=counter%>);">
							<%string optLabelStatus = "";
							foreach(int status in orderStatus.Keys){
								optLabelStatus = orderStatus[status];
								if(!String.IsNullOrEmpty(lang.getTranslated("backend.ordini.view.table.label."+optLabelStatus))){
									optLabelStatus = lang.getTranslated("backend.ordini.view.table.label."+optLabelStatus);
								}
								%>
								<OPTION VALUE="<%=status%>" <%if (k.status==status) { Response.Write("selected");}%>><%=optLabelStatus%></OPTION>
							<%}%>
							</SELECT>	
							</div>
							<script>
							$("#edit_status_<%=counter%>").hide();
							</script>							
							</td>
							</tr>			
						<%
					}
				}%>	  

			<tr> 
				<th colspan="10" align="left">
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
			
			<form action="/backoffice/orders/insertorder.aspx" method="post" name="form_crea">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="-1" name="id">
				<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.lista.button.inserisci.label")%>" onclick="javascript:document.form_crea.submit();" />
			</form>		
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>