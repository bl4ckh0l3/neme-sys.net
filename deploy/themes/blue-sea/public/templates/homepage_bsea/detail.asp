﻿<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include file="include/init2.inc" -->
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
<%if not(isNull(strCSS)) ANd not(strCSS = "") then%><link rel="stylesheet" href="<%=Application("baseroot") & strCSS%>" type="text/css"><%end if%>
</head>
<body>
<div id="warp">
	<!-- #include virtual="/public/layout/include/header.inc" -->	
	<div id="container">	
		<!-- #include virtual="/public/layout/include/menu_orizz.inc" -->
		<!-- #include virtual="/public/layout/include/menu_vert_sx.inc" -->
		<div id="content-center">
			<!-- include virtual="/public/layout/include/menutips.inc" -->
			<div align="left">
			<%if (bolHasObj) then%>
				<p><strong><%=objCurrentNews.getTitolo()%></strong></p>
				<%
				if (Len(objCurrentNews.getAbstract1()) > 0) then response.Write(objCurrentNews.getAbstract1()) end if
				if (Len(objCurrentNews.getAbstract2()) > 0) then response.Write(objCurrentNews.getAbstract2()) end if
				if (Len(objCurrentNews.getAbstract3()) > 0) then response.Write(objCurrentNews.getAbstract3()) end if
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
				%>
		<!-- include virtual="/public/layout/addson/contents/news_comments_widget.inc" -->
			<%else%>
				<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
			<%end if%>
			</div>
		</div>
		<!-- include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set objListaTargetCat = nothing
Set objListaTargetLang = nothing
Set objListaNews = nothing
Set News = Nothing
%>