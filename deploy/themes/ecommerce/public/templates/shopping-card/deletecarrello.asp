<%@ Language=VBScript %>
<% 
option explicit
On error resume next
%>
<!-- #include virtual="/common/include/IncludeShopObjectList.inc" -->
<!-- #include virtual="/common/include/Objects/CardClass.asp" -->
<!-- #include virtual="/common/include/Objects/ProductsCardClass.asp" -->

<%	
'/**
'* Recupero tutti i parametri dal form e li elaboro
'*/	
Dim id_carrello	

id_carrello = request("id_carrello_to_delete")

Dim objCarrello
Set objCarrello = New CardClass	

call objCarrello.deleteCarrello(id_carrello)

Set objCarrello = nothing
Set objUserLogged = nothing			
response.Redirect(Application("baseroot")&Application("dir_upload_templ")&"shopping-card/DelCarrelloConfirmed.asp")

' If something fails inside the script, but the exception is handled
If Err.Number<>0 then
	response.Redirect(Application("baseroot")&Application("error_page")&"?error="&Err.description)
end if
%>