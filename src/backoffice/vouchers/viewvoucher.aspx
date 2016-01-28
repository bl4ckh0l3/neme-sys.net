<%@ Page Language="C#" AutoEventWireup="true" CodeFile="viewvoucher.aspx.cs" Inherits="_VoucherView" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function deleteVoucherCode(id_objref){
	if(confirm("<%=lang.getTranslated("backend.voucher.lista.js.alert.delete_code")%>?")){
		document.form_delete.voucher_code.value=id_objref;
		document.form_delete.submit();
	}
}  

function generateVoucherCode(){
	<%if(campaign.type==4){%>
	if(document.form_crea.id_user_ref.value == ""){
		alert("<%=lang.getTranslated("backend.voucher.detail.js.alert.insert_user")%>");
		document.form_crea.id_user_ref.focus();
		return;
	}
	<%}%>	
	
	document.form_crea.submit();
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
				<tr>
				<th width="30%"><%=lang.getTranslated("backend.voucher.lista.table.header.label")%></th>
				<td class="separator">&nbsp;</td>
				<th width="50%"><%=lang.getTranslated("backend.voucher.detail.table.label.desc")%></th>
				<td class="separator">&nbsp;</td>
				<th width="20%"><%=lang.getTranslated("backend.voucher.lista.table.header.activate")%></th>
				</tr>		
				<tr>
				<td><%=campaign.label%></td>
				<td class="separator">&nbsp;</td>
				<td><%=campaign.description%></td>	
				<td class="separator">&nbsp;</td>
				<td>
				<%
				if(!campaign.active){
					Response.Write(lang.getTranslated("backend.commons.no"));
				}else{
					Response.Write(lang.getTranslated("backend.commons.yes"));
				}%></td>	
				</tr>		
				<tr>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.voucher_type")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.value")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.operation")%></th>
				</tr>		
				<tr>
				<td><%
				int caseSwitch = campaign.type;
				switch (caseSwitch)
				{							
					// valore fisso
					case 0:
						Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot"));
						break;
					case 1:
						Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_multiple_use"));
						break;
					case 2:
						Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_time"));
					break;
					case 3:
						Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_multiple_use_by_time"));
					break;
					case 4:
						Response.Write(lang.getTranslated("backend.voucher.lista.table.label.type_one_shot_by_user"));
					break;
					default:
					break;
				}%></td>
				<td class="separator">&nbsp;</td>
				<td><%=campaign.voucherAmount.ToString("#,###0.00")%></td>
				<td class="separator">&nbsp;</td>
				<td>
				<%
				if(campaign.operation==0){
					Response.Write(lang.getTranslated("backend.voucher.lista.operation.label.percentage"));
				}else if(campaign.operation==1){
					Response.Write(lang.getTranslated("backend.voucher.lista.operation.label.fixed"));
				}%>
				</td>
				</tr>		
				<tr>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.generated_code")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.max_generation")%><%if(campaign.type==4){Response.Write("&nbsp;"+lang.getTranslated("backend.voucher.lista.table.header.max_generation_by_user"));}%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.max_usage")%></th>			
				</tr>		
				<tr>
				<td><%=totalCounterCode%></td>
				<td class="separator">&nbsp;</td>
				<td>
				<%if(campaign.maxGeneration==-1){
					Response.Write(lang.getTranslated("backend.voucher.label.unlimited"));
				}else{
					Response.Write(campaign.maxGeneration);
				}%></td>
				<td class="separator">&nbsp;</td>
				<td>
				<%if(campaign.maxUsage==-1){
					Response.Write(lang.getTranslated("backend.voucher.label.unlimited"));
				}else{
					Response.Write(campaign.maxUsage);
				}%></td>		
				</tr>		
				<tr>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.enable_date")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.expire_date")%></th>
				<td class="separator">&nbsp;</td>
				<th><%=lang.getTranslated("backend.voucher.lista.table.header.exclude_prod_rule")%></th>
				</tr>		
				<tr>
				<td>
				<%string aDate = campaign.enableDate.ToString("dd/MM/yyyy HH:mm");
				if("31/12/9999 23:59".Equals(aDate)){
					aDate = "";
				}
				Response.Write(aDate);%>			
				</td>
				<td class="separator">&nbsp;</td>
				<td>
				<%string eDate = campaign.expireDate.ToString("dd/MM/yyyy HH:mm");
				if("31/12/9999 23:59".Equals(eDate)){
					eDate = "";
				}
				Response.Write(eDate);%>
				</td>
				<td class="separator">&nbsp;</td>
				<td>
				<%
				if(!campaign.excludeProdRule){
					Response.Write(lang.getTranslated("backend.commons.no"));
				}else{
					Response.Write(lang.getTranslated("backend.commons.yes"));
				}%>
				</td>			
				</tr>
			</table><br/>

			<%
			if(!String.IsNullOrEmpty(Request["error_message"])){			
				Response.Write("<span class=error-text>"+Request["error_message"]+"</span><br/><br/>");
			}
			if(!String.IsNullOrEmpty(Request["id_new_code"])){			
				Response.Write("<span class=message-text>"+lang.getTranslated("backend.voucher.label.new_voucher_code")+Request["id_new_code"]+"</span><br/><br/>");
			}%>			
			
			<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<tr> 
				<th colspan="5" align="left">
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
				  <th>&nbsp;</th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.table.header.voucher_code")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.table.header.insert_date")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.table.header.usage_counter")%></th>
					<th class="upper"><%=lang.getTranslated("backend.voucher.table.header.id_user_ref")%></th>
				</tr> 
					<%int counter = 0;				
					if(bolFoundLista){
						for(counter = fromVoucher; counter<= toVoucher;counter++){
						VoucherCode k = voucherCodes[counter];%>
						<form action="/backoffice/vouchers/insertvoucher.aspx" method="post" name="form_lista_<%=counter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="<%=cssClass%>" name="cssClass">		
						</form> 
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>" id="tr_delete_list_<%=counter%>">        
							<td align="center" width="25"><a href="javascript:deleteVoucherCode(<%=k.id%>);"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.voucher.lista.table.alt.delete_voucher")%>" hspace="2" vspace="0" border="0"></a></td>						
							<td width="20%"><%=k.code%></td>
							<td width="20%"><%=k.insertDate.ToString("dd/MM/yyyy HH:mm")%></td>
							<td width="20%"><%=k.usageCounter%></td>
							<td>
							<%
							string vUser = "";
							if(k.userId>0){
							User user = usrrep.getById(k.userId);
							if(user!=null){
								vUser=user.username+"&nbsp;("+user.email+")";
							}
							
							Response.Write(vUser);
							}%>
							</td>							
						</tr>		
						<%}
					}%>	
				<tr> 
				<th colspan="5" align="left">
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
		<form action="/backoffice/vouchers/viewvoucher.aspx" method="post" name="form_crea">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="<%=campaign.id%>" name="id_voucher">
		<input type="hidden" value="insert" name="operation">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.voucher.lista.button.label.generate_code")%>" onclick="javascript:generateVoucherCode();" />
		<%if(campaign.type==4){%>
		  <select name="id_user_ref" class="formFieldSelect">
		  <option value=""></option>
		  <%if(bolFoundUsers){
		  foreach(User y in users){%>		  
		  <option value="<%=y.id%>"><%=y.username+"&nbsp;("+y.email+")"%></option>
		  <%}
		  }%>
		  </select>		
		<%}%>
		</form>
		<br/>
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/vouchers/voucherlist.aspx?cssClass=LVC';" />
		<br/><br/>
		
		<form action="/backoffice/vouchers/viewvoucher.aspx" method="post" name="form_delete">
		<input type="hidden" value="<%=cssClass%>" name="cssClass">	
		<input type="hidden" value="" name="voucher_code">
		<input type="hidden" value="<%=campaign.id%>" name="id_voucher">
		<input type="hidden" value="delete" name="operation">
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>