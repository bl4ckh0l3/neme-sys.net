    <script>
    function openLinkMenuSX(numGer, actionUrl){
        if(actionUrl!="#"){
          document.menu_sx_linker.gerarchia.value=numGer;
          document.menu_sx_linker.action=actionUrl;
          document.menu_sx_linker.submit();
        }
    }
           
    function ajaxLoadMenuSX(){
      var query_string = "gerarchia=<%=request("gerarchia")%>";
      //alert("query_string: "+query_string);

      //$("#ajx_menu_sx").hide();
      $.ajax({
        async: true,
        type: "GET",
        cache: false,
        url: "<%=Application("baseroot")&"/public/layout/include/menu_vert_sx_ajax.asp"%>",
        data: query_string,
        success: function(response) {
          //alert(response);
          //$("#ajx_menu_sx").empty();
          $("#loading-menu-sx").hide();
          $("#ajx_menu_sx").append(response);
          $("#ajx_menu_sx").fadeIn(1000);
        },
        error: function() {
          //alert("errorrrrrrrrrr!");
          $("#loading-menu-sx").hide();
        }
      });
    }

    jQuery(document).ready(function(){
      ajaxLoadMenuSX();
    });
    </script>    
    <div id="menu-left">
      <span id="loading-menu-sx"><img src="<%=Application("baseroot")&"/common/img/loading_icon2.gif"%>" hspace="0" vspace="0" border="0" align="center" alt="" style="padding-top:50px;padding-bottom:50px;"></span>
			<ul id="ajx_menu_sx" style="display:none;">
      </ul>
      <form name="menu_sx_linker" method="post" action="">
      <input type="hidden" name="gerarchia" value="">
      <input type="hidden" name="modelPageNum" value="1">
      </form>
      <ul>
			<!--nsys-inc1-->
			<%if(Application("disable_ecommerce") = 0) then%>
				<li><a <%if(request("ext_ger") = "card") then response.Write("class=""link-attivo""")%> href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?ext_ger=card"%>"><%=lang.getTranslated("frontend.menu.label.go_to_carrello")%><img src="<%=Application("baseroot")&"/common/img/cart.png"%>" alt="<%=lang.getTranslated("frontend.menu.label.go_to_carrello")%>" hspace="2" vspace="2" border="0" align="absmiddle"></a></li>
			<%end if%>
			<!---nsys-inc1-->
			</ul>
      
      <!-- #include virtual="/public/layout/addson/user/user_mask_widget.inc" -->
			
      <%if isEmpty(Session("objUtenteLogged")) then%>
			<ul>
			<li><h3><%=lang.getTranslated("frontend.menu.label.new_user")%>?</h3></li>
			<li><h2><a href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&"/area_user/manageUser.asp"%>"><%=lang.getTranslated("frontend.menu.label.not_registered_user")%></a></h2></li>
			<li><p><%=lang.getTranslated("frontend.header.label.subscribe")%></p></li>
			</ul>
      <%end if%>
		</div>