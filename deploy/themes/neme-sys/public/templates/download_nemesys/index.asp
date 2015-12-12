<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init1.inc" -->
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
<script type="text/javascript">
$(document).ready(function(){
  $(".fix_notes_down").hide();
  $(".fix_notes_notes").hide();
});  
  
function showDownload(elem){
	//$(".fix_notes_download").click(function(event) {
		$(elem).slideToggle('hide');
		 event.preventDefault();

		return false;
	
	//});
}

function showNote(elem){
	//$(".fix_notes_vedi").click(function(event) {
		$(elem).slideToggle('hide');
		 event.preventDefault();

		return false;
	
	//});
}  
</script>
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
			'************** codice per la lista news e paginazione
			if(bolHasObj) then%>
				<br/>			
				<%		
				for newsCounter = FromNews to ToNews
					Set objSelNews = objTmpNews(newsCounter)%>
					<div class="fix_notes">
            
						<div class="fix_notes_ico">
							<span><%=objSelNews.getAbstract1()%></span>
							<small><%=lang.getTranslated("frontend.template.download.label.version")%></small>
						</div>
						<div class="fix_notes_txt">
							<h2><span><%=FormatDateTime(objSelNews.getDataPubNews(),2)%></span>&nbsp;<%=objSelNews.getTitolo()%></h2>
							
							<a href="#" class="fix_notes_download" onclick="showDownload('#fix_notes_down<%=newsCounter%>');"><%=lang.getTranslated("frontend.template.download.label.down_version")%></a>
                
							<a href="#" class="fix_notes_vedi" onclick="showNote('#fix_notes_notes<%=newsCounter%>');"><%=lang.getTranslated("frontend.template.download.label.fix_notes")%></a>

							<div class="fix_notes_down" id="fix_notes_down<%=newsCounter%>">
               
							<%if not(isNull(objSelNews.getFilePerNews())) AND not(isEmpty(objSelNews.getFilePerNews())) then
							  Set objListaFilePerNews = objSelNews.getFilePerNews()
							  
							  if not(isEmpty(objListaFilePerNews)) then
							    ' LEGENDA TIPI FILE
							    '1 = img small
							    '2 = img big
							    '3 = pdf
							    '4 = audio-video
							    '5 = others%>				
							    <%
							    ' Lista label tipi file
							    Dim hasBigImg, hasPdf, hasAudioVideo, hasOthers
							    hasBigImg = false
							    hasPdf = false
							    hasAudioVideo = false
							    hasOthers = false
							    
							    for each xObjFile in objListaFilePerNews
							      Set objFileXNews = objListaFilePerNews(xObjFile)					
							      
							      select case objFileXNews.getFileTypeLabel()
							      case 3
								hasPdf = true
							      case 5
								hasOthers = true
							      case else
							      end select
							      Set objFileXNews = nothing	
							    next
							    
							    if (cbool(hasPdf)) then response.write("<strong>"&lang.getTranslated("frontend.file_allegati.label.key_pdf")&"</strong><br/>") end if
							    ' Lista pdf
							    for each xObjFile in objListaFilePerNews
							      Set objFileXNews = objListaFilePerNews(xObjFile)					
							      if(objFileXNews.getFileTypeLabel() = 3) then%>
								<p><a class="pdfAttachLink" href="javascript:openWin('<%=Application("baseroot")&Application("dir_upload_templ")&"download/popup_download.asp?id_allegato="&objFileXNews.getFileID()%>','popupallegati',400,400,100,100)"><%=objFileXNews.getFileName()%></a></p>				
								<%objListaFilePerNews.remove(xObjFile)
							      end if
							      Set objFileXNews = nothing	
							    next
							    
							    if (cbool(hasOthers)) then response.write("<br/><strong>"&lang.getTranslated("frontend.file_allegati.label.key_applications")&"</strong><br/>") end if
							    ' Lista others documents
							    for each xObjFile in objListaFilePerNews
							      Set objFileXNews = objListaFilePerNews(xObjFile)					
							      if(objFileXNews.getFileTypeLabel() = 5) then%>
								<p><a href="javascript:openWin('<%=Application("baseroot")&Application("dir_upload_templ")&"download/popup_download.asp?id_allegato="&objFileXNews.getFileID()&"&force=1"%>','popupallegati',400,400,100,100)"><%=objFileXNews.getFileName()%></a></p>					
								<%objListaFilePerNews.remove(xObjFile)
							      end if
							      Set objFileXNews = nothing	
							    next				
							  end if
							  Set objListaFilePerNews = nothing
							end if%>							
						      </div>                  

                
								
							<div class="fix_notes_notes" id="fix_notes_notes<%=newsCounter%>">
								<p><%=objSelNews.getAbstract2()%></p>
							</div>
						</div>  
						</div>  
					<%Set objSelNews = nothing
				next%>
				<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "") end if%></div>
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
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
