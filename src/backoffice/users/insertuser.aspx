<%@ Page Language="C#" AutoEventWireup="true" CodeFile="insertuser.aspx.cs" Inherits="_User" Debug="false" ValidateRequest="false"%>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script type="text/javascript" src="/common/js/highcharts.js"></script>
<script language="JavaScript">
function insertUser(){
	if(controllaCampiInput()){
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function controllaCampiInput(){		
	//valorizzo il campo nascosto "usr_languages" con la lista delle lingue separate da "|"
	var strLanguages = "";
	strLanguages+=listLanguages
	if(strLanguages.charAt(strLanguages.length -1) == "|"){
		strLanguages = strLanguages.substring(0, strLanguages.length -1);
	}	
	document.form_inserisci.usr_languages.value = strLanguages;
	//alert("usr_languages:"+document.form_inserisci.usr_languages.value+";");
	
	
	if(document.form_inserisci.username.value == ""){
		alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.insert_username")%>");
		document.form_inserisci.username.focus();
		return false;
	}
	
	<%if(user.id==-1){%>
	if(document.form_inserisci.password.value == ""){
		alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.insert_pwd")%>");
		document.form_inserisci.password.focus();
		return false;
	}
	<%}%>
	if(document.form_inserisci.password.value != document.form_inserisci.conferma_password.value){
		alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.pwd_no_match")%>");
		document.form_inserisci.conferma_password.focus();
		return false;
	}

	var strMail = document.form_inserisci.email.value;
	if(strMail != ""){
		if (strMail.indexOf("@")<2 || strMail.indexOf(".")==-1 || strMail.indexOf(" ")!=-1 || strMail.length<6){
			alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.wrong_mail")%>");
			document.form_inserisci.email.focus();
			return false;
		}
	}else if(strMail == ""){
		alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.insert_mail")%>");
		document.form_inserisci.email.focus();
		return false;
	}	
/*<!--nsys-usrins2-->*/
	if(document.form_inserisci.discount.value != "") {
		var scontoTmp = document.form_inserisci.discount.value;
		if(!checkDoubleFormat(scontoTmp) || scontoTmp.indexOf(".")!=-1){
			alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.isnan_value")%>");
			document.form_inserisci.discount.value = "0,00";
			document.form_inserisci.discount.focus();
			return false;
		}
	}else{
		alert("<%=lang.getTranslated("backend.utenti.detail.js.alert.insert_sconto")%>");
		document.form_inserisci.discount.value = "0,00";
		document.form_inserisci.discount.focus();
		return false;		
	}
/*<!---nsys-usrins2-->*/

	<%if(bolFoundFields) {
		Response.Write(UserService.renderFieldJsFormValidation(usrfields, user, lang.currentLangCode, lang.defaultLangCode));
	}%>


	if(document.form_inserisci.ck_newsletter.checked == false){
		document.form_inserisci.newsletter.value = "false";	
	}else{
		document.form_inserisci.newsletter.value = "true";		
	}
	
	return true;
}

function replaceChars(inString){
	var outString = inString;

	for(a = 0; a < outString.length; a++){
		if(outString.charAt(a) == '"'){
			outString=outString.substring(0,a) + "&quot;" + outString.substring(a+1, outString.length);
		}
	}
	return outString;
}

function checkNewsletter(formField){	
	if(document.form_inserisci.ck_newsletter.checked == false){
		formField.checked = false;
	}	
}

function uncheckNewsletter(){	
	if(document.form_inserisci.ck_newsletter.checked == false){
		if(document.form_inserisci.list_newsletter != null){
			if(document.form_inserisci.list_newsletter.length == null){
				document.form_inserisci.list_newsletter.checked = false;
			}else{
				for(i=0; i<document.form_inserisci.list_newsletter.length; i++){				
					document.form_inserisci.list_newsletter[i].checked = false;
				}
			}
		}
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
		<table class="principal" border="0" align="top" cellpadding="0" cellspacing="0">
		<form action="/backoffice/users/insertuser.aspx" method="post" name="form_inserisci">
		  <input type="hidden" value="<%=user.id%>" name="id">
		  <input type="hidden" value="insert" name="operation">
		  <input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">	
<!--nsys-usrins3-->
<!---nsys-usrins3-->
			<tr>
			<td width="300">	 		  
		    <span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.username")%></span><br>
			<%if (user.id != -1) {%>
				<div><%="<b>"+user.username+"</b>"%></div>
				<%
				long total = 0;
				long percentual = 0;
				total = preftrep.countTotal(user.id, true);
				percentual = preftrep.getPositivePercentage(user.id);

				long total_comment_news = commentrep.countComments(user.id,1,true,false);
				//<!--nsys-usrins4-->
				long total_comment_prod = commentrep.countComments(user.id,2,true,false);
				//<!---nsys-usrins4-->				
				%>
				<div style="padding-left:0px;padding-top:3px;" class="txtUserPreference">
				<%=lang.getTranslated("backend.utenti.detail.table.label.like")%>:&nbsp;<%=percentual%>%<br/>				
				<script type="text/javascript">
				$(function () {
				  var chart;
				  $(document).ready(function() {
				    chart = new Highcharts.Chart({
				      chart: {
					renderTo: 'usrprefchartbox',
					type: 'bar',
					width: 100,
					height: 70,
					spacingTop:-20,
					marginLeft:-1,
					marginRight:0
				      },
				      title: {
					text: ''
				      },
				      xAxis: {
					categories: [''],
					gridLineWidth:0
				      },
				      yAxis: {
					title: {
					  text: ''
					},
					min: 0,
					max:100,
					showFirstLabel:false,
					showLastLabel:false,
					gridLineWidth:0
				      },
				      tooltip: {
					enabled: false
				      },            
				      legend: {
					enabled: false
				      },
				      series: [{
					data: [
					{
					  color: 'blue',
					  y: <%=percentual%>
					}
					]
				      }]
				    });
				  });
				});
				</script>
				<div align="left" id="usrprefchartbox" style="width:100px;height:5px;border:#000000 1px solid;overflow: hidden;"></div>	
				<%=lang.getTranslated("backend.utenti.detail.table.label.total_vote")%>:&nbsp;<%=total%><br/>
				<%=lang.getTranslated("backend.utenti.detail.table.label.total_commenti_news")%>:&nbsp;<%=total_comment_news%>
<!--nsys-usrins5-->
				<br/><%=lang.getTranslated("backend.utenti.detail.table.label.total_commenti_prod")%>:&nbsp;<%=total_comment_prod%>
<!---nsys-usrins5-->
				<div><%=lang.getTranslated("backend.utenti.detail.table.label.date_insert").ToLower()+": "+user.insertDate.ToString("dd/MM/yyyy HH:mm")%></div>
				<div><%=lang.getTranslated("backend.utenti.detail.table.label.last_modify")+": "+user.modifyDate.ToString("dd/MM/yyyy HH:mm")%></div>
				</div>
				<input type="hidden" name="username" value="<%=user.username%>">
			<%}else{%>
				<input type="text" name="username" value="<%=user.username%>" class="formFieldTXT">
			<%}%>
			</td>
			<td>								
			<span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.password")%></span><br>
			<input type="password" name="password" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialCharAndSpace(event);">
			<br>
			<span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.conf_password")%></span><br>
			<input type="password" name="conferma_password" value="" class="formFieldTXT" onkeypress="javascript:return notSpecialCharAndSpace(event);">
			<br/>
			<!--nsys-usrins8-->
			<br/><span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.user_group")%></span><br>
			<select name="user_group" class="formFieldTXT">
			<option value=""></option>
				<%foreach(UserGroup ug in groupsu){%>
				<option value="<%=ug.id%>" <%if (groupid == ug.id) { Response.Write("selected");}%>><%=ug.shortDesc%></option>
				<%}%>
			</select>
			<!---nsys-usrins8-->
			</td>
			<td><span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.user_role")%></span><br/>
              <select name="role" class="formFieldTXT">
				<%
				int roleid = -1;
				foreach(int labelr in UserRole.roles()){
				if(user.role!=null){roleid=user.role.id;}%>
				<option value="<%=labelr%>" <%if (roleid == labelr) { Response.Write("selected");}%>><%=UserRole.UppercaseFirst(Enum.GetName(typeof(UserRole.Roles), labelr).ToLower())%></option>
				<%}%>
				</SELECT>	
              </select>
	      <br><br>
              <span class="labelForm">
              <%=lang.getTranslated("backend.utenti.detail.table.label.user_active")%><br/>
              <select name="user_active" class="formFieldSelectSimple">
                <OPTION VALUE="0" <%if (!user.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
                <OPTION VALUE="1" <%if (user.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
              </select>
              </span>
	      <br><br>	      
              <span class="labelForm">
              <%=lang.getTranslated("backend.utenti.detail.table.label.public_profile")%><br/>
              <select name="public_profile" class="formFieldSelectSimple">
                <OPTION VALUE="0" <%if (!user.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></OPTION>
             	<OPTION VALUE="1" <%if (user.isPublicProfile) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></OPTION>
                 </select>
              </span>		
		</td>
		</tr>

		<tr>
		<td>			
		<span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.email")%></span><br>
		<input type="text" name="email" value="<%=user.email%>" class="formFieldTXT">
		</td>
		<td>
<!--nsys-usrins7-->
		<br><span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.sconto")%></span>&nbsp;
		<input type="text" name="discount" value="<%=user.discount.ToString()%>" class="formFieldTXTShort" maxlength="5" onkeypress="javascript:return isDouble(event);">
		  % 
<!---nsys-usrins7-->
		</td>
		<td>&nbsp;</td>
		</tr>

		<tr>
		<td colspan="3">&nbsp;</td>
		</tr>



		<tr>
		<td colspan="3">
		<%if(bolFoundFields) {
			string style = "text-align:left;vertical-align:top;padding-right:10px;min-width:250px;height:30px;padding-bottom:20px;";
			Response.Write(UserService.renderField(usrfields, user, null, style, "user-fields", lang.currentLangCode, lang.defaultLangCode, "1,3"));
		}%>
		</td>
		</tr>

			
			<tr>		
			<td colspan="3" align="left" nowrap><br/>
			<%=CategoryService.renderCategoryBox(lang.getTranslated("backend.utenti.detail.table.label.categories"), categories, lang.currentLangCode, lang.defaultLangCode, user, "usr_categories", false, null)%>
			<br/>			
			
			<input type="hidden" value="" name="usr_languages">	
			<br><br>
			<%=UserService.renderTargetBox("listLanguages", "langbox_sx", "langbox_dx", lang.getTranslated("backend.utenti.detail.table.label.language_x_user"), lang.getTranslated("backend.utenti.detail.table.label.language_disp"), usrlanguages, languages, true, true, lang.currentLangCode, lang.defaultLangCode)%>		
			<br>
			</td>
			</tr>
			<tr>		
			<td valign="top">
			  <span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.admin_comments")%></span><br>
			<textarea name="admin_comments" class="formFieldAdminComments"><%=user.boComments%></textarea>
			</td>
			<td colspan="2">	
			  <input type="checkbox" value="true" name="ck_newsletter" <%if (user.hasNewsletter) { Response.Write("checked");}%> onclick="uncheckNewsletter();">&nbsp;<span class="labelForm"><%=lang.getTranslated("backend.utenti.detail.table.label.subscribe_newsletter")%></span>
              <br>
              <input type="hidden" name="newsletter" value="">
				<input type="hidden" name="privacy" value="true">
				<%if(newsletters!=null) {
					foreach(Newsletter x in newsletters){
						string chechedVal = "";										
						if(user.newsletters!=null){
							foreach(UserNewsletter un in user.newsletters){
								if(un.newsletterId==x.id){
									chechedVal = " checked='checked'";
									break;
								}
							}
						}
						%>
						<input type="checkbox" value="<%=x.id%>" onclick="checkNewsletter(this);" name="list_newsletter" <%=chechedVal%>>&nbsp;<%=x.description%><br/>				  
					<%}%>
				<%}%>
			</td>
		  </tr>
		</form>				
		</table><br/>			    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.utenti.detail.button.inserisci.label")%>" onclick="javascript:insertUser();" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/users/userlist.aspx?cssClass=LU';" />
		<br/><br/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>