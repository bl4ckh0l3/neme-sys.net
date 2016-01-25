<%@ Page Language="C#" AutoEventWireup="true" CodeFile="userlist.aspx.cs" Inherits="_UserList" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
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
function deleteUtente(theForm){
	if(confirm("<%=lang.getTranslated("backend.utenti.lista.js.alert.delete_user")%>")){
		theForm.operation.value = "delete";
		theForm.action = "/backoffice/users/userlist.aspx";
		theForm.submit();
	}

}

function deleteField(theForm){
	if(confirm("<%=lang.getTranslated("backend.utenti.lista.js.alert.delete_field")%>")){
		theForm.operation.value = "deleteField";
		theForm.action = "/backoffice/users/userlist.aspx";
		theForm.submit();
	}
}

function showHideDivUserField(element){
	var elementUl = document.getElementById("usrlist");
	var elementaUl = document.getElementById("ausrlist");
	var elementUf = document.getElementById("usrfield");
	var elementaUf = document.getElementById("ausrfield");

	if(element == 'usrlist'){
		elementUf.style.visibility = 'hidden';		
		elementUf.style.display = "none";
		elementaUf.className= "";
		elementUl.style.visibility = 'visible';
		elementUl.style.display = "block";
		elementaUl.className= "active";
	}else if(element == 'usrfield'){
		elementUl.style.visibility = 'hidden';
		elementUl.style.display = "none";
		elementaUl.className= "";
		elementUf.style.visibility = 'visible';		
		elementUf.style.display = "block";
		elementaUf.className= "active";
	}
}

function changeRowListData(listCounter, objtype, field){
	if(objtype.indexOf("User")>=0){
		var active = $("#user_active_"+listCounter).val();
		var render = "";

		if(active==1){
			render +=('<img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.utenti.lista.table.alt.used_user")%>" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.used_user")%>" hspace="5" vspace="0" border="0">');
		}else{
			render +='<a href="';
			render+="javascript:deleteUtente(document.form_lista_"+listCounter+");";
			render+='">';
			render +=('<img src="/backoffice/img/cancel.png" title="<%=lang.getTranslated("backend.utenti.lista.table.alt.delete_user")%>" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.delete_user")%>" hspace="5" vspace="0" border="0">');
			render +=('</a>');
		}
		
		$("#cancel_"+listCounter).empty();
		$("#cancel_"+listCounter).append(render);
	}
}

function sortUserParam(val){
	document.user_filter.order_by.value = val;
	document.user_filter.order_by_fields.value = "";
	document.user_filter.submit();	
}

function sortFilterUserParam(val){
	document.user_filter.order_by_fields.value = val;
	document.user_filter.order_by.value = "";
	document.user_filter.submit();	
}

function filterUserParam(){
	document.user_filter.submit();	
}

function showHideDivFilter(elemID){
	if ( $('#'+elemID).is(':visible')){
		$('#'+elemID).hide();
		document.user_filter.view_filter.value = 0;
	}else{
		$('#'+elemID).show();
		document.user_filter.view_filter.value = 1;
	}
}

function showHideDivFields(elemID){
	if ( $('.'+elemID).is(':visible')){
		$('.'+elemID).hide();
		document.user_filter.view_fields.value = 0;
	}else{
		$('.'+elemID).show();
		document.user_filter.view_fields.value = 1;
	}
}

function showHideDivMailBox(elemID){
	if ( $('#'+elemID).is(':visible')){
		$('#'+elemID).hide();
	}else{
		$('#'+elemID).show();
		$('#mailbox_error').empty();
		openMailbox();
	}
}

function openMailbox(){
	$.ajax({
		async: true,
		type: "GET",
		cache: false,
		url: "/backoffice/users/ajaxshowmailbox.aspx",
		success: function(response) {
			//alert("response: "+response);
			$("#mail_text_body").empty();
			$("#mail_text_body").append(response);
		},
		error: function() {
			//alert("errorrrrrrrrrr!");
			$("#mail_text_body").empty();
			$("#mail_text_body").append("<textarea class='formFieldTXTAREAAbstract' name='mail_body'></textarea>");
		}
	});
}

jQuery(document).ready(function(){
	showHideDivUserField('<%=showTab%>'); 
})
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">		
		<div id="tab-user-field"><a id="ausrlist" <%if(showTab=="usrlist"){ Response.Write("class=active");}%> href="javascript:showHideDivUserField('usrlist');"><%=lang.getTranslated("backend.utenti.lista.table.header.label_usr_list")%></a><a id="ausrfield" <%if(showTab=="usrfield"){Response.Write("class=active");}%> href="javascript:showHideDivUserField('usrfield');"><%=lang.getTranslated("backend.utenti.lista.table.header.label_usr_field")%></a></div>
		<div id="ajaxresp" align="center" style="background-color:#FFFF00; border:1px solid #000000; color:#000000; display:none;"></div>
		<div id="usrlist" style="visibility:hidden;/*display:block;*/margin:0px;padding:0px;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr>
				<td colspan="<%if(bolFoundField){ Response.Write(9+usrfields.Count); }else{ Response.Write("9");}%>">
				<form action="/backoffice/users/userlist.aspx" method="post" name="form_search" accept-charset="UTF-8">
				<input type="hidden" value="1" name="page">
				<input type="hidden" value="LU" name="cssClass">
				<input type="submit" value="<%=lang.getTranslated("backend.utenti.lista.label.search")%>" class="buttonForm" hspace="4">
				<input type="text" name="search_key" value="" class="formFieldTXTLong">	
				</form>
				<input type="button" value="<%=lang.getTranslated("backend.utenti.lista.label.fields_view_button")%>" class="buttonForm" hspace="4" onclick="javascript:showHideDivFields('filterrowfields');">
				<input type="button" value="<%=lang.getTranslated("backend.utenti.lista.label.filter_button")%>" class="buttonForm" hspace="4" onclick="javascript:showHideDivFilter('filterrow');">				
				</td>				
			</tr>
			<tr> 
			<th colspan="<%if(bolFoundField){ Response.Write(9+usrfields.Count); }else{ Response.Write("9");}%>" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="text" name="itemsList" class="formFieldTXTNumXPage" value="<%=itemsXpageList%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
			</div>
			</th>
			</tr>
			<tr id="filterrow">
				<form action="/backoffice/users/userlist.aspx" method="post" name="user_filter">
				<input type="hidden" value="usrlist" name="showtab">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="<%=Request["order_by"]%>" name="order_by">
				<input type="hidden" value="<%=Request["order_by_fields"]%>" name="order_by_fields">
				<input type="hidden" value="<%=Request["view_filter"]%>" name="view_filter">
				<input type="hidden" value="<%=Request["view_fields"]%>" name="view_fields">
				<th colspan="4" style="padding-left:100px;vertical-align: middle;"><input type="button" value="<%=lang.getTranslated("backend.utenti.lista.label.filter_button_apply")%>" class="buttonForm" style="border:1px solid #000000;padding-left:10px;padding-right:10px;" hspace="4" onclick="javascript:filterUserParam();"></th>
				<th>
				<select name="rolef" class="formfieldSelect" multiple="multiple" size="3">
				<option value=""></option>
				<%
				string selected;
				string[] arrRoles = null;
				if(!String.IsNullOrEmpty(rolef)){
					arrRoles = rolef.Split(',');				
				}
				foreach(int labelr in UserRole.roles()){
					selected = "";
					if(arrRoles!=null && arrRoles.Length>0){
						foreach(string x in arrRoles){
							if(Convert.ToInt32(x)==labelr){
								selected = " selected";
							}
						}
					}%>
					<option value="<%=labelr%>" <%=selected%>><%=UserRole.UppercaseFirst(Enum.GetName(typeof(UserRole.Roles), labelr).ToLower())%></option>
				<%}%>
				</SELECT>
				</th>
				<th>
				<select name="activef" class="formfieldSelect">
				<option value=""></option>
				<OPTION VALUE="false" <%if (Request["activef"]== "false") {Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
				<OPTION VALUE="true" <%if (Request["activef"]== "true") {Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
				</SELECT></td>
				<th>
				<select name="publicf" class="formfieldSelect">
				<option value=""></option>
				<OPTION VALUE="false" <%if (Request["publicf"]== "false") {Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
				<OPTION VALUE="true" <%if (Request["publicf"]== "true") {Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
				</SELECT></th>
				<th>&nbsp;</th>
				<th>&nbsp;</th>
				<%if(bolFoundField) {
					foreach (UserField uf in usrfields){%>
						<th class="filterrowfields">
						<%if(uf.type==1 || uf.type==7) {%>
							<select name="user_field_<%=uf.id%>" class="formfieldSelect" multiple size="3">
							<option value=""></option>								
							<%
							IDictionary<string,int> uniqueFieldsMatch = usrrep.getUniqueFieldsMatch(uf.id);
							if(uniqueFieldsMatch != null && uniqueFieldsMatch.Count>0){
								foreach(string ufmk in uniqueFieldsMatch.Keys){
									string isSelected="";
									bool doSelect=false;
									string refFieldVal = "";
									filteredFieldsActive.TryGetValue(uniqueFieldsMatch[ufmk], out refFieldVal);
									string[] splittedFilter = null;
									if(!String.IsNullOrEmpty(refFieldVal)){
										splittedFilter = refFieldVal.Split(',');
									}
									if(splittedFilter != null){
										foreach(string x in splittedFilter) {
											if(ufmk==x){
												doSelect=true;
												break;
											}
										}
									}
									if(doSelect){isSelected="selected";}
									string currvalue = UserService.translate("backend.utenti.detail.table.label.field_values_"+uf.description+"_"+ufmk, ufmk, lang.currentLangCode, lang.defaultLangCode);%>
									<option value="<%=ufmk%>" <%if (doSelect) {Response.Write(isSelected);}%>><%=currvalue%></option>
								<%}
							}%>
							</select>
						<%}%>
						</th>
					<%}
				}%>
				</form>
			</tr>
			
			<tr> 
				<th colspan="2">&nbsp;</th>
				<th onclick="javascript:sortUserParam(<%if(Request["order_by"]=="1"){ Response.Write("2"); }else{ Response.Write("1");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.utenti.lista.table.header.username" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.mail" runat="server" /></th>
				<th onclick="javascript:sortUserParam(<%if(Request["order_by"]=="3"){ Response.Write("4"); }else{ Response.Write("3");}%>);" style="cursor:pointer;text-decoration:underline;padding-right:80px;"><lang:getTranslated keyword="backend.utenti.lista.table.header.role" runat="server" /></th>
				<th class="upper" onclick="javascript:sortUserParam(<%if(Request["order_by"]=="5"){ Response.Write("6"); }else{ Response.Write("5");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.utenti.lista.table.header.user_active" runat="server" /></th>
				<th class="upper" onclick="javascript:sortUserParam(<%if(Request["order_by"]=="7"){ Response.Write("8"); }else{ Response.Write("7");}%>);" style="cursor:pointer;text-decoration:underline;"><lang:getTranslated keyword="backend.utenti.lista.table.header.public_profile" runat="server" /></th>
				<th style="padding-right:80px;"><lang:getTranslated keyword="backend.utenti.lista.table.header.group" runat="server" /></th>
				<th class="upper"><lang:getTranslated keyword="backend.utenti.lista.table.header.date_modify" runat="server" /></th>
				
				<%
				if(bolFoundField) {
					foreach (UserField uf in usrfields){
						string usrfieldlabel = UserService.translate("backend.utenti.detail.table.label.description_"+uf.description, uf.description, lang.currentLangCode, lang.defaultLangCode);%>
						<th class="filterrowfields" style="cursor:pointer;text-decoration:underline;padding-right:20px;"   onclick="javascript:sortFilterUserParam(<%=uf.id%>);"><%=usrfieldlabel%></th>
					<%}
				}%>	
			</tr>
			<%if(Request["view_filter"]!="1"){%>
				<script>
				$("#filterrow").hide();
				</script>
			<%}
												
			int counter = 0;				
			if(bolFoundLista)
			{
				//foreach (User k in users)
				for(counter = fromUsers; counter<= toUsers;counter++)
				{
					User k = users[counter];%>
					<form action="/backoffice/users/insertuser.aspx" method="post" name="form_lista_<%=counter%>">
					<input type="hidden" value="<%=k.id%>" name="id">
					<input type="hidden" value="" name="operation"> 
					<input type="hidden" value="usrlist" name="showtab">
					<input type="hidden" value="<%=cssClass%>" name="cssClass">	
					</form>		
					<tr class="<%if(counter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">	
					  <td align="center" width="25"><!--nsys-demoeditusr1--><a href="javascript:document.form_lista_<%=counter%>.submit();"><!---nsys-demoeditusr1--><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.modify_user")%>" hspace="2" vspace="0" border="0"></a></td>
						<%if(k.isActive) {%>
						<td align="center" width="25" id="cancel_<%=counter%>"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.used_user")%>" hspace="5" vspace="0" border="0"></td>					
						<%}else{%>
						<td align="center" width="25" id="cancel_<%=counter%>"><a href="javascript:deleteUtente(document.form_lista_<%=counter%>);"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.delete_user")%>" hspace="5" vspace="0" border="0"></a></td>										
						<%}%>						
						<td><%=k.username%></td>
						<td><%=k.email%></td>	
						<td>
						<div class="ajax" id="view_role_<%=counter%>" onmouseover="javascript:showHide('view_role_<%=counter%>','edit_role_<%=counter%>','role_<%=counter%>',500, true);">
						<%=k.role.labelU%>
						</div>
						<div class="ajax" id="edit_role_<%=counter%>">
						<select name="role" class="formfieldAjaxSelect" id="role_<%=counter%>" onblur="javascript:updateField('edit_role_<%=counter%>','view_role_<%=counter%>','role_<%=counter%>','User|IUserRepository|UserRole.id.int',<%=k.id%>,2,<%=counter%>);">		  
						<%foreach(int labelr in UserRole.roles()){%>
						<option value="<%=labelr%>" <%if (k.role.id == labelr) { Response.Write("selected");}%>><%=UserRole.UppercaseFirst(Enum.GetName(typeof(UserRole.Roles), labelr).ToLower())%></option>
						<%}%>
						</SELECT>	
						</div>
						<script>
						$("#edit_role_<%=counter%>").hide();
						</script>
						</td>
						<td>
						<div class="ajax" id="view_user_active_<%=counter%>" onmouseover="javascript:showHide('view_user_active_<%=counter%>','edit_user_active_<%=counter%>','user_active_<%=counter%>',500, true);">
						<%
						if (k.isActive) { 
							Response.Write(lang.getTranslated("backend.commons.yes"));
						}else{ 
							Response.Write(lang.getTranslated("backend.commons.no"));
						}
						%>
						</div>
						<div class="ajax" id="edit_user_active_<%=counter%>">
						<select name="isActive" class="formfieldAjaxSelect" id="user_active_<%=counter%>" onblur="javascript:updateField('edit_user_active_<%=counter%>','view_user_active_<%=counter%>','user_active_<%=counter%>','User|IUserRepository|bool',<%=k.id%>,2,<%=counter%>);">
						<OPTION VALUE="0" <%if (!k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (k.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_user_active_<%=counter%>").hide();
						</script>						
						</td>
						<td>
						<div class="ajax" id="view_public_profile_<%=counter%>" onmouseover="javascript:showHide('view_public_profile_<%=counter%>','edit_public_profile_<%=counter%>','public_profile_<%=counter%>',500, true);">
						<%
						if (k.isPublicProfile) { 
							Response.Write(lang.getTranslated("backend.commons.yes"));
						}else{ 
							Response.Write(lang.getTranslated("backend.commons.no"));
						}
						%>	
						</div>
						<div class="ajax" id="edit_public_profile_<%=counter%>">
						<select name="isPublicProfile" class="formfieldAjaxSelect" id="public_profile_<%=counter%>" onblur="javascript:updateField('edit_public_profile_<%=counter%>','view_public_profile_<%=counter%>','public_profile_<%=counter%>','User|IUserRepository|bool',<%=k.id%>,2,<%=counter%>);">
						<OPTION VALUE="0" <%if (!k.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
						<OPTION VALUE="1" <%if (k.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
						</SELECT>	
						</div>
						<script>
						$("#edit_public_profile_<%=counter%>").hide();
						</script>
						</td>
						<td style="padding-right:80px;">
						<div class="ajax" id="view_user_group_<%=counter%>" onmouseover="javascript:showHide('view_user_group_<%=counter%>','edit_user_group_<%=counter%>','user_group_<%=counter%>',500, true);">
						<%UserGroup groupu = usrrep.getUserGroup(k);
						if (groupu!=null) {
							Response.Write(groupu.shortDesc);
						}%>
						</div>
						<div class="ajax" id="edit_user_group_<%=counter%>">
						<select name="userGroup" class="formfieldAjaxSelect" id="user_group_<%=counter%>" onblur="javascript:updateField('edit_user_group_<%=counter%>','view_user_group_<%=counter%>','user_group_<%=counter%>','User|IUserRepository|int',<%=k.id%>,2,<%=counter%>);">
						<%							
						if(groupsu!=null){
							foreach(UserGroup ug in groupsu){%>
							<option value="<%=ug.id%>" <%if (k.userGroup == ug.id) { Response.Write("selected");}%>><%=ug.shortDesc%></option>
							<%}
						}%>
						</SELECT>	
						</div>
						<script>
						$("#edit_user_group_<%=counter%>").hide();
						</script>
						</td>
						<td><%=k.modifyDate.ToString("dd/MM/yyyy")%></td>

						<%if(bolFoundField) {
							foreach(UserField uf in usrfields){%>
								<td class="filterrowfields">
									<%
									string fieldMatchValue="";
									if(k.fields != null && k.fields.Count>0){
										foreach(UserFieldsMatch ufm in k.fields){
											if (ufm.idParentField==uf.id) {
												fieldMatchValue = ufm.value;
												break;
											}
										}
										Response.Write(fieldMatchValue);
									}%>
								</td>
							<%}
						}%>	
					</tr>			
				<%}
			}%>
			  
			<tr> 
				<th colspan="<%if(bolFoundField){ Response.Write(9+usrfields.Count); }else{ Response.Write("9");}%>" align="left">
				<div style="float:left;padding-right:3px;height:15px;">
				<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page">
				<input type="hidden" value="usrlist" name="showtab">
				<input type="hidden" value="<%=cssClass%>" name="cssClass">	
				<input type="hidden" value="1" name="page">	
				<input type="text" name="itemsList" class="formFieldTXTNumXPage" value="<%=itemsXpageList%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
				</form>
				</div>
				<div style="height:15px;">
				<CommonPagination:paginate ID="pg2" runat="server" index="2" maxVisiblePages="10" />
				</div>
				</th>
		      	</tr>
				
		<script>
		<%if(Request["view_fields"]!="1"){%>
		$('.filterrowfields').hide();
		<%}%>
		</script>
            </table>	    
		<br/>
		<form action="/backoffice/users/insertuser.aspx" method="post" name="form_crea">
		<input type="hidden" value="-1" name="id">
		<input type="hidden" value="LU" name="cssClass">
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.lista.button.inserisci.label")%>" onclick="javascript:document.form_crea.submit();" />
		&nbsp;&nbsp;
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.lista.download_csv")%>" onclick="javascript:openWinExcel('/backoffice/report/create-user-csv.aspx?<%=urlparamusrfilter.ToString()%>','crea_excel',400,400,100,100);" />&nbsp;&nbsp;
		<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.lista.button.inserisci.show_mail")%>" onclick="javascript:showHideDivMailBox('mail_communication_container');" />
		</form>
		
		<asp:Literal id="message" runat="server" />
		
		<div id="mail_communication_container" style="display:none;">
		<form action="/backoffice/users/userlist.aspx" method="post" name="mail_communication">
		<input type="hidden" value="usrlist" name="showtab">
		<input type="hidden" value="<%=mailAddressBCC%>" name="mail_bcc">
		<input type="hidden" value="1" name="do_send_mail">		
		<b><%=lang.getTranslated("backend.utenti.lista.button.inserisci.subject_mail")%></b><br/><input type="text" value="" name="mail_subject" class="formFieldTXTLong"><br/><br/>
		<b><%=lang.getTranslated("backend.utenti.lista.button.inserisci.text_mail")%></b><br/>
		<div id="mail_text_body"></div>
		<br/><input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.lista.button.inserisci.send_mail")%>" onclick="javascript:document.mail_communication.submit();" />		
		</form>		
		</div>	
		</div>
		
		<div id="usrfield" style="visibility:hidden;">
			<table class="principal" border="0" cellpadding="0" cellspacing="0" align="top">
			<tr> 
			<th colspan="11" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="usrfield" name="showtab">
			<input type="text" name="itemsField" class="formFieldTXTNumXPage" value="<%=itemsXpageField%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg3" runat="server" index="3" maxVisiblePages="10" />
			</div>
			</th>
			<tr> 
				<th colspan="2">&nbsp;</th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.description" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.group" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.order" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.type" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.type_content" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.required" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.enabled" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.use_for" runat="server" /></th>
				<th><lang:getTranslated keyword="backend.utenti.lista.table.header.apply_to" runat="server" /></th>
			</tr>
				<%						
				int fcounter = 0;				
				if(bolFoundField)
				{
					for(fcounter = fromFields; fcounter<= toFields;fcounter++)
					{
						UserField k = usrfields[fcounter];%>
						<form action="/backoffice/users/insertfield.aspx" method="post" name="form_lista_field_<%=fcounter%>">
						<input type="hidden" value="<%=k.id%>" name="id">
						<input type="hidden" value="" name="operation">
						<input type="hidden" value="usrfield" name="showtab">
						<input type="hidden" value="LU" name="cssClass">	
						</form>		
						<tr class="<%if(fcounter % 2 == 0){Response.Write("table-list-on");}else{Response.Write("table-list-off");}%>">
							<td align="center" width="25"><a href="javascript:document.form_lista_field_<%=fcounter%>.submit();"><img src="/backoffice/img/pencil.png" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.modify_field")%>" hspace="2" vspace="0" border="0"></a></td>
							<td align="center" width="25"><a href="javascript:deleteField(document.form_lista_field_<%=fcounter%>);"><img src="/backoffice/img/cancel.png" alt="<%=lang.getTranslated("backend.utenti.lista.table.alt.delete_field")%>" hspace="5" vspace="0" border="0"></a></td>										
							<td width="15%">						
							<div class="ajax" id="view_description_<%=fcounter%>" onmouseover="javascript:showHide('view_description_<%=fcounter%>','edit_description_<%=fcounter%>','description_<%=fcounter%>',500, false);"><%=k.description%></div>
							<div class="ajax" id="edit_description_<%=fcounter%>"><input type="text" class="formfieldAjax" id="description_<%=fcounter%>" name="description" onmouseout="javascript:restoreField('edit_description_<%=fcounter%>','view_description_<%=fcounter%>','description_<%=fcounter%>','UserField|IUserRepository|string|getUserFieldById|updateUserField',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.description%>"></div>
							<script>
							$("#edit_description_<%=fcounter%>").hide();
							</script>
							</td>
							<td width="18%">						
							<div class="ajax" id="view_id_group_<%=fcounter%>" onmouseover="javascript:showHide('view_id_group_<%=fcounter%>','edit_id_group_<%=fcounter%>','id_group_<%=fcounter%>',500, true);"><%=k.groupDescription%></div>
							<div class="ajax" id="edit_id_group_<%=fcounter%>">
							<select name="groupDescription" class="formfieldAjaxSelect" id="id_group_<%=fcounter%>" onblur="javascript:updateField('edit_id_group_<%=fcounter%>','view_id_group_<%=fcounter%>','id_group_<%=fcounter%>','UserField|IUserRepository|string|getUserFieldById|updateUserField',<%=k.id%>,2,<%=fcounter%>);">
								<option></option>
								<%foreach(string x in fieldGroupNames){%>
								<option value="<%=x%>" <%if(x==k.groupDescription){Response.Write("selected='selected'");}%>><%=x%></option>
								<%}%>
							</select>
							</div>
							<script>
							$("#edit_id_group_<%=fcounter%>").hide();
							</script>
							</td>
							<td>				
							<div class="ajax" id="view_order_<%=fcounter%>" onmouseover="javascript:showHide('view_order_<%=fcounter%>','edit_order_<%=fcounter%>','order_<%=fcounter%>',500, false);"><%=k.sorting%></div>
							<div class="ajax" id="edit_order_<%=fcounter%>"><input type="text" class="formfieldAjaxShort" id="order_<%=fcounter%>" name="sorting" onmouseout="javascript:restoreField('edit_order_<%=fcounter%>','view_order_<%=fcounter%>','order_<%=fcounter%>','UserField|IUserRepository|int|getUserFieldById|updateUserField',<%=k.id%>,1,<%=fcounter%>);" value="<%=k.sorting%>" maxlength="3" onkeypress="javascript:return isInteger(event);"></div>
							<script>
							$("#edit_order_<%=fcounter%>").hide();
							</script>
							</td>
							<td>
							<%foreach(SystemFieldsType x in systemFieldsType){
								if (x.id==k.type) {
									string stypeLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type.label."+x.description))){
										stypeLabel = lang.getTranslated("portal.commons.content_field.type.label."+x.description);
									}
									Response.Write(stypeLabel);
									break;
								}
								%>
							<%}%></td>
							<td>
							<%foreach(SystemFieldsTypeContent x in systemFieldsTypeContent){
								if (x.id==k.typeContent) {
									string stypecLabel = x.description;
									if(!String.IsNullOrEmpty(lang.getTranslated("portal.commons.content_field.type_content.label."+x.description))){
										stypecLabel = lang.getTranslated("portal.commons.content_field.type_content.label."+x.description);
									}
									Response.Write(stypecLabel);
									break;
								}
							}%></td>
							<td>
							<div class="ajax" id="view_required_<%=fcounter%>" onmouseover="javascript:showHide('view_required_<%=fcounter%>','edit_required_<%=fcounter%>','required_<%=fcounter%>',500, true);">
							<%
							if (k.required) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else {
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_required_<%=fcounter%>">
							<select name="required" class="formfieldAjaxSelect" id="required_<%=fcounter%>" onblur="javascript:updateField('edit_required_<%=fcounter%>','view_required_<%=fcounter%>','required_<%=fcounter%>','UserField|IUserRepository|bool|getUserFieldById|updateUserField',<%=k.id%>,2,<%=fcounter%>);">
							<OPTION VALUE="0" <%if (!k.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.required) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_required_<%=fcounter%>").hide();
							</script>
							</td>
							<td>
							<div class="ajax" id="view_enabled_<%=fcounter%>" onmouseover="javascript:showHide('view_enabled_<%=fcounter%>','edit_enabled_<%=fcounter%>','enabled_<%=fcounter%>',500, true);">
							<%
							if (k.enabled) { 
								Response.Write(lang.getTranslated("backend.commons.yes"));
							}else {
								Response.Write(lang.getTranslated("backend.commons.no"));
							}%>
							</div>
							<div class="ajax" id="edit_enabled_<%=fcounter%>">
							<select name="enabled" class="formfieldAjaxSelect" id="enabled_<%=fcounter%>" onblur="javascript:updateField('edit_enabled_<%=fcounter%>','view_enabled_<%=fcounter%>','enabled_<%=fcounter%>','UserField|IUserRepository|bool|getUserFieldById|updateUserField',<%=k.id%>,2,<%=fcounter%>);">
							<OPTION VALUE="0" <%if (!k.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
							<OPTION VALUE="1" <%if (k.enabled) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
							</SELECT>	
							</div>
							<script>
							$("#edit_enabled_<%=fcounter%>").hide();
							</script>
							</td>	
							<td width="12%">
							<div class="ajax" id="view_use_for_<%=fcounter%>" onmouseover="javascript:showHide('view_use_for_<%=fcounter%>','edit_use_for_<%=fcounter%>','use_for_<%=fcounter%>',500, true);">
							<%
							switch (k.useFor)
							{
								case 1:
									Response.Write(lang.getTranslated("backend.utenti.field.use_for.registration"));
									break;
								case 2:
									Response.Write(lang.getTranslated("backend.utenti.field.use_for.purchase"));
									break;
								case 3:
									Response.Write(lang.getTranslated("backend.utenti.field.use_for.all"));
									break;
								default:
									break;
							}%>
							</div>
							<div class="ajax" id="edit_use_for_<%=fcounter%>">
							<select name="useFor" class="formfieldAjaxSelect" id="use_for_<%=fcounter%>" onblur="javascript:updateField('edit_use_for_<%=fcounter%>','view_use_for_<%=fcounter%>','use_for_<%=fcounter%>','UserField|IUserRepository|int|getUserFieldById|updateUserField',<%=k.id%>,2,<%=fcounter%>);">
							<option value="1"<%if (1==k.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.use_for.registration")%></option>	
<!--nsys-usrlist6-->
							<option value="2"<%if (2==k.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.use_for.purchase")%></option>	
							<option value="3"<%if (3==k.useFor) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.use_for.all")%></option>	
<!---nsys-usrlist6-->
							</SELECT>	
							</div>
							<script>
							$("#edit_use_for_<%=fcounter%>").hide();
							</script>
							</td>
							<td width="12%">
							<div class="ajax" id="view_apply_to_<%=fcounter%>" onmouseover="javascript:showHide('view_apply_to_<%=fcounter%>','edit_apply_to_<%=fcounter%>','apply_to_<%=fcounter%>',500, true);">
							<%
							switch (k.applyTo)
							{
								case 0:
									Response.Write(lang.getTranslated("backend.utenti.field.applyto_front"));
									break;
								case 1:
									Response.Write(lang.getTranslated("backend.utenti.field.applyto_back"));
									break;
								case 2:
									Response.Write(lang.getTranslated("backend.utenti.field.applyto_both"));
									break;
								default:
									break;
							}%>
							</div>
							<div class="ajax" id="edit_apply_to_<%=fcounter%>">
							<select name="applyTo" class="formfieldAjaxSelect" id="apply_to_<%=fcounter%>" onblur="javascript:updateField('edit_apply_to_<%=fcounter%>','view_apply_to_<%=fcounter%>','apply_to_<%=fcounter%>','UserField|IUserRepository|int|getUserFieldById|updateUserField',<%=k.id%>,2,<%=fcounter%>);">
							<option value="0"<%if (0==k.applyTo) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.applyto_front")%></option>	
							<option value="1"<%if (1==k.applyTo) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.applyto_back")%></option>	
							<option value="2"<%if (2==k.applyTo) { Response.Write("selected");}%>><%=lang.getTranslated("backend.utenti.field.applyto_both")%></option>	
							</SELECT>	
							</div>
							<script>
							$("#edit_apply_to_<%=fcounter%>").hide();
							</script>
							</td>			
						</tr>				
					<%}
				}%>
			<tr> 
			<th colspan="11" align="left">
			<div style="float:left;padding-right:3px;height:15px;">
			<form action="<%=Request.Url.AbsolutePath%>" method="post" name="item_x_page_field">
			<input type="hidden" value="<%=cssClass%>" name="cssClass">	
			<input type="hidden" value="1" name="page">	
			<input type="hidden" value="usrfield" name="showtab">
			<input type="text" name="itemsField" class="formFieldTXTNumXPage" value="<%=itemsXpageField%>" title="<%=lang.getTranslated("backend.commons.lista.table.alt.item_x_page")%>" onblur="javascript:submit();" onkeypress="javascript:return isInteger(event);">
			</form>
			</div>
			<div style="height:15px;">
			<CommonPagination:paginate ID="pg4" runat="server" index="4" maxVisiblePages="10" />
			</div>
			</th>
			</tr>				  
		    </table>
			<br/>
			<form action="/backoffice/users/insertfield.aspx" method="post" name="form_crea_field">
			<input type="hidden" value="-1" name="id">
			<input type="hidden" value="LU" name="cssClass">
			<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.lista.button.inserisci_field.label")%>" onclick="javascript:document.form_crea_field.submit();" />
			</form>			
		</div>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>