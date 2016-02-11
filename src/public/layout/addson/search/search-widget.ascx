<%@control Language="c#" description="search-widget"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/common-user-logged.ascx" %>
<%@ Register TagPrefix="lang" TagName="getTranslated" Src="~/common/include/multilanguage.ascx" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
private ASP.MultiLanguageControl lang;
private ASP.UserLoginControl login;
private string cssClass, url;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
    login = (ASP.UserLoginControl)LoadControl("~/common/include/common-user-logged.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	login.acceptedRoles = "";
	bool logged = login.checkedUser();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;
	cssClass = Request["cssClass"];
	ConfigurationService confservice = new ConfigurationService();

	StringBuilder searchPath = new StringBuilder();
	if(confservice.get("url_with_langcode_prefix").value=="1")
	{	
		searchPath.Append(lang.currentLangCode.ToLower()).Append("/");
	}
	searchPath.Append("search/search_results");
	if(confservice.get("url_rewrite_file_ext").value=="1")
	{	
		searchPath.Append(".aspx");
	}
	
	UriBuilder builder = new UriBuilder(Request.Url);
	builder.Scheme = "http";
	builder.Port = -1;	
	builder.Query="";
	builder.Path = searchPath.ToString();		
	url = builder.ToString();
}
</script>

<script language="JavaScript">
	function doSearch(){
		if(document.search.search_full_txt.value == "" || document.search.search_full_txt.value == "<%=lang.getTranslated("frontend.header.label.search")%>"){
			alert("<%=lang.getTranslated("frontend.menu.js.alert.insert_search_key")%>");
			return false;
		}
		document.search.submit();
	}
	function cleanSearchField(formfieldId){
	  var elem = document.getElementById(formfieldId);
	  elem.value="";
	}
	
	function restoreSearchField(formfieldId, valueField){
	  var elem = document.getElementById(formfieldId);
	  if(elem.value==''){
		elem.value=valueField;
	  }
	}
</script>
<form method="post" name="search" action="<%=url%>" onSubmit="return doSearch();">
<input name="send" align="absmiddle" class="buttonSearchHead" type="image" hspace="0" vspace="0" src="/common/img/zoom.png"><input name="search_full_txt" id="search_full_txt" type="text" value="<%=lang.getTranslated("frontend.header.label.search")%>" onFocus="cleanSearchField('search_full_txt');" onBlur="restoreSearchField('search_full_txt','<%=lang.getTranslated("frontend.header.label.search")%>');"></form>