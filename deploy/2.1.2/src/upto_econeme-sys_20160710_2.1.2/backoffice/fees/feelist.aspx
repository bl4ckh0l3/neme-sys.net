<%@ Page Language="C#" AutoEventWireup="true" CodeFile="feelist.aspx.cs" Inherits="_FeeList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="System.Globalization" %>
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
<script language="JavaScript">
function deleteFee(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.spese.lista.js.alert.delete_spesa")%>?")){
		ajaxDeleteItem(id_objref,"Fee|IFeeRepository",row,refreshrows);
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
				  <th colspan="2">&nbsp;</th>
				  <th><%=lang.getTranslated("backend.spese.lista.table.header.descrizione_spesa").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.spese.lista.table.header.tipologia_valore").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.spese.lista.table.header.tassa_applicata").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.spese.lista.table.header.taxs_group").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.fees.lista.table.header.apply_to").ToUpper()%></th>
				  <th><%=lang.getTranslated("backend.spese.lista.table.header.group").ToUpper()%></th>			  
				  
			</tr> 
					<%int counter = 0;				
					if(bolFoundLista){
						for(counter = fromFee; counter<= toFee;counter++){
						Fee k = fees[counter];%>
						<form action="/backoffice/fees/insertfee.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">		
						</form> 
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=counter%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_<%=counter%>.submit();"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.spese.lista.table.alt.modify_spesa")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteFee(<%=k.id%>, 'tr_delete_list_<%=counter%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.spese.lista.table.alt.delete_spesa")%>" hspace="2" vspace="0" border="0"></a></td>						
							<td width="190">						
							<div class="ajax" id="view_description_<%=counter%>" onmouseover="javascript:showHide('view_description_<%=counter%>','edit_description_<%=counter%>','description_<%=counter%>',500, false);"><%=k.description%></div>
							<div class="ajax" id="edit_description_<%=counter%>"><input type="text" class="formfieldAjax" id="description_<%=counter%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=counter%>','view_description_<%=counter%>','description_<%=counter%>','Fee|IFeeRepository|string',<%=k.id%>,1,<%=counter%>);" value="<%=k.description%>"></div>
							<script>
							$("#edit_description_<%=counter%>").hide();
							</script>
							</td>
							<td width="240">
							<%
							int caseSwitch = k.type;
							switch (caseSwitch)
							{							
								// valore fisso
								case 1:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso"));
									break;
								// imponibile ordine: valore percentuale
								case 2:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_percentuale"));
									break;
								// range imponibile ordine: valore fisso
								case 3:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso_range_imp"));
								break;
								// range imponibile ordine: valore percentuale
								case 4:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_percentuale_range_imp"));
								break;
								// range quantit� ordine: valore fisso
								case 5:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso_qta"));
								break;
								// range quantit� ordine incrementale: valore fisso
								case 6:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso_qta_incr"));
								break;
								// range field prodotto: valore fisso
								case 7:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso_field"));
								break;
								// range field prodotto incrementale: valore fisso
								case 8:
									Response.Write(lang.getTranslated("backend.spese.label.tipologia_fisso_field_incr"));
								break;
								default:
								break;
							}%>
							</td>
							<td style="min-width:90px;">
							<div class="ajax" id="view_id_supplement_<%=counter%>" onmouseover="javascript:showHide('view_id_supplement_<%=counter%>','edit_id_supplement_<%=counter%>','id_supplement_<%=counter%>',500, true);">
							<%
							if(bolFoundSup){
								foreach(Supplement sup in supplements){
									if (k.idSupplement != null && sup.id==k.idSupplement) {
										Response.Write(sup.description);
										break;
									}
								}
							}%>
							</div>
							<div class="ajax" id="edit_id_supplement_<%=counter%>">
							<select name="idSupplement" class="formfieldAjaxSelect" id="id_supplement_<%=counter%>" onblur="javascript:updateField('edit_id_supplement_<%=counter%>','view_id_supplement_<%=counter%>','id_supplement_<%=counter%>','Fee|IFeeRepository|int',<%=k.id%>,2,<%=counter%>);">
							<option value="-1"></option>
							<%if(bolFoundSup){
								foreach(Supplement sup in supplements){%>
								<option value="<%=sup.id%>" <%if (k.idSupplement != null && sup.id==k.idSupplement) { Response.Write("selected");}%>><%=sup.description%></option>
								<%}
							}%>
							</SELECT>	
							</div>
							<script>
							$("#edit_id_supplement_<%=counter%>").hide();
							</script>
							</td>
							<td style="min-width:90px;">
							<div class="ajax" id="view_supplement_group_<%=counter%>" onmouseover="javascript:showHide('view_supplement_group_<%=counter%>','edit_supplement_group_<%=counter%>','supplement_group_<%=counter%>',500, true);">
							<%
							if(bolFoundSupG){
								foreach(SupplementGroup supg in supplementGroups){
									if (k.supplementGroup != null && supg.id==k.supplementGroup) {
										Response.Write(supg.description);
										break;
									}
								}
							}%>
							</div>
							<div class="ajax" id="edit_supplement_group_<%=counter%>">
							<select name="supplementGroup" class="formfieldAjaxSelect" id="supplement_group_<%=counter%>" onblur="javascript:updateField('edit_supplement_group_<%=counter%>','view_supplement_group_<%=counter%>','supplement_group_<%=counter%>','Fee|IFeeRepository|int',<%=k.id%>,2,<%=counter%>);">
							<option value="-1"></option>
							<%if(bolFoundSupG){
								foreach(SupplementGroup supg in supplementGroups){%>
								<option value="<%=supg.id%>" <%if (k.supplementGroup != null && supg.id==k.supplementGroup) { Response.Write("selected");}%>><%=supg.description%></option>
								<%}
							}%>
							</SELECT>	
							</div>
							<script>
							$("#edit_supplement_group_<%=counter%>").hide();
							</script>
							</td>
							
							<td style="min-width:140px;">
							<div class="ajax" id="view_applyto_<%=counter%>" onmouseover="javascript:showHide('view_applyto_<%=counter%>','edit_applyto_<%=counter%>','applyto_<%=counter%>',500, true);">
							<%
							if(k.applyTo==0){
								Response.Write(lang.getTranslated("backend.fees.lista.table.applyto_front"));
							}else if(k.applyTo==1){
								Response.Write(lang.getTranslated("backend.fees.lista.table.applyto_back"));
							}else if(k.applyTo==2){
								Response.Write(lang.getTranslated("backend.fees.lista.table.applyto_both"));
							}%>
							</div>
							<div class="ajax" id="edit_applyto_<%=counter%>">
							<select name="applyTo" class="formfieldAjaxSelect" id="applyto_<%=counter%>" onblur="javascript:updateField('edit_applyto_<%=counter%>','view_applyto_<%=counter%>','applyto_<%=counter%>','Fee|IFeeRepository|int',<%=k.id%>,2,<%=counter%>);">
							<OPTION VALUE="0" <%if (k.applyTo==0) { Response.Write("selected");}%>><%=lang.getTranslated("backend.fees.lista.table.applyto_front")%></OPTION>
							<OPTION VALUE="1" <%if (k.applyTo==1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.fees.lista.table.applyto_back")%></OPTION>
							<OPTION VALUE="2" <%if (k.applyTo==2) { Response.Write("selected");}%>><%=lang.getTranslated("backend.fees.lista.table.applyto_both")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_applyto_<%=counter%>").hide();
							</script>
							</td>
							<td>
							<%=k.feeGroup%>
							</td>
						</tr>		
						<%}
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
		<form action="/backoffice/fees/insertfee.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.spese.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />	
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>