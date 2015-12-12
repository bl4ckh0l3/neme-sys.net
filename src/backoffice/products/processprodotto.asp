<%@Language=VBScript codepage=65001 %>
<% 
'option explicit
On error resume next 
Server.ScriptTimeout=3600 ' max value = 2147483647
Response.Expires=-1500
Response.Buffer = TRUE
Response.Clear
Response.ContentType="text/html"
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<!-- #include virtual="/common/include/Objects/FileUploadClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->

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
	Dim id_prod, strCodProd, strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod, sconto_prod, id_tassa_applicata, strServerName
	Dim reqTargets, reqFiles, arrTarget, arrFiles, reqDownFiles, arrDownFiles, reqProdRelList
	Dim reqFilesToMod, arrFilesToMod, save_esc, redirectPage, numMaxImgs, prod_type, max_download, max_download_time, taxs_group, edit_buy_qta
    Dim Upload, fileName, fileSize, ks, i, fileKey
	Dim uploadsDirVar	
	Dim reqFieldList, arrFieldList
	Dim page_title, meta_description, meta_keyword
	
  Set Upload = New FileUploadClass
	Upload.SaveField()
	
	strServerName = Upload.Form("srv_name")
	redirectPage = Application("baseroot")&"/editor/prodotti/ListaProdotti.asp"
	save_esc = Upload.Form("save_esc")	
	
	id_prod = Upload.Form("id_prodotto")
	
	if(save_esc = 0) then
		redirectPage = Application("baseroot")&"/editor/prodotti/inserisciprodotto.asp?id_prodotto="&id_prod&"&cssClass=LP"
	end if	
	
	strCodProd = Upload.Form("codice_prod")
	strNomeProd = Upload.Form("nome_prod")
	strSommarioProd = Upload.Form("sommario_prod")
	strDescProd = Upload.Form("desc_prod")
	numPrezzo = Upload.Form("prezzo_prod")
	numQta = Upload.Form("qta_prod")
	stato_prod = Upload.Form("stato_prod")
	sconto_prod = Upload.Form("sconto_prod")
	if(sconto_prod="")then
		sconto_prod=0
	end if
	
	id_tassa_applicata  = Upload.Form("id_tassa_applicata")
	taxs_group = Upload.Form("taxs_group")
	prod_type = Upload.Form("prod_type")
	max_download = Upload.Form("max_download")
	max_download_time = Upload.Form("max_download_time")
	edit_buy_qta = Upload.Form("edit_buy_qta")
	
	'** sostituisco dai campi abstract e dal testo i caratteri di default aggiunti dall'editor html:
	if (strSommarioProd ="<br type=&quot;_moz&quot; />" or strSommarioProd ="<br type=""_moz"" />" or strSommarioProd ="&lt;br type=&quot;_moz&quot; /&gt;" or strSommarioProd ="&lt;br /&gt;" or strSommarioProd ="<br />") then
		strSommarioProd = ""
	else
		strSommarioProd = Replace(strSommarioProd, "src="""&strServerName, "src=""", 1, -1, 1)
		strSommarioProd = Replace(strSommarioProd, "\r\n", "", 1, -1, 1)
		strSommarioProd = Replace(strSommarioProd, "'", "&#39;", 1, -1, 1)
	end if

	if (strDescProd ="<br type=&quot;_moz&quot; />" or strDescProd ="<br type=""_moz"" />" or strDescProd ="&lt;br type=&quot;_moz&quot; /&gt;" or strDescProd ="&lt;br /&gt;" or strDescProd ="<br />") then
		strDescProd = ""
	else
		strDescProd = Replace(strDescProd, "src="""&strServerName, "src=""", 1, -1, 1)
		strDescProd = Replace(strDescProd, "\r\n", "", 1, -1, 1)
		strDescProd = Replace(strDescProd, "'", "&#39;", 1, -1, 1)	
	end if
	
	page_title = Upload.Form("page_title")
	meta_description = Upload.Form("meta_description")
	meta_keyword = Upload.Form("meta_keyword")
	
	reqTargets = Upload.Form("ListTarget")
	reqFiles = Upload.Form("ListFileDaEliminare")
	reqDownFiles = Upload.Form("ListFileDownDaEliminare")
	reqFilesToMod = Upload.Form("ListFileDaModificare")
	numMaxImgs = Upload.Form("numMaxImgs")
	reqFieldList = Upload.Form("list_prod_fields")
	reqFieldListValues = Upload.Form("list_prod_fields_values")
	reqProdRelList = Upload.Form("list_prod_relations")
		
	arrTarget = split(reqTargets, "|", -1, 1)
	arrFiles = split(reqFiles, "|", -1, 1)
	arrDownFiles = split(reqDownFiles, "|", -1, 1)
	arrFilesToMod = split(reqFilesToMod, "|", -1, 1)
	arrFieldList = split(reqFieldList, "|", -1, 1)
	arrFieldListValues = split(reqFieldListValues, "##", -1, 1)	
	reqProdRelList = split(reqProdRelList, "|", -1, 1)

	Dim objFSO
	Dim fileXprod, tmpFileXprod, tmpPath
	Dim xFiles, yFiles, xDownFiles
	Dim tmpFileName, tmpFilePath, new_id_file	
	Dim targetXprod	
	Dim xTarget
	Dim objDownloadedProdUpload,numMaxProds, hasDownAttachment
					
	Dim objProd
	Set objProd = New ProductsClass
	
	Dim objLogger
	Set objLogger = New LogClass

	Dim objProdField
	Set objProdField = new ProductFieldClass
	
	Dim objDB,objConn 


	'response.write("id_prod: "&id_prod&"<br>")	
	'response.write("strCodProd: "&strCodProd&"<br>")
	'response.write("strNomeProd: "&strNomeProd&"<br>")
	'response.write("strSommarioProd: "&strSommarioProd&"<br>")
	'response.write("strDescProd: "&strDescProd&"<br>")
	'response.write("numPrezzo: "&numPrezzo&"<br>")
	'response.write("numQta: "&numQta&"<br>")
	'response.write("stato_prod: "&stato_prod&"<br>")
	'response.write("sconto_prod: "&sconto_prod&"<br>")
	'response.write("id_tassa_applicata: "&id_tassa_applicata&"<br>")
	'response.write("taxs_group: "&taxs_group&"<br>")
	'response.write("prod_type: "&prod_type&"<br>")
	'response.write("max_download: "&max_download&"<br>")
	'response.write("max_download_time: "&max_download_time&"<br>")
	'response.write("page_title: "&page_title&"<br>")
	'response.write("meta_description: "&meta_description&"<br>")
	'response.write("meta_keyword: "&meta_keyword&"<br>")
	
	if (Cint(id_prod) <> -1) then
		'/**
		'* prodotto da mofificare
		'*/		

		'call objLogger.write("pre modifica prodotto --> id: "&id_prod&"; nome prodotto: "&strNomeProd&"; codice prodotto: "&strCodProd&"; sommario prodotto: "&strSommarioProd&"; testo prodotto: "&strDescProd, "system", "debug")
		'response.end
				
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		call objProd.modifyProdotto(id_prod, strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod, sconto_prod, strCodProd, id_tassa_applicata, prod_type, max_download, max_download_time, taxs_group, meta_description, meta_keyword, page_title, edit_buy_qta, objConn)
		call objLogger.write("process prodotto - modificato prodotto --> id: "&id_prod&"; nome prodotto: "&strNomeProd&"; codice prodotto: "&strCodProd, objUserLogged.getUserName(), "info")
		
		'/**
		'* cancello i vecchi field e inserisco i nuovi field per prodotto
		'*/			
		call objProdField.deleteFieldMatchByProd(id_prod, objConn)
		
		for each xField in arrFieldList
			idField = Left(xField,InStr(1,xField,"-",1)-1)
			value = ""
			typeField = Right(xField,InStr(1,xField,"-",1)-1)
			if(typeField <> 3 AND typeField <> 4) then value = Upload.Form(objProdField.getFieldPrefix()&idField) end if
			call objProdField.insertFieldMatch(idField, id_prod, value, objConn)	
		next	

		
		'/**
		'* cancello i vecchi field values e inserisco i nuovi field values per prodotto
		'*/					
		call objProdField.deleteFieldValueMatchByProd(id_prod, objConn)	
		
		for each arrFieldVal in arrFieldListValues
			xFieldVal = split(arrFieldVal, "|", -1, 1)
			intQta = 0
			if(Ubound(xFieldVal)>0) then
				if(Ubound(xFieldVal) = 3) then 
					if(xFieldVal(3) <> "") then
						intQta = xFieldVal(3)
					end if
				end if
				call objProdField.insertFieldValueMatch(xFieldVal(0), xFieldVal(1), intQta, xFieldVal(2), objConn)
			end if
		next
		
		
		Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
		
		uploadsDirVar = Application("dir_upload_prod")
		uploadsDirVar = Server.MapPath(uploadsDirVar)


		Set fileXprod = new File4ProductsClass
		
		'/**
		'* modifico le didascalie dei file allegati!
		'*/			
		Dim strDida, strFileTypeLabel, objSingleFile
		
		for each yFiles in arrFilesToMod
			Set objSingleFile = fileXprod.getFileByID(yFiles)
			strDida = Upload.Form("fileDaModificare_"&objSingleFile.getFileID())
			strFileTypeLabel = Upload.Form("fileDaModificare_"&objSingleFile.getFileID()&"_label")
			call fileXprod.modifyFileXProdotto(objSingleFile.getFileID(), id_prod, objSingleFile.getFileName(), objSingleFile.getFileType(), objSingleFile.getFilePath(), strDida, strFileTypeLabel, objConn)
			Set objSingleFile = nothing
		next
		
		
		'/**
		'* cancello i file allegati selezionati
		'*/		
		for each xFiles in arrFiles
			Set tmpFileXprod = fileXprod.getFileByID(xFiles)			
			tmpPath = tmpFileXprod.getFilePath()			
			tmpPath = Replace(tmpPath, "/", "\", 1, -1, 1)			
			if(objFSO.FileExists(uploadsDirVar & "\" & tmpPath)) then
				objFSO.DeleteFile(uploadsDirVar & "\" & tmpPath)
			end if
			call fileXprod.deleteFileXProdotto(xFiles, objConn)
			Set tmpFileXprod = nothing	
		next
		'/**
		'* inserisco i nuovi file allegati
		'*/
		uploadsDirVar = uploadsDirVar & "\" & id_prod &"\"
		if not(objFSO.FolderExists(uploadsDirVar)) then
'<!--nsys-demoprdproc1-->
			call objFSO.CreateFolder(uploadsDirVar)	
'<!---nsys-demoprdproc1-->
		end if
		Set objFSO = nothing
'<!--nsys-demoprdproc2-->		
		call Upload.SaveAttach(uploadsDirVar,"fileupload", numMaxImgs)
'<!---nsys-demoprdproc2-->		
		ks = Upload.UploadedFiles.keys
		if (UBound(ks) <> -1) then
			dim f
			for f = 1 to numMaxImgs			
				if not(isEmpty(Upload.UploadedFiles("fileupload"&f)))then
					tmpFileName = Upload.UploadedFiles("fileupload"&f).FileName()
					tmpFilePath = id_prod & "/" & tmpFileName
					if (Instr(1, typename(fileXprod.getFileByFileNameAndIdProd(id_prod,tmpFileName)), "File4ProductsClass", 1) > 0) then
						call fileXprod.modifyFileXProdotto(fileXprod.getFileByFileNameAndIdProd(id_prod,tmpFileName).getFileID(), id_prod, tmpFileName, Upload.UploadedFiles("fileupload"&f).Content_Type(), tmpFilePath, Upload.Form("fileupload"&f & "_dida"), Upload.Form("fileupload"&f & "_label"), objConn)
					else
						call fileXprod.insertFileXProdotto(id_prod, tmpFileName, Upload.UploadedFiles("fileupload"&f).Content_Type(), tmpFilePath, Upload.Form("fileupload"&f & "_dida"), Upload.Form("fileupload"&f & "_label"),objConn)					
					end if
				end if
			next
		end if		
		Set fileXprod = nothing
	
		'/**
		'* se il prodotto è di tipo download faccio upload sul server con la classe opportuna
		'*/
		if(prod_type=1) then			
			On Error Resume Next	
			Dim uploadsProdDirVar, tmpDownPath, tmpDownFileXprod
			Set objDownloadedProdUpload = new DownloadableProductClass
			hasDownAttachment = false
	
			uploadsProdDirVar = Application("dir_down_prod")
			uploadsProdDirVar = Server.MapPath(uploadsProdDirVar)
		
			Dim ScriptObject
			Set ScriptObject = Server.CreateObject("Scripting.FileSystemObject")					
			'/**
			'* cancello i file downloadable allegati selezionati
			'*/		
			for each xDownFiles in arrDownFiles
				Set tmpDownFileXprod = objDownloadedProdUpload.getFileByID(xDownFiles)			
				tmpDownPath = tmpDownFileXprod.getFilePath()			
				tmpDownPath = Replace(tmpDownPath, "/", "\", 1, -1, 1)

				if(ScriptObject.FileExists(uploadsProdDirVar & "\" & tmpDownPath)) then
					ScriptObject.DeleteFile(uploadsProdDirVar & "\" & tmpDownPath)
				end if
				call objDownloadedProdUpload.deleteDownProd(xDownFiles, objConn)
				Set tmpDownFileXprod = nothing	
			next
			Set ScriptObject = nothing
			
			numMaxProds = Upload.Form("numMaxProds")	
			call objDownloadedProdUpload.saveDownloadProd(id_prod,"prodfileupload",numMaxProds, Upload.getVarArrayBinRequest())			

			'/**
			'* verifico se esiste almeno ancora un file allegato dopo la cancellazione
			'*/
			if(Instr(1, typename(objDownloadedProdUpload.getFilePerProdotto(id_prod)), "Dictionary", 1) > 0) then
				hasDownAttachment = true
			end if

			ks = Upload.UploadedFiles.keys
			if (UBound(ks) <> -1) then
				dim x
				for x = 1 to numMaxProds			
					if not(isEmpty(Upload.UploadedFiles("prodfileupload"&x)))then
						hasDownAttachment = true
						tmpFileName = Upload.UploadedFiles("prodfileupload"&x).FileName()
						tmpFilePath = id_prod & "/" & tmpFileName
						if (Instr(1, typename(objDownloadedProdUpload.getFileByFileNameAndIdProd(id_prod,tmpFileName)), "DownloadableProductClass", 1) > 0) then
							call objDownloadedProdUpload.modifyDownProd(fileXprod.getFileByFileNameAndIdProd(id_prod,tmpFileName).getFileID(), id_prod, tmpFileName, tmpFilePath, Upload.UploadedFiles("prodfileupload"&x).Content_Type(), Upload.UploadedFiles("prodfileupload"&x).FileLength(), objConn)
						else
							call objDownloadedProdUpload.insertDownProd(id_prod, tmpFileName, tmpFilePath, Upload.UploadedFiles("prodfileupload"&x).Content_Type(), Upload.UploadedFiles("prodfileupload"&x).FileLength(),objConn)					
						end if
					end if
				next
			end if				
			
			Set objDownloadedProdUpload = Nothing
			if (Err.number <> 0) then
				'response.Write(Err.description)
			end if
			
			if not(hasDownAttachment) then
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&Application("error_page")&"?error=009")
			end if
		end if
		
		'/**
		'* cancello i vecchi target e inserisco i nuovi target per prodotto
		'*/			
		call objProd.deleteTargetXProdotto(id_prod, objConn)
		
		for each xTarget in arrTarget
			call objProd.insertTargetXProdotto(xTarget, id_prod, objConn)	
		next

		'/**
		'* cancello i vecchi prodotti correlati e inserisco i nuovi per prodotto
		'*/			
		call objProd.deleteAllRelationXProdotto(id_prod, objConn)
		
		for each xReqProd in reqProdRelList
			call objProd.insertRelationXProdotto(id_prod, xReqProd, objConn)	
		next
					

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans

			'rimuovo l'oggetto dalla cache
			Set objCacheClass = new CacheClass
			Set objBase64 = new Base64Class
			objCacheClass.remove("product-"&objBase64.Base64Encode(id_prod))
			call objCacheClass.removeByPrefix("findp", id_prod)
			Set objBase64 = nothing
			Set objCacheClass = nothing	
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objProdField = nothing
		Set objProd = nothing
		Set objUserLogged = nothing
		response.Redirect(redirectPage)		
	else
		'/**
		'* prodotto da inserire e recupero il nuovo ID del prodotto
		'*/	

		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans		

		Dim newMaxID
		newMaxID = objProd.insertProdotto(strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod, sconto_prod, strCodProd, id_tassa_applicata, prod_type, max_download, max_download_time,taxs_group, meta_description, meta_keyword, page_title, edit_buy_qta, objConn)
		call objLogger.write("process prodotto - modificato prodotto --> id: "&newMaxID&"; nome prodotto: "&strNomeProd, objUserLogged.getUserName(), "info")

		
		'/**
		'* inserisco i nuovi field per prodotto
		'*/					
		for each xField in arrFieldList
			idField = Left(xField,InStr(1,xField,"-",1)-1)
			value = ""
			typeField = Right(xField,InStr(1,xField,"-",1)-1)
			if(typeField <> 3 AND typeField <> 4) then value = Upload.Form(objProdField.getFieldPrefix()&idField) end if
			call objProdField.insertFieldMatch(idField, newMaxID, value, objConn)	
		next

		
		'/**
		'* inserisco i nuovi field values per prodotto
		'*/							
		for each arrFieldVal in arrFieldListValues
			xFieldVal = split(arrFieldVal, "|", -1, 1)
			intQta = 0
			if(Ubound(xFieldVal)>0) then
				if(Ubound(xFieldVal) = 3) then 
					if(xFieldVal(3) <> "") then
						intQta = xFieldVal(3)
					end if
				end if
				call objProdField.insertFieldValueMatch(xFieldVal(0), newMaxID, intQta, xFieldVal(2), objConn)
			end if
		next
		
		
		'/**
		'* inserisco i nuovi file allegati
		'*/
		Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
		
		uploadsDirVar = Application("dir_upload_prod")
		uploadsDirVar = Server.MapPath(uploadsDirVar)
		
		uploadsDirVar = uploadsDirVar & "\" & newMaxID &"\"
		if not(objFSO.FolderExists(uploadsDirVar)) then
'<!--nsys-demoprdproc3-->
			call objFSO.CreateFolder(uploadsDirVar)
'<!---nsys-demoprdproc3-->
		end if
		Set objFSO = nothing
'<!--nsys-demoprdproc4-->		
		call Upload.SaveAttach(uploadsDirVar,"fileupload", numMaxImgs)
'<!---nsys-demoprdproc4-->
		
		Set fileXprod = new File4ProductsClass
		
		ks = Upload.UploadedFiles.keys
		if (UBound(ks) <> -1) then
			dim q
			for q = 1 to numMaxImgs			
				if not(isEmpty(Upload.UploadedFiles("fileupload"&q)))then
					tmpFileName = Upload.UploadedFiles("fileupload"&q).FileName()
					tmpFilePath = newMaxID & "/" & tmpFileName
					call fileXprod.insertFileXProdotto(newMaxID, tmpFileName, Upload.UploadedFiles("fileupload"&q).Content_Type(), tmpFilePath, Upload.Form("fileupload"&q & "_dida"), Upload.Form("fileupload"&q & "_label"),objConn)
				end if
			next

		end if		
		Set fileXprod = nothing

		'/**
		'* se il prodotto è di tipo download faccio upload sul server con la classe opportuna
		'*/
		if(prod_type=1) then
			Set objDownloadedProdUpload = new DownloadableProductClass
			numMaxProds = Upload.Form("numMaxProds")
			hasDownAttachment = false
			
			On Error Resume Next			
			call objDownloadedProdUpload.saveDownloadProd(newMaxID,"prodfileupload",numMaxProds, Upload.getVarArrayBinRequest())	

			ks = Upload.UploadedFiles.keys
			if (UBound(ks) <> -1) then
				dim y
				for y = 1 to numMaxProds			
					if not(isEmpty(Upload.UploadedFiles("prodfileupload"&y)))then
						hasDownAttachment = true
						tmpFileName = Upload.UploadedFiles("prodfileupload"&y).FileName()
						tmpFilePath = newMaxID & "/" & tmpFileName
						call objDownloadedProdUpload.insertDownProd(newMaxID, tmpFileName, tmpFilePath, Upload.UploadedFiles("prodfileupload"&y).Content_Type(), Upload.UploadedFiles("prodfileupload"&y).FileLength(),objConn)					
					end if
				next
			end if

			Set objDownloadedProdUpload = Nothing
			if (Err.number <> 0) then
				response.Write(Err.description)
			end if
			
			if not(hasDownAttachment) then
				objConn.RollBackTrans
				response.Redirect(Application("baseroot")&Application("error_page")&"?error=009")
			end if
		end if
		
		'/**
		'* inserisco i nuovi target per prodotto
		'*/
		for each xTarget in arrTarget
			call objProd.insertTargetXProdotto(xTarget, newMaxID, objConn)	
		next	

		'/**
		'* inserisco i nuovi prodotti correlati
		'*/					
		for each xReqProd in reqProdRelList
			call objProd.insertRelationXProdotto(newMaxID, xReqProd, objConn)	
		next	

		'/**
		'* aggiorno le localizzazioni se sono state inserite prima di salvare il contenuto
		'*/
		if(Upload.Form("pregeoloc_el_id")<>"") then
			Set objLoc = new LocalizationClass
			Set listOfPoints = objLoc.findPointByElement(Upload.Form("pregeoloc_el_id"), 2)
			for each q in listOfPoints
				call objLoc.modifyPoint(q, newMaxID, listOfPoints(q).getLatitude(), listOfPoints(q).getLongitude(), listOfPoints(q).getInfo(), objConn)
			next
			Set listOfPoints = nothing
			Set objLoc = nothing
		end if
		
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
		Set objProdField = nothing						
		Set objProd = nothing
		Set objUserLogged = nothing
		response.Redirect(redirectPage)				
	end if
	
	Set objLogger = nothing

	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>