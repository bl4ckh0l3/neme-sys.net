<%@ Language=VBScript %>
<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	On error resume next
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
	Dim id_order, stato_order, order_by, items, page
	
	id_order = request("id_order")
	order_by = request("order_by")
	items = request("items")
	page = request("page")
	search_ordini = request("search_ordini")
					
	Dim objOrder, objSelOrder, objPaymentTrans, objUtilTmp, objPayment, objCurrPayment, objTargetTrans, id_ads
	Set objOrder = New OrderClass
	Set objSelOrder = objOrder.findOrdineByID(id_order, 0)
	Set objPaymentTrans = new PaymentTransactionClass
	Set objUtilTmp = new UtilClass
	Set objPayment = new PaymentClass
	Set objCurrPayment = objPayment.findPaymentByID(objSelOrder.getTipoPagam())
	Set objTargetTrans = objPaymentTrans.findPaymentTransactionByIDTransactionToNotify(id_order)
	
	Set objDB = New DBManagerClass
	Set objConn = objDB.openConnection()
	objConn.BeginTrans
	call objSelOrder.changePagamDoneOrder(id_order, 1, objConn)
	call objPaymentTrans.modifyPaymentTransaction(objTargetTrans.getID(), id_order, objCurrPayment.getPaymentModuleID(), objTargetTrans.getIdTransaction(), objUtilTmp.getUniqueKeySuccessPaymentTransaction(), 1, objConn)
	
	id_ads = objSelOrder.getIdAdRef()
	'*** Se il pagamento e'  andato a buon fine verifico se nella lista prodotti ci sono degli annunci a pagamento e imposto activate a true e la data di attivazione alla data corrente			
	On Error Resume Next
	if(id_ads<>"")then
		Set objAds = new AdsClass
		Set objP4O = new Products4OrderClass
		Set objProdList = objP4O.getListaProdottiXOrdine(id_order)
		for each j in objProdList
			'response.write("id_ads: "&id_ads&" - objProdList(j).getIDProdotto(): "&objProdList(j).getIDProdotto()&" - objProdList(j).getProdType(): "&objProdList(j).getProdType()&"<br>")
			if(objProdList(j).getProdType()=2)then
				call objAds.activateAdsPromotion(id_ads, objProdList(j).getIDProdotto(), objConn)
			end if		
		next			
		Set objProdList = nothing
		Set objP4O = nothing
		Set objAds = nothing
	end if
	If Err.Number<>0 then
		'response.write(Err.description)
	end if	
	
	if objConn.Errors.Count = 0 then
		objConn.CommitTrans
	else
		objConn.RollBackTrans
	end if			
	Set objDB = nothing	
			
	Set objTargetTrans = nothing
	Set objCurrPayment = nothing
	Set objPayment = nothing
	Set objUtilTmp = nothing
	Set objPaymentTrans = nothing
	Set objSelOrder = nothing
	Set objOrder = nothing
	Set objUserLogged = nothing
	response.Redirect(Application("baseroot")&"/editor/ordini/ListaOrdini.asp?order_by="&order_by&"&items="&items&"&page="&page&"&search_ordini="&search_ordini)				


	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>