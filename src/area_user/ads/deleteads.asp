<%@ Language=VBScript %>
<!-- #include virtual="/common/include/IncludeObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/AdsClass.asp" -->
<%
if not(isEmpty(Session("objUtenteLogged"))) then
	On error resume next
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("guest_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	Dim objLogger
	Set objLogger = New LogClass
	
	'/**
	'* Recupero tutti i parametri dal form e li elaboro
	'*/	
	Dim id_ads	
	id_ads = request("id_ads_to_delete")
					
	Dim objAds
	Set objAds = New AdsClass
	call objAds.deleteAds(id_ads)
	Set objAds = nothing
	
	call objLogger.write("cancellato annuncio --> id: "&id_ads, objUserLogged.getUserName(), "info")
	
	Set objUserLogged = nothing	
	
	Set objLogger = nothing
	
	response.Redirect(Application("baseroot")&"/area_user/ads/ListaNews.asp")				


	' If something fails inside the script, but the exception is handled
	If Err.Number<>0 then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
	end if
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>