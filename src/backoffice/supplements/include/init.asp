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

Dim objTassa, objListaTasse, objTaxsGroup, objListaTaxsGroup
Set objTassa = New TaxsClass
Set objTaxsGroup = New TaxsGroupClass

Dim totPages, itemsXpageTax, numPageTax,itemsXpageGroup, numPageGroup

showTab="taxslist"
if(request("showtab")<>"")then
	showTab=request("showtab")
end if

if not(request("itemsTax") = "") then
	session("taxsItems") = request("itemsTax")
	itemsXpageTax = session("taxsItems")
	session("taxsPage") = 1
else
	if not(session("taxsItems") = "") then
		itemsXpageTax = session("taxsItems")
	else
		session("taxsItems") = 20
		itemsXpageTax = session("taxsItems")
	end if
end if

if (showTab="taxslist") AND not(request("page") = "") then
	session("taxsPage") = request("page")
	numPageTax = session("taxsPage")
else
	if not(session("taxsPage") = "") then
		numPageTax = session("taxsPage")
	else
		session("taxsPage") = 1
		numPageTax = session("taxsPage")
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

if (showTab="taxsgroup") AND not(request("page") = "") then
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
%>