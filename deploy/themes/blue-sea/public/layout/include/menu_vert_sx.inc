<div id="menu-left">
      <!-- #include virtual="/public/layout/addson/user/user_mask_widget.inc" -->
			<div id="clear"></div>
						
			<%if isEmpty(Session("objUtenteLogged")) then%>
				<div class="menu-left-new-user">	
				<h2><a href="<%=base_url&Application("srt_default_server_name")&Application("baseroot")&"/area_user/manageUser.asp"%>"><%=lang.getTranslated("frontend.menu.label.not_registered_user")%></a></h2>
				<p><%=lang.getTranslated("frontend.header.label.subscribe")%></p>
				</div>
			<%end if%>
			<div id="clear"></div>
			<img src="<%=Application("baseroot") & "/common/img/loano_menu_sx.jpg"%>" border="0" align="left" />
			<div id="clear"></div>
			<!-- #include virtual="/public/layout/addson/user/user_online_widget.inc" -->
</div>