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

Dim objMargini, objListaMargini, objGroup, objListaGroup, objRules, objListaRules
Set objGroup = New UserGroupClass
Set objMargini = New MarginDiscountClass
Set objRules = New BusinessRulesClass

Dim totPages, itemsXpageMargin, numPageMargin,itemsXpageGroup, numPageGroup,itemsXpageRules, numPageRules

showTab="usrgroup"
if(request("showtab")<>"")then
	showTab=request("showtab")
end if


if not(request("itemsMargin") = "") then
	session("marginItems") = request("itemsMargin")
	itemsXpageMargin = session("marginItems")
	session("marginPage") = 1
else
	if not(session("marginItems") = "") then
		itemsXpageMargin = session("marginItems")
	else
		session("marginItems") = 20
		itemsXpageMargin = session("marginItems")
	end if
end if

if (showTab="margindiscount") AND not(request("page") = "") then
	session("marginPage") = request("page")
	numPageMargin = session("marginPage")
else
	if not(session("marginPage") = "") then
		numPageMargin = session("marginPage")
	else
		session("marginPage") = 1
		numPageMargin = session("marginPage")
	end if
end if



if not(request("itemsGroup") = "") then
	session("groupItems") = request("itemsGroup")
	itemsXpageGroup = session("groupItems")
	session("groupPage") = 1
else
	if not(session("groupItems") = "") then
		itemsXpageGroup = session("groupItems")
	else
		session("groupItems") = 20
		itemsXpageGroup = session("groupItems")
	end if
end if

if (showTab="usrgroup") AND not(request("page") = "") then
	session("groupPage") = request("page")
	numPageGroup = session("groupPage")
else
	if not(session("groupPage") = "") then
		numPageGroup = session("groupPage")
	else
		session("groupPage") = 1
		numPageGroup = session("groupPage")
	end if
end if



if not(request("itemsRules") = "") then
	session("rulesItems") = request("itemsRules")
	itemsXpageRules = session("rulesItems")
	session("rulesPage") = 1
else
	if not(session("rulesItems") = "") then
		itemsXpageRules = session("rulesItems")
	else
		session("rulesItems") = 20
		itemsXpageRules = session("rulesItems")
	end if
end if

if (showTab="businessrules") AND not(request("page") = "") then
	session("rulesPage") = request("page")
	numPageRules = session("rulesPage")
else
	if not(session("rulesPage") = "") then
		numPageRules = session("rulesPage")
	else
		session("rulesPage") = 1
		numPageRules = session("rulesPage")
	end if
end if
%>