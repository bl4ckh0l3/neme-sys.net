<%@control Language="c#" description="cookies-policy"%>
<%@ import Namespace="System" %>
<%@ import Namespace="System.Collections" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<%@ Reference Control="~/common/include/multilanguage.ascx" %>
<script runat="server">
protected ASP.MultiLanguageControl lang;

protected void Page_Init(Object sender, EventArgs e)
{
    lang = (ASP.MultiLanguageControl)LoadControl("~/common/include/multilanguage.ascx");
}
protected void Page_Load(Object sender, EventArgs e)
{
	lang.set();
	Response.Charset="UTF-8";
	Session.CodePage  = 65001;	
}
</script>

<script type="text/javascript">
function acceptCookie(){
	$('#cookies_policy').hide();
	setCookie("cookiespa", "true", 365);
}

function closeBox(){
	$('#cookies_policy_ext').hide();
}

function openDetail(boxid){
	$('#cookies_policy_ext').show();
}

function setCookie(cname, cvalue, exdays) {
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires +"; path=/";
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
    }
    return "";
}

function checkCookie() {
    var cpa = getCookie("cookiespa");
    if (cpa == "") {
        $('#cookies_policy').show();
    }
}

$(document).ready(function(){
	checkCookie();
});	
</script>

<div id="cookies_policy" style="display:none;">
<div align="right" style="padding-bottom:2px"><a href="javascript:acceptCookie();">x</a></div>
<%=lang.getTranslated("frontend.cookies_policy.message")%>
</div>

<div id="cookies_policy_ext" align="center" style="display:none;">
<div align="right" style="padding-right:10px"><a href="javascript:closeBox();">X</a></div>
<%=lang.getTranslated("frontend.cookies_policy.message.extended")%>
</div>