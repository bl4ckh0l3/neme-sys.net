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
		
		if(login.userLogged != null && (login.userLogged.role.isAdmin() || login.userLogged.role.isEditor())){
			Response.Redirect("~/backoffice/index.aspx");
		}
		
		if(!loggedin){
			Response.Redirect("~/login.aspx");
		}
		
		ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
		usrrep = RepositoryFactory.getInstance<IUserRepository>("IUserRepository");
		confservice = new ConfigurationService();
		bolFoundPhotos = false;

		StringBuilder url = new StringBuilder("/error.aspx?error_code=");	
		StringBuilder happyUrl = new StringBuilder("/area_user/photos.aspx");		
		Logger log = new Logger();

		basePath = new StringBuilder(Request.Url.Scheme).Append("://").Append(Request.Url.Host).Append("/public/upload/files/user/").ToString();
		albums = new Dictionary<string, IList<UserAttachment>>();

		try
		{		
			User user = usrrep.getById(login.userLogged.id);
			if(user != null && user.attachments != null && user.attachments.Count>0){
				attachments = user.attachments;					
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

		bool carryOn;
		
		//******** AGGIUNGO NUOVA FOTO
		if("addphoto".Equals(Request["operation"]))
		{
			carryOn = true;
			try
			{			
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
					switch (Path.GetExtension(fileName))
					{
						case ".jpg": case ".jpeg": case ".png": case ".gif": case ".bmp":					
							UserService.SaveStreamToFile(MyFile.InputStream, HttpContext.Current.Server.MapPath("~/public/upload/files/user/"+login.userLogged.id+"/"+MyFile.FileName));
		
							User user = usrrep.getById(login.userLogged.id);	
							
							UserAttachment attachment = new UserAttachment();
							attachment.idUser = login.userLogged.id;
							attachment.fileName = fileName;	
							attachment.contentType = MyFile.ContentType;
							attachment.filePath = login.userLogged.id+"/";
							attachment.fileDida = Request["file_dida"];
							attachment.fileLabel = Request["file_label"];
							attachment.isAvatar = false;							
							attachment.insertDate = DateTime.Now;
		
							user.attachments.Add(attachment);
							usrrep.update(user);
							login.updateUserLogged(user);
							break;
						default:
							throw new Exception("022");										
							break;
					}	
				}			
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
		}else if("deletephoto".Equals(Request["operation"])){
			carryOn = true;
			try
			{
				User user = usrrep.getById(login.userLogged.id);
				int attachId = Convert.ToInt32(Request["id"]);

				IList<UserAttachment> newAttachments = new List<UserAttachment>();
				foreach(UserAttachment attach in user.attachments){
					if(attach.id != attachId){
						newAttachments.Add(attach);
					}
				}
				
				user.attachments = newAttachments;
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

function insertPhoto(){
	document.form_photos.submit();      
}

function deletePhoto(id){
	if(confirm("<%=lang.getTranslated("frontend.area_user.manage.label.confirm_del_attach")%>")){
		location.href='/area_user/photos.aspx?operation=deletephoto&id='+id;      
	}
}

function hidePhotoForm(){
	$('#send-photo').toggle();
}

function changeAlbumName(){
	if($('#file_label').is(':visible')){
		$('#file_label').hide();
		$('#file_label_c').show();		
	}else{
		$('#file_label_c').hide();
		$('#file_label').show();		
	}	
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
			<h1><%=lang.getTranslated("frontend.header.label.utente_photo")%>&nbsp;<em><%=login.userLogged.username%></em></h1>

					<p class="area_user_tabs">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.profile")%>" type="button" onclick="javascript:changeTab(1);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.modify")%>" type="button" onclick="javascript:changeTab(2);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.friends")%>" type="button" onclick="javascript:changeTab(3);">
					<input name="profile" align="left" value="<%=lang.getTranslated("frontend.area_user.manage.label.photos")%>" type="button" class="active" onclick="javascript:changeTab(4);">
					</p>
	
			<div id="profilo-utente" style="margin-top:20px;">      
				<div id="send-photo" style="margin-bottom:10px;vertical-align:top;text-align:left;font-size: 10px;text-decoration: none;border:none;padding-left:0px;padding-right:0px;padding-bottom:5px;background:#FFFFFF;">
					<form action="/area_user/photos.aspx" method="post" name="form_photos" accept-charset="UTF-8" enctype="multipart/form-data">		
						<input type="hidden" value="addphoto" name="operation">		
						<br/>
						<div style="float:left;margin-right:20px;">
							<span class="labelForm"><%=lang.getTranslated("frontend.area_user.manage.label.create_dida")%></span><br/>
							<input type="text" value="" name="file_dida">
						</div>
						<div style="float:top;margin-right:20px;">					
							<span class="labelForm"><%=lang.getTranslated("frontend.area_user.manage.label.create_album")%></span>
							<img onclick="javascipt:changeAlbumName();" style="cursor:pointer;" align="absmiddle" src="/backoffice/img/arrow_rotate_clockwise.png" title="<%=lang.getTranslated("frontend.area_user.manage.label.use_exist_album")%>" hspace="2" vspace="0" border="0"><br/>
							<input type="text" value="" name="file_label" id="file_label">
							<select name="file_label_c" id="file_label_c" style="display:none;min-width:150px;vertical-align:top;">
							<option></option>
							<%
							if(albums.Keys != null){
								foreach(string x in albums.Keys){
									if(x!="none"){%>
									<option value="<%=x%>"><%=x%></option>
									<%}
								}
							}%>
							</select>	
						</div>
						<br/>						
						<input type="file" name="imageupload" />&nbsp;&nbsp;
						<input name="send" align="middle" value="<%=lang.getTranslated("frontend.area_user.manage.label.insert")%>" type="button" onclick="javascript:insertPhoto();">
					</form>
					<script type="text/javascript">												
							$("#file_label_c").change(function(){
								$("#file_label").val($('#file_label_c').val());
								$("#file_label_c").hide();
								$("#file_label").show();
							});
												
							$("#file_label_c").blur(function(){
								$("#file_label").val($('#file_label_c').val());
								$("#file_label_c").hide();
								$("#file_label").show();
							});
					</script>
				</div>

				<div id="info-utente" style="margin-bottom:10px;padding:5px;">	
					<%
					if(bolFoundPhotos) {
						int photoCounter = 1;

						IList<UserAttachment> itemsNoAlbum = null;
						if(albums.TryGetValue("none", out itemsNoAlbum)){			
							foreach (UserAttachment attachment in itemsNoAlbum){
								string divfloat = "left";
								if(photoCounter % 3 == 0){divfloat = "top";}%>				
								<div style="margin-bottom:10px;float:<%=divfloat%>;margin-right:5px;width:200px;height:200px;overflow:hidden;border:1px solid #E3E3E3;text-align:center;vertical-align:middle;">
								<div style="position:absolute;background-color:#FFFFFF;cursor:pointer;" onclick="javascript:deletePhoto(<%=attachment.id%>);" title="<%=lang.getTranslated("frontend.area_user.manage.label.delete_photo")%>">x</div>
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
											<div style="position:absolute;background-color:#FFFFFF;cursor:pointer;" onclick="javascript:deletePhoto(<%=attachment.id%>);" title="<%=lang.getTranslated("frontend.area_user.manage.label.delete_photo")%>">x</div>
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