<%Response.Buffer=True %>
<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/objects/DownloadedFilesClass.asp" -->
<%
Dim id_allegato, name_allegato, type_allegato, path_allegato, dida_allegato, content_type_allegato, objFiles, objSelectedFile, idUserLogged
id_allegato = request("id_allegato")
Set objFiles = new File4NewsClass
Set objSelectedFile = objFiles.getFileByID(id_allegato)
Set objFiles = nothing

'*** RECUPERO id utente se in sessione da inserire nella tabella downloaded_files
idUserLogged = Session("objUtenteLogged")

name_allegato = objSelectedFile.getFileName()
type_allegato = objSelectedFile.getFileTypeLabel()
path_allegato = Application("baseroot")&Application("dir_upload_news")&objSelectedFile.getFilePath()
dida_allegato = objSelectedFile.getFileDida()
content_type_allegato= objSelectedFile.getFileType()

'*** RECUPERO USER HOST E USER INFO
Dim userHost, userInfo
userHost = request.ServerVariables("REMOTE_ADDR")
if(userHost="") then
	userHost = request.ServerVariables("REMOTE_HOST")
end if
userInfo = request.ServerVariables("HTTP_USER_AGENT")


Const adTypeBinary = 1
Const adTypeText = 2
Const chunkSize = 2048

'global variables:
Dim forceDownload 'force the download or allow the file to be opebed in the browser?

'force download?
forceDownload = (Request("force")="1")


'**** INSERISCO NUOVO RECORD DENTRO TABELLA DOWNLOADED_FILES
Dim objDownFile 
Set objDownFile = new DownloadedFilesClass
call objDownFile.insertDownFileNoTransaction(id_allegato, idUserLogged, userHost, userInfo, name_allegato, content_type_allegato, path_allegato, now())
Set objDownFile = nothing

'**** RICHIAMO IL METODO PER IL DOWNLOAD DEL FILE
Call DownloadFile (Server.MapPath(path_allegato), name_allegato, forceDownload)


Sub DownloadFile(strFilePath, strFileName, blnForceDownload)
	'local variables:
	Dim fso, objFile
	Dim fileSize, blnBinary, strContentType
	Dim objStream, strAllFile, iSz
	Dim i
	Dim strForce
	
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
	    	'Response.AddHeader "Content-Disposition", "attachment; filename="&strFileName
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
		'Response.AddHeader "Content-Length", iSz
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


Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=lang.getTranslated("frontend.page.title")%></title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
</head>
<body>
	<div id="container">	
		<div id="content-popup">
		<%=lang.getTranslated("frontend.popup.label.download_selected_file")%>: <%=name_allegato%>
		<div align="center" style="padding-top:30px;">	
		<a href="javascript:window.close();" class="vociMenuFruizione"><%=lang.getTranslated("frontend.popup.label.close_window")%></a></div>
		</div>
	</div>
</body>
</html>