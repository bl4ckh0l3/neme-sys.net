<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Paginazione.inc" -->
<!-- #include virtual="/common/include/Objects/SearchClass.asp" -->
<!-- #include file="include/init2.inc" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=pageTemplateTitle%></title>
<META name="description" CONTENT="<%=metaDescription%>">
<META name="keywords" CONTENT="<%=metaKeyword%>">
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
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
			
			<%
			'************** codice per la lista news e paginazione
			if bolHasObj then%>
				<div id="search">
					<%Dim objSelNews, newsCounter, iIndex, objTmpNews, objTmpKeyNews, FromNews, ToNews, Diff, numPageTempl
					Dim splittedGerarchia
					iIndex = objListaNews.Count%>
					<p>				
					<%=lang.getTranslated("frontend.search.table.label.key_find") & " <strong>" & iIndex &"</strong> " &lang.getTranslated("frontend.search.table.label.key_result_for") & " ""<strong>" & search_txt & "</strong>""<br><br><br>"%>
					</p>
					<%FromNews = ((numPage * elem_x_page) - elem_x_page)
					Diff = (iIndex - ((numPage * elem_x_page)-1))
					if(Diff < 1) then
						Diff = 1
					end if
					
					ToNews = iIndex - Diff
					
					totPages = iIndex\elem_x_page
					if(totPages < 1) then
						totPages = 1
					elseif((iIndex MOD elem_x_page <> 0) AND not ((totPages * elem_x_page) >= iIndex)) then
	
						totPages = totPages +1	
					end if
							
					objTmpNews = objListaNews.Items
					objTmpKeyNews = objListaNews.Keys
					for newsCounter = FromNews to ToNews
						'per recuperare la gerarchia e page_num corretti devo eliminare la parte iniziale con l'id dell news
						'la gerarchia arriva nella forma idnews|gerarchia-page_num
						'basta fare una substring che elimini la prima parte 
						splittedInfo = objTmpKeyNews(newsCounter)
						splittedGerarchia = Right(splittedInfo,(Len(splittedInfo)-inStr(splittedInfo,"|")))
						splittedGerarchia = Left(splittedGerarchia,inStr(splittedGerarchia,"-")-1)        
						'recupero la pagina piu alta in base al template
						numPageTempl = Right(splittedInfo,(Len(splittedInfo)-inStr(splittedInfo,"-")))
						
						Set objSelNews = objTmpNews(newsCounter)%>
						<div>	
							<p><strong><a class="title-ricerca" href="<%=Application("baseroot") & "/common/include/Controller.asp?gerarchia="&splittedGerarchia&"&id_news="&objSelNews.getNewsID()&"&page=1&modelPageNum="&numPageTempl%>"><%=objSelNews.getTitolo()%></a></strong><br>
							<%if not(objSelNews.getAbstract1() = "") then response.write(objSelNews.getAbstract1()) end if%>
							</p><p class="line"></p>
						</div>
						<%Set objSelNews = nothing
					next%>
					<div><%if(totPages > 1) then call PaginazioneFrontend(totPages, numPage, strGerarchia, request.ServerVariables("URL"), "search_full_txt="&search_txt) end if%></div>
				</div>
			<%else%>
				<div align="center"><br/><%=lang.getTranslated("frontend.search.table.label.no_result_found")%></div>
			<%end if
		
		Set objPageTempl = nothing
		Set objCat = nothing
		%>
		</div>
		<!-- include virtual="/public/layout/include/menu_vert_dx.inc" -->
	</div>
	<!-- #include virtual="/public/layout/include/bottom.inc" -->
</div>
</body>
</html>
<%
Set objListaNews = nothing
Set Search = nothing
%>