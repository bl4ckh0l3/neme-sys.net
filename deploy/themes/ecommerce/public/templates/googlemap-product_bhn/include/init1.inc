<%
Dim Prodotto, objListaProdotto, objListaTargetCat, objListaTargetLang
Dim strGerarchia, strCSS, totPages, numPage, objSelMargin

Set Prodotto = New ProductsClass
strGerarchia = request("gerarchia")
numPage = 1

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
Dim bolHasObj
bolHasObj = false

Dim objLocaliz, objPoint
Set objLocaliz = New LocalizationClass
Set objListPoint = Server.CreateObject("Scripting.Dictionary")

on error Resume Next
if (bolCatContainProd) AND not(isNull(objListaTargetCat)) then
  Set objListaProdotto = Prodotto.findProdottiCached(null, null, null, null, null, null, null, null, 0, order_by, objListaTargetCat, objListaTargetLang, 1, 1)	
  
  if(objListaProdotto.Count > 0) then		
    bolHasObj = true
  
    for each t in objListaProdotto
      if not(lang.getTranslated(objListaProdotto(t).getMetaDescription()) = "") then
        metaDescription = metaDescription & " " & lang.getTranslated(objListaProdotto(t).getMetaDescription())
      else
        if not(objListaProdotto(t).getMetaDescription()="")then
          metaDescription = metaDescription & " " & objListaProdotto(t).getMetaDescription()
        end if
      end if
      
      if not(lang.getTranslated(objListaProdotto(t).getMetaKeyword()) = "") then
        metaKeyword = metaKeyword & " " & lang.getTranslated(objListaProdotto(t).getMetaKeyword())
      else
        if not(objListaProdotto(t).getMetaKeyword()="")then
          metaKeyword = metaKeyword & " " & objListaProdotto(t).getMetaKeyword()
        end if
      end if
      
      'if not(lang.getTranslated(objListaProdotto(t).getPageTitle()) = "") then
      ' pageTemplateTitle = pageTemplateTitle & " " & lang.getTranslated(objListaProdotto(t).getPageTitle())
      'else
      '  if not(objListaProdotto(t).getPageTitle()="")then
      '    pageTemplateTitle = pageTemplateTitle & " " & objListaProdotto(t).getPageTitle()
      '  end if
      'end if       
    next

    metaDescription = Trim(metaDescription)
    metaKeyword = Trim(metaKeyword)
    'pageTemplateTitle = Trim(pageTemplateTitle)  
      
		
    Dim objSelProdotto, objListaFile, ProdottoCounter, iIndex, objTmpProdotto, FromProdotto, ToProdotto, Diff
    iIndex = objListaProdotto.Count
    FromProdotto = ((numPage * elem_x_page) - elem_x_page)
    Diff = (iIndex - ((numPage * elem_x_page)-1))
    if(Diff < 1) then
      Diff = 1
    end if

    ToProdotto = iIndex - Diff

    totPages = iIndex\elem_x_page
    if(totPages < 1) then
      totPages = 1
      elseif((iIndex MOD elem_x_page <> 0) AND not ((totPages * elem_x_page) >= iIndex)) then
      totPages = totPages +1	
    end if		

    objTmpProdotto = objListaProdotto.Items      
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


'*************** verifico se esiste la geolocalizzazione per questo elemento      
on error Resume Next
if(bolHasObj) then	
  for each t in objListaProdotto    
    Set points = objLocaliz.findPointByElement(objListaProdotto(t).getIDProdotto(), 2)
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