<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include file="include/init3.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function sendForm(){
	var id_user = document.form_inserisci.id_utente.value;
	if(id_user == "" ){
		alert("<%=langEditor.getTranslated("backend.ordini.detail.js.alert.seleziona_utente")%>");
		return;
	}else{
		document.form_inserisci.submit();
	}
}


var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
})

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
          
function getAjaxUsrData(id_user, id_span){
	hideDiv('user_data');
	$('#'+id_span).empty();
	var query_string = "id_user="+id_user;
	
	$.ajax({
	type: "POST",
	url: "<%=Application("baseroot") & "/editor/ordini/getUserData.asp"%>",
	data: query_string,
	success: function(response) {
		$("#"+id_span).append(response);
		showDiv('user_data');
	}
	});
}

function sortDropDownListByText(elem) {  
	$("select#"+elem).each(function() {  
		var selectedValue = $(this).val();  
		$(this).html($("option", $(this)).sort(function(a, b) {  
		return a.text == b.text ? 0 : a.text < b.text ? -1 : 1  
		}));  
		$(this).val(selectedValue);  
	});  
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
		<table border="0" cellpadding="0" cellspacing="0" align="center">
		<tr>
		<td><a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine1.asp?id_ordine="&id_order&"&order_modified="&order_modified%>"><img src="<%=Application("baseroot")&"/editor/img/utenti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.order_client")%>"></a></td>
		<td width="100" align="center"><img src="<%=Application("baseroot")&"/editor/img/freccia_order.jpg"%>" hspace="0" vspace="0" border="0"></td>
		<td>
		<%if(CInt(id_order) <> -1 AND CInt(order_modified) <> 1) then%>
			<a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine2.asp?id_ordine="&id_order&"&order_modified="&order_modified&"&resetMenu=1"%>"><img src="<%=Application("baseroot")&"/editor/img/prodotti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%>"></a>
		<%else%>
			<img src="<%=Application("baseroot")&"/editor/img/prodotti.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.prod_list")%>">
		<%end if%>
		</td>
		<td width="100" align="center"><img src="<%=Application("baseroot")&"/editor/img/freccia_order.jpg"%>" hspace="0" vspace="0" border="0"></td>
		<td>
		<%if(CInt(id_order) <> -1 AND CInt(order_modified) <> 1) then%>
			<a href="<%=Application("baseroot")&"/editor/ordini/InserisciOrdine3.asp?id_ordine="&id_order&"&order_modified="&order_modified%>"><img src="<%=Application("baseroot")&"/editor/img/pagamento.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.tipo_pagam_order")%>"></a>
		<%else%>
			<img src="<%=Application("baseroot")&"/editor/img/pagamento.jpg"%>" hspace="0" vspace="0" border="0" alt="<%=langEditor.getTranslated("backend.ordini.detail.table.label.tipo_pagam_order")%>">
		<%end if%>
		</td>
		</tr>
		</table>
		<br/><br/>
		<form action="<%=Application("baseroot") & "/editor/ordini/ProcessOrdine1.asp"%>" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=id_order%>" name="id_ordine">
		  <input type="hidden" value="1" name="order_modified">

		  <span class="labelForm"><%=langEditor.getTranslated("backend.ordini.detail.table.label.order_client")%></span>:&nbsp;
		  <select name="id_utente" id="id_utente" class="formFieldUserOrder" multiple size="7">
		  <option value=""></option>
		  <%
		  Dim objUtente, objListaUtenti, iIndex, userCounter, objTmpUtenti, objTmpUtentiKey, tmpObjUsr
		  Set objUtente = New UserClass
		  On Error Resume Next		  
		  Set objListaUtenti = objUtente.findUtente(null, 3, 1, null, automatic_user, 1)
		  
		  if(Err.number<>0) then
			response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
		  end if
			
		  Dim idUserTmp
		  idUserTmp = id_utente
		  if(not(idUserTmp = "")) then
		  	idUserTmp = Clng(idUserTmp)
		  end if
		  
		  for each y in objListaUtenti.Keys
		  Set tmpObjUsr = objListaUtenti(y)
		  bolUserSelected = (idUserTmp = y)
		  bolIsAutomaticU = tmpObjUsr.getAutomaticUser()
		  if (bolIsAutomaticU=0) OR (bolIsAutomaticU=1 AND bolUserSelected) then
		  %>		  
		  <option value="<%=y%>" <%if (bolUserSelected) then response.Write("selected")%>><%=tmpObjUsr.getUserName()%></option>
		  <%
		  end if
		  next%>
		  </select>&nbsp;<a href="#" onClick="javascript:getAjaxUsrData($('#id_utente').val(), 'txt_usr_data');" class="labelForm">?</a>
		  <div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;margin-left:300px;" id="user_data">
		  <span id="txt_usr_data"></span>
		  </div>
		  
			<script>
			$('#id_utente').change(function() {			
				var id_utente_val_ch = $('#id_utente').val();
				
				//getAjaxUsrData(id_utente_val_ch, 'txt_usr_data');
				//sortDropDownListByText("id_utente");
			});
			
			$('#user_data').click(function(){
			   hideDiv('user_data');
			});
			</script> 		  
			<br><br>
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.ordini.detail.button.prosegui.label")%>" onclick="javascript:sendForm();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/ordini/ListaOrdini.asp?cssClass=LO"%>';" />
		</form>	
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>