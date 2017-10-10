<%@ Page Language="C#"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e)
{
	//<!--nsys-demologoff1-->
	//'**** elimino l'utente loggato alla lista degli utenti online	
	try{
		UserService.removeOnlineUser(Session.SessionID, (User)Session["user-online"]);
	}catch(Exception ex){}
	//<!---nsys-demologoff1-->

	HttpCookie myCookie = new HttpCookie("KeepLoggedUser");
	myCookie.Expires = DateTime.Now.AddDays(-1d);
	Response.Cookies.Add(myCookie);

	//Response.Write("<br>username: "+Session["user-logged"]);
	Session.Abandon();
	
	Response.Redirect(CommonService.getBaseUrl(Request.Url.ToString(),0).ToString());
}
</script>