<%@ Page Language="C#" AutoEventWireup="true" CodeFile="configuration.aspx.cs" Inherits="_Configuration" Debug="true"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="CommonMeta" TagName="insert" Src="~/backoffice/include/common-meta.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/backoffice/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/backoffice/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/backoffice/include/footer.ascx" %>
<%@ Register TagPrefix="CommonMenu" TagName="insert" Src="~/backoffice/include/menu.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script>
function insertConfiguration(theForm){
	if(document.form_inserisci.keyword.value == ""){
		alert("<%=lang.getTranslated("backend.config.lista.js.alert.insert_keyword")%>");
		document.form_inserisci.keyword.focus();
		return false;
	}	
	
	if(confirm("<%=lang.getTranslated("backend.config.lista.js.alert.confirm_insert_config")%>")){
		theForm.action = "/backoffice/configuration/configuration.aspx";
		theForm.submit();
	}
}
function deleteConfiguration(theForm){	
	if(confirm("<%=lang.getTranslated("backend.config.lista.js.alert.confirm_delete_config")%>")){
		theForm.operation.value = "delete";
		theForm.action = "/backoffice/configuration/configuration.aspx";
		theForm.submit();
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
			<table border="0" cellpadding="0" cellspacing="0" class="principal">
				<form action="/backoffice/configuration/configuration.aspx" method="post" name="form_inserisci" accept-charset="UTF-8">
				<input type="hidden" value="insert" name="operation">
				<input type="hidden" name="alert" value="0">
				<input type="hidden" name="is_base" value="0">
				  <tr height="35">
					<td colspan="5" align="left">
					<div style="padding-left:5px;float:left;padding-top:15px;">
					<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" value="<%=lang.getTranslated("backend.multilingue.lista.button.label.inserisci")%>" onclick="javascript:insertConfiguration(document.form_inserisci);" />
					</div>
					<div style="padding-left:5px;float:left;">
					<span class="labelForm"><lang:getTranslated keyword="backend.config.lista.table.header.keyword" runat="server" /></span><br/>
					<input type="text" name="keyword" value="" class="formFieldTXTMedium">
					</div>
					<div style="padding-left:5px;float:left;">
					<span class="labelForm"><lang:getTranslated keyword="backend.config.lista.table.header.descrizione" runat="server" /></span><br/>
					<input type="text" name="description" value="" class="formFieldTXTLang"></div>
					<div style="padding-left:5px;float:left;">
					<span class="labelForm"><lang:getTranslated keyword="backend.config.lista.table.header.value" runat="server" /></span><br/>
					<input type="text" name="value" value="" class="formFieldTXTMedium">
					</div>
					<div style="padding-left:5px;padding-right:5px;float:left;">
					<span class="labelForm"><lang:getTranslated keyword="backend.config.lista.table.header.type" runat="server" /></span><br/>
					<input type="text" name="type" value="" class="formFieldTXTMedium">
					</div>
					<div style="padding-left:5px;">
					<span class="labelForm"><lang:getTranslated keyword="backend.config.lista.table.header.type_values" runat="server" /></span><br/>
					<input type="text" name="type_values" value="" class="formFieldTXTMedium">
					</div>
					</td>
				  </tr>	
				</form>		

				<tr>
					<th>&nbsp;</th>
					<th>&nbsp;</th>
					<th><lang:getTranslated keyword="backend.config.lista.table.header.nome_variabile" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.config.lista.table.header.descrizione" runat="server" /></th>
					<th><lang:getTranslated keyword="backend.config.lista.table.header.value" runat="server" /></th>
				</tr>
				<%	
				int counter = 0;
				foreach (Config k in configs){	%>
					<form action="/backoffice/configuration/configuration.aspx" method="post" name="form_lista_<%=counter%>">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">
					<input type="hidden" value="<%=k.key%>" name="key">	
					<input type="hidden" value="" name="operation">				
					<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
					<td>
					<%if(!k.is_base){%>
						<a href="javascript:deleteConfiguration(document.form_lista_<%=counter%>);"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.config.lista.table.alt.delete_config")%>" hspace="5" vspace="0" border="0"></a>
					<%}else{%>
					<%if(k.alert == "1"){%>
						<img src="/common/img/ico_alert.gif" vspace="2" hspace="2" border="0" align="middle" title="<%=lang.getTranslated("backend.config.lista.table.alt.dont_doit")%>">
					<%}else{ Response.Write("&nbsp;");}}%>
					</td>
					<td align="center">
					<!--nsys-democonf1--><a href="javascript:document.form_lista_<%=counter%>.submit();"><!---nsys-democonf1--><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.config.lista.table.alt.modify_config")%>" hspace="2" vspace="0" border="0"></a>
					</td>
					<td><span class="labelForm"><%=k.key%></span></td>
					<td width="400"><%=lang.getTranslated(k.description)%></td>
					<td>
					<%if(!String.IsNullOrEmpty(k.type_values)){%>
						<select name="value">
							<%
							if(k.type_values.StartsWith("[#")){
								if(k.type_values.IndexOf("lang") > 0){
									ILanguageRepository langRepository = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
									IList<Language> languages = langRepository.getLanguageList();
									foreach (Language w in languages){%>
										<option value="<%=w.label%>" <%if(w.label==k.value){Response.Write(" selected");}%>><%=lang.getTranslated("portal.header.label.desc_lang."+w.label)%></option>
									<%}								
								}
							}else{
								string[] p = k.type_values.Split(',');
								if(p!=null){
									foreach (string j in p){%>
										<option value="<%=j%>" <%if(j==k.value){Response.Write(" selected");}%>><%=j%></option>
									<%}
								}
							}%>
						</select>
					<%}else{%>
						<input type="text" name="value" value="<%=k.value%>" class="formFieldTXT">
					<%}%>
					</td>
					</tr>					
					</form>					
					<%counter++;
				}%>			
				<tr>
					<th colspan="5">&nbsp;</th>
				</tr>
			</table>
			<br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>