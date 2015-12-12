<%
Dim News, objListaNews, objListaTargetCat, objListaTargetLang
Dim strGerarchia, totPages, numPage, stato

Set News = New NewsClass
strGerarchia = request("gerarchia")
numPage = 1
stato = 1

if not(isNull(request("page"))) AND not(request("page") = "") then
	numPage = request("page")
end if

if(request("is_preview_content")) then
	stato = null
end if
%>
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<%
Dim bolHasObj
bolHasObj = false

on error Resume Next
if(bolCatContainNews) AND not(isNull(objListaTargetCat)) then
  Set objListaNews = News.findNewsSlimCached(null, null, null, null, objListaTargetCat, objListaTargetLang, null, null, stato, order_by,false,false)	
  
  if(objListaNews.Count > 0) then		
    bolHasObj = true
  
    for each t in objListaNews
      if not(lang.getTranslated(objListaNews(t).getMetaDescription()) = "") then
        metaDescription = metaDescription & " " & lang.getTranslated(objListaNews(t).getMetaDescription())
      else
        if not(objListaNews(t).getMetaDescription()="")then
          metaDescription = metaDescription & " " & objListaNews(t).getMetaDescription()
        end if
      end if
      
      if not(lang.getTranslated(objListaNews(t).getMetaKeyword()) = "") then
        metaKeyword = metaKeyword & " " & lang.getTranslated(objListaNews(t).getMetaKeyword())
      else
        if not(objListaNews(t).getMetaKeyword()="")then
          metaKeyword = metaKeyword & " " & objListaNews(t).getMetaKeyword()
        end if
      end if
      
      'if not(lang.getTranslated(objListaNews(t).getPageTitle()) = "") then
      ' pageTemplateTitle = pageTemplateTitle & " " & lang.getTranslated(objListaNews(t).getPageTitle())
      'else
      '  if not(objListaNews(t).getPageTitle()="")then
      '    pageTemplateTitle = pageTemplateTitle & " " & objListaNews(t).getPageTitle()
      '  end if
      'end if       
    next

    metaDescription = Trim(metaDescription)
    metaKeyword = Trim(metaKeyword)
    'pageTemplateTitle = Trim(pageTemplateTitle)  
      
    Dim objSelNews, newsCounter, iIndex, objTmpNews, FromNews, ToNews, Diff
    iIndex = objListaNews.Count
    FromNews = ((numPage * elem_x_page) - elem_x_page)
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
  end if
end if
  
if Err.number <> 0 then
  bolHasObj = false
end if

if (pageTemplateTitle = "") then
  pageTemplateTitle = lang.getTranslated("frontend.page.title")
end if  

Response.Charset="UTF-8"
Session.CodePage  = 65001
%>