<% Option Explicit %>
<% Response.Buffer=True %>
<%On Error Resume Next%>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/DownloadableProductClass.asp" -->
<!-- #include virtual="/common/include/Objects/DownloadableProduct4OrderClass.asp" -->
<%
'Constants
'full path to the secure folder
Dim FOLDER_PATH, isValidDown, objDownProd, objDownProd4Order
FOLDER_PATH=Application("baseroot")&Application("dir_down_prod")
if Right(FOLDER_PATH, 1) <> "/" then FOLDER_PATH = FOLDER_PATH & "/"

Const adTypeBinary = 1
Const adTypeText = 2
Const chunkSize = 2048
isValidDown = false

'global variables:
Dim strOrderID 'id of the referred order
Dim strFileID 'id of the file to be downloaded
Dim strFilePath 'path of the file to be downloaded
Dim strFileName 'name of the file to be downloaded
Dim blnForceDownload 'force the download or allow the file to be opebed in the browser?

'read file from querystring:
strOrderID=Request("id_ordine")
strFileID=Request("id_file")
'force download?
blnForceDownload = (Request("force")="1")

Set objDownProd = new DownloadableProductClass
Set objDownProd4Order = new DownloadableProduct4OrderClass	
Dim objDownProdTmp, objDownProd4OrderTmp
Set objDownProdTmp = objDownProd.getFileByID(strFileID)

strFilePath = objDownProdTmp.getFilePath()
strFilePath = Server.MapPath(FOLDER_PATH & strFilePath)
strFileName = objDownProdTmp.getFileName()

'*** verifico se il download è valido in base ai parametri isValid, expireDate e maxNumDownload
Set objDownProd4OrderTmp = objDownProd4Order.getFileByIDProdDown(strOrderID, objDownProdTmp.getIdProd(), strFileID)

if not(isNull(objDownProd4OrderTmp))then
	Dim isValidDownTmp, isExpired, isMaxDownNum
	isValidDownTmp = objDownProd4OrderTmp.isActive()
	isExpired = objDownProd4OrderTmp.isExpired()
	isMaxDownNum = objDownProd4OrderTmp.isMaxDownNum()
	
	if(isValidDownTmp AND NOT isExpired AND NOT isMaxDownNum)then
		isValidDown = true
	end if
end if
			

'execute the function if we got anything:
If (isValidDown) Then
	Call DownloadFile (strFilePath, strFileName, blnForceDownload)
	call objDownProd4Order.modifyDownProdNoTransaction(objDownProd4OrderTmp.getID(), objDownProd4OrderTmp.getIdOrder(), objDownProd4OrderTmp.getIdProd(), objDownProd4OrderTmp.getIdDownProd(), objDownProd4OrderTmp.getIdUser(), objDownProd4OrderTmp.isActive(), objDownProd4OrderTmp.getMaxNumDownload(), now(), objDownProd4OrderTmp.getExpireDate(), (objDownProd4OrderTmp.getDownloadCounter()+1), now())
	Response.END
else
	response.write("Il file selezionato non e' piu' scaricabile!")
End If

Set objDownProd4OrderTmp = nothing
Set objDownProdTmp = nothing
Set objDownProd4Order = nothing
Set objDownProd = nothing



Sub DownloadFile(strFilePath, strFileName, blnForceDownload)
	'local variables:
	Dim fso, objFile
	Dim fileSize, blnBinary, strContentType
	Dim objStream, strAllFile, iSz
	Dim i
	Dim strForce
	
	'----------------------
	'first step: verify the file exists
	'----------------------
	
	'build file path:
	'strFilePath=FOLDER_PATH
	' add backslash if needed:
	'If Right(strFilePath, 1)<>"\" Then strFilePath=strFilePath&"\"
	'strFilePath=strFilePath&strFileName
	
	'initialize file system object:
	Set fso=Server.CreateObject("Scripting.FileSystemObject")
	
	'check that the file exists:
	If Not(fso.FileExists(strFilePath)) Then
		Set fso=Nothing
		Err.Raise 20000, "Download Manager", "Fatal Error: file does not exist: "&strFilePath
		Response.END
	End If
	
	'----------------------
	'second step: get file size.
	'----------------------
	Set objFile=fso.GetFile(strFilePath)
	fileSize=objFile.Size
	Set objFile=Nothing
	
	'----------------------
	'third step: check whether file is binary or not and get content type of the file. (according to its extension)
	'----------------------
	blnBinary=GetContentType(strFileName, strContentType)
	strAllFile=""
	
	'----------------------
	'forth step: read the file contents.
	'----------------------
	'force download? if so, add proper header:
	If blnForceDownload Then
		strForce =  "attachment; filename="&strFileName
	else
		strForce =  "filename="&strFileName
	End If	
	
	If blnBinary Then
		Set objStream=Server.CreateObject("ADODB.Stream")
		
		'Added to breakup chunk
		Response.Buffer = False 
		
		'this might be long...
		Server.ScriptTimeout = 30000
		
		'----------------------
		objStream.Open
		objStream.Type = 1 'adTypeBinary
		objStream.LoadFromFile strFilePath
		
		'Added to breakup chunk
		iSz = objStream.Size
		Response.AddHeader "Content-Length", iSz
		Response.AddHeader "Content-Disposition", strForce
		Response.Charset = "UTF-8"
		Response.ContentType = strContentType
		For i = 1 To iSz \ chunkSize
			If Not Response.IsClientConnected Then Exit For
			Response.BinaryWrite objStream.Read(chunkSize)
		Next 
		If iSz Mod chunkSize > 0 Then 
			If Response.IsClientConnected Then 
				Response.BinaryWrite objStream.Read(iSz Mod chunkSize)
			End If 
		End If
  		objStream.Close
		Set objStream = Nothing		
		'--------------------------------------
		'Commented out Original Code
		'strAllFile=objStream.Read(fileSize)
		'objStream.Close
		'Set objStream = Nothing
		'--------------------------------------
	Else  
		Set objFile=fso.OpenTextFile(strFilePath,1) 'forReading
		If Not(objFile.AtEndOfStream) Then
			strAllFile=objFile.ReadAll
		End If
		objFile.Close
		Set objFile=Nothing
		Response.Write(strAllFile)
	End If
	
	'clean up:
	Set fso=Nothing
	Response.Flush
End Sub

Function GetContentType(ByVal strName, ByRef ContentType)
	'return whether binary or not, put type into second parameter
	Dim strExtension
	strExtension="."&GetExtension(strName)
	Select Case strExtension
		Case ".asf"
			ContentType = "video/x-ms-asf"
			GetContentType=True
		Case ".avi"
			ContentType = "video/avi"
			GetContentType=True
		Case ".doc"
			ContentType = "application/msword"
			GetContentType=True
		Case ".zip"
			ContentType = "application/zip"
			GetContentType=True
		Case ".xls"
			ContentType = "application/vnd.ms-excel"
			GetContentType=True
		Case ".gif"
			ContentType = "image/gif"
			GetContentType=True
		Case ".jpg", ".jpeg"
			ContentType = "image/jpeg"
			GetContentType=True
		Case ".wav"
			ContentType = "audio/wav"
			GetContentType=True
		Case ".mp3"
			ContentType = "audio/mpeg3"
			GetContentType=True
		Case ".wma" 
			ContentType = "audio/wma"
			GetContentType=True
		Case ".mpg", ".mpeg"
			ContentType = "video/mpeg"
			GetContentType=True
		Case ".pdf"
			ContentType = "application/pdf"
			GetContentType=True
		Case ".rtf"
			ContentType = "application/rtf"
			GetContentType=True
		Case ".htm", ".html"
			ContentType = "text/html"
			GetContentType=False
		Case ".asp"
			ContentType = "text/asp"
			GetContentType=False
		Case ".txt"
			ContentType = "text/plain"
			GetContentType=False
		Case Else
			'Handle All Other Files
			ContentType = "application/octet-stream"
			GetContentType=True
	End Select
End Function

Function GetExtension(strName)
	Dim arrTmp
	arrTmp=Split(strName, ".")
	GetExtension=arrTmp(UBound(arrTmp))
End Function
%>