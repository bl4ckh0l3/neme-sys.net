<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init2.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">

function insertTassa(){
	
	if(document.form_inserisci.descrizione.value == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.descrizione.focus();
		return;
	}

	var thisValoreProd = document.form_inserisci.valore.value;
	if(thisValoreProd == ""){
		alert("<%=langEditor.getTranslated("backend.tasse.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.valore.focus();
		return;
	}else if(thisValoreProd.indexOf('.') != -1){
		alert("<%=langEditor.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.valore.focus();
		return;		
	}
	
	document.form_inserisci.submit()
}

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
});

function showDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;

	element.style.left=tempX+10;
	element.style.top=tempY+10;
	$(jquery_id).show(500);
	element.style.visibility = 'visible';		
	element.style.display = "block";
}

function hideDiv(elemID){
	var element = document.getElementById(elemID);

	element.style.visibility = 'hidden';
	element.style.display = "none";
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.descrizione.focus();">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr><td>
		<form action="<%=Application("baseroot") & "/editor/tax/ProcessTassa.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_tassa%>" name="id_tassa">
		  <span class="labelForm"><%=langEditor.getTranslated("backend.tasse.detail.table.label.descrizione_tassa")%></span><br>
		  <input type="text" name="descrizione" value="<%=strDescrizione%>" class="formFieldTXT">&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_desc');" class="labelForm" onmouseout="javascript:hideDiv('help_desc');">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_desc">
		  <%=langEditor.getTranslated("backend.tasse.detail.table.label.field_help_desc")%>
		  </div>
		  <br/><br/>	
		  <div align="left" style="float:left;"><span class="labelForm"><%=langEditor.getTranslated("backend.tasse.detail.table.label.valore")%></span><br>
		  <input type="text" name="valore" value="<%=iValore%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=langEditor.getTranslated("backend.tasse.detail.table.label.tipo_valore")%></span><br>
			<select name="tipo_valore" class="formFieldTXTMedium">
			<option value="1"<%if ("1"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.tasse.label.tipologia_fisso")%></option>	
			<option value="2"<%if ("2"=iType) then response.Write(" selected")%>><%=langEditor.getTranslated("backend.tasse.label.tipologia_percentuale")%></option>	
			</SELECT>	
		  </div>
		</form><br/>
		</td></tr>
		</table><br/>	    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.tasse.detail.button.inserisci.label")%>" onclick="javascript:insertTassa();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/tax/ListaTasse.asp?cssClass=LTX"%>';" />
		<br/><br/> 		
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>