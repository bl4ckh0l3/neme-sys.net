<!-- #include virtual="/editor/include/IncludeShopObjectList.inc" -->

<%
if not(isEmpty(Session("objCMSUtenteLogged"))) then
	Dim objUserLogged, objUserLoggedTmp
	Set objUserLoggedTmp = new UserClass
	Set objUserLogged = objUserLoggedTmp.findUserByID(Session("objCMSUtenteLogged"))
	Set objUserLoggedTmp = nothing
	Dim strRuoloLogged
	strRuoloLogged = objUserLogged.getRuolo()
	if not(strComp(Cint(strRuoloLogged), Application("admin_role"), 1) = 0) then
		response.Redirect(Application("baseroot")&Application("error_page")&"?error=002")
	end if
	
	Dim id_group, shortDesc, longDesc, bolDelGroup,bolDefGroup,taxsGroup
	id_group = request("id_group")
	shortDesc = request("short_desc")
	longDesc = request("long_desc")
	bolDelGroup = request("delete_group")
	bolDefGroup = request("default_group")
	taxsGroup = request("taxs_group")
	
	Dim objGroup
	Set objGroup = New UserGroupClass

	if not(strComp(bolDelGroup, "del", 1) = 0) AND (bolDefGroup="1") then
		if(strComp(typename(objGroup.findUserGroupDefault()), "UserGroupClass", 1) = 0)then
			if(Trim(objGroup.findUserGroupDefault().getID()) <> Trim(id_group))then
				response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=usrgroup&err=1")	
			end if
		end if
	end if

	if (Cint(id_group) <> -1) then
		if(strComp(bolDelGroup, "del", 1) = 0) then
			call objGroup.deleteUserGroup(id_group)
			response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=usrgroup")	
		end if
		
		call objGroup.modifyUserGroup(id_group, shortDesc, longDesc,bolDefGroup,taxsGroup)
		Set objGroup = nothing
		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=usrgroup")		
	else
		call objGroup.insertUserGroup(shortDesc, longDesc,bolDefGroup,taxsGroup)
		Set objGroup = nothing
		response.Redirect(Application("baseroot")&"/editor/margini/ListaMargini.asp?showtab=usrgroup")				
	end if

	Set objUserLogged = nothing
else
	response.Redirect(Application("baseroot")&"/login.asp")
end if
%>