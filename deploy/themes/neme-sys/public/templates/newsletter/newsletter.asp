<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<%
Dim id_news, News, objCurrentNews
Set News = New NewsClass
id_news = request("id_news")%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<META name="autore" CONTENT="Neme-sys; email:info@neme-sys.org">
<META http-equiv="Content-Type" CONTENT="text/html; charset=utf-8">
<link rel="stylesheet" href="<%="http://" & request.ServerVariables("SERVER_NAME") & Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
</head>
<body>
<div id="container">	
	<!-- main -->
	<div id="main">		
		<!-- content -->	
		<div class="content">
		<%
		Set objCurrentNews = News.findNewsByID(id_news)
		if (Instr(1, typename(objCurrentNews), "NewsClass", 1) > 0) then%>
			<div>
			<p><strong><%=objCurrentNews.getTitolo()%></strong></p>
			<%
			if (Len(objCurrentNews.getAbstract1()) > 0) then response.Write(objCurrentNews.getAbstract1()) end if
			if (Len(objCurrentNews.getAbstract2()) > 0) then response.Write(objCurrentNews.getAbstract2()) end if
			if (Len(objCurrentNews.getAbstract3()) > 0) then response.Write(objCurrentNews.getAbstract3()) end if
			response.Write(objCurrentNews.getTesto())
			Set objCurrentNews = nothing				
			%>
			</div>
		<%else%>
			<br/><br/><div align="center"><strong><%=lang.getTranslated("portal.commons.templates.label.page_in_progress")%></strong></div>
		<%end if%>
		</div>
		<!-- content fine -->		
	</div>
	<!-- main fine -->	
</div>
</body>
</html>
<%
'****************************** PULIZIA DEGLI OGGETTI UTILIZZATI
Set News = Nothing
%>
