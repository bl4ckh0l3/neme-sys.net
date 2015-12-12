<% 
Server.ScriptTimeout=3600 ' max value = 2147483647
Response.Expires=-1500
Response.Buffer = TRUE
Response.Clear
%>
<!-- #include virtual="/common/include/Objects/FileUploadClass.asp" -->
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->

<%
Dim objLogger
Set objLogger = New LogClass

Set Upload = New FileUploadClass
Upload.SaveField()

Dim id_prodotto
id_prodotto = Upload.Form("selected_prodotto")
'call objLogger.write("id_prodotto: "&id_prodotto, "system", "debug")

Set objFSO = Server.CreateObject("Scripting.FileSystemObject")							
uploadsDirVar = Application("dir_upload_prod")&"fields/"
uploadsDirVar = Server.MapPath(uploadsDirVar)
uploadsDirVar = uploadsDirVar & "\" & id_prodotto &"\"
'call objLogger.write("uploadsDirVar: "&uploadsDirVar, "system", "debug")
'call objLogger.write("typename(objFSO): "&typename(objFSO), "system", "debug")
'call objLogger.write("objFSO.FolderExists(uploadsDirVar): "& objFSO.FolderExists(uploadsDirVar), "system", "debug")
on Error Resume Next
if not(objFSO.FolderExists(uploadsDirVar)) then
	call objFSO.CreateFolder(uploadsDirVar)
	if not(objFSO.FolderExists(uploadsDirVar & Session.SessionID &"\")) then
		call objFSO.CreateFolder(uploadsDirVar & Session.SessionID &"\")
	end if
	'call objLogger.write("f.Path: "&f.Path, "system", "debug")
end if
if not(objFSO.FolderExists(uploadsDirVar & Session.SessionID &"\")) then
	call objFSO.CreateFolder(uploadsDirVar & Session.SessionID &"\")
end if
if(Err.number<>0)then
call objLogger.write("product field ajax upload file - Err.description: "&Err.description, "system", "error")
end if	
uploadsDirVar = uploadsDirVar & Session.SessionID &"\"
Set objFSO = nothing
call Upload.Save(uploadsDirVar)

Set objLogger = nothing
%>