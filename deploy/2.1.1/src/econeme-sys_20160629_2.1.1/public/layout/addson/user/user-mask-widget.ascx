<%@control Language="c#" description="user-mask-widget-control" className="UserMaskWidgetControl"%>
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
<%@ Register TagPrefix="UserProfileWidget" TagName="render" Src="~/public/layout/addson/user/user-profile-widget.ascx" %>
<script runat="server">  
public ASP.MultiLanguageControl lang;
public ASP.UserLoginControl login;
private ConfigurationService configService;
private ICategoryRepository catrep;
private ILanguageRepository langrep;
private string action, from;
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
	get { if(_style!=null){return _style;}else{return "";} }
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
	catrep = RepositoryFactory.getInstance<ICategoryRepository>("ICategoryRepository");
	langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	configService = new ConfigurationService();
	usrHasAvatar = false;
	avatarPath = "";
	forcedAvHeight = "";
	
	if(Request.ServerVariables["HTTP_USER_AGENT"].Contains("MSIE")){
		//forcedAvHeight = " height=50";
	}
	
	UriBuilder redirectUrl = new UriBuilder(Request.Url);
	if(configService.get("use_https").value=="1")
	{	
		redirectUrl.Scheme = "https";
	}
	else
	{
		redirectUrl.Scheme = "http";
	}
	redirectUrl.Port = -1;	
	redirectUrl.Path = "login.aspx";		
	action = redirectUrl.ToString();
	
	if(logged){
		UserAttachment avatar = UserService.getUserAvatar(login.userLogged);
		if(avatar != null){
			usrHasAvatar = true;
			avatarPath = "/public/upload/files/user/"+avatar.filePath+avatar.fileName;
		}
	}
	
	from = "area_user";
	if(!String.IsNullOrEmpty(Request["from"])){
		from = Request["from"];
	}
}
</script>

<div id="user-mask-widget" style="<%=style%>" class="<%=cssClass%>">     
<%if(!logged){%>
	<script>
	function sendLoginForm(){
		if(document.login.j_username.value == "<%=lang.getTranslated("frontend.login.label.username")%>"){
			document.login.j_username.value = "";
		}
		if(document.login.j_username.value == ""){
			alert("<%=lang.getTranslated("frontend.login.js.alert.insert_username")%>");
			document.login.j_username.focus();
			return false;						
		}

		if(document.login.j_password.value == ""){
			alert("<%=lang.getTranslated("frontend.login.js.alert.insert_password")%>");
			return false;
		}					

		document.login.submit();
	}

	function cleanLoginField(formfieldId){
		var elem = document.getElementById(formfieldId);
		elem.value="";
	}

	function restoreLoginField(formfieldId, valueField){
		var elem = document.getElementById(formfieldId);
		if(elem.value==''){
			elem.value=valueField;
		}
	}
	</script>
	<h2><a href="<%=action%>"><%=lang.getTranslated("frontend.menu.label.login_button")%></a></h2>
	<form name="login" method="post" action="<%=action%>" onsubmit="return sendLoginForm();">
		<input type="hidden" name="from" value="<%=from%>">
		<input type="text" class="formfield-user-widget" name="j_username" id="j_username" value="<%=lang.getTranslated("frontend.login.label.username")%>" onFocus="cleanLoginField('j_username');" onBlur="restoreLoginField('j_username','<%=lang.getTranslated("frontend.login.label.username")%>');">
		<br/><br/>        
		<input class="formfield-user-widget" name="j_password" id="j_password" type="text" value="<%=lang.getTranslated("frontend.login.label.password")%>"  onkeypress="javascript:return notSpecialCharAndSpaceButReturn(event);"/>
		<script>
		$('#j_password').focus(function() {        
			$('#j_password').val("");
			document.getElementById('j_password').setAttribute('type', 'password');
		});
		</script>           
		<br/>
		<input type="checkbox" value="1" name="keep_logged" style="vertical-align:middle;">&nbsp;<span><%=lang.getTranslated("frontend.login.label.keep_logged")%></span>
		<input name="sendForm" type="submit" value="<%=lang.getTranslated("frontend.menu.label.login_button")%>"/>
	</form>
		
	<ul>
		<li><br/></li>
		<li><h2><a href="/area_user/account.aspx"><%=lang.getTranslated("frontend.menu.label.not_registered_user")%></a></h2></li>
		<li><p><%=lang.getTranslated("frontend.header.label.subscribe")%></p></li>
	</ul>
<%}else{%>     	      
	<h2><%//=lang.getTranslated("frontend.header.label.utente")%>&nbsp;<em><%=login.userLogged.username%></em></h2>
	<%=DateTime.Now.ToString("dd/MM/yyyy")%><input type="text" name="clock" id="user-mask-clock" value="<%=DateTime.Now.ToString("HH:mm")%>">
	<div style="float:left;">
	<script>
	  $(function() {
		$(".imgAvatarUser").aeImageResize({height: 50, width: 50});
	  });
	</script>	
	<%if (usrHasAvatar) {%>
		<img class="imgAvatarUser" align="top" width="50" <%=forcedAvHeight%> src="<%=avatarPath%>" />
	<%}else{%>
		<img class="imgAvatarUser" align="top" width="50" <%=forcedAvHeight%> src="/common/img/unkow-user.jpg" />
	<%}%>
	<%if(!String.IsNullOrEmpty(avatarPath)){%>
	<script>
		var varIntervalCounter = 0;
		var myTimer;
		
		var int=self.setInterval(function(){clock()},1000);
		function clock()
		{
			var d=new Date();
			var t=d.toLocaleTimeString();
			t=t.substring(0,t.lastIndexOf('.'));
			document.getElementById("user-mask-clock").value=t;
		}
  	
		function reloadAvatarImage(){       
			  preloadSelectedImages("<%=avatarPath%>");
			  $(".imgAvatarUser").aeImageResize({height: 50, width: 50});
			  varIntervalCounter++;
			  
			  if(varIntervalCounter>10){
				//alert("varIntervalCounter:"+varIntervalCounter+" - chiamo clearInterval su : "+myTimer);
				clearInterval(myTimer);    
			  }
		}
			
		jQuery(document).ready(function(){	
		  myTimer = setInterval("reloadAvatarImage()",100);
		});
	</script>	
	<%}%>
	</div>
	<div style="float:left;">	
	<a href="/area_user/account.aspx"><%=lang.getTranslated("frontend.area_user.manage.label.profile")%></a>
	<!--nsys-incecom1-->
	<%if(configService.get("disable_ecommerce").value == "0") {%>
	<a href="/public/templates/shopping-cart/checkout.aspx?ext_ger=card"><%=lang.getTranslated("frontend.area_user.index.label.go_to_carrello")%></a>
	<a href="/area_user/userorders.aspx"><%=lang.getTranslated("frontend.area_user.index.label.list_ordini")%></a>
	<%}%>
	<!---nsys-incecom1-->
	<!--nsys-modblog1--><!---nsys-modblog1-->
	<a href="/logoff.aspx"><%=lang.getTranslated("frontend.header.label.logoff")%></a>
	</div>
	<!--nsys-modcommunity3--><!---nsys-modcommunity3-->
	<div id="clear"></div>	
<%}%>
</div>	