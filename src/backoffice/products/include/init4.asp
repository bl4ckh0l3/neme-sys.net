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

Set objField = New ProductFieldClass
Set objFieldGroup = New ProductFieldGroupClass

'/**
'* recupero i valori della news selezionata se id_field <> -1
'*/
Dim id_field, description, idGroup,typeField,typeContent,values,order,required,enabled,editable, maxLenght, objDispGroup
id_field = request("id_field")
description = ""
typeField = null
typeContent = null
values = ""
idGroup = null
order = 0
required = 0
enabled = 0
editable = 0
maxLenght = null
objDispGroup = null

Set typeList = objField.getListaTypeField()
Set typeContentList = objField.getListaTypeContent()

On Error resume next
Set objDispGroup = objFieldGroup.getListProductFieldGroup()
if(Err.number <>0)then
'response.write(Err.description)
end if

if (Cint(id_field) <> -1) then
	Dim objField, objSelField
	Set objSelField = objField.findProductFieldById(id_field)
	
	id_field = objSelField.getID()
	description = objSelField.getDescription()			
	typeField = objSelField.getTypeField()			
	typeContent = objSelField.getTypeContent()			
	values = objSelField.getValues()	
	idGroup = objSelField.getIdGroup()	
	order = objSelField.getOrder()	
	required = objSelField.getRequired()	
	enabled = objSelField.getEnabled()
	editable = objSelField.getEditable()
	maxLenght = objSelField.getMaxLenght()
	Set objSelField = Nothing
end if

Set objFieldGroup = nothing
%>