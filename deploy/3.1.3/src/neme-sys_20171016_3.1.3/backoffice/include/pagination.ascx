<%@control Language="c#" description="pagination-control" className="BoPaginationControl"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Data" %>
<%@ import Namespace="System.Threading" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">  
private ConfigurationService configService = new ConfigurationService();

private int _maxVisiblePages;	
public int maxVisiblePages {
	get { if(_maxVisiblePages!=null){return _maxVisiblePages;}else{return 10;} }
	set { _maxVisiblePages = value; }
}

private int _totalPages;	
public int totalPages {
	get { return _totalPages; }
	set { _totalPages = value; }
}

private int _currentPage;	
public int currentPage {
	get { return _currentPage; }
	set { _currentPage = value; }
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
private string _pageForward;	
public string pageForward {
	get { return _pageForward; }
	set { _pageForward = value; }
}
private string _parameters;	
public string parameters {
	get { return _parameters; }
	set { _parameters = value; }
}

private int _startPage;	
public int startPage {
	get { return _startPage; }
}

private int _endPage;	
public int endPage {
	get { return _endPage; }
}

private int _index;	
public int index {
	get { return _index; }
	set { _index = value; }
}


protected string getTranslated(string keyword)
{
  return MultiLanguageService.translate(keyword,_currentLangCode,_defaultLangCode); 
}

protected void Page_Load(Object sender, EventArgs e)
{ 
	set();
}

protected void set() 
{
	// risolvo current langCode in base al cascade su Session,Request,Locale
	_currentLangCode = MultiLanguageService.getLangCode((string)Session["bo-lang-code"], Request["lang_code"], Convert.ToBoolean(Convert.ToInt32(configService.get("use_locale").value)));

	//_currentLangCode = (string)Session["lang-code"];
	//if (!String.IsNullOrEmpty(Request["lang_code"]))
	//{
		//_currentLangCode = Request["lang_code"];
		Session["bo-lang-code"] = _currentLangCode;
	//}
	//if (String.IsNullOrEmpty(_currentLangCode) && (bool)configService.get("use_locale").value && !String.IsNullOrEmpty(MultiLanguageService.convertLocaleCode(Thread.CurrentThread.CurrentCulture.LCID.ToString())))
	//{
		//_currentLangCode = MultiLanguageService.convertLocaleCode(Thread.CurrentThread.CurrentCulture.LCID.ToString());
		//Session["lang-code"] = _currentLangCode;
	//}		

	_endPage = _currentPage + _maxVisiblePages-1;
	_startPage = 1;
	
	//' qualche controllo
	if (_endPage > _totalPages) {
		_endPage = _totalPages;
	}
	
	//' qualche controllo
	if (_startPage < _currentPage) {
		_startPage = _currentPage;
	}	
	if((_endPage - _startPage) < _maxVisiblePages) {
		_startPage = _endPage - _maxVisiblePages+1;
	}
	if (_startPage < 1) {
		_startPage = 1;
	}
}
</script>
	
<%if(totalPages>1){%>
	<script>
		function sendPaginationForm<%=_index%>(pageNum){
			document.form_pagination<%=_index%>.page.value=pageNum;
			document.form_pagination<%=_index%>.submit();
		}
	</script>

	<%if (_currentPage > 1) {%>
		<a title="<%=getTranslated("portal.commons.pagination.label.prec_page")%>" class="linkPaginazione" href="javascript:sendPaginationForm<%=_index%>('<%=_currentPage-1%>');"><span class="linkPaginazioneLabel"><%=getTranslated("portal.commons.pagination.label.prec_page")%></span>&nbsp;&lt;&nbsp;</a>
	<%}%>

	<%for (int i = startPage; i<= endPage;i++){
		if(i== _currentPage) {%>
			<a title="<%=getTranslated("portal.commons.pagination.label.page")+" "+i%>" class="linkPaginazioneActive" href="javascript:sendPaginationForm<%=_index%>('<%=i%>');"><span class="linkPaginazione">[</span><%=i%><span class="linkPaginazione">]</span></a>
		<%}else{%>
			<a title="<%=getTranslated("portal.commons.pagination.label.page")+" "+i%>" class="linkPaginazione" href="javascript:sendPaginationForm<%=_index%>('<%=i%>');"><%=i%></a>
		<%}	  
	}%>

	<%if (_currentPage <  _totalPages) {%>
		<a title="<%=getTranslated("portal.commons.pagination.label.next_page")%>" class="linkPaginazione" href="javascript:sendPaginationForm<%=_index%>('<%=_currentPage+1%>');">&nbsp;&gt;&nbsp;<span class="linkPaginazioneLabel"><%=getTranslated("portal.commons.pagination.label.next_page")%></span></a>
	<%}%>

	<form name="form_pagination<%=_index%>" method="post" action="<%=pageForward%>">
		<input type="hidden" name="page" value="">	
		<%
		string[] p = null;
		if(!String.IsNullOrEmpty(parameters)){
			p = parameters.Split('&');
		}
		if(p!=null){
			foreach (string k in p){
				string[] values = k.Split('=');
				if(values!=null){%>
					<input type=hidden name="<%=values[0]%>" value="<%=values[1]%>"> 	
				<%}			
			}
		}%> 
	</form>
<%}%>
