<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertsupplement.aspx.cs" Inherits="_Supplement" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1,2" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertSupplement(){
	
	if(document.form_inserisci.description.value == ""){
		alert("<%=lang.getTranslated("backend.payment.detail.js.alert.insert_descrizione_value")%>");
		document.form_inserisci.description.focus();
		return;
	}

	var commission = document.form_inserisci.amount.value;
	if(commission == ""){
		alert("<%=lang.getTranslated("backend.currency.detail.js.alert.insert_valore_value")%>");
		document.form_inserisci.amount.focus();
		return;
	}else if(commission.indexOf('.') != -1){
		alert("<%=lang.getTranslated("backend.prodotti.detail.js.alert.use_only_comma")%>");
		document.form_inserisci.amount.focus();
		return;		
	}
	
	document.form_inserisci.submit()
}
</script>
</head>
<body onLoad="javascript:document.form_inserisci.description.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<tr><td>
		<form action="/backoffice/supplements/insertsupplement.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=supplement.id%>" name="id">
		  <input type="hidden" value="<%=cssClass%>" name="cssClass">	
		  <input type="hidden" value="insert" name="operation">
		  <span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.descrizione")%></span><br>
		  <input type="text" name="description" value="<%=supplement.description%>" class="formFieldTXT">
		  <a href="javascript:showHideDiv('description_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a><br/>
			<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="description_ml">
			<%
			foreach (Language x in languages){%>
			<input type="text" hspace="2" vspace="2" name="description_<%=x.label%>" id="description_<%=x.label%>" value="<%=mlangrep.translate("backend.supplement.description.label."+supplement.description, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>				
			</div>
		  <br/><br/>	
		  <div align="left" style="float:left;padding-right:8px;"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.commission")%></span><br>
		  <input type="text" name="amount" value="<%=supplement.value.ToString("#0.00#")%>" class="formFieldTXTShort" onkeypress="javascript:return isDouble(event);">&nbsp;&nbsp;
		  </div>	
		  <div align="left"><span class="labelForm"><%=lang.getTranslated("backend.payment.detail.table.label.commission_type")%></span><br>
			<select name="type" class="formFieldTXTMedium">
			<option value="1"<%if (supplement.type==1) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.tipologia_fisso")%></option>	
			<option value="2"<%if (supplement.type==2) { Response.Write(" selected");}%>><%=lang.getTranslated("backend.payment.label.tipologia_percentuale")%></option>	
			</SELECT>	
		  </div>
		</form><br>
		</td></tr>
		</table>	<br> 
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.payment.detail.button.inserisci.label")%>" onclick="javascript:insertSupplement();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/supplements/supplementlist.aspx?showtab=taxslist&cssClass=<%=cssClass%>';" />
		<br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>