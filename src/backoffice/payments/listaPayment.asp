<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deletePayment(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.payment.lista.js.alert.delete_payment")%>?")){
		ajaxDeleteItem(id_objref,"payment",row,refreshrows);
	}
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LPT"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=langEditor.getTranslated("backend.payment.lista.table.header.descrizione_payment")%></th>
				  <th><%=langEditor.getTranslated("backend.payment.lista.table.header.dati_pagamento")%></th>
				  <th><%=langEditor.getTranslated("backend.payment.lista.table.header.active")%></th>
				  <th><%=langEditor.getTranslated("backend.payment.lista.table.header.payment_type")%></th>
				  <th><%=langEditor.getTranslated("backend.payment.lista.table.header.url")%></th>
			</tr> 
				<%
				On Error Resume Next
				Set objListaPayment = objPayment.getListaPayment(null,null)
				
				if Err.number <> 0 then
					Set objListaPayment = null
				end if	
				if not(isNull(objListaPayment)) AND not isEmpty(objListaPayment) AND isObject(objListaPayment) then
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpPayment, objTmpPaymentKey, FromPayment, ToPayment, Diff
					iIndex = objListaPayment.Count
					FromPayment = ((numPage * itemsXpage) - itemsXpage)
					Diff = (iIndex - ((numPage * itemsXpage)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToPayment = iIndex - Diff
					
					totPages = iIndex\itemsXpage
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"							
								
					objTmpPayment = objListaPayment.Items
					objTmpPaymentKey=objListaPayment.Keys	
					for newsCounter = FromPayment to ToPayment
					styleRow = "table-list-off"
					if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
					<form action="<%=Application("baseroot") & "/editor/payments/InserisciPayment.asp"%>" method="post" name="form_lista_<%=intCount%>">
					<input type="hidden" value="<%=objTmpPaymentKey(newsCounter)%>" name="id_payment">
					<input type="hidden" value="" name="delete_payment">
					<input type="hidden" value="LPT" name="cssClass">
					</form> 
					<tr class="<%=styleRow%>" id="tr_delete_list_<%=intCount%>">
						<%Set objTmpPayment0 = objTmpPayment(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_lista_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.payment.lista.table.alt.modify_payment")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deletePayment(<%=objTmpPaymentKey(newsCounter)%>, 'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.payment.lista.table.alt.delete_payment")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="17%">						
						<div class="ajax" id="view_descrizione_<%=intCount%>" onmouseover="javascript:showHide('view_descrizione_<%=intCount%>','edit_descrizione_<%=intCount%>','descrizione_<%=intCount%>',500, false);"><%=objTmpPayment0.getDescrizione()%></div>
						<div class="ajax" id="edit_descrizione_<%=intCount%>"><input type="text" class="formfieldAjax" id="descrizione_<%=intCount%>" name="descrizione" onmouseout="javascript:restoreField('edit_descrizione_<%=intCount%>','view_descrizione_<%=intCount%>','descrizione_<%=intCount%>','payment',<%=objTmpPayment0.getPaymentID()%>,1,<%=intCount%>);" value="<%=objTmpPayment0.getDescrizione()%>"></div>
						<script>
						$("#edit_descrizione_<%=intCount%>").hide();
						</script>
						</td>
						<td width="30%">					
						<div class="ajax" id="view_dati_pagamento_<%=intCount%>" onmouseover="javascript:showHide('view_dati_pagamento_<%=intCount%>','edit_dati_pagamento_<%=intCount%>','dati_pagamento_<%=intCount%>',500, false);"><%=objTmpPayment0.getDatiPagamento()%></div>
						<div class="ajax" id="edit_dati_pagamento_<%=intCount%>" style="position:relative;z-index:1000;"><textarea class="formfieldAjaxArea" id="dati_pagamento_<%=intCount%>" name="dati_pagamento" onmouseout="javascript:restoreField('edit_dati_pagamento_<%=intCount%>','view_dati_pagamento_<%=intCount%>','dati_pagamento_<%=intCount%>','payment',<%=objTmpPayment0.getPaymentID()%>,1,<%=intCount%>);"><%=objTmpPayment0.getDatiPagamento()%></textarea></div>
						<script>
						$("#edit_dati_pagamento_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_active_<%=intCount%>" onmouseover="javascript:showHide('view_active_<%=intCount%>','edit_active_<%=intCount%>','active_<%=intCount%>',500, true);">
						<%
						if (strComp("1", objTmpPayment0.getAttivo(), 1) = 0) then 
							response.Write(langEditor.getTranslated("backend.commons.yes"))
						else 
							response.Write(langEditor.getTranslated("backend.commons.no"))
						end if
						%>
						</div>
						<div class="ajax" id="edit_active_<%=intCount%>">
						<select name="active" class="formfieldAjaxSelect" id="active_<%=intCount%>" onblur="javascript:updateField('edit_active_<%=intCount%>','view_active_<%=intCount%>','active_<%=intCount%>','payment',<%=objTmpPayment0.getPaymentID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpPayment0.getAttivo(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpPayment0.getAttivo(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_active_<%=intCount%>").hide();
						</script>
						</td>						
						<td>
						<div class="ajax" id="view_payment_type_<%=intCount%>" onmouseover="javascript:showHide('view_payment_type_<%=intCount%>','edit_payment_type_<%=intCount%>','payment_type_<%=intCount%>',500, true);">
						<%
						if (strComp("1", objTmpPayment0.getPaymentType(), 1) = 0) then 
							response.Write(langEditor.getTranslated("backend.payment.label.direct_payment"))
						else 
							response.Write(langEditor.getTranslated("backend.payment.label.no_charge"))
						end if
						%>
						</div>
						<div class="ajax" id="edit_payment_type_<%=intCount%>">
						<select name="payment_type" class="formfieldAjaxSelect" id="payment_type_<%=intCount%>" onblur="javascript:updateField('edit_payment_type_<%=intCount%>','view_payment_type_<%=intCount%>','payment_type_<%=intCount%>','payment',<%=objTmpPayment0.getPaymentID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpPayment0.getPaymentType(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.payment.label.no_charge")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpPayment0.getPaymentType(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.payment.label.direct_payment")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_payment_type_<%=intCount%>").hide();
						</script>
						</td>
						
						<td><%if (objTmpPayment0.getURL() = 0) then response.write(langEditor.getTranslated("backend.commons.no")) else response.write(langEditor.getTranslated("backend.commons.yes")) end if%></td>
					</tr>				
					<%intCount = intCount +1
					next
					Set objListaPayment = nothing
				end if
				Set objPayment = Nothing
				%>
			<tr> 
			<form action="<%=Application("baseroot") & "/editor/payments/ListaPayment.asp"%>" method="post" name="item_x_page">
			<th colspan="7">
			<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPage, strGerarchia, "/editor/payments/ListaPayment.asp", "&items="&itemsXpage)
			%>
			</th>
			</form>
		</tr>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/payments/InserisciPayment.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LPT" name="cssClass">	
		<input type="hidden" value="-1" name="id_payment">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.payment.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>		
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>