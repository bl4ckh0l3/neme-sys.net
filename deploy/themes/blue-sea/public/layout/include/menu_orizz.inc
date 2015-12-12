<script>
function openLinkMenuOrizz(numGer, actionUrl){
    if(actionUrl!="#"){
      document.menu_orizz_linker.gerarchia.value=numGer;
      document.menu_orizz_linker.action=actionUrl;
      document.menu_orizz_linker.submit();
    }
}
           
function ajaxLoadMenuOrizz(){
  var query_string = "gerarchia=<%=request("gerarchia")%>";
  //alert("query_string: "+query_string);

  $.ajax({
    async: true,
    type: "GET",
    cache: false,
    url: "<%=Application("baseroot")&"/public/layout/include/menu_orizz_ajax.asp"%>",
    data: query_string,
    success: function(response) {
      //alert(response);
      $("#loading-menu-orizz").hide();
      $("#myslidemenu").append(response);
      $("#myslidemenu").fadeIn(1000);
      jqueryslidemenu.buildmenu("myslidemenu", arrowimages);
    },
    error: function() {
      //alert("errorrrrrrrrrr!");
      $("#loading-menu-orizz").hide();
    }
  });
}

jQuery(document).ready(function(){
  ajaxLoadMenuOrizz();
});
</script> 
<div id="myslidemenu" class="jqueryslidemenu">
  <span id="loading-menu-orizz"><img src="<%=Application("baseroot")&"/common/img/loading_icon2.gif"%>" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:2px;padding-bottom:0px;"></span>
</div>
<form name="menu_orizz_linker" method="post" action="">
<input type="hidden" name="gerarchia" value="">
<input type="hidden" name="modelPageNum" value="1">
</form>     