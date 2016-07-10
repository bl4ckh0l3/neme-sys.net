<%@ Page Language="C#" AutoEventWireup="true" CodeFile="countrylist.aspx.cs" Inherits="_CountryList" Debug="false" ValidateRequest="false"%>
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
function deleteCountry(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.country.lista.js.alert.delete_country")%>?")){
		ajaxDeleteItem(id_objref,"Country|ICountryRepository",row,refreshrows);
	}
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search">
			<input type="hidden" value="1" name="page">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			  <tr height="35">
				<td colspan="8">
					<input type="submit" maxlength="100" value="<%=lang.getTranslated("backend.country.lista.label.search")%>" class="buttonForm" hspace="4" align="absbottom">&nbsp;&nbsp;<input type="text" name="search_key" value="<%=search_key%>" class="formFieldTXTLangKeyword">
				</td>			
			  </tr>
			</form>
			
			<tr> 
				<th colspan="8" align="left">
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
				  <th colspan="2">&nbsp;</th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.country_code" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.country" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.state_region_code" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.state_region" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.active" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.country.lista.table.header.use_for" runat="server" /></th>
			</tr> 
				<%					
				int counter = 0;				
				if(bolFoundLista){
					foreach (Country k in countries){%>
						<form action="/backoffice/countries/Insertcountry.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="" name="delete_country">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">
						</form> 
						<tr id="tr_delete_list_<%=counter%>" class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">	
						<td align="center" width="25"><a href="javascript:document.form_lista_<%=counter%>.submit();"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.country.lista.table.alt.modify_country")%>" hspace="2" vspace="0" border="0"></a></td>
						<td align="center" width="25"><a href="javascript:deleteCountry(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.country.lista.table.alt.delete_country")%>" hspace="2" vspace="0" border="0"></a></td>
						<td width="10%">						
						<div class="ajax" id="view_country_code_<%=counter%>" onmouseover="javascript:showHide('view_country_code_<%=counter%>','edit_country_code_<%=counter%>','country_code_<%=counter%>',500, false);"><%=k.countryCode%></div>
						<div class="ajax" id="edit_country_code_<%=counter%>"><input type="text" class="formfieldAjaxShort" id="country_code_<%=counter%>" name="countryCode" onmouseout="javascript:restoreField('edit_country_code_<%=counter%>','view_country_code_<%=counter%>','country_code_<%=counter%>','Country|ICountryRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.countryCode%>"></div>
						<script>
						$("#edit_country_code_<%=counter%>").hide();
						</script>
						</td>
						<td width="19%">						
						<div class="ajax" id="view_country_description_<%=counter%>" onmouseover="javascript:showHide('view_country_description_<%=counter%>','edit_country_description_<%=counter%>','country_description_<%=counter%>',500, false);"><%=k.countryDescription%></div>
						<div class="ajax" id="edit_country_description_<%=counter%>"><input type="text" class="formfieldAjax" id="country_description_<%=counter%>" name="countryDescription" onmouseout="javascript:restoreField('edit_country_description_<%=counter%>','view_country_description_<%=counter%>','country_description_<%=counter%>','Country|ICountryRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.countryDescription%>"></div>
						<script>
						$("#edit_country_description_<%=counter%>").hide();
						</script>
						</td>
						
						<td width="16%">						
						<div class="ajax" id="view_state_region_code_<%=counter%>" onmouseover="javascript:showHide('view_state_region_code_<%=counter%>','edit_state_region_code_<%=counter%>','state_region_code_<%=counter%>',500, false);"><%=k.stateRegionCode%></div>
						<div class="ajax" id="edit_state_region_code_<%=counter%>"><input type="text" class="formfieldAjax" id="state_region_code_<%=counter%>" name="stateRegionCode" onmouseout="javascript:restoreField('edit_state_region_code_<%=counter%>','view_state_region_code_<%=counter%>','state_region_code_<%=counter%>','Country|ICountryRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.stateRegionCode%>"></div>
						<script>
						$("#edit_state_region_code_<%=counter%>").hide();
						</script>
						</td>
						<td width="25%">						
						<div class="ajax" id="view_state_region_description_<%=counter%>" onmouseover="javascript:showHide('view_state_region_description_<%=counter%>','edit_state_region_description_<%=counter%>','state_region_description_<%=counter%>',500, false);"><%=k.stateRegionDescription%></div>
						<div class="ajax" id="edit_state_region_description_<%=counter%>"><input type="text" class="formfieldAjaxLong" id="state_region_description_<%=counter%>" name="stateRegionDescription" onmouseout="javascript:restoreField('edit_state_region_description_<%=counter%>','view_state_region_description_<%=counter%>','state_region_description_<%=counter%>','Country|ICountryRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.stateRegionDescription%>"></div>
						<script>
						$("#edit_state_region_description_<%=counter%>").hide();
						</script>
						</td>						
						
						<td width="5%">
						<div class="ajax" id="view_active_<%=counter%>" onmouseover="javascript:showHide('view_active_<%=counter%>','edit_active_<%=counter%>','active_<%=counter%>',500, true);">
						<%
						if (k.active) { 
							Response.Write(lang.getTranslated("backend.commons.yes"));
						}else{
							Response.Write(lang.getTranslated("backend.commons.no"));
						}
						%>
						</div>
						<div class="ajax" id="edit_active_<%=counter%>">
						<select name="active" class="formfieldAjaxSelect" id="active_<%=counter%>" onblur="javascript:updateField('edit_active_<%=counter%>','view_active_<%=counter%>','active_<%=counter%>','Country|ICountryRepository|bool',<%=k.id%>,2,<%=counter%>);">
						<OPTION VALUE="0" <%if (!k.active){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (k.active){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_active_<%=counter%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_use_for_<%=counter%>" onmouseover="javascript:showHide('view_use_for_<%=counter%>','edit_use_for_<%=counter%>','use_for_<%=counter%>',500, true);">
						<%
						switch (k.useFor)
						{
							case "1": 
								Response.Write(lang.getTranslated("backend.country.use_for.registration"));
								break;
							case "2":
								Response.Write(lang.getTranslated("backend.country.use_for.purchase"));
								break;
							case "3":
								Response.Write(lang.getTranslated("backend.country.use_for.all"));
								break;
							default:
								break;
						}
						%>
						</div>
						<div class="ajax" id="edit_use_for_<%=counter%>">
						<select name="useFor" class="formfieldAjaxSelect" id="use_for_<%=counter%>" onblur="javascript:updateField('edit_use_for_<%=counter%>','view_use_for_<%=counter%>','use_for_<%=counter%>','Country|ICountryRepository|string',<%=k.id%>,2,<%=counter%>);">
						<option value="1"<%if ("1"==k.useFor) {Response.Write(" selected");}%>><%=lang.getTranslated("backend.country.use_for.registration")%></option>	
<!--nsys-cntlist1-->
						<option value="2"<%if ("2"==k.useFor) {Response.Write(" selected");}%>><%=lang.getTranslated("backend.country.use_for.purchase")%></option>	
						<option value="3"<%if ("3"==k.useFor) {Response.Write(" selected");}%>><%=lang.getTranslated("backend.country.use_for.all")%></option>	
<!---nsys-cntlist1-->
						</SELECT>	
						</div>
						<script>
						$("#edit_use_for_<%=counter%>").hide();
						</script>
						</td>               
						</tr>				
						<%counter++;
					}
				}%>
				<tr> 
				<th colspan="8" align="left">
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
		<form action="/backoffice/countries/insertcountry.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.country.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>		
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>