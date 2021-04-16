<%@ Page Language="C#" AutoEventWireup="true" CodeFile="detail.aspx.cs" Inherits="_Detail" Debug="false" %>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="TellaFriendWidgetControl" TagName="render" Src="~/public/layout/addson/user/tellafriend-widget.ascx" %>
<%@ Register TagPrefix="CommentsWidgetWrapperControl" TagName="render" Src="~/public/layout/addson/comments/comments-widget-wrapper.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Register TagPrefix="CommonUserLogin" TagName="insert" Src="~/common/include/common-user-logged.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<script>
function sendMail(){
	<%
	if(contentFields.Count>0){ 
		Response.Write(ContentService.renderFieldJsFormValidation(contentFields, lang.currentLangCode, lang.defaultLangCode));
	}%>
	
	document.form_sendmail.submit();
}

function showMailToFriend(){
	$('#tellafriend_container').slideToggle();
}

function openAttach(path, fileName, idAttach, contentType){

	var query_string = "attach_id="+idAttach+"&attach_path="+path+"&page_url=<%=Request.Url%>&contenttype="+contentType+"&filename="+fileName;
	//alert(query_string);
	$.ajax({
		async: false,
		type: "POST",
		cache: false,
		url: "/public/layout/addson/tracking/ajaxlogdownload.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			
		},
		error: function() {
			//alert("error");
		}
	});	
	
	window.open('/public/upload/files/contents/'+path, '_blank');
}
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>
		<div style="clear:left;float:left;">
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>
		</div>
		<div id="content-center">
			<MenuFrontendControl:insert runat="server" ID="mf3" index="3" model="tips"/>
			<div align="left">
			<%if (content != null) {%>
				<div>
				<p><strong><asp:Literal id="ctitle" runat="server" /></strong></p>
				<asp:Literal id="csummary" runat="server" />
				<asp:Literal id="cdescription" runat="server" />
				
				<a href="javascript:showMailToFriend();"><%=lang.getTranslated("backend.utenti.mail.subject.label.tella_friend")%></a>
				<TellaFriendWidgetControl:render runat="server" ID="tfw1" index="tellafriend_container" style="display:none;position:absolute;width:auto;border:1px solid #000;background-color:#ffffff;padding:5px;"/><br/><br/>


				<%if(attachmentsDictionary.Keys.Count>0){ 
					foreach(string keyword in attachmentsDictionary.Keys){%>
						<br/><br/><strong><%=keyword%></strong><br/>
						<%foreach(ContentAttachment item in attachmentsDictionary[keyword]){
							// TODO gestire le singole tipologie di file con la forma di download corretta%>
							<!--<a href="javascript:openWin('/public/layout/include/popup.aspx?attachmentid=<%//=item.id%>&parent_type=1','popupallegati',400,400,100,100)"><%//=item.fileName%></a><br>-->
							<a href="javascript:openAttach('<%=item.filePath+item.fileName%>','<%=item.fileName%>','<%=item.id%>','<%=item.contentType%>')"><%=item.fileName%></a><br>
						<%}
					}
				}%>
				<asp:Literal id="mailRespMsg" runat="server" />				
				<form method="post" action="<%=currentUrl%>" name="form_sendmail">
				<input type="hidden" value="sendmail" name="operation">
				<input type="hidden" value="<%=hierarchy%>" name="hierarchy">
				<input type="hidden" value="<%=categoryid%>" name="categoryid">
				<input type="hidden" value="<%=numPage%>" name="page">
				<input type="hidden" value="<%=modelPageNum%>" name="modelPageNum">
				<input type="hidden" value="<%=content.id%>" name="contentid">
				<%if(contentFields.Count>0){ 
					Response.Write(ContentService.renderField(contentFields, null, "", "", lang.currentLangCode, lang.defaultLangCode));
				}%>
				<input type="button" name="send" value="<%=lang.getTranslated("portal.commons.button.label.sendmail")%>" onclick="javascript:sendMail();">
				</form>
				</div>				
				
				<div id="torna"><a href="/common/include/feedRSS.aspx?hierarchy=<%=hierarchy%>&contentid=<%=content.id%>&page=<%=numPage%>&modelPageNum=<%=modelPageNum%>" target="_blank"><img src="/common/img/rss_image.gif" vspace="3" hspace="3" border="0" align="right" alt="RSS"></a></div>
		
				<CommentsWidgetWrapperControl:render runat="server" ID="cwwc1" index="1"/>
			<%}else{%>
				<br/><br/><div align="center"><strong><lang:getTranslated keyword="portal.commons.templates.label.page_in_progress" runat="server" /></strong></div>
			<%}%>
			</div>
		</div>
		<br style="clear: left" />
		<div>
		<MenuFrontendControl:insert runat="server" ID="mf5" index="5" model="horizontal"/>
		</div>
	</div>
	<CommonFooter:insert runat="server" />
</div>
</body>
</html>