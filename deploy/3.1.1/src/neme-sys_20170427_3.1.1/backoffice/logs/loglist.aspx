<%@ Page Language="C#" AutoEventWireup="true" CodeFile="loglist.aspx.cs" Inherits="_LogList" Debug="true"%>
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
<script language="JavaScript">
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
		alert("<%=lang.getTranslated("backend.logs.lista.js.alert.date_format")%>")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		alert("<%=lang.getTranslated("backend.logs.lista.js.alert.valid_month")%>")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		alert("<%=lang.getTranslated("backend.logs.lista.js.alert.valid_day")%>")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		alert("<%=lang.getTranslated("backend.logs.lista.js.alert.valid_year")%> "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		alert("<%=lang.getTranslated("backend.logs.lista.js.alert.valid_date")%>")
		return false
	}
return true
}

function sendSearchLogs(){
	var dtf=document.form_search.dta_from
	var dtt=document.form_search.dta_to
	if(dtf.value != ""){
		if (isDate(dtf.value)==false){
			dtf.focus()
			return
		}
		//document.form_search.dta_from.value = document.form_search.dta_from.value + " 00:00:00"
		//alert(document.form_search.dta_ins_search.value);
		
	}
	if(dtt.value != ""){
		if (isDate(dtt.value)==false){
			dtt.focus()
			return
		}
		//document.form_search.dta_to.value = document.form_search.dta_to.value + " 23:59:59"
		//alert(document.form_search.dta_ins_search.value);
		
	}
    document.form_search.submit();
 }
 
 

function sendDeleteLogs(){
	var dtf=document.form_search.dta_from
	var dtt=document.form_search.dta_to
	if(dtf.value != ""){
		if (isDate(dtf.value)==false){
			dtf.focus()
		return
		}
		//document.form_search.dta_from.value = document.form_search.dta_from.value + " 00:00:00"
		//alert(document.form_search.dta_ins_search.value);

	}
	
	if(dtt.value != ""){
		if (isDate(dtt.value)==false){
			dtt.focus()
		return
		}
		//document.form_search.dta_to.value = document.form_search.dta_to.value + " 23:59:59";
		//alert(document.form_search.dta_ins_search.value);

	}
	
	document.form_search.delete_log.value="1";
	
	if(confirm("<%=lang.getTranslated("backend.logs.lista.js.alert.confirm_log_delete")%>")){
		document.form_search.submit();
	}else
		return;
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
		<table class="principal" cellpadding="0" cellspacing="0">
		<form action="/backoffice/logs/loglist.aspx" method="post" name="form_search">
		<INPUT TYPE="hidden" NAME="delete_log" VALUE="">
		<input type="hidden" value="1" name="page">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">
		<tr> 
		<th>&nbsp;</th>
		<th><lang:getTranslated keyword="backend.logs.lista.table.header.type" runat="server" /></th>
		<th><lang:getTranslated keyword="backend.logs.lista.table.header.date_from" runat="server" /></th>
		<th><lang:getTranslated keyword="backend.logs.lista.table.header.date_to" runat="server" /></th>
		</tr>
		<tr height="40"> 
		<td align="center">
		<input type="button" class="buttonForm" hspace="4" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.logs.lista.button.cerca.label")%>" onclick="javascript:sendSearchLogs();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="4" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.logs.lista.button.cancella.label")%>" onclick="javascript:sendDeleteLogs();" />
		</td>
		<td>			  
		  <select name="log_type" class="formFieldChangeStato">
		  <option value=""></option>
		  <option value="debug" <%if(paramType == "debug") { Response.Write("selected"); }%>><%=lang.getTranslated("backend.logs.lista.table.select.option.degug")%></option>
		  <option value="info" <%if(paramType == "info") { Response.Write("selected"); }%>><%=lang.getTranslated("backend.logs.lista.table.select.option.info")%></option>
		  <option value="error" <%if(paramType == "error") { Response.Write("selected"); }%>><%=lang.getTranslated("backend.logs.lista.table.select.option.error")%></option>
		  </select>		
		</td>
		<td><input type="text" value="<%=paramDateFrom%>" name="dta_from" id="dta_from" class="formFieldTXT"></td>
		<td><input type="text" value="<%=paramDateTo%>" name="dta_to" id="dta_to" class="formFieldTXT"></td>
		</tr>
		  </form>
		</table>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		      <tr> 
				<th colspan="5" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="/backoffice/logs/loglist.aspx" method="post" name="item_x_page">
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
		      <th>&nbsp;</th>
			<th><lang:getTranslated keyword="backend.logs.lista.table.header.msg" runat="server" /></th>
			<th><lang:getTranslated keyword="backend.logs.lista.table.header.usr" runat="server" /></th>
			<th><lang:getTranslated keyword="backend.logs.lista.table.header.type" runat="server" /></th>
		      <th><lang:getTranslated keyword="backend.logs.lista.table.header.date_insert" runat="server" /></th>
		      </tr> 
			<%			
			int counter = 0;
			foreach (Logger k in logs.Values){%>
				<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">				
					<td>&nbsp;</td>
					<td><%=k.msg%></td>
					<td><%=k.usr%></td>
					<td><%=k.type%></td>
					<td><%=k.date%></td>               
				</tr>				
				<%counter++;
			}%>
		      <tr> 
				<th colspan="5" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="/backoffice/logs/loglist.aspx" method="post" name="item_x_page">
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
		<br><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.logs.lista.button.download_excel.label")%>" onclick="javascript:openWinExcel('/backoffice/report/create-log-excel.aspx','crea_excel',400,400,100,100);" />		
		<br/><br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>