<%@ Language=VBScript %>
<% 
'option explicit
On error resume next 
%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->
<!-- #include virtual="/common/include/Objects/CommentsClass.asp" -->
<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_prodotto, redirectPage
	Dim objDB, objConn
	redirectPage = Application("baseroot")&"/editor/prodotti/inserisciprodotto.asp?cssClass=LP&id_prodotto="
	
	Dim objFSO, uploadsDirVar, origUploadsDirVar
	Dim objFileXprod, fileXprod, tmpfileXprod, tmpPath
	Dim xFiles, yFiles
	Dim tmpFileName, tmpFilePath, new_id_file	
	Dim targetXprod	
	Dim xTarget
	Dim prod_type
	prod_type = 0
					
	Dim objProd, objOriginalProd
	Set objProd = New ProductsClass

	Dim objLocal
	Set objLocal = new LocalizationClass
	
	Dim objLogger
	Set objLogger = New LogClass	

	Set objFileXprod = new File4ProductsClass

	Dim commentsXprod, commentListXprod
	Set commentsXprod = New CommentsClass

	'/**
	'* recupero la news originale da clonare
	'*/
	id_prodotto = request("id_prodotto")
	Set objOriginalProd = objProd.findProdottoByID(id_prodotto,true)

	On Error Resume Next
	Set objRelationsProd = objOriginalProd.getRelationPerProdotto(id_prodotto)	
	If(Err.number <> 0) then
		objRelationsProd = null
	end if	
	On error resume next
	Set targetXprod = objOriginalProd.getListaTarget()
	if(Err.number <> 0) then	
	end if
	On error resume next
	Set fileXprod = objOriginalProd.getFileXProdotto()
	if(Err.number <> 0) then	
	end if
	On error resume next
	prod_type = objOriginalProd.getProdType()
	if(Err.number <> 0) then	
	end if
	On error resume next
	Set commentListXprod = commentsXprod.findCommentiByIDElement(id_prodotto, 2, null)
	if(Err.number <> 0) then	
	end if
	On error resume next
	Set points = objLocal.findPointByElement(id_prodotto, 2)
	if(Err.number <> 0) then	
	end if	
	'/**
	'* news da inserire e recupero Max(ID) 
	'*/	
	Dim newMaxID
	
	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans		

	newMaxID = objProd.insertProdotto(objOriginalProd.getNomeProdotto(), objOriginalProd.getSommarioProdotto(), objOriginalProd.getDescProdotto(), objOriginalProd.getPrezzo(), Application("unlimited_key"), 0, objOriginalProd.getSconto(), objOriginalProd.getCodiceProd(), objOriginalProd.getIDTassaApplicata(), objOriginalProd.getProdType(), objOriginalProd.getMaxDownload(), objOriginalProd.getMaxDownloadTime(),objOriginalProd.getTaxGroup(), objOriginalProd.getMetaDescription(), objOriginalProd.getMetaKeyword(), objOriginalProd.getPageTitle(), objOriginalProd.getEditBuyQta(), objConn)
	call objLogger.write("modificato prodotto --> id: "&newMaxID&"; nome prodotto: "&objOriginalProd.getNomeProdotto(), objUserLogged.getUserName(), "info")
	
	'/**
	'* inserisco i commenti per prodotto
	'*/	
	On error resume next
	for each xComment in commentListXprod.Items
		call commentsXprod.insertCommento(newMaxID, xComment.getElementType(), xComment.getIDUtente(), xComment.getMessage(), xComment.getVoteType(), xComment.getActive(), objConn)
	next	
	Set commentListXprod = nothing
	Set commentsXprod = nothing
	if(Err.number <> 0) then
	end if


	'********** RECUPERO LA LISTA DI FIELD PRODOTTI ASSOCIATI AL PRODOTTO
	Dim objProdField, objListProdField
	Set objProdField = new ProductFieldClass
	On Error Resume Next
	Set objListProdField = objProdField.getListProductField4ProdActive(id_prodotto)

	if(Instr(1, typename(objListProdField), "Dictionary", 1) > 0) then
		if(objListProdField.count > 0)then		
			'/**
			'* inserisco i field per prodotto
			'*/					
			for each xField in objListProdField
				Set objProductField = objListProdField(xField)
				call objProdField.insertFieldMatch(xField, newMaxID, objProductField.getSelValue(), objConn)	
				Set objProductField = nothing
			next
		end if
	end if
	if(Err.number <> 0) then
	end if
	Set objProdField = nothing	

	Set objOriginalProd = nothing
	
	'/**
	'* inserisco i nuovi file allegati
	'*/
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	
	uploadsDirVar = Application("baseroot")&Application("dir_upload_prod")
	uploadsDirVar = Server.MapPath(uploadsDirVar)
	origUploadsDirVar = uploadsDirVar
	
	uploadsDirVar = uploadsDirVar & "\" & newMaxID
	if not(objFSO.FolderExists(uploadsDirVar)) then
		call objFSO.CreateFolder(uploadsDirVar)		
	end if

	On error resume next
	for each xFiles in fileXprod	
		Set tmpfileXprod = fileXprod(xFiles)
		tmpFileName = tmpfileXprod.getFileName()
		tmpFilePath = newMaxID & "/" & tmpFileName						
		call objFileXprod.insertFileXProdotto(newMaxID, tmpFileName, tmpfileXprod.getFileType(), tmpFilePath, tmpfileXprod.getFileDida(), tmpfileXprod.getFileTypeLabel(),objConn)
		Set tmpfileXprod = nothing
	next	
	Set fileXprod = nothing	
	if (objFSO.FolderExists(objFSO.BuildPath(origUploadsDirVar,id_prodotto))) then
		objFSO.CopyFile objFSO.BuildPath(origUploadsDirVar,id_prodotto)&"\*.*",uploadsDirVar&"\"
	end if
	if(Err.number <> 0) then	
	end if
	Set objFileXprod = nothing

	if(prod_type=1) then
		Set objDownloadedProdUpload = new DownloadableProductClass
		
		On Error Resume Next
		uploadsProdDirVar = Application("dir_down_prod")
		uploadsProdDirVar = Server.MapPath(uploadsProdDirVar)
		origUploadsProdDirVar = uploadsProdDirVar

		if(Instr(1, typename(objDownloadedProdUpload.getFilePerProdotto(id_prodotto)), "Dictionary", 1) > 0) then
			uploadsProdDirVar = uploadsProdDirVar & "\" & newMaxID
			if not(objFSO.FolderExists(uploadsProdDirVar)) then
				call objFSO.CreateFolder(uploadsProdDirVar)		
			end if
			if (objFSO.FolderExists(objFSO.BuildPath(origUploadsProdDirVar,id_prodotto))) then
				objFSO.CopyFile objFSO.BuildPath(origUploadsProdDirVar,id_prodotto)&"\*.*",uploadsProdDirVar&"\"
			end if
			Set downloadedProdUploadList = objDownloadedProdUpload.getFilePerProdotto(id_prodotto)
			for each j in downloadedProdUploadList		
				tmpFileName = downloadedProdUploadList(j).getFileName()
				tmpFilePath = newMaxID & "/" & tmpFileName
				call objDownloadedProdUpload.insertDownProd(newMaxID, tmpFileName, tmpFilePath, downloadedProdUploadList(j).getContentType(), downloadedProdUploadList(j).getFileSize(),objConn)					
			next
			Set downloadedProdUploadList = nothing
		end if
		Set objDownloadedProdUpload = Nothing
		if (Err.number <> 0) then
			response.Write(Err.description)
		end if
	end if

	Set objFSO = nothing


	'/**
	'* inserisco i target per news clonati
	'*/
	for each xTarget in targetXprod
		call objProd.insertTargetXProdotto(xTarget, newMaxID, objConn)	
	next			
	Set targetXprod = nothing

	'/**
	'* inserisco i nuovi prodotti correlati clonati
	'*/					
	if not(isNull(objRelationsProd)) then
		for each xReqProd in objRelationsProd
			call objProd.insertRelationXProdotto(newMaxID, xReqProd, objConn)	
		next		
	end if	
	
	'/**
	'* inserisco i dati di geolocalizzazione clonati
	'*/					
	if not(isNull(points)) then
		'call objLogger.Write("insertPoint --> newMaxID: "&newMaxID&" - xLocal.getLatitude():"&xLocal.getLatitude()&"xLocal.getLongitude():"&xLocal.getLongitude()&"xLocal.getInfo():"&xLocal.getInfo(), objUserLogged.getUserName(), "info")
		for each xLocal in points.Items
			call objLocal.insertPoint(newMaxID, 2, xLocal.getLatitude(), xLocal.getLongitude(), xLocal.getInfo(), objConn)
		next
	end if	
	Set objLocal = nothing
					
	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
			
		'rimuovo gli oggetti find dalla cache
		Set objCacheClass = new CacheClass
		call objCacheClass.removeByPrefix("findp", null)
		Set objCacheClass = nothing	
	else
		objConn.RollBackTrans
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
	
	Set objDB = nothing	
	Set objProd = nothing
	Set objUserLogged = nothing	

	response.Redirect(redirectPage&newMaxID)	

	Set objLogger = nothing

	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>