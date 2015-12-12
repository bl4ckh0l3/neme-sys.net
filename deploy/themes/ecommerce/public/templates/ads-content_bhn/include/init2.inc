<%
Dim id_news, News, objCurrentNews, strGerarchia, strCSS, objFileXNews, objListaFilePerNews, objAds, objCurrAds
Dim totPages, numPage

Dim stato
stato = 1
if(request("is_preview_content")) then
	stato = null
end if

Set News = New NewsClass
Set objAds = New AdsClass
id_news = request("id_news")
strGerarchia = request("gerarchia")
numPage = 1

if not(isNull(request("page"))) AND not(request("page") = "") then
	numPage = request("page")
end if%>
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<%
Dim bolHasObj, bolHasAttach
bolHasObj = false
bolHasAttach = false
bolHasAds = false

on error Resume Next
if(id_news <> "")then
			Set objCurrentNews = News.findNewsByIDCached(id_news)
      bolHasObj = true      
end if    
if Err.number <> 0 then
  bolHasObj = false
end if	

on error Resume Next
if(bolHasObj)then
			Set objCurrAds = objAds.findAdByElement(null, id_news)
      bolHasAds = true      
end if    
if Err.number <> 0 then
  bolHasAds = false
end if	
  
if (Instr(1, typename(objCurrentNews), "NewsClass", 1) > 0) then
  id_news= objCurrentNews.getNewsID()

  if not(lang.getTranslated(objCurrentNews.getMetaDescription()) = "") then
    metaDescription = metaDescription & " " & lang.getTranslated(objCurrentNews.getMetaDescription())
  else
    metaDescription = metaDescription & " " & objCurrentNews.getMetaDescription()
  end if

  if not(lang.getTranslated(objCurrentNews.getMetaKeyword()) = "") then
    metaKeyword = metaKeyword & " " & lang.getTranslated(objCurrentNews.getMetaKeyword())
  else
    metaKeyword = metaKeyword & " " & objCurrentNews.getMetaKeyword()
  end if

  if not(lang.getTranslated(objCurrentNews.getPageTitle()) = "") then
    pageTemplateTitle = lang.getTranslated(objCurrentNews.getPageTitle())
  else
    if not(objCurrentNews.getPageTitle() = "")then
      pageTemplateTitle = objCurrentNews.getPageTitle()
    end if
  end if 


  if not(isNull(objCurrentNews.getFilePerNews())) AND not(isEmpty(objCurrentNews.getFilePerNews())) then
			Set objListaFilePerNews = objCurrentNews.getFilePerNews()
			
			if not(isEmpty(objListaFilePerNews)) then
				' LEGENDA TIPI FILE      
        '1 = img small
        '2 = img big
        '3 = pdf
        '4 = audio-video
        '5 = others...
        '6 = img medium
        '7 = img carrello   
      
				' Lista label tipi file
				Dim hasSmallImg, hasMediumImg, hasBigImg, hasCardImg, hasPdf, hasAudioVideo, hasOthers
				hasSmallImg = false
				hasBigImg = false
				hasPdf = false
				hasAudioVideo = false
				hasOthers = false
				hasMediumImg = false
				hasCardImg = false
        
        bolHasAttach = true
      
        Set attachMap = Server.CreateObject("Scripting.Dictionary")
        Set attachMultiLangKey = Server.CreateObject("Scripting.Dictionary")
        Set attachSmall = Server.CreateObject("Scripting.Dictionary")
        Set attachBig = Server.CreateObject("Scripting.Dictionary")
        Set attachPdf = Server.CreateObject("Scripting.Dictionary")
        Set attachAudioVideo = Server.CreateObject("Scripting.Dictionary")
        Set attachOther = Server.CreateObject("Scripting.Dictionary")
        Set attachMedium = Server.CreateObject("Scripting.Dictionary")
        Set attachCard = Server.CreateObject("Scripting.Dictionary")
				
				for each xObjFile in objListaFilePerNews
					Set objFileXNews = objListaFilePerNews(xObjFile)					
					
					select case objFileXNews.getFileTypeLabel()
					case 1
						hasSmallImg = true
            attachSmall.add objFileXNews, ""
					case 2
						hasBigImg = true
            attachBig.add objFileXNews, ""	
					case 3
						hasPdf = true
            attachPdf.add objFileXNews, ""
					case 4
						hasAudioVideo = true
            attachAudioVideo.add objFileXNews, ""
					case 5
						hasOthers = true
            attachOther.add objFileXNews, ""
					case 6
						hasMediumImg = true
            attachMedium.add objFileXNews, ""
					case 7						
            hasCardImg = true
            attachCard.add objFileXNews, ""
					case else
					end select
					Set objFileXNews = nothing	
				next
          
        attachMap.add "small", attachSmall
        attachMap.add "big", attachBig
        attachMap.add "pdf", attachPdf
        attachMap.add "media", attachAudioVideo
        attachMap.add "other", attachOther
        attachMap.add "medium", attachMedium
        attachMap.add "card", attachCard
          
        attachMultiLangKey.add "small", "frontend.file_allegati.label.key_img_small"
        attachMultiLangKey.add "big", "frontend.file_allegati.label.key_img_big"
        attachMultiLangKey.add "pdf", "frontend.file_allegati.label.key_pdf"
        attachMultiLangKey.add "media", "frontend.file_allegati.label.key_audio_video"
        attachMultiLangKey.add "other", "frontend.file_allegati.label.key_others_doc"
        attachMultiLangKey.add "medium", "frontend.file_allegati.label.key_img_medium"
        attachMultiLangKey.add "card", "frontend.file_allegati.label.key_img_card"

        
			end if
			Set objListaFilePerNews = nothing
    end if 
    
  '*************** verifico se esiste la geolocalizzazione per questo elemento
  Dim objLocaliz, objPoint, latitude, longitude
  Set objLocaliz = new LocalizationClass  
  Set objListPoint = Server.CreateObject("Scripting.Dictionary")    
  on error Resume Next  
  Set points = objLocaliz.findPointByElement(id_news, 1)
  if (Instr(1, typename(points), "Dictionary", 1) > 0) then
    for each xLocal in points.Items
      objListPoint.add xLocal, xLocal.getInfo()
    next
  end if
  Set points = nothing  
  if Err.number <> 0 then
    'response.write(Err.description&"<br>")
  end if  
  Set objLocaliz = nothing
  
end if

metaDescription = Trim(metaDescription)
metaKeyword = Trim(metaKeyword)
pageTemplateTitle = Trim(pageTemplateTitle)

if (pageTemplateTitle = "") then
  pageTemplateTitle = lang.getTranslated("frontend.page.title")
end if  

Response.Charset="UTF-8"
Session.CodePage  = 65001
%>