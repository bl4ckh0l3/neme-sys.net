<%@control Language="c#" description="comments-widget-control" className="CommentsWidgetControl"%>
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
<script runat="server">  
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
protected ConfigurationService configService;
protected ICommentRepository commentrep;
protected IUserPreferencesRepository preferencerep;
protected IUserRepository usrrep;
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
	commentrep = RepositoryFactory.getInstance<ICommentRepository>("ICommentRepository");
	preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
	secureURL = Utils.getBaseUrl(Request.Url.ToString(),1).ToString();
}
</script>

<%if(elemId!=null){%> 
	<script>
	  function reloadCommentWidget(elemid, elemtype){
		var query_string = "elemid="+elemid+"&elemtype="+elemtype;

		$.ajax({
		   type: "GET",
		   cache: false,
		   url: "<%=secureURL%>public/layout/addson/comments/ajax-comments-widget.aspx",
		   data: query_string,
			success: function(html) {
			  //alert("ciao");
			  $("#ncwList").empty();
			  $("#ncwList").append(html);
			},
			error: function (xhr, ajaxOptions, thrownError){
			  //alert(xhr.status);
			  //alert(thrownError);
			}
		 });            
	  }


	  $(document).ready(function() {
		$(document).oneTime(30000, function() {
		  reloadCommentWidget(<%=elemId%>, <%=elemType%>);
		}, 1);
	  });
	</script>
		 
	<div align="left" id="div_ncw" style="margin-top:10px;width:100%;">
		<div id="view-comments">
			<%if("1".Equals(elemType)){%>
				<%if (logged){%>
					<a href="javascript:prepareComment();"><img alt="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" src="/common/img/comment_add.png" hspace="0" vspace="0" border="0"></a>
				  <%}else{%>
					<a href="<%=secureURL%>login.aspx?from=<%=from%>&elemid=<%=elemId%>&elemtype=<%=elemType%>&hierarchy=<%=hierarchy%>&categoryid=<%=categoryId%>"><img alt="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" src="/common/img/comment_add.png" hspace="0" vspace="0" border="0"></a>
				<%}%>
			<%}%>
			<%="&nbsp;&nbsp;"+lang.getTranslated("portal.templates.commons.label.see_comments_news")%><br/>
		</div>

		<div id="comments-widget">
		<%if(Request["vode_done"]=="1") {%>
			<span class="vote-confirmed" id="vote_done"><%=lang.getTranslated("portal.templates.commons.label.vote_done")%><br/></span>
		<%}else if(Request["vode_done"]=="0") {%>
			<span class="vote-confirmed" id="vote_nodone"><%=lang.getTranslated("portal.templates.commons.label.vote_not_done")%><br/></span>
		<%}else if(Request["vode_done"]=="2") {%>
			<span class="vote-confirmed" id="vote_waitdone"><%=lang.getTranslated("portal.templates.commons.label.vote_wait_done")%><br/></span>
		<%}%>
		<span class="vote-confirmed" id="friend_added" style="display:none;"><%=lang.getTranslated("portal.templates.commons.label.add_done")%><br/></span>			
		<span class="vote-confirmed" id="friend_noadded" style="display:none;"><%=lang.getTranslated("portal.templates.commons.label.add_not_done")%><br/></span>			
		
		<%if(Request["posted"]=="1") {%>
			<span class="vote-confirmed">
			<%if ("1".Equals(configService.get("use_comments_filter").value)) {%>
			  <%=lang.getTranslated("portal.templates.commons.label.comment_posted_standby")%>
			<%}else{%>
			  <%=lang.getTranslated("portal.templates.commons.label.comment_posted")%>
			<%}%>
			</span><br/>
		<%}else if(Request["posted"]=="0") {%>
		  <span class="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.comment_no_posted")%></span><br/>
		<%}
		bool commentsFound = false;		
		int userid = -1;
		if(logged){
			userid = login.userLogged.id;
		}
		
		IList<Comment> comments = commentrep.find(-1, Convert.ToInt32(elemId), Convert.ToInt32(elemType), true);		
		if (comments != null && comments.Count>0){
		  commentsFound = true;
		}
		
		if (commentsFound) {		
			int commentCounter = 0;
			
			foreach(Comment comment in comments){
				bool usrCanVote = true;
				int likeCount = 0;
				int nolikeCount = 0;
				bool usrHasAvatar = false;
				string avatarPath = "";
				bool hasPrefs = false;
				
				User userComment = usrrep.getById(comment.userId);
				UserAttachment avatar = UserService.getUserAvatar(userComment);
				if(avatar != null){
					usrHasAvatar = true;
					avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
				}
				
				IList<Preference> objLPC = preferencerep.find(-1, comment.userId, comment.id, comment.elementType, null, false, false);
				if(objLPC != null && objLPC.Count>0){
					hasPrefs = true;
					foreach(Preference h in objLPC){
						if(h.type==1) {
							likeCount++;
						}else if(h.type==-1){
							nolikeCount++;    
						}  
						
						if (h.friendId==userid){
							usrCanVote=usrCanVote && false;
						}			
					}
				}%>
				<div class="commento" style="border:1px solid #999999;padding-top:10px;margin-bottom:10px;" id="comment_<%=commentCounter%>">
					<div style="float:left;padding:0px 5px 5px 0px;width:50px;height:50px;overflow:hidden;text-align:center;">
						<%if (usrHasAvatar) {%>
							<img class="imgAvatarUserNCW" align="top" width="50" src="<%=avatarPath%>" />
						<%}else{%>
							<img class="imgAvatarUserNCW" align="top" width="50" src="/common/img/unkow-user.jpg" />
						<%}%>
						<%if(!String.IsNullOrEmpty(avatarPath)){%>
						<script>
							var varIntervalCounterNCW = 0;
							var myTimerNCW;
						
							function reloadAvatarImageNCW(){       
								  preloadSelectedImages("<%=avatarPath%>");
								  $(".imgAvatarUserNCW").aeImageResize({height: 50, width: 50});
								  varIntervalCounterNCW++;
								  
								  if(varIntervalCounterNCW>10){
									//alert("varIntervalCounter:"+varIntervalCounter+" - chiamo clearInterval su : "+myTimer);
									clearInterval(myTimerNCW);    
								  }
							}
								
							jQuery(document).ready(function(){	
							  myTimerNCW = setInterval("reloadAvatarImageNCW()",100);
							});
						</script>	
						<%}%>
					</div>					
					<div style="display:inline-block;padding:0px 5px 5px 0px;">
						<strong><%=comment.insertDate.ToString("dd/MM/yyyy HH:mm")+"&nbsp;"%>
						<!--nsys-modcommunity6-->
						<%if(userComment.isPublicProfile) {
							usrCanVote=usrCanVote && (userid >0 && comment.userId!=userid);%>
							<span id="showprofilenc<%=commentCounter%>_<%=comment.userId%>"><a title="<%=lang.getTranslated("portal.templates.commons.label.view_pub_profile")%>" href="javascript:document.form_public_profile_<%=commentCounter%>_<%=comment.userId%>.submit();"><%=userComment.username%></a></span>
							<span id="shownamenc<%=commentCounter%>_<%=comment.userId%>"></span><br/> 
							<span id="showlikenc<%=commentCounter%>_<%=comment.userId%>"><a class="addcommentvote<%=commentCounter%>" href="javascript:prepareVote(<%=comment.userId%>, <%=comment.id%>, 1, <%=comment.elementType%>);"><img id="ok<%=commentCounter%>" title="<%=lang.getTranslated("portal.templates.commons.label.vote_up")%>" src="/common/img/vote_ok.png"/></a><%if(likeCount>0){Response.Write("<span class=likecountpref>"+likeCount+"</span>");}%>
							&nbsp;&nbsp;<a class="addcommentvote<%=commentCounter%>" href="javascript:prepareVote(<%=comment.userId%>, <%=comment.id%>, -1, <%=comment.elementType%>);"><img id="ko<%=commentCounter%>" title="<%=lang.getTranslated("portal.templates.commons.label.vote_down")%>" src="/common/img/vote_ko.png"/></a><%if(nolikeCount>0){Response.Write("<span class=likecountpref>"+nolikeCount+"</span>");}%></span>
							<span id="showaddfnc<%=commentCounter%>_<%=comment.userId%>">&nbsp;&nbsp;<a href="javascript:addFriend('showaddfnc<%=commentCounter%>_',<%=comment.userId%>);"><img id="add<%=commentCounter%>" title="<%=lang.getTranslated("portal.templates.commons.label.add_friend")%>" src="/common/img/group_link.png"/></a></span>
							<script>
								$("#showaddfnc<%=commentCounter%>_<%=comment.userId%>").hide();                  
								checkAjaxHasFriendNC('showaddfnc<%=commentCounter%>_',<%=comment.userId%>, 0);
							
								<%if(!usrCanVote){%> 
									$("a.addcommentvote<%=commentCounter%>").attr('href', 'javascript:alert("<%=lang.getTranslated("portal.templates.commons.label.vote_cannot_done")%>")');   
									$("a.addcommentvote<%=commentCounter%>").attr('style', 'cursor: default');               
								<%}%>		
								$("#showprofilenc<%=commentCounter%>_<%=comment.userId%>").hide();                  
								checkAjaxHasFriendActiveNC('showprofilenc<%=commentCounter%>_','shownamenc<%=commentCounter%>_',<%=comment.userId%>, '<%=userComment.username%>');
						 	</script>
							<form action="<%=secureURL%>area_user/publicprofile.aspx" method="post" name="form_public_profile_<%=commentCounter%>_<%=comment.userId%>">
							<input type="hidden" value="<%=comment.userId%>" name="userid">
							</form>
						<%}else{%>
							<%=userComment.username%>
						<%}%> 
						<!---nsys-modcommunity6-->
						</strong>             
						<br><%if(comment.voteType==1){%><img id="nolike<%=commentCounter%>" src="/common/img/like.png" align="absbottom"/><%}else{%><img id="nolike<%=commentCounter%>" src="/common/img/nolike.png" align="absbottom"/><%}%>&nbsp;<%=comment.message%><br>
					</div>
					
					<%if(hasPrefs){
						foreach(Preference h in objLPC){
							if(h.active){
								bool usrHasAvatarP = false;
								string avatarPathP = "";
								
								User userP = usrrep.getById(h.userId);
								UserAttachment avatarP = UserService.getUserAvatar(userP);
								if(avatarP != null){
									usrHasAvatarP = true;
									avatarPathP = "/public/upload/files/user/"+avatarP.filePath+avatarP.fileName;
								}%>
								<div style="clear:left;background-color: #EEEEEE;border: 1px solid #E3E3E3;padding:5px;margin:5px 2px 5px 50px;">								
									<div style="float:left;padding:0px 5px 5px 0px;width:30px;height:30px;overflow:hidden;text-align:center;">
										<%if (usrHasAvatarP) {%>
											<img class="imgAvatarUserNCWP" align="top" width="30" src="<%=avatarPathP%>" />
										<%}else{%>
											<img class="imgAvatarUserNCWP" align="top" width="30" src="/common/img/unkow-user.jpg" />
										<%}%>
										<%if(!String.IsNullOrEmpty(avatarPathP)){%>
										<script>
											var varIntervalCounterNCWP = 0;
											var myTimerNCWP;
										
											function reloadAvatarImageNCWP(){       
												  preloadSelectedImages("<%=avatarPathP%>");
												  $(".imgAvatarUserNCWP").aeImageResize({height: 30, width: 30});
												  varIntervalCounterNCWP++;
												  
												  if(varIntervalCounterNCWP>10){
													clearInterval(myTimerNCWP);    
												  }
											}
												
											jQuery(document).ready(function(){	
											  myTimerNCWP = setInterval("reloadAvatarImageNCWP()",100);
											});
										</script>	
										<%}%>
									</div>					
									<div style="display:inline-block;padding:0px 0px 0px 0px;">									
										<strong><%=h.insertDate.ToString("dd/MM/yyyy HH:mm")+"&nbsp;"%>
										<!--nsys-modcommunity8-->
										<%if(userP.isPublicProfile) {%>
											<span id="showprofilencp<%=h.id%>_<%=userP.id%>"><a title="<%=lang.getTranslated("portal.templates.commons.label.view_pub_profile")%>" href="javascript:document.form_public_profilep_<%=h.id%>_<%=userP.id%>.submit();"><%=userP.username%></a></span>
											<span id="shownamencp<%=h.id%>_<%=userP.id%>"></span><br/> 
											<span id="showaddfncp<%=h.id%>_<%=userP.id%>">&nbsp;&nbsp;<a href="javascript:addFriend('showaddfncp<%=h.id%>_',<%=userP.id%>);"><img id="addp<%=h.id%>" title="<%=lang.getTranslated("portal.templates.commons.label.add_friend")%>" src="/common/img/group_link.png"/></a></span>
											<script>
												$("#showaddfncp<%=h.id%>_<%=userP.id%>").hide();                  
												checkAjaxHasFriendNC('showaddfncp<%=h.id%>_',<%=userP.id%>, 0);	
												$("#showprofilencp<%=h.id%>_<%=userP.id%>").hide();                  
												checkAjaxHasFriendActiveNC('showprofilencp<%=h.id%>_','shownamencp<%=h.id%>_',<%=userP.id%>, '<%=userP.username%>');
											</script>
											<form action="<%=secureURL%>area_user/publicprofile.aspx" method="post" name="form_public_profilep_<%=h.id%>_<%=userP.id%>">
											<input type="hidden" value="<%=userP.id%>" name="userid">
											</form>
										<%}else{%>
											<%=userP.username%>
										<%}%> 
										<!---nsys-modcommunity8-->
										</strong><br/>
										<%=h.message%>
									</div>
								</div>
							<%}
						}
					}%>					
				</div>				
				<%commentCounter++;
			}%>
			<script>
			$(function() {
				$('.imgAvatarUserNCW').aeImageResize({height: 50, width: 50});
			});   
			</script>              
		<%}else{
			Response.Write("<br/><div align='center'>"+lang.getTranslated("frontend.popup.label.no_comments_news")+"</div><br>");
		}%>
		</div>
	</div>        	
<%}%>