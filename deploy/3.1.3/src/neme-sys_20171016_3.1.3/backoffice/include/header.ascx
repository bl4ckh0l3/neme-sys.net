<%@control Language="c#" description="backend-header"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Web" %>
<%@ import Namespace="System.Resources" %>
<%@ import Namespace="System.Xml" %>
<%@ import Namespace="System.IO" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/backoffice/include/bo-multilanguage.ascx" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<script runat="server">
private ASP.BoMultiLanguageControl lang;
private ASP.UserLoginControl login;
protected IList<Language> languages;
private ConfigurationService configService;
protected string baseURL,secureURL;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.BoMultiLanguageControl)LoadControl("~/backoffice/include/bo-multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	login.acceptedRoles = "1,2";
	if(!login.checkedUser()){
		//Response.Redirect("~/login.aspx?error_code=002");
		return;
	}
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	
	ILanguageRepository langrep = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");
	try{			
		languages = langrep.getLanguageList();	
		if(languages == null){				
			languages = new List<Language>();						
		}
	}catch (Exception ex){
		languages = new List<Language>();
	}
	//IMultiLanguageRepository rep = new MultiLanguageRepository();
	//MultiLanguage ml = rep.getById(1001);
	//Response.Write("keyword: "+ml.keyword+" - value: "+ml.value+" - lang: "+ml.langCode+"<br>");
	/*
	//XmlDocument xml = new XmlDocument();
	
	//string resxFile = Server.MapPath("~/app_data/conf/lang-code-mapping.xml");
	//Get a StreamReader class that can be used to read the file
	try{
		StreamReader reader = File.OpenText(resxFile);
		//Now, read the entire file into a string
		xml.Load(reader);
		reader.Close();	
	}catch(Exception ex){
		//Response.Write("An error occured: " + ex.Message+"<br><br><br>"+ex.StackTrace);
	}

	//IList<Config> results = new List<Config>();
	
	//XmlNode node = xml.SelectSingleNode("/root/data");
	//System.Web.HttpContext.Current.Response.Write(node.Attributes.GetNamedItem("name").Value+"<br>");
	
	XmlNodeList  xnList = xml.SelectNodes("//root/lang-code-mapping");	
	//XmlNode xnList = xml.FirstChild;
	
	foreach (XmlNode nd in xnList)
	{
		//System.Web.HttpContext.Current.Response.Write("key name: "+nd["keyword"].InnerText+" - value: "+nd["value"].InnerText+"<br>");			
	}*/
	
	//string name = Thread.CurrentThread.CurrentCulture.Name;
	//System.Web.HttpContext.Current.Response.Write("locale name: "+name+"<br>");	
	
	//int identifier = Thread.CurrentThread.CurrentCulture.LCID;
	//System.Web.HttpContext.Current.Response.Write("local identifier: "+identifier+"<br>");
	
	configService = new ConfigurationService();
	baseURL = CommonService.getBaseUrl(Request.Url.ToString(),0).ToString();
	secureURL = CommonService.getBaseUrl(Request.Url.ToString(),1).ToString();
}
</script>
<div id="backend-header">
  <div id="backend-header-container">
    <div id="backend-header-logo"><a class="logo" href="<%=secureURL%>backoffice/index.aspx"><img src="/backoffice/img/logo.png" hspace="0" vspace="0" border="0" align="left"></a></div>

    <div id="backend-header-language">
    <%foreach (Language k in languages){%>
		<a title="<%=lang.getTranslated("portal.header.label.desc_lang."+k.label)%>" class="link-lang-fruizione<%if(k.label==lang.currentLangCode){Response.Write("-active");}%>" href="<%=secureURL%>backoffice/index.aspx?lang_code=<%=k.label%>"><img src="/backoffice/img/flag/flag-<%=k.label%>.png" alt="" width="16" height="11" border="0" /></a>
    <%}%>
    </div> 
      
    <div id="backend-header-user">
    <strong><lang:getTranslated keyword="backend.header.utente" runat="server" />:</strong>&nbsp;<%=login.userLogged.username%>&nbsp;&nbsp;<input type="button" class="buttonLogOff" hspace="2" vspace="0" border="0" align="absmiddle" value="<%=lang.getTranslated("backend.header.logoff")%>" onClick="javascript: document.location.href='<%=baseURL%>logoff.aspx';" />
    </div>
  </div>
</div>