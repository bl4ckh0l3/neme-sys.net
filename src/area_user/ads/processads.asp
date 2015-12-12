<%@Language=VBScript codepage=65001 %>
<% 
On error resume next 
Response.Charset="UTF-8"
Session.CodePage  = 65001
%>
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<%
if not(isEmpty(Session("objUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()	
	id_user = objUserLogged.getUserID()
	if not(strComp(Cint(strRuoloLogged), Application("guest_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_ads, id_element, id_utente, ads_type, price, phone, dta_ins, promotional
	Dim objDB, objConn
	
	redirectPage = Application("baseroot")&"/area_user/ads/ListaNews.asp"
	id_ads = request("id_ads")	
	id_element = request("id_element")	
	id_utente = request("id_utente")
	ads_type = request("ads_type")
	price = request("price")
	phone = request("phone")
	dta_ins = request("dta_ins")
	promotional = request("promotional")	
	arrPromotional = split(promotional, ",", -1, 1)
	'response.write("promotional: "&promotional&"<br>")
	'response.write("typename(arrPromotional): "&typename(arrPromotional)&"<br>")
	'response.write("ubound(arrPromotional): "&ubound(arrPromotional)&"<br>")
	'response.write("arrPromotional(0): "&arrPromotional(0)&"<br>")
	'response.end
					
	Dim objAds, objCarrelloUser, objProdPerCarr
	Set objAds = New AdsClass
	Set carrello = New CardClass
	Set objProdPerCarr = New ProductsCardClass
			
	Dim objLogger
	Set objLogger = New LogClass
	
	if (Cint(id_ads) <> -1) then
		'/**
		'* ads da mofificare
		'*/	
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans
		
		call objAds.modifyAds(id_ads, phone, ads_type, price, objConn)		
		call objLogger.write("modificato annuncio --> id: "&id_ads, objUserLogged.getUserName(), "info")

		'********* GESTISCO L'ACQUISTO DI PROMOZIONI ADS SE PRESENTI
		if(UBound(arrPromotional)>=0)then
			'call objLogger.write("promozione annunci", "system", "debug")		
			
			hasSessionIDCard = carrello.findCarrelloByIDUser(Session.SessionID)			
			if(hasSessionIDCard) then	
				Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)	
				call objCarrelloUser.updateIDUtenteCarrello(objCarrelloUser.getIDCarrello(), id_user)
				Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
			else
				Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
			end if			
				
			for each x in arrPromotional
				arrTmp = split(Trim(x), "|", -1, 1)
				'call objLogger.write("arrTmp(0): "&arrTmp(0)&" - arrTmp(1): "&arrTmp(1), "system", "debug")
				call objAds.deleteAdsPromotion(id_ads, arrTmp(0), objConn)
				call objAds.insertAdsPromotion(id_ads, arrTmp(0), arrTmp(1), 0, now(), objConn)
				call objProdPerCarr.delItem(objCarrelloUser.getIDCarrello(), arrTmp(0), 0, objConn)
				call objProdPerCarr.addItem(objCarrelloUser.getIDCarrello(), arrTmp(0), 0, 1, 2, false, objConn)
			next			
			redirectPage=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_ads="&id_ads
		end if

		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objProdPerCarr = nothing
		Set carrello = nothing		
		Set objAds = nothing
		Set objUserLogged = nothing
		response.Redirect(redirectPage)		
	else
		'/**
		'* ads da inserire e recupero Max(ID) 
		'*/	
		Dim adMaxID
		
		Set objDB = New DBManagerClass
		Set objConn = objDB.openConnection()
		objConn.BeginTrans		
			
		adMaxID = objAds.insertAds(id_element, id_utente, phone, ads_type, price, dta_ins, objConn)
		call objLogger.write("inserito annuncio --> id: "&adMaxID, objUserLogged.getUserName(), "info")	
		
		'********* GESTISCO L'ACQUISTO DI PROMOZIONI ADS SE PRESENTI
		if(UBound(arrPromotional)>=0)then
			'call objLogger.write("promozione annunci", "system", "debug")		
			
			hasSessionIDCard = carrello.findCarrelloByIDUser(Session.SessionID)			
			if(hasSessionIDCard) then	
				Set objCarrelloUser = carrello.getCarrelloByIDUser(Session.SessionID)	
				call objCarrelloUser.updateIDUtenteCarrello(objCarrelloUser.getIDCarrello(), id_user)
				Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
			else
				Set objCarrelloUser = carrello.getCarrelloByIDUser(id_user)
			end if
			
			for each x in arrPromotional
				arrTmp = split(Trim(x), "|", -1, 1)
				call objAds.insertAdsPromotion(adMaxID, arrTmp(0), arrTmp(1), 0, now(), objConn)				
				call objProdPerCarr.addItem(objCarrelloUser.getIDCarrello(), arrTmp(0), 0, 1, 2, false, objConn)
			next
			redirectPage=Application("baseroot")&Application("dir_upload_templ")&"shopping-card/card.asp?id_ads="&adMaxID
		end if
						
		if objConn.Errors.Count = 0 then
			objConn.CommitTrans
		else
			objConn.RollBackTrans
			response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
		end if
		
		Set objDB = nothing
		Set objProdPerCarr = nothing
		Set carrello = nothing				
		Set objAds = nothing
		Set objUserLogged = nothing
		response.Redirect(redirectPage)				
	end if

	Set objLogger = nothing

	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>