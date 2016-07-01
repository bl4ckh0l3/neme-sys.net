<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertugroup.aspx.cs" Inherits="_UserGroup" Debug="false" ValidateRequest="false"%>
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
<%@ Reference Control="~/backoffice/include/pagination.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertGroup(){

	if(document.form_inserisci.short_desc.value == "") {
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_short_desc")%>");
		document.form_inserisci.short_desc.focus();
		return false;		
	}

	if(document.form_inserisci.long_desc.value == "") {
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_long_desc")%>");
		document.form_inserisci.long_desc.focus();
		return false;		
	}
	
	if(document.form_inserisci.margin.value != "") {
		var margineTmp = document.form_inserisci.margin.value;
		if(!checkDoubleFormat(margineTmp) || margineTmp.indexOf(".")!=-1){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.isnan_value")%>");
			document.form_inserisci.margin.value = "0";
			document.form_inserisci.margin.focus();
			return false;
		}
	}else{
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_margine")%>");
		document.form_inserisci.margin.value = "0";
		document.form_inserisci.margin.focus();
		return false;		
	}

	if(document.form_inserisci.discount.value != "") {
		var discountTmp = document.form_inserisci.discount.value;
		if(!checkDoubleFormat(discountTmp) || discountTmp.indexOf(".")!=-1){
			alert("<%=lang.getTranslated("backend.margini.detail.js.alert.isnan_value")%>");
			document.form_inserisci.discount.value = "0";
			document.form_inserisci.discount.focus();
			return false;
		}
	}else{
		alert("<%=lang.getTranslated("backend.margini.detail.js.alert.insert_discount")%>");
		document.form_inserisci.discount.value = "0";
		document.form_inserisci.discount.focus();
		return false;		
	}

	document.form_inserisci.submit()
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.short_desc.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		
		<%if("1".Equals(Request["err"])) {%>			
			<span class="error-text"><%=lang.getTranslated("backend.margini.lista.table.error.default_exist")%></span><br/><br/>
		<%}%>
		<form action="/backoffice/business-strategy/insertugroup.aspx" method="post" name="form_inserisci">
		<input type="hidden" value="<%=usergroup.id%>" name="id_group">
		<input type="hidden" value="ugrouplist" name="showtab">
		<input type="hidden" value="insert" name="operation">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
			<tr>
			<td>
			<div style="float:top;padding-bottom:20px;">
			<span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.short_desc")%></span><br>
			  <input type="text" name="short_desc" value="<%=usergroup.shortDesc%>" class="formFieldTXTMedium">
			</div>
			<div style="float:top;padding-bottom:20px;">
			<span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.long_desc")%></span><br>
			  <textarea name="long_desc" class="formFieldTXTAREAAbstract"><%=usergroup.longDesc%></textarea>
			</div>
			<div style="float:left;padding-bottom:20px;padding-right:20px;">		
			  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.default_group")%></span><br>
				<select name="default_group" class="formFieldTXT">
				<option value="0" <%if (!usergroup.defaultGroup) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
				<option value="1" <%if (usergroup.defaultGroup) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
				</SELECT>		  
			</div>
			<div style="float:top;padding-bottom:20px;">	
				<%								
				string supDesc = "";
				StringBuilder supOptions = new StringBuilder();	
				foreach (SupplementGroup x in supplements){
					supOptions.Append("<option value=\"").Append(x.id).Append("\"");
					if(usergroup.supplementGroup != null && usergroup.supplementGroup>0 && usergroup.supplementGroup==x.id){
						supDesc = x.description;
						supOptions.Append(" selected");
					}
					supOptions.Append(">").Append(x.description).Append("</option>");
				}			
				%>
				<span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.taxs_group")%></span><br>
				<select name="taxs_group" class="formFieldTXT">
					<option value=""></option>
					<%=supOptions.ToString()%>	  
				</select>
			</div>
			<div style="float:left;padding-bottom:20px;padding-right:20px;">
			  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.margine")%></span><br>
			  <input type="text" name="margin" value="<%=usergroup.margin.ToString("##0.00")%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
			  </div>	
			  <div style="float:top;padding-bottom:20px;">
			  <span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.discount")%></span><br>
			  <input type="text" name="discount" value="<%=usergroup.discount.ToString("##0.00")%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">%
			  </div>
			<br>		  
			  <div align="left" style="float:left;padding-right:20px;"><span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.active_disc_prod")%></span><br>
				<select name="prod_disc" class="formFieldTXTShort">
				<option value="0" <%if (!usergroup.applyProdDiscount) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
				<option value="1" <%if (usergroup.applyProdDiscount) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
				</SELECT>&nbsp;&nbsp;	
			  </div>	 	
			  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.margini.detail.table.label.active_disc_user")%></span><br>
				<select name="user_disc" class="formFieldTXTShort">
				<option value="0" <%if (!usergroup.applyUserDiscount) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>	
				<option value="1" <%if (usergroup.applyUserDiscount) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>	
				</SELECT>
			  </div><br>
			</td>
			</tr>
		</table>		
			<br/>				
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.margini.detail.button.inserisci.label")%>" onclick="javascript:insertGroup();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/business-strategy/strategylist.aspx?cssClass=<%=cssClass%>';" />
		</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>