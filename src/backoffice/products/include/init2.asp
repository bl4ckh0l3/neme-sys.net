<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUserLogged, objUserLoggedTmp
Set objUserLoggedTmp = new UserClass
Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
Set objUserLoggedTmp = nothing
Dim strRuoloLogged
strRuoloLogged = objUserLogged.getRuolo()
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

'/**
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_prod, strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod, sconto_prod, objProd, objTarget, id_tassa_applicata, taxs_group
Dim prod_type, max_download, max_download_time
Dim page_title, meta_description, meta_keyword, edit_buy_qta, strGeolocal
id_prod = request("id_prodotto")
strCodProd = ""
strNomeProd = ""
strSommarioProd = ""
strDescProd = ""
numPrezzo = 0
numQta = 0
stato_prod = 0
sconto_prod = 0
objProd = null
objTarget = null
id_tassa_applicata = null
taxs_group = null
prod_type = 0
max_download = -1
max_download_time = -1
page_title = ""
meta_description = ""
meta_keyword = ""
edit_buy_qta = 0
strGeolocal = ""

if not (isNull(id_prod)) then
	Dim objProdotti, objSelProdotti
	Set objProdotti = New ProductsClass
	Set objSelProdotti = objProdotti.findProdottoByID(id_prod, 1)
	Set objProdotti = nothing
	
	id_prod = objSelProdotti.getIDProdotto()
	strCodProd = objSelProdotti.getCodiceProd()
	strNomeProd = objSelProdotti.getNomeProdotto()
	strSommarioProd = objSelProdotti.getSommarioProdotto()
	strDescProd = objSelProdotti.getDescProdotto()
	numPrezzo = objSelProdotti.getPrezzo()
	numQta = objSelProdotti.getQtaDisp()	
	stato_prod = objSelProdotti.getAttivo()
	sconto_prod = objSelProdotti.getSconto()
	id_tassa_applicata = objSelProdotti.getIDTassaApplicata()
	taxs_group = objSelProdotti.getTaxGroup()
	prod_type = objSelProdotti.getProdType()
	max_download = objSelProdotti.getMaxDownload()
	max_download_time = objSelProdotti.getMaxDownloadTime()
	page_title = objSelProdotti.getPageTitle()
	meta_description = objSelProdotti.getMetaDescription()
	meta_keyword = objSelProdotti.getMetaKeyword()
	edit_buy_qta = objSelProdotti.getEditBuyQta()
	
	On Error Resume Next
	Set objRelationsProd = objSelProdotti.getRelationPerProdotto(id_prod)	
	If(Err.number <> 0) then
		objRelationsProd = null
	end if
	
	On Error Resume Next
	Set objTarget = objSelProdotti.getListaTarget()	
	If(Err.number <> 0) then
		objTarget = null
	end if
	
	On Error Resume Next
	Set objProd = objSelProdotti.getFileXProdotto()	
	If(Err.number <> 0) then
		objProd = null
	end if	

	'********** RECUPERO LA LISTA DI FIELD PRODOTTI ASSOCIATI AL PRODOTTO
	Dim objProdField, objListProdField, hasProdFields
	hasProdFields=false
	On Error Resume Next
	Set objProdField = new ProductFieldClass
	Set objListProdField = objProdField.getListProductField4ProdActive(id_prod)
	if(objListProdField.count > 0)then
		hasProdFields=true
	end if
	if(Err.number <> 0) then
		hasProdFields=false
	end if

	'********** RECUPERO LA LISTA DI POINTS GOOGLEMAP ASSOCIATI AL PRODOTTO
	Dim objLocal
	Set objLocal = new LocalizationClass
	On error resume next
	Set points = objLocal.findPointByElement(id_prod, 2)
	if not(isNull(points)) then
		for each xLocal in points.Items
			strGeolocal = strGeolocal & langEditor.getTranslated("backend.commons.detail.table.label.latitude") & ", "&langEditor.getTranslated("backend.commons.detail.table.label.longitude")&": "&xLocal.getLatitude()&", "&xLocal.getLongitude()&"<br/>"
		next
	end if
	Set points = nothing	
	if(Err.number <> 0) then	
	end if	
	Set objLocal = nothing
else
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=004")			
end if
%>