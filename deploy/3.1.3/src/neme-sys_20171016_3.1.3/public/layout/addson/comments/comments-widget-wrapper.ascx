<%@control Language="c#" description="comments-widget-wrapper-control" className="CommentsWidgetWrapperControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommentsWidget" TagName="render" Src="~/public/layout/addson/comments/comments-widget.ascx" %>
<script runat="server">  
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
private ConfigurationService configService;
protected string secureURL;
bool logged;

private string _elemId;	
public string elemId {
	get { return _elemId; }
	set { _elemId = value; }
}

private string _elemType;	
public string elemType {
	get { return _elemType; }
	set { _elemType = value; }
}

private string _from;	
public string from {
	get { return _from; }
	set { _from = value; }
}

private string _hierarchy;	
public string hierarchy {
	get { return _hierarchy; }
	set { _hierarchy = value; }
}

private string _categoryId;	
public string categoryId {
	get { return _categoryId; }
	set { _categoryId = value; }
}

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}

protected void Page_Load(Object sender, EventArgs e)
{ 
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	login.acceptedRoles = "3";
	logged = login.checkedUser();
	configService = new ConfigurationService();
	cw1.elemId = elemId;
	cw1.elemType = elemType;
	cw1.from = from;
	cw1.hierarchy = hierarchy;
	cw1.categoryId = categoryId;
	secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
}
</script>

<form action="<%=from%>" method="get" name="form_reload_page">
	<input type="hidden" name="hierarchy" value="<%=hierarchy%>">
	<input type="hidden" name="elemid" value="<%=elemId%>">
	<input type="hidden" name="elemtype" value="<%=elemType%>">
	<input type="hidden" name="page" value="<%=Request["page"]%>">
	<input type="hidden" name="modelPageNum" value="<%=Request["modelPageNum"]%>">
</form>

<script language="JavaScript">
  var commentWidgetX = 0;
  var commentWidgetY = 0;

  jQuery(document).ready(function(){
	 $(document).mousemove(function(e){
	  commentWidgetX = e.pageX;
	  commentWidgetY = e.pageY;
	 }); 
  })

  function prepareComment(){		
	var divcomment = document.getElementById("send-comment");
	var offsetx   = 400;
	var offsety   = 50;	
	  
	if(ie||mac_ie){
	divcomment.style.left=commentWidgetX-offsetx;
	divcomment.style.top=commentWidgetY-offsety;
	}else{
	divcomment.style.left=commentWidgetX-offsetx+"px";
	divcomment.style.top=commentWidgetY-offsety+"px";
	}

	$("#send-comment").show(1000);
	divcomment.style.visibility = "visible";
	divcomment.style.display = "block";
  }

  function sendForm(){    
    if(document.form_comment.comment_message.value == ""){
      alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
      return;
    }else{
      document.form_comment.submit();	
    }
  }

  function prepareVote(userid, id_comment, vote, comment_type){		
	var divvote = document.getElementById("send-vote");
	var offsetx   = 150;
	var offsety   = 150;	
	  
	if(ie||mac_ie){
	divvote.style.left=commentWidgetX-offsetx;
	divvote.style.top=commentWidgetY-offsety;
	}else{
	divvote.style.left=commentWidgetX-offsetx+"px";
	divvote.style.top=commentWidgetY-offsety+"px";
	}

	$("#send-vote").show(1000);
	divvote.style.visibility = "visible";
	divvote.style.display = "block";
	
	document.form_vote.userid.value=userid;
	document.form_vote.id_comment.value=id_comment;
	document.form_vote.comment_type.value=comment_type;
	document.form_vote.vote.value=vote;
	/** con le sei righe seguenti disabilito la comparsa del popup per il voto
	 immetto un messaggio standard = "a xx piace questo elemento" oppure "a xx non piace questo elemento"
	 per riabilitare l'inserimento di un messaggio da parte dell'utente oltre al voto commentare le sei righe seguenti
	 e decommentare il blocco precedente dello script **/
	/*if(vote==1){
		document.form_vote.message.value = "<%=lang.getTranslated("frontend.area_user.manage.label.likemsg")%>";
	}else{
		document.form_vote.message.value = "<%=lang.getTranslated("frontend.area_user.manage.label.nolikemsg")%>";
	}
	insertVote();*/
  }
  
  function insertVote(){
	$("#send-vote").hide();
	
	if(document.form_vote.message.value==""){
	  if(document.form_vote.vote.value==1){
		document.form_vote.message.value = "<%=lang.getTranslated("frontend.area_user.manage.label.likemsg")%>";
	  }else{
		document.form_vote.message.value = "<%=lang.getTranslated("frontend.area_user.manage.label.nolikemsg")%>";
	  }
	}
	
	document.form_vote.submit();      
  }

  function addFriend(divprofile, idfriend){
    if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.addthis")%>")){		
		var query_string = "userid="+idfriend+"&active=0&action=1";
	  
		$.ajax({
		   type: "POST",
		   cache: false,
		   url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
		   data: query_string,
			success: function(response) {
			  if(response==0){
			  	$("#"+divprofile+idfriend).hide();
				$('#friend_added').show();
			  }
			},
			error: function() {
			  $("#"+divprofile+idfriend).show();
				$('#friend_noadded').show();
			}
		 });		
    }
  }
  
  function hideVoteform(){
	var divvote = document.getElementById("send-vote");
	divvote.style.visibility = "hidden";
	divvote.style.display = "none";
  }
  
  function hideCommentform(){
	var divcomment = document.getElementById("send-comment");
	divcomment.style.visibility = "hidden";
	divcomment.style.display = "none";
  }

  function checkAjaxHasFriendNC(divprofile, id_friend, active){
	var query_string = "userid="+id_friend+"&active="+active+"&action=0";    
    
	$.ajax({
	   type: "POST",
	   cache: false,
	   url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
	   data: query_string,
		success: function(response) {
		  // show friend request icon
		  if(response==0){
		  $("#"+divprofile+id_friend).show();
		  }
		},
		error: function() {
		  $("#"+divprofile+id_friend).hide();
		}
	 });
  }

function checkAjaxHasFriendActiveNC(divprofile, divname, id_friend, usrnameCurrUser){
	var query_string = "userid="+id_friend+"&action=2";
	
	$.ajax({
		type: "POST",
		cache: false,
		url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			if(response!=1){
				$("#"+divname+id_friend).empty();
				$("#"+divprofile+id_friend).show();	
			}else{		
				$("#"+divprofile+id_friend).hide();
				$("#"+divname+id_friend).empty().append(usrnameCurrUser);		
			}
		},
		error: function() {
			$("#"+divprofile+id_friend).hide();
			$("#"+divname+id_friend).empty().append(usrnameCurrUser);
		}
	});
}
        

$(function() {
	$("#send-comment").draggable();
});

$(function() {
	$("#send-vote").draggable();
});
  </script>
<div id="send-vote" style="position:absolute;left:0px;top:0px;margin-bottom:3px;vertical-align:middle;text-align:center;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:15px;background:#FFFFFF;width:320px;">
		<form action="<%=secureURL%>area_user/insertvote.aspx" method="post" name="form_vote" accept-charset="UTF-8">		  
		<input type="hidden" value="" name="userid">
		<input type="hidden" name="vote">
		<input type="hidden" name="active" value="<%if("1".Equals(configService.get("use_comments_filter").value)) {Response.Write("0");}else{Response.Write("1");}%>">  
		<input type="hidden" name="id_comment">
		<input type="hidden" name="comment_type">
		<input type="hidden" name="elemid" value="<%=elemId%>">
		<input type="hidden" name="elemtype" value="<%=elemType%>">
		<input type="hidden" name="hierarchy" value="<%=hierarchy%>">
		<input type="hidden" name="page" value="<%=Request["page"]%>">
		<input type="hidden" name="modelPageNum" value="<%=Request["modelPageNum"]%>">
		<input type="hidden" name="from" value="<%=from%>">
		<p align="right"><a href="javascript:hideVoteform();">x</a></p>
		<strong><%=lang.getTranslated("portal.templates.commons.label.insert_vote")%></strong><br/>
    	<textarea class="formFieldTXTTextareaComment" name="message" id="vote-message" onclick="$('#vote-message').focus();"></textarea>
    &nbsp;<input name="send" align="middle" value="<%=lang.getTranslated("frontend.area_user.manage.label.do_vote")%>" type="button" onclick="javascript:insertVote();">
    </form>
</div>
<div id="send-comment" style="position:absolute;left:-0px;top:0px;margin-bottom:3px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;visibility:hidden;display:none;border:1px solid;padding:10px;background:#FFFFFF;width:350px;">
	<form action="<%=secureURL%>area_user/insertcomment.aspx" method="post" name="form_comment" accept-charset="UTF-8">		  
		<input type="hidden" name="id_element" value="<%=elemId%>">
		<input type="hidden" name="elemid" value="<%=elemId%>">
		<input type="hidden" name="elemtype" value="<%=elemType%>">
		<input type="hidden" name="hierarchy" value="<%=hierarchy%>">
		<input type="hidden" name="page" value="<%=Request["page"]%>">
		<input type="hidden" name="modelPageNum" value="<%=Request["modelPageNum"]%>">
		<input type="hidden" name="from" value="<%=from%>">
		<input type="hidden" name="element_type" value="<%=elemType%>">
		<input type="hidden" name="active" value="<%if("1".Equals(configService.get("use_comments_filter").value)) {Response.Write("0");}else{Response.Write("1");}%>">   
		
		<p align="right"><a href="javascript:hideCommentform();">x</a></p>
		  
		<div style="float:top;"><span class="labelForm"><%=lang.getTranslated("frontend.popup.label.insert_commento")%></span><br>
			<textarea class="formFieldTXTTextareaComment" name="message" id="comment_message" onclick="$('#comment_message').focus();"></textarea>
		</div> 
		<div><span><%=lang.getTranslated("frontend.area_user.manage.label.like")%></span><br>
			<select name="comment_type" id="comment_type">
				<OPTION VALUE="1"><%=lang.getTranslated("portal.commons.yes")%></OPTION>
				<OPTION VALUE="0"><%=lang.getTranslated("portal.commons.no")%></OPTION>
			</select>&nbsp;&nbsp;	
			<input type="button" name="send" style="margin-left:70px;" value="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" onclick="javascript:sendForm();">		
		</div>
	</form>
</div>
	  
<div id="ncwList">
<CommentsWidget:render runat="server" ID="cw1" index="1"/>
</div>