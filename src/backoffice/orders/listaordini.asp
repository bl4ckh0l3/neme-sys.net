<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script type="text/javascript" src="<%=Application("baseroot") & "/common/js/highcharts.js"%>"></script>
<script language = "Javascript">
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
	var dtf=document.form_search.dta_ins_search_from
	if(dtf.value != ""){
		if (isDate(dtf.value)==false){
			dtf.focus()
			return
		}
		
	}
	var dtt=document.form_search.dta_ins_search_to
	if(dtt.value != ""){
		if (isDate(dtt.value)==false){
			dtt.focus()
			return
		}
		
	}
    document.form_search.submit();
 }

function confirmDelete(id_order, status_order){
	document.form_cancella_order.id_order_to_delete.value = id_order;
	document.form_cancella_order.status_order_to_delete.value = status_order;
	if(status_order == 4 || status_order == 3){
		if(confirm("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.confirm_del_order_status_sca_ese")%>")){
			document.form_cancella_order.submit();
		}
	}else{		
		if(confirm("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.confirm_del_order_change_qta_disp")%>")){
			document.form_cancella_order.submit();
		}
	}
}

function confirmNotify(id_order){
	document.form_notify_payment.id_order.value = id_order;
		
	if(confirm("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.confirm_notify_order")%>")){
		document.form_notify_payment.submit();
	}
}

function editOrder(idOrder){
	location.href='<%=Application("baseroot") & "/editor/ordini/InserisciOrdine1.asp?cssClass=LO&id_ordine="%>'+idOrder+'&id_order_to_delete='+idOrder;
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LO"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
			<table align="top" border="0" class="principal" cellpadding="0" cellspacing="0">
			  <form action="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp"%>" method="post" name="form_search">
			  <input type="hidden" value="LO" name="cssClass">
			  <input type="hidden" value="1" name="page">
		              <tr> 
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.cliente")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.data_insert")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.data_insert_to")%></th>
				  </tr>
				<tr>
				<td>
				<input type="hidden" value="1" name="search_ordini">
				  <select name="id_utente_search" class="formFieldTXT">
				  <option value=""></option>
				  <%
				  On Error Resume Next				  
				  Set objListaUtenti = objUtente.findUtente(null, 3, 1, null, null, null)				  
				  
				  If Err.Number<>0 then
					response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
				  end if
				  
				  if not(id_user_search = "") then id_user_search = Cint(id_user_search) end if
				  for each y in objListaUtenti.Keys
				  	Set tmpObjUsr = objListaUtenti(y)%>		  
					<option value="<%=y%>" <%if(id_user_search = y) then response.write("selected") end if%>><%=tmpObjUsr.getUserName()%></option>
				  <%next%>
				  </select>	
				  </td>
					<td>
					<input type="text" value="<%=dta_ins_search_from%>" name="dta_ins_search_from" class="formFieldTXT">
					</td>
				  <td>			  
				  <input type="text" value="<%=dta_ins_search_to%>" name="dta_ins_search_to" class="formFieldTXT">	  
				  </td> 
				  </tr>
				  <tr> 
					<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.type_pagam")%></th>
					<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.pagam_done")%></th>
					<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.order_by")%></th>
				  </tr>	
				  <tr>
				  <td>			  
				  <select name="tipo_pagam_search" class="formFieldTXT">		
					<option value=""></option>		
				  <%
				  On Error Resume Next
				  Dim objListaTipiPagamento, pagamCount, iIndexPagam, objTmpPagam, objTmpPagamKey
				  Set objListaTipiPagamento = objPayment.getListaPayment(1,null)  	
				  if not(tipo_pagam_search = "") then tipo_pagam_search = Cint(tipo_pagam_search) end if			  
				  for each k in objListaTipiPagamento.Keys%>
				 	<option value="<%=k%>" <%if(tipo_pagam_search = k) then response.write("selected") end if%>><%=langEditor.getTranslated(objListaTipiPagamento(k).getKeywordMultilingua())%></option>					
				  <%next
				  Set objListaTipiPagamento = nothing
				  If Err.Number<>0 then
				  end if
				  %> 
				  </select>
				  </td>
				  <td>			  
				  <select name="pagam_done_search" class="formFieldChangeStato">
					<option value=""></option>
					<option value="0" <%if(pagam_done_search = "0") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.commons.no")%></option>
					<option value="1" <%if(pagam_done_search = "1") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.commons.yes")%></option>
				  </select>		  
				  </td> 
				<td>			  
				  <select name="ord_by_search" class="formFieldSelect">
					  <option value=""></option>
					  <option value="3" <%if(ord_by_search = "3") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_user_asc")%></option>
					  <option value="4" <%if(ord_by_search = "4") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_user_desc")%></option>
					  <option value="5" <%if(ord_by_search = "5") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_asc")%></option>
					  <option value="6" <%if(ord_by_search = "6") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_desc")%></option>
					  <option value="7" <%if(ord_by_search = "7") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_asc")%></option>
					  <option value="8" <%if(ord_by_search = "8") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_desc")%></option>
					  <option value="11" <%if(ord_by_search = "11") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_tipo_pagam_asc")%></option>
					  <option value="12" <%if(ord_by_search = "12") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_tipo_pagam_desc")%></option>
					  <option value="13" <%if(ord_by_search = "13") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_asc")%></option>
					  <option value="14" <%if(ord_by_search = "14") then response.write("selected") end if%>><%=langEditor.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_desc")%></option>
				  </select>					
				  </td>
			  </tr>
				<tr> 
					<th colspan="2"><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.order_guid")%></th>
					<th><%=langEditor.getTranslated("backend.ordini.lista.table.search.header.stato_ord")%></th>
				  </tr>	
				<tr><td colspan="2">
					<input type="text" value="<%=ord_guid_search%>" name="ord_guid_search" class="formFieldTXTBig">
					</td>
					  <td>			  
					  <%Set objListaStatiOrdine = objOrdini.getListaStatiOrder()
					  if not(stato_ord_search = "") then stato_ord_search = Cint(stato_ord_search) end if%>
					  <select name="stato_ord_search" class="formFieldChangeStato">
						<option value=""></option>
					  <%for each w in objListaStatiOrdine.Keys%>
						<option value="<%=w%>" <%if(stato_ord_search = Cint(w)) then response.write("selected") end if%>><%=langEditor.getTranslated(objListaStatiOrdine(w))%></option>
					  <%next%>
					  </select>
					  <%Set objListaStatiOrdine = nothing%>	  
					  </td> 
				</tr>
			  <tr><td colspan="3">			  
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.lista.button.search.label")%>" onclick="javascript:sendSearchOrder();" />&nbsp;
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.lista.button.label.download_excel")%>" onclick="javascript:openWinExcel('<%=Application("baseroot")&"/editor/report/CreateOrderExcel.asp?search_ordini="&request("search_ordini")&"&id_utente_search="&id_user_search&"&dta_ins_search_from="&dta_ins_search_from&"&dta_ins_search_to="&dta_ins_search_to&"&tipo_pagam_search="&tipo_pagam_search&"&pagam_done_search="&pagam_done_search&"&stato_ord_search="&stato_ord_search&"&ord_by_search="&ord_by_search&"&ord_guid_search="&ord_guid_search%>','crea_excel',400,400,100,100);" />
				<br/><br/>
			</td></tr>	    
			  </form>
		 	</table>	
		<%

		Dim hasOrder, id_ordine_search
		hasOrder = false
		
		Set objListaStatiOrdine = objOrdini.getListaStatiOrder()
			
		if(request("search_ordini") = "") then
			on error Resume Next
			Set objListaOrdini = objOrdini.getListaOrdini(order_ordine_by, 0)		

			if(objListaOrdini.Count > 0) then
				hasOrder = true
			end if

			if Err.number <> 0 then
			end if		
		else		
			id_ordine_search = null
			
			if(id_user_search = "") then id_user_search = null end if
			if(dta_ins_search_from = "") then dta_ins_search_from = null end if
			if(dta_ins_search_to = "") then dta_ins_search_to = null end if
			if(tipo_pagam_search = "") then tipo_pagam_search = null end if
			if(pagam_done_search = "") then pagam_done_search = null else pagam_done_search=Cint(pagam_done_search) end if
			if(stato_ord_search = "") then stato_ord_search = null end if
			if(ord_by_search = "") then ord_by_search = null end if
			if(ord_guid_search = "") then ord_guid_search = null end if		

			on error Resume Next
			Set objListaOrdini = objOrdini.findOrdini(id_ordine_search, id_user_search, dta_ins_search_from, dta_ins_search_to, stato_ord_search, tipo_pagam_search, pagam_done_search, ord_by_search, 0, ord_guid_search)	

			if(objListaOrdini.Count > 0) then
				hasOrder = true
			end if
				
			if Err.number <> 0 then
			end if	
		end if
		
		
		
		
		'****************************** creo il grafico vendite su base annua/mensile
		on error Resume Next
		showChart = false
		Set objDictChart= Server.CreateObject("Scripting.Dictionary")
		Set objDictMonths= Server.CreateObject("Scripting.Dictionary")
		objDictMonths.add 1, langEditor.getTranslated("backend.ordini.lista.table.chart.gen")
		objDictMonths.add 2, langEditor.getTranslated("backend.ordini.lista.table.chart.feb")
		objDictMonths.add 3, langEditor.getTranslated("backend.ordini.lista.table.chart.mar")
		objDictMonths.add 4, langEditor.getTranslated("backend.ordini.lista.table.chart.apr")
		objDictMonths.add 5, langEditor.getTranslated("backend.ordini.lista.table.chart.mag")
		objDictMonths.add 6, langEditor.getTranslated("backend.ordini.lista.table.chart.giu")
		objDictMonths.add 7, langEditor.getTranslated("backend.ordini.lista.table.chart.lug")
		objDictMonths.add 8, langEditor.getTranslated("backend.ordini.lista.table.chart.ago")
		objDictMonths.add 9, langEditor.getTranslated("backend.ordini.lista.table.chart.set")
		objDictMonths.add 10, langEditor.getTranslated("backend.ordini.lista.table.chart.ott")
		objDictMonths.add 11, langEditor.getTranslated("backend.ordini.lista.table.chart.nov")
		objDictMonths.add 12, langEditor.getTranslated("backend.ordini.lista.table.chart.dic")		

		reference = ""		
		if(request("chart_filter") = "m")then
			curr_day = Day(Date())
			reference = objDictMonths(Month(Date()))
			
			for counter = 1 to curr_day
			objDictChart.add counter, 0
			next
			
			dta_chart_from = "01/"&Month(Date())&"/"&year(Date())
			dta_chart_to = Date()		
		else
			curr_mont = Month(Date())
			reference = year(Date())
			
			for counter = 1 to curr_mont
			objDictChart.add counter, 0
			next
			
			dta_chart_from = "01/01/"&year(Date())
			dta_chart_to = Day(Date())&"/"&Month(Date())&"/"&year(Date())		
		end if
		
		Set objListaOrdiniC = objOrdini.findOrdini(null, null, dta_chart_from, dta_chart_to, 3, null, 1, 5, 0, null)	

		total_orderc = 0
		if(objListaOrdiniC.Count > 0) then
			showChart = true
			total_orderc = objListaOrdiniC.Count
			for each x in objListaOrdiniC
				if(request("chart_filter") = "m")then
					baseC = Day(objListaOrdiniC(x).getDtaInserimento())
				else
					baseC = Month(objListaOrdiniC(x).getDtaInserimento())
				end if
				val = objDictChart.Item(baseC)
				objDictChart.Item(baseC) = Cint(val)+1
			next
		end if
		Set objListaOrdiniC = nothing
		
		if Err.number <> 0 then
			showChart = false
		end if
		
		if(showChart)then%>
		<table border="0" class="chart" align="top" cellpadding="0" cellspacing="0">
		<tr>
		<td valign="middle" align="right">
			<form action="<%=Application("baseroot") & "/editor/ordini/listaordini.asp"%>" method="post" name="form_change_chart">
			<input type="hidden" value="<%=order_ordine_by%>" name="order_by">
			<input type="hidden" value="<%=itemsXpage%>" name="items">			
			<input type="hidden" value="<%=numPage%>" name="page">			
			<input type="hidden" value="<%=request("search_ordini")%>" name="search_ordini">
			  <select name="chart_filter" class="formFieldChangeStato" onChange="document.form_change_chart.submit();">
				<option value="m" <%if (request("chart_filter") = "m") then response.Write("selected")%>><%=langEditor.getTranslated("backend.ordini.lista.table.chart.month")%></option>
				<option value="y" <%if (request("chart_filter") = "y" OR request("chart_filter") = "") then response.Write("selected")%>><%=langEditor.getTranslated("backend.ordini.lista.table.chart.year")%></option>
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
					width: 700,
					height: 200					
				    },
				    title: {
					text: '<%=langEditor.getTranslated("backend.ordini.lista.table.chart.sales_rep")%><%if (request("chart_filter") = "m") then response.Write(" "&langEditor.getTranslated("backend.ordini.lista.table.chart.month")) else response.Write(" "&langEditor.getTranslated("backend.ordini.lista.table.chart.year")) end if%><%=" ("&reference&")"%>',
					x: -20 //center
				    },
				    subtitle: {
					text: '(<%=langEditor.getTranslated("backend.ordini.lista.table.chart.sales_rep_sub")&" "&total_orderc%>)',
					x: -20 //center
				    },
				    xAxis: {
					categories: [
					<%
					categories = ""
					for each q in objDictChart
						if(request("chart_filter") = "m")then
							categories = categories & "'"& q &"',"							
						else
							categories = categories & "'"& objDictMonths(q) &"',"						
						end if
					next					
					if(Len(categories)>0) then categories= Left(categories,Len(categories)-1) end if					
					response.write(categories)
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
					name: '<%=langEditor.getTranslated("backend.ordini.lista.table.chart.orders_label")%>',
					data: [
					<%
					series = ""
					for each q in objDictChart
						series = series & objDictChart(q) &","
					next					
					if(Len(series)>0) then series= Left(series,Len(series)-1) end if					
					response.write(series)
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
		<%end if%>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr> 
				<th colspan="3">&nbsp;</th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.id_ordine")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.cliente")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.data_insert")%>&nbsp;<a href="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp?order_by=1&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&items="&itemsXpage&"&search_ordini="&request("search_ordini")%>"><img src="<%=Application("baseroot")&"/editor/img/order_top.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_asc")%>" hspace="2" vspace="0" border="0"></a><a href="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp?order_by=2&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&items="&itemsXpage&"&search_ordini="&request("search_ordini")%>"><img src="<%=Application("baseroot")&"/editor/img/order_bottom.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_desc")%>" hspace="2" vspace="0" border="0"></a></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.type_pagam")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.pagam_done")%></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.totale_order")%>&nbsp;<a href="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp?order_by=3&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&items="&itemsXpage&"&search_ordini="&request("search_ordini")%>"><img src="<%=Application("baseroot")&"/editor/img/order_top.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_asc")%>" hspace="2" vspace="0" border="0"></a><a href="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp?order_by=4&page="&numPage&"&strGerarchiaTmp="&request("strGerarchiaTmp")&"&target_cat="&request("target_cat")&"&items="&itemsXpage&"&search_ordini="&request("search_ordini")%>"><img src="<%=Application("baseroot")&"/editor/img/order_bottom.gif"%>" alt="<%=langEditor.getTranslated("backend.commons.alt.order_by_desc")%>" hspace="2" vspace="0" border="0"></a></th>
				<th><%=langEditor.getTranslated("backend.ordini.lista.table.header.stato_ord")%></th>
			</tr>
			  
			<%					
			if(hasOrder) then
				intCount = 0					
				iIndex = objListaOrdini.Count
				iIndexStatiOrder = objListaStatiOrdine.Count
				
				FromOrder = ((numPage * itemsXpage) - itemsXpage)
				Diff = (iIndex - ((numPage * itemsXpage)-1))
				if(Diff < 1) then
					Diff = 1
				end if
				
				ToOrder = iIndex - Diff
				
				totPages = iIndex\itemsXpage
				if(totPages < 1) then
					totPages = 1
				elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
					totPages = totPages +1	
				end if		
						
				objTmpOrder = objListaOrdini.Items					
				Dim objTmpUser				
				
				styleRow2 = "table-list-on"
											
				for orderCounter = FromOrder to ToOrder
					styleRow = "table-list-off"
					if(orderCounter MOD 2 = 0) then styleRow = styleRow2 end if
					Set objFilteredOrder = objTmpOrder(orderCounter)
					%>
					<form action="<%=Application("baseroot") & "/editor/ordini/CambiaStatoOrder.asp"%>" method="post" name="form_change_state_<%=intCount%>">
					<input type="hidden" value="<%=objFilteredOrder.getIDOrdine()%>" name="id_order_to_change">
					<input type="hidden" value="<%=order_ordine_by%>" name="order_by">
					<input type="hidden" value="<%=itemsXpage%>" name="items">			
					<input type="hidden" value="<%=numPage%>" name="page">			
					<input type="hidden" value="<%=request("search_ordini")%>" name="search_ordini">
					
					<tr class="<%=styleRow%>">
					<td align="center" width="25"><a href="<%=Application("baseroot") & "/editor/ordini/VisualizzaOrdine.asp?cssClass=LO&id_ordine=" & objFilteredOrder.getIDOrdine()%>"><img src="<%=Application("baseroot")&"/editor/img/zoom.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.lista.table.alt.view_order")%>" hspace="2" vspace="0" border="0"></a></td>
					<td align="center" width="25"><%if not(objFilteredOrder.getStatoOrdine() = 3) AND not(objFilteredOrder.getStatoOrdine() = 4) then%><a href="javascript:editOrder(<%=objFilteredOrder.getIDOrdine()%>);"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.lista.table.alt.modify_order")%>" hspace="2" vspace="0" border="0"></a><%else%>&nbsp;<%end if%></td>		
					<td align="center" width="25"><a href="javascript:confirmDelete('<%=objFilteredOrder.getIDOrdine()%>','<%=objFilteredOrder.getStatoOrdine()%>');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.detail.button.elimina.label")%>" hspace="2" vspace="0" border="0"></a></td>				
					<td><%=objFilteredOrder.getIDOrdine()%></td>
					<td>
					<%
					Set objTmpUser = objUtente.findUserByID(objFilteredOrder.getIDUtente())
					response.Write(objTmpUser.getUserName())
					%>
					</td>
					<td><%=objFilteredOrder.getDtaInserimento()%></td>
					<td>
					<%
					Set objTmpPayment = objPayment.findPaymentByID(objFilteredOrder.getTipoPagam())
					payUrlTmp = objTmpPayment.getURL()
					response.write(langEditor.getTranslated(objTmpPayment.getKeywordMultilingua()))
					Set objTmpPayment = Nothing
					%>
					</td>
					<td>
					<%
					Select Case objFilteredOrder.getPagamEffettuato()
					Case 0%>
						&nbsp;&nbsp;<img src="<%=Application("baseroot")&"/editor/img/sema_al.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.lista.table.alt.order_to_pay")%>" hspace="2" vspace="0" border="0" align="absmiddle">
					<%	response.write(langEditor.getTranslated("backend.commons.no"))						
					Case 1						
						Dim paymentNotified
						paymentNotified = false
						Set objPaymentTrans = new PaymentTransactionClass
						if(objPaymentTrans.hasPaymentTransactionNotified(objFilteredOrder.getIDOrdine())) then
							paymentNotified = true
						end if
						Set objPaymentTrans = nothing
						
						if(paymentNotified OR payUrlTmp = 0) then%>
							&nbsp;&nbsp;<img src="<%=Application("baseroot")&"/editor/img/sema_no.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.lista.table.alt.order_paied_notified")%>" hspace="2" vspace="0" border="0" align="absmiddle">
						<%else%>
							&nbsp;&nbsp;<a href="javascript:confirmNotify('<%=objFilteredOrder.getIDOrdine()%>');"><img src="<%=Application("baseroot")&"/editor/img/sema_adup.png"%>" alt="<%=langEditor.getTranslated("backend.ordini.lista.table.alt.order_paied_no_notified")%>" hspace="2" vspace="0" border="0" align="absmiddle"></a>
						<%end if							
						response.write(langEditor.getTranslated("backend.commons.yes"))
					Case Else
					End Select
					%>
					</td>
					<td>&euro;&nbsp;<%=FormatNumber(objFilteredOrder.getTotale(),2,-1)%></td>
					<td>
					  <select name="stato_order" class="formFieldChangeStato" onChange="document.form_change_state_<%=intCount%>.submit();">
					  <%for each y in objListaStatiOrdine%>
						<option value="<%=y%>" <%if (objFilteredOrder.getStatoOrdine() = y) then response.Write("selected")%>><%=langEditor.getTranslated(objListaStatiOrdine(y))%></option>
					  <%next%>
					  </select>
					</td>
					</tr>			
					</form>	
					<%intCount = intCount +1
					Set objFilteredOrder = nothing
				next
				Set objTmpUser = nothing
				Set objTmpOrder = nothing
				Set objTmpStatiOrder = nothing
				Set objTmpStatiOrderKey = nothing
				Set objListaOrdini = nothing
				%>
			  
			<form action="<%=Application("baseroot") & "/editor/ordini/ListaOrdini.asp"%>" method="post" name="item_x_page">
				<input type="hidden" value="<%=order_ordine_by%>" name="order_by">		
			  <tr> 
				<th colspan="10" align="left">
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				<%		
				'**************** richiamo paginazione
				call PaginazioneFrontend(totPages, numPage, strGerarchia, "/editor/ordini/ListaOrdini.asp", "&order_by="&order_ordine_by&"&items="&itemsXpage&"&search_ordini="&request("search_ordini"))%>
			</th>	
			</tr>		
			</form>		
			<%end if%>
		</table>
		<br/>
		<form action="<%=Application("baseroot") & "/editor/ordini/InserisciOrdine1.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LO" name="cssClass">
		<input type="hidden" value="-1" name="id_ordine">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.lista.button.inserisci.label")%>" onclick="javascript:document.form_crea.submit();" />
		</form>
		<form action="<%=Application("baseroot") & "/editor/ordini/DeleteOrder.asp"%>" method="post" name="form_cancella_order">
		<input type="hidden" value="" name="id_order_to_delete">
		<input type="hidden" value="" name="status_order_to_delete">
		<input type="hidden" value="<%=order_ordine_by%>" name="order_by">
		<input type="hidden" value="<%=itemsXpage%>" name="items">			
		<input type="hidden" value="1" name="page">
		<input type="hidden" value="<%=request("search_ordini")%>" name="search_ordini">
		</form>
		<form action="<%=Application("baseroot") & "/editor/ordini/confirmPayNotifiedOrder.asp"%>" method="post" name="form_notify_payment">
		<input type="hidden" value="" name="id_order">
		<input type="hidden" value="<%=order_ordine_by%>" name="order_by">
		<input type="hidden" value="<%=itemsXpage%>" name="items">			
		<input type="hidden" value="<%=numPage%>" name="page">
		<input type="hidden" value="<%=request("search_ordini")%>" name="search_ordini">
		</form>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>		
<%		
Set objPayment = Nothing
Set objOrdini = Nothing	
Set objUtente = nothing	
%>