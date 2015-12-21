<%@ Page Language="C#" AutoEventWireup="true" CodeFile="orderlist.aspx.cs" Inherits="_OrderList" Debug="false" ValidateRequest="false"%>
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
function editCategoria(idCat){
	location.href='/backoffice/categories/insertcategory.aspx?cssClass=LCE&id='+idCat;
}

function deleteCategoria(id_objref, row, refreshrows){
	if(confirm("<%=lang.getTranslated("backend.categorie.lista.js.alert.delete_category")%>?")){		
		ajaxDeleteItem(id_objref,"Category|ICategoryRepository",row, refreshrows);
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
			<table align="top" border="0" class="principal" cellpadding="0" cellspacing="0">
			  <form action="<%=Request.Url.AbsolutePath%>" method="post" name="form_search" accept-charset="UTF-8">
			  <input type="hidden" value="<%=cssClass%>" name="cssClass">
			  <input type="hidden" value="1" name="page">
		       <tr> 
				<th><%=lang.getTranslated("backend.ordini.lista.table.header.cliente")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.data_insert")%></th>
				<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.data_insert_to")%></th>
				  </tr>
				<tr>
				<td>
				  <select name="order_user" class="formFieldTXT">
				  <option value=""></option>
				  <%if(bolFoundUser){
					  foreach(User y in users){%>		  
						<option value="<%=y.id%>" <%if(search_user == y.id){Response.Write("selected");}%>><%=y.username%></option>
					  <%}
				  }%>
				  </select>	
				  </td>
					<td>
					<input type="text" value="<%=search_datefrom%>" name="order_date_from" class="formFieldTXT">
					</td>
				  <td>			  
				  <input type="text" value="<%=search_dateto%>" name="order_date_to" class="formFieldTXT">	  
				  </td> 
				  </tr>
				  <tr> 
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.type_pagam")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.pagam_done")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.order_by")%></th>
				  </tr>	
				  <tr>
				  <td>			  
				  <select name="order_payment" class="formFieldTXT">		
					<option value=""></option>		
				  <%if(bolFoundFees){			  
					  foreach(Payment k in payments){
						string pdesc = k.description;
						if(!String.IsNullOrEmpty(lang.getTranslated("backend.payment.description.label."+pdesc))){
							pdesc = lang.getTranslated("backend.payment.description.label."+pdesc);
						}%>
						<option value="<%=k.id%>" <%if(search_paytype == k.id){Response.Write("selected");}%>><%=pdesc%></option>					
					  <%}
				  }%> 
				  </select>
				  </td>
				  <td>			  
				  <select name="payment_done" class="formFieldChangeStato">
					<option value=""></option>
					<option value="0" <%if("0".Equals(search_paydone)){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
					<option value="1" <%if("1".Equals(search_paydone)){Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
				  </select>		  
				  </td> 
				<td>			  
				  <select name="order_by" class="formFieldSelect">
					  <option value=""></option>
					  <option value="3" <%if(search_orderby == 3){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_asc")%></option>
					  <option value="4" <%if(search_orderby == 4){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_dta_ins_desc")%></option>
					  <option value="5" <%if(search_orderby == 5){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_asc")%></option>
					  <option value="6" <%if(search_orderby == 6){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_stato_ordine_desc")%></option>
					  <option value="7" <%if(search_orderby == 7){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_amount_ordine_asc")%></option>
					  <option value="8" <%if(search_orderby == 8){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_amount_ordine_desc")%></option>
					  <option value="11" <%if(search_orderby == 11){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_asc")%></option>
					  <option value="12" <%if(search_orderby == 12){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.lista.table.select.option.ord_by_pagam_effettuato_desc")%></option>
				  </select>					                                                                                                                                                                     
				  </td>
			  </tr>
				<tr> 
					<th colspan="2"><%=lang.getTranslated("backend.ordini.lista.table.search.header.order_guid")%></th>
					<th><%=lang.getTranslated("backend.ordini.lista.table.search.header.stato_ord")%></th>
				  </tr>	
				<tr><td colspan="2">
					<input type="text" value="<%=search_guid%>" name="order_guid" class="formFieldTXTBig">
					</td>
					  <td>			  
					  <select name="order_status" class="formFieldChangeStato">
						<option value=""></option>
						<option value="1" <%if("1".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_inserting")%></option>
						<option value="2" <%if("2".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_executing")%></option>
						<option value="3" <%if("3".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_executed")%></option>
						<option value="4" <%if("4".Equals(search_status)){Response.Write("selected");}%>><%=lang.getTranslated("backend.ordini.view.table.label.ord_sca")%></option>
					  </select> 
					  </td> 
				</tr>
			  <tr><td colspan="3">			  
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.lista.button.search.label")%>" onclick="javascript:sendSearchOrder();" />&nbsp;
				  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.ordini.lista.button.label.download_excel")%>" onclick="javascript:openWinExcel('<%//=Application("baseroot")&"/editor/report/CreateOrderExcel.asp?search_ordini="&request("search_ordini")&"&id_utente_search="&id_user_search&"&dta_ins_search_from="&dta_ins_search_from&"&dta_ins_search_to="&dta_ins_search_to&"&tipo_pagam_search="&tipo_pagam_search&"&pagam_done_search="&pagam_done_search&"&stato_ord_search="&stato_ord_search&"&ord_by_search="&ord_by_search&"&ord_guid_search="&ord_guid_search%>','crea_excel',400,400,100,100);" />
				<br/><br/>
				</td></tr>	    
			  </form>
		 	</table>			
			
			
			
			
			
			
			
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
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
				<th colspan="2">&nbsp;</td>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.num_menu" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.gerarchia" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.descrizione" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.visible" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.contains_elements" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.categorie.lista.table.header.automatic" runat="server" /></th>
			    </tr>
				<%
				int counter = 0;				
				if(bolFoundLista){
					foreach (FOrder k in orders){%>	
							<tr id="tr_delete_list_<%=counter%>" class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:editCategoria(<%=k.id%>);"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.categorie.lista.table.alt.modify_cat")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteCategoria(<%=k.id%>,'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.categorie.lista.table.alt.delete_cat")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center">	
							<div class="ajax" id="view_num_menu_<%=counter%>" onmouseover="javascript:showHide('view_num_menu_<%=counter%>','edit_num_menu_<%=counter%>','num_menu_<%=counter%>',500, false);"><%//=k.numMenu%></div>
							<div class="ajax" id="edit_num_menu_<%=counter%>"><input type="text" class="formfieldAjaxShort" id="num_menu_<%=counter%>" name="numMenu" onmouseout="javascript:restoreField('edit_num_menu_<%=counter%>','view_num_menu_<%=counter%>','num_menu_<%=counter%>','Category|ICategoryRepository|int',<%=k.id%>,1,<%=counter%>);" value="<%//=k.numMenu%>" maxlength="2" onkeypress="javascript:return isInteger(event);"></div>
							<script>
							$("#edit_num_menu_<%=counter%>").hide();
							</script>
							</td>
							<td width="17%">	
							<div class="ajax" id="view_gerarchia_<%=counter%>" onmouseover="javascript:showHide('view_gerarchia_<%=counter%>','edit_gerarchia_<%=counter%>','gerarchia_<%=counter%>',500, false);"><%//=k.hierarchy%></div>
							<div class="ajax" id="edit_gerarchia_<%=counter%>"><input type="text" class="formfieldAjax" id="gerarchia_<%=counter%>" name="hierarchy" onmouseout="javascript:restoreField('edit_gerarchia_<%=counter%>','view_gerarchia_<%=counter%>','gerarchia_<%=counter%>','Category|ICategoryRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%//=k.hierarchy%>" onkeypress="javascript:return isDecimal(event);"></div>
							<script>
							$("#edit_gerarchia_<%=counter%>").hide();
							</script>
							</td>
							<td><%//=k.description%></td>
							<td>
							<div class="ajax" id="view_visibile_<%=counter%>" onmouseover="javascript:showHide('view_visibile_<%=counter%>','edit_visibile_<%=counter%>','visibile_<%=counter%>',500, true);">
							<%
							/*if (k.visible) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{ 
								Response.Write(lang.getTranslated("backend.commons.no"));
							}*/
							%>
							</div>
							<div class="ajax" id="edit_visibile_<%=counter%>">
							<select name="visible" class="formfieldAjaxSelect" id="visibile_<%=counter%>" onblur="javascript:updateField('edit_visibile_<%=counter%>','view_visibile_<%=counter%>','visibile_<%=counter%>','Category|ICategoryRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%//if (!k.visible) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%//if (k.visible) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_visibile_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<div class="ajax" id="view_contiene_elements_<%=counter%>" onmouseover="javascript:showHide('view_contiene_elements_<%=counter%>','edit_contiene_elements_<%=counter%>','contiene_elements_<%=counter%>',500, true);">
							<%//if(k.hasElements) {
								 //Response.Write(lang.getTranslated("backend.commons.yes"));
							//}else{
								//Response.Write(lang.getTranslated("backend.commons.no"));
							//}
							%>
							</div>
							<div class="ajax" id="edit_contiene_elements_<%=counter%>">
							<select name="hasElements" class="formfieldAjaxSelect" id="contiene_elements_<%=counter%>" onblur="javascript:updateField('edit_contiene_elements_<%=counter%>','view_contiene_elements_<%=counter%>','contiene_elements_<%=counter%>','Category|ICategoryRepository|bool',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%//if (!k.hasElements) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%//if (k.hasElements) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_contiene_elements_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<%/*if(k.automatic) {
								 Response.Write(lang.getTranslated("backend.commons.yes"));
							}else{
								Response.Write(lang.getTranslated("backend.commons.no"));
							}*/
							%>
							</td>							
							</tr>			
						<%
						counter++;
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
			
			<form action="/backoffice/categories/insertcategory.aspx" method="post" name="form_crea">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="" name="id">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.categorie.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
			</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>