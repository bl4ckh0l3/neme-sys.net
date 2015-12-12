<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init3.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">

function insertGroup(){

	if(document.form_inserisci.short_desc.value == "") {
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_short_desc")%>");
		document.form_inserisci.short_desc.focus();
		return false;		
	}

	if(document.form_inserisci.long_desc.value == "") {
		alert("<%=langEditor.getTranslated("backend.margini.detail.js.alert.insert_long_desc")%>");
		document.form_inserisci.long_desc.focus();
		return false;		
	}

	document.form_inserisci.submit()
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.short_desc.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
	<table class="principal" cellpadding="0" cellspacing="0">
	<tr> 
	<td>
		<form action="<%=Application("baseroot") & "/editor/margini/ProcessGroup.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="usrgroup" name="showtab">
		  <input type="hidden" value="<%=id_group%>" name="id_group">
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.short_desc")%></span><br>
		  <input type="text" name="short_desc" value="<%=shortDesc%>" class="formFieldTXTMedium">
		  <br/><br/>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.long_desc")%></span><br>
		  <textarea name="long_desc" class="formFieldTXTAREAAbstract"><%=longDesc%></textarea>
		  </div>	
		  <br/>		  
		  <span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.taxs_group")%></span><br>
		  <select name="taxs_group" class="formFieldTXT">
		  <option value=""></option>
			<%
			Dim objTaxGroup, objListaTaxGroup, objGroupT
			Set objTaxGroup = new TaxsGroupClass
			On Error Resume Next
			Set objListaTaxGroup = objTaxGroup.getListaTaxsGroup(null)
			if not (isNull(objListaTaxGroup)) then
				for each y in objListaTaxGroup.Keys
					Set objGroupT = objListaTaxGroup(y)%>
					<option value="<%=y%>" <%if (taxsGroup = y) then response.write("selected") end if%>><%=objGroupT.getGroupDescription()%></option>	
				<%	Set objGroupT = nothing
				next
			end if		
			Set objListaTaxGroup = nothing
			if(Err.number<>0)then
			end if
			Set objTaxGroup = nothing
			%>	  
		  </select><br/><br/>	 	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.margini.detail.table.label.default_group")%></span><br>
			<select name="default_group" class="formFieldTXTShort">
			<option value="0"<%if ("0"=defaultGroup) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.no")%></option>	
			<option value="1"<%if ("1"=defaultGroup) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></option>	
			</SELECT>
		  </div>	
		</form>
		</td></tr>
		</table><br/>		
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.detail.button.inserisci.label")%>" onclick="javascript:insertGroup();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/margini/ListaMargini.asp?cssClass=LM&showtab=usrgroup"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>