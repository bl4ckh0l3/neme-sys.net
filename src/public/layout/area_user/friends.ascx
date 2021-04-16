<%@control Language="c#" description="user-friends-control"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.Net" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="CommonCssJs" TagName="insert" Src="~/common/include/common-css-js.ascx" %>
<%@ Register TagPrefix="CommonHeader" TagName="insert" Src="~/public/layout/include/header.ascx" %>
<%@ Register TagPrefix="CommonFooter" TagName="insert" Src="~/public/layout/include/footer.ascx" %>
<%@ Register TagPrefix="MenuFrontendControl" TagName="insert" Src="~/public/layout/include/menu-frontend.ascx" %>
<%@ Register TagPrefix="UserMaskWidget" TagName="render" Src="~/public/layout/addson/user/user-mask-widget.ascx" %>
<%@ Register TagPrefix="CommonPagination" TagName="paginate" Src="~/backoffice/include/pagination.ascx" %>
<script runat="server">
	protected ASP.MultiLanguageControl lang;
	protected ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected IList<UserFriend> friends;
	protected bool foundFriends;
	protected IUserRepository usrrep;
	protected int fromFriend, toFriend, itemXpage, numPage,totalPages;
	protected string baseURL, secureURL;
	
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
		bool loggedin = login.checkedUser();
		
		baseURL = CommonService.getBaseUrl(Request.Url.ToString(),2).ToString();
		secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect(secureURL+"backoffice/index.aspx");
		}
		
		if(!loggedin){
			Response.Redirect(secureURL+"login.aspx");
		}
		
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		confservice = new ConfigurationService();
		foundFriends = false;
		itemXpage = 20;
		numPage=1;

		if (!String.IsNullOrEmpty(Request["page"])) {
			numPage = Convert.ToInt32(Request["page"]);
		}

		StringBuilder url = new StringBuilder(baseURL).Append("error.aspx?error_code=");	
		StringBuilder happyUrl = new StringBuilder(secureURL).Append("area_user/friends.aspx");		
		Logger log = new Logger();
		
		// recupero elementi della pagina necessari
		try{				
			friends = usrrep.getById(login.userLogged.id).friends;
			foundFriends = true;
			if(friends == null){				
				friends = new List<UserFriend>();	
				foundFriends = false;					
			}
		}catch (Exception ex){
			friends = new List<UserFriend>();
			foundFriends = false;
		}
						
		//******** CONFERMO AMICIZIA / ELIMINO ESISTENTE
		if("delete".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{
				int friendId = Convert.ToInt32(Request["friendid"]);
				User user = usrrep.getById(login.userLogged.id);
				User friend = usrrep.getById(friendId);
				IList<UserFriend> newFriends = null;
				if(user.friends!= null && user.friends.Count>0){
					newFriends = new List<UserFriend>();
					foreach(UserFriend uf in user.friends){
						if(uf.friend!=friendId){
							newFriends.Add(uf);
						}
					}
					user.friends = newFriends;
				}
				if(friend.friends!= null && friend.friends.Count>0){
					newFriends = new List<UserFriend>();
					foreach(UserFriend uf in friend.friends){
						if(uf.friend!=login.userLogged.id){
							newFriends.Add(uf);
						}
					}
					friend.friends = newFriends;
				}
				
				usrrep.update(user);
				usrrep.update(friend);
				login.updateUserLogged(user);
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;				
			}		
			
			if(carryOn){
				Response.Redirect(happyUrl.ToString());
			}else{
				Response.Redirect(url.ToString());
			}
		}else if("confirm".Equals(Request["operation"])){
			bool carryOn = true;
			try
			{
				int friendId = Convert.ToInt32(Request["friendid"]);
				bool active = Convert.ToBoolean(Convert.ToInt32(Request["active"]));
				User user = usrrep.getById(login.userLogged.id);
				if(user.friends!= null && user.friends.Count>0){
					foreach(UserFriend uf in user.friends){
						if(uf.friend==friendId){
							uf.isActive=active;
						}
					}
				}
				
				usrrep.update(user);
				login.updateUserLogged(user);
			}
			catch(Exception ex)
			{
				url.Append(Regex.Replace(ex.Message, @"\t|\n|\r", " "));					
				carryOn = false;				
			}		
			
			if(carryOn){
				Response.Redirect(happyUrl.ToString());
			}else{
				Response.Redirect(url.ToString());
			}			
		}


		int iIndex = friends.Count;
		
		fromFriend = ((numPage * itemXpage) - itemXpage);
		int diff = (iIndex - ((this.numPage * itemXpage)-1));
		if(diff < 1) {
			diff = 1;
		}
		
		toFriend = iIndex - diff;
			
		if(itemXpage>0){totalPages = iIndex/itemXpage;}
		if(totalPages < 1) {
			totalPages = 1;
		}else if(friends.Count % itemXpage != 0 &&  (totalPages * itemXpage) < iIndex) {
			totalPages = totalPages +1;	
		}
			
		this.pg1.totalPages = totalPages;
		this.pg1.defaultLangCode = lang.defaultLangCode;
		this.pg1.currentPage = numPage;
		this.pg1.pageForward = Request.Url.AbsolutePath;		

		// init menu frontend
		this.mf1.modelPageNum = 1;
		this.mf1.categoryid = "";	
		this.mf1.hierarchy = "";	
		this.mf2.modelPageNum = 1;
		this.mf2.categoryid = "";	
		this.mf2.hierarchy = "";	
		this.mf5.modelPageNum = 1;
		this.mf5.categoryid = "";	
		this.mf5.hierarchy = "";		
	}
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="robots" content="noindex">
<meta name="googlebot" content="noindex">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script language="JavaScript">
function changeTab(number){
	if(number==1)
		location.href='<%=secureURL%>area_user/profile.aspx';
	else if(number==2)
		location.href='<%=secureURL%>area_user/account.aspx';
	else if(number==3)
		location.href='<%=secureURL%>area_user/friends.aspx';
	else if(number==4)
		location.href='<%=secureURL%>area_user/photos.aspx';

}

function deleteFriend(idfriend){
	if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.delthis")%>")){
		location.href='<%=secureURL%>area_user/friends.aspx?operation=delete&friendid='+idfriend;
	}
}

function confirmFriend(idfriend, active){
	if(active==1){
		if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.confthis")%>")){
			location.href='<%=secureURL%>area_user/friends.aspx?operation=confirm&active='+active+'&friendid='+idfriend;
		}	
	}else{
		if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.deconfthis")%>")){
			location.href='<%=secureURL%>area_user/friends.aspx?operation=confirm&active='+active+'&friendid='+idfriend;
		}
	}
}

function checkAjaxHasFriendActive(id_friend, usrnameCurrUser){
	var query_string = "userid="+id_friend+"&action=2";

	$.ajax({
		type: "POST",
		cache: false,
		url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			if(response!=1){
				$("#showname_"+id_friend).empty();
				$("#showprofile_"+id_friend).show();	
			}else{		
				$("#showprofile_"+id_friend).hide();
				$("#showname_"+id_friend).empty().append(usrnameCurrUser);		
			}
		},
		error: function() {
			$("#showprofile_"+id_friend).hide();
			$("#showname_"+id_friend).empty().append(usrnameCurrUser);
		}
	});
}

jQuery(document).ready(function(){

});
</script>
</head>
<body>
<div id="warp">
	<CommonHeader:insert runat="server" />	
	<div id="container">	
		<MenuFrontendControl:insert runat="server" ID="mf2" index="2" model="horizontal"/>
		<MenuFrontendControl:insert runat="server" ID="mf1" index="1" model="vertical"/>	
		<UserMaskWidget:render runat="server" ID="umw1" index="1" style="float:left;clear:both;width:170px;"/>	
		<div id="backend-content">		
			<h1><%=lang.getTranslated("frontend.header.label.utente_friends")%>&nbsp;<em><%=login.userLogged.username%></em></h1>

					<p class="area_user_tabs">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.profile")%>" type="button" onclick="javascript:changeTab(1);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.modify")%>" type="button" onclick="javascript:changeTab(2);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.friends")%>" type="button" class="active" onclick="javascript:changeTab(3);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.photos")%>" type="button" onclick="javascript:changeTab(4);">
					</p>

			<div id="profilo-utente">      
				<br/>
				<table border="0" cellpadding="0" cellspacing="0" class="friends_table">
					<tr> 
					<th>&nbsp;</th>
					<th align="center" width="25">&nbsp;</th>
					<th><%=lang.getTranslated("frontend.area_user.manage.label.username")%></th>
					<th><%=lang.getTranslated("frontend.area_user.manage.label.public_profile")%></th>
					<th><%=lang.getTranslated("frontend.area_user.manage.label.dta_inser")%></th>
					<th><%=lang.getTranslated("frontend.area_user.manage.label.status")%></th>
					</tr>
					<%						
					int counter = 0;
					if(foundFriends) {
						for(counter = fromFriend; counter<=toFriend;counter++)
						{							
							bool usrHasAvatar = false;
							string avatarPath = "";
							bool friendActive = false;
							User k = usrrep.getById(friends[counter].friend);
							if(k!=null){
								UserAttachment avatar = UserService.getUserAvatar(k);
								if(avatar != null){
									usrHasAvatar = true;
									avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
								}
								friendActive = friends[counter].isActive;
								%>
								<tr>
								<td><a title="<%=lang.getTranslated("portal.templates.commons.label.del_friend")%>" href="javascript:deleteFriend(<%=k.id%>);"><img id="add" src="/common/img/cancel.png"/></a></td>
								<td align="center">
									<%if (usrHasAvatar) {%>
										<img class="imgAvatarUserFL" align="top" width="50" src="<%=avatarPath%>" />
									<%}else{%>
										<img class="imgAvatarUserFL" align="top" width="50" src="/common/img/unkow-user.jpg" />
									<%}%>
									<%if(!String.IsNullOrEmpty(avatarPath)){%>
									<script>
										var varIntervalCounterFL = 0;
										var myTimerFL;
									
										function reloadAvatarImageFL(){       
											  preloadSelectedImages("<%=avatarPath%>");
											  $(".imgAvatarUserFL").aeImageResize({height: 50, width: 50});
											  varIntervalCounterFL++;
											  
											  if(varIntervalCounterFL>10){
												clearInterval(myTimerFL);    
											  }
										}
											
										jQuery(document).ready(function(){	
										  myTimerFL = setInterval("reloadAvatarImageFL()",100);
										});
									</script>	
									<%}%>
								</td>
								<td>
									<%if(k.isPublicProfile) {%>
										<span id="showprofile_<%=k.id%>"><a title="<%=lang.getTranslated("portal.templates.commons.label.view_pub_profile")%>" href="javascript:document.form_public_profile_<%=k.id%>.submit();"><%=k.username%></a></span>
										<span id="showname_<%=k.id%>"></span>
										<script>
										$("#showprofile_<%=k.id%>").hide();           
										checkAjaxHasFriendActive(<%=k.id%>, '<%=k.username%>');
										</script>
									<%}else{%>
										<%=k.username%>
									<%}%>
								</td>
								<td><%if(k.isPublicProfile) {Response.Write(lang.getTranslated("portal.commons.yes"));}else{Response.Write(lang.getTranslated("portal.commons.no"));}%></td>
								<td><%=k.insertDate.ToString("dd/MM/yyyy")%></td>
								<td>
								<%
								bool hasFriendActive = false;
								foreach(UserFriend uf in k.friends){
									if(uf.friend==login.userLogged.id && uf.isActive){
										hasFriendActive = true;
										break;
									}
								}
									
								if(friendActive){
									if(hasFriendActive){%>
										<a title="<%=lang.getTranslated("portal.templates.commons.label.deconf_friend")%>" href="javascript:confirmFriend(<%=k.id%>,0);"><img id="deconf" src="/common/img/link.png"/></a>
									<%}else{%>								
										<img id="waitfriend" src="/common/img/clock.png" title="<%=lang.getTranslated("portal.templates.commons.label.wait_friend")%>" alt="<%=lang.getTranslated("portal.templates.commons.label.wait_friend")%>"/>										
									<%}
								}else{									
									if(hasFriendActive) {%>
										<a title="<%=lang.getTranslated("portal.templates.commons.label.confirm_friend")%>" href="javascript:confirmFriend(<%=k.id%>,1);"><img id="waitconf" src="/common/img/link_error.png"/></a>
									<%}else{%>
										<a title="<%=lang.getTranslated("portal.templates.commons.label.conf_friend")%>" href="javascript:confirmFriend(<%=k.id%>,1);"><img id="conf" src="/common/img/link_break.png"/></a>						
									<%}%>
								<%}%>&nbsp;</td>
								</tr>
								<form action="<%=secureURL%>area_user/publicprofile.aspx" method="post" name="form_public_profile_<%=k.id%>">
								<input type="hidden" value="<%=k.id%>" name="userid">
								</form>				
							<%}
						}%>
					  
						<tr> 
						<th colspan="6" align="left">						
							<div>
								<CommonPagination:paginate ID="pg1" runat="server" index="1" maxVisiblePages="10" />
							</div>
						</th>			
						</tr>		
					<%}%>
				 </table>
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