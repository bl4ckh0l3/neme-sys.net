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
	protected IList<UserField> usrfields;
	protected User publicuser;
	protected bool bolFoundPhotos;
	protected IList<UserAttachment> attachments;
	protected IDictionary<string, IList<UserAttachment>> albums;
	protected string basePath;
	
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
		
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		preferencerep = RepositoryFactory.getInstance<IUserPreferencesRepository>("IUserPreferencesRepository");
		confservice = new ConfigurationService();
		preferenceFound = false;
		bolFoundField = false;
		bolFoundPhotos = false;

		StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
		StringBuilder happyUrl = new StringBuilder("/area_user/publicprofile.aspx");		
		Logger log = new Logger();
		
		basePath = new StringBuilder(Request.Url.Scheme).Append("://").Append(Request.Url.Host).Append("/public/upload/files/user/").ToString();
		albums = new Dictionary<string, IList<UserAttachment>>();
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect("~/backoffice/index.aspx");
		}
				
		if(!loggedin || String.IsNullOrEmpty(Request["userid"])){
			Response.Redirect("~/login.aspx");
		}	

		publicuser = usrrep.getById(Convert.ToInt32(Request["userid"]));
		
		if(publicuser==null){
			url.Append(Regex.Replace(lang.getTranslated("frontend.area_user.manage.label.public_profile_not_found"), @"\t|\n|\r", " "));	
			Response.Redirect(url.ToString());
		}
		
		bool thisFriendOk = false;
		if(publicuser.friends != null && publicuser.friends.Count>0){
			foreach(UserFriend uf in publicuser.friends){
				if(uf.friend==login.userLogged.id && uf.isActive){
					thisFriendOk = true;
					break;
				}				
			}
		}
		
		if(publicuser.id==login.userLogged.id || !publicuser.isPublicProfile || !thisFriendOk){
			Response.Redirect("~/area_user/profile.aspx");
		}

		// recupero elementi della pagina necessari
		try{				
			objLPC = preferencerep.find(-1, publicuser.id,  -1, -1, true, null, null);
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
			List<string> applyTo = new List<string>();
			applyTo.Add("0");
			applyTo.Add("2");
			usrfields = usrrep.getUserFields(true,usesFor,applyTo);
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


		//***************** RECUPERO LISTA USER PHOTOS E ALBUM 
		try
		{		
			if(publicuser != null && publicuser.attachments != null && publicuser.attachments.Count>0){
				attachments = publicuser.attachments;					
				bolFoundPhotos = true;
			}
			
			if(bolFoundPhotos){
				foreach(UserAttachment tmp in attachments){
					if(!tmp.isAvatar){
						string label = tmp.fileLabel;
						if(String.IsNullOrEmpty(label)){
							if(albums.ContainsKey("none"))
							{
								IList<UserAttachment> items = null;
								if(albums.TryGetValue("none", out items)){
									items.Add(tmp);
									albums["none"] = items;
								}
							}
							else
							{
								IList<UserAttachment> items = new List<UserAttachment>();
								items.Add(tmp);
								albums["none"] = items;
							}
						}else{
							if(albums.ContainsKey(label))
							{
								IList<UserAttachment> items = null;
								if(albums.TryGetValue(label, out items)){
									items.Add(tmp);
									albums[label] = items;
								}
							}
							else
							{
								IList<UserAttachment> items = new List<UserAttachment>();
								items.Add(tmp);
								albums[label] = items;
							}						
						}
					}
				}
			}
			
		}catch (Exception ex){
			//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
			attachments = new List<UserAttachment>();						
			bolFoundPhotos = false;
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
				preference.friendId = publicuser.id;
				preference.commentId = 0;
				preference.commentType = 0;
				preference.type = vote;
				preference.active=true;				
			
				HttpFileCollection MyFileCollection = Request.Files;
				HttpPostedFile MyFile;							
				MyFile = MyFileCollection[0];						
				string fileName = Path.GetFileName(MyFile.FileName);				
				string dirName = HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+publicuser.id); 
				if (!Directory.Exists(dirName))
				{
					Directory.CreateDirectory(dirName);
				}					
				if(!String.IsNullOrEmpty(fileName))
				{	
					switch (Path.GetExtension(fileName))
					{
						case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":
							UserService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+publicuser.id+"/"+MyFile.FileName));
							message.Append("<br/><br/>").Append("<img align='top' src='/public/upload/files/user/").Append(publicuser.id).Append("/").Append(MyFile.FileName).Append("'>");
							break;
						default:
							throw new Exception("022");										
							break;
					}
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
				Response.Redirect(happyUrl.ToString()+"?userid="+publicuser.id);
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
<link rel="stylesheet" href="/common/css/jquery.fancybox.css" type="text/css" media="screen" />
<script type="text/javascript" src="/common/js/jquery.fancybox.pack.js"></script>
<link rel="stylesheet" type="text/css" href="/common/css/jquery.fancybox-buttons.css?v=1.0.5" />
<script type="text/javascript" src="/common/js/jquery.fancybox-buttons.js?v=1.0.5"></script>
<script language="JavaScript">

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

function insertVote(){
	if(document.form_update_status.message.value=="" || document.form_update_status.message.value=="<br>"){
		 alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
		 document.form_update_status.message.value="";
		 return;
	}

	document.form_update_status.submit();      
}

function hideStatusForm(){
	$('#send-status').toggle();
}

function hideInfoForm(){
	$('#info-utente').toggle();
}

function hidePhotoForm(){
	$('#photo-utente-container').toggle();
}

function openAlbum(divid){
	$('#'+divid).show();
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
			<h1><%=lang.getTranslated("frontend.header.label.utente_profile")%>&nbsp;<em><%=publicuser.username%></em></h1>
	
			<div id="profilo-utente" style="margin-top:20px;">      
				<div style="float:left;border:1px solid #999999;margin-bottom:0px;width:100px;height:20px;text-align:center;cursor:pointer;padding-top:5px;" id="change_user_status"><%=lang.getTranslated("frontend.area_user.manage.label.insert_comment")%></div>
				<div style="display:inline-block;border:1px solid #999999;margin-bottom:0px;width:100px;height:20px;text-align:center;cursor:pointer;padding-top:5px;" id="show_user_info"><%=lang.getTranslated("frontend.area_user.manage.label.user_info")%></div>
				<%if(bolFoundPhotos) {%><div style="display:inline-block;border:1px solid #999999;margin-bottom:0px;width:100px;height:20px;text-align:center;cursor:pointer;padding-top:5px;" id="show_user_photos"><%=lang.getTranslated("frontend.area_user.manage.label.photos")%></div><%}%>
				<div id="send-status" style="display:none;margin-bottom:10px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;border:none;padding-left:0px;padding-right:0px;padding-bottom:5px;background:#FFFFFF;">
					<form action="/area_user/publicprofile.aspx" method="post" name="form_update_status" accept-charset="UTF-8" enctype="multipart/form-data">
						<input type="hidden" name="friendid" value="<%=login.userLogged.id%>">
						<input type="hidden" value="poststatus" name="operation">
						<input type="hidden" value="<%=publicuser.id%>" name="userid">						

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
						<div style="padding-right:5px;display:inline;float:left;">	
							<input type="file" name="imageupload" />&nbsp;&nbsp;
						</div>
						<div style="padding-right:5px;display:inline; float:left;">
						<%=lang.getTranslated("frontend.area_user.manage.label.like")%><br>
							<select name="vote" id="vote">
								<option VALUE="0"></option>
								<option VALUE="1"><%=lang.getTranslated("portal.commons.yes")%></option>
								<option VALUE="-1"><%=lang.getTranslated("portal.commons.no")%></option>
							</select>
						</div>
						<div style="padding-right:5px;display:inline;float:top;">	
							<input name="send" align="middle" value="<%=lang.getTranslated("frontend.area_user.manage.label.publish")%>" type="button" onclick="javascript:insertVote();">
						</div>
					</form>
				</div>

				<div id="info-utente" style="background-color: #EEEEEE;margin-bottom:10px;padding:5px;">	
					<div style="padding-bottom:10px;float:left;margin-right:20px;">					
						<%
						bool usrHasAvatarPP = false;
						string avatarPathPP = "";
						
						UserAttachment avatarPP = UserService.getUserAvatar(publicuser);
						if(avatarPP != null){
							usrHasAvatarPP = true;
							avatarPathPP = "/public/upload/files/user/"+avatarPP.filePath+avatarPP.fileName;
						}
						
						if (usrHasAvatarPP) {%>
							<img class="imgAvatarUserPP" align="top" width="50" src="<%=avatarPathPP%>" />
						<%}else{%>
							<img class="imgAvatarUserPP" align="top" width="50" src="/common/img/unkow-user.jpg" />
						<%}%>
						<%if(!String.IsNullOrEmpty(avatarPathPP)){%>
						<script>
							var varIntervalCounterPP = 0;
							var myTimerPP;
						
							function reloadAvatarImagePP(){       
								  preloadSelectedImages("<%=avatarPathPP%>");
								  $(".imgAvatarUserPP").aeImageResize({height: 50, width: 50});
								  varIntervalCounterPP++;
								  
								  if(varIntervalCounterPP>10){
									clearInterval(myTimerPP);    
								  }
							}
								
							jQuery(document).ready(function(){	
							  myTimerPP = setInterval("reloadAvatarImagePP()",100);
							});
						</script>	
						<%}
						
						long percentual = preferencerep.getPositivePercentage(publicuser.id);						
						int endcounter=0;      
						if(percentual>0 && percentual<=20){
						  endcounter=1; 
						}else if(percentual>20 && percentual<=40){ 
						  endcounter=2; 
						}else if(percentual>40 && percentual<=60){
						  endcounter=3; 
						}else if(percentual>60 && percentual<=80){ 
						  endcounter=4; 
						}else if(percentual>80 && percentual<=100){ 
						  endcounter=5; 
						}
						if(endcounter>0){%>
						  <div align="left" id="usrprefstarsbox" style="width:100px;height:15px;">
						  <%for(int starcount = 1; starcount<=endcounter; starcount++){%>
							  <img width="14" height="15" src="/common/img/ico_stella.png" alt="<%=percentual%> %" title="<%=percentual%> %" align="absmiddle" style="padding:0px;border:0px;">
						  <%}%>
						  </div><br/>
						<%}%>		
					</div>				
					<div style="padding-bottom:15px;float:left;margin-right:30px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.username")%></b><br/>
					<%=publicuser.username%>
					</div>
					<div style="padding-bottom:15px;float:left;margin-right:30px;">
						<b><%=lang.getTranslated("frontend.area_user.manage.label.public_profile")%></b><br/>
						<%
						if (publicuser.isPublicProfile) { 
							Response.Write(lang.getTranslated("backend.commons.yes"));
						}else{ 
							Response.Write(lang.getTranslated("backend.commons.no"));
						}%>
					</div>
					<div style="padding-bottom:15px;height:30px;">
						<%if(publicuser.friends != null && publicuser.friends.Count>0){
							Response.Write("<b>"+lang.getTranslated("frontend.area_user.manage.label.friends")+": </b>");
							Response.Write(publicuser.friends.Count);
						}%>
					</div>
					
					<%int fieldcount = 1;
					if(bolFoundField && publicuser.fields != null && publicuser.fields.Count>0){
						foreach(UserField uf in usrfields){
							string description = UserService.translate("backend.utenti.detail.table.label.description_"+uf.description, uf.description, lang.currentLangCode, lang.defaultLangCode);
								
							foreach(UserFieldsMatch ufm in publicuser.fields){
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
					
					<div style="clear:both;"></div>
					<div style="padding-bottom:15px;float:left;margin-right:30px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.date_insert")%></b><br/>
					<%=publicuser.insertDate.ToString("dd/MM/yyyy")%>
					</div>
					<div style="padding-bottom:15px;"><b><%=lang.getTranslated("frontend.area_user.manage.label.date_modify")%></b><br/>
					<%=publicuser.modifyDate.ToString("dd/MM/yyyy")%>
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
				$("#show_user_photos").click( function() {
					hidePhotoForm();
				});
				</script> 
				
				<div style="clear:both;height:10px;"></div>
				
				<div id="photo-utente-container" style="display:none;">
					<div id="photo-utente" style="margin-bottom:10px;padding:5px;">	
						<%
						if(bolFoundPhotos) {
							int photoCounter = 1;

							IList<UserAttachment> itemsNoAlbum = null;
							if(albums.TryGetValue("none", out itemsNoAlbum)){			
								foreach (UserAttachment attachment in itemsNoAlbum){
									string divfloat = "left";
									if(photoCounter % 3 == 0){divfloat = "top";}%>				
									<div style="margin-bottom:10px;float:<%=divfloat%>;margin-right:5px;width:200px;height:200px;overflow:hidden;border:1px solid #E3E3E3;text-align:center;vertical-align:middle;">
										<a class="fancybox" href="<%=basePath+attachment.filePath+attachment.fileName%>" title="<%=attachment.fileDida%>"><img width="200" alt="<%=attachment.fileDida%>" title="<%=attachment.fileDida%>" src="<%=basePath+attachment.filePath+attachment.fileName%>" hspace="0" vspace="0" border="0"></a>
									</div>
									<%photoCounter++;		
								}%>	
								<script>
								$(document).ready(function() {
									$('.fancybox').fancybox();
								});
								</script>							
							<%}
						}%>
					</div>

					<div style="clear:both;height:50px;"></div>
					<%if(bolFoundPhotos && albums.Keys != null) {%><h2 style="text-align:center;"><%=lang.getTranslated("frontend.area_user.manage.label.albums")%></h2><%}%>
					<div id="album-utente" style="margin-bottom:10px;padding:5px;">	
						<%
						if(bolFoundPhotos) {
							int photoCounterA = 1;
							
							if(albums.Keys != null){
								foreach(string x in albums.Keys){
									if(x!="none"){
										IList<UserAttachment> itemsAlbum = null;
										if(albums.TryGetValue(x, out itemsAlbum)){
											foreach (UserAttachment attachment in itemsAlbum){
												string divfloatA = "left";
												if(photoCounterA % 3 == 0){divfloatA = "top";}%>				
												<div style="margin-bottom:10px;float:<%=divfloatA%>;margin-right:5px;width:200px;height:200px;overflow:hidden;border:1px solid #E3E3E3;text-align:center;vertical-align:middle;">
												<div style="position:relative;background-color:#FFFFFF;cursor:pointer;" onclick="javascript:openAlbum('itemsAlbum_<%=x.Replace(" ","")%>');"><%=attachment.fileLabel%></div>
												<a" href="<%=basePath+attachment.filePath+attachment.fileName%>" title="<%=attachment.fileDida%>"><img src="<%=basePath+attachment.filePath+attachment.fileName%>" width="200" alt="<%=attachment.fileDida%>" title="<%=attachment.fileDida%>" /></a>
												</div>
												<%photoCounterA++;
												break;											
											}%>
											
											<div id="itemsAlbum_<%=x.Replace(" ","")%>" style="z-index:1;display:none;position:absolute;background-color:#FFFFFF;min-width:615px;border:1px solid #E3E3E3;">
											<div style="text-align:right;width:100%;background-color:#FFFFFF;cursor:pointer;" onclick="$('#itemsAlbum_<%=x.Replace(" ","")%>').hide();" title="<%=lang.getTranslated("frontend.area_user.manage.label.close_album")%>">x</div>
											<%
											int photoCounterX = 1;
											foreach (UserAttachment attachment in itemsAlbum){
												string divfloat = "left";
												if(photoCounterX % 3 == 0){divfloat = "top";}%>
												<div style="margin-bottom:10px;float:<%=divfloat%>;margin-right:5px;width:200px;height:200px;overflow:hidden;border:1px solid #E3E3E3;text-align:center;vertical-align:middle;">
													<a class="fancybox_<%=x.Replace(" ","")%>" href="<%=basePath+attachment.filePath+attachment.fileName%>" title="<%=attachment.fileDida%>"><img width="200" alt="<%=attachment.fileDida%>" title="<%=attachment.fileDida%>" src="<%=basePath+attachment.filePath+attachment.fileName%>" hspace="0" vspace="0" border="0"></a>
												</div>										
												<%photoCounterX++;
											}%>
											</div>
											<script>
											$(document).ready(function() {
												$('.fancybox_<%=x.Replace(" ","")%>').fancybox();
											});
											</script>	
										<%}
									}
								}
							}
						}%>
					</div>
				</div>
				
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
							<%=h.insertDate.ToString("dd/MM/yyyy HH:mm")%><br/><b><%=username%></b>&nbsp;&nbsp;<%=useraction%>
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