<!-- #include virtual="/public/demo/common/include/Objects/DBManagerClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/LanguageClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/ConfigClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/objPageCache.asp"-->
<!-- #include virtual="/public/demo/common/include/Objects/UTF8Filer.asp" -->
<!-- #include virtual="/public/demo/editor/include/InitData.inc" -->

<%
Dim publicDirVar, publicReloadDirVar, installFormPageVar, installResultPageVar, globalQueryFile, nemesiConfigFile

'************************************************************************************************************************************************************
'	LA VARIABILE SEGUENTE RAPPRESENTA L'UNICO PERCORSO FISICO CABLATO NELL'APPLICAZIONE;

'	SE LA DIRECTORY CON PERMESSO DI SCRITTURA MESSA A DISPOSIZIONE DAL VOSTRO PROVIDER FOSSE DIVERSA DA QUELLA PREFISSATA: "/public/*"
'	PRIMA DI AVVIARE LA PROCEDURA DI ISTALLAZIONE:
'	- MODIFICARE IL VALORE DELLA VARIABILE "publicDirVar" INDICANDO IL NUOVO PERCORSO
'	- SPOSTARE TUTTO IL CONTENUTO DELLA DIRECTORY /public/* DENTRO LA NUOVA DIRECTORY SCRIVIBILE;

'	UNA VOLTA GENERATO IL DATABASE TRAMITE LA PROCEDURA DI INSTALL, MODIFICARE DALLA CONSOLE DI AMMINISTRAZIONE IL CONF_VALUE DELLE KEYWORD:
'	dir_editor_upload;
'	dir_upload_news;
'	dir_upload_prod;
'	dir_upload_templ;
'	INDICANDO LA NUOVA DIRECTORY SCRIVIBILE PRINCIPALE, AL POSTO DI /public/*

publicDirVar = Application("demo_baseroot") & "/public"

'************************************************************************************************************************************************************

publicReloadDirVar = publicDirVar&"/install/"
installFormPageVar = publicReloadDirVar & "demoreload.asp"
globalQueryFile = publicReloadDirVar&"global_reload_query_demo.sql"
nemesiConfigFile = publicDirVar & "/conf/nemesi_config.xml"


On Error Resume Next	
Dim objConfig, strDbConnVar, installDirVar, strLineDbQuery, objFSO, queryFile, configFile, allAppVar

'************* CREO LA NUOVA STRINGA DI CONNESSIONE CON I DATI FORNITI DALL'UTENTE
strDbConnVar ="driver={MySQL ODBC 3.51 Driver};uid=Sql198279;pwd=a34d7876;database=Sql198279_2;Server=62.149.150.77;port=3306"

'************* IMPOSTO L'OGGETTO objConn CON LA NUOVA STRINGA DI CONNESSIONE
Set objConn = Server.CreateObject("ADODB.Connection")
objConn.ConnectionString = strDbConnVar	

'************* RECUPERO TUTTE LE QUERY NECESSARIE PER VALORIZZARE IL DATABASE E LE LANCIO IN SEQUENZA
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")

strLineDbQuery = ""
'Set queryFile=objFSO.OpenTextFile(Server.MapPath(globalQueryFile), 1)	

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
	
'queryFile.Close
'Set queryFile=Nothing

'************* CONFIGURO TUTTE LE VARIABILI APPLICATION NECESSARIE AL FUNZIONAMENTO DEL PORTALE
Application("demo_srt_dbconn") = strDbConnVar
Application("demo_srt_default_server_name") = Request.ServerVariables("SERVER_NAME")
Set objConfig = New ConfigClass	
call objConfig.updateConfigValue("srt_dbconn", strDbConnVar) 
call objConfig.updateConfigValue("srt_default_server_name", Request.ServerVariables("SERVER_NAME")) 		
call objConfig.setAllApplicationVariables()
Set allAppVar = objConfig.getListaConfig()
Set objConfig = nothing

'************* CREO UN NUOVO FILE nemesi_config.xml dove inserisco tutte le variabili di configurazione dell'applicazione, da recuperare quando necessario
Set configFile=objFSO.OpenTextFile(Server.MapPath(nemesiConfigFile), 2, True)
configFile.writeLine("<config>")		
for each x in allAppVar
	Set objConf = allAppVar(x)
	configFile.writeLine("<"&objConf.getKey()&" attr_"&objConf.getKey()&"="""&objConf.getValue()&"""></"&objConf.getKey()&">")
	Set objConf = nothing
next		
configFile.writeLine("</config>")	
configFile.Close
Set configFile=Nothing
Set allAppVar = nothing	
Set objFSO = nothing

'************* IMPOSTO L'OGGETTO Application("demo_objConn") CON L'OGGETTO objConn
Set Application("demo_objConn") = objConn

If Err.Number<>0 then
	response.Write(Err.description&"<br/><br/>")
end if
%>
