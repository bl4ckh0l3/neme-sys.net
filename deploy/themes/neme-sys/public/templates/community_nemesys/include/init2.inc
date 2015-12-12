<%
Dim id_news, News, objCurrentNews, strGerarchia, strCSS, objFileXNews, objListaFilePerNews
Dim objListaNews, objListaTargetCat, objListaTargetLang
Dim totPages, numPage

Dim stato
stato = 1
if(request("is_preview_content")) then
	stato = null
end if

Set News = New NewsClass
id_news = request("id_news")
strGerarchia = request("gerarchia")
numPage = 1

if not(isNull(request("page"))) AND not(request("page") = "") then
	numPage = request("page")
end if%>
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<%
Set objUserLogged = new UserClass
if not(isEmpty(Session("objUtenteLogged"))) AND not(Session("objUtenteLogged") = "") then
  Set objUserLoggedTmp = objUserLogged.findUserByID(Session("objUtenteLogged"))
  if not(isNull(objUserLoggedTmp)) AND (Instr(1, typename(objUserLoggedTmp), "UserClass", 1) > 0) then 
    strRuoloLogged = objUserLoggedTmp.getRuolo()  
    numIdUser = objUserLoggedTmp.getUserID()
  end if
  Set objUserLoggedTmp = nothing
  isLogged = true
elseif not(isEmpty(Session("objCMSUtenteLogged"))) AND not(Session("objCMSUtenteLogged") = "") then
  Set objCMSUtenteLoggedTmp = objUserLogged.findUserByID(Session("objCMSUtenteLogged"))
  if not(isNull(objCMSUtenteLoggedTmp)) AND (Instr(1, typename(objCMSUtenteLoggedTmp), "UserClass", 1) > 0) then 
    strRuoloLogged = objCMSUtenteLoggedTmp.getRuolo()
    numIdUser = objCMSUtenteLoggedTmp.getUserID() 
  end if
  Set objCMSUtenteLoggedTmp = nothing
  isLogged = true
end if
Set objUserLogged = nothing	

Dim bolHasObj, bolHasAttach
bolHasObj = false
bolHasAttach = false

on error Resume Next
if(id_news <> "")then
			Set objCurrentNews = News.findNewsByIDCached(id_news)
      bolHasObj = true  
elseif(id_news = "" AND bolCatContainNews AND not(isNull(objListaTargetCat))) then
  Set objListaNews = News.findNewsSlimCached(null, null, null, null, objListaTargetCat, objListaTargetLang, null, null, stato, order_by,false,true)	
  
  if(objListaNews.Count > 0) then
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

    arrTmpListNews = objListaNews.Items
    Set objCurrentNews = arrTmpListNews(FromNews)    
  
    bolHasObj = true
  end if
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
end if

metaDescription = Trim(metaDescription)
metaKeyword = Trim(metaKeyword)
pageTemplateTitle = Trim(pageTemplateTitle)

if (pageTemplateTitle = "") then
  pageTemplateTitle = lang.getTranslated("frontend.page.title")
end if      
    
if Err.number <> 0 then
  'response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
  bolHasObj = false
end if	

Response.Charset="UTF-8"
Session.CodePage  = 65001
%>