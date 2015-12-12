<%@control Language="c#" description="common-css-js-control"%>
<%@ import Namespace="com.nemesys.model" %>
<%@ import Namespace="com.nemesys.database.repository" %>
<%@ import Namespace="com.nemesys.services" %>
<script runat="server">
protected ConfigurationService confservice;

protected void Page_Load(Object sender, EventArgs e)
{
	confservice = new ConfigurationService();
}
</script>
<link rel="shortcut icon" type="image/x-icon" href="/favicon.ico">
<link rel="stylesheet" href="/public/layout/css/stile.css" type="text/css">
<link rel="stylesheet" href="/common/css/jquery.datetimepicker.css" type="text/css">

<link rel="stylesheet" href="/common/css/jquery-ui-latest.custom.css" type="text/css">
<!-- codice per gestire un menu orizzontale con jquery al posto del menu classico verticale a sinistra -->
<link rel="stylesheet" type="text/css" href="/public/layout/css/jqueryslidemenu.css" />
<!--[if lte IE 7]>
<style type="text/css">
html .jqueryslidemenu{height: 1%;} /*Holly Hack for IE7 and below*/
</style>
<![endif]-->

<script type="text/javascript" src="/common/js/jquery-latest.min.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui-latest.custom.min.js"></script>
<script type="text/javascript" src="/common/js/jquery.google-analytics.js"></script>
<script type="text/javascript" src="/common/js/jquery.ae.image.resize.min.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/javascript_global.js"></script>
<script type="text/javascript" src="/common/js/jqueryslidemenu.js"></script>
<script type="text/javascript" src="/common/js/jquery.timers.js"></script>
<script type="text/javascript" src="/common/js/highcharts.js"></script>
<script type="text/javascript" src="/common/js/jquery.datetimepicker.js"></script>

<!-- carico l'editor html semplificato CLEditor -->
<link rel="stylesheet" type="text/css" href="/cleditor/jquery.cleditor.css" />      
<script type="text/javascript" src="/cleditor/jquery.cleditor.min.js"></script>

<%if(!String.IsNullOrEmpty(confservice.get("googlemaps_key").value)){%>
<!--  ****************************************** INTEGRAZIONE GOOGLEMAP API ****************************************** -->
<script src="https://maps.googleapis.com/maps/api/js?key=<%=confservice.get("googlemaps_key").value%>&amp;sensor=false&amp;libraries=drawing,geometry" type="text/javascript"></script>
<script type="text/javascript" src="/common/js/markerclusterer_compiled.js"></script>
 <%}%>

 <%if(!String.IsNullOrEmpty(confservice.get("analytics_account").value)){%>
<!--  ******************************************** START: SCRIPT TRACKING ANALYTICS ******************************************** -->
<script type="text/javascript">
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '<%=confservice.get("analytics_account").value%>']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script>
<!--  ******************************************** END: SCRIPT TRACKING ANALYTICS ******************************************** -->
 <%}%>