<%@control Language="c#" description="multilanguage-control" className="MultiLanguageControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<script runat="server">
private ConfigurationService configService = new ConfigurationService();
private ILanguageRepository langRepository = RepositoryFactory.getInstance<ILanguageRepository>("ILanguageRepository");

private string _keyword;	
public string keyword {
	get { return _keyword; }
	set { _keyword = value; }
}

private string _defaultLangCode;	
public string defaultLangCode {
	get { return _defaultLangCode; }
	set { _defaultLangCode = value; }
}

private string _currentLangCode;	
public string currentLangCode {
	get { return _currentLangCode; }
}

public void set() 
{
	_defaultLangCode = configService.get("lang_code_default").value;
	
	// risolvo current langCode in base al cascade su Session,Request,Locale, URL
	IList<Language> languages =  langRepository.findActive(true);

	string forcedLangCode = (string)HttpContext.Current.Items["lang-code"];
	
	if(!String.IsNullOrEmpty(Request["lang_code"])){
		forcedLangCode = Request["lang_code"];
	}
	string retrivedLangURL = Request.Url.AbsolutePath;
	string test = Request.Path.ToLower();

	//Response.Write("retrivedLangURL:"+retrivedLangURL+" -forcedLangCode:"+forcedLangCode+" -test:"+test+"<br>");

	foreach(Language r in languages)
	{
		//Response.Write("language:"+r.ToString()+"<br>");
		if(retrivedLangURL.Contains("/"+r.label+"/") || retrivedLangURL.Contains("/"+r.label.ToLower()+"/"))
		{
			forcedLangCode = r.label;
			//Response.Write("new forcedLangCode:"+forcedLangCode+"<br>");
			break;		
		}
	}

	_currentLangCode = MultiLanguageService.getLangCode((string)Session["lang-code"], forcedLangCode, Convert.ToBoolean(Convert.ToInt32(configService.get("use_locale").value)));
	Session["lang-code"] = _currentLangCode;		
}
	
public string getTranslated(string keyword) 
{
	return MultiLanguageService.translate(keyword,_currentLangCode,_defaultLangCode);
}

protected void Page_Load(Object sender, EventArgs e)
{
	set();
	label.Text = getTranslated(_keyword);
}	
</script>
<asp:Literal id="label" runat="server" />