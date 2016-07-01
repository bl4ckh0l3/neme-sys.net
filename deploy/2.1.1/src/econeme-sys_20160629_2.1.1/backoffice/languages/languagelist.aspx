<%@ Page Language="C#" AutoEventWireup="true" CodeFile="languagelist.aspx.cs" Inherits="_LanguageList" Debug="false" ValidateRequest="false"%>
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
function insertLanguage(){
	var strOptionValue = document.form_inserisci.option_code.options[document.form_inserisci.option_code.selectedIndex].value;
	document.form_inserisci.label.value = strOptionValue.substring(0, strOptionValue.indexOf("|"));
	document.form_inserisci.description.value = strOptionValue.substring(strOptionValue.indexOf("|")+1,strOptionValue.length);
	
	if(confirm("<%=lang.getTranslated("backend.lingue.js.alert.confirm_set_target_to_user")%>")){
		document.form_inserisci.set_to_users.value = 1;
	}
	
	var element = document.getElementById("urlSubdomain");
	if(element.style.visibility == 'visible'){
		if(document.form_inserisci.url_subdomain.value == ''){
			alert("<%=lang.getTranslated("backend.lingue.js.alert.empty_url")%>");
			return;
		}		
	}	
	
	document.form_inserisci.submit();
}

function deleteLanguage(id_language){
/*<!--nsys-demolangtmp1-->*/
	document.form_delete_lang.id.value = id_language;
	document.form_delete_lang.action = "/backoffice/languages/languagelist.aspx";
	document.form_delete_lang.submit();
/*<!---nsys-demolangtmp1-->*/
}

function activateLanguage(id_language,elem){
/*<!---nsys-demolangtmp2-->*/
	//document.form_activate_lang.id.value = id_language;
	//document.form_activate_lang.isactive.value = elem.value;
	//document.form_activate_lang.submit();

	var dataString = "id="+id_language+"&isactive="+elem.value;
	$.ajax({  
		type: "POST",  
		url: "/backoffice/languages/ajaxactivatelang.aspx",  
		data: dataString,  
		success: function(response) {   
			//alert("ok passato"+response);			
		},
		error: function() {
			//alert("errore");
		}
	}); 
/*<!---nsys-demolangtmp2-->*/
}

function showHideURLsubdomain(elemID){
	var elem = document.form_inserisci.subdomain_active.options[document.form_inserisci.subdomain_active.selectedIndex].value;

	var element = document.getElementById(elemID);
	if(elem == 0){
		element.style.visibility = 'hidden';
		element.style.display = "none";
	}else if(elem == 1){
		element.style.visibility = 'visible';		
		element.style.display = "block";
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
		<table class="principal" border="0" cellpadding="0" cellspacing="0">
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
				<th>&nbsp;</td>
				<th><lang:getTranslated keyword="backend.lingue.lista.table.header.descrizione" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.lingue.lista.table.header.lang_active" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.lingue.lista.table.header.subdomain_active" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.lingue.lista.table.header.url_sottodominio" runat="server" /></th>
		      </tr> 
				<%		
				int counter = 0;				
				if(bolFoundLista){
					foreach (Language k in languages){%>
						<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
						<td align="center" width="25"><a href="javascript:deleteLanguage(<%=k.id%>,'<%=k.label%>');"><img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.lingue.lista.table.alt.delete_lang")%>" hspace="2" vspace="0" border="0"></a></td>
						<td><img width="16" height="11" border="0" style="padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%>" title="<%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%>" src="/backoffice/img/flag/flag-<%=k.label%>.png"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%></td>
						<td>
						  <select name="activate" class="formFieldTXTShort" onChange="javascript:activateLanguage(<%=k.id%>,this);">
						  <option value="0" <%if (!k.langActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
						  <option value="1" <%if (k.langActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
						  </select>
						</td>

						<td><%if (k.subdomainActive) { Response.Write(lang.getTranslated("backend.commons.yes"));} else {Response.Write(lang.getTranslated("backend.commons.no"));}%></td>
						<td><%=k.urlSubdomain%></td>
						</tr>
						<%
						counter++;
					}
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
			<br/><br>
			<table border="0" align="top" cellpadding="0" cellspacing="0" class="principal">
			<form action="/backoffice/languages/languagelist.aspx" method="post" name="form_inserisci">
			<input type="hidden" value="-1" name="id">
			<input type="hidden" value="" name="description">
			<input type="hidden" value="" name="label">
			<input type="hidden" value="0" name="set_to_users">		
			<input type="hidden" value="insert" name="operation">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<tr>		  
				<td align="left" valign="top">
				 <span class="labelForm"><%=lang.getTranslated("backend.lingue.lista.label.lang_name")%></span><br>
				 <select name="option_code" class="formFieldTXT">
					<%foreach (AvailableLanguage k in availableLangs){%>	
						<%if (languagesKey != null && !languagesKey.Contains(k.keyword)) {%><option value="<%=k.keyword+"|"+k.description%>" style="background-image: url('/backoffice/img/flag/flag-<%=k.keyword%>.png');background-repeat: no-repeat;background-position: left center;padding-left:20px;padding-bottom:2px;vertical-align:top;"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%></option><%}%>
					<%}%>
					</select>&nbsp;&nbsp;
				</td>
				<td align="left" valign="top">&nbsp;</td>
			</tr>
			<tr>  
				<td align="left" valign="top">
				<br><span class="labelForm"><%=lang.getTranslated("backend.lingue.lista.label.lang_active")%></span><br>
			      <select name="lang_active" class="formFieldTXTShort">
				  <option value="0"><%=lang.getTranslated("backend.commons.no")%></option>
				  <option value="1"><%=lang.getTranslated("backend.commons.yes")%></option>
				</select>&nbsp;&nbsp;
				</td>
				<td align="left" valign="top">&nbsp;</td>
			</tr>
			<tr>  
				<td align="left" valign="top">
				<br><span class="labelForm"><%=lang.getTranslated("backend.lingue.lista.label.subdomain_active")%></span><br>
			      <select name="subdomain_active" class="formFieldTXTShort" onChange="javascript:showHideURLsubdomain('urlSubdomain')">
				  <option value="0"><%=lang.getTranslated("backend.commons.no")%></option>
				  <option value="1"><%=lang.getTranslated("backend.commons.yes")%></option>
				</select>&nbsp;&nbsp;
				</td>
				<td align="left" valign="top">
				<br><div id="urlSubdomain" style="visibility:hidden;display:none;" align="left"> 
				<span class="labelForm"><%=lang.getTranslated("backend.lingue.lista.label.url_subdomain_active")%></span><br>
				<input type="text" name="url_subdomain" class="formFieldTXTLong" value="">
				</div> 
			  	</td>
			</tr>
			</form>
			</table>
			<br/>
			<input type="button" class="buttonForm" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.lingue.lista.button.label.inserisci")%>" onclick="javascript:insertLanguage();" />
			<br/><br/>

			<form action="" method="post" name="form_delete_lang">
			<input type="hidden" value="" name="id">
			<input type="hidden" value="delete" name="operation">	
			<input type="hidden" value="" name="description">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			</form>
			
			<form action="/backoffice/languages/ajaxactivatelang.aspx" method="post" name="form_activate_lang">
			<input type="hidden" value="" name="id">
			<input type="hidden" value="<%=itemsXpage%>" name="items">			
			<input type="hidden" value="<%=numPage%>" name="page">		
			<input type="hidden" value="" name="isactive">
			<input type="hidden" value="activate" name="operation">	
			<input type="hidden" value="<%=cssClass%>" name="cssClass">
			</form>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>