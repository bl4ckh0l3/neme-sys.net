<%@ Page Language="C#" AutoEventWireup="true" CodeFile="newsletterlist.aspx.cs" Inherits="_NewsletterList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function deleteNewsletter(id_objref,row,refreshrows){
	if(confirm("<%=lang.getTranslated("backend.newsletter.lista.js.alert.delete_newsletter")%>?")){
		ajaxDeleteItem(id_objref,"Newsletter|INewsletterRepository",row,refreshrows);
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
		<table border="0" align="top" cellpadding="0" cellspacing="0" class="principal">
			<tr> 
<!--nsys-nwsletlist4-->
			<th colspan="7" align="left">
<!---nsys-nwsletlist4-->
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
				  <th><lang:getTranslated keyword="backend.newsletter.lista.table.header.descrizione" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.newsletter.lista.table.header.newsletter_stato" runat="server" /></th>
				  <th><lang:getTranslated keyword="backend.newsletter.lista.table.header.newsletter_template" runat="server" /></th>
<!--nsys-nwsletlist5-->
				  <th><lang:getTranslated keyword="backend.newsletter.lista.table.header.voucher_campaign" runat="server" /></th>
<!---nsys-nwsletlist5-->
				  <th><lang:getTranslated keyword="backend.newsletter.lista.table.header.newsletter_subscribed" runat="server" /></th>
              </tr> 
				<%	
				int intCount = 0;				
				if(bolFoundLista){
					foreach(Newsletter k in newsletters){
						int subscribed = newslrep.findSubscribed(k.id);
						%>
					<form action="/backoffice/newsletter/insertnewsletter.aspx" method="post" name="form_lista_<%=intCount%>">
					<input type="hidden" value="<%=k.id%>" name="id">
					<input type="hidden" value="delete" name="operation">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">
					</form> 	
					<tr class="<%if(intCount % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=intCount%>">
					<td align="center" width="25"><a href="javascript:document.form_lista_<%=intCount%>.submit();"><img src="/backoffice/img/pencil.png" title="<%=lang.getTranslated("backend.newsletter.lista.table.alt.modify_newsletter")%>" hspace="2" vspace="0" border="0"></a></td>
					<td align="center" width="25"><a href="javascript:deleteNewsletter(<%=k.id%>, 'tr_delete_list_<%=intCount%>','tr_delete_list_');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.newsletter.lista.table.alt.delete_newsletter")%>" hspace="2" vspace="0" border="0"></a></td>
					<td width="30%">
					<div class="ajax" id="view_description_<%=intCount%>" onmouseover="javascript:showHide('view_description_<%=intCount%>','edit_description_<%=intCount%>','description_<%=intCount%>',500, false);"><%=k.description%></div>
					<div class="ajax" id="edit_description_<%=intCount%>"><input type="text" class="formfieldAjax" id="description_<%=intCount%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=intCount%>','view_description_<%=intCount%>','description_<%=intCount%>','Newsletter|INewsletterRepository|string',<%=k.id%>,1,<%=intCount%>);" value="<%=k.description%>"></div>
					<script>
					$("#edit_description_<%=intCount%>").hide();
					</script>
					</td>
					<td width="10%">
					<div class="ajax" id="view_active_<%=intCount%>" onmouseover="javascript:showHide('view_active_<%=intCount%>','edit_active_<%=intCount%>','active_<%=intCount%>',500, true);">
					<%
					if (k.isActive) { 
						Response.Write(lang.getTranslated("backend.newsletter.lista.table.label.active"));
					}else{ 
						Response.Write(lang.getTranslated("backend.newsletter.lista.table.label.inactive"));
					}%>
					</div>
					<div class="ajax" id="edit_active_<%=intCount%>">
					<select name="isActive" class="formfieldAjaxSelect" id="active_<%=intCount%>" onblur="javascript:updateField('edit_active_<%=intCount%>','view_active_<%=intCount%>','active_<%=intCount%>','Newsletter|INewsletterRepository|bool',<%=k.id%>,2,<%=intCount%>);">
					<option value="0"<%if (!k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.newsletter.lista.table.label.inactive")%></option>	
					<option value="1"<%if (k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.newsletter.lista.table.label.active")%></option>	
					</SELECT>	
					</div>
					<script>
					$("#edit_active_<%=intCount%>").hide();
					</script>
					</td>
					<td width="20%">
					<div class="ajax" id="view_template_<%=intCount%>" onmouseover="javascript:showHide('view_template_<%=intCount%>','edit_template_<%=intCount%>','template_<%=intCount%>',500, true);">
					<%
					foreach(MailMsg msg in templates){
						if (msg.id==k.templateId) { Response.Write(msg.name);break;}
					}
					%>
					</div>
					<div class="ajax" id="edit_template_<%=intCount%>">
					<select name="templateId" class="formfieldAjaxSelect" id="template_<%=intCount%>" onblur="javascript:updateField('edit_template_<%=intCount%>','view_template_<%=intCount%>','template_<%=intCount%>','Newsletter|INewsletterRepository|int',<%=k.id%>,2,<%=intCount%>);">		  
					<%foreach(MailMsg msg in templates){%>					
					<option value="<%=msg.id%>"<%if (msg.id==k.templateId) { Response.Write(" selected");}%>><%=msg.name%></option>	
					<%}%>
					</SELECT>	
					</div>
					<script>
					$("#edit_template_<%=intCount%>").hide();
					</script>
				</td>
<!--nsys-nwsletlist6-->
				<td>
					<div class="ajax" id="view_voucher_<%=intCount%>" onmouseover="javascript:showHide('view_voucher_<%=intCount%>','edit_voucher_<%=intCount%>','voucher_<%=intCount%>',500, true);">
					<%
					string klabel = "";
					if(hasVoucherCampaign){
						foreach(VoucherCampaign g in voucherCampaigns){
							if(g.id==k.idVoucherCampaign){
								klabel = g.label;
								break;
							}
						}
					}
					Response.Write(klabel);
					%>
					</div>
					<div class="ajax" id="edit_voucher_<%=intCount%>">
					<select name="idVoucherCampaign" class="formfieldAjaxSelect" id="voucher_<%=intCount%>" onblur="javascript:updateField('edit_voucher_<%=intCount%>','view_voucher_<%=intCount%>','voucher_<%=intCount%>','Newsletter|INewsletterRepository|int',<%=k.id%>,2,<%=intCount%>);">		  
					  <option value=""></option>
					  <%if(hasVoucherCampaign){
						foreach(VoucherCampaign g in voucherCampaigns){%>
						<option value="<%=g.id%>" <%if(g.id==k.idVoucherCampaign){Response.Write(" selected");}%>><%=g.label%></option>
						<%}
					  }%>
					</SELECT>	
					</div>
					<script>
					$("#edit_voucher_<%=intCount%>").hide();
					</script>
				</td>               
<!---nsys-nwsletlist6-->
				<td>
					<%=subscribed%>
				</td>     
              	</tr>			
					<%intCount++;
				}
			}%>
			  
			<tr> 
<!--nsys-nwsletlist4-->
			<th colspan="7" align="left">
<!---nsys-nwsletlist4-->
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
		<form action="/backoffice/newsletter/insertnewsletter.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="-1" name="id">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.newsletter.lista.button.label.inserisci")%>" onclick="javascript:document.form_crea.submit();" />
		</form>		
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>