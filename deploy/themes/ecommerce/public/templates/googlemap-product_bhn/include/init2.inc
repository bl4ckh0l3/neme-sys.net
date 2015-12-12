<%
Dim id_prodotto, Prodotto, objCurrentProdotto, strGerarchia, strCSS, objFileXProdotto, objListaFilePerProdotto, objSelMargin

Set Prodotto = New ProductsClass
id_prodotto = request("id_prodotto")
strGerarchia = request("gerarchia")

if not(isNull(request("page"))) AND not(request("page") = "") then
	numPage = request("page")
end if

Set objCommento = New CommentsClass

'**************** IMPOSTO LE CLASSI PER LA VALUTA
Dim currClass, defCurrObj, thisCurrObj
Set currClass = new CurrencyClass
On Error Resume Next
defCurrObj = currClass.getDefaultCurrency().getCurrency()
if(Err.number <> 0) then
	defCurrObj = ""
end if

if(request("currency") <> "") then
	Session("currency") = request("currency")
	thisCurrObj = Session("currency")
elseif(Session("currency") <> "") then
	thisCurrObj = Session("currency")
else
	thisCurrObj = defCurrObj
	Session("currency") = thisCurrObj
end if

Set objProdField = new ProductFieldClass
Set objProdFieldGroup = new ProductFieldGroupClass

hasSconto=false
hasGroup = false
scontoCliente = 0
groupCliente = ""
groupDesc = ""
groupClienteTax = null	
objSelMargin = null	

Dim bolHasAttach
bolHasAttach = false

'********** GESTIONE INTERNAZIONALIZZAZIONE TASSE
Dim international_country_code, international_state_region_code, userIsCompanyClient
international_country_code = ""
international_state_region_code = ""
userIsCompanyClient = 0
groupClienteTax = null

if not(isEmpty(Session("objUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing

	id_user = objUserLogged.getUserID()

  groupCliente = objUserLogged.getGroup()
  if(not(groupCliente= "")) then
    On Error Resume Next
    Dim objGroup
    Set objGroup = New UserGroupClass
    Set objTmpGr = objGroup.findUserGroupByID(groupCliente)
    groupDesc = objTmpGr.getShortDesc()
    if (not(isNull(objTmpGr.getTaxGroup()))) then
      Set groupClienteTax = objTmpGr.getTaxGroupObj(objTmpGr.getTaxGroup())
    end if
    hasGroup = true
    Set objTmpGr = nothing
		Set objSelMargin = objGroup.getMarginDiscountXUserGroup(groupCliente)
    Set objGroup = nothing
    if(Err.number <> 0) then
      hasGroup = false
    end if
  end if

	scontoCliente= objUserLogged.getSconto()
	
	if(scontoCliente <> "" AND Cdbl(scontoCliente) > 0) then
		hasSconto = true
	end if
  
	Set objUserLogged = nothing


  On Error Resume Next
  Set objShip = new ShippingAddressClass
  Set orderShip = objShip.findShippingAddressByUserID(id_user)

  if (Instr(1, typename(orderShip), "ShippingAddressClass", 1) > 0) then
    international_country_code = orderShip.getCountry()	
    if not(isNull(orderShip.getStateRegion()) AND not(orderShip.getStateRegion()="")) then
      international_state_region_code = orderShip.getStateRegion()
    end if
    userIsCompanyClient = orderShip.isCompanyClient()	
  end if
  Set orderShip = nothing
  Set objShip = nothing

  if(Err.number <> 0) then 
  'response.write(Err.description)
  end if
end if	
%>
<!-- #include virtual="/common/include/setTemplateTargetList.inc" -->
<%
on error Resume Next
if(id_prodotto <> "")then
			Set objCurrentProdotto = Prodotto.findProdottoByParameter("id", id_prodotto, 1, 1)  
end if     
    
if Err.number <> 0 then
end if    
  
if (Instr(1, typename(objCurrentProdotto), "ProductsClass", 1) > 0) then
  if not(lang.getTranslated(objCurrentProdotto.getMetaDescription()) = "") then
    metaDescription = metaDescription & " " & lang.getTranslated(objCurrentProdotto.getMetaDescription())
  else
    metaDescription = metaDescription & " " & objCurrentProdotto.getMetaDescription()
  end if
  
  if not(lang.getTranslated(objCurrentProdotto.getMetaKeyword()) = "") then
    metaKeyword = metaKeyword & " " & lang.getTranslated(objCurrentProdotto.getMetaKeyword())
  else
    metaKeyword = metaKeyword & " " & objCurrentProdotto.getMetaKeyword()
  end if
  
  if not(lang.getTranslated(objCurrentProdotto.getPageTitle()) = "") then
    pageTemplateTitle = lang.getTranslated(objCurrentProdotto.getPageTitle())
  else
    if not(objCurrentProdotto.getPageTitle() = "")then
      pageTemplateTitle = objCurrentProdotto.getPageTitle()
    end if
  end if

  '*************** verifico se esiste la geolocalizzazione per questo elemento
  Dim objLocaliz, objPoint, latitude, longitude
  Set objLocaliz = new LocalizationClass  
  Set objListPoint = Server.CreateObject("Scripting.Dictionary")     
  on error Resume Next
  Set points = objLocaliz.findPointByElement(id_prodotto, 2)
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

  Set objListaFile = New File4ProductsClass
  if not(isNull(objListaFile.getFilePerProdotto(id_prodotto))) AND not(isEmpty(objListaFile.getFilePerProdotto(id_prodotto))) then
    Set objListaFilePerProdotto = objListaFile.getFilePerProdotto(id_prodotto)

    if not(isEmpty(objListaFilePerProdotto)) then 
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
				
				for each xObjFile in objListaFilePerProdotto
					Set objFileXProd = objListaFilePerProdotto(xObjFile)					
					
					select case objFileXProd.getFileTypeLabel()
					case 1
						hasSmallImg = true
            attachSmall.add objFileXProd, ""
					case 2
						hasBigImg = true
            attachBig.add objFileXProd, ""	
					case 3
						hasPdf = true
            attachPdf.add objFileXProd, ""
					case 4
						hasAudioVideo = true
            attachAudioVideo.add objFileXProd, ""
					case 5
						hasOthers = true
            attachOther.add objFileXProd, ""
					case 6
						hasMediumImg = true
            attachMedium.add objFileXProd, ""
					case 7						
            hasCardImg = true
            attachCard.add objFileXProd, ""
					case else
					end select
					Set objFileXProd = nothing	
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
			Set objListaFilePerProdotto = nothing
		end if
    Set objListaFile = nothing     
end if

metaDescription = Trim(metaDescription)
metaKeyword = Trim(metaKeyword)
pageTemplateTitle = Trim(pageTemplateTitle)

if (pageTemplateTitle = "") then
  pageTemplateTitle = lang.getTranslated("frontend.page.title")
end if 

Response.Charset="UTF-8"
Session.CodePage  = 65001

Set objCat = new CategoryClass
Set objPageTempl = new Page4TemplateClass
Set objTemplate = new TemplateClass
Set objMenuFruizione = new MenuClass

'*** recupero la back url verso la pagina lista
backUrl = "#"
On Error Resume Next							         
Set objCategoriaTmp = objCat.findExsitingCategoriaByGerarchia(strGerarchia)
if not(isNull(objCategoriaTmp)) then
  Set objTemplateSelected = objTemplate.findTemplateByID(objCategoriaTmp.findLangTemplateXCategoria(lang.getLangCode(),true))
  backUrl = objMenuFruizione.resolveHrefUrl(base_url, 1, lang, objCategoriaTmp, objTemplateSelected, objPageTempl)
  Set objTemplateSelected = nothing
else
  backUrl = "#"                  
end if
Set objCategoriaTmp = nothing
if(Err.number <>0) then
  backUrl = "#"
end if 
%>
