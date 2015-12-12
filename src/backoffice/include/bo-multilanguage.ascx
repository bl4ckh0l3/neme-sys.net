<%@control Language="c#" description="multilanguage-control" className="BoMultiLanguageControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
private ConfigurationService configService = new ConfigurationService();

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
	_defaultLangCode = configService.get("bo_lang_code_default").value;

	// risolvo current langCode in base al cascade su Request,Session,Locale
	_currentLangCode = MultiLanguageService.getLangCode((string)Session["bo-lang-code"], Request["lang_code"], Convert.ToBoolean(Convert.ToInt32(configService.get("use_locale").value)));
	
	//_currentLangCode = (string)Session["bo-lang-code"];
	//if (!String.IsNullOrEmpty(Request["lang_code"]))
	//{
		//_currentLangCode = Request["lang_code"];
		Session["bo-lang-code"] = _currentLangCode;
	//}
	//if (String.IsNullOrEmpty(_currentLangCode) && (bool)configService.get("use_locale").value && !String.IsNullOrEmpty(MultiLanguageService.convertLocaleCode(Thread.CurrentThread.CurrentCulture.LCID.ToString())))
	//{
		//_currentLangCode = MultiLanguageService.convertLocaleCode(Thread.CurrentThread.CurrentCulture.LCID.ToString());
		//Session["bo-lang-code"] = _currentLangCode;
	//}	
}

public string getTranslated(string keyword) 
{
	//Response.Write("<b>method getTranslated</b> - keyword:"+keyword+" - _currentLangCode:"+_currentLangCode+" - _defaultLangCode:"+_defaultLangCode+"<br>");
	return MultiLanguageService.translate(keyword,_currentLangCode,_defaultLangCode);
}

protected void Page_Load(Object sender, EventArgs e)
{
	set();
	label.Text = getTranslated(_keyword);
}	
</script>
<asp:Literal id="label" runat="server" />