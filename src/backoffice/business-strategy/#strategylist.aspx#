<%@ Page Language="C#" AutoEventWireup="true" CodeFile="strategylist.aspx.cs" Inherits="_StrategyList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script>
function editGroup(id){
	location.href='/backoffice/business-strategy/insertugroup.aspx?cssClass=LM&id_group='+id;
}

function deleteGroup(id_objref, row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.margini.lista.js.alert.delete_group")%>")){	
		ajaxDeleteItem(id_objref,"UserGroup||IUserRepository|deleteUserGroup|public|"+id_objref,row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
	}
}

function deleteRule(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.margini.lista.js.alert.delete_rule")%>")){
		ajaxDeleteItem(id_objref,"BusinessRule|IBusinessRuleRepository",row,refreshrows);
		$('#tr_preview_row_'+row.substring(row.indexOf("tr_preview_row_")+16)).hide();
	}
}

function showHideDivBusinessStrategy(element){
	var elementUl = document.getElementById("ugrouplist");
	var elementaUl = document.getElementById("augrouplist");
	var elementUf = document.getElementById("businessrulelist");
	var elementaUf = document.getElementById("abusinessrulelist");

	if(element == 'ugrouplist'){
		elementUf.style.visibility = 'hidden';		
		elementUf.style.display = "none";
		elementaUf.className= "";
		elementUl.style.visibility = 'visible';
		elementUl.style.display = "block";
		elementaUl.className= "active";
	}else if(element == 'businessrulelist'){
		elementUl.style.visibility = 'hidden';
		elementUl.style.display = "none";
		elementaUl.className= "";
		elementUf.style.visibility = 'visible';		
		elementUf.style.display = "block";
		elementaUf.className= "active";
	}
}

jQuery(document).ready(function(){
	showHideDivBusinessStrategy('<%=showTab%>'); 
})
</SCRIPT>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		
		<%if("1".Equals(Request["err"])) {%>			
			<span class="error-text"><%=lang.getTranslated("backend.margini.lista.table.error.default_exist")%></span><br/><br/>
		<%}%>
		
		<div id="tab-margin-group"><a id="augrouplist" <%if(showTab=="ugrouplist"){ Response.Write("class=active");}%> href="javascript:showHideDivBusinessStrategy('ugrouplist');"><%=lang.getTranslated("backend.margini.lista.table.header.label_group")%></a><a id="abusinessrulelist" <%if(showTab=="businessrulelist"){Response.Write("class=active");}%> href="javascript:showHideDivBusinessStrategy('businessrulelist');"><%=lang.getTranslated("backend.margini.lista.table.header.label_rules")%></a></div>
		<div id="ugrouplist" style="visibility:hidden;margin:0px;padding:0px;">

			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<div id="contenutilist" style="visibility:visible;display:block;margin:0px;padding:0px;">
				<table border="0" cellpadding="0" cellspacing="0" class="principal">
					<tr> 
						<th colspan="6" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">	
						<input type="hidden" value="ugrouplist" name="showtab">
						<input type="text" name="itemsUGroup" class="formFieldTXTNumXPage" value="<%=itemsXpageUGroup%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
						</div>
						</th>
					</tr>

				      <tr> 
					<th colspan="2">&nbsp;</td>
					<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.short_desc" runat="server" /></th>
					<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.long_desc" runat="server" /></th>
					<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.taxs_group" runat="server" /></th>
					<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.default" runat="server" /></th>
				      </tr>
					  
						<%
						int intCount = 0;				
						if(bolFoundUGroup){
							for(intCount = fromUGroups; intCount<= toUGroups;intCount++){
								UserGroup k = userGroups[intCount];%>							
								<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
								<td align="center" width="25"><a href="javascript:editGroup('<%=k.id%>');"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.margini.lista.table.alt.modify_group")%>" hspace="2" vspace="0" border="0"></a></td>
								<td align="center" width="25"><a href="javascript:deleteGroup(<%=k.id%>,'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.margini.lista.table.alt.delete_group")%>" hspace="2" vspace="0" border="0"></a></td>
								<td nowrap width="20%">		
								<div class="ajax" id="view_short_desc_<%=intCount%>" onMouseOver="javascript:showHide('view_short_desc_<%=intCount%>','edit_short_desc_<%=intCount%>','short_desc_<%=intCount%>',500, false);"><%=k.shortDesc%></div>
								<div class="ajax" id="edit_short_desc_<%=intCount%>"><input type="text" class="formfieldAjax" id="short_desc_<%=intCount%>" name="shortDesc" onMouseOut="javascript:restoreField('edit_short_desc_<%=intCount%>','view_short_desc_<%=intCount%>','short_desc_<%=intCount%>','UserGroup|IUserRepository|string|getUserGroupById|updateUserGroup',<%=k.id%>,1,<%=intCount%>);" value="<%=k.shortDesc%>"></div>
								<script>
								$("#edit_short_desc_<%=intCount%>").hide();
								</script>
								</td>							
								<td nowrap width="40%">
								<div class="ajax" id="view_long_desc_<%=intCount%>" onMouseOver="javascript:showHide('view_long_desc_<%=intCount%>','edit_long_desc_<%=intCount%>','long_desc_<%=intCount%>',500, false);"><%=k.longDesc%></div>
								<div class="ajax" id="edit_long_desc_<%=intCount%>"><textarea class="formfieldAjaxArea" id="long_desc_<%=intCount%>" name="longDesc" onMouseOut="javascript:restoreField('edit_long_desc_<%=intCount%>','view_long_desc_<%=intCount%>','long_desc_<%=intCount%>','UserGroup|IUserRepository|string|getUserGroupById|updateUserGroup',<%=k.id%>,1,<%=intCount%>);"><%=k.longDesc%></textarea></div>
								<script>
								$("#edit_long_desc_<%=intCount%>").hide();
								</script>
								</td>
								<td width="20%">
								<%								
								string supDesc = "";
								StringBuilder supOptions = new StringBuilder();	
								foreach (SupplementGroup x in supplements){
									supOptions.Append("<option value=\"").Append(x.id).Append("\"");
									if(k.supplementGroup != null && k.supplementGroup>0 && k.supplementGroup==x.id){
										supDesc = x.description;
										supOptions.Append(" selected");
									}
									supOptions.Append(">").Append(x.description).Append("</option>");
								}			
								%>								
								<div class="ajax" id="view_id_supplement_<%=intCount%>" onmouseover="javascript:showHide('view_id_supplement_<%=intCount%>','edit_id_supplement_<%=intCount%>','id_supplement_<%=intCount%>',500, true);"><%=supDesc%></div>
								<div class="ajax" id="edit_id_supplement_<%=intCount%>">
								<select name="supplementGroup" class="formfieldAjaxSelect" id="id_supplement_<%=intCount%>" onblur="javascript:updateField('edit_id_supplement_<%=intCount%>','view_id_supplement_<%=intCount%>','id_supplement_<%=intCount%>','UserGroup|IUserRepository|int|getUserGroupById|updateUserGroup',<%=k.id%>,2,<%=intCount%>);">
									<option value=""></option>
									<%=supOptions.ToString()%>	  
								</select>
								</div>
								<script>
								$("#edit_id_supplement_<%=intCount%>").hide();
								</script>	
								</td>
								<td><%if(!k.defaultGroup){Response.Write(lang.getTranslated("backend.commons.no"));}else{Response.Write(lang.getTranslated("backend.commons.yes"));}%></td>
								</tr>
								<%
							}
						}
						%>
					
					<tr> 
						<th colspan="6" align="left">
						<div style="float:left;padding-right:3px;height:15px;">
						<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="hidden" value="1" name="page">
						<input type="hidden" value="ugrouplist" name="showtab">	
						<input type="text" name="itemsUGroup" class="formFieldTXTNumXPage" value="<%=itemsXpageUGroup%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
						</form>
						</div>
						<div style="height:15px;">
						<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
						</div>
						</th>
					</tr>			
				</table>
				<br/>
				<div style="float:left;">
					<form action="/backoffice/business-strategy/insertugroup.aspx" method="post" name="form_crea">
						<input type="hidden" value="-1" name="id_group">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">	
						<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.margini.lista.button.label.inserisci_group")%>" onclick="javascript:document.form_crea.submit();" />
					</form>
				</div>
			</div>
			
			</div>
			
			<div id="businessrulelist" style="visibility:hidden;">

			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
			<th colspan="6" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="businessrulelist" name="showtab">
			<input type="text" name="itemsRule" class="formFieldTXTNumXPage" value="<%=itemsXpageRule%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg3" runat="server" index="3" maxVisiblePages="10" />
			</div>
			</th>
			<tr> 
				<th colspan="2">&nbsp;</th>
				<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.rule_type" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.rule_label" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.rule_desc" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.margini.lista.table.header.rule_active" runat="server" /></th>
			</tr>
				<%						
				int fcounter = 0;				
				if(bolFoundRules)
				{
					for(fcounter = fromBrules; fcounter<= toBrules;fcounter++)
					{
						BusinessRule k = businessRules[fcounter];%>
						<form action="/backoffice/business-strategy/insertbusinessrule.aspx" method="post" name="form_lista_field_<%=fcounter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="businessrulelist" name="showtab">
						<input type="hidden" value="LM" name="cssClass">	
						</form>		
						<tr id="tr_delete_flist_<%=fcounter%>" class="<%if(fcounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_field_<%=fcounter%>.submit();"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.margini.lista.table.alt.modify_rule")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteRule(<%=k.id%>,'tr_delete_flist_<%=intCount%>','tr_delete_flist_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.margini.lista.table.alt.delete_rule")%>" hspace="5" vspace="0" border="0"></a></td>										
							<td width="350">						
								<%
								switch (k.ruleType)
								{
								    case 1:
									Response.Write(lang.getTranslated("backend.margini.label.amount_order_rule"));
									break;
								    case 2:
									Response.Write(lang.getTranslated("backend.margini.label.percentage_order_rule"));
									break;
								    case 3:
									Response.Write(lang.getTranslated("backend.margini.label.voucher_order_rule"));
									break;
								    case 4:
									Response.Write(lang.getTranslated("backend.margini.label.first_amount_order_rule"));
									break;
								    case 5:
									Response.Write(lang.getTranslated("backend.margini.label.first_percentage_order_rule"));
									break;
								    case 6:
									Response.Write(lang.getTranslated("backend.margini.label.amount_qta_product_rule"));
									break;
								    case 7:
									Response.Write(lang.getTranslated("backend.margini.label.percentage_qta_product_rule"));
									break;
								    case 8:
									Response.Write(lang.getTranslated("backend.margini.label.amount_related_product_rule"));
									break;
								    case 9:
									Response.Write(lang.getTranslated("backend.margini.label.percentage_related_product_rule"));
									break;
								    case 10:
									Response.Write(lang.getTranslated("backend.margini.label.exclude_bills_product_rule"));
									break;
								    default:
									break;
								}
								%>	
							</td>
							<td width="300">					
							<div class="ajax" id="view_label_<%=fcounter%>" onmouseover="javascript:showHide('view_label_<%=fcounter%>','edit_label_<%=fcounter%>','label_<%=fcounter%>',500, false);"><%=k.label%></div>
							<div class="ajax" id="edit_label_<%=fcounter%>"><input type="text" class="formfieldAjaxLong" id="label_<%=fcounter%>" name="label" onmouseout="javascript:restoreField('edit_label_<%=fcounter%>','view_label_<%=fcounter%>','label_<%=fcounter%>','BusinessRule|IBusinessRuleRepository|string',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.label%>"></div>
							<script>
							$("#edit_label_<%=fcounter%>").hide();
							</script>
							</td>
							<td width="350">							
							<div class="ajax" id="view_description_<%=fcounter%>" onmouseover="javascript:showHide('view_description_<%=fcounter%>','edit_description_<%=fcounter%>','description_<%=fcounter%>',500, false);"><%=k.description%></div>
							<div class="ajax" id="edit_description_<%=fcounter%>"><input type="text" class="formfieldAjaxBig" id="description_<%=fcounter%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=fcounter%>','view_description_<%=fcounter%>','description_<%=fcounter%>','BusinessRule|IBusinessRuleRepository|string',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.description%>"></div>
							<script>
							$("#edit_description_<%=fcounter%>").hide();
							</script>
							</td>
							<td>
							<div class="ajax" id="view_active_<%=fcounter%>" onmouseover="javascript:showHide('view_active_<%=fcounter%>','edit_active_<%=fcounter%>','active_<%=fcounter%>',500, true);">
							<%
							if (k.active) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else {
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_active_<%=fcounter%>">
							<select name="active" class="formfieldAjaxSelect" id="active_<%=fcounter%>" onblur="javascript:updateField('edit_active_<%=fcounter%>','view_active_<%=fcounter%>','active_<%=fcounter%>','BusinessRule|IBusinessRuleRepository|bool',<%=k.id%>,2,<%=fcounter%>);">
							<OPTION VALUE="0" <%if (!k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.active) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_active_<%=fcounter%>").hide();
							</script>
							</td>			
						</tr>				
					<%}
				}%>
			<tr> 
			<th colspan="6" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="businessrulelist" name="showtab">
			<input type="text" name="itemsRule" class="formFieldTXTNumXPage" value="<%=itemsXpageRule%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg4" runat="server" index="4" maxVisiblePages="10" />
			</div>
			</th>
			</tr>				  
		    </table>
			<br/>
			<form action="/backoffice/business-strategy/insertbusinessrule.aspx" method="post" name="form_crea_field">
			<input type="hidden" value="-1" name="id">
			<input type="hidden" value="LM" name="cssClass">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.margini.lista.button.label.inserisci_rule")%>" onclick="javascript:document.form_crea_field.submit();" />
			</form>


			</div>

		</div>		
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>