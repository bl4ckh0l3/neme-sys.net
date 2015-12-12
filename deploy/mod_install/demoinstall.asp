<!-- #include virtual="/public/demo/common/include/Objects/DBManagerClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/LanguageClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/ConfigClass.asp" -->
<!-- #include virtual="/public/demo/common/include/Objects/objPageCache.asp"-->
<!-- #include virtual="/public/demo/common/include/Objects/UTF8Filer.asp" -->
<!-- include virtual="/public/demo/editor/include/InitData.inc" -->

<%
Dim publicDirVar, publicInstallDirVar, installFormPageVar, installResultPageVar, globalQueryFile, nemesiConfigFile

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

publicInstallDirVar = publicDirVar&"/install/"
installFormPageVar = publicInstallDirVar & "demoinstall.asp"
installResultPageVar = "/installed.asp"
globalQueryFile = publicInstallDirVar&"global_install_query_demo.sql"
nemesiConfigFile = publicDirVar & "/conf/nemesi_config.xml"

if(request("apply") = "true") then	
	On Error Resume Next	
	Dim objConfig, strDbConnVar, installDirVar, strLineDbQuery, objFSO, queryFile, configFile, allAppVar
	
	'************* CREO LA NUOVA STRINGA DI CONNESSIONE CON I DATI FORNITI DALL'UTENTE
	strDbConnVar ="driver={MySQL ODBC "&request("drivernumber")&" Driver};uid="&request("dbuser")&";pwd="&request("dbpassword")&";database="&request("dbname")&";Server="&request("servername")&";port="&request("serverport")

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
	
	'************* CANCELLO LA DIRECTORY INSTALL E TUTTI I CONTENUTI PER EVITARE CHE VENGA REINIZIALIZZATO TUTTO IL PORTALE
	installDirVar = Server.MapPath(publicInstallDirVar)
	if (objFSO.FolderExists(installDirVar)) then
		objFSO.DeleteFolder(installDirVar)
	end if	
	
	Set objFSO = nothing
	
	'************* IMPOSTO L'OGGETTO Application("demo_objConn") CON L'OGGETTO objConn
	Set Application("demo_objConn") = objConn
	
	If Err.Number<>0 then
		response.Write(Err.description&"<br/><br/>")
	else			
		response.Redirect(installResultPageVar)
	end if
end if
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>install demo</title>
<meta name="autore" content="Testa Denis; email:blackhole01@gmail.com">
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=Application("demo_baseroot") & "/common/css/stile.css"%>" type="text/css">
<!-- #include virtual="/public/demo/common/include/initCommonJs.inc" -->
<script language="JavaScript">
function sendForm(){
	if(document.form_install.dbuser.value == ""){
		alert("valorizzare il nome utente!");
		return;
	}
	if(document.form_install.dbpassword.value == ""){
		alert("valorizzare la password!");
		return;
	}
	if(document.form_install.dbname.value == ""){
		alert("valorizzare il nome del database!");
		return;
	}
	if(document.form_install.servername.value == ""){
		alert("valorizzare il nome del server!");
		return;
	}
	if(document.form_install.serverport.value == ""){
		alert("valorizzare la porta del database(se nn si conosce lasciare la 3306 di default)!");
		return;
	}
	
	if(confirm("Verranno lanciate tutte le query per la creazione e la prima inizializzazione del nuovo database;\nconfermi avvio procedura?")){
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
			<div id="top-bar-logo"><a href="<%=Application("demo_baseroot")&"/default.asp"%>" style="color:#FFFFFF;text-decoration:none;">Home<!--<img src="<%'=Application("demo_baseroot")&"/common/img/logo.png"%>" width="133" height="38" hspace="2" vspace="0" border="0" align="left" alt="home page">--></a></div>
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
	  
		<form action="<%=Application("demo_baseroot") & installFormPageVar%>" method="post" name="form_install">
		<input type="hidden" name="apply" value="true">

		<h1>DB connection variables:</h1>
		
		<h3>DB user:</h3>
		<input name="dbuser" type="text" class="larghezza100" />
		
		<h3>DB password:</h3>
		<input name="dbpassword" type="text" class="larghezza100" />
		
		<h3>DB name:</h3>
		<input name="dbname" type="text" class="larghezza100" />
		
		<h3>Server name/IP:</h3>
		<input name="servername" type="text" value="localhost" class="larghezza100" />
		
		<h3>Server port:</h3>
		<input name="serverport" type="text" class="larghezza100" value="3306" />
		
		<h3>MySQL ODBC Driver Number:</h3>
		<select name="drivernumber" class="formFieldTXT">
		<option value="3.51">3.51</option>
		<option value="5.1">5.1</option>
		</select>

		<div id="loading" style="visibility:hidden;display:none;" align="center"><img src="<%=Application("demo_baseroot") & "/editor/img/loading.gif"%>" vspace="0" hspace="0" border="0" alt="Loading..." width="200" height="50"></div>
		
		<p align="center"><input type="button" value="INSERT" onclick="javascript:sendForm();"></p>	
		</form>	

		</div>
		<div id="menu-right"></div>
	</div>
	<div id="footer"><span>Powered by BHNet Online Technology Merchant Copyright © 2007-2009</span></div>
</div>
</body>
</html>
