<%
if (isEmpty(Session("objCMSUtenteLogged"))) then
	response.Redirect(Application("baseroot")&"/login.asp")
end if

Dim objUserLogged, objUserLoggedTmp, objListaTargetPerUser,numMaxImg, numMaxProd
Set objUserLoggedTmp = new UserClass
Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
Dim strRuoloLogged
strRuoloLogged = objUserLogged.getRuolo()
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) AND not(strComp(Cint(strRuoloLogged), Application("editor_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
if not(isNull(objUserLogged.getTargetPerUser(objUserLogged.getUserID()))) then
	Set objListaTargetPerUser = objUserLogged.getTargetPerUser(objUserLogged.getUserID())	
end if
Set objUserLoggedTmp = nothing
Set objUserLogged = nothing

numMaxImg = Application("num_max_attachments")
if(not(request("numMaxImgs") = "")) then
	numMaxImg = request("numMaxImgs")
end if

numMaxProd = 1
if(not(request("numMaxProds") = "")) then
	numMaxProd = request("numMaxProds")
end if
'/**
'* recupero i valori della news selezionata se id_prod <> -1
'*/
Dim id_prod, strCodProd, strNomeProd, strSommarioProd, strDescProd, numPrezzo, numQta, stato_prod 
DIm sconto_prod, objFilesProd, objTarget, objRelationsProd, id_tassa_applicata, prod_type, max_download, max_download_time 
Dim page_title, meta_description, meta_keyword, edit_buy_qta
id_prod = request("id_prodotto")

if(id_prod = "") then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=018")
end if

strCodProd = ""
strNomeProd = ""
strSommarioProd = ""
strDescProd = ""
numPrezzo = 0
numQta = Application("unlimited_key")
stato_prod = 0
sconto_prod = 0
objFilesProd = null
objTarget = null
objRelationsProd = null
id_tassa_applicata = null
taxs_group = null
prod_type = 0
max_download = -1
max_download_time = -1
page_title = ""
meta_description = ""
meta_keyword = ""
edit_buy_qta = 1

Dim objProd
Set objProd = New ProductsClass

if (CInt(id_prod) <> -1) then
	Dim objSelProd
	Set objSelProd = objProd.findProdottoByID(id_prod, 1)
	
	id_prod = objSelProd.getIDProdotto()
	strCodProd = objSelProd.getCodiceProd()
	strNomeProd = objSelProd.getNomeProdotto()
	strSommarioProd = objSelProd.getSommarioProdotto()
	strDescProd = objSelProd.getDescProdotto()
	numPrezzo = objSelProd.getPrezzo()
	numQta = objSelProd.getQtaDisp()
	stato_prod = objSelProd.getAttivo()
	sconto_prod = objSelProd.getSconto()
	id_tassa_applicata = objSelProd.getIDTassaApplicata()
	taxs_group = objSelProd.getTaxGroup()
	prod_type = objSelProd.getProdType()
	max_download = objSelProd.getMaxDownload()
	max_download_time = objSelProd.getMaxDownloadTime()
	page_title = objSelProd.getPageTitle()
	meta_description = objSelProd.getMetaDescription()
	meta_keyword = objSelProd.getMetaKeyword()
	edit_buy_qta = objSelProd.getEditBuyQta()
	

	On Error Resume Next
	Set objRelationsProd = objSelProd.getRelationPerProdotto(id_prod)	
	If(Err.number <> 0) then
		objRelationsProd = null
	end if	

	On Error Resume Next
	Set objTarget = objSelProd.getListaTarget()
	If(Err.number <> 0) then
		objTarget = null
	end if	
	
	On Error Resume Next
	Set objFilesProd = objSelProd.getFileXProdotto()	
	If(Err.number <> 0) then
		objFilesProd = null
	end if	

	Set objSelProd = Nothing	
end if


'*** RECUPERO LA TIPOLOGIA DI QUANTITA' PER PRODOTTO SE MODIFICATA
if(request("change_num_qta") <> "") then
	numQta = request("change_num_qta")
	if(CInt(id_prod) = -1 AND request("change_num_qta")="0")then
		numQta = ""
	end if
end if


'********** RECUPERO LA LISTA DI FIELD PRODOTTI ASSOCIATI AL PRODOTTO
Dim objProdField, objListProdField, hasProdFields
hasProdFields=false
On Error Resume Next
Set objProdField = new ProductFieldClass
Set objListProdField = objProdField.getListProductField4Prod(id_prod)
if(objListProdField.count > 0)then
	hasProdFields=true
end if
if(Err.number <> 0) then
	hasProdFields=false
end if


if(not(request("prod_type") = "")) then
	prod_type = request("prod_type")
end if
%>