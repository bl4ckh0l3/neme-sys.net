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

Dim objProdotti, objListaProdotti, objProdField, objListaField
Set objProdotti = New ProductsClass
Set objProdField = new ProductFieldClass

Dim order_prod_by

if not(request("order_by") = "") then
	session("order_prod_by") = request("order_by")
	order_prod_by = session("order_prod_by")
else
	if not(session("order_prod_by") = "") then
		order_prod_by = session("order_prod_by")
	else
		session("order_prod_by") = 1
		order_prod_by = session("order_prod_by")
	end if
end if

Dim totPages, itemsXpageProd, numPageProd,itemsXpageField, numPageField

showTab="prodlist"
if(request("showtab")<>"")then
	showTab=request("showtab")
end if

if not(request("itemsProd") = "") then
	session("prodottiItems") = request("itemsProd")
	itemsXpageProd = session("prodottiItems")
	session("prodottiPage") = 1
else
	if not(session("prodottiItems") = "") then
		itemsXpageProd = session("prodottiItems")
	else
		session("prodottiItems") = 20
		itemsXpageProd = session("prodottiItems")
	end if
end if

if (showTab="prodlist") AND not(request("page") = "") then
	session("prodottiPage") = request("page")
	numPageProd = session("prodottiPage")
else
	if not(session("prodottiPage") = "") then
		numPageProd = session("prodottiPage")
	else
		session("prodottiPage") = 1
		numPageProd = session("prodottiPage")
	end if
end if	


if not(request("itemsField") = "") then
	session("fieldItems") = request("itemsField")
	itemsXpageField = session("fieldItems")
	session("fieldPage") = 1
else
	if not(session("fieldItems") = "") then
		itemsXpageField = session("fieldItems")
	else
		session("fieldItems") = 20
		itemsXpageField = session("fieldItems")
	end if
end if

if (showTab="prodfield") AND not(request("page") = "") then
	session("fieldPage") = request("page")
	numPageField = session("fieldPage")
else
	if not(session("fieldPage") = "") then
		numPageField = session("fieldPage")
	else
		session("fieldPage") = 1
		numPageField = session("fieldPage")
	end if
end if


Dim target_prod_param
target_prod_param = ""

Dim CategoryClassTmp, objListCatXProdTmp
Set CategoryClassTmp = new CategoryClass
%>