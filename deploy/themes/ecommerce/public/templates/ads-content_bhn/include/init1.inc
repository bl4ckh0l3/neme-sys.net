<%
Dim News, objListaNews, objListaTargetCat, objListaTargetLang
Dim strGerarchia, totPages, numPage, stato

Set News = New NewsClass
Set objAds = New AdsClass
Set objU = new UserClass
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
bolHasAds = false

Dim objLocaliz, objPoint
Set objLocaliz = New LocalizationClass
Set objListPoint = Server.CreateObject("Scripting.Dictionary")

on error Resume Next
Set objListaNews = Server.CreateObject("Scripting.Dictionary")
Set objListAdsFind = Server.CreateObject("Scripting.Dictionary")

search_ads_type = request("ads_type")
search_price_from = request("price_from")
search_price_to = request("price_to")
search_dta_ins_from = request("dta_ins_from")
search_dta_ins_to = request("dta_ins_to")
search_title = request("ads_title")

Set objListAds = objAds.findAds(null, null, search_ads_type, search_price_from, search_price_to, search_dta_ins_from, search_dta_ins_to, search_title, objListaTargetCat, objListaTargetLang)
objTmpAds = objListAds.Items 

Dim objSelNews, newsCounter, iIndex, objTmpNews, FromNews, ToNews, Diff
iIndex = objListAds.Count
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

for adsCounter = FromNews to ToNews
  Set objTmpNews = News.findNewsByIDCached(objTmpAds(adsCounter).getIDElement())
  objListaNews.add objTmpAds(adsCounter).getIDElement(), objTmpNews
  objListAdsFind.add objTmpAds(adsCounter).getIDElement(), objTmpAds(adsCounter)
  Set objTmpNews = nothing    
next
Set objListAds = nothing

if(objListAdsFind.Count > 0) then		
  bolHasAds = true  
end if  
if(objListaNews.Count > 0) then		
  bolHasObj = true  
end if
if Err.number <> 0 then
  bolHasObj = false
  bolHasAds = false
end if

if(bolHasObj) then	
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
      
  objTmpNews = objListaNews.Items     
end if

if (pageTemplateTitle = "") then
  pageTemplateTitle = lang.getTranslated("frontend.page.title")
end if  

Response.Charset="UTF-8"
Session.CodePage  = 65001

'*************** verifico se esiste la geolocalizzazione per questo elemento      
on error Resume Next
'response.write("objListaNews.Count: "&objListaNews.Count&"<br>")
if(bolHasObj) then	
  'response.write("objLocaliz: "&typename(objLocaliz)&"<br>")  
  for each t in objListaNews
    Set points = objLocaliz.findPointByElement(objListaNews(t).getNewsID(), 1)
    if (Instr(1, typename(points), "Dictionary", 1) > 0) then
      for each xLocal in points.Items
        objListPoint.add xLocal, xLocal.getInfo()
      next
    end if
    Set points = nothing       
  next
end if
if Err.number <> 0 then
  'response.write(Err.description&"<br>")
end if  
Set objLocaliz = nothing 


Set objCat = new CategoryClass
Set objPageTempl = new Page4TemplateClass
Set objTemplate = new TemplateClass
Set objMenuFruizione = new MenuClass
bolHasDetailLink = false
On Error Resume Next							         
Set objCategoriaTmp = objCat.findExsitingCategoriaByGerarchia(strGerarchia)
if not(isNull(objCategoriaTmp)) then
  Set objTemplateSelected = objTemplate.findTemplateByID(objCategoriaTmp.findLangTemplateXCategoria(lang.getLangCode(),true))
  bolHasDetailLink = true
else
  bolHasDetailLink = false                  
end if
if(Err.number <>0) then
  bolHasDetailLink = false
end if 
%>