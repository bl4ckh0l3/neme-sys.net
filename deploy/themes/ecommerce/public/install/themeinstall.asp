<!-- #include virtual="/common/include/Objects/DBManagerClass.asp" -->
<!-- #include virtual="/common/include/Objects/LanguageClass.asp" -->
<!-- #include virtual="/common/include/Objects/ConfigClass.asp" -->
<!-- #include virtual="/common/include/Objects/UTF8Filer.asp" -->
<%
Dim publicDirVar, publicInstallDirVar, installFormPageVar, installResultPageVar, globalQueryFile

'************************************************************************************************************************************************************
'	LA VARIABILE SEGUENTE RAPPRESENTA L'UNICO PERCORSO FISICO CABLATO NELL'APPLICAZIONE;

'	SE LA DIRECTORY CON PERMESSO DI SCRITTURA MESSA A DISPOSIZIONE DAL VOSTRO PROVIDER FOSSE DIVERSA DA QUELLA PREFISSATA: "/public/*"
'	PRIMA DI AVVIARE LA PROCEDURA DI ISTALLAZIONE:
'	- MODIFICARE IL VALORE DELLA VARIABILE "publicDirVar" INDICANDO IL NUOVO PERCORSO
'	- SPOSTARE TUTTO IL CONTENUTO DELLA DIRECTORY /public/* DENTRO LA NUOVA DIRECTORY SCRIVIBILE;

publicDirVar = "/public"

'************************************************************************************************************************************************************

publicInstallDirVar = publicDirVar&"/install/"
installFormPageVar = publicInstallDirVar & "themeinstall.asp"
installResultPageVar = "/installed.asp"
globalQueryFile = publicInstallDirVar&"theme_install_query.sql"

if(request("apply") = "true") then	
	On Error Resume Next	
	Dim objConfig, strDbConnVar, installDirVar, strLineDbQuery, objFSO, queryFile, configFile, allAppVar
	
	'************* CREO LA NUOVA STRINGA DI CONNESSIONE CON I DATI FORNITI DALL'UTENTE
	strDbConnVar = Application("srt_dbconn")

	'************* IMPOSTO L'OGGETTO objConn CON LA NUOVA STRINGA DI CONNESSIONE
	Set objConn = Server.CreateObject("ADODB.Connection")
	objConn.ConnectionString = strDbConnVar	

	'************* RECUPERO TUTTE LE QUERY NECESSARIE PER VALORIZZARE IL DATABASE E LE LANCIO IN SEQUENZA	
	Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
	'Set queryFile=objFSO.OpenTextFile(Server.MapPath(globalQueryFile), 1)		
	strLineDbQuery = ""
	
	Set MyUTF8File = New UTF8Filer
	MyUTF8File.UnicodeCharset = "UTF-8"
	if (MyUTF8File.LoadFile(Server.MapPath(globalQueryFile))) then
		MyUTF8File.cTextBuffer2Unicode
		objConn.Open()	
		do while MyUTF8File.EOF = false
		strLineDbQuery = MyUTF8File.ReadLine
		objConn.Execute(strLineDbQuery)
		loop
		objConn.close()		
	end if
	set MyUTF8File = nothing

	'************* AGGIUNGO A TUTTI I FILE DEI TEMPLATE LE COPIE PER LE LINGUE ATTIVE SUL SITO	
	Set objDict = Server.CreateObject("Scripting.Dictionary") 
	objDict.add "ads-content_bhn","" 
	objDict.add "base-list-img_bhn",""
	objDict.add "base-social_bhn",""
	objDict.add "contact_bhn",""
	objDict.add "download_bhn",""
	objDict.add "googlemap-content_bhn",""
	objDict.add "googlemap-product_bhn",""
	objDict.add "newsletter",""
	objDict.add "products_bhn",""
	objDict.add "search",""
	objDict.add "shopping-card",""
	objDict.add "voucher-module_bhn",""
	objDict.add "voucher-module-friend_bhn",""

	Set objSelLanguage = New LanguageClass
	Set objLangList = objSelLanguage.getListaLanguage()
	Set objSelLanguage = nothing
	
	uploadsDirVar = Application("baseroot")&Application("dir_upload_templ")	
	uploadsDirVar = Server.MapPath(uploadsDirVar)	

	for each x in objDict
		uploadsDirVarAsp = uploadsDirVar & "\" & x &"\"
		uploadsDirVarIncludes =  uploadsDirVarAsp &"include\"

		For Each lang In objLangList
			if not(objFSO.FolderExists(uploadsDirVarAsp&Ucase(objLangList(lang).getLanguageDescrizione()) & "\")) then
				objFSO.CreateFolder(uploadsDirVarAsp&Ucase(objLangList(lang).getLanguageDescrizione()) & "\")
				if (objFSO.FolderExists(uploadsDirVarIncludes)) then
					objFSO.CreateFolder(uploadsDirVarAsp&Ucase(objLangList(lang).getLanguageDescrizione()) & "\include\")
				end if
			end if
			
			objFSO.CopyFile uploadsDirVarAsp&"*.*", uploadsDirVarAsp&Ucase(objLangList(lang).getLanguageDescrizione()) & "\"
			if (objFSO.FolderExists(uploadsDirVarIncludes)) then
				objFSO.CopyFile uploadsDirVarIncludes&"*.*", uploadsDirVarAsp&Ucase(objLangList(lang).getLanguageDescrizione()) & "\include\"
			end if
		Next	
	Next	
	Set objLangList = nothing
	Set objDict = nothing
	
	' aggiorno tutti i file di progetto legati ai moduli
	Set objDictModule = Server.CreateObject("Scripting.Dictionary")  
	Set objDictModuleKV = Server.CreateObject("Scripting.Dictionary")    

	objConn.Open()
	strSQLModule = "SELECT * FROM module_portal ORDER BY date_insert ASC;"
	Set objRS = objConn.Execute(strSQLModule)
	if not(objRS.EOF) then  
		do while not objRS.EOF
			Set objModule = Server.CreateObject("Scripting.Dictionary") 
			strID = objRS("keyword")
			objModule.add "descrizione", objRS("descrizione")
			objModule.add "version", objRS("version")
			objModule.add "active", objRS("active")
			objModule.add "date_insert", objRS("date_insert")
			
			'response.write("<br><br>keyword:"&strID&"<br>")
			'response.write("descrizione:"&objModule("descrizione")&"<br>")
			'response.write("version:"&objModule("version")&"<br>")
			'response.write("active:"&objModule("active")&"<br>")
			'response.write("date_insert:"&objModule("date_insert")&"<br>")
			
			objDictModule.add strID, objModule
			Set objModule = Nothing
			objRS.moveNext()
		loop  
	end if
	Set objRS = nothing
	objConn.close()

	for each x in objDictModule
		'Response.write("module name: "&x& "<br />")
		'response.write("Server.MapPath: "&Server.MapPath("/public/install/"&x&"_replace.properties")&"<br>")	
		if objFSO.FileExists(Server.MapPath("/public/install/"&x&"_replace.properties")) Then
			set File = objFSO.GetFile(Server.MapPath("/public/install/"&x&"_replace.properties"))
			Set objModuleKV = Server.CreateObject("Scripting.Dictionary") 
			' Open the file			
			Set configFile=objFSO.OpenTextFile(file.path, 1, false)
			do while configFile.AtEndOfStream = false
			Line = configFile.readline
			Line = Replace(Line, vbCrLf, "")
			'Response.write "Line: "&Line&"<br>"
			if(Trim(Line)<>"")then
				' Do something with "Line"
				key = Left(Line, InStr(1,Line,"=",1)-1)
				value = Right(Line,(Len(Line)-InStr(1,Line,"=",1)))
				'Response.write "key:"&key&"; - value:"&value&";<br>"
				objModuleKV.add key, value		
			end if	
			loop
			configFile.Close
			Set configFile=Nothing	
			set File = nothing		
			objDictModuleKV.add x, objModuleKV	
			Set objModuleKV = nothing	
		else
			'response.write("file not exists: "&"/public/install/"&x&"_replace.properties")			
		End If				
	next


	set objFO=objFSO.GetFolder(Server.MapPath(Application("baseroot")&"/public/layout"))
	ricorsiveFolder(objFO)
	set objFO=objFSO.GetFolder(Server.MapPath(Application("baseroot")&"/public/modules"))
	ricorsiveFolder(objFO)
	set objFO=nothing
	
	Set objDictModuleKV = nothing
	Set objDictModule = nothing
	
	'************* CANCELLO LA DIRECTORY INSTALL E TUTTI I CONTENUTI PER EVITARE CHE VENGA REINIZIALIZZATO TUTTO IL PORTALE
	installDirVar = Server.MapPath(publicInstallDirVar)
	if (objFSO.FolderExists(installDirVar)) then
		call objFSO.DeleteFile(installDirVar&"\themeinstall.asp",true)
		call objFSO.DeleteFile(installDirVar&"\theme_install_query.sql",true)
	end if	
	
	Set objFSO = nothing
	
	If Err.Number<>0 then
		response.write("page themeinstall error: "&Err.description&"<br/><br/>")
	else			
		response.Redirect(installResultPageVar)
	end if
end if


Public Sub checkModuleTag(objFl)
	Set fs=Server.CreateObject("Scripting.FileSystemObject") 
	Set objTextStream = fs.OpenTextFile(objFl.Path,1)
	content=  objTextStream.ReadAll
	'Response.write("content: <pre>"&content& "</pre><br />")
	objTextStream.Close
	Set objTextStream = Nothing
	bolSaveFile = false
	
	
	'Set MyUTF8File = New UTF8Filer
	'MyUTF8File.UnicodeCharset = "UTF-8"
	'if (MyUTF8File.LoadFile(objFl.Path)) then	
		On Error Resume Next
		'Response.write("objFl.Path: "&objFl.Path& "<br />")
		'MyUTF8File.cTextBuffer2Unicode		
		'content = MyUTF8File.TextBuffer
		'Response.write("content: <pre>"&MyUTF8File.TextBuffer& "</pre><br />")
		'*** faccio il parsing del file per ogni modulo istallato
		for each x in objDictModuleKV
			'Response.write("module name: "&x& "<br />")
			for each y in objDictModuleKV(x)
				'Response.write("key: "&y&" - value: "&objDictModuleKV(x)(y)& "<br />")
				' fare il parsing dei tag in base al modulo e al tipo di tag
				if (Instr(1, content, "'<!--"&y, 1) > 0) then  
					'Response.write("found tag '&lt;!--"&y& "<br />")
					'Response.write(" - content before: "&content&"<br /><br /><br />")
					bolSaveFile = true
					startRepl = Left(content,Instr(1, content, "'<!--"&y&"-->", 1)+Len(y)+11)
					endRepl = Right(content,Len(content)-Instr(1, content, "'<!---"&y&"-->", 1)+1)
					content = startRepl&objDictModuleKV(x)(y)&endRepl
				elseif (Instr(1, content, "/*<!--"&y, 1) > 0) then  
					'Response.write("found tag /*&lt;!--"&y& "<br />")	
					'Response.write(" - content before: "&content&"<br /><br /><br />")	
					bolSaveFile = true
					startRepl = Left(content,Instr(1, content, "/*<!--"&y&"-->*/", 1)+Len(y)+11)
					endRepl = Right(content,Len(content)-Instr(1, content, "/*<!---"&y&"-->*/", 1)+1)
					content = startRepl&objDictModuleKV(x)(y)&endRepl			
				elseif (Instr(1, content, "<!--"&y, 1) > 0) then  
					'Response.write("found tag &lt;!--"&y& "<br />")
					'Response.write(" - content before: "&content&"<br /><br /><br />")
					bolSaveFile = true
					startRepl = Left(content,Instr(1, content, "<!--"&y&"-->", 1)+Len(y)+11)
					endRepl = Right(content,Len(content)-Instr(1, content, "<!---"&y&"-->", 1)+1)
					content = startRepl&objDictModuleKV(x)(y)&endRepl				
				end if
			next				
		next

		if(bolSaveFile)then
			'response.write("method checkModulesave file before<br/><br/>")
			Set objTextStream = fs.OpenTextFile(objFl.Path,2)
			'response.write("typename(objTextStream):"&typename(objTextStream)&"<br>")
			objTextStream.write(content)
			objTextStream.Close
			Set objTextStream = Nothing
			'response.write("method checkModulesave file after<br/><br/>")
		end if

		'MyUTF8File.TextBuffer=content
		'if not MyUTF8File.SaveFile(objFl.Path) then
		'	'The filenames are stored here during the open process
		'	Response.Write(MyUTF8File.AbsoluteFileName & " (" & MyUTF8File.VirtualFileName & ")<br>")
		'	Response.Write(MyUTF8File.ErrorText & "<br>")
		'end if
		if(Err.number<>0)then
			response.write("method checkModuleTag error: "&Err.description&"<br/><br/>")
		end if
	'end if	
	'Set MyUTF8File = nothing
	Set fs=nothing
	'response.end	
End Sub

Public Sub ricorsiveFolder(objF)
	'Response.write("<b>Curr fold Name:</b> "&objF.Name & "<b> - Path:</b> "&objF.Path&"<br />")
	On Error Resume Next
	for each y in objF.files
		'Response.write("<b>Filter Name:</b> "&Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1)))&"<br />")
		if("asp"=Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1))) OR "inc"=Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1))) OR "css"=Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1))) OR "js"=Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1))) OR "xml"=Right(y.Name,(Len(y.Name)-InStrRev(y.Name,".",-1,1))))then
			'Response.write(y.Name & "<br />")
			checkModuleTag(y)
		end if
	next	
	if(objF.SubFolders.count>0)then
		for each x in objF.SubFolders
			ricorsiveFolder(x)
		next
	end if
	if(Err.number<>0)then
		response.write("method ricorsiveFolder error: "&Err.description&"<br/><br/>")
	end if
End Sub
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>install page</title>
<meta name="autore" content="Neme-sys; email:info@neme-sys.org">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<link rel="stylesheet" href="<%=Application("baseroot") & "/public/layout/css/stile.css"%>" type="text/css">
<!-- #include virtual="/common/include/initCommonJs.inc" -->
<script language="JavaScript">
function sendForm(){	
	if(confirm("Verranno lanciate tutte le query per l'inserimento dei nuovi dati su database;\nconfermi avvio procedura? \n\n All query will execute on database; confirm procedure?")){
		document.getElementById("loading").style.visibility = "visible";
		document.getElementById("loading").style.display = "block";
		document.form_install.submit();
	}else{
		return;
	}
}
</script>
</head>
<body>
<div id="warp">

	<div id="header">
		<div id="top-bar">
			<div id="top-bar-logo"><a href="<%=Application("baseroot")&"/default.asp"%>">Home<!--<img src="<%=Application("baseroot")&"/common/img/logo.png"%>" width="133" height="38" hspace="2" vspace="0" border="0" align="left" alt="home page">--></a></div>
			<div id="top-bar-search"></div>
			<div id="top-bar-lenguage">
				<ul>
				<li></li>
				</ul>
			</div>
		</div>
		<div id="image-container"></div>
	</div>
	<div id="container">    	
		<div id="menu-left"></div>
		<div id="content-center">
	  
		<form action="<%=Application("baseroot") & installFormPageVar%>" method="post" name="form_install">
		<input type="hidden" name="apply" value="true">

		<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="<%=Application("baseroot") & "/editor/img/loading.gif"%>" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>

		<p align="center"><input type="button" value="ACTIVATE THEME" onclick="javascript:sendForm();"></p>	
		</form>	

		</div>
		<div id="menu-right"></div>
	</div>
	<div id="footer"><span>Powered by BHN Online Technology Merchant Copyright &copy; 2007-2012</span></div>
</div>
</body>
</html>
