<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/editor/include/Paginazione.inc" -->
<!-- #include file="include/init.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!-- #include virtual="/editor/include/initCommonMeta.inc" -->
<!-- #include virtual="/editor/include/initCommonJs.inc" -->
<script language="JavaScript">
function deleteMargine(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.margini.lista.js.alert.delete_margine")%>?")){
		ajaxDeleteItem(id_objref,"margin",row,refreshrows);
	}
}
function deleteGroup(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.margini.lista.js.alert.delete_group")%>?")){
		ajaxDeleteItem(id_objref,"margin_group",row,refreshrows);
	}
}
function deleteRule(id_objref,row,refreshrows){
	if(confirm("<%=langEditor.getTranslated("backend.margini.lista.js.alert.delete_rule")%>?")){
		ajaxDeleteItem(id_objref,"business_rule",row,refreshrows);
	}
}

function showHideDivMarginGroup(element){
	var elementGr = document.getElementById("usrgroup");
	var elementaGr = document.getElementById("ausrgroup");
	var elementMr = document.getElementById("margindiscount");
	var elementaMr = document.getElementById("amargindiscount");
	var elementRl = document.getElementById("businessrules");
	var elementaRl = document.getElementById("abusinessrules");

	if(element == 'margindiscount'){
		elementGr.style.visibility = 'hidden';
		elementGr.style.display = "none";
		elementaGr.className= "";
		elementRl.style.visibility = 'hidden';
		elementRl.style.display = "none";
		elementaRl.className= "";
		elementMr.style.visibility = 'visible';		
		elementMr.style.display = "block";
		elementaMr.className= "active";
	}else if(element == 'usrgroup'){
		elementMr.style.visibility = 'hidden';		
		elementMr.style.display = "none";
		elementaMr.className= "";
		elementRl.style.visibility = 'hidden';
		elementRl.style.display = "none";
		elementaRl.className= "";
		elementGr.style.visibility = 'visible';
		elementGr.style.display = "block";
		elementaGr.className= "active";
	}else if(element == 'businessrules'){
		elementMr.style.visibility = 'hidden';		
		elementMr.style.display = "none";
		elementaMr.className= "";
		elementGr.style.visibility = 'hidden';
		elementGr.style.display = "none";
		elementaGr.className= "";
		elementRl.style.visibility = 'visible';
		elementRl.style.display = "block";
		elementaRl.className= "active";
	}
}
</script>
</head>
<body onLoad="showHideDivMarginGroup('<%=showTab%>')">
<div id="backend-warp">
	<!-- #include virtual="/editor/include/header.inc" -->	
	<div id="container">
		<%cssClass="LM"%>
		<!-- #include virtual="/editor/include/menu.inc" -->
		<div id="backend-content">
		<%
		if(request("err")="1") then			
			response.write("<span class=error-text>"&langEditor.getTranslated("backend.margini.lista.table.error.default_exist")&"</span><br/><br/>")
		end if
		%>
		
		<div id="tab-margin-group"><a id="ausrgroup" <%if(showtab="usrgroup")then response.write("class=active") end if%> href="javascript:showHideDivMarginGroup('usrgroup');"><%=langEditor.getTranslated("backend.margini.lista.table.header.label_group")%></a><a id="amargindiscount" <%if(showtab="margindiscount")then response.write("class=active") end if%> href="javascript:showHideDivMarginGroup('margindiscount');"><%=langEditor.getTranslated("backend.margini.lista.table.header.label_margini")%></a><a id="abusinessrules" <%if(showtab="businessrules")then response.write("class=active") end if%> href="javascript:showHideDivMarginGroup('businessrules');"><%=langEditor.getTranslated("backend.margini.lista.table.header.label_rules")%></a></div>
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<div id="usrgroup" style="visibility:visible;display:block;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.short_desc"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.long_desc"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.taxs_group"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.default"))%></th>
			</tr> 
				<%
				On Error Resume Next
				Dim hasGroup
				hasGroup = false
				Set objListaGroup = objGroup.getListaUserGroup()
				hasGroup = true				
				
				if Err.number <> 0 then
					hasGroup = false
				end if
				
				if(hasGroup) then			
					Dim intCount
					intCount = 0
					
					Dim newsCounter, iIndex, objTmpGroup, objTmpGroupKey, FromCurr, ToCurr, Diff
					iIndex = objListaGroup.Count
					FromCurr = ((numPageGroup * itemsXpageGroup) - itemsXpageGroup)
					Diff = (iIndex - ((numPageGroup * itemsXpageGroup)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToCurr = iIndex - Diff
					
					totPages = iIndex\itemsXpageGroup
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageGroup <> 0) AND not ((totPages * itemsXpageGroup) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					Dim styleRow, styleRow2
					styleRow2 = "table-list-on"							
							
					objTmpGroup = objListaGroup.Items
					objTmpGroupKey=objListaGroup.Keys	
					for newsCounter = FromCurr to ToCurr
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/margini/InserisciGroup.asp"%>" method="post" name="form_group_<%=intCount%>">
						<input type="hidden" value="<%=objTmpGroupKey(newsCounter)%>" name="id_group">
						<input type="hidden" value="" name="delete_group">
						<input type="hidden" value="LM" name="cssClass">						
						</form> 
						<tr class="<%=styleRow%>" id="tr_delete_group_list_<%=intCount%>">
						<%Set objTmpGroup0 = objTmpGroup(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_group_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.modify_group")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteGroup(<%=objTmpGroupKey(newsCounter)%>, 'tr_delete_group_list_<%=intCount%>','tr_delete_group_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.delete_group")%>" hspace="2" vspace="0" border="0"></a></td>						
						<td width="20%">						
						<div class="ajax" id="view_short_desc_<%=intCount%>" onMouseOver="javascript:showHide('view_short_desc_<%=intCount%>','edit_short_desc_<%=intCount%>','short_desc_<%=intCount%>',500, false);"><%=objTmpGroup0.getShortDesc()%></div>
						<div class="ajax" id="edit_short_desc_<%=intCount%>"><input type="text" class="formfieldAjax" id="short_desc_<%=intCount%>" name="short_desc" onMouseOut="javascript:restoreField('edit_short_desc_<%=intCount%>','view_short_desc_<%=intCount%>','short_desc_<%=intCount%>','margin_group',<%=objTmpGroup0.getID()%>,1,<%=intCount%>);" value="<%=objTmpGroup0.getShortDesc()%>"></div>
						<script>
						$("#edit_short_desc_<%=intCount%>").hide();
						</script>
						</td>
						<td width="40%">						
						<div class="ajax" id="view_long_desc_<%=intCount%>" onMouseOver="javascript:showHide('view_long_desc_<%=intCount%>','edit_long_desc_<%=intCount%>','long_desc_<%=intCount%>',500, false);"><%=objTmpGroup0.getLongDesc()%></div>
						<div class="ajax" id="edit_long_desc_<%=intCount%>"><textarea class="formfieldAjaxArea" id="long_desc_<%=intCount%>" name="long_desc" onMouseOut="javascript:restoreField('edit_long_desc_<%=intCount%>','view_long_desc_<%=intCount%>','long_desc_<%=intCount%>','margin_group',<%=objTmpGroup0.getID()%>,1,<%=intCount%>);"><%=objTmpGroup0.getLongDesc()%></textarea></div>
						<script>
						$("#edit_long_desc_<%=intCount%>").hide();
						</script>
						</td>						
						<td width="20%">
						<div class="ajax" id="view_taxs_group_<%=intCount%>" onMouseOver="javascript:showHide('view_taxs_group_<%=intCount%>','edit_taxs_group_<%=intCount%>','taxs_group_<%=intCount%>',500, true);">
						<%
						Dim taxsG, objTaxGroup
						Set objTaxGroup = new TaxsGroupClass
						On Error resume Next
						Set taxsG = objTaxGroup.getGroupByID(objTmpGroup0.getTaxGroup())
						response.Write(taxsG.getGroupDescription())
						Set taxsG = nothing
						if(Err.number <> 0)then
						end if
						%>
						</div>
						<div class="ajax" id="edit_taxs_group_<%=intCount%>">
						<select name="taxs_group" class="formfieldAjaxSelect" id="taxs_group_<%=intCount%>" onBlur="javascript:updateField('edit_taxs_group_<%=intCount%>','view_taxs_group_<%=intCount%>','taxs_group_<%=intCount%>','margin_group',<%=objTmpGroup0.getID()%>,2,<%=intCount%>);">
						  <option value=""></option>
							<%							
							Dim objListaTaxGroup, objGroupT
							On Error Resume Next
							Set objListaTaxGroup = objTaxGroup.getListaTaxsGroup(null)
							if not (isNull(objListaTaxGroup)) then
								for each y in objListaTaxGroup.Keys
									Set objGroupT = objListaTaxGroup(y)%>
									<option value="<%=y%>" <%if (objTmpGroup0.getTaxGroup() = y) then response.write("selected") end if%>><%=objGroupT.getGroupDescription()%></option>	
								<%	Set objGroupT = nothing
								next
							end if		
							Set objListaTaxGroup = nothing
							if(Err.number<>0)then
							end if					
							%>	  
						</select>
						</div>
						<script>
						$("#edit_taxs_group_<%=intCount%>").hide();
						</script>
						<%Set objTaxGroup = nothing%>
						</td>
						<td><%if(objTmpGroup0.isDefault()=0)then response.write(langEditor.getTranslated("backend.commons.no")) else response.write(langEditor.getTranslated("backend.commons.yes")) end if%></td>
						</tr>				
						<%						
						Set objTmpGroup0 = nothing
						intCount = intCount +1
					next
					Set objListaGroup = nothing		
				end if
				%>
              <tr> 
			<form action="<%=Application("baseroot") & "/editor/margini/ListaMargini.asp"%>" method="post" name="item_x_page_group">
			<input type="hidden" value="usrgroup" name="showtab">
			<th colspan="6" align="left">
			<input type="text" name="itemsGroup" class="formFieldTXTNumXPage" value="<%=itemsXpageGroup%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onBlur="javascript:submit();" onKeyPress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPageGroup, strGerarchia, "/editor/margini/ListaMargini.asp", "&itemsGroup="&itemsXpageGroup&"&showtab=usrgroup")
			%>
			</th>
			</form>
              </tr>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/margini/InserisciGroup.asp"%>" method="post" name="form_group">
		<input type="hidden" value="LM" name="cssClass">	
		<input type="hidden" value="-1" name="id_group">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.lista.button.label.inserisci_group")%>" onClick="javascript:document.form_group.submit();" />	
		</form>
		</div>
		
		<div id="margindiscount" style="visibility:hidden;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
              <tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.margine"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.discount"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.prod_discount"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.user_discount"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.group"))%></th>
              </tr> 
				<%
				On Error Resume Next
				Dim hasMargine
				hasMargine = false
				Set objListaMargini = objMargini.getListaMarginDiscount()
				hasMargine = true				
				
				if Err.number <> 0 then
					hasMargine = false
				end if
				
				if(hasMargine) then			
					'Dim intCount
					intCount = 0
					
					'Dim newsCounter, iIndex, objTmpMargine, objTmpMargineKey, FromCurr, ToCurr, Diff
					Dim objTmpMargine, objTmpMargineKey
					iIndex = objListaMargini.Count
					FromCurr = ((numPageMargin * itemsXpageMargin) - itemsXpageMargin)
					Diff = (iIndex - ((numPageMargin * itemsXpageMargin)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToCurr = iIndex - Diff
					
					totPages = iIndex\itemsXpageMargin
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageMargin <> 0) AND not ((totPages * itemsXpageMargin) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					'Dim styleRow, styleRow2
					styleRow2 = "table-list-on"							
							
					objTmpMargine = objListaMargini.Items
					objTmpMargineKey=objListaMargini.Keys	
					for newsCounter = FromCurr to ToCurr
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/margini/InserisciMargine.asp"%>" method="post" name="form_margin_<%=intCount%>">
						<input type="hidden" value="<%=objTmpMargineKey(newsCounter)%>" name="id_margine">
						<input type="hidden" value="" name="delete_margine">
						<input type="hidden" value="LM" name="cssClass">
						</form> 	
						<tr class="<%=styleRow%>" id="tr_delete_margine_list_<%=intCount%>">
						<%Set objTmpMargine0 = objTmpMargine(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_margin_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.modify_margine")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteMargine(<%=objTmpMargineKey(newsCounter)%>, 'tr_delete_margine_list_<%=intCount%>','tr_delete_margine_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.delete_margine")%>" hspace="2" vspace="0" border="0"></a></td>						
						<td width="15%">
						<div class="ajax" style="float:left" id="view_margine_<%=intCount%>" onMouseOver="javascript:showHide('view_margine_<%=intCount%>','edit_margine_<%=intCount%>','margine_<%=intCount%>',500, false);"><%=FormatNumber(objTmpMargine0.getMargin(),2,-1)%></div>
						<div class="ajax" style="float:left" id="edit_margine_<%=intCount%>"><input type="text" align="absmiddle" class="formfieldAjaxShort2" id="margine_<%=intCount%>" name="margine" onMouseOut="javascript:restoreField('edit_margine_<%=intCount%>','view_margine_<%=intCount%>','margine_<%=intCount%>','margin',<%=objTmpMargine0.getID()%>,1,<%=intCount%>);" value="<%=FormatNumber(objTmpMargine0.getMargin(),2,-1)%>"></div>
						<div>%</div>
						<script>
						$("#edit_margine_<%=intCount%>").hide();
						</script>
						</td>
						<td width="15%">						
						<div class="ajax" style="float:left" id="view_discount_<%=intCount%>" onMouseOver="javascript:showHide('view_discount_<%=intCount%>','edit_discount_<%=intCount%>','discount_<%=intCount%>',500, false);"><%=FormatNumber(objTmpMargine0.getDiscount(),2,-1)%></div>
						<div class="ajax" style="float:left" id="edit_discount_<%=intCount%>"><input type="text" class="formfieldAjaxShort2" id="discount_<%=intCount%>" name="discount" onMouseOut="javascript:restoreField('edit_discount_<%=intCount%>','view_discount_<%=intCount%>','discount_<%=intCount%>','margin',<%=objTmpMargine0.getID()%>,1,<%=intCount%>);" value="<%=FormatNumber(objTmpMargine0.getDiscount(),2,-1)%>"></div>
						<div>%</div>
						<script>
						$("#edit_discount_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_prod_disc_<%=intCount%>" onMouseOver="javascript:showHide('view_prod_disc_<%=intCount%>','edit_prod_disc_<%=intCount%>','prod_disc_<%=intCount%>',500, true);">
						<%
						Select Case objTmpMargine0.isApplyProdDiscount()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_prod_disc_<%=intCount%>">
						<select name="prod_disc" class="formfieldAjaxSelect" id="prod_disc_<%=intCount%>" onBlur="javascript:updateField('edit_prod_disc_<%=intCount%>','view_prod_disc_<%=intCount%>','prod_disc_<%=intCount%>','margin',<%=objTmpMargine0.getID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpMargine0.isApplyProdDiscount(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpMargine0.isApplyProdDiscount(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_prod_disc_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_user_disc_<%=intCount%>" onMouseOver="javascript:showHide('view_user_disc_<%=intCount%>','edit_user_disc_<%=intCount%>','user_disc_<%=intCount%>',500, true);">
						<%
						Select Case objTmpMargine0.isApplyUserDiscount()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_user_disc_<%=intCount%>">
						<select name="user_disc" class="formfieldAjaxSelect" id="user_disc_<%=intCount%>" onBlur="javascript:updateField('edit_user_disc_<%=intCount%>','view_user_disc_<%=intCount%>','user_disc_<%=intCount%>','margin',<%=objTmpMargine0.getID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpMargine0.isApplyUserDiscount(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpMargine0.isApplyUserDiscount(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_user_disc_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<%
						On Error Resume Next
						Set objGroupMargin = objGroup.getUserGroupXMarginDiscount(objTmpMargineKey(newsCounter))
						for each z in objGroupMargin
							response.write(objGroupMargin(z).getShortDesc()&"<br/>")
						next
						Set objGroupMargin = nothing
						if(Err-number<>0)then
						end if
						%>
						</td>               
						</tr>			
						<%						
						Set objTmpMargine0 = nothing
						intCount = intCount +1
					next
					Set objListaMargini = nothing		
				end if
				%>
              <tr> 
			<form action="<%=Application("baseroot") & "/editor/margini/ListaMargini.asp"%>" method="post" name="item_x_page">
			<input type="hidden" value="margindiscount" name="showtab">
			<th colspan="7" align="left">
			<input type="text" name="itemsMargin" class="formFieldTXTNumXPage" value="<%=itemsXpageMargin%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onBlur="javascript:submit();" onKeyPress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPageMargin, strGerarchia, "/editor/margini/ListaMargini.asp", "&itemsMargin="&itemsXpageMargin&"&showtab=margindiscount")
			%>
			</th>
			</form>
              </tr>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/margini/InserisciMargine.asp"%>" method="post" name="form_crea_margin">
		<input type="hidden" value="LM" name="cssClass">	
		<input type="hidden" value="-1" name="id_margine">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.lista.button.label.inserisci")%>" onClick="javascript:document.form_crea_margin.submit();" />	
		</form>
		</div>
		
		<div id="businessrules" style="visibility:hidden;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
				  <th colspan="2">&nbsp;</th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.rule_type"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.rule_label"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.rule_desc"))%></th>
				  <th><%=UCase(langEditor.getTranslated("backend.margini.lista.table.header.rule_active"))%></th>
			</tr> 
				<%
				On Error Resume Next
				Dim hasRules
				hasRules = false
				Set objListaRules = objRules.getListaRules(null,null)
				hasRules = true				
				
				if Err.number <> 0 then
					hasRules = false
				end if
				
				if(hasRules) then	
					intCount = 0
					
					Dim objTmpRule, objTmpRuleKey
					iIndex = objListaRules.Count
					FromCurr = ((numPageRules * itemsXpageRules) - itemsXpageRules)
					Diff = (iIndex - ((numPageRules * itemsXpageRules)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToCurr = iIndex - Diff
					
					totPages = iIndex\itemsXpageRules
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD itemsXpageRules <> 0) AND not ((totPages * itemsXpageRules) >= iIndex)) then
						totPages = totPages +1	
					end if		
				
					styleRow2 = "table-list-on"							
							
					objTmpRule = objListaRules.Items
					objTmpRuleKey=objListaRules.Keys	
					for newsCounter = FromCurr to ToCurr
						styleRow = "table-list-off"
						if(newsCounter MOD 2 = 0) then styleRow = styleRow2 end if%>
						<form action="<%=Application("baseroot") & "/editor/margini/InserisciRule.asp"%>" method="post" name="form_rule_<%=intCount%>">
						<input type="hidden" value="<%=objTmpRuleKey(newsCounter)%>" name="id_rule">
						<input type="hidden" value="" name="delete_rule">
						<input type="hidden" value="LM" name="cssClass">
						</form> 	
						<tr class="<%=styleRow%>" id="tr_delete_rule_list_<%=intCount%>">
						<%Set objTmpRule0 = objTmpRule(newsCounter)%>	
						<td align="center" width="25"><a href="javascript:document.form_rule_<%=intCount%>.submit();"><img src="<%=Application("baseroot")&"/editor/img/pencil.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.modify_rule")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteRule(<%=objTmpRuleKey(newsCounter)%>, 'tr_delete_rule_list_<%=intCount%>','tr_delete_rule_list_');"><img src="<%=Application("baseroot")&"/editor/img/cancel.png"%>" alt="<%=langEditor.getTranslated("backend.margini.lista.table.alt.delete_rule")%>" hspace="2" vspace="0" border="0"></a></td>						
						<td width="25%">
						<%
						Select Case objTmpRule0.getRuleType()
						Case 1
							response.write(langEditor.getTranslated("backend.margini.label.amount_order_rule"))
						Case 2
							response.write(langEditor.getTranslated("backend.margini.label.percentage_order_rule"))
						Case 3
							response.write(langEditor.getTranslated("backend.margini.label.voucher_order_rule"))
						Case 4
							response.write(langEditor.getTranslated("backend.margini.label.first_amount_order_rule"))
						Case 5
							response.write(langEditor.getTranslated("backend.margini.label.first_percentage_order_rule"))
						Case 6
							response.write(langEditor.getTranslated("backend.margini.label.amount_qta_product_rule"))
						Case 7
							response.write(langEditor.getTranslated("backend.margini.label.percentage_qta_product_rule"))
						Case 8
							response.write(langEditor.getTranslated("backend.margini.label.amount_related_product_rule"))
						Case 9
							response.write(langEditor.getTranslated("backend.margini.label.percentage_related_product_rule"))
						Case 10
							response.write(langEditor.getTranslated("backend.margini.label.exclude_bills_product_rule"))
						Case Else
						End Select%>							
						</td>
						<td width="17%">
						<div class="ajax" id="view_label_<%=intCount%>" onmouseover="javascript:showHide('view_label_<%=intCount%>','edit_label_<%=intCount%>','label_<%=intCount%>',500, false);"><%=objTmpRule0.getLabel()%></div>
						<div class="ajax" id="edit_label_<%=intCount%>"><input type="text" class="formfieldAjax" id="label_<%=intCount%>" name="label" onmouseout="javascript:restoreField('edit_label_<%=intCount%>','view_label_<%=intCount%>','label_<%=intCount%>','business_rule',<%=objTmpRule0.getID()%>,1,<%=intCount%>);" value="<%=objTmpRule0.getLabel()%>"></div>
						<script>
						$("#edit_label_<%=intCount%>").hide();
						</script>
						</td>
						<td width="30%">
						<div class="ajax" id="view_descrizione_<%=intCount%>" onmouseover="javascript:showHide('view_descrizione_<%=intCount%>','edit_descrizione_<%=intCount%>','descrizione_<%=intCount%>',500, false);"><%=objTmpRule0.getDescrizione()%></div>
						<div class="ajax" id="edit_descrizione_<%=intCount%>"><textarea class="formfieldAjaxAreaMedium" id="descrizione_<%=intCount%>" name="descrizione" onMouseOut="javascript:restoreField('edit_descrizione_<%=intCount%>','view_descrizione_<%=intCount%>','descrizione_<%=intCount%>','business_rule',<%=objTmpRule0.getID()%>,1,<%=intCount%>);"><%=objTmpRule0.getDescrizione()%></textarea></div>
						<script>
						$("#edit_descrizione_<%=intCount%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_activate_<%=intCount%>" onMouseOver="javascript:showHide('view_activate_<%=intCount%>','edit_activate_<%=intCount%>','activate_<%=intCount%>',500, true);">
						<%
						Select Case objTmpRule0.getActivate()
						Case 0
							response.write(langEditor.getTranslated("backend.commons.no"))
						Case 1
							response.write(langEditor.getTranslated("backend.commons.yes"))
						Case Else
						End Select%>
						</div>
						<div class="ajax" id="edit_activate_<%=intCount%>">
						<select name="activate" class="formfieldAjaxSelect" id="activate_<%=intCount%>" onBlur="javascript:updateField('edit_activate_<%=intCount%>','view_activate_<%=intCount%>','activate_<%=intCount%>','business_rule',<%=objTmpRule0.getID()%>,2,<%=intCount%>);">
						<OPTION VALUE="0" <%if (strComp("0", objTmpRule0.getActivate(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (strComp("1", objTmpRule0.getActivate(), 1) = 0) then response.Write("selected")%>><%=langEditor.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_activate_<%=intCount%>").hide();
						</script>
						</td>               
						</tr>			
						<%						
						Set objTmpRule0 = nothing
						intCount = intCount +1
					next
					Set objListaRules = nothing		
				end if
				%>
              <tr> 
			<form action="<%=Application("baseroot") & "/editor/margini/ListaMargini.asp"%>" method="post" name="item_x_page">
			<input type="hidden" value="businessrules" name="showtab">
			<th colspan="7" align="left">
			<input type="text" name="itemsRules" class="formFieldTXTNumXPage" value="<%=itemsXpageRules%>" title="<%=langEditor.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onBlur="javascript:submit();" onKeyPress="javascript:return isInteger(event);">
			<%		
			'**************** richiamo paginazione
			call PaginazioneFrontend(totPages, numPageRules, strGerarchia, "/editor/margini/ListaMargini.asp", "&itemsRules="&itemsXpageRules&"&showtab=businessrules")
			%>
			</th>
			</form>
              </tr>
		</table>
		<br/>	
		<form action="<%=Application("baseroot") & "/editor/margini/InserisciRule.asp"%>" method="post" name="form_crea_rule">
		<input type="hidden" value="LM" name="cssClass">	
		<input type="hidden" value="-1" name="id_rule">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=langEditor.getTranslated("backend.margini.lista.button.label.inserisci_rule")%>" onClick="javascript:document.form_crea_rule.submit();" />	
		</form>
		</div>
		<%
		Set objRules = nothing
		Set objGroup = Nothing
		Set objMargini = Nothing
		%>
		</div>
	</div>
	<!-- #include virtual="/editor/include/bottom.inc" -->
</div>
</body>
</html>