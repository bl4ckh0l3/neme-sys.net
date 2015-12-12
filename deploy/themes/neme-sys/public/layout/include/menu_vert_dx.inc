    <script>
    function openLinkMenuDX(numGer, actionUrl){
        if(actionUrl!="#"){
          document.menu_dx_linker.gerarchia.value=numGer;
          document.menu_dx_linker.action=actionUrl;
          document.menu_dx_linker.submit();
        }
    }
           
    function ajaxLoadMenuDX(){
      var query_string = "gerarchia=<%=request("gerarchia")%>";
      //alert("query_string: "+query_string);

      $.ajax({
        async: true,
        type: "GET",
        cache: false,
        url: "<%=Application("baseroot")&"/public/layout/include/menu_vert_dx_ajax.asp"%>",
        data: query_string,
        success: function(response) {
          //alert(response);
          $("#loading-menu-dx").hide();
          $("#ajx_menu_dx").append(response);
          $("#ajx_menu_dx").fadeIn(1000);
        },
        error: function() {
          //alert("errorrrrrrrrrr!");
          $("#loading-menu-dx").hide();
        }
      });
    }

    jQuery(document).ready(function(){
      ajaxLoadMenuDX();
    });
    </script> 
  <div id="menu-right">
      <span id="loading-menu-dx"><img src="<%=Application("baseroot")&"/common/img/loading_icon2.gif"%>" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:50px;padding-bottom:50px;"></span>
			<ul id="ajx_menu_dx" style="display:none;">
      </ul>
      <form name="menu_dx_linker" method="post" action="">
      <input type="hidden" name="gerarchia" value="">
      <input type="hidden" name="modelPageNum" value="1">
      </form>
		</div>
