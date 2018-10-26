<%@control Language="c#" description="common-css-js-control" Debug="true"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
protected ConfigurationService confservice;
protected string currentLangCode;

protected void Page_Load(Object sender, EventArgs e)
{
	confservice = new ConfigurationService();
	currentLangCode = MultiLanguageService.getLangCode((string)Session["lang-code"], Request["lang_code"], Convert.ToBoolean(Convert.ToInt32(confservice.get("use_locale").value)));
	if(String.IsNullOrEmpty(currentLangCode)){
		currentLangCode = confservice.get("lang_code_default").value;
	}
}
</script>

<%if(!String.IsNullOrEmpty(confservice.get("analytics_account").value)){%>
<!--  ******************************************** START: SCRIPT TRACKING ANALYTICS ******************************************** -->
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-13199767-3"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', '<%=confservice.get("analytics_account").value%>');
</script>
<!--  ******************************************** END: SCRIPT TRACKING ANALYTICS ******************************************** -->
<%}%>

<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
<link rel="stylesheet" href="/common/css/jquery.datetimepicker.css" type="text/css">

<link rel="stylesheet" href="/common/css/jquery-ui.min.css" type="text/css">
<!-- codice per gestire un menu orizzontale con jquery al posto del menu classico verticale a sinistra -->
<link rel="stylesheet" type="text/css" href="/public/layout/css/jqueryslidemenu.css" />
<!--[if lte IE 7]>
<style type="text/css">
html .jqueryslidemenu{height: 1%;} /*Holly Hack for IE7 and below*/
</style>
<![endif]-->

<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="/common/js/jquery.google-analytics.js"></script>
<script type="text/javascript" src="/common/js/jquery.ae.image.resize.min.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.min.js"></script>
<script type="text/javascript" src="/common/js/javascript_global.min.js"></script>
<script type="text/javascript" src="/common/js/jqueryslidemenu.min.js"></script>
<!--script type="text/javascript" src="/common/js/jquery.timers.min.js"></script-->
<script type="text/javascript" src="/common/js/highcharts.min.js"></script>
<script type="text/javascript" src="/common/js/jquery.datetimepicker.min.js"></script>

<!-- carico l'editor html semplificato CLEditor -->
<link rel="stylesheet" type="text/css" href="/cleditor/jquery.cleditor.css" />      
<script type="text/javascript" src="/cleditor/jquery.cleditor.min.js"></script>

<%if(!String.IsNullOrEmpty(confservice.get("googlemaps_key").value)){%>
<!--  ****************************************** INTEGRAZIONE GOOGLEMAP API ****************************************** -->
<script src="https://maps.googleapis.com/maps/api/js?key=<%=confservice.get("googlemaps_key").value%>&amp;sensor=false&amp;libraries=drawing,geometry,places&amp;language=<%=currentLangCode.ToLower()%>" type="text/javascript"></script>
<script type="text/javascript" src="/common/js/markerclusterer_compiled.min.js"></script>
 <%}%>