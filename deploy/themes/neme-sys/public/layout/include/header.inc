	<div id="header" class="bg_nemesys">      
      <div class="header_navbar">
        <h1 class="nemesys_h1" title="nemesys cms">ne<span>me-sys</span></h1>
        
        <div style="float:left;padding-left:20px;"><!-- #include virtual="/public/layout/addson/langs/langs_widget.inc" --></div>
        
        <div class="div_login">
          <%if not isEmpty(Session("objUtenteLogged")) then%> <a href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&"/common/include/LogOFF.asp"%>"><%=lang.getTranslated("frontend.header.label.logoff")%></a> <%else%> <a href="<%=Application("baseroot")&"/login.asp"%>"><%=lang.getTranslated("frontend.area_user.manage.label.do_login")%></a> <%end if%> <%=lang.getTranslated("frontend.area_user.manage.label.or")%> <a href="<%=Application("baseroot")&"/area_user/manageUser.asp"%>"><%=lang.getTranslated("frontend.area_user.manage.label.do_registration")%></a>
        </div>
      </div>
      
       
      <div class="navbar">
        <!-- #include virtual="/public/layout/include/menu_orizz.inc" -->
      </div>      
	</div>