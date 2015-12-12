<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init3.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deleteVoucherCode(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.voucher.lista.js.alert.delete_code")%>?")){
		ajaxDeleteItem(id_objref,"voucher_code",row,refreshrows);
	}
}

function generateVoucherCode(){
	<%if(voucher_type="4")then%>
	if(document.form_crea.id_user_ref.value == ""){
		alert("<%=langEditor.getTranslated("backend.voucher.detail.js.alert.insert_user")%>");
		document.form_crea.id_user_ref.focus();
		return;
	}
	<%end if%>	
	
	document.form_crea.submit();
}
</script>
</head>
<body>
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">		
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<tr>
			<th width="30%"><%=langEditor.getTranslated("backend.voucher.lista.table.header.label")%></th>
			<td class="separator">&nbsp;</td>
			<th width="50%"><%=langEditor.getTranslated("backend.voucher.detail.table.label.desc")%></th>
			<td class="separator">&nbsp;</td>
			<th width="20%"><%=langEditor.getTranslated("backend.voucher.lista.table.header.activate")%></th>
			</tr>		
			<tr>
			<td><%=label%></td>
			<td class="separator">&nbsp;</td>
			<td><%=description%></td>	
			<td class="separator">&nbsp;</td>
			<td>
			<%
			Select Case activate
			Case 0
				response.write(langEditor.getTranslated("backend.commons.no"))
			Case 1
				response.write(langEditor.getTranslated("backend.commons.yes"))
			Case Else
			End Select
			%></td>	
			</tr>		
			<tr>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.voucher_type")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.value")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.operation")%></th>
			</tr>		
			<tr>
			<td><%
			Select Case voucher_type
			Case 0
				response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot"))
			Case 1
				response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use"))
			Case 2
				response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_time"))
			Case 3
				response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_multiple_use_by_time"))
			Case 4
				response.write(langEditor.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_user"))
			Case Else
			End Select
			%></td>
			<td class="separator">&nbsp;</td>
			<td><%=valore%></td>
			<td class="separator">&nbsp;</td>
			<td>
			<%
			Select Case operation
			Case 0
				response.write(langEditor.getTranslated("backend.voucher.lista.operation.label.percentage"))
			Case 1
				response.write(langEditor.getTranslated("backend.voucher.lista.operation.label.fixed"))
			Case Else
			End Select
			%>
			</td>
			</tr>		
			<tr>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.generated_code")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.max_generation")%><%if(voucher_type="4")then response.write("&nbsp;"&langEditor.getTranslated("backend.voucher.lista.table.header.max_generation_by_user")) end if%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.max_usage")%></th>			
			</tr>		
			<tr>
			<td>
			<%
			total_counter_code = 0
			On Error Resume Next
			total_counter_code = objVoucher.countVoucherCodeByCampaign(id_voucher,null)
			if(Err.number<>0)then
				total_counter_code = 0
			end if
			response.write(total_counter_code)
			%></td>
			<td class="separator">&nbsp;</td>
			<td><%
			Select Case max_generation
			Case -1
				response.write(langEditor.getTranslated("backend.voucher.label.unlimited"))
			Case Else
				response.write(max_generation)
			End Select
			%></td>
			<td class="separator">&nbsp;</td>
			<td><%
			Select Case max_usage
			Case -1
				response.write(langEditor.getTranslated("backend.voucher.label.unlimited"))
			Case Else
				response.write(max_usage)
			End Select
			%></td>		
			</tr>		
			<tr>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.enable_date")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.expire_date")%></th>
			<td class="separator">&nbsp;</td>
			<th><%=langEditor.getTranslated("backend.voucher.lista.table.header.exclude_prod_rule")%></th>
			</tr>		
			<tr>
			<td>
			<%if(enable_date<>"")then
				response.write(FormatDateTime(enable_date,2)&" "&FormatDateTime(enable_date,vbshorttime))
			end if%>			
			</td>
			<td class="separator">&nbsp;</td>
			<td>
			<%if(expire_date<>"")then
				response.write(FormatDateTime(expire_date,2)&" "&FormatDateTime(expire_date,vbshorttime))
			end if%>	
			</td>
			<td class="separator">&nbsp;</td>
			<td><%
			Select Case exclude_prod_rule
			Case 0
				response.write(langEditor.getTranslated("backend.commons.no"))
			Case 1
				response.write(langEditor.getTranslated("backend.commons.yes"))
			Case Else
			End Select
			%></td>			
			</tr>
		</table><br/>

		<%
		if(request("error_message")<>"") then			
			response.write("<span class=error-text>"&request("error_message")&"</span><br/><br/>")
		end if
		if(request("id_new_code")<>"") then			
			response.write("<span class=message-text>"&langEditor.getTranslated("backend.voucher.label.new_voucher_code")&request("id_new_code")&"</span><br/><br/>")
		end if
		%>
		
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		      <tr> 
			<th>&nbsp;</th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.table.header.voucher_code"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.table.header.insert_date"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.table.header.usage_counter"))%></th>
			<th><%=UCase(langEditor.getTranslated("backend.voucher.table.header.id_user_ref"))%></th>
		      </tr> 
				<%
				Dim hasVoucherCode
				hasVoucherCode = false
				on error Resume Next
				Set objListaVoucher = objVoucher.getListaVoucherCode(id_voucher)
				
				if(objListaVoucher.Count > 0) then
					hasVoucherCode = true
				end if
					
				if Err.number <> 0 then
					hasVoucherCode = false
				end if	
				
				if(hasVoucherCode) then				
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpVoucher, objTmpVoucherKey, FromVoucher, ToVoucher, Diff
					iIndex = objListaVoucher.Count
					FromVoucher = ((numPage * itemsXpage) - itemsXpage)
					Diff = (iIndex - ((numPage * itemsXpage)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToVoucher = iIndex - Diff
					
					totPages = iIndex\itemsXpage
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpage <> 0) AND not ((totPages * itemsXpage) >= iIndex)) then
						totPages = totPages +1	
					end if		
					
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"			
											
					objTmpVoucher = objListaVoucher.Items
					objTmpVoucherKey=objListaVoucher.Keys		
					for newsCounter = FromVoucher to ToVoucher
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>	
					<tr class="<%=styleRow%>" id="tr_delete_list_<%=intCount%>">
						<%
						Set objTmpVoucher0 = objTmpVoucher(newsCounter)
						%>
						<td align="center" width="25"><a href="javascript:deleteVoucherCode(<%=objTmpVoucherKey(newsCounter)%>, 'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.voucher.lista.table.alt.delete_voucher")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="20%"><%=objTmpVoucher0.getVoucherCode()%></td>
						<td width="20%">
						<%if(objTmpVoucher0.getInsertDate()<>"")then
							response.write(FormatDateTime(objTmpVoucher0.getInsertDate(),2)&" "&FormatDateTime(objTmpVoucher0.getInsertDate(),vbshorttime))
						end if%>
						</td>
						<td width="10%"><%=objTmpVoucher0.getUsageCounter()%></td>
						<td><%
						if(objTmpVoucher0.getIdUserRef()<>"")then
							On Error Resume Next
							response.write(objUserLoggedTmp.findUserByIDExt(objTmpVoucher0.getIdUserRef(), false).getUserName())
							if(Err.number<>0)then							
							end if
						end if
						%></td>												
					</tr>		
					<%intCount = intCount +1
					next
					Set objListaVoucher = nothing
					Set objVoucher = Nothing
					%>
				<tr> 
				<form action="<%=Application("baseroot") & "/editor/voucher/visualizzavoucher.asp"%>" method="post" name="item_x_page">
				<th colspan="5">
				<input type="hidden" value="<%=id_voucher%>" name="id_voucher">
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				<%		
				'**************** richiamo paginazione
				call PaginazioneFrontend(totPages, numPage, strGerarchia, "/editor/voucher/visualizzavoucher.asp", "&items="&itemsXpage&"&id_voucher="&id_voucher)
				%>
				</th>
				</form>
				</tr>
			<%end if%>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/voucher/processvouchercode.asp"%>" method="post" name="form_crea">
		<input type="hidden" value="LVC" name="cssClass">	
		<input type="hidden" value="<%=id_voucher%>" name="id_voucher">		
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.voucher.lista.button.label.generate_code")%>" onclick="javascript:generateVoucherCode();" />
		<%if(voucher_type="4")then%>
		  <select name="id_user_ref" class="formFieldSelect">
		  <option value=""></option>
		  <%
		  Dim objListaUtenti
		  hasUserList = false
		  On Error Resume Next		  
		  Set objListaUtenti = objUserLoggedTmp.findUtente(null, 3, 1, null, 0, null)
		  if(objListaUtenti.count>0)then
			hasUserList = true
		  end if
		  if(Err.number<>0)then
		  hasUserList = false
		  end if
		  
		  if(hasUserList)then
		  for each y in objListaUtenti.Keys%>		  
		  <option value="<%=y%>"><%=objListaUtenti(y).getUserName()%></option>
		  <%next
		  end if%>
		  </select>		
		<%end if%>
		</form>
		<br/>
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='<%=Application("baseroot")&"/editor/voucher/ListaVoucher.asp?cssClass=LVC"%>';" />
		<br/><br/>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>
<%Set objVoucher = nothing
Set objUserLoggedTmp = nothing%>