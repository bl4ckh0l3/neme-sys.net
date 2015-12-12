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
if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
end if
Set objUserLogged = nothing

'/**
'* recupero i valori della news selezionata se id_currency <> -1
'*/
Dim id_margine, dblMargine, dblSconto, bolProdDisc, bolUserdisc
Dim objGroup, objDispGroup, objSelGroup, objAlreadyUsedGroup

id_margine = request("id_margine")
dblMargine = 0
dblSconto = 0
bolProdDisc = 0
bolUserdisc = 0

Set objGroup = new UserGroupClass

On Error Resume Next
Set objDispGroup = objGroup.getListaUserGroup()
Set objAlreadyUsedGroup = objGroup.getUserGroupXMarginDiscount(null)
if(Err.number <> 0) then
end if

if (Cint(id_margine) <> -1) then
	Dim objMargine, objSelMargine
	Set objMargine = New MarginDiscountClass
	Set objSelMargine = objMargine.findMarginDiscountByID(id_margine)
	Set objMargine = nothing
	
	id_margine = objSelMargine.getID()
	dblMargine = objSelMargine.getMargin()		
	dblSconto = objSelMargine.getDiscount()	
	bolProdDisc = objSelMargine.isApplyProdDiscount()	
	bolUserdisc = objSelMargine.isApplyUserDiscount()		
	Set objSelMargine = Nothing

	'*** recupero la lista di gruppi uente e la lista di gruppi per margine
	On Error Resume Next
	Set objSelGroup = objGroup.getUserGroupXMarginDiscount(id_margine)
	if(Err.number <> 0) then
	end if
end if

Set objGroup = nothing
%>