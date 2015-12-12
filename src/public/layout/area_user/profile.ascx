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
<script runat="server">
	protected ASP.MultiLanguageControl lang;
	protected ASP.UserLoginControl login;
	protected ConfigurationService confservice;
	protected IUserRepository usrrep;
	protected IUserPreferencesRepository preferencerep;
	protected IList<Preference> objLPC;
	protected bool preferenceFound, bolFoundField;
	IList<UserField> usrfields;
	
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
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect("~/backoffice/index.aspx");
		}
		
		if(!loggedin){
			Response.Redirect("~/login.aspx");
		}
		
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
		confservice = new ConfigurationService();
		preferenceFound = false;
		bolFoundField = false;

		StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
		StringBuilder happyUrl = new StringBuilder("/area_user/profile.aspx");		
		Logger log = new Logger();
		
		// recupero elementi della pagina necessari
		try{				
			objLPC = preferencerep.find(-1, login.userLogged.id,  -1, -1, "true", null, null);
			if(objLPC != null && objLPC.Count>0){
				preferenceFound = true;
			}
		}catch (Exception ex){
			objLPC = new List<Preference>();
		preferenceFound = false;
		}


		//***************** RECUPERO LISTA USER FIELDS 
		try
		{
			List<string> usesFor = new List<string>();
			usesFor.Add("1");
			usesFor.Add("3");
			usrfields = usrrep.getUserFields("true",usesFor);
			if(usrfields != null)
			{				
				bolFoundField = true;				
			}    	
		}
		catch (Exception ex)
		{
			usrfields = new List<UserField>();
			bolFoundField = false;
		}

		//******** CONFERMO AMICIZIA / ELIMINO ESISTENTE
		if("poststatus".Equals(Request["operation"]))
		{
			bool carryOn = true;
			try
			{			
				StringBuilder message = new StringBuilder(Request["message"]);
				int vote = Convert.ToInt32(Request["vote"]);
					
				Preference preference = new Preference();
				preference.userId = login.userLogged.id;
				preference.friendId = login.userLogged.id;
				preference.commentId = 0;
				preference.commentType = 0;
				preference.type = vote;	
				preference.active=true;						
			
				HttpFileCollection MyFileCollection = Request.Files;
				HttpPostedFile MyFile;							
				MyFile = MyFileCollection[0];						
				string fileName = Path.GetFileName(MyFile.FileName);				
				string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+login.userLogged.id); 
				if (!Directory.Exists(dirName))
				{
					Directory.CreateDirectory(dirName);
				}					
				if(!String.IsNullOrEmpty(fileName))
				{
					UserService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+login.userLogged.id+"/"+MyFile.FileName));
					message.Append("<br/><br/>").Append("<img align='top' src='/public/upload/files/user/").Append(login.userLogged.id).Append("/").Append(MyFile.FileName).Append("'>");
				}

				preference.message = message.ToString();				
				preference.insertDate = DateTime.Now;
				preferencerep.insert(preference);	
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
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<CommonCssJs:insert runat="server" />
<link rel="stylesheet" href="/public/layout/css/area_user.css" type="text/css">
<script language="JavaScript">
function changeTab(number){
	if(number==1)
		location.href='/area_user/profile.aspx';
	else if(number==2)
		location.href='/area_user/account.aspx';
	else if(number==3)
		location.href='/area_user/friends.aspx';
	else if(number==4)
		location.href='/area_user/photos.aspx';

}

function checkAjaxHasFriendActive(id_friend, usrnameCurrUser){
	var query_string = "userid="+id_friend+"&action=2";

	$.ajax({
		type: "POST",
		cache: false,
		url: "/area_user/ajaxcheckfriend.aspx",
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

function deleteStatus(id_status){
	var query_string = "preferenceid="+id_status;

	$.ajax({
		type: "POST",
		cache: false,
		url: "/area_user/ajaxdeletepreference.aspx",
		data: query_string,
		success: function(response) {
			//alert("response: "+response);
			if(response!=1){
				$("#user_status_"+id_status).hide();
			}
		}
	});
}

function insertVote(){
	if(document.form_update_status.message.value=="" || document.form_update_status.message.value=="<br>"){
		 alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
		 document.form_update_status.message.value="";
		 return;
	}
	//$("#send-status").hide();

	document.form_update_status.submit();      
}

function hideStatusForm(){
	$('#send-status').toggle();
}

function hideInfoForm(){
	$('#info-utente').toggle();
}
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
			<h1><%=lang.getTranslated("frontend.header.label.utente_profile")%>&nbsp;<em><%=login.userLogged.username%></em></h1>

			<p class="area_user_tabs">
			<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.profile")%>" type="button" class="active" onclick="javascript:changeTab(1);">
			<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.modify")%>" type="button" onclick="javascript:changeTab(2);">
			<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.friends")%>" type="button" onclick="javascript:changeTab(3);">
			<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.photos")%>" type="button" onclick="javascript:changeTab(4);">
			</p>
	
			<div id="profilo-utente" style="margin-top:20px;">      
				<div style="float:left;border:1px solid #999999;margin-bottom:0px;width:100px;height:20px;text-align:center;cursor:pointer;padding-top:5px;" id="change_user_status"><%=lang.getTranslated("frontend.area_user.manage.label.user_status")%></div>
				<div style="display:inline-block;border:1px solid #999999;margin-bottom:0px;width:100px;height:20px;text-align:center;cursor:pointer;padding-top:5px;" id="show_user_info"><%=lang.getTranslated("frontend.area_user.manage.label.user_info")%></div>
				<div id="send-status" style="display:none;margin-bottom:10px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;border:none;padding-left:0px;padding-right:0px;padding-bottom:5px;background:#FFFFFF;">
					<form action="/area_user/profile.aspx" method="post" name="form_update_status" accept-charset="UTF-8" enctype="multipart/form-data">		
						<input type="hidden" value="0" name="vote">
						<input type="hidden" value="poststatus" name="operation">						

						<textarea name="message" id="message" class="formFieldTXTAREAAbstract"></textarea>
						<script>
						$.cleditor.defaultOptions.width = 500;
						$.cleditor.defaultOptions.height = 170;
						$.cleditor.defaultOptions.controls = "bold italic underline strikethrough | font size style | color highlight | bullets numbering | alignleft center alignright justify | rule | image";		
						$(document).ready(function(){
							$('#message').cleditor();
						});
						</script>

						<br/>
						<input type="file" name="imageupload" />&nbsp;&nbsp;
						<input name="send" align="middle" value="<%=lang.getTranslated("frontend.area_user.manage.label.publish")%>" type="button" onclick="javascript:insertVote();">
					</form>
				</div>

				<div id="info-utente" style="background-color: #EEEEEE;display:none;margin-bottom:10px;padding:5px;">				
					<div style="padding-bottom:15px;float:left;margin-right:30px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.username")%></b><br/>
					<%=login.userLogged.username%>
					</div>
					<div style="padding-bottom:15px;float:left;margin-right:30px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.email")%></b><br/>
					<%=login.userLogged.email%>
					</div>
					<div style="padding-bottom:15px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.public_profile")%></b><br/>
					<%
					if (login.userLogged.isPublicProfile) { 
						Response.Write(lang.getTranslated("backend.commons.yes"));
					}else{ 
						Response.Write(lang.getTranslated("backend.commons.no"));
					}%>
					</div>

					<%int fieldcount = 1;
					if(bolFoundField && login.userLogged.fields != null && login.userLogged.fields.Count>0){
						foreach(UserField uf in usrfields){
							string description = UserService.translate("backend.utenti.detail.table.label.description_"+uf.description, uf.description, lang.currentLangCode, lang.defaultLangCode);
								
							foreach(UserFieldsMatch ufm in login.userLogged.fields){
								if(ufm.idParentField==uf.id){
									string floatpos = "float:left;margin-right:30px;";
									if(fieldcount % 3 == 0){floatpos = "float:top;";}%>
									<div style="<%=floatpos%>padding-bottom:15px;"><b><%=description%></b><br/>
									<%=ufm.value%>
									</div>
									<%fieldcount++;
									break;
								}
							}
						}
					}%>
					
					<div style="padding-bottom:15px;float:left;margin-right:30px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.date_insert")%></b><br/>
					<%=login.userLogged.insertDate.ToString("dd/MM/yyyy")%>
					</div>
					<div style="padding-bottom:15px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.date_modify")%></b><br/>
					<%=login.userLogged.modifyDate.ToString("dd/MM/yyyy")%>
					</div>
				</div>
				<script>
				$("#change_user_status").click( function() {
					hideStatusForm();
					$('#message').cleditor()[0].focus();
				});
				$("#show_user_info").click( function() {
					hideInfoForm();
				});
				</script> 
				
				<div style="clear:both;height:10px;"></div>
				
				<%foreach(Preference h in objLPC){
					string username = "";
					bool usrHasAvatar = false;
					string avatarPath = "";
					User committer = usrrep.getById(h.userId);
					if(committer!=null){
						username = committer.username;
						UserAttachment avatar = UserService.getUserAvatar(committer);
						if(avatar != null){
							usrHasAvatar = true;
							avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
						}
					}%>
					<div id="user_status_<%=h.id%>" style="background-color:#FFFFFF; border:1px solid #E3E3E3;padding:5px;margin-bottom:10px;">
						<p style="padding-bottom:15px;">
							<%if (usrHasAvatar) {%>
								<img class="imgAvatarUserPF" align="left" style="padding-right:3px;padding-bottom:0px;" width="30" src="<%=avatarPath%>" />
							<%}else{%>
								<img class="imgAvatarUserPF" align="left" style="padding-right:3px;padding-bottom:0px;" width="30" src="/common/img/unkow-user.jpg" />
							<%}%>
							<%if(!String.IsNullOrEmpty(avatarPath)){%>
							<script>
								var varIntervalCounterPF = 0;
								var myTimerPF;
							
								function reloadAvatarImagePF(){       
									  preloadSelectedImages("<%=avatarPath%>");
									  $(".imgAvatarUserPF").aeImageResize({height: 30, width: 30});
									  varIntervalCounterPF++;
									  
									  if(varIntervalCounterPF>10){
										//alert("varIntervalCounter:"+varIntervalCounter+" - chiamo clearInterval su : "+myTimer);
										clearInterval(myTimerPF);    
									  }
								}
									
								jQuery(document).ready(function(){	
								  myTimerPF = setInterval("reloadAvatarImagePF()",100);
								});
							</script>	
							<%}%>
							<%string useraction = lang.getTranslated("frontend.area_user.manage.label.user_has_posted");
							if(h.commentId != null && h.commentId>0){
								useraction = lang.getTranslated("frontend.area_user.manage.label.user_has_voted");
							}%>
							<a href="javascript:deleteStatus(<%=h.id%>);" title="<%=lang.getTranslated("frontend.area_user.manage.label.delete_status")%>" alt="<%=lang.getTranslated("frontend.area_user.manage.label.delete_status")%>">x</a>&nbsp;&nbsp;<%=h.insertDate.ToString("dd/MM/yyyy HH:mm")%><br/><b><%=username%></b>&nbsp;&nbsp;<%=useraction%>
						</p>
						
						<%=h.message%>
					</div>
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