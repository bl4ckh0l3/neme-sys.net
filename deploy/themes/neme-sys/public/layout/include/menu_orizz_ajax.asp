<!-- #include virtual="/common/include/Objects/DBManagerClass.asp" -->
<!-- #include virtual="/common/include/Objects/CategoryClass.asp" -->
<!-- #include virtual="/common/include/Objects/MenuClass.asp" -->
<!-- #include virtual="/common/include/Objects/LanguageClass.asp" -->
<!-- #include virtual="/common/include/Objects/TemplateClass.asp" -->
<!-- #include virtual="/common/include/Objects/Page4TemplateClass.asp" -->
<!-- #include virtual="/common/include/InitData.inc" -->
<ul>  
	<%
	Dim menuFruizioneOrizz, menuCompleteOrizz, categoriaClassTmpOrizz
	Dim levelOrizz, iWidthOrizz, strSubTmpGerOrizz, strSubTmpGerFilteredOrizz
	Dim iGerlevelOrizz, iGerDiffOrizz, hrefGerOrizz, menuCompleteOrizzCatDescTrans
	
	Set menuFruizioneOrizz = new MenuClass
	Set categoriaClassTmpOrizz = new CategoryClass
  Set objTemplateOrizz = new TemplateClass	
  Set objPage4TemplateMenuOrizz = new Page4TemplateClass  
	
  strGerarchia = request("gerarchia")
  bolMenuOrizzFound = false
	
	oldlevelOrizz = 1
	menuOrizzCounter = 0
	
	Dim xOrizz, objCategoriaCheckOrizz, strHrefOrizz

  On Error Resume Next			
  Set menuCompleteOrizz = menuFruizioneOrizz.getCompleteMenuByMenu("1")
  bolMenuOrizzFound = true
  if(Err.number <>0) then
    bolMenuOrizzFound = false
  end if
  if(bolMenuOrizzFound)then
    for each xOrizz in menuCompleteOrizz			
      levelOrizz = menuFruizioneOrizz.getLivello(xOrizz)  
      menuCompleteOrizzCatLabelTrans = "frontend.menu.label."&menuCompleteOrizz(xOrizz).getCatDescrizione()
        
      strSubTmpGerOrizz = strGerarchia
      if(InStr(1, strGerarchia, ".", 1)>0)then
        strSubTmpGerOrizz = Left(strGerarchia, InStr(1, strGerarchia, ".", 1)-1)
      end if
      
      '*** Controllo se la categoria contiene news, altrimenti disabilito il link
      On Error Resume Next
      Set objCategoriaCheckOrizz = categoriaClassTmpOrizz.checkEmptyCategory(menuCompleteOrizz(xOrizz), false)
      if not(isNull(objCategoriaCheckOrizz)) then
        hrefGerOrizz = objCategoriaCheckOrizz.getCatGerarchia()
        Set objTemplateSelectedOrizz = objTemplateOrizz.findTemplateByID(objCategoriaCheckOrizz.findLangTemplateXCategoria(lang.getLangCode(),true))
        strHrefOrizz = menuFruizioneOrizz.resolveHrefUrl(base_url, 1, lang, objCategoriaCheckOrizz, objTemplateSelectedOrizz, objPage4TemplateMenuOrizz)
        Set objTemplateSelectedOrizz = nothing
      end if
      Set objCategoriaCheckOrizz = nothing
      if(Err.number <>0) then
        strHrefOrizz = "#"
      end if
      
      if(levelOrizz<oldlevelOrizz) then
        for counter = levelOrizz to oldlevelOrizz-1%>
        </ul>
        </li>
      <%next	
      end if%>
      <li><a href="javascript:openLinkMenuOrizz('<%=hrefGerOrizz%>','<%=strHrefOrizz%>');" <%if(strComp(xOrizz, strSubTmpGerOrizz, 1) = 0) then response.Write("class=""link-attivo""")%>><%if not(isNull(lang.getTranslated(menuCompleteOrizzCatLabelTrans))) AND not(lang.getTranslated(menuCompleteOrizzCatLabelTrans) = "") then response.write(lang.getTranslated(menuCompleteOrizzCatLabelTrans)) else response.Write(menuCompleteOrizz(xOrizz).getCatDescrizione()) end if%></a>
      <%
      bolHasSubCat = false
      On Error Resume Next
      Set objCategoriaTmpOrizz = categoriaClassTmpOrizz.findExsitingChildCategoriaStartWithGerarchia(xOrizz)
      if not(isNull(objCategoriaTmpOrizz)) then
        bolHasSubCat = true
      end if
      if(Err.number <>0) then
       bolHasSubCat = false
      end if
      if(bolHasSubCat)then
        if(objCategoriaTmpOrizz.isCatVisible()) then%>
          <ul>
        <%else%>
          </li>
        <%end if
        Set objCategoriaTmpOrizz = nothing
      else%>
          </li>
      <%end if      
      oldlevelOrizz = levelOrizz
      menuOrizzCounter = menuOrizzCounter+1		
      
      if(menuOrizzCounter=menuCompleteOrizz.Count) then
        if(levelOrizz>1) then
          for counter = 1 to levelOrizz-1%>
            </ul>
            </li>
          <%next	
        end if			
      end if
    next            
	end if

  Set objPage4TemplateMenuOrizz = nothing
  Set objTemplateOrizz = nothing  
	Set menuCompleteOrizz = nothing
	Set categoriaClassTmpOrizz = nothing
	Set menuFruizioneOrizz = nothing%>
</ul>
<br style="clear: left" />  