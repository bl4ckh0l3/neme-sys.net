<%@ Page Language="C#" AutoEventWireup="true" CodeFile="inserttemplatemail.aspx.cs" Inherits="_Mail" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Net.Mail" %>
<%@ import Namespace="System.Net.Mime" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ Register Assembly="FredCK.FCKeditorV2" Namespace="FredCK.FCKeditorV2" TagPrefix="FCKeditorV2" %>
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
<CommonUserLogin:insert runat="server" acceptedRoles="1" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<CommonMeta:insert runat="server" />
<CommonCssJs:insert runat="server" />
<script language="JavaScript">
function insertMail(savesc){
	if(controllaCampiInput()){
		if(savesc==0){
			document.form_inserisci.savesc.value=0;
		}
		
		document.form_inserisci.submit();
	}else{
		return;
	}
}

function controllaCampiInput(){		
	if(document.form_inserisci.name.value == ""){
		alert("<%=lang.getTranslated("backend.mails.detail.js.alert.insert_name")%>");		
		document.form_inserisci.name.focus();
		return false;
	}
		
	return true;
}

var tempX = 0;
var tempY = 0;

jQuery(document).ready(function(){
	$(document).mousemove(function(e){
	tempX = e.pageX;
	tempY = e.pageY;
	}); 
})

function showDiv(elemID){
	var element = document.getElementById(elemID);
	var jquery_id= "#"+elemID;

	element.style.left=tempX+10;
	element.style.top=tempY+10;
	$(jquery_id).show(500);
	element.style.visibility = 'visible';		
	element.style.display = "block";
}

function hideDiv(elemID){
	var element = document.getElementById(elemID);

	element.style.visibility = 'hidden';
	element.style.display = "none";
}
</script>
</head>
<body>
<div id="backend-warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">
		<CommonMenu:insert runat="server" />
		<div id="backend-content">
			<table border="0" cellspacing="0" cellpadding="0" class="principal">
		<form action="/backoffice/mails/inserttemplatemail.aspx" method="post" name="form_inserisci" enctype="multipart/form-data" accept-charset="UTF-8">
		  <input type="hidden" value="<%=mail.id%>" name="id">
		  <input type="hidden" value="insert" name="operation">
		  <input type="hidden" value="1" name="savesc">
		  <input type="hidden" value="<%=Request["cssClass"]%>" name="cssClass">			
			<tr> 		  		  
			  <td align="left" valign="top" width="223">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.name")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_name');" class="labelForm" onmouseout="javascript:hideDiv('help_name');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_name">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_name")%>
				</div><br/>
				<input class="formFieldTXT" type="text" name="name" value="<%=mail.name%>">			  
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top" width="30%">			
			<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.description")%></span><br/>
			<textarea name="description" class="formFieldTXTAREA"><%=mail.description%></textarea>			
			</td>			  
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top"><span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.language")%></span><br/>
				<select name="mlang_code">
					<option value=""><%=lang.getTranslated("backend.mails.detail.table.label.neutral")%></option>
					<%foreach (Language w in languages){%>
						<option value="<%=w.label%>" <%if(w.label==mail.langCode){Response.Write(" selected");}%>><%=lang.getTranslated("portal.header.label.desc_lang."+w.label)%></option>
					<%}%>
				</select>
				</td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 		  		  
			<td align="left" valign="top">
		  <div align="left" style="float:left;"><span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.mail_category")%></span><br>
			<select name="mail_category" class="formFieldSelectSimple">
			<option value=""></option>
			<%
			try{
			IList<MailCategory> mcl = mailrep.findCategories();
			string compcat = "";
			if(mail.mailCategory!=null){compcat=mail.mailCategory.name;}
			foreach(MailCategory mc in mcl){%>
				<OPTION VALUE="<%=mc.name%>" <%if (mc.name==compcat) { Response.Write("selected");}%>><%=mc.name%></OPTION>
			<%}
			}catch(Exception ex){}
			%>
			</select>
		  </div>
		  <br><br>			
		  	</td>		  
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top">
			  <div align="left" style="text-align:left;display:block;">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.insert_category")%></span><br>
				<input type="text" name="new_mail_category" id="new_mail_category"  value="" class="formFieldTXT" onkeypress="javascript:return notSpecialChar(event);">
			  </div>	
			  </td>		  
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top">
			  	<div style="float:left;padding-right:20px;" id="body_html_container">  
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.body_html")%></span><br/>
				<select id="is_body_html" name="is_body_html" class="formFieldTXTShort">
					<option value="1" <%if (mail.isBodyHTML || mail.id==-1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
					<option value="0" <%if (!mail.isBodyHTML && mail.id!=-1) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
				</select>
				</div>	
				<div style="display:inline;" id="ext_body_container">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.ext_body")%></span><br/>
				<select name="is_ext_body" id="is_ext_body" class="formFieldTXTShort">
					<option value="0"><%=lang.getTranslated("backend.commons.no")%></option>
					<option value="1"><%=lang.getTranslated("backend.commons.yes")%></option>
					</select>	
				</div>	
				<script>
				jQuery(document).ready(function(){
					$("#is_ext_body").val(0);	
					if($("#is_body_html").val()==0){		
						$("#ext_body_container").hide();
						$("#mail_body_external").hide();
						$("#mail_body_html_internal").hide();
						$("#mail_body_text_internal").show();
					}else{
						$("#mail_body_text_internal").hide();
						$("#ext_body_container").show();
						$("#mail_body_html_internal").show();	
					} 
				});				
				
								
				$('#is_body_html').change(function() {
					var body_html_val_ch = $('#is_body_html').val();
					if(body_html_val_ch==1){
						$('#is_ext_body').val(0);				
						$("#ext_body_container").show();	
						$("#mail_body_external").hide();
						$("#mail_body_text_internal").hide();
						$("#mail_body_html_internal").show();				
					}else{
						$("#ext_body_container").hide();	
						$('#is_ext_body').val(0);
						$("#mail_body_external").hide();
						$("#mail_body_html_internal").hide();
						$("#mail_body_text_internal").show();			
					}
				});	
							
				$('#is_ext_body').change(function() {
					var ext_body_val_ch = $('#is_ext_body').val();
					if(ext_body_val_ch==1){
						$("#mail_body_html_internal").hide();	
						$("#mail_body_text_internal").hide();				
						$("#mail_body_external").show();			
					}else{
						$("#mail_body_external").hide();
						if($('#is_body_html').val()==0){
							$("#mail_body_text_internal").show();
						}else{
							$("#mail_body_html_internal").show();							
						}				
					}
				});
				</script>
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.active")%></span><br/>
			<select name="active" class="formFieldTXTShort">
				<option value="1" <%if (mail.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
				<option value="0" <%if (!mail.isActive) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
			</select>				  	    
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.base")%></span><br/>
				<select name="base" class="formFieldTXTShort">
					<option value="1" <%if (mail.isBase) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.yes")%></option>
					<option value="0" <%if (!mail.isBase) { Response.Write("selected");}%>><%=lang.getTranslated("backend.commons.no")%></option>
				</select>	 			  
			  </td>
			  <td align="left" valign="top">&nbsp;</td>
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.priority")%></span><br/>
				<select name="priority" class="formFieldTXT">
					<option value="1" <%if (mail.priority==1) { Response.Write("selected");}%>><%=MailPriority.Normal.ToString()%></option>
					<option value="2" <%if (mail.priority==2) { Response.Write("selected");}%>><%=MailPriority.Low.ToString()%></option>
					<option value="3" <%if (mail.priority==3) { Response.Write("selected");}%>><%=MailPriority.High.ToString()%></option>
				</select>	 		    			  
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.sender")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_sender');" class="labelForm" onmouseout="javascript:hideDiv('help_sender');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_sender">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_sender")%>
				</div><br/>
			    <input type="text" name="sender" value="<%=mail.sender%>" class="formFieldTXT">
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.receiver")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_receiver');" class="labelForm" onmouseout="javascript:hideDiv('help_receiver');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_receiver">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_receiver")%>
				</div><br/>
			<input type="text" name="receiver" value="<%=mail.receiver%>" class="formFieldTXT">
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
				<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.subject")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_subject');" class="labelForm" onmouseout="javascript:hideDiv('help_subject');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_subject">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_subject")%>
				</div><br/>
			<input type="text" name="subject" value="<%=mail.subject%>" class="formFieldTXT"><a href="javascript:showHideDiv('subject_ml');" class="labelForm"><img width="25" height="25" border="0" style="padding-left:0px;padding-right:0px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" title="<%=lang.getTranslated("portal.header.label.desc_lang.translate_ml")%>" src="/backoffice/img/multilanguages5.jpeg"></a>	
			<br/>
			<div style="visibility:hidden;position:absolute;background-color: #DEE4E8;border:1px solid #000;padding:2px;" id="subject_ml">
			<%
			foreach (Language x in languages){%>
			<input type="text" hspace="2" vspace="2" name="subject_<%=x.label%>" id="subject_<%=x.label%>" value="<%=mlangrep.translate("backend.mails.detail.table.label.subject_"+mail.subject, x.label, lang.defaultLangCode)%>" class="formFieldTXTInternationalization">
			&nbsp;<img width="16" height="11" border="0" style="padding-left:5px;padding-right:5px;vertical-align:middle;" alt="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" title="<%=lang.getTranslated("portal.header.label.desc_lang."+x.label)%>" src="/backoffice/img/flag/flag-<%=x.label%>.png"><br/>
			<%}%>			
			</div>			  
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.cc")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_cc');" class="labelForm" onmouseout="javascript:hideDiv('help_cc');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_cc">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_cc")%>
				</div><br/>
			    <input type="text" name="cc" value="<%=mail.cc%>" class="formFieldTXT">
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.bcc")%></span>&nbsp;<a href="#" onMouseOver="javascript:showDiv('help_bcc');" class="labelForm" onmouseout="javascript:hideDiv('help_bcc');">?</a>
				<div align="left" style="z-index:1000;position:absolute;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;" id="help_bcc">
				<%=lang.getTranslated("backend.mails.detail.table.label.field_help_bcc")%>
				</div><br/>
			<input type="text" name="bcc" value="<%=mail.bcc%>" class="formFieldTXT">
			  </td>
			  <td align="center" valign="middle">&nbsp;</td>
			  <td align="left" valign="top">
			<span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.last_modify")%></span><br/>
			<%if(mail.id!=-1){Response.Write(mail.modifyDate.ToString("dd/MM/yyyy"));}%>			
			  </td>
			</tr>
			<tr> 
			  <td align="left" valign="top" colspan="5" height="20">&nbsp;</td>
			</tr>
			<tr> 
			  <td align="center" valign="top" colspan="5">
			  <span class="labelForm"><%=lang.getTranslated("backend.mails.detail.table.label.body")%></span><br/>
			 <div id="mail_body_html_internal" style="display:none;">	
			<FCKeditorV2:FCKeditor ID="body_html" ImageBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" LinkBrowserURL="/fckeditor/editor/filemanager/browser/default/browser.html?Type=Image&Connector=/fckeditor/editor/filemanager/connectors/aspx/connector.aspx" Width="600px" Height="300px" runat="server"></FCKeditorV2:FCKeditor>			 
			 </div>
			 <div id="mail_body_text_internal" style="display:none;">	
			 <textarea name="body_text" class="formFieldTXTAREAMail"><%=mail.body%></textarea>
			 </div>
			 <div id="mail_body_external" style="display:none;">	
			 <input id="body_external" type="file" runat="server">
			 </div>
			  </td>
			</tr>
			</form>	
			</table>
			<br/>	    
		  <input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.mails.detail.button.inserisci.label")%>" onclick="javascript:insertMail(0);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.mails.detail.button.inserisci_esc.label")%>" onclick="javascript:insertMail(1);" />&nbsp;&nbsp;<input type="button" class="buttonForm" hspace="2" vspace="4" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.commons.back")%>" onclick="javascript:location.href='/backoffice/mails/mailtemplatelist.aspx?cssClass=LMT';" />
		  <br/><br/>	
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>