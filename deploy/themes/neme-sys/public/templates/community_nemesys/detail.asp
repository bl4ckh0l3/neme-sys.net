<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init2.inc" -->
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%>
<link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css">
<%end if%>
</head>
<body>
<!-- inizio container -->
<div id="container">
	<!-- header -->
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<!-- header fine -->
	<!-- main -->
	<div id="main">		
		<!-- content -->	
		<div class="content">
			<!-- include virtual="/public/layout/include/Menutips.inc" -->
			<%
			if bolHasObj then%>
				<h2><%=objCurrentNews.getTitolo()%></h2>
				<%if (Len(objCurrentNews.getAbstract1()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract1()&"</cite>") end if
				if (Len(objCurrentNews.getAbstract2()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract2()&"</cite>") end if
				if (Len(objCurrentNews.getAbstract3()) > 0) then response.Write("<cite class=box_home>"&objCurrentNews.getAbstract3()&"</cite>") end if
				response.Write(objCurrentNews.getTesto())
				
				if(bolHasAttach) then 
					for each key in attachMap
						if(attachMap(key).count > 0)then%>
							<br/><br/><strong><%=lang.getTranslated(attachMultiLangKey(key))%></strong><br/>
							<%for each item in attachMap(key)%>
								<a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popup.asp?id_allegato="&item.getFileID()&"&parent_type=1"%>','popupallegati',400,400,100,100)"><%=item.getFileName()%></a><br>
							<%next
						end if
					next
				end if
				Set objCurrentNews = nothing
			else
				response.Write("<br/><br/><div align=""center""><strong>"& lang.getTranslated("portal.commons.templates.label.page_in_progress")&"</strong></div>")
			end if%>			
			
			
        <script language="JavaScript">
          /*var commentWidgetX = 0;
          var commentWidgetY = 0;

          jQuery(document).ready(function(){
             $(document).mousemove(function(e){
              commentWidgetX = e.pageX;
              commentWidgetY = e.pageY;
             }); 
          });*/

          function sendForm(){
            if(document.form_comment.message.value == ""){
              alert("<%=lang.getTranslated("frontend.popup.js.alert.insert_commento")%>");
              return;
            }else{
              document.form_comment.submit();	
            }
          }
          
          
          function sendAjaxDelComment(id_comment, id_element,id_div_comment){
            var query_string = "element_type=1&del_commento=1&id_commento="+id_comment+"&id_element="+id_element;
          
            $.ajax({
               type: "POST",
               url: "/common/include/popupInsertComments.asp",
               data: query_string,
                success: function() {
                  // update comments-widget element
                  $("#"+id_div_comment).remove();
                }
             });
           }
          </script>


<script type="text/javascript">
$(document).ready(function() {	
	//select all the a tag with name equal to modal
	$('a[name=modal]').click(function(e) {
		//Cancel the link behavior
		e.preventDefault();
		
		//Get the A tag
		var id = $(this).attr('href');
	
		//Get the screen height and width
		var maskHeight = $(document).height();
		var maskWidth = $(window).width();
	
		//Set heigth and width to mask to fill up the whole screen
		$('#mask').css({'width':maskWidth,'height':maskHeight});
		
		//transition effect		
		$('#mask').fadeIn(1000);	
		$('#mask').fadeTo("slow",0.8);	
	
		//Get the window height and width
		var winH = $(window).height();
		var winW = $(window).width();
              
		//Set the popup window to center    
    $(id).css('top', Math.max(winH/2-$(id).height()/2 + $(window).scrollTop(),0));
    $(id).css('left', Math.max(winW/2-$(id).width()/2 + $(window).scrollLeft(),0)); 
	
		//transition effect
		$(id).fadeIn(2000); 
	
	});
	
	//if close button is clicked
	$('.window .addcomment_close').click(function (e) {
		//Cancel the link behavior
		e.preventDefault();
		
		$('#mask').hide();
		$('.window').hide();
	});		
	
	//if mask is clicked
	$('#mask').click(function () {
		$(this).hide();
		$('.window').hide();
	});			
	
});

</script>

        
        


		<div class="aggiungi_commento_modeale">
          <%if (isLogged) then
            if (CInt(strRuoloLogged) = Application("admin_role")) then%>
              <a href="javascript:openWin('<%=Application("baseroot")&"/public/layout/include/popupInsertComments.asp?id_element="&id_news&"&element_type=1"%>','popupallegati',400,400,100,100);"><img alt="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" src="<%=Application("baseroot")&"/common/img/comment_add.png"%>" hspace="0" vspace="0" border="0"></a>
            <%else%>
              <a href="#addcomment" name="modal"><%=lang.getTranslated("frontend.popup.label.insert_commento")%></a>
            <%end if
            else%>
              <a href="<%=Application("baseroot")&"/login.asp?from="&Application("baseroot") & "/common/include/controller.asp?gerarchia="&request("gerarchia")&"&id_news="&id_news&"&page="&request("page")&"&modelPageNum="&request("modelPageNum")%>"><%=lang.getTranslated("frontend.popup.label.insert_commento")%></a>
          <%end if%>

				</div>
				<!-- commenti -->
				<div id="comments-widgets">
				
				
            <%if(request("vode_done")="1") then%>
            <span id="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.vote_done")%></span><br/><br/>
            <%elseif(request("vode_done")="0") then%>
            <span id="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.vote_not_done")%></span><br/><br/>
            <%elseif(request("add_done")="1") then%>
            <span id="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.add_done")%></span><br/><br/>			
            <%elseif(request("add_done")="0") then%>
            <span id="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.add_not_done")%></span><br/><br/>			
            <%end if%>
            <%if(request("posted")="1") then%>
              <span id="vote-confirmed">
                <%if(Application("use_comments_filter")=1) then%>
                  <%=lang.getTranslated("portal.templates.commons.label.comment_posted_standby")%>
                <%else%>
                  <%=lang.getTranslated("portal.templates.commons.label.comment_posted")%>
                <%end if%>
              </span><br/><br/>
            <%elseif(request("posted")="0") then%>
              <span id="vote-confirmed"><%=lang.getTranslated("portal.templates.commons.label.comment_no_posted")%></span><br/><br/>
            <%end if

            Set objCommento = New CommentsClass
            
            Dim commentsFound
            commentsFound = false
            
            on error Resume Next
            
            if not(id_news="") AND objCommento.findCommentiByIDElement(id_news,1,1).Count > 0 then
              commentsFound = true
            end if
            
            if Err.number <> 0 then
              'response.write(Err.description)
              commentsFound = false
            end if	
            
            if (commentsFound) then
          		Dim  kk, objTmpCommento, objUserClass, usrHasImgComment, commentCounter		
              Set objSelectedCommento = objCommento.findCommentiByIDElement(id_news,1,1)
              Set objUserClass = new UserClass
              
          		commentCounter = 0
              for each kk in objSelectedCommento.Keys
                Set objTmpCommento = objSelectedCommento(kk)
                Set objUserComment = objUserClass.findUserByID(objTmpCommento.getIDUtente())
                usrHasImgComment = objUserClass.hasImageUser(objTmpCommento.getIDUtente())%>
            		<div class="commento" id="comment_<%=commentCounter%>">
                
                  <div class="commento-testo">
                    <script>
                      $(function() {
                        $(".imgAvatarUser").aeImageResize({height: 50, width: 50});
                      });
                    </script>
                    <%if (usrHasImgComment) then%>
                    <img class="imgAvatarUser" src="<%=Application("baseroot") & "/public/layout/addson/user/userImage.asp?userID="&objUserComment.getUserID()%>"/>
                    <%else%>
                    <img class="imgAvatarUser" src="<%=Application("baseroot") & "/common/img/unkow-user.jpg"%>"/>
                    <%end if%>
                    
                  	<span class="commento-nome"><%=objUserComment.getUsername()%></span>
                    
                    <%if (isLogged) then
                      if (CInt(strRuoloLogged) = Application("admin_role")) then%>
                      &nbsp;&nbsp;&nbsp;<a href="javascript:sendAjaxDelComment(<%=objTmpCommento.getIDCommento()%>,<%=id_news%>,'comment_<%=commentCounter%>');">x</a>
                    <%end if
                    end if%>
	                    
                    <span class="commento-data"><%=objTmpCommento.getDtaInserimento()%></span> 
                      
                    <div class="commento-testo-body">                    
                      <!--<%'if(objTmpCommento.getVoteType()=1)then%><img id="nolike" src="<%'=Application("baseroot") & "/common/img/like.png"%>" align="absbottom"/><%'else%><img id="nolike" src="<%'=Application("baseroot") & "/common/img/nolike.png"%>" align="absbottom"/><%'end if%>&nbsp;--><%=objTmpCommento.getMessage()%>
                    </div>
                  </div>
            	</div>
                
                <%Set objUserComment = nothing
              commentCounter = commentCounter+1
              next
              
              Set objUserClass = nothing
            else
              response.Write("<br/><div align='center'>"&lang.getTranslated("frontend.popup.label.no_comments_news")&"</div><br>")
            end if				
            Set objCommento = Nothing
            %>					
				</div>
				 
				<div id="box-comment">
					<div id="addcomment" class="window">
						<div class="addcomment_header">
							<span><%=lang.getTranslated("frontend.popup.label.insert_commento")%></span>
							<a href="#"class="addcomment_close" >X</a>
						</div>
		
            <form action="<%=Application("baseroot") & "/area_user/processusercomment.asp?gerarchia="&request("gerarchia")&"&id_news="&id_news&"&page="&request("page")&"&modelPageNum="&request("modelPageNum")%>" method="post" name="form_comment">
            <input type="hidden" name="id_element" value="<%=id_news%>">
            <input type="hidden" name="element_type" value="1">
            <input type="hidden" name="active" value="<%if(Application("use_comments_filter")=1) then response.write("0") else response.write("1") end if%>">
            <textarea onclick="$('#message').focus();" id="message" name="message" class="addcomment_message"></textarea>
                          
            <div class="addcomment_footer">
              <input type="hidden" name="comment_type" value="0">                
            <!--<span><%'=lang.getTranslated("frontend.area_user.manage.label.like")%></span>
            <select name="comment_type" size="1" id="comment_type">
                <OPTION VALUE="1" <%'if (strComp("1", bolPublic, 1) = 0) then response.Write("selected")%>><%'=lang.getTranslated("portal.commons.yes")%></OPTION>
                <OPTION VALUE="0" <%'if (strComp("0", bolPublic, 1) = 0) then response.Write("selected")%>><%'=lang.getTranslated("portal.commons.no")%></OPTION>
            </select>-->	
            <input class="addcomment_form_btn" type="button" onclick="javascript:sendForm();" value="<%=lang.getTranslated("frontend.popup.label.insert_commento")%>" name="send">
          </div>
          </form>
					</div>
					<!-- Mask to cover the whole screen -->
  					<div id="mask"></div>
				</div>
            
          <form action="<%=Application("baseroot") & "/common/include/Controller.asp"%>" method="get" name="form_reload_page">
          <input type="hidden" name="gerarchia" value="<%=request("gerarchia")%>">
          <input type="hidden" name="id_news" value="<%=id_news%>">
          <input type="hidden" name="page" value="<%=request("page")%>">
          <input type="hidden" name="modelPageNum" value="<%=request("modelPageNum")%>">
          </form>           
				<!-- commenti fine -->    
		</div>
		<!-- content fine -->		
	</div>
	<!-- main fine -->	
</div>
<!-- fine container -->
<!-- #include virtual="/public/layout/include/bottom.inc" -->
</body>
</html>
<%
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>