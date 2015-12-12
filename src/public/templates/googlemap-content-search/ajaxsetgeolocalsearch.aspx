<%@ Page Language="C#" Debug="false" ValidateRequest="false"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Runtime.Remoting" %>
<%@ import Namespace="System.Reflection" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Collections.Specialized" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %> 
<%@ import Namespace="com.nemesys.services" %> 
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;
protected ASP.UserLoginControl login;
protected ConfigurationService confservice;
	
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
	bool logged = login.checkedUser();
	confservice = new ConfigurationService();	
	ILoggerRepository lrep = RepositoryFactory.getInstance<ILoggerRepository>("ILoggerRepository");
	Logger log;

	string objtype = Request["type"];
	string vertices = Request["vertices"];
	string center = Request["center"];
	string radius = Request["radius"];
	string current_overlay = Request["current_overlay"];
	string last_selection= Request["last_selection"];
	
	if(Session["geolocalsearchpoly"] == null || Session["geolocalsearchpoly"].GetType().ToString().IndexOf("System.Collections.Generic.Dictionary")<0){
		IDictionary<string,object> objGeolocalSearch = new Dictionary<string,object>();
		Session["geolocalsearchpoly"] = objGeolocalSearch;		
	}
	
	((IDictionary<string,object>)Session["geolocalsearchpoly"])["type"] =  objtype;
	((IDictionary<string,object>)Session["geolocalsearchpoly"])["current_overlay"] =  current_overlay;
	((IDictionary<string,object>)Session["geolocalsearchpoly"])["last_selection"] =  last_selection;
	((IDictionary<string,object>)Session["geolocalsearchpoly"])["search_active"] =  "0"; 
	
	if(objtype=="1"){
		((IDictionary<string,object>)Session["geolocalsearchpoly"])["vertices"] =  vertices; 		
	}else if(objtype=="2"){
		((IDictionary<string,object>)Session["geolocalsearchpoly"])["center"] =  center; 	
		((IDictionary<string,object>)Session["geolocalsearchpoly"])["radius"] =  radius; 
	}else if(objtype=="3"){
		((IDictionary<string,object>)Session["geolocalsearchpoly"]).Clear();
		((IDictionary<string,object>)Session["geolocalsearchpoly"])["search_active"] =  "0"; 
	}else{
		Session["geolocalsearchpoly"] = null;
	}	
}
</script>