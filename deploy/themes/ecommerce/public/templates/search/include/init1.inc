<%
Dim Search, objListaAll
Dim strGerarchia, strCSS
Dim totPages, numPage

numPage = 1

if not(isNull(request("page"))) AND not(request("page") = "") then
	numPage = request("page")
end if

if(isNull(strGerarchia) OR strGerarchia = "") then strGerarchia = "01"

Set Search = New SearchClass

Dim search_txt, search_txt_tmp
search_txt = request("search_full_txt")
search_txt_tmp = request("search_full_txt") 
%>
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<%
Dim bolHasObj, objCat, objPageTempl
bolHasObj = false

Set objCat = new CategoryClass
Set objPageTempl = new Page4TemplateClass

on error Resume Next
if not(isNull(objListaTargetCat)) then
  Set objListaAll = Search.searchAll(search_txt_tmp, objListaTargetLang, false)
  
  if(objListaAll.Count > 0) then		
    bolHasObj = true
  
    'devo cablare il numero di elementi per pagina perche' la ricerca non ha una categoria definita ma va direttamente sul template
    elem_x_page = 20
  
    for each t in objListaAll
      if not(lang.getTranslated(objListaAll(t).getMetaDescription()) = "") then
        metaDescription = metaDescription & " " & lang.getTranslated(objListaAll(t).getMetaDescription())
      else
        if not(objListaAll(t).getMetaDescription()="")then
          metaDescription = metaDescription & " " & objListaAll(t).getMetaDescription()
        end if
      end if
      
      if not(lang.getTranslated(objListaAll(t).getMetaKeyword()) = "") then
        metaKeyword = metaKeyword & " " & lang.getTranslated(objListaAll(t).getMetaKeyword())
      else
        if not(objListaAll(t).getMetaKeyword()="")then
          metaKeyword = metaKeyword & " " & objListaAll(t).getMetaKeyword()
        end if
      end if
      
      'if not(lang.getTranslated(objListaAll(t).getPageTitle()) = "") then
      ' pageTemplateTitle = pageTemplateTitle & " " & lang.getTranslated(objListaAll(t).getPageTitle())
      'else
      '  if not(objListaAll(t).getPageTitle()="")then
      '    pageTemplateTitle = pageTemplateTitle & " " & objListaAll(t).getPageTitle()
      '  end if
      'end if       
    next

    metaDescription = Trim(metaDescription)
    metaKeyword = Trim(metaKeyword)
    'pageTemplateTitle = Trim(pageTemplateTitle)  
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
