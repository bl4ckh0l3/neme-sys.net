<%@ Page Language="C#" AutoEventWireup="true" CodeFile="multilanguagelist.aspx.cs" Inherits="_MultiLanguageList" Debug="false" ValidateRequest="false"%>
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
function insertLanguage(){
	if(document.form_inserisci.keyword.value == ""){
		alert("<%=lang.getTranslated("backend.multilingue.lista.js.alert.insert_keyword")%>");
		return;
	}

	//verifico se si tratta di un messaggio javascript o di una label testuale
	var isJs = false;
	if(document.form_inserisci.keyword.value.indexOf(".js.") > 0){
		isJs = true;
	}
	
	var strTmpValue
	<%if (bolFoundLista) {
		foreach (Language k in languages){%>
			strTmpValue = document.form_inserisci.value_<%=k.label%>.value;
			strTmpValue = replaceChars(strTmpValue,isJs);
			document.form_inserisci.value_<%=k.label%>.value = strTmpValue;
	<%	}
	}%>

	document.form_inserisci.operation.value = "insert";	
	document.form_inserisci.submit();
}

function modifyLanguage(theForm){
	if(theForm.keyword.value == ""){
		alert("<%=lang.getTranslated("backend.multilingue.lista.js.alert.insert_keyword")%>");
		return;
	}

	//verifico se si tratta di un messaggio javascript o di una label testuale
	var isJs = false;
	if(theForm.keyword.value.indexOf(".js.") > 0){
		isJs = true;
	}
	
	var strTmpValue
	<%if (bolFoundLista) {
		foreach (Language k in languages){%>
			strTmpValue = theForm.value_<%=k.label%>.value;
			//alert("strTmpValue before:"+strTmpValue);	
			strTmpValue = replaceChars(strTmpValue,isJs);
			//alert("strTmpValue after:"+strTmpValue);
			theForm.value_<%=k.label%>.value = strTmpValue;
			//alert("strTmpValue:"+strTmpValue+" - theForm.value_<%=k.label%>.value:"+theForm.value_<%=k.label%>.value);	
	<%	}
	}%>	

	theForm.operation.value = "update";	
	theForm.submit();
}

function deleteLanguage(theForm){	
	if(confirm("<%=lang.getTranslated("backend.multilingue.lista.js.alert.confirm_delete_multilang")%>?")){
		theForm.operation.value = "delete";
		theForm.action = "/backoffice/multilanguages/multilanguagelist.aspx";
		theForm.submit();
	}
}

function selectAllLanguageKey(){
	var form, ck_value, is_ck_value_ck;
	ck_value = document.getElementById("ck_do_select_all");
	is_ck_value_ck = ck_value.checked;
	for (var counter = 0; counter < <%=itemsXpage%>; counter++) {
		form = document.getElementById("form_lista_"+counter);
		if(form){			
			if (is_ck_value_ck){
				form.ck_select_all.checked = true;
			}else{
				form.ck_select_all.checked = false;
			}
		}
	}
}

function modifyAllSelectedLanguage(){
	var form;
	for (var counter = 0; counter < <%=(itemsXpage)%>; counter++) {
		form = document.getElementById("form_lista_"+counter);
		if(form){			
			if (form.ck_select_all.checked){
				var singleLineValue;
				singleLineValue = "keyword=" + form.keyword.value + "||";

				//verifico se si tratta di un messaggio javascript o di una label testuale
				var isJs = false;
				if(form.keyword.value.indexOf(".js.") > 0){
					isJs = true;
				}
				
				var strTmpValue;
				<%if (bolFoundLista) {
					foreach (Language k in languages){%>
						strTmpValue = "id_<%=k.label%>=" + form.klid_<%=k.label%>.value + "||";
						strTmpValue += "value_<%=k.label%>=" + form.value_<%=k.label%>.value; //encodeURIComponent();
						strTmpValue = replaceChars(strTmpValue,isJs);
						singleLineValue += strTmpValue + "||";				
				<%	}
				}%>		
				
				singleLineValue = singleLineValue.substring(0,singleLineValue.lastIndexOf("||"));
				singleLineValue += "###";
				
				document.form_lista_multi_select.multiple_values.value += singleLineValue;
			}
		}
	}
	
	document.form_lista_multi_select.multiple_values.value = document.form_lista_multi_select.multiple_values.value.substring(0,document.form_lista_multi_select.multiple_values.value.lastIndexOf("###"));
	document.form_lista_multi_select.operation.value = "modify";

	//alert(document.form_lista_multi_select.multiple_values.value);
	if(confirm("<%=lang.getTranslated("backend.multilingue.lista.js.alert.confirm_modify_sel_multilang")%>?")){
		document.form_lista_multi_select.submit();
	}
}

function deleteAllSelectedLanguage(){
	var form;
	var singleLineValue = "";
	for (var counter = 0; counter < <%=(itemsXpage)%>; counter++) {
		form = document.getElementById("form_lista_"+counter);
		if(form){			
			if (form.ck_select_all.checked){				
				var strTmpValue;
				<%if (bolFoundLista) {
					foreach (Language k in languages){%>
						singleLineValue += form.klid_<%=k.label%>.value + "|";				
				<%	}
				}%>	
			}
		}
	}
				
	singleLineValue = singleLineValue.substring(0,singleLineValue.lastIndexOf("|"));			

	//alert(singleLineValue);
	if(confirm("<%=lang.getTranslated("backend.multilingue.lista.js.alert.confirm_delete_sel_multilang")%>?")){
		document.form_lista_multi_select.multiple_values.value += singleLineValue;	
		//alert(document.form_lista_multi_select.multiple_values.value);
		document.form_lista_multi_select.operation.value = "delete";
		document.form_lista_multi_select.submit();	
	}
}

function replaceChars(inString,isJs){
	var outString = inString;
	var pos= 0;
	
	// ricerca e escaping degli apici	
	/*
	var quote= -1;
	do {
		quote= outString.indexOf('\'', pos);
		if (quote >= 0) {
			if(isJs){
				outString= outString.substring(0, quote) + "\'" + outString.substring(quote +1);
			}else{
				outString= outString.substring(0, quote) + "&#39;" + outString.substring(quote +1);
			}
			pos= quote+2;
		}
	} while (quote >= 0);
	*/

	// ricerca e escaping dei doppi apici
	pos= 0;
	var double_quote= -1;
	do {
		double_quote= outString.indexOf('"', pos);
		if (double_quote >= 0) {
			outString= outString.substring(0, double_quote) + "&quot;" + outString.substring(double_quote +1);
			pos= double_quote+2;
		}
	} while (double_quote >= 0);
	
	/*
	// ricerca e escaping dei new line
	pos= 0;
	var linefeed= -1;
	do {
		linefeed= outString.indexOf('\n', pos);
		if (linefeed >= 0) {
			outString= outString.substring(0, linefeed) + "\\n" + outString.substring(linefeed +1);
			pos= linefeed+2;
		}
	} while (linefeed >= 0);

	// ricerca e escaping dei line feed
	pos= 0;
	var creturn= -1;
	do {
		creturn= outString.indexOf('\r', pos);
		if (creturn >= 0) {
			outString= outString.substring(0, creturn) + "\\r" + outString.substring(creturn +1);
			pos= creturn+2;
		}
	} while (creturn >= 0);
	*/
	
	return outString;
}
</script>
</head>
<body onLoad="javascript:document.form_search.search_key.focus();">
<div id="backend-warp">
	<CommonHeader:insert runat="server" />
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
		<table class="principal" border="0" cellpadding="0" cellspacing="0">
			<%if (bolFoundLista) {%>
				<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" name="form_search" accept-charset="UTF-8">
				<input type="hidden" value="1" name="page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				  <tr height="35">
					<td colspan="2" align="center"><input type="submit" value="<%=lang.getTranslated("backend.multilingue.lista.label.search")%>" class="buttonForm" hspace="4"></td>
					<td colspan="<%=languages.Count+1%>">
						<input type="text" name="search_key" value="<%=search_key%>" class="formFieldTXTLangKeyword">
					</td>			
				  </tr>
				</form>
				<tr> 
				<th colspan="2">&nbsp;</th>
				<th><%=lang.getTranslated("backend.multilingue.lista.table.header.keyword")%></th>
				<%foreach(Language k in languages){%>
					<th class="upper"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%></th>
				<%}%>
				</tr> 
				<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" name="form_inserisci" accept-charset="UTF-8">
				<input type="hidden" value="" name="id">
				<input type="hidden" value="" name="operation">
				<input type="hidden" value="0" name="is_multiple_selection">
				<input type="hidden" value="<%=itemsXpage%>" name="items">
				<input type="hidden" name="search_key" value="<%=search_key%>">
				<input type="hidden" value="<%=numPage%>" name="page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				  <tr height="35">
					<td colspan="2" align="center"><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.multilingue.lista.button.label.inserisci")%>" onclick="javascript:insertLanguage();" /></td>
					<td><input type="text" name="keyword" value="" class="formFieldTXTLangKeyword"></td>
					<%foreach(Language k in languages){%>
						<td><input type="text" name="value_<%=k.label%>" value="" class="formFieldTXTLang"></td>
					<%}%>
				  </tr>	
				</form>			

		      <tr> 
				<th colspan="<%=3+languages.Count%>" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				<input type="hidden" value="<%=(string)Session["search_key"]%>" name="search_key">
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
				<th class="icons" width="70" nowrap>
					<a href="javascript:modifyAllSelectedLanguage();"><img src="/backoffice/img/accept.png" alt="<%=lang.getTranslated("backend.multilingue.lista.table.alt.modify_sel_lang")%>" hspace="2" vspace="0" border="0"></a>
					<input type="checkbox" value="" id="ck_do_select_all" name="ck_do_select_all" onclick="javascript:selectAllLanguageKey();"/>
					<a href="javascript:deleteAllSelectedLanguage();"><img src="/backoffice/img/delete.png" alt="<%=lang.getTranslated("backend.multilingue.lista.table.alt.delete_sel_lang")%>" hspace="2" vspace="0" border="0"></a>
				</th>
				<th width="70">&nbsp;</th>
				<th><%=lang.getTranslated("backend.multilingue.lista.table.header.keyword")%></th>
				<%foreach(Language k in languages){%>
					<th class="upper"><%=lang.getTranslated("backend.lingue.lista.table.lang_label."+k.description)%></th>
				<%}%>
				</tr> 
				<%
				int keycounter = 0;
				foreach(string k in distKeys){%>
						<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" id="form_lista_<%=keycounter%>" name="form_lista_<%=keycounter%>" accept-charset="UTF-8">
						<tr>
						<td class="icons" width="70"><input type="checkbox" value="" name="ck_select_all"/></td>
						<td class="icons" width="70" nowrap>
						<input type="hidden" value="<%//=k.id%>-1" name="id">
						<input type="hidden" value="" name="operation">
						<input type="hidden" value="0" name="is_multiple_selection">
						<input type="hidden" name="search_key" value="<%=search_key%>">
						<input type="hidden" value="<%=itemsXpage%>" name="items">
						<input type="hidden" value="<%=numPage%>" name="page"> 
						<input type="hidden" value="<%=cssClass%>" name="cssClass">
						<a href="javascript:modifyLanguage(document.form_lista_<%=keycounter%>);"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.multilingue.lista.table.alt.modify_lang")%>" hspace="5" vspace="0" border="0"></a><a href="javascript:deleteLanguage(document.form_lista_<%=keycounter%>);"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.multilingue.lista.table.alt.delete_lang")%>" hspace="5" vspace="0" border="0"></a>
						</td>
						<td><input type="text" name="keyword" value="<%=k%>" class="formFieldTXTLangKeyword"></td>
						<%foreach(Language q in languages){
							MultiLanguage element = null;
							int tmpid = 0;
							string tmpval = "";
							multilanguages.TryGetValue(q.label+"-"+k, out element);
							if(element!=null){
								tmpid = element.id;
								tmpval = element.value;
							}
							%>
							<td>
							<input type="hidden" value="<%=tmpid%>" name="klid_<%=q.label%>">
							<input type="text" name="value_<%=q.label%>" value="<%=tmpval%>" class="formFieldTXTLang">
							</td>	
						<%}%>
						</tr>				
						</form>						
						<%keycounter++;
				}%> 
		

		      <tr> 
				<th colspan="<%=3+languages.Count%>" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" name="item_x_page">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">
				<input type="hidden" value="<%=(string)Session["search_key"]%>" name="search_key">
				<input type="hidden" value="1" name="page">	
				<input type="text" name="items" class="formFieldTXTNumXPage" value="<%=itemsXpage%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
				</div>
				</th>
		      </tr>			
				<%		 	
			}%>
		</table>
		<br/><br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>

<form action="/backoffice/multilanguages/multilanguagelist.aspx" method="post" name="form_lista_multi_select" accept-charset="UTF-8">
<input type="hidden" value="1" name="is_multiple_selection">
<input type="hidden" value="" name="operation">
<input type="hidden" value="" name="multiple_values">
<input type="hidden" value="<%=itemsXpage%>" name="items">
<input type="hidden" name="search_key" value="<%=search_key%>">
<input type="hidden" value="<%=cssClass%>" name="cssClass">
</form>
</body>
</html>