<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/ProductFieldGroupClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductFieldClass.asp" -->

<%
On error resume next
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
	
	Dim objLogger
	Set objLogger = New LogClass
	
	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_prod	
	
	id_prod = request("id_prod_to_delete")
					
	Dim objProd
	Set objProd = New ProductsClass
	Set objField = New ProductFieldClass
	
	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans
	
	call objProd.deleteProdotto(id_prod,objConn)
	call objField.deleteFieldMatchByProd(id_prod, objConn)
	
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
	Set objField = nothing
	Set objProd = nothing
	
	call objLogger.write("cancellato prodotto --> id: "&id_prod, objUserLogged.getUserName(), "info")
	
	Set objUserLogged = nothing
	
	Set objLogger = nothing
	
	response.Redirect(Application("baseroot")&"/editor/prodotti/ListaProdotti.asp")				


	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>