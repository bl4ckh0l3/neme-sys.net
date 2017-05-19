<%@control Language="c#" description="user-online-widget-control" className="UserOnlineWidgetControl"%>
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
private IUserPreferencesRepository preftrep;
private string action, from;
protected string secureURL;
bool logged;
protected bool usrHasAvatar;
protected string avatarPath;
protected string forcedAvHeight;

private int _index;	
public int index {
	get { return _index; }
	set { _index = value; }
}
private string _style;	
public string style {
	get { if(_style!=null){return _style;}else{return "height:200px;overflow:auto;";} }
	set { _style = value; }
}
private string _cssClass;	
public string cssClass {
	get { if(_cssClass!=null){return _cssClass;}else{return "";} }
	set { _cssClass = value; }
}
private string _model;	
public string model {
	get { if(_model!=null){return _model;}else{return "compact";} }
	set { _model = value; }
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
	preftrep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
	secureURL = Utils.getBaseUrl(Request.Url.ToString(),1).ToString();
}
</script>

<div id="onlineUsersList" style="<%=style%>" class="<%=cssClass%>">
	<script>
			function reloadUsrOnline(){
      var query_string = "style=<%=style%>&cssClass=<%=cssClass%>";
      
		  $.ajax({
			 type: "GET",
			 data: query_string,
			 cache: false,
			 url: "<%=secureURL%>public/layout/addson/user/ajax-user-online-widget.aspx",
			  success: function(html) {
					//alert("ciao");
					$("#onlineUsersList").empty();
					$("#onlineUsersList").append(html);
			  },
			  error: function (xhr, ajaxOptions, thrownError){
										//alert(xhr.status);
										//alert(thrownError);
									}
		   });            
			}
	
	
      $(document).ready(function() {
        $(document).oneTime(30000, function() {
          reloadUsrOnline();
        }, 1);
      });
		  
		function addAjaxFriend(id_friend, active){
		  var query_string = "userid="+id_friend+"&active="+active+"&action=1";
		
		  $.ajax({
			 type: "POST",
			 cache: false,
			 url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
			 data: query_string,
			  success: function(response) {
				// show friend request icon
				//alert("response: "+response);
				if(response==0){
				$("#addfriend_"+id_friend).hide();
				}
			  },
			  error: function() {
				//$("#addfriend_"+id_friend).show();
			  }
		   });
		}

		function checkAjaxHasFriend(id_friend, active){
			var query_string = "userid="+id_friend+"&active="+active+"&action=0";
			
			$.ajax({
				type: "POST",
				cache: false,
				url: "<%=secureURL%>area_user/ajaxcheckfriend.aspx",
				data: query_string,
				success: function(response) {
				  // show friend request icon
				  if(response==0){
				  	$("#addfriend_"+id_friend).show();
				  }
				},
				error: function() {
				  $("#addfriend_"+id_friend).hide();
				}
			});
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
						$("#shownamew_"+id_friend).empty();
						$("#showprofilew_"+id_friend).show();	
					}else{		
						$("#showprofilew_"+id_friend).hide();
						$("#shownamew_"+id_friend).empty().append(usrnameCurrUser);
					}
				},
				error: function() {
					$("#showprofilew_"+id_friend).hide();
					$("#shownamew_"+id_friend).empty().append(usrnameCurrUser);
				}
			});
		}		
	</script>
      <%
      IDictionary<string, UserOnline> onlineUsers = UserService.getOnlineUsers();
      
      if(onlineUsers!= null && onlineUsers.Count>0) {%>
        <div id="online-users">  
          <script>
            var varIntervalCounterOn = 0;
            var myTimerOn;
            
            function reloadAvatarImageOn(){       
                preloadSelectedImages("<%=avatarPath%>");
                $(".imgAvatarUserOn").aeImageResize({height: 50, width: 50});
                varIntervalCounterOn++;
                
                if(varIntervalCounterOn>10){
                //alert("varIntervalCounterOn:"+varIntervalCounterOn+" - chiamo clearInterval su : "+myTimerOn);
                clearInterval(myTimerOn);    
                }
            }
              
            jQuery(document).ready(function(){	
              myTimerOn = setInterval("reloadAvatarImageOn()",100);
            });
          </script>    
          <h2><%=lang.getTranslated("frontend.menu.label.online_users_list")%></h2>
          <%foreach(UserOnline  ou in onlineUsers.Values){
                User x = ou.userOnline;
                usrHasAvatar = false;
                avatarPath = "";
                forcedAvHeight = "";	
                if(Request.ServerVariables["HTTP_USER_AGENT"].Contains("MSIE")){
                  //forcedAvHeight = " height=50";
                }
                
                UserAttachment avatar = UserService.getUserAvatar(x);
                if(avatar != null){
                  usrHasAvatar = true;
                  avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
                }%>
              <div style="float:left;width:50px;height:50px;overflow:hidden;text-align:center;padding-top:1px;padding-right:2px;">              
                <script>
                  $(function() {
                  $(".imgAvatarUserOn").aeImageResize({height: 50, width: 50});
                  });
                </script>	
                <%if (usrHasAvatar) {%>
                  <img class="imgAvatarUserOn" align="top" width="50" <%=forcedAvHeight%> src="<%=avatarPath%>" />
                <%}else{%>
                  <img class="imgAvatarUserOn" align="top" width="50" <%=forcedAvHeight%> src="/common/img/unkow-user.jpg" />
                <%}%>
              </div>
              <div style="margin-bottom:40px;border-top:1px solid;height:12px;text-align:left;font-size:12px;">
              <!--nsys-modcommunity5-->
              <%if(x.isPublicProfile) {%>
                <span id="showprofilew_<%=x.id%>"><a title="<%=lang.getTranslated("portal.templates.commons.label.view_pub_profile")%>" href="javascript:document.form_public_profile_<%=x.id%>.submit();"><%=x.username%></a></span>
                <span id="shownamew_<%=x.id%>"></span>
                <script>
				$("#showprofilew_<%=x.id%>").hide();                  
                checkAjaxHasFriendActive(<%=x.id%>, '<%=x.username%>');
                </script>
		<form action="<%=secureURL%>area_user/publicprofile.aspx" method="post" name="form_public_profile_<%=x.id%>">
		<input type="hidden" value="<%=x.id%>" name="userid">
		</form>
              <%}else{
                Response.Write(x.username);
              }
              
              long percentualO = preftrep.getPositivePercentage(x.id);
              int endcounterO=0;      
              if(percentualO>0 && percentualO<=20){
                endcounterO=1; 
              }else if(percentualO>20 && percentualO<=40){ 
                endcounterO=2; 
              }else if(percentualO>40 && percentualO<=60){
                endcounterO=3; 
              }else if(percentualO>60 && percentualO<=80){ 
                endcounterO=4; 
              }else if(percentualO>80 && percentualO<=100){ 
                endcounterO=5; 
              }
              if(endcounterO>0){
                for(int starcount = 1; starcount<=endcounterO; starcount++){%>
                    <img width="14" height="15" src="/common/img/ico_stella.png" align="absmiddle" style="padding:0px;border:0px;">
                <%}
              }%>               
              <!---nsys-modcommunity5-->
                <!--nsys-modcommunity4-->
                <%if(x.isPublicProfile) {%>  
                  <br/><a href="javascript:addAjaxFriend(<%=x.id%>,0);" title="<%=lang.getTranslated("portal.templates.commons.label.add_friend")%>"><img id="addfriend_<%=x.id%>" alt="<%=lang.getTranslated("portal.templates.commons.label.add_friend")%>" src="/common/img/group_link.png"/></a>
                  <script>
                  $('#addfriend_<%=x.id%>').hide();                
                  checkAjaxHasFriend(<%=x.id%>, 0);
                  </script>
                <%}%>
                <!---nsys-modcommunity4-->
              </div>           
          <%}%>
        </div>
      <%}%>
</div>