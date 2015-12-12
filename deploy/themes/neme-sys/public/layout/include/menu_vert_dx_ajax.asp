<!-- #include virtual="/common/include/Objects/DBManagerClass.asp" -->
<!-- #include virtual="/common/include/Objects/CategoryClass.asp" -->
<!-- #include virtual="/common/include/Objects/MenuClass.asp" -->
<!-- #include virtual="/common/include/Objects/LanguageClass.asp" -->
<!-- #include virtual="/common/include/Objects/TemplateClass.asp" -->
<!-- #include virtual="/common/include/Objects/Page4TemplateClass.asp" -->
<!-- #include virtual="/common/include/InitData.inc" -->
<%
Dim menuFruizioneDx, menuCompleteDx, categoriaClassTmpDx, menuCompleteDxCatLabelTrans
			
strGerarchia = request("gerarchia")
bolMenuFound = false

Set menuFruizioneDx = new MenuClass
Set categoriaClassTmpDx = new CategoryClass
Set objTemplateSx = new TemplateClass	
Set objPage4TemplateMenuSx = new Page4TemplateClass   

iGerLevel = menuFruizioneDx.getLivello(strGerarchia)

On Error Resume Next			
Set menuCompleteDx = menuFruizioneDx.getCompleteMenuByMenu("2")
bolMenuFound = true
if(Err.number <>0) then
bolMenuFound = false
end if
if(bolMenuFound)then
menuDxCounter = 0
for each x in menuCompleteDx
  level = menuFruizioneDx.getLivello(x)
  iGerDiff = level - iGerLevel
  menuCompleteDxCatLabelTrans = "frontend.menu.label."&menuCompleteDx(x).getCatDescrizione()
  menuCompleteDxCatDescTrans = "frontend.menu.desc."&menuCompleteDx(x).getCatDescrizione()

  if(level > 1) then
    iWidth = ((level-1) * 10)+5 
    strSubTmpGer=x
    if(level>iGerLevel)then
      numDeltaTmpGer = 0
      if(InStrRev(x,".",-1,1)>0)then
	numDeltaTmpGer = Len(x)-(InStrRev(x,".",-1,1)-1)
      end if
      strSubTmpGer = Left(x, Len(x)-numDeltaTmpGer)
    end if
      
    numDeltaSubTmpGer = 0
    if(InStrRev(strSubTmpGer,".",-1,1)>0)then
      numDeltaSubTmpGer = Len(strSubTmpGer)-(InStrRev(strSubTmpGer,".",-1,1)-1)
    end if
    strSubTmpGerFiltered = Left(strSubTmpGer, Len(strSubTmpGer)-numDeltaSubTmpGer)
    
    if(iGerDiff <= 1) then
      if(iGerDiff<=0)then
	strSubTmpGer = strSubTmpGerFiltered
      end if
      if (InStr(1, strGerarchia, strSubTmpGer, 1) > 0) then                
	'*** Controllo se la categoria contiene news, altrimenti cerco la prima sottocategoria che contenga news
	'*** e imposto la nuova gerarchia come parametro nel link
	On Error Resume Next
	Set objCategoriaCheck = categoriaClassTmpDx.checkEmptyCategory(menuCompleteDx(x), true)
	if not(isNull(objCategoriaCheck)) then
	  hrefGer = objCategoriaCheck.getCatGerarchia()
	  Set objTemplateSelectedDx = objTemplateSx.findTemplateByID(objCategoriaCheck.findLangTemplateXCategoria(lang.getLangCode(),true))
	  strHref = menuFruizioneDx.resolveHrefUrl(base_url, 1, lang, objCategoriaCheck, objTemplateSelectedDx, objPage4TemplateMenuSx)
	  Set objTemplateSelectedDx = nothing
	else
	  strHref = "#"                  
	end if
	Set objCategoriaCheck = nothing
	if(Err.number <>0) then
	  strHref = "#"
	end if

	'*** checkSelectedCategory
	bolSelectedCat = false
	strSubSelCat = strGerarchia
	for a=1 to Abs(iGerDiff)
	    strSubSelCat = Left(strSubSelCat,InStrRev(strSubSelCat,".",-1,1)-1)
	next
	
	if(strComp(x, strSubSelCat, 1) = 0) then
	    bolSelectedCat = true
	end if              
	%>
	<li><h3><a href="javascript:openLinkMenuDX('<%=hrefGer%>','<%=strHref%>');" style="padding-left:<%=iWidth%>px;" <%if(bolSelectedCat) then response.Write("class=""link-attivo-menu-sub""") else response.Write("class=""link-menu-sub""") end if%>><%if not(isNull(lang.getTranslated(menuCompleteDxCatLabelTrans))) AND not(lang.getTranslated(menuCompleteDxCatLabelTrans) = "") then response.write(lang.getTranslated(menuCompleteDxCatLabelTrans)) else response.Write(menuCompleteDx(x).getCatDescrizione()) end if%></a></h3>
	<%if not(isNull(lang.getTranslated(menuCompleteDxCatDescTrans))) AND not(lang.getTranslated(menuCompleteDxCatDescTrans) = "") then%><p style="padding-left:<%=iWidth%>px;"><%=lang.getTranslated(menuCompleteDxCatDescTrans)%></p><%end if%>
	</li>		
      <%end if
    end if
  else
    iWidth = 0

    strSubTmpGer = strGerarchia
    numDeltaTmpGer = 0
    if(InStr(1, strGerarchia, ".", 1) > 0)then
      numDeltaTmpGer = Len(strGerarchia)-(InStr(1, strGerarchia, ".", 1)-1)
    end if
    strSubTmpGer = Left(strGerarchia, Len(strGerarchia)-numDeltaTmpGer)
  
    '*** Controllo se la categoria contiene news, altrimenti cerco la prima sottocategoria che contenga news
    '*** e imposto la nuova gerarchia come parametro nel link
    On Error Resume Next
    Set objCategoriaCheck = categoriaClassTmpDx.checkEmptyCategory(menuCompleteDx(x), true)
    if not(isNull(objCategoriaCheck)) then
      hrefGer = objCategoriaCheck.getCatGerarchia()
      Set objTemplateSelectedDx = objTemplateSx.findTemplateByID(objCategoriaCheck.findLangTemplateXCategoria(lang.getLangCode(),true))
      strHref = menuFruizioneDx.resolveHrefUrl(base_url, 1, lang, objCategoriaCheck, objTemplateSelectedDx, objPage4TemplateMenuSx)
      Set objTemplateSelectedDx = nothing
    else
      strHref = "#"                  
    end if
    Set objCategoriaCheck = nothing
    if(Err.number <>0) then
      strHref = "#"
    end if%>
    <li><h3><a href="javascript:openLinkMenuDX('<%=hrefGer%>','<%=strHref%>');" <%if(strComp(x, strSubTmpGer, 1) = 0) then response.Write("class=""link-attivo""")%>><%if not(isNull(lang.getTranslated(menuCompleteDxCatLabelTrans))) AND not(lang.getTranslated(menuCompleteDxCatLabelTrans) = "") then response.write(lang.getTranslated(menuCompleteDxCatLabelTrans)) else response.Write(menuCompleteDx(x).getCatDescrizione()) end if%></a></h3>
    <%if not(isNull(lang.getTranslated(menuCompleteDxCatDescTrans))) AND not(lang.getTranslated(menuCompleteDxCatDescTrans) = "") then%><p style="padding-left:<%=iWidth%>px;"><%=lang.getTranslated(menuCompleteDxCatDescTrans)%></p><%end if%></li>
  <%end if
  menuDxCounter = menuDxCounter +1
next
end if
Set objPage4TemplateMenuSx = nothing
Set objTemplateSx = nothing
Set categoriaClassTmpDx = nothing
Set menuCompleteDx = nothing
Set menuFruizioneDx = nothing%>